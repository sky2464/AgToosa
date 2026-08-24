#!/usr/bin/env bash
# lib/scenario.sh — Behavioral Conformance Lab helpers (DEV-121)

SCENARIO_PLATFORMS="cursor claude codex copilot windsurf gemini"

scenario_is_platform() {
  local p="$1"
  [[ " $SCENARIO_PLATFORMS " == *" $p "* ]]
}

scenario_resolve_root() {
  local script_dir="$1"
  cd "$script_dir/.." && pwd
}

scenario_load_definition() {
  local root="$1"
  local scenario_id="$2"
  local def="$root/data/scenarios/${scenario_id}.json"
  [[ -f "$def" ]] || { echo "Error: scenario definition not found: $def" >&2; return 1; }
  printf '%s\n' "$def"
}

scenario_verify_impl() {
  local root="$1"
  local scenario_id="$2"
  local platform="$3"
  local artifact_root="$4"

  python3 - "$root" "$scenario_id" "$platform" "$artifact_root" <<'PY'
import json, os, sys

root, scenario_id, platform, artifact_root = sys.argv[1:5]
def_path = os.path.join(root, "data", "scenarios", f"{scenario_id}.json")

def fail(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

try:
    with open(def_path, encoding="utf-8") as f:
        scenario = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    fail(f"cannot read scenario: {e}")

if scenario.get("id") != scenario_id:
    fail(f"scenario id mismatch: expected {scenario_id}, got {scenario.get('id')}")
platforms = scenario.get("platforms", [])
if platform not in platforms:
    fail(f"unknown platform '{platform}' for scenario '{scenario_id}'")

artifacts = list(scenario.get("shared_artifacts", []))
artifacts.extend(scenario.get("platform_artifacts", {}).get(platform, []))

results = []
for spec in artifacts:
    rel = spec.get("path", "")
    if not rel or ".." in rel or rel.startswith("/"):
        fail(f"unsafe artifact path '{rel}'")
    full = os.path.join(artifact_root, rel)
    required = spec.get("required", True)
    markers = spec.get("markers", [])
    min_lines = spec.get("min_lines", 0)
    entry = {"path": rel, "passed": False, "detail": ""}

    if not os.path.isfile(full):
        entry["detail"] = "missing file"
        results.append(entry)
        if required:
            print(json.dumps({"ok": False, "first_failure": entry, "results": results}))
            sys.exit(1)
        continue

    try:
        with open(full, encoding="utf-8") as fh:
            content = fh.read()
    except OSError as e:
        entry["detail"] = f"read error: {e}"
        results.append(entry)
        if required:
            print(json.dumps({"ok": False, "first_failure": entry, "results": results}))
            sys.exit(1)
        continue

    if min_lines and content.count("\n") + (1 if content else 0) < min_lines:
        entry["detail"] = f"min_lines {min_lines} not met"
        results.append(entry)
        if required:
            print(json.dumps({"ok": False, "first_failure": entry, "results": results}))
            sys.exit(1)
        continue

    for marker in markers:
        if marker not in content:
            entry["detail"] = f"marker not found: {marker}"
            results.append(entry)
            if required:
                print(json.dumps({"ok": False, "first_failure": entry, "results": results}))
                sys.exit(1)
            break
    else:
        entry["passed"] = True
        entry["detail"] = "ok"
        results.append(entry)

print(json.dumps({"ok": True, "results": results}))
PY
}

scenario_validate_corpus() {
  local root="$1"
  local corpus="$2"
  python3 - "$corpus" "$root" <<'PY'
import json, os, sys

corpus_path, root = sys.argv[1], sys.argv[2]
schema_path = os.path.join(root, "data", "contracts", "scenario-corpus-v1.schema.json")

def fail(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

try:
    import jsonschema
except ImportError:
    fail("jsonschema required (pip install jsonschema)")

if not os.path.isfile(schema_path):
    fail(f"schema missing: {schema_path}")

try:
    with open(schema_path, encoding="utf-8") as sf:
        schema = json.load(sf)
    with open(corpus_path, encoding="utf-8") as cf:
        corpus = json.load(cf)
except (OSError, json.JSONDecodeError) as e:
    fail(f"cannot read corpus or schema: {e}")

validator = jsonschema.Draft202012Validator(schema)
errors = sorted(validator.iter_errors(corpus), key=lambda e: list(e.path))
if errors:
    fail(f"corpus schema: {errors[0].message}")

for entry in corpus.get("scenarios", []):
    def_path = os.path.join(root, entry["definition_path"])
    if not os.path.isfile(def_path):
        fail(f"definition missing: {def_path}")
PY
}

# Locate repo root containing data/contracts/ from any path under the tree.
scenario_resolve_contracts_root() {
  local start_path="$1"
  local dir
  dir="$(cd "$(dirname "$start_path")" && pwd)"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/data/contracts/scenario-run-v1.schema.json" ]]; then
      printf '%s' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  echo "Error: cannot locate data/contracts/scenario-run-v1.schema.json" >&2
  return 1
}

scenario_validate_run_json() {
  local run_file="$1"
  local root="${2:-}"
  [[ -n "$root" ]] || root="$(scenario_resolve_contracts_root "$run_file")" || return 1
  python3 - "$run_file" "$root" <<'PY'
import json, os, sys

run_path, root = sys.argv[1], sys.argv[2]
schema_path = os.path.join(root, "data", "contracts", "scenario-run-v1.schema.json")

def fail(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)

try:
    import jsonschema
except ImportError:
    fail("jsonschema required (pip install jsonschema)")

if not os.path.isfile(schema_path):
    fail(f"schema missing: {schema_path}")

try:
    with open(schema_path, encoding="utf-8") as sf:
        schema = json.load(sf)
    with open(run_path, encoding="utf-8") as rf:
        data = json.load(rf)
except (OSError, json.JSONDecodeError) as e:
    fail(f"cannot read run json or schema: {e}")

validator = jsonschema.Draft202012Validator(schema)
errors = sorted(validator.iter_errors(data), key=lambda e: list(e.path))
if errors:
    fail(f"run json schema: {errors[0].message}")
PY
}
