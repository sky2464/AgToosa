"""Core loader, closed-schema validation, and bounded rendering."""

from __future__ import annotations

import datetime as dt
import json
import re
from pathlib import Path

from product_truth_schema import load_schema, validate_instance

VERSION = "1"
MAX_CONTRACT_BYTES = 1_048_576
MAX_FINDINGS = 100
ROOT_KEYS = {
    "$schema", "schema_version", "contract_id", "contract_version",
    "static_claim_boundary", "path_policy", "commands", "targets", "platforms",
    "dependencies", "claims", "governed_surfaces", "auxiliary_artifacts",
}
OBJECT_KEYS = {
    "static_claim_boundary": {"allowed", "forbidden"},
    "path_policy": {"id", "generated_root", "installed_root", "candidate_files",
                    "max_file_bytes", "max_entries", "max_string_bytes", "exemptions"},
    "exemption": {"id", "kind", "paths", "owner", "reason"},
    "command": {"id", "phase", "invocation", "modes", "canonical_workflow",
                "operating_context", "question_budget", "mutation_class",
                "approval_gate", "phase_stop", "lifecycle_close", "state_reads",
                "state_writes", "side_effects", "dependencies", "failure_policy",
                "portable_invariants"},
    "question_budget": {"max_questions", "quick_max"},
    "target": {"id", "directory", "suffix", "format", "artifact_kind",
               "renderer_version", "managed_marker", "supported_fields",
               "unsupported_fields", "extensions"},
    "platform": {"id", "install_token", "target_ids", "aliases",
                 "preserved_identity", "non_inheriting_products",
                 "evidence_inheritance_from"},
    "dependency": {"id", "commands", "affected_operations", "affected_platforms",
                   "version_constraint", "preflight_probe", "missing_behavior",
                   "backend_class", "network_access"},
    "claim": {"id", "capability_id", "target_id", "status", "owner",
              "evidence_class", "evidence_ref", "evidence_commit",
              "evidence_tool_version", "governed_surfaces", "owner_contract_id",
              "owner_contract_fingerprint", "verified_at", "expires_at",
              "verifier", "notes"},
    "surface": {"id", "path", "claim_ids", "marker_id"},
    "auxiliary": {"kind", "path_glob", "coverage", "reason"},
}
REQUIRED_TARGETS = {
    "cursor.project-commands", "windsurf.workflows", "anthropic.claude-code",
    "google.gemini-cli", "github.copilot-vscode", "openai.codex-cli",
}
BACKENDS = {"native", "bash-delegated", "redirect-only", "unsupported",
            "optional/degraded"}
FORBIDDEN_PUBLIC = [
    (re.compile(r"\bfully supported\b", re.I), "fully supported"),
    (re.compile(r"\bzero[- ]downtime\b", re.I), "zero-downtime"),
    (re.compile(r"\bfull (?:feature |powershell )?parity\b", re.I), "full parity"),
    (re.compile(r"\bworks with any (?:ai )?(?:assistant|tool)\b", re.I), "universal support"),
    (re.compile(r"\bonly multi-assistant\b", re.I), "superiority"),
    (re.compile(r"\bstrongest non-agtoosa\b", re.I), "superiority"),
    (re.compile(r"\benforced during every\b", re.I), "unsupported enforcement"),
]
NEGATIVE_CONTEXT = re.compile(
    r"must not|does not|do not|not claim|without claiming|forbidden|cannot claim|"
    r"only then|not automatically|not generator-enforced", re.I
)


class Findings:
    def __init__(self) -> None:
        self.items: list[str] = []

    def add(self, message: str) -> None:
        if len(self.items) < MAX_FINDINGS:
            self.items.append(message)

    def emit(self) -> int:
        if self.items:
            for item in self.items:
                print(f"FAIL: {item}")
            return 1
        return 0


def duplicate_guard(pairs):
    out = {}
    for key, value in pairs:
        if key in out:
            raise ValueError(f"duplicate field: {key}")
        out[key] = value
    return out


def reject_nonfinite(value: str):
    raise ValueError(f"non-finite JSON number forbidden: {value}")


