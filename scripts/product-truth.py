#!/usr/bin/env python3
"""Deterministic, offline validation for AgToosa's Product Truth Contract."""

from __future__ import annotations

import argparse
import datetime as dt
import fnmatch
import hashlib
import json
import re
from pathlib import Path

from product_truth_core import (
    BACKENDS, FORBIDDEN_PUBLIC, NEGATIVE_CONTEXT, REQUIRED_TARGETS, Findings,
    adapter_path, command_name, load_contract, render, repo_path, validate_schema,
)

def check_inventory(data: dict, root: Path, findings: Findings) -> None:
    commands = {command_name(item) for item in data["commands"]}
    target_ids = {item["id"] for item in data["targets"]}
    if target_ids != REQUIRED_TARGETS:
        findings.add(f"target inventory mismatch: {sorted(target_ids ^ REQUIRED_TARGETS)}")
    for target in data["targets"]:
        directory = repo_path(root, target["directory"], findings)
        if directory is None or not directory.is_dir():
            continue
        suffix = target["suffix"]
        found = set()
        for path in directory.glob(f"agtoosa-*{suffix}"):
            base = path.name[len("agtoosa-"):-len(suffix)]
            if base in found:
                findings.add(f"{target['id']}: duplicate command cell '{base}'")
            found.add(base)
        for extra in sorted(found - commands):
            findings.add(f"{target['id']}: unreviewed command cell '{extra}'")
        for missing in sorted(commands - found):
            findings.add(f"{target['id']}: missing command cell '{missing}'")
    if not data.get("auxiliary_artifacts"):
        findings.add("auxiliary artifact kinds require explicit exceptions")
    else:
        auxiliary = repo_path(root, "template/.codex/skills", findings)
        if auxiliary is None or not any(auxiliary.glob("agtoosa-*/SKILL.md")):
            findings.add("declared codex-skill auxiliary layer is missing")
    if not findings.items:
        print(f"PASS: inventory reconciled {len(commands)} commands x "
              f"{len(target_ids)} targets ({len(commands) * len(target_ids)} cells)")


def check_adapters(data: dict, root: Path, as_of: dt.date,
                   findings: Findings) -> None:
    render(data, root, as_of, False, findings)
    for target in data["targets"]:
        for command in data["commands"]:
            path = adapter_path(root, target, command)
            relative = str(path.relative_to(root))
            if repo_path(root, relative, findings) is None:
                continue
            text = path.read_text(encoding="utf-8")
            if command["canonical_workflow"] not in text:
                findings.add(f"{target['id']}:{command['id']}: canonical route missing")
            if command["id"] == "command.spec" and re.search(
                    r"quick[^\n]{0,100}(?:3 questions|2[–-]3)", text, re.I):
                findings.add(f"{target['id']}:{command['id']}: quick budget contradicts 2")
    if not findings.items:
        print("PASS: portable adapter invariants and five lifecycle goldens")


def exemption_matches(policy: dict, relative: str, line: str) -> bool:
    for item in policy["exemptions"]:
        if not any(fnmatch.fnmatch(relative, pattern) for pattern in item["paths"]):
            continue
        kind = item["kind"]
        if kind == "remote-url" and re.search(r"https?://\S*docs/", line):
            return True
        if kind == "dual-root-resolver":
            return True
        if kind == "maintainer-dogfood" and re.search(
                r"maintainer|dogfood|source repositor", line, re.I):
            return True
        if kind == "safe-example" and re.search(r"example|fixture", line, re.I):
            return True
    return False


def exact_case_exists(root: Path, relative: str) -> bool:
    current = root
    for part in Path(relative).parts:
        try:
            names = {entry.name for entry in current.iterdir()}
        except OSError:
            return False
        if part not in names:
            return False
        current = current / part
    return True


