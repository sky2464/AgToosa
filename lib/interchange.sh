#!/usr/bin/env bash
# lib/interchange.sh — Cross-Framework Interchange helpers (DEV-124)

interchange_path_safe() {
  local rel="$1"
  [[ -z "$rel" ]] && return 1
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *".."* ]] && return 1
  return 0
}

interchange_resolve_path() {
  local root="$1"
  local rel="$2"
  interchange_path_safe "$rel" || return 1
  local full="$root/$rel"
  [[ -e "$full" ]] && printf '%s\n' "$full"
}

interchange_resolve_spec_path() {
  local root="$1"
  local story="$2"
  local archived="$root/docs/archived"
  if [[ ! -d "$archived" ]]; then
    archived="$root/Docs/archived"
  fi
  local candidate="$archived/spec-${story}.md"
  [[ -f "$candidate" ]] && printf '%s\n' "$candidate"
}

interchange_derived_artifact_path() {
  local manifest_path="$1"
  local target="$2"
  local ext="$3"
  local base="${manifest_path%.json}"
  printf '%s-%s.%s\n' "$base" "$target" "$ext"
}

interchange_rel_path() {
  local from_dir="$1"
  local abs_path="$2"
  python3 - "$from_dir" "$abs_path" <<'PY'
import os, sys
print(os.path.relpath(os.path.abspath(sys.argv[2]), os.path.abspath(sys.argv[1])))
PY
}

interchange_detect_framework_from_fixture() {
  local fixture="$1"
  python3 - "$fixture" <<'PY'
import json, os, sys

fixture = sys.argv[1]
basename = os.path.basename(fixture).lower()
path_lower = fixture.replace("\\", "/").lower()
for name in ("speckit", "openspec", "bmad", "kiro"):
    if name in basename or f"/{name}/" in path_lower:
        print(name)
        raise SystemExit(0)

if fixture.endswith(".md"):
    print("kiro")
    raise SystemExit(0)

try:
    with open(fixture, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError):
    print("unknown", file=sys.stderr)
    raise SystemExit(1)

explicit = data.get("framework") or data.get("source_framework")
if explicit in {"speckit", "openspec", "bmad", "kiro"}:
    print(explicit)
    raise SystemExit(0)
if "openspec" in data:
    print("openspec")
elif "speckit" in data or str(data.get("$schema", "")).endswith("speckit"):
    print("speckit")
elif "bmad" in data:
    print("bmad")
elif data.get("format") == "kiro-spec":
    print("kiro")
else:
    print("unknown", file=sys.stderr)
    raise SystemExit(1)
PY
}