def load_contract(path: Path, findings: Findings) -> dict:
    try:
        if path.stat().st_size > MAX_CONTRACT_BYTES:
            findings.add("contract exceeds bounded-size limit")
            return {}
        data = json.loads(path.read_text(encoding="utf-8"),
                          object_pairs_hook=duplicate_guard,
                          parse_constant=reject_nonfinite)
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as exc:
        findings.add(f"contract load failed: {exc}")
        return {}
    scan_inert(data, findings)
    return data


def scan_inert(value, findings: Findings, where="$", depth=0, counter=None) -> None:
    if counter is None:
        counter = [0]
    counter[0] += 1
    if counter[0] > 4096:
        findings.add("contract exceeds 4096-entry bound")
        return
    if depth > 20:
        findings.add(f"{where}: nesting exceeds depth bound")
        return
    if isinstance(value, dict):
        for key, child in value.items():
            if key.lower() in {"include", "includes", "import", "imports",
                               "dynamic_include", "command", "exec", "eval"}:
                findings.add(f"{where}.{key}: dynamic include/executable field forbidden")
            scan_inert(child, findings, f"{where}.{key}", depth + 1, counter)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            scan_inert(child, findings, f"{where}[{index}]", depth + 1, counter)
    elif isinstance(value, str):
        if len(value.encode("utf-8")) > 4096:
            findings.add(f"{where}: string exceeds bound")
        if re.search(r"\$\{|\$\(|\{\{|<%|\beval\s*\(|\bexec\s*\(", value):
            findings.add(f"{where}: interpolation or executable expression forbidden")


def exact_fields(obj, expected: set[str], where: str, findings: Findings) -> None:
    if not isinstance(obj, dict):
        findings.add(f"{where}: expected object")
        return
    for key in sorted(set(obj) - expected):
        findings.add(f"{where}: unknown field '{key}'")
    for key in sorted(expected - set(obj)):
        findings.add(f"{where}: missing field '{key}'")


def safe_lexical_path(value: str, where: str, findings: Findings,
                      allow_glob=False) -> None:
    if not isinstance(value, str) or not value:
        findings.add(f"{where}: path must be a non-empty string")
        return
    if value.startswith(("/", "\\")) or re.match(r"^[A-Za-z]:", value):
        findings.add(f"{where}: absolute repository path forbidden")
    parts = value.replace("\\", "/").split("/")
    if ".." in parts:
        findings.add(f"{where}: traversal path forbidden")
    allowed = r"^[A-Za-z0-9._/*-]+$" if allow_glob else r"^[A-Za-z0-9._/-]+$"
    if not re.match(allowed, value):
        findings.add(f"{where}: invalid repository path grammar")


def unique_ids(items, where: str, findings: Findings) -> None:
    seen = set()
    for item in items:
        item_id = item.get("id") if isinstance(item, dict) else None
        if not isinstance(item_id, str):
            findings.add(f"{where}: item missing stable id")
        elif item_id in seen:
            findings.add(f"{where}: duplicate id '{item_id}'")
        else:
            seen.add(item_id)