def check_paths(data: dict, root: Path, findings: Findings) -> None:
    policy = data["path_policy"]
    for relative in policy["candidate_files"]:
        path = repo_path(root, relative, findings)
        if path is None:
            continue
        if not exact_case_exists(root, relative):
            findings.add(f"{relative}: exact-case generated inventory path missing")
            continue
        if path.stat().st_size > policy["max_file_bytes"]:
            findings.add(f"{relative}: generated file exceeds bound")
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if "docs/" in line and not exemption_matches(policy, relative, line):
                findings.add(f"{relative}:{number}: lowercase generated local path 'docs/'")
    if not findings.items:
        print("PASS: generated local references resolve with exact Docs/ casing")


def canonical_json(value: dict) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"),
                      ensure_ascii=False).encode("utf-8")


def owner_map(data: dict) -> dict:
    values = [data["path_policy"], *data["commands"], *data["targets"],
              *data["platforms"], *data["dependencies"]]
    return {item["id"]: item for item in values}


def check_platforms(data: dict, root: Path, findings: Findings) -> None:
    platforms = {item["install_token"]: item for item in data["platforms"]}
    if "copilot" not in platforms or "vscode" not in platforms:
        findings.add("copilot and vscode must remain distinct canonical identities")
    elif platforms["copilot"]["id"] == platforms["vscode"]["id"]:
        findings.add("vscode identity collapsed into copilot")
    for item in data["platforms"]:
        overlap = set(item["non_inheriting_products"]) & set(item["evidence_inheritance_from"])
        if overlap:
            findings.add(f"{item['id']}: evidence inheritance forbidden for {sorted(overlap)}")
    ps_path = repo_path(root, "agtoosa.ps1", findings)
    bash_path = repo_path(root, "agtoosa.sh", findings)
    if ps_path is None or bash_path is None:
        return
    ps = ps_path.read_text(encoding="utf-8")
    bash = bash_path.read_text(encoding="utf-8")
    if "'^(6|vscode)$' { & $addPlatform 'vscode'; break }" not in ps:
        findings.add("PowerShell vscode token collapses into copilot identity")
    if "6|vscode)" not in bash:
        findings.add("Bash vscode token is not preserved")
    if not findings.items:
        print("PASS: Bash/PowerShell preserve copilot and vscode identities")


def check_dependencies(data: dict, root: Path, available: str | None,
                       findings: Findings) -> None:
    for item in data["dependencies"]:
        if item["backend_class"] not in BACKENDS:
            findings.add(f"{item['id']}: invalid backend classification")
    if available is not None:
        commands = {value.strip().lower() for value in available.split(",") if value.strip()}
        for item in data["dependencies"]:
            for command in item["commands"]:
                if command.lower() not in commands:
                    findings.add(f"{item['id']} ({item['backend_class']}): "
                                 f"missing prerequisite: {command}")
    network_doc = repo_path(root, "docs/AgToosa_Network_Matrix.md", findings)
    if network_doc is not None:
        text = network_doc.read_text(encoding="utf-8")
        if "Backend classification" not in text:
            findings.add("human network help missing Backend classification truth")
        for item in data["dependencies"]:
            if item["id"] not in text or item["backend_class"] not in text:
                findings.add(f"human network help drifted for {item['id']}")
    if not findings.items:
        print("PASS: operation backends and dependencies are classified before mutation")


def validate_ref(ref: str) -> bool:
    return bool(re.fullmatch(r"(?:v\d+\.\d+\.\d+|main|master)", ref))


def check_windows_ref(root: Path, ref: str | None, archive_map: str | None,
                      findings: Findings) -> None:
    script_path = repo_path(root, "bootstrap.ps1", findings)
    if script_path is None:
        return
    script = script_path.read_text(encoding="utf-8")
    if "function Test-ReleaseRef" not in script or "Test-ReleaseRef $Ref" not in script:
        findings.add("bootstrap.ps1 lacks fail-closed release-ref validation")
    if ref is not None:
        if not validate_ref(ref):
            findings.add(f"invalid release ref: {ref}")
            return
        if archive_map:
            mapping = json.loads(Path(archive_map).read_text(encoding="utf-8"))
            if ref not in mapping:
                findings.add(f"unavailable release ref: {ref}")
            else:
                expected = f"refs/tags/{ref}" if ref.startswith("v") else f"refs/heads/{ref}"
                if mapping[ref] != expected:
                    findings.add(f"release ref rewritten: expected {expected}")
                else:
                    print(f"PASS: exact archive selection {mapping[ref]}")
    elif not findings.items:
        print("PASS: Windows bootstrap exact-ref contract")