interchange_build_export_manifest() {
  local root="$1"
  local parsed_json="$2"
  local spec_path="$3"
  local proof_graph="$4"
  local out_manifest="$5"
  python3 - "$root" "$parsed_json" "$spec_path" "$proof_graph" "$out_manifest" <<'PY'
import json, os, sys
from datetime import datetime, timezone

root, parsed_json, spec_path, proof_graph, out_path = sys.argv[1:6]
with open(parsed_json, encoding="utf-8") as f:
    parsed = json.load(f)

spec_rel = os.path.relpath(os.path.abspath(spec_path), root)
manifest = {
    "version": 1,
    "story_id": parsed["story_id"],
    "source_framework": "agtoosa",
    "source_ids": {
        "story_id": parsed["story_id"],
        "spec_path": spec_rel,
    },
    "authority": {
        "owner": "master-plan",
        "preserved": True,
    },
    "requirements": parsed.get("requirements", []),
    "tasks": parsed.get("tasks", []),
    "provenance": {
        "spec_path": spec_rel,
        "exported_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    },
}
if proof_graph:
    manifest["provenance"]["proof_graph_path"] = proof_graph

with open(out_path, "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2)
    f.write("\n")
PY
}

interchange_parse_spec() {
  local spec_path="$1"
  python3 - "$spec_path" <<'PY'
import json, re, sys

spec_path = sys.argv[1]
ac_pat = re.compile(r"^AC-[0-9]{3}$")

with open(spec_path, encoding="utf-8") as f:
    text = f.read()

story_id = "UNKNOWN"
m = re.search(r"^#\s+Spec:\s+([A-Za-z0-9._-]+)\s+—", text, re.MULTILINE)
if m:
    story_id = m.group(1)
else:
    m = re.search(r">\s*\*\*Story ID:\*\*\s*([A-Za-z0-9._-]+)", text)
    if m:
        story_id = m.group(1)

requirements = []
in_ac_table = False
for line in text.splitlines():
    if re.match(r"^###\s+1\.2\s+Acceptance Criteria", line):
        in_ac_table = True
        continue
    if in_ac_table and re.match(r"^###\s+", line):
        break
    if not in_ac_table:
        continue
    if not line.strip().startswith("|"):
        continue
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) < 3:
        continue
    ac_id = cells[0]
    if not ac_pat.match(ac_id):
        continue
    ears = cells[1]
    priority = cells[2] if len(cells) > 2 else "Must"
    if priority not in ("Must", "Should", "Could", "Won't"):
        priority = "Must"
    requirements.append({
        "id": ac_id,
        "kind": "acceptance-criterion",
        "text": ears,
        "priority": priority,
    })

tasks = []
in_tasks = False
for line in text.splitlines():
    if re.match(r"^###\s+3\.1\s+Task tree", line):
        in_tasks = True
        continue
    if in_tasks and re.match(r"^###\s+Wave Plan", line):
        break
    if not in_tasks:
        continue
    m = re.match(r"^-\s+\[[ xX]\]\s+\*\*(\d+(?:\.\d+)?)\.\*\*\s+(.*)$", line)
    if m:
        tasks.append({
            "id": m.group(1),
            "text": m.group(2).strip(),
            "completed": "[x]" in line.lower()[:6],
        })
        continue
    m = re.match(r"^\s+-\s+\[[ xX]\]\s+(\d+(?:\.\d+)?)\s+(.*)$", line)
    if m:
        tasks.append({
            "id": m.group(1),
            "text": m.group(2).strip(),
            "completed": "[x]" in line.lower()[:12],
        })

print(json.dumps({
    "story_id": story_id,
    "requirements": requirements,
    "tasks": tasks,
}, indent=2))
PY
}

interchange_validate_manifest() {
  local root="$1"
  local manifest="$2"
  python3 - "$manifest" "$root" <<'PY'
import json, re, sys

manifest_path, root = sys.argv[1], sys.argv[2]
safe_pat = re.compile(r"^(?!/)(?!.*\.\.).+$")
ac_pat = re.compile(r"^AC-[0-9]{3}$")
frameworks = {"speckit", "openspec", "bmad", "kiro", "agtoosa"}
owners = {"master-plan", "imported-derived"}
priorities = {"Must", "Should", "Could", "Won't"}

def safe_path(p):
    return bool(p) and safe_pat.match(p)

try:
    with open(manifest_path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read manifest: {e}", file=sys.stderr)
    sys.exit(1)

if data.get("version") != 1:
    print("Error: unsupported manifest version", file=sys.stderr)
    sys.exit(1)

story_id = data.get("story_id", "")
if not re.match(r"^[A-Za-z0-9._-]+$", story_id or ""):
    print("Error: invalid story_id", file=sys.stderr)
    sys.exit(1)

if data.get("source_framework") not in frameworks:
    print("Error: invalid source_framework", file=sys.stderr)
    sys.exit(1)

source_ids = data.get("source_ids", {})
if not isinstance(source_ids, dict) or not source_ids:
    print("Error: source_ids must be non-empty object", file=sys.stderr)
    sys.exit(1)
for key, val in source_ids.items():
    if not isinstance(val, str) or not val:
        print(f"Error: source_ids.{key} must be non-empty string", file=sys.stderr)
        sys.exit(1)

authority = data.get("authority", {})
if authority.get("owner") not in owners:
    print("Error: authority.owner must be master-plan or imported-derived", file=sys.stderr)
    sys.exit(1)
if not isinstance(authority.get("preserved"), bool):
    print("Error: authority.preserved must be boolean", file=sys.stderr)
    sys.exit(1)

requirements = data.get("requirements", [])
if not isinstance(requirements, list):
    print("Error: requirements must be array", file=sys.stderr)
    sys.exit(1)
seen_ac = set()
for req in requirements:
    if not isinstance(req, dict):
        print("Error: requirement entry must be object", file=sys.stderr)
        sys.exit(1)
    rid = req.get("id", "")
    if not ac_pat.match(rid or ""):
        print(f"Error: invalid requirement id '{rid}'", file=sys.stderr)
        sys.exit(1)
    if rid in seen_ac:
        print(f"Error: duplicate requirement id '{rid}'", file=sys.stderr)
        sys.exit(1)
    seen_ac.add(rid)
    if req.get("kind") != "acceptance-criterion":
        print(f"Error: requirement {rid} kind must be acceptance-criterion", file=sys.stderr)
        sys.exit(1)
    if not req.get("text"):
        print(f"Error: requirement {rid} missing text", file=sys.stderr)
        sys.exit(1)
    pri = req.get("priority")
    if pri is not None and pri not in priorities:
        print(f"Error: requirement {rid} invalid priority", file=sys.stderr)
        sys.exit(1)

tasks = data.get("tasks", [])
if not isinstance(tasks, list):
    print("Error: tasks must be array", file=sys.stderr)
    sys.exit(1)
seen_task = set()
for task in tasks:
    if not isinstance(task, dict):
        print("Error: task entry must be object", file=sys.stderr)
        sys.exit(1)
    tid = task.get("id", "")
    if not tid:
        print("Error: task missing id", file=sys.stderr)
        sys.exit(1)
    if tid in seen_task:
        print(f"Error: duplicate task id '{tid}'", file=sys.stderr)
        sys.exit(1)
    seen_task.add(tid)
    if not task.get("text"):
        print(f"Error: task {tid} missing text", file=sys.stderr)
        sys.exit(1)
    if "completed" in task and not isinstance(task["completed"], bool):
        print(f"Error: task {tid} completed must be boolean", file=sys.stderr)
        sys.exit(1)

prov = data.get("provenance", {})
if prov:
    for key in ("spec_path", "proof_graph_path", "fixture_path"):
        val = prov.get(key)
        if val and not safe_path(val):
            print(f"Error: unsafe provenance path '{val}'", file=sys.stderr)
            sys.exit(1)
PY
}

interchange_validate_loss_report() {
  local loss_report="$1"
  python3 - "$loss_report" <<'PY'
import json, re, sys

loss_path = sys.argv[1]
frameworks = {"speckit", "openspec", "bmad", "kiro", "agtoosa"}
severities = {"low", "high"}

try:
    with open(loss_path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read loss report: {e}", file=sys.stderr)
    sys.exit(1)

if data.get("version") != 1:
    print("Error: unsupported loss report version", file=sys.stderr)
    sys.exit(1)

story_id = data.get("story_id", "")
if not re.match(r"^[A-Za-z0-9._-]+$", story_id or ""):
    print("Error: invalid story_id", file=sys.stderr)
    sys.exit(1)

if data.get("source_framework") not in frameworks:
    print("Error: invalid source_framework", file=sys.stderr)
    sys.exit(1)

entries = data.get("entries", [])
if not isinstance(entries, list):
    print("Error: entries must be array", file=sys.stderr)
    sys.exit(1)

for idx, entry in enumerate(entries):
    if not isinstance(entry, dict):
        print(f"Error: entry {idx} must be object", file=sys.stderr)
        sys.exit(1)
    if not entry.get("field"):
        print(f"Error: entry {idx} missing field", file=sys.stderr)
        sys.exit(1)
    if not entry.get("reason"):
        print(f"Error: entry {idx} missing reason", file=sys.stderr)
        sys.exit(1)
    if entry.get("severity") not in severities:
        print(f"Error: entry {idx} invalid severity", file=sys.stderr)
        sys.exit(1)
PY
}

interchange_assess_loss_report() {
  local loss_report="$1"
  local strict="${2:-false}"
  interchange_validate_loss_report "$loss_report" || return 1
  python3 - "$loss_report" "$strict" <<'PY'
import json, sys

loss_path, strict_flag = sys.argv[1], sys.argv[2]
strict = strict_flag.lower() == "true"

with open(loss_path, encoding="utf-8") as f:
    data = json.load(f)

high = [e for e in data.get("entries", []) if e.get("severity") == "high"]
low = [e for e in data.get("entries", []) if e.get("severity") == "low"]

if high:
    for e in high:
        print(f"high: {e['field']}: {e['reason']}")
if low:
    for e in low:
        print(f"low: {e['field']}: {e['reason']}")

if strict and high:
    sys.exit(1)
if high and any(e.get("field", "").startswith("authority") for e in high):
    sys.exit(1)
sys.exit(0)
PY
}
