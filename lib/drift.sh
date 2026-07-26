#!/usr/bin/env bash
# lib/drift.sh — Change-Aware Adaptive Delivery helpers (DEV-122)

drift_sha256_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    echo "Error: no sha256 tool (shasum or sha256sum)" >&2
    return 2
  fi
}

drift_resolve_path() {
  local root="$1"
  local rel="$2"
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *".."* ]] && return 1
  local full="$root/$rel"
  [[ -f "$full" ]] && printf '%s\n' "$full"
}

drift_suggested_rigor() {
  local impact="$1"
  case "$impact" in
    none|low) printf '%s\n' "light" ;;
    medium) printf '%s\n' "standard" ;;
    high) printf '%s\n' "elevated" ;;
    *) printf '%s\n' "light" ;;
  esac
}

drift_validate_baseline() {
  local root="$1"
  local baseline="$2"
  python3 - "$baseline" "$root" <<'PY'
import json, os, re, sys

baseline_path, root = sys.argv[1], sys.argv[2]
sha_pat = re.compile(r"^[a-fA-F0-9]{64}$")
impact_levels = {"low", "medium", "high"}

try:
    with open(baseline_path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read baseline: {e}", file=sys.stderr)
    sys.exit(1)

if data.get("version") != 1:
    print("Error: unsupported baseline version", file=sys.stderr)
    sys.exit(1)
for field in ("baseline_id", "paths"):
    if field not in data:
        print(f"Error: baseline missing {field}", file=sys.stderr)
        sys.exit(1)
paths = data.get("paths", [])
if not paths:
    print("Error: baseline has no paths", file=sys.stderr)
    sys.exit(1)
seen = set()
for entry in paths:
    if not isinstance(entry, dict):
        print("Error: path entry must be object", file=sys.stderr)
        sys.exit(1)
    rel = entry.get("path", "")
    sha = entry.get("sha256", "")
    impact = entry.get("impact_level", "low")
    if not rel or rel.startswith("/") or ".." in rel:
        print(f"Error: unsafe baseline path '{rel}'", file=sys.stderr)
        sys.exit(1)
    if rel in seen:
        print(f"Error: duplicate baseline path '{rel}'", file=sys.stderr)
        sys.exit(1)
    seen.add(rel)
    if not sha_pat.match(sha or ""):
        print(f"Error: invalid sha256 for '{rel}'", file=sys.stderr)
        sys.exit(1)
    if impact not in impact_levels:
        print(f"Error: invalid impact_level for '{rel}'", file=sys.stderr)
        sys.exit(1)
PY
}

drift_validate_report() {
  local report="$1"
  python3 - "$report" <<'PY'
import json, re, sys

path = sys.argv[1]
sha_pat = re.compile(r"^[a-fA-F0-9]{64}$")
required = {
    "version", "provider", "baseline_id", "assessed_at", "summary",
    "overall_impact_level", "suggested_rigor", "changes"
}
rigor = {"light", "standard", "elevated"}
impact = {"none", "low", "medium", "high"}

try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read report: {e}", file=sys.stderr)
    sys.exit(1)

missing = required - set(data.keys())
if missing:
    print(f"Error: report missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)
if data.get("version") != 1 or data.get("provider") != "git-inventory":
    print("Error: unsupported report version/provider", file=sys.stderr)
    sys.exit(1)
if data.get("suggested_rigor") not in rigor:
    print("Error: invalid suggested_rigor", file=sys.stderr)
    sys.exit(1)
if data.get("overall_impact_level") not in impact:
    print("Error: invalid overall_impact_level", file=sys.stderr)
    sys.exit(1)
changes = data.get("changes", {})
for key in ("added", "removed", "modified", "unchanged"):
    if key not in changes:
        print(f"Error: changes missing {key}", file=sys.stderr)
        sys.exit(1)
for item in changes.get("modified", []):
    if "path" not in item or "impact_level" not in item:
        print("Error: modified entry incomplete", file=sys.stderr)
        sys.exit(1)
    for sha_field in ("expected_sha256", "actual_sha256"):
        if sha_field in item and not sha_pat.match(item.get(sha_field, "")):
            print(f"Error: invalid {sha_field}", file=sys.stderr)
            sys.exit(1)
PY
}

drift_validate_context_compilation() {
  local compilation="$1"
  python3 - "$compilation" <<'PY'
import json, sys

path = sys.argv[1]
required = {"version", "story_id", "compiled_at", "provenance", "drift", "task_context"}

try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read context compilation: {e}", file=sys.stderr)
    sys.exit(1)

missing = required - set(data.keys())
if missing:
    print(f"Error: context compilation missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)
if data.get("version") != 1:
    print("Error: unsupported context compilation version", file=sys.stderr)
    sys.exit(1)
prov = data.get("provenance", {})
if "proof_graph_verified" not in prov:
    print("Error: provenance missing proof_graph_verified", file=sys.stderr)
    sys.exit(1)
PY
}
