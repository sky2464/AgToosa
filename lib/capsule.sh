#!/usr/bin/env bash
# lib/capsule.sh — Guarded Portable Execution helpers (DEV-123)

capsule_path_safe() {
  local rel="$1"
  [[ -z "$rel" ]] && return 1
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *".."* ]] && return 1
  return 0
}

capsule_resolve_path() {
  local root="$1"
  local rel="$2"
  capsule_path_safe "$rel" || return 1
  local full="$root/$rel"
  [[ -e "$full" ]] && printf '%s\n' "$full"
}

capsule_validate_capsule() {
  local root="$1"
  local capsule="$2"
  python3 - "$capsule" "$root" <<'PY'
import json, os, re, sys

capsule_path, root = sys.argv[1], sys.argv[2]
safe_pat = re.compile(r"^(?!/)(?!.*\.\.).+$")
network_policy = {"deny", "allow"}
secrets_policy = {"forbid", "allow"}

def safe_path(p):
    return bool(p) and safe_pat.match(p)

try:
    with open(capsule_path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read capsule: {e}", file=sys.stderr)
    sys.exit(1)

if data.get("version") != 1:
    print("Error: unsupported capsule version", file=sys.stderr)
    sys.exit(1)

required = {
    "capsule_id", "story_id", "created_at", "ownership", "scope",
    "policy", "budgets", "verification", "return_contract"
}
missing = required - set(data.keys())
if missing:
    print(f"Error: capsule missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)

if not re.match(r"^[A-Za-z0-9._-]+$", data.get("capsule_id", "")):
    print("Error: invalid capsule_id", file=sys.stderr)
    sys.exit(1)

ownership = data.get("ownership", {})
if not ownership.get("owner"):
    print("Error: ownership.owner required", file=sys.stderr)
    sys.exit(1)

scope = data.get("scope", {})
allowed = scope.get("allowed_paths", [])
forbidden = scope.get("forbidden_paths", [])
if not allowed:
    print("Error: scope.allowed_paths must be non-empty", file=sys.stderr)
    sys.exit(1)
for paths, label in ((allowed, "allowed_paths"), (forbidden, "forbidden_paths")):
    for rel in paths:
        if not safe_path(rel):
            print(f"Error: unsafe path in {label}: '{rel}'", file=sys.stderr)
            sys.exit(1)

policy = data.get("policy", {})
if policy.get("network") not in network_policy:
    print("Error: policy.network must be deny or allow", file=sys.stderr)
    sys.exit(1)
if policy.get("secrets") not in secrets_policy:
    print("Error: policy.secrets must be forbid or allow", file=sys.stderr)
    sys.exit(1)

budgets = data.get("budgets", {})
for field in ("max_files_changed", "max_verification_commands"):
    val = budgets.get(field)
    if not isinstance(val, int) or val < 1:
        print(f"Error: budgets.{field} must be positive integer", file=sys.stderr)
        sys.exit(1)

commands = data.get("verification", {}).get("commands", [])
if not commands:
    print("Error: verification.commands must be non-empty", file=sys.stderr)
    sys.exit(1)
for cmd in commands:
    if not cmd.get("command"):
        print("Error: verification command missing command string", file=sys.stderr)
        sys.exit(1)

rc = data.get("return_contract", {})
if rc.get("schema") != "capsule-return-v1":
    print("Error: return_contract.schema must be capsule-return-v1", file=sys.stderr)
    sys.exit(1)
if not rc.get("required_fields"):
    print("Error: return_contract.required_fields must be non-empty", file=sys.stderr)
    sys.exit(1)

prov = data.get("provenance", {})
for key in ("proof_graph_path", "drift_report_path", "handoff_path"):
    if key in prov and prov[key] and not safe_path(prov[key]):
        print(f"Error: unsafe provenance path '{prov[key]}'", file=sys.stderr)
        sys.exit(1)
PY
}

capsule_validate_return() {
  local capsule="$1"
  local return_env="$2"
  python3 - "$capsule" "$return_env" <<'PY'
import json, re, sys

capsule_path, return_path = sys.argv[1], sys.argv[2]
safe_pat = re.compile(r"^(?!/)(?!.*\.\.).+$")
ac_pat = re.compile(r"^AC-[0-9]{3}$")

def safe_path(p):
    return bool(p) and safe_pat.match(p)

def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)

try:
    capsule = load_json(capsule_path)
    ret = load_json(return_path)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read capsule or return: {e}", file=sys.stderr)
    sys.exit(1)

if ret.get("version") != 1:
    print("Error: unsupported return version", file=sys.stderr)
    sys.exit(1)

required = {
    "capsule_id", "returned_at", "changed_files",
    "verification_results", "mapped_acs", "import_ready"
}
missing = required - set(ret.keys())
if missing:
    print(f"Error: return missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)

if ret.get("capsule_id") != capsule.get("capsule_id"):
    print("Error: return capsule_id mismatch", file=sys.stderr)
    sys.exit(1)

violations = []
scope = capsule.get("scope", {})
allowed = set(scope.get("allowed_paths", []))
forbidden = set(scope.get("forbidden_paths", []))
budgets = capsule.get("budgets", {})
policy = capsule.get("policy", {})

for rel in ret.get("changed_files", []):
    if not safe_path(rel):
        violations.append({"code": "unsafe_path", "message": f"unsafe changed path '{rel}'"})
    elif rel in forbidden:
        violations.append({"code": "forbidden_path", "message": f"forbidden path '{rel}'"})
    elif allowed and rel not in allowed:
        violations.append({"code": "out_of_scope", "message": f"path '{rel}' not in allowed_paths"})

max_files = budgets.get("max_files_changed", 1)
if len(ret.get("changed_files", [])) > max_files:
    violations.append({
        "code": "budget_files_exceeded",
        "message": f"changed_files count {len(ret['changed_files'])} exceeds max {max_files}"
    })

max_cmds = budgets.get("max_verification_commands", 1)
if len(ret.get("verification_results", [])) > max_cmds:
    violations.append({
        "code": "budget_commands_exceeded",
        "message": f"verification_results count exceeds max {max_cmds}"
    })

if policy.get("network") == "deny":
    for vr in ret.get("verification_results", []):
        cmd = (vr.get("command") or "").lower()
        if any(tok in cmd for tok in ("curl ", "wget ", "npm install", "pip install", "fetch ")):
            violations.append({
                "code": "policy_network",
                "message": f"network-like command blocked by policy: {vr.get('command')}"
            })

for ac in ret.get("mapped_acs", []):
    if not ac_pat.match(ac.get("ac_id", "")):
        violations.append({"code": "invalid_ac", "message": f"invalid ac_id '{ac.get('ac_id')}'"})
    if not ac.get("evidence"):
        violations.append({"code": "missing_evidence", "message": f"missing evidence for {ac.get('ac_id')}"})

for field in capsule.get("return_contract", {}).get("required_fields", []):
    if field not in ret or ret[field] in (None, [], ""):
        violations.append({"code": "missing_contract_field", "message": f"required field '{field}' missing or empty"})

declared_ready = bool(ret.get("import_ready"))
computed_ready = len(violations) == 0
if declared_ready and not computed_ready:
    print("Error: import_ready true but violations present", file=sys.stderr)
    sys.exit(1)
if not declared_ready and computed_ready:
    print("Warning: import_ready false but no violations detected", file=sys.stderr)

if violations and not ret.get("violations"):
    print("Error: violations present but return.violations not recorded", file=sys.stderr)
    sys.exit(1)
PY
}