def scan_public_file(path: Path, findings: Findings) -> None:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        findings.add(f"{path}: public scan failed: {exc}")
        return
    for number, line in enumerate(lines, 1):
        if NEGATIVE_CONTEXT.search(line):
            continue
        for pattern, label in FORBIDDEN_PUBLIC:
            if pattern.search(line):
                findings.add(f"{path}:{number}: unsupported public claim ({label})")


def check_claims(data: dict, root: Path, as_of: dt.date,
                 scan_file: str | None, findings: Findings) -> None:
    owners = owner_map(data)
    surfaces = {item["id"]: item for item in data["governed_surfaces"]}
    claim_ids = {item["id"] for item in data["claims"]}
    for claim in data["claims"]:
        try:
            verified = dt.date.fromisoformat(claim["verified_at"])
            expires = dt.date.fromisoformat(claim["expires_at"])
        except ValueError:
            findings.add(f"{claim['id']}: invalid freshness date")
            continue
        if expires < verified or (expires - verified).days > 90:
            findings.add(f"{claim['id']}: freshness window exceeds 90 days")
        owner = owners.get(claim["owner_contract_id"])
        if owner is None:
            findings.add(f"{claim['id']}: unknown owner_contract_id")
        else:
            current = hashlib.sha256(canonical_json(owner)).hexdigest()
            if current != claim["owner_contract_fingerprint"]:
                findings.add(f"{claim['id']}: owner fingerprint changed; stale/unverified")
        if as_of > expires:
            findings.add(f"{claim['id']}: expired on {expires}; stale/unverified")
        unknown_surfaces = set(claim["governed_surfaces"]) - set(surfaces)
        if unknown_surfaces:
            findings.add(f"{claim['id']}: unknown governed surfaces {sorted(unknown_surfaces)}")
    for surface in surfaces.values():
        unknown = set(surface["claim_ids"]) - claim_ids
        if unknown:
            findings.add(f"{surface['id']}: unknown claim IDs {sorted(unknown)}")
    if scan_file:
        scan_path = Path(scan_file).resolve()
        try:
            scan_path.relative_to(root.resolve(strict=True))
        except (OSError, ValueError):
            findings.add("public scan file resolves outside the repository root")
        else:
            scan_public_file(scan_path, findings)
    else:
        for surface in surfaces.values():
            path = repo_path(root, surface["path"], findings)
            if path is not None:
                scan_public_file(path, findings)
        render(data, root, as_of, False, findings)
    if not findings.items:
        print("PASS: governed claims are fresh, bounded, and non-contradictory")


def check_boundaries(data: dict, findings: Findings) -> None:
    boundary = data["static_claim_boundary"]
    overlap = set(boundary["allowed"]) & set(boundary["forbidden"])
    for name in sorted(overlap):
        findings.add(f"forbidden conclusion listed as allowed: {name}")
    if not set(["host-recognition", "scenario-tested-behavior",
                "authenticated-provenance", "native-sandboxing",
                "full-powershell-parity", "universal-assistant-support"]).issubset(
                    set(boundary["forbidden"])):
        findings.add("static claim boundary omits required forbidden conclusions")
    if not findings.items:
        print("PASS: conclusions limited to static conformance and freshness")