def validate_schema(data: dict, root: Path, findings: Findings) -> None:
    exact_fields(data, ROOT_KEYS, "$", findings)
    if not isinstance(data, dict) or not data:
        return
    if data.get("$schema") != "product-truth-v1.schema.json":
        findings.add("$schema must bind product-truth-v1.schema.json")
    if data.get("schema_version") != "1":
        findings.add("unsupported schema_version")
    schema_path = root / "contracts/product-truth-v1.schema.json"
    try:
        schema_path.resolve(strict=True).relative_to(root.resolve(strict=True))
    except (OSError, ValueError):
        findings.add("closed schema file is missing or resolves through a symlink escape")
        return
    schema = load_schema(schema_path, findings.add)
    if schema is None:
        return
    validate_instance(data, schema, schema, findings.add)
    if findings.items:
        return
    exact_fields(data.get("static_claim_boundary"), OBJECT_KEYS["static_claim_boundary"],
                 "static_claim_boundary", findings)
    policy = data.get("path_policy", {})
    exact_fields(policy, OBJECT_KEYS["path_policy"], "path_policy", findings)
    for key in ("generated_root", "installed_root"):
        safe_lexical_path(policy.get(key), f"path_policy.{key}", findings)
    for index, value in enumerate(policy.get("candidate_files", [])):
        safe_lexical_path(value, f"path_policy.candidate_files[{index}]", findings)
    for index, item in enumerate(policy.get("exemptions", [])):
        exact_fields(item, OBJECT_KEYS["exemption"], f"exemption[{index}]", findings)
        if not item.get("owner") or not item.get("reason"):
            findings.add(f"exemption[{index}]: owner and reason are required")
        for value in item.get("paths", []):
            safe_lexical_path(value, f"exemption[{index}].paths", findings, True)
    for kind in ("commands", "targets", "platforms", "dependencies", "claims",
                 "governed_surfaces"):
        unique_ids(data.get(kind, []), kind, findings)
    for index, item in enumerate(data.get("commands", [])):
        exact_fields(item, OBJECT_KEYS["command"], f"commands[{index}]", findings)
        exact_fields(item.get("question_budget"), OBJECT_KEYS["question_budget"],
                     f"commands[{index}].question_budget", findings)
        safe_lexical_path(item.get("canonical_workflow"),
                          f"commands[{index}].canonical_workflow", findings)
    for index, item in enumerate(data.get("targets", [])):
        exact_fields(item, OBJECT_KEYS["target"], f"targets[{index}]", findings)
        safe_lexical_path(item.get("directory"), f"targets[{index}].directory", findings)
        extensions = item.get("extensions", {})
        if not isinstance(extensions, dict) or any(not k.startswith("x-") for k in extensions):
            findings.add(f"targets[{index}]: extensions must be namespaced with x-")
    for kind in ("platform", "dependency", "claim", "surface", "auxiliary"):
        collection = {"platform": "platforms", "dependency": "dependencies",
                      "claim": "claims", "surface": "governed_surfaces",
                      "auxiliary": "auxiliary_artifacts"}[kind]
        for index, item in enumerate(data.get(collection, [])):
            exact_fields(item, OBJECT_KEYS[kind], f"{collection}[{index}]", findings)
            if kind == "surface":
                safe_lexical_path(item.get("path"), f"{collection}[{index}].path", findings)
            if kind == "auxiliary":
                safe_lexical_path(item.get("path_glob"),
                                  f"{collection}[{index}].path_glob", findings, True)
    if len(data.get("commands", [])) > 64 or len(data.get("claims", [])) > 256:
        findings.add("contract collection exceeds bounded-size limit")


def repo_path(root: Path, relative: str, findings: Findings) -> Path | None:
    candidate = root / relative
    try:
        resolved_root = root.resolve(strict=True)
        resolved = candidate.resolve(strict=True)
        resolved.relative_to(resolved_root)
    except (OSError, ValueError):
        findings.add(f"{relative}: missing path or symlink escape")
        return None
    return candidate


def command_name(command: dict) -> str:
    return command["id"].removeprefix("command.")


def adapter_path(root: Path, target: dict, command: dict) -> Path:
    name = f"agtoosa-{command_name(command)}{target['suffix']}"
    return root / target["directory"] / name


def managed_block(command: dict) -> str:
    begin = f"<!-- AGTOOSA PRODUCT TRUTH START: {command['id']} -->"
    end = f"<!-- AGTOOSA PRODUCT TRUTH END: {command['id']} -->"
    modes = ", ".join(f"`{mode}`" for mode in command["modes"])
    budget = command["question_budget"]
    return "\n".join([
        begin,
        "<!-- Generated by scripts/product-truth.py; edit the contract, not this block. -->",
        f"- Command: `{command['invocation']}` (`{command['id']}`)",
        f"- Canonical workflow: `{command['canonical_workflow']}`",
        f"- Modes: {modes}",
        f"- Question budget: max {budget['max_questions']}; Quick max: {budget['quick_max']}",
        f"- Mutation class: `{command['mutation_class']}`",
        f"- Approval gate: {'required' if command['approval_gate'] else 'none'}",
        f"- Phase stop: {'required' if command['phase_stop'] else 'none'}",
        f"- Lifecycle close: `{command['lifecycle_close']}`",
        end,
    ])


