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
  # Copy the script to /tmp where there is no sibling template/ directory
  local tmp_script
  tmp_script="$(mktemp /tmp/agtoosa-preflight-test-XXXXXX.sh)"
  cp "$SCRIPT" "$tmp_script"
  run bash "$tmp_script" 2>&1 || true
  rm -f "$tmp_script"
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

@test "auto-copy appends AgToosa block to existing platform files without --force" {
  mkdir -p "$TEST_PROJECT"
  echo "old content" > "$TEST_PROJECT/CLAUDE.md"

  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"appended"* ]]
  # A .bak of the original file should have been created
  [ "$(find "$TEST_PROJECT" -name 'CLAUDE.md.bak.*' | wc -l)" -gt 0 ]
  # Original user content should be preserved
  run grep -q "old content" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
  # AgToosa block should have been appended
  run grep -q "AgToosa" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
  # Docs/ workflow files are always updated regardless
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  run grep -q "old content" "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  [ "$status" -ne 0 ]
}

@test "auto-copy does not duplicate AgToosa block on re-run" {
  # First install
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  # Second run (same version) — shows 'up to date', does not duplicate the block
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"up to date"* ]]
  # Block should appear exactly once
  [ "$(grep -c 'AgToosa.*START' "$TEST_PROJECT/CLAUDE.md")" -eq 1 ]
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

# ── DEV-147: Platform coverage ────────────────────────────────

@test "platform selection 2 copies .windsurfrules" {
  run bash -c "printf '$TEST_PROJECT\n2\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.windsurfrules" ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
}

@test "platform selection 5 copies copilot-instructions.md" {
  run bash -c "printf '$TEST_PROJECT\n5\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.github/copilot-instructions.md" ]
  [ ! -f "$TEST_PROJECT/CLAUDE.md" ]
}

@test "re-run with existing copilot-instructions.md appends AgToosa block without --force" {
  mkdir -p "$TEST_PROJECT/.github"
  echo "# My existing Copilot instructions" > "$TEST_PROJECT/.github/copilot-instructions.md"

  run bash -c "printf '$TEST_PROJECT\n5\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"appended"* ]]
  # A .bak of the original file should have been created
  [ "$(find "$TEST_PROJECT/.github" -name 'copilot-instructions.md.bak.*' | wc -l)" -gt 0 ]
  # Original user content should be preserved
  run grep -q "My existing Copilot instructions" "$TEST_PROJECT/.github/copilot-instructions.md"
  [ "$status" -eq 0 ]
  # AgToosa block should have been appended
  run grep -q "AgToosa" "$TEST_PROJECT/.github/copilot-instructions.md"
  [ "$status" -eq 0 ]
}

@test "platform selection 6 copies only Docs files with no platform config" {
  run bash -c "printf '$TEST_PROJECT\n6\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
  [ ! -f "$TEST_PROJECT/CLAUDE.md" ]
  [ ! -f "$TEST_PROJECT/.windsurfrules" ]
}

@test "platform selection 8 copies all platform files" {
  run bash -c "printf '$TEST_PROJECT\n8\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursorrules" ]
  [ -f "$TEST_PROJECT/.windsurfrules" ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/AGENTS.md" ]
  [ -f "$TEST_PROJECT/.github/copilot-instructions.md" ]
  [ -f "$TEST_PROJECT/.roorules" ]
  [ -f "$TEST_PROJECT/OPENCODE.md" ]
}

@test "--list-template-files lists core and platform files" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Agent.md"* ]]
  [[ "$output" == *"Docs/AgToosa_QA.md"* ]]
  [[ "$output" == *".cursorrules"* ]]
  [[ "$output" == *"CLAUDE.md"* ]]
  [[ "$output" == *"Docs/Context/workflow.md"* ]]
}

@test "auto-copy installs AgToosa_QA.md" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_QA.md" ]
}

@test "auto-copy creates Context/ directory with config stubs" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -d "$TEST_PROJECT/Docs/Context" ]
  [ -f "$TEST_PROJECT/Docs/Context/workflow.md" ]
  [ -f "$TEST_PROJECT/Docs/Context/tech-stack.md" ]
  [ -f "$TEST_PROJECT/Docs/Context/product.md" ]
  [ -f "$TEST_PROJECT/Docs/Context/product-guidelines.md" ]
}

# ── DEV-150: inject_version tests ────────────────────────────

@test "inject_version: platform files contain AgToosa version marker" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run grep -q "AgToosa v" "$TEST_PROJECT/.cursorrules"
  [ "$status" -eq 0 ]
}

@test "inject_version: .md platform files use HTML comment marker" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run grep -q "<!-- AgToosa v" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
}

# ── DEV-151: extract_version tests ───────────────────────────

