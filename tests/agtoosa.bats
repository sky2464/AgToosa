#!/usr/bin/env bats
# AgToosa generator smoke tests
# Run: bats tests/agtoosa.bats
# Requires: bats-core (https://github.com/bats-core/bats-core)

SCRIPT="$BATS_TEST_DIRNAME/../agtoosa.sh"
TEMPLATE_DIR="$BATS_TEST_DIRNAME/../template"

# ── Helpers ──────────────────────────────────────────────────────────────────
setup() {
  # Create a fresh temp project dir for each test
  TEST_PROJECT="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_PROJECT"
  # Clean up any ship/ left by the generator
  rm -rf "$BATS_TEST_DIRNAME/../ship"
}

# ── Flag tests ────────────────────────────────────────────────────────────────
@test "--version prints version string" {
  run bash "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == AgToosa\ v* ]]
}

@test "--help prints usage" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--force"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

@test "preflight fails without template/ directory" {
  # Run from a directory that has no template/
  run bash -c "cd /tmp && bash '$SCRIPT' --version"
  # --version exits 0 before the preflight check, so test the actual preflight via a different path
  run bash -c "cd /tmp && echo -e '$TEST_PROJECT\n1\nn\n' | bash '$SCRIPT' 2>&1 || true"
  [[ "$output" == *"template/"* ]]
}

# ── Dry-run tests ─────────────────────────────────────────────────────────────
@test "--dry-run shows files without copying" {
  # Provide: project path, select cursor (1), then script exits without prompting copy
  run bash -c "printf '$TEST_PROJECT\n1\n' | bash '$SCRIPT' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"No changes made"* ]]
  # Nothing should have been copied
  [ ! -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
}

# ── Copy path tests ───────────────────────────────────────────────────────────
@test "auto-copy installs core Docs files" {
  # Provide: project path, select all (8), confirm copy (Y)
  run bash -c "printf '$TEST_PROJECT\n8\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Spec.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Build.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Review.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Ship.md" ]
}

@test "auto-copy with --force overwrites existing files" {
  # Pre-create a file
  mkdir -p "$TEST_PROJECT/Docs"
  echo "old content" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"

  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  # File should be overwritten (not "old content")
  run grep -q "old content" "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  [ "$status" -ne 0 ]
}

@test "auto-copy skips existing files without --force" {
  mkdir -p "$TEST_PROJECT/Docs"
  echo "old content" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"

  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping"* ]]
  # Old file should be preserved
  run grep -q "old content" "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  [ "$status" -eq 0 ]
}

@test "platform selection 1 copies .cursorrules but not CLAUDE.md" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursorrules" ]
  [ ! -f "$TEST_PROJECT/CLAUDE.md" ]
}

@test "platform selection 3 copies CLAUDE.md and AgToosa_Claude.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Claude.md" ]
}

@test "platform selection 4 copies AGENTS.md and AgToosa_Gemini.md" {
  run bash -c "printf '$TEST_PROJECT\n4\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/AGENTS.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Gemini.md" ]
}

@test "platform selection 7 copies .roorules and OPENCODE.md" {
  run bash -c "printf '$TEST_PROJECT\n7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.roorules" ]
  [ -f "$TEST_PROJECT/OPENCODE.md" ]
}

# ── No-copy path tests ────────────────────────────────────────────────────────
@test "declining copy keeps ship/ intact" {
  run bash -c "printf '$TEST_PROJECT\n1\nn\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -d "$BATS_TEST_DIRNAME/../ship" ]
  [ -f "$BATS_TEST_DIRNAME/../ship/Docs/AgToosa_Agent.md" ]
}

@test "ship/ is cleaned up after successful auto-copy" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ ! -d "$BATS_TEST_DIRNAME/../ship" ]
}