def check_ci(data: dict, root: Path, findings: Findings) -> None:
    workflow = root / ".github/workflows/ci.yml"
    tests = root / "tests/product-truth.bats"
    plan = root / "docs/AgToosa_TestPlan-DEV-118.md"
    for path in (workflow, tests, plan):
        relative = str(path.relative_to(root))
        if repo_path(root, relative, findings) is None:
            findings.add(f"{path.relative_to(root)}: required CI evidence file missing")
            return
    ci_text = workflow.read_text(encoding="utf-8")
    if "tests/product-truth.bats" not in ci_text or "render --check" not in ci_text:
        findings.add("focused Product Truth CI gate is missing or incomplete")
    test_text = tests.read_text(encoding="utf-8")
    plan_text = plan.read_text(encoding="utf-8")
    for number in range(1, 13):
        test_id = f"PTC-{number:03d}"
        if test_id not in test_text or test_id not in plan_text:
            findings.add(f"{test_id}: Must AC test or mapping missing")
    adjacent_path = repo_path(root, "tests/agtoosa.bats", findings)
    if adjacent_path is None:
        return
    adjacent = adjacent_path.read_text(encoding="utf-8")
    for family in ("PN", "WP2", "ACC", "NET", "PSP", "CORE"):
        if family not in adjacent:
            findings.add(f"adjacent regression owner {family} disappeared")
    forbidden_keys = {"provenance", "scenario_corpus", "behavioral_certification"}
    def keys(value):
        if isinstance(value, dict):
            for key, child in value.items():
                yield key
                yield from keys(child)
        elif isinstance(value, list):
            for child in value:
                yield from keys(child)
    leaked = forbidden_keys & set(keys(data))
    if leaked:
        findings.add(f"DEV-120/DEV-121 ownership leaked into contract: {sorted(leaked)}")
    if not findings.items:
        print("PASS: CI maps all Must ACs and retains adjacent regression owners")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--root", default=None)
    common.add_argument("--contract", required=True)
    common.add_argument("--as-of", required=True)
    check = sub.add_parser("check", parents=[common])
    check.add_argument("--only", default="all", choices=[
        "all", "schema", "inventory", "render", "adapters", "paths",
        "platforms", "dependencies", "windows-ref", "claims", "boundaries", "ci"])
    check.add_argument("--available-commands")
    check.add_argument("--windows-ref")
    check.add_argument("--archive-map")
    check.add_argument("--scan-file")
    render_parser = sub.add_parser("render", parents=[common])
    mode = render_parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--apply", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    findings = Findings()
    contract_path = Path(args.contract).resolve()
    root = Path(args.root).resolve() if args.root else contract_path.parent.parent
    data = load_contract(contract_path, findings)
    validate_schema(data, root, findings)
    try:
        as_of = dt.date.fromisoformat(args.as_of)
    except ValueError:
        findings.add("--as-of must be YYYY-MM-DD")
        return findings.emit()
    if findings.items:
        return findings.emit()
    if args.action == "render":
        render(data, root, as_of, args.apply, findings)
        return findings.emit()
    groups = {
        "schema": lambda: None,
        "inventory": lambda: check_inventory(data, root, findings),
        "render": lambda: render(data, root, as_of, False, findings),
        "adapters": lambda: check_adapters(data, root, as_of, findings),
        "paths": lambda: check_paths(data, root, findings),
        "platforms": lambda: check_platforms(data, root, findings),
        "dependencies": lambda: check_dependencies(
            data, root, args.available_commands, findings),
        "windows-ref": lambda: check_windows_ref(
            root, args.windows_ref, args.archive_map, findings),
        "claims": lambda: check_claims(data, root, as_of, args.scan_file, findings),
        "boundaries": lambda: check_boundaries(data, findings),
        "ci": lambda: check_ci(data, root, findings),
    }
    selected = list(groups) if args.only == "all" else [args.only]
    for name in selected:
        groups[name]()
    if args.only == "schema" and not findings.items:
        print("PASS: closed inert Product Truth v1 contract")
    return findings.emit()


if __name__ == "__main__":
    raise SystemExit(main())
