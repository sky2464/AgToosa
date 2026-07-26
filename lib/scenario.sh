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
  local def="$root/scenarios/${scenario_id}.json"
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
def_path = os.path.join(root, "scenarios", f"{scenario_id}.json")

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
try:
    with open(corpus_path, encoding="utf-8") as f:
        corpus = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: cannot read corpus: {e}", file=sys.stderr)
    sys.exit(1)
if corpus.get("version") != 1:
    print("Error: unsupported corpus version", file=sys.stderr)
    sys.exit(1)
scenarios = corpus.get("scenarios", [])
if not scenarios:
    print("Error: corpus has no scenarios", file=sys.stderr)
    sys.exit(1)
for entry in scenarios:
    if "id" not in entry or "definition_path" not in entry:
        print("Error: corpus entry missing id or definition_path", file=sys.stderr)
        sys.exit(1)
    def_path = os.path.join(root, entry["definition_path"])
    if not os.path.isfile(def_path):
        print(f"Error: definition missing: {def_path}", file=sys.stderr)
        sys.exit(1)
PY
}

scenario_validate_run_json() {
  local run_file="$1"
  python3 - "$run_file" <<'PY'
import json, sys

path = sys.argv[1]
platforms = {"cursor", "claude", "codex", "copilot", "windsurf", "gemini"}
required = {"version", "scenario_id", "platform", "run_at", "artifact_results", "verifier_exit_code"}
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError) as e:
    print(f"Error: invalid run json: {e}", file=sys.stderr)
    sys.exit(1)
missing = required - set(data.keys())
if missing:
    print(f"Error: run json missing fields: {sorted(missing)}", file=sys.stderr)
    sys.exit(1)
if data.get("version") != 1:
    print("Error: unsupported run version", file=sys.stderr)
    sys.exit(1)
if data.get("platform") not in platforms:
    print("Error: invalid platform", file=sys.stderr)
    sys.exit(1)
for item in data.get("artifact_results", []):
    if "path" not in item or "passed" not in item:
        print("Error: artifact_results entry incomplete", file=sys.stderr)
        sys.exit(1)
PY
}
