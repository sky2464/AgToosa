#!/usr/bin/env bats

setup() {
  ROOT="$BATS_TEST_DIRNAME/.."
  TOOL="$ROOT/scripts/product-truth.py"
  CONTRACT="$ROOT/contracts/product-truth-v1.json"
  FIXTURES="$ROOT/tests/fixtures/product-truth"
  AS_OF="2026-07-14"
  TMP_ROOT="$BATS_TEST_TMPDIR/repo"
}

copy_contract() {
  mkdir -p "$TMP_ROOT/contracts"
  cp "$CONTRACT" "$TMP_ROOT/contracts/product-truth-v1.json"
  cp "$ROOT/contracts/product-truth-v1.schema.json" "$TMP_ROOT/contracts/product-truth-v1.schema.json"
}

copy_targets() {
  local dir
  for dir in     template/.cursor/commands     template/.windsurf/workflows     template/.claude/commands     template/.gemini/commands     template/.github/prompts     template/.codex/prompts; do
    mkdir -p "$TMP_ROOT/$(dirname "$dir")"
    cp -R "$ROOT/$dir" "$TMP_ROOT/$dir"
  done
  mkdir -p "$TMP_ROOT/template/.codex"
  cp -R "$ROOT/template/.codex/skills" "$TMP_ROOT/template/.codex/skills"
  cp "$ROOT/README.md" "$TMP_ROOT/README.md"
  local surface
  for surface in \
    docs/AgToosa_Compatibility_Contract.md \
    docs/AgToosa_Network_Matrix.md \
    docs/AgToosa_Readiness.md \
    docs/enforcement-comparison.md \
    docs/AgToosa_Team_Trust_Roadmap.md \
    template/Docs/AgToosa_Compatibility_Contract.md \
    template/Docs/AgToosa_Network_Matrix.md \
    template/Docs/AgToosa_Readiness.md; do
    mkdir -p "$TMP_ROOT/$(dirname "$surface")"
    cp "$ROOT/$surface" "$TMP_ROOT/$surface"
  done
}

copy_path_candidates() {
  mkdir -p "$TMP_ROOT/template"
  cp -R "$ROOT/template/Docs" "$TMP_ROOT/template/Docs"
}

run_check() {
  run python3 "$TOOL" check --root "$ROOT" --contract "$CONTRACT" --as-of "$AS_OF" "$@"
}

@test "DEV-118 @smoke PTC-001: closed inert contract rejects tampering" {
  local sentinel="$BATS_TEST_TMPDIR/no-write-sentinel"
  printf 'unchanged\n' > "$sentinel"
  local sentinel_hash
  sentinel_hash="$(shasum -a 256 "$sentinel" | awk '{print $1}')"

  run_check --only schema
  [ "$status" -eq 0 ]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["unknown_field"] = "${SECRET}"
data["path_policy"]["generated_root"] = "../escape"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown field"* ]]
  [[ "$output" == *"interpolation"* || "$output" == *"traversal"* ]]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["commands"][0]["mutation_class"] = "execute-anything"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  run python3 "$TOOL" check --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
  [ "$status" -ne 0 ]
  [[ "$output" == *"schema enum"* ]]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
text = p.read_text(encoding="utf-8")
text = text.replace('"schema_version": "1",',
                    '"schema_version": "1",\n  "schema_version": "1",', 1)
p.write_text(text, encoding="utf-8")
PY
  run python3 "$TOOL" check --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
  [ "$status" -ne 0 ]
  [[ "$output" == *"duplicate field"* ]]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["include"] = "dynamic.json"
data["commands"][0]["failure_policy"] = "${SECRET} $(whoami)"
data["path_policy"]["candidate_files"][0] = "/tmp/outside"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  run python3 "$TOOL" check --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
  [ "$status" -ne 0 ]
  [[ "$output" == *"dynamic include"* ]]
  [[ "$output" == *"interpolation or executable"* ]]
  [[ "$output" == *"absolute repository path"* || "$output" == *"schema pattern"* ]]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
from pathlib import Path
import sys
Path(sys.argv[1]).write_bytes(b" " * 1_048_577)
PY
  run python3 "$TOOL" check --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
  [ "$status" -ne 0 ]
  [[ "$output" == *"bounded-size limit"* ]]

  copy_contract
  rm "$TMP_ROOT/contracts/product-truth-v1.schema.json"
  if ln -s "$ROOT/contracts/product-truth-v1.schema.json" \
      "$TMP_ROOT/contracts/product-truth-v1.schema.json" 2>/dev/null; then
    run python3 "$TOOL" check --root "$TMP_ROOT" \
      --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only schema
    [ "$status" -ne 0 ]
    [[ "$output" == *"symlink escape"* ]]
  fi

  [ "$sentinel_hash" = "$(shasum -a 256 "$sentinel" | awk '{print $1}')" ]
  ! grep -Eq '^(from|import) (os|subprocess|urllib|requests|socket|importlib)' \
    "$ROOT/scripts/product-truth.py" "$ROOT/scripts/product_truth_core.py" \
    "$ROOT/scripts/product_truth_schema.py"
}

