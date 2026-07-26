#!/usr/bin/env bash
# lib/capsule-exporters/manual-handoff.sh — pack execution capsule from handoff (DEV-123)

capsule_pack_from_handoff() {
  local root="$1"
  local handoff_json_or_story="$2"
  local output_path="$3"

  python3 - "$root" "$handoff_json_or_story" "$output_path" <<'PY'
import json, os, re, sys
from datetime import datetime, timezone

root, handoff_arg, output_path = sys.argv[1:4]
safe_pat = re.compile(r"^(?!/)(?!.*\.\.).+$")

def safe_path(p):
    return bool(p) and safe_pat.match(p)

def now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def resolve_handoff_path(arg):
    if os.path.isfile(arg):
        return arg
    story = arg.strip()
    archived = os.path.join(root, "docs", "archived")
    if not os.path.isdir(archived):
        archived = os.path.join(root, "Docs", "archived")
    if not os.path.isdir(archived):
        raise FileNotFoundError(f"no archived handoff directory for story {story}")
    matches = []
    for name in sorted(os.listdir(archived)):
        if name.startswith(f"handoff-{story}") and name.endswith(".md"):
            matches.append(os.path.join(archived, name))
    if not matches:
        raise FileNotFoundError(f"no handoff markdown found for story {story}")
    return matches[-1]

def parse_handoff_md(text):
    story_id = "UNKNOWN"
    m = re.search(r"^#\s+Handoff Pack\s+—\s+([A-Za-z0-9._-]+)", text, re.MULTILINE)
    if m:
        story_id = m.group(1)
    else:
        m = re.search(r">\s*\*\*Story:\*\*\s*([A-Za-z0-9._-]+)", text)
        if m:
            story_id = m.group(1)

    allowed = []
    in_scope = False
    for line in text.splitlines():
        if re.match(r"^##\s+3\.\s+Files in Scope", line):
            in_scope = True
            continue
        if in_scope and re.match(r"^##\s+\d", line):
            break
        if in_scope:
            for token in re.findall(r"`([^`]+)`", line):
                if safe_path(token) and token not in allowed:
                    allowed.append(token)
            for token in re.findall(r"(?:^|\s)((?:[A-Za-z0-9._-]+/)+[A-Za-z0-9._*-]+)", line):
                if safe_path(token) and token not in allowed:
                    allowed.append(token)

    commands = []
    in_verify = False
    in_code = False
    for line in text.splitlines():
        if re.match(r"^##\s+5\.\s+Verification Commands", line):
            in_verify = True
            continue
        if in_verify and re.match(r"^##\s+\d", line) and not in_code:
            break
        if in_verify and line.strip().startswith("```"):
            in_code = not in_code
            continue
        if in_verify and in_code and line.strip():
            commands.append({"command": line.strip(), "expected_exit_code": 0})

    ac_ids = sorted(set(re.findall(r"AC-[0-9]{3}", text)))
    return {
        "story_id": story_id,
        "allowed_paths": allowed or ["lib/"],
        "commands": commands or [{"command": "true", "description": "smoke", "expected_exit_code": 0}],
        "ac_ids": ac_ids,
    }

def load_handoff(path):
    if path.endswith(".json"):
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return {
            "story_id": data.get("story_id", "UNKNOWN"),
            "allowed_paths": data.get("scope", {}).get("allowed_paths", data.get("allowed_paths", ["lib/"])),
            "commands": data.get("verification", {}).get("commands", [{"command": "true", "expected_exit_code": 0}]),
            "ac_ids": data.get("acceptance_criteria", []),
            "handoff_path": os.path.relpath(path, root) if path.startswith(root) else path,
            "owner": data.get("ownership", {}).get("owner", "handoff-exporter"),
            "forbidden_paths": data.get("scope", {}).get("forbidden_paths", ["docs/Master-Plan.md"]),
            "proof_graph_path": data.get("provenance", {}).get("proof_graph_path"),
            "drift_report_path": data.get("provenance", {}).get("drift_report_path"),
        }
    with open(path, encoding="utf-8") as f:
        text = f.read()
    parsed = parse_handoff_md(text)
    rel = os.path.relpath(path, root) if path.startswith(root) else path
    return {
        **parsed,
        "handoff_path": rel if safe_path(rel) else None,
        "owner": "handoff-exporter",
        "forbidden_paths": ["docs/Master-Plan.md", "Docs/Master-Plan.md"],
        "proof_graph_path": None,
        "drift_report_path": None,
    }

try:
    handoff_path = resolve_handoff_path(handoff_arg)
    handoff = load_handoff(handoff_path)
except (OSError, json.JSONDecodeError, FileNotFoundError) as e:
    print(f"Error: cannot load handoff: {e}", file=sys.stderr)
    sys.exit(1)

story_id = handoff["story_id"]
capsule_id = f"caps-{story_id.lower()}"
allowed = [p for p in handoff["allowed_paths"] if safe_path(p)]
if not allowed:
    print("Error: no safe allowed_paths from handoff", file=sys.stderr)
    sys.exit(1)

forbidden = [p for p in handoff.get("forbidden_paths", []) if safe_path(p)]

capsule = {
    "version": 1,
    "capsule_id": capsule_id,
    "story_id": story_id,
    "created_at": now_iso(),
    "ownership": {
        "owner": handoff.get("owner", "handoff-exporter"),
        "exported_by": "manual-handoff",
    },
    "scope": {
        "allowed_paths": allowed,
        "forbidden_paths": forbidden,
    },
    "policy": {
        "network": "deny",
        "secrets": "forbid",
    },
    "budgets": {
        "max_files_changed": max(1, len(allowed)),
        "max_verification_commands": max(1, len(handoff["commands"])),
    },
    "verification": {
        "commands": handoff["commands"],
    },
    "return_contract": {
        "schema": "capsule-return-v1",
        "required_fields": ["changed_files", "verification_results", "mapped_acs"],
    },
}

prov = {}
if handoff.get("handoff_path") and safe_path(handoff["handoff_path"]):
    prov["handoff_path"] = handoff["handoff_path"]
if handoff.get("proof_graph_path") and safe_path(handoff["proof_graph_path"]):
    prov["proof_graph_path"] = handoff["proof_graph_path"]
if handoff.get("drift_report_path") and safe_path(handoff["drift_report_path"]):
    prov["drift_report_path"] = handoff["drift_report_path"]
if prov:
    capsule["provenance"] = prov

os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(capsule, f, indent=2)
    f.write("\n")
PY
}