def claim_block(surface: dict, claims_by_id: dict, dependencies: list[dict],
                as_of: dt.date) -> str:
    begin = f"<!-- AGTOOSA PRODUCT TRUTH START: {surface['marker_id']} -->"
    end = f"<!-- AGTOOSA PRODUCT TRUTH END: {surface['marker_id']} -->"
    lines = [begin,
             "<!-- Static conformance and freshness only; not behavioral or provenance proof. -->",
             "| Claim ID | Target | Status | Evidence class | Expires |",
             "| --- | --- | --- | --- | --- |"]
    for claim_id in surface["claim_ids"]:
        claim = claims_by_id[claim_id]
        expires = dt.date.fromisoformat(claim["expires_at"])
        status = claim["status"] if as_of <= expires else "stale/unverified"
        lines.append(f"| `{claim_id}` | `{claim['target_id']}` | {status} | "
                     f"{claim['evidence_class']} | {claim['expires_at']} |")
    if "network" in surface["id"]:
        lines += ["", "### Backend classification", "",
                  "| Operation ID | Backend | Commands | Network | Missing behavior |",
                  "| --- | --- | --- | --- | --- |"]
        for item in dependencies:
            commands = ", ".join(f"`{value}`" for value in item["commands"])
            lines.append(f"| `{item['id']}` | `{item['backend_class']}` | "
                         f"{commands} | {'yes' if item['network_access'] else 'no'} | "
                         f"{item['missing_behavior']} |")
    lines += [end]
    return "\n".join(lines)


def replace_block(text: str, block_id: str, expected: str,
                  where: str, findings: Findings) -> str | None:
    begin = f"<!-- AGTOOSA PRODUCT TRUTH START: {block_id} -->"
    end = f"<!-- AGTOOSA PRODUCT TRUTH END: {block_id} -->"
    if text.count(begin) != 1 or text.count(end) != 1:
        findings.add(f"{where}: requires exactly one existing managed block '{block_id}'")
        return None
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)
    return pattern.sub(expected, text, count=1)


def render(data: dict, root: Path, as_of: dt.date, apply: bool,
           findings: Findings) -> None:
    updates: dict[Path, str] = {}
    for target in data.get("targets", []):
        for command in data.get("commands", []):
            path = adapter_path(root, target, command)
            safe = repo_path(root, str(path.relative_to(root)), findings)
            if safe is None:
                continue
            text = path.read_text(encoding="utf-8")
            new = replace_block(text, command["id"], managed_block(command),
                                f"{target['id']}:{command['id']}", findings)
            if new is not None and new != text:
                if apply:
                    updates[path] = new
                else:
                    findings.add(f"{target['id']}:{command['id']}: managed block drift")
    claims = {item["id"]: item for item in data.get("claims", [])}
    for surface in data.get("governed_surfaces", []):
        path = root / surface["path"]
        safe = repo_path(root, surface["path"], findings)
        if safe is None:
            continue
        text = path.read_text(encoding="utf-8")
        expected = claim_block(surface, claims, data.get("dependencies", []), as_of)
        new = replace_block(text, surface["marker_id"], expected,
                            surface["path"], findings)
        if new is not None and new != text:
            if apply:
                updates[path] = new
            else:
                findings.add(f"{surface['path']}: managed claim block drift")
    if apply and not findings.items:
        temp_paths = {
            path: path.with_name(path.name + ".product-truth.tmp")
            for path in updates
        }
        for tmp in temp_paths.values():
            if tmp.exists() or tmp.is_symlink():
                findings.add(f"{tmp.relative_to(root)}: temporary render path already exists")
        if findings.items:
            return
        created: list[Path] = []
        try:
            for path, text in updates.items():
                tmp = temp_paths[path]
                with tmp.open("x", encoding="utf-8", newline="") as handle:
                    handle.write(text)
                created.append(tmp)
        except OSError as exc:
            findings.add(f"render staging failed before replacement: {exc}")
            for tmp in created:
                tmp.unlink(missing_ok=True)
            return
        for path, tmp in temp_paths.items():
            tmp.replace(path)
        print(f"PASS: render --apply updated {len(updates)} managed files")
    elif not apply and not findings.items:
        print("PASS: managed blocks match contract (check-only)")