@test "DEV-118 @smoke PTC-002: dynamic inventory covers 19 commands on six targets" {
  run_check --only inventory
  [ "$status" -eq 0 ]
  [[ "$output" == *"19 commands x 6 targets"* ]]

  copy_contract
  copy_targets
  cp "$TMP_ROOT/template/.cursor/commands/agtoosa-help.md"     "$TMP_ROOT/template/.cursor/commands/agtoosa-unreviewed.md"
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only inventory
  [ "$status" -ne 0 ]
  [[ "$output" == *"unreviewed"* ]]
  [[ "$output" == *"cursor.project-commands"* ]]
}

@test "DEV-118 @smoke PTC-003: renderer is bounded and check modes do not write" {
  local before after
  before="$(git -C "$ROOT" status --porcelain=v1 | shasum -a 256 | awk '{print $1}')"
  run_check --only render
  [ "$status" -eq 0 ]
  run python3 "$TOOL" render --check --root "$ROOT" --contract "$CONTRACT" --as-of "$AS_OF"
  [ "$status" -eq 0 ]
  after="$(git -C "$ROOT" status --porcelain=v1 | shasum -a 256 | awk '{print $1}')"
  [ "$before" = "$after" ]

  copy_contract
  copy_targets
  printf 'outside\n' > "$TMP_ROOT/outside.txt"
  printf '\nPLATFORM-OWNED-SENTINEL\n' >> \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md"
  sed -i.bak 's/^- Question budget:/- Question budget: drifted /' \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md"
  rm -f "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md.bak"
  run python3 "$TOOL" render --check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF"
  [ "$status" -ne 0 ]
  run python3 "$TOOL" render --apply --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP_ROOT/outside.txt")" = "outside" ]
  grep -q 'PLATFORM-OWNED-SENTINEL' \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md"

  rm -rf "$TMP_ROOT"
  copy_contract
  copy_targets
  sed -i.bak '/AGTOOSA PRODUCT TRUTH END: command.build/d' \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-build.md"
  rm -f "$TMP_ROOT/template/.cursor/commands/agtoosa-build.md.bak"
  sed -i.bak 's/^- Question budget:/- Question budget: drifted /' \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md"
  rm -f "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md.bak"
  local malformed_hash
  malformed_hash="$(shasum -a 256 \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md" | awk '{print $1}')"
  run python3 "$TOOL" render --apply --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"requires exactly one existing managed block"* ]]
  [ "$malformed_hash" = "$(shasum -a 256 \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md" | awk '{print $1}')" ]

  rm -rf "$TMP_ROOT"
  copy_contract
  copy_targets
  sed -i.bak 's/^- Question budget:/- Question budget: drifted /' \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md"
  rm -f "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md.bak"
  printf 'outside-temp\n' > "$BATS_TEST_TMPDIR/outside-temp"
  ln -s "$BATS_TEST_TMPDIR/outside-temp" \
    "$TMP_ROOT/template/.cursor/commands/agtoosa-spec.md.product-truth.tmp"
  run python3 "$TOOL" render --apply --root "$TMP_ROOT" \
    --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF"
  [ "$status" -ne 0 ]
  [[ "$output" == *"temporary render path already exists"* ]]
  [ "$(cat "$BATS_TEST_TMPDIR/outside-temp")" = "outside-temp" ]
}

@test "DEV-118 @smoke PTC-004: every adapter preserves portable semantics and lifecycle goldens" {
  run_check --only adapters
  [ "$status" -eq 0 ]

  copy_contract
  copy_targets
  sed -i.bak 's/Quick max: 2/Quick max: 3/'     "$TMP_ROOT/template/.gemini/commands/agtoosa-spec.toml"
  rm -f "$TMP_ROOT/template/.gemini/commands/agtoosa-spec.toml.bak"
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only adapters
  [ "$status" -ne 0 ]
  [[ "$output" == *"google.gemini-cli"* ]]
  [[ "$output" == *"command.spec"* ]]
}

@test "DEV-118 @smoke PTC-005: generated local references use exact Docs casing" {
  run_check --only paths
  [ "$status" -eq 0 ]

  copy_contract
  copy_path_candidates
  printf '\nSee docs/Master-Plan.md for local state.\n' >>     "$TMP_ROOT/template/Docs/AgToosa_Build.md"
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only paths
  [ "$status" -ne 0 ]
  [[ "$output" == *"lowercase generated local path"* ]]
  [[ "$output" == *"AgToosa_Build.md"* ]]
}