@test "extract_version: same-version reinstall with --force keeps customizations" {
  # Install first
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Reinstall with --force — same version should be kept (extract_version detects it)
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  [[ "$output" == *"keeping your customizations"* ]]
}

# ── DEV-152: version_lt tests ────────────────────────────────

@test "version_lt: older version triggers update with --force" {
  mkdir -p "$TEST_PROJECT"
  # Create a file with an older version marker (shell-style comment for .cursorrules)
  printf '# AgToosa v1.0.0\n# old content\n' > "$TEST_PROJECT/.cursorrules"

  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  # Output should indicate upgrade happened
  [[ "$output" == *"v1.0.0 →"* ]]
}

# ── DEV-153: backup_file tests ───────────────────────────────

@test "backup_file: creates timestamped .bak file when upgrading" {
  mkdir -p "$TEST_PROJECT"
  printf '# AgToosa v1.0.0\nold content\n' > "$TEST_PROJECT/.cursorrules"

  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  # At least one .bak file should exist
  bak_count="$(find "$TEST_PROJECT" -name '.cursorrules.bak.*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
}

@test "backup_file: .bak file contains original content" {
  mkdir -p "$TEST_PROJECT"
  printf '# AgToosa v1.0.0\noriginal-sentinel-content\n' > "$TEST_PROJECT/.cursorrules"

  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  bak_file="$(find "$TEST_PROJECT" -name '.cursorrules.bak.*' 2>/dev/null | head -1)"
  [ -n "$bak_file" ]
  run grep -q "original-sentinel-content" "$bak_file"
  [ "$status" -eq 0 ]
}

# ── DEV-154: copy_platform_file (new file) tests ─────────────

@test "copy_platform_file: new platform file is copied with version marker" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursorrules" ]
  # Version marker should be present
  run grep -q "AgToosa v" "$TEST_PROJECT/.cursorrules"
  [ "$status" -eq 0 ]
}

@test "copy_platform_file: new file copy is counted in output" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Copied:"* ]]
}

# ── DEV-155: copy_platform_file (force + backup) tests ───────

@test "copy_platform_file: --force on older version creates .bak and overwrites" {
  mkdir -p "$TEST_PROJECT"
  printf '# AgToosa v1.0.0\noriginal\n' > "$TEST_PROJECT/.cursorrules"

  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  # .bak file created
  bak_count="$(find "$TEST_PROJECT" -name '.cursorrules.bak.*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  # File is overwritten with new version
  run grep -q "AgToosa v1.0.0" "$TEST_PROJECT/.cursorrules"
  [ "$status" -ne 0 ]
}

@test "copy_platform_file: --force on same version skips backup" {
  # Install first
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Reinstall with --force — same version, no backup
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  bak_count="$(find "$TEST_PROJECT" -name '.cursorrules.bak.*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$bak_count" -eq 0 ]
}

@test "gitignore warning shown when backup files are created" {
  mkdir -p "$TEST_PROJECT"
  printf '# AgToosa v1.0.0\nold\n' > "$TEST_PROJECT/.cursorrules"

  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Backup files created"* ]]
}

# ── Native platform command/rule tests ───────────────────────────────────────

@test "Claude option installs .claude/commands/ slash commands" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-build.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-review.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-ship.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-help.md" ]
}

@test "Claude option installs .claude/settings.json with hooks" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/settings.json" ]
  run python3 -c "import json; d=json.load(open('$TEST_PROJECT/.claude/settings.json')); exit(0 if 'hooks' in d else 1)"
  [ "$status" -eq 0 ]
}

@test "Claude option installs .claude/skills/agtoosa-review.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/skills/agtoosa-review.md" ]
}

@test "Cursor option installs .cursor/rules/ MDX files" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-core.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-spec.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-build.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-review.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-ship.mdc" ]
}

@test "non-Claude option does not install .claude/ directory" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ ! -f "$TEST_PROJECT/.claude/settings.json" ]
}

@test "non-Cursor option does not install .cursor/rules/" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/.cursor/rules/agtoosa-core.mdc" ]
}

@test "settings.json hooks not duplicated on re-run" {
  # First install
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/settings.json" ]
  # Second install — hooks must not be duplicated
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Stop hook command should appear exactly once in the JSON
  stop_count="$(python3 -c "
import json
d = json.load(open('$TEST_PROJECT/.claude/settings.json'))
cmds = [h.get('command','') for e in d.get('hooks',{}).get('Stop',[]) for h in e.get('hooks',[])]
print(sum(1 for c in cmds if 'Master-Plan' in c))
")"
  [ "$stop_count" -eq 1 ]
}

@test "dry-run shows .claude/commands as AgToosa-owned overwrite" {
  run bash -c "printf '$TEST_PROJECT\n3\n' | bash '$SCRIPT' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *".claude/commands"* ]]
  [[ "$output" == *"AgToosa-owned"* ]]
}