@test "DEV-118 @smoke PTC-006: platform identities stay distinct across Bash and PowerShell" {
  run_check --only platforms
  [ "$status" -eq 0 ]

  copy_contract
  cp "$ROOT/agtoosa.sh" "$TMP_ROOT/agtoosa.sh"
  cp "$ROOT/agtoosa.ps1" "$TMP_ROOT/agtoosa.ps1"
  sed -i.bak "s/addPlatform 'vscode'/addPlatform 'copilot'/" "$TMP_ROOT/agtoosa.ps1"
  rm -f "$TMP_ROOT/agtoosa.ps1.bak"
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only platforms
  [ "$status" -ne 0 ]
  [[ "$output" == *"vscode"* ]]
  [[ "$output" == *"copilot"* ]]
}

@test "DEV-118 @smoke PTC-007: operation dependencies fail before mutation" {
  run_check --only dependencies     --available-commands powershell,git,bash,curl,tar,python3,node,npm,jq
  [ "$status" -eq 0 ]

  printf 'unchanged\n' > "$BATS_TEST_TMPDIR/mutation-sentinel"
  local before
  before="$(shasum -a 256 "$BATS_TEST_TMPDIR/mutation-sentinel" | awk '{print $1}')"
  run_check --only dependencies     --available-commands powershell,git,curl,tar,python3,node,npm,jq
  [ "$status" -ne 0 ]
  [[ "$output" == *"bash-delegated"* ]]
  [[ "$output" == *"missing prerequisite: bash"* ]]
  [ "$before" = "$(shasum -a 256 "$BATS_TEST_TMPDIR/mutation-sentinel" | awk '{print $1}')" ]
}

@test "DEV-118 @smoke PTC-008: Windows bootstrap binds and validates exact refs" {
  run_check --only windows-ref --windows-ref v5.3.28     --archive-map "$FIXTURES/windows-ref/archives.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"refs/tags/v5.3.28"* ]]

  run_check --only windows-ref --windows-ref 'v5.3.28;main'     --archive-map "$FIXTURES/windows-ref/archives.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid release ref"* ]]

  run_check --only windows-ref --windows-ref v9.9.9     --archive-map "$FIXTURES/windows-ref/archives.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unavailable release ref"* ]]
}

@test "DEV-118 @smoke PTC-009: claims expire and owner fingerprints invalidate freshness" {
  run_check --only claims
  [ "$status" -eq 0 ]

  run python3 "$TOOL" check --root "$ROOT" --contract "$CONTRACT"     --as-of 2026-10-13 --only claims
  [ "$status" -ne 0 ]
  [[ "$output" == *"stale/unverified"* ]]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["targets"][0]["renderer_version"] = "2"
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  run python3 "$TOOL" check --root "$ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only claims
  [ "$status" -ne 0 ]
  [[ "$output" == *"fingerprint"* ]]
}

@test "DEV-118 @smoke PTC-010: governed surfaces reject stale or overbroad public claims" {
  run_check --only claims
  [ "$status" -eq 0 ]

  run_check --only claims --scan-file "$FIXTURES/claims/overbroad.md"
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported public claim"* ]]
  [[ "$output" == *"overbroad.md"* ]]
}

@test "DEV-118 @smoke PTC-011: static checks cannot claim behavior provenance or universal support" {
  run_check --only boundaries
  [ "$status" -eq 0 ]

  copy_contract
  python3 - "$TMP_ROOT/contracts/product-truth-v1.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["static_claim_boundary"]["allowed"].append("host-recognition")
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  run python3 "$TOOL" check --root "$ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only boundaries
  [ "$status" -ne 0 ]
  [[ "$output" == *"forbidden conclusion"* ]]
  [[ "$output" == *"host-recognition"* ]]
}

@test "DEV-118 @smoke PTC-012: CI discovers every Must AC and retains adjacent owners" {
  run_check --only ci
  [ "$status" -eq 0 ]

  copy_contract
  mkdir -p "$TMP_ROOT/.github/workflows" "$TMP_ROOT/tests" "$TMP_ROOT/docs"
  cp "$ROOT/.github/workflows/ci.yml" "$TMP_ROOT/.github/workflows/ci.yml"
  cp "$ROOT/tests/product-truth.bats" "$TMP_ROOT/tests/product-truth.bats"
  cp "$ROOT/tests/agtoosa.bats" "$TMP_ROOT/tests/agtoosa.bats"
  cp "$ROOT/docs/AgToosa_TestPlan-DEV-118.md" "$TMP_ROOT/docs/AgToosa_TestPlan-DEV-118.md"
  sed -i.bak '/product-truth/d' "$TMP_ROOT/.github/workflows/ci.yml"
  rm -f "$TMP_ROOT/.github/workflows/ci.yml.bak"
  run python3 "$TOOL" check --root "$TMP_ROOT"     --contract "$TMP_ROOT/contracts/product-truth-v1.json" --as-of "$AS_OF" --only ci
  [ "$status" -ne 0 ]
  [[ "$output" == *"focused Product Truth CI gate"* ]]
}
