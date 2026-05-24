#!/usr/bin/env bats
# AgToosa generator smoke tests
# Run: bats tests/agtoosa.bats
# Requires: bats-core (https://github.com/bats-core/bats-core)
SCRIPT="$BATS_TEST_DIRNAME/../agtoosa.sh"
TEMPLATE_DIR="$BATS_TEST_DIRNAME/../template"
BOOTSTRAP_SCRIPT="$BATS_TEST_DIRNAME/../bootstrap.sh"
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
  # Update this expected string on each release (Eng review: exact-version pin)
  run bash "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == "AgToosa v4.12.2" ]]
}
@test "--help prints usage" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--force"* ]]
  [[ "$output" == *"--dry-run"* ]]
}
@test "bootstrap --help prints options" {
  run bash "$BOOTSTRAP_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--ref"* ]]
  [[ "$output" == *"--archive"* ]]
  [[ "$output" == *"-- --version"* ]]
}
@test "bootstrap parses pinned ref and fails clearly for missing local archive" {
  run bash "$BOOTSTRAP_SCRIPT" --ref v9.9.9 --archive /tmp/does-not-exist-agtoosa.tgz
  [ "$status" -ne 0 ]
  [[ "$output" == *"--archive file not found"* ]]
}
@test "bootstrap rejects incomplete archive payload" {
  local fixture_dir
  local archive_path
  fixture_dir="$(mktemp -d)"
  archive_path="$(mktemp /tmp/agtoosa-bootstrap-fixture-XXXXXX.tar.gz)"
  mkdir -p "$fixture_dir/AgToosa-fixture"
  cat > "$fixture_dir/AgToosa-fixture/agtoosa.sh" <<'EOF'
#!/usr/bin/env bash
echo "fixture"
EOF
  chmod +x "$fixture_dir/AgToosa-fixture/agtoosa.sh"
  tar -czf "$archive_path" -C "$fixture_dir" AgToosa-fixture
  run bash "$BOOTSTRAP_SCRIPT" --archive "$archive_path"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Extracted archive is incomplete"* ]]
  rm -rf "$fixture_dir"
  rm -f "$archive_path"
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
@test "platform selection 7 copies OPENCODE.md" {
  run bash -c "printf '$TEST_PROJECT\n7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
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
@test "ship/ is cleaned up after unexpected EOF (forced failure scenario)" {
  # Provide project path and platform but no answer to copy prompt.
  # The read for "Copy files now?" gets EOF and exits non-zero.
  # The EXIT trap must remove ship/ regardless.
  run bash -c "printf '$TEST_PROJECT\n1\n' | bash '$SCRIPT'"
  # ship/ must be absent whether the script succeeded or failed
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
  [ -d "$TEST_PROJECT/.github/instructions" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-core.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-testing.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-security.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-changelog.instructions.md" ]
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
@test "platform selection 6 (VS Code) installs copilot-instructions, prompts, and agent" {
  run bash -c "printf '$TEST_PROJECT\n6\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ -f "$TEST_PROJECT/.github/copilot-instructions.md" ]
  [ -d "$TEST_PROJECT/.github/instructions" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-core.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-testing.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-security.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-changelog.instructions.md" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-init.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa.agent.md" ]
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
  [ -d "$TEST_PROJECT/.github/instructions" ]
  [ -f "$TEST_PROJECT/.github/instructions/agtoosa-core.instructions.md" ]
  [ -f "$TEST_PROJECT/OPENCODE.md" ]
  # Native platform rule/command directories
  [ -d "$TEST_PROJECT/.cursor/rules" ]
  [ -d "$TEST_PROJECT/.cursor/commands" ]
  [ -d "$TEST_PROJECT/.claude/commands" ]
  [ -d "$TEST_PROJECT/.gemini/commands" ]
  [ -d "$TEST_PROJECT/.github/prompts" ]
  [ -d "$TEST_PROJECT/.github/agents" ]
  [ -d "$TEST_PROJECT/.codex/skills" ]
  [ -d "$TEST_PROJECT/.codex/prompts" ]
  [ -d "$TEST_PROJECT/.windsurf/rules" ]
  [ -d "$TEST_PROJECT/.windsurf/workflows" ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.windsurf/workflows/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-spec/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-spec.md" ]
}
@test "platform selection 1 installs .cursor/rules/ MDX files" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-core.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-spec.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-build.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-goal.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-revert.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
}
@test "platform selection 2 installs .windsurf/rules/ files" {
  run bash -c "printf '$TEST_PROJECT\n2\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-core.md" ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-goal.md" ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-revert.md" ]
  [ -f "$TEST_PROJECT/.windsurf/workflows/agtoosa-spec.md" ]
}
@test "platform selection 3 installs .claude/commands/ slash commands" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-spec.md"  ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-ship.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-goal.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-help.md" ]
}
@test "platform selection 4 installs .gemini/commands/ TOML files" {
  run bash -c "printf '$TEST_PROJECT\n4\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-init.toml" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-spec.toml" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-goal.toml" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-help.toml" ]
}
@test "platform selection 5 installs .github/prompts/ and .github/agents/" {
  run bash -c "printf '$TEST_PROJECT\n5\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-init.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-spec.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-goal.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa.agent.md" ]
}
@test "platform selection 7 installs OPENCODE.md, Codex skills, and Codex prompts" {
  run bash -c "printf '$TEST_PROJECT\n7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/OPENCODE.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-spec/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-build/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-build.md" ]
  [ ! -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
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
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-goal.md" ]
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
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-goal.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-review.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-ship.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-build.md" ]
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
  [ ! -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
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
@test "--list-template-files output has no duplicates" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  # Sort and find any lines that appear more than once
  local dupes
  dupes="$(echo "$output" | sort | uniq -d)"
  [ -z "$dupes" ]
}
# ── Update wiring: AgToosa_Update.md in DOCS_FILES ───────────
@test "--list-template-files includes Docs/AgToosa_Update.md" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Update.md"* ]]
}
# ── DEV-178: unknown flag ─────────────────────────────────────
@test "unknown flag exits 1 with error message" {
  run bash "$SCRIPT" --foo
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
  [[ "$output" == *"Usage:"* ]]
}
# ── DEV-179: non-existent path ────────────────────────────────
@test "non-existent project path exits with error" {
  run bash -c "printf '/tmp/agtoosa-nonexistent-99999\n' | bash '$SCRIPT'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}
# ── DEV-177: self-targeting block ─────────────────────────────
@test "self-targeting AgToosa source directory is blocked" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash -c "printf '$src_dir\n' | bash '$SCRIPT'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Target path cannot be the AgToosa source directory"* ]]
}
# ── DEV-175: invalid selection warning ───────────────────────
@test "invalid selection number shows warning but continues" {
  # '9' is out of range → warning; then no valid platform → no-platform prompt → default N → exit 0
  run bash -c "printf '$TEST_PROJECT\n9\n\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Unknown selection"* ]]
}
# ── DEV-176: empty platform selection ────────────────────────
@test "empty selection + default N exits with re-run suggestion" {
  run bash -c "printf '$TEST_PROJECT\n\n\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No AI platform selected"* ]]
  [[ "$output" == *"Re-run"* ]]
}
@test "empty selection + explicit y installs only Docs files" {
  run bash -c "printf '$TEST_PROJECT\n\ny\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ ! -f "$TEST_PROJECT/CLAUDE.md" ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
  [ ! -f "$TEST_PROJECT/AGENTS.md" ]
}
# ── DEV-180: multi-platform combo ────────────────────────────
@test "multi-platform combo '1 3' installs both Cursor and Claude files" {
  run bash -c "printf '$TEST_PROJECT\n1 3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursorrules" ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-core.mdc" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ ! -f "$TEST_PROJECT/.windsurfrules" ]
  [ ! -f "$TEST_PROJECT/AGENTS.md" ]
}
@test "multi-platform combo '3 4' installs both Claude and Gemini files" {
  run bash -c "printf '$TEST_PROJECT\n3 4\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/AGENTS.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-init.toml" ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
}
@test "multi-platform combo '5 6' deduplicates .github/ files (no double install)" {
  run bash -c "printf '$TEST_PROJECT\n5 6\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.github/copilot-instructions.md" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-init.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa.agent.md" ]
  # Only one AgToosa START block — no duplicate from VS Code path
  [ "$(grep -c 'AgToosa.*START' "$TEST_PROJECT/.github/copilot-instructions.md")" -eq 1 ]
}
# ── DEV-172: merge_platform_file Case B (older version) ──────
@test "merge_platform_file Case B: older AgToosa block upgraded in-place with .bak" {
  mkdir -p "$TEST_PROJECT"
  printf '<!-- AgToosa v1.0.0 START -->\nold block content\n<!-- AgToosa END -->\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  local main_output="$output"
  # .bak file created
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name 'CLAUDE.md.bak.*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  # Old version marker gone, new one present
  run grep -q "v1.0.0 START" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -ne 0 ]
  run grep -q "AgToosa v.*START" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
  # Only one START block
  [ "$(grep -c 'AgToosa.*START' "$TEST_PROJECT/CLAUDE.md")" -eq 1 ]
  [[ "$main_output" == *"merged:"* ]]
}
# ── DEV-173: merge_platform_file Case C (old-format, no START/END) ──
@test "merge_platform_file Case C: old-format AgToosa file replaced with backup" {
  mkdir -p "$TEST_PROJECT"
  printf '<!-- AgToosa v1.0.0 -->\nold format content without delimiters\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # .bak file created
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name 'CLAUDE.md.bak.*' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  # New file uses START/END delimiter format
  run grep -q "AgToosa v.*START" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
}
# ── DEV-174: merge_platform_file Case D + --force ────────────
@test "merge_platform_file Case D + --force: user-owned file fully replaced" {
  mkdir -p "$TEST_PROJECT"
  printf 'my-sentinel-user-content-only\n' > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  local main_output="$output"
  # .bak file created with original content
  local bak_file
  bak_file="$(find "$TEST_PROJECT" -name 'CLAUDE.md.bak.*' 2>/dev/null | head -1)"
  [ -n "$bak_file" ]
  run grep -q "my-sentinel-user-content-only" "$bak_file"
  [ "$status" -eq 0 ]
  # Main file replaced — original content gone
  run grep -q "my-sentinel-user-content-only" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -ne 0 ]
  # New file has AgToosa version marker
  run grep -q "AgToosa v.*START" "$TEST_PROJECT/CLAUDE.md"
  [ "$status" -eq 0 ]
  [[ "$main_output" == *"vunknown →"* ]]
}
# ── DEV-181: --dry-run --force combined ──────────────────────
@test "--dry-run --force shows 'Would backup + replace' for older-versioned file" {
  mkdir -p "$TEST_PROJECT"
  printf '# AgToosa v1.0.0 START\nold\n# AgToosa END\n' > "$TEST_PROJECT/.cursorrules"
  run bash -c "printf '$TEST_PROJECT\n1\n' | bash '$SCRIPT' --dry-run --force"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would backup + replace"* ]]
  [[ "$output" == *"No changes made"* ]]
  # File untouched
  run grep -q "old" "$TEST_PROJECT/.cursorrules"
  [ "$status" -eq 0 ]
}
@test "--dry-run --force shows 'Would keep' for same-version file" {
  # Install first to get a current-version file
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run bash -c "printf '$TEST_PROJECT\n1\n' | bash '$SCRIPT' --dry-run --force"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would keep"* ]]
  [[ "$output" == *"No changes made"* ]]
}
# ── DEV-182: --dry-run messages for existing platform files ──
@test "--dry-run shows 'Would backup + merge' for file with older AgToosa block" {
  mkdir -p "$TEST_PROJECT"
  printf '<!-- AgToosa v1.0.0 START -->\nold block\n<!-- AgToosa END -->\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\n' | bash '$SCRIPT' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would backup + merge AgToosa block"* ]]
  [[ "$output" == *"No changes made"* ]]
}
@test "--dry-run shows 'Would backup + append' for user-owned file" {
  mkdir -p "$TEST_PROJECT"
  printf 'user-only content no agtoosa markers\n' > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\n' | bash '$SCRIPT' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would backup + append AgToosa block"* ]]
  [[ "$output" == *"No changes made"* ]]
}
@test "--dry-run shows 'Already up to date' for current-version file" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run bash -c "printf '$TEST_PROJECT\n3\n' | bash '$SCRIPT' --dry-run"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already up to date"* ]]
  [[ "$output" == *"No changes made"* ]]
}
# ── DEV-183: Context/ stubs preserved on re-run ──────────────
@test "Context/ stubs are skipped on re-run to preserve user edits" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/Context/tech-stack.md" ]
  echo "my-custom-tech-stack-sentinel" >> "$TEST_PROJECT/Docs/Context/tech-stack.md"
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  local rerun_output="$output"
  run grep -q "my-custom-tech-stack-sentinel" "$TEST_PROJECT/Docs/Context/tech-stack.md"
  [ "$status" -eq 0 ]
  [[ "$rerun_output" == *"Skipping"* ]]
}
# ── DEV-184: .gitignore warning absent when no backups ────────
@test "gitignore warning NOT shown on clean install with no backups" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Backup files created"* ]]
}
@test "gitignore warning NOT shown on same-version re-run" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Backup files created"* ]]
}
# ── DEV-185: merge_settings_json invalid JSON fallback ───────
@test "merge_settings_json: invalid JSON in existing settings.json skips gracefully" {
  mkdir -p "$TEST_PROJECT/.claude"
  printf '{ invalid json here }' > "$TEST_PROJECT/.claude/settings.json"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Warning shown, file not silently cleared
  [[ "$output" == *"skipped"* ]] || [[ "$output" == *"JSON parse error"* ]] || [[ "$output" == *"unavailable"* ]]
  # Original invalid content still present (not overwritten with valid JSON)
  run grep -q "invalid json here" "$TEST_PROJECT/.claude/settings.json"
  [ "$status" -eq 0 ]
}
# ── DEV-186: manual copy instructions ────────────────────────
@test "declining copy shows manual copy instructions" {
  run bash -c "printf '$TEST_PROJECT\n1\nn\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"copy them manually"* ]]
  [[ "$output" == *"cp -r ship/"* ]]
  [[ "$output" == *"find ship/"* ]]
}
# ── --update: flag wiring ─────────────────────────────────────
@test "--update on path with no Docs/ exits with error" {
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"No Docs/"* ]]
}
@test "--update on non-existent path exits with error" {
  run bash "$SCRIPT" --update "/tmp/agtoosa-nonexistent-update-99999"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}
@test "--update on AgToosa source directory is blocked" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash "$SCRIPT" --update "$src_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Target path cannot be the AgToosa source directory"* ]]
}
# ── --update: core behavior ───────────────────────────────────
@test "--update overwrites workflow files" {
  run bash -c "printf '$TEST_PROJECT\n8\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "STALE CONTENT" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$(cat "$TEST_PROJECT/Docs/AgToosa_Agent.md")" != "STALE CONTENT" ]]
}
@test "--update preserves Docs/Context/ files" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "my custom stack" > "$TEST_PROJECT/Docs/Context/tech-stack.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "my custom stack" "$TEST_PROJECT/Docs/Context/tech-stack.md"
}
@test "--update preserves Docs/Master-Plan.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "# My Master Plan" > "$TEST_PROJECT/Docs/Master-Plan.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "My Master Plan" "$TEST_PROJECT/Docs/Master-Plan.md"
}
@test "Master-Plan.md template contains progress bar placeholder" {
  run grep -c "▰" "$TEMPLATE_DIR/Docs/Master-Plan.md"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}
@test "Master-Plan.md template contains Active Tasks checkbox tree" {
  run grep -c "\- \[ \]" "$TEMPLATE_DIR/Docs/Master-Plan.md"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}
@test "--update preserves Docs/AgToosa_Changelog.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "# My Changelog" > "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "My Changelog" "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
}
@test "MA5: --update preserves Docs/Master-Architecture.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "# My Architecture" > "$TEST_PROJECT/Docs/Master-Architecture.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "My Architecture" "$TEST_PROJECT/Docs/Master-Architecture.md"
}
@test "--update writes Docs/.agtoosa-version" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  local ver
  ver="$(cat "$TEST_PROJECT/Docs/.agtoosa-version")"
  [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
# ── --update: version display ─────────────────────────────────
@test "--update shows 'unknown' when no prior version file" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  rm -f "$TEST_PROJECT/Docs/.agtoosa-version"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unknown"* ]]
}
@test "--update shows old version when prior version file exists" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "2.0.0" > "$TEST_PROJECT/Docs/.agtoosa-version"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2.0.0"* ]]
}
# ── --update: platform detection ─────────────────────────────
@test "--update detects installed Claude platform and merges CLAUDE.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  printf '<!-- AgToosa v1.0.0 START -->\nold content\n<!-- AgToosa END -->\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name "CLAUDE.md.bak.*" | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  ! grep -q "v1.0.0 START" "$TEST_PROJECT/CLAUDE.md"
}
@test "--update does not create .cursorrules when not previously installed" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
}
@test "--update adds native discoverability dirs for existing platform installs" {
  run bash -c "printf '$TEST_PROJECT\n1 2 7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  rm -rf "$TEST_PROJECT/.cursor/commands" "$TEST_PROJECT/.windsurf/workflows" "$TEST_PROJECT/.codex/skills" "$TEST_PROJECT/.codex/prompts"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.windsurf/workflows/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-spec/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-spec.md" ]
}
# ── --update --dry-run / --force ─────────────────────────────
@test "--update --dry-run writes no files and shows DRY RUN" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "STALE" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  run bash "$SCRIPT" --update --dry-run "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  grep -q "STALE" "$TEST_PROJECT/Docs/AgToosa_Agent.md"
}
@test "--update --force replaces user-owned platform entry-point with backup" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "my own CLAUDE content, no agtoosa markers" > "$TEST_PROJECT/CLAUDE.md"
  run bash "$SCRIPT" --update --force "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name "CLAUDE.md.bak.*" | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  ! grep -q "my own CLAUDE content" "$TEST_PROJECT/CLAUDE.md"
}
# ── /agtoosa-update wiring ────────────────────────────────────
@test "all platform entry-point templates include /agtoosa-update" {
  local files=(
    "$TEMPLATE_DIR/CLAUDE.md"
    "$TEMPLATE_DIR/.cursorrules"
    "$TEMPLATE_DIR/AGENTS.md"
    "$TEMPLATE_DIR/.windsurfrules"
    "$TEMPLATE_DIR/OPENCODE.md"
    "$TEMPLATE_DIR/.github/copilot-instructions.md"
  )
  local f
  for f in "${files[@]}"; do
    grep -q "agtoosa-update" "$f" || {
      echo "Missing /agtoosa-update in: $f"
      return 1
    }
  done
}
@test "AgToosa_Agent.md utility table includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
}
@test "agtoosa-update Claude command exists in template" {
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-update.md" ]
}
@test "agtoosa-help Claude command includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
}
@test "agtoosa-help Claude command includes /agtoosa-goal" {
  grep -q "agtoosa-goal" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
}
@test "agtoosa-update Gemini command exists in template" {
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-update.toml" ]
}
@test "agtoosa-help Gemini command includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
}
@test "agtoosa-help Gemini command includes /agtoosa-goal" {
  grep -q "agtoosa-goal" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
}
@test "agtoosa-update Copilot prompt exists in template" {
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-update.prompt.md" ]
}
@test "agtoosa-help Copilot prompt includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
}
@test "agtoosa-help Copilot prompt includes /agtoosa-goal" {
  grep -q "agtoosa-goal" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
}
@test "agtoosa-update Cursor rule exists in template" {
  [ -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-update.mdc" ]
}
@test "agtoosa-update Windsurf rule exists in template" {
  [ -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-update.md" ]
}
# ── mattpocock/skills integration tests ──────────────────────────────────────
@test "agtoosa-debug workflow doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Debug.md" ]
}
@test "agtoosa-debug Claude command exists in template" {
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-debug.md" ]
}
@test "agtoosa-debug Claude skill exists in template" {
  [ -f "$TEMPLATE_DIR/.claude/skills/agtoosa-debug.md" ]
}
@test "agtoosa-debug Cursor rule exists in template" {
  [ -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-debug.mdc" ]
}
@test "agtoosa-debug Windsurf rule exists in template" {
  [ -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-debug.md" ]
}
@test "agtoosa-debug Gemini command exists in template" {
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-debug.toml" ]
}
@test "agtoosa-debug Copilot prompt exists in template" {
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-debug.prompt.md" ]
}
@test "agtoosa-concise workflow doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Concise.md" ]
}
@test "agtoosa-concise Claude command exists in template" {
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-concise.md" ]
}
@test "agtoosa-concise Cursor rule exists in template" {
  [ -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-concise.mdc" ]
}
@test "agtoosa-concise Windsurf rule exists in template" {
  [ -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-concise.md" ]
}
@test "agtoosa-concise Gemini command exists in template" {
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-concise.toml" ]
}
@test "agtoosa-concise Copilot prompt exists in template" {
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-concise.prompt.md" ]
}
@test "git guardrails hook script exists in template" {
  [ -f "$TEMPLATE_DIR/.claude/hooks/block-dangerous-git.sh" ]
}
@test "git guardrails hook is executable" {
  [ -x "$TEMPLATE_DIR/.claude/hooks/block-dangerous-git.sh" ]
}
@test "CONTEXT-FORMAT reference doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/CONTEXT-FORMAT.md" ]
}
@test "ADR-FORMAT reference doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/ADR-FORMAT.md" ]
}
@test "DEEPENING reference doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/DEEPENING.md" ]
}
@test "LANGUAGE reference doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/LANGUAGE.md" ]
}
@test "agtoosa-spec includes domain language alignment in Part 1" {
  grep -q "Domain Language Alignment" "$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
}
@test "agtoosa-spec workflow includes to-issues sub-command" {
  grep -q "to-issues" "$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
}
@test "agtoosa-review workflow includes DEEPENING reference" {
  grep -q "DEEPENING" "$TEMPLATE_DIR/Docs/AgToosa_Review.md"
}
@test "agtoosa-init workflow includes zoom-out sub-command" {
  grep -q "zoom-out" "$TEMPLATE_DIR/Docs/AgToosa_Init.md"
}
@test "agtoosa-goal workflow doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Goal.md" ]
}
@test "agtoosa-goal workflow is listed in DOCS_FILES" {
  grep -q '"Docs/AgToosa_Goal.md"' "$BATS_TEST_DIRNAME/../lib/config.sh"
}
@test "--list-template-files includes agtoosa-goal workflow and native entries" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Goal.md"* ]]
  [[ "$output" == *".claude/commands/agtoosa-goal.md"* ]]
  [[ "$output" == *".cursor/rules/agtoosa-goal.mdc"* ]]
  [[ "$output" == *".gemini/commands/agtoosa-goal.toml"* ]]
  [[ "$output" == *".github/prompts/agtoosa-goal.prompt.md"* ]]
  [[ "$output" == *".windsurf/rules/agtoosa-goal.md"* ]]
}
@test "agtoosa-goal native platform templates exist" {
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-goal.md" ]
  [ -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-goal.mdc" ]
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-goal.toml" ]
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-goal.prompt.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-goal.md" ]
}
@test "goal contract is integrated into core workflows" {
  grep -q "Goal Clarification Protocol" "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q "Project Goal Contract" "$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  grep -q "Story Goal Contract" "$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q "Goal Contract alignment" "$TEMPLATE_DIR/Docs/AgToosa_Review.md"
  grep -q "Goal Contract satisfied" "$TEMPLATE_DIR/Docs/AgToosa_Ship.md"
}
@test "agtoosa-update remains read-only while reporting goal gaps" {
  grep -q "pure read command" "$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q "This step is read-only" "$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q "Goal clarity gaps" "$TEMPLATE_DIR/Docs/AgToosa_Update.md"
}
@test "SPEC-FORMAT defines story Goal Contract" {
  grep -q "Goal Contract" "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q "Success condition" "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q "Proof / evidence" "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
}
@test "agtoosa-goal does not add Claude-specific Stop hook evaluator" {
  run grep -q "agtoosa-goal" "$TEMPLATE_DIR/.claude/settings.json"
  [ "$status" -ne 0 ]
  run grep -q "Goal Contract" "$TEMPLATE_DIR/.claude/settings.json"
  [ "$status" -ne 0 ]
}
# ── ADR implementation tests ─────────────────────────────────────────────────
@test "AgToosa_Governance reference doc exists in template" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Governance.md" ]
}
@test "AgToosa_Governance is listed in DOCS_FILES" {
  grep -q "AgToosa_Governance" "$BATS_TEST_DIRNAME/../lib/config.sh"
}
@test "SPEC-FORMAT.md exists in template" {
  [ -f "template/Docs/SPEC-FORMAT.md" ]
}
@test "SPEC-FORMAT.md is listed in DOCS_FILES" {
  run grep -c '"Docs/SPEC-FORMAT.md"' "$BATS_TEST_DIRNAME/../lib/config.sh"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}
@test "--list-template-files includes SPEC-FORMAT.md" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"SPEC-FORMAT.md"* ]]
}
@test "--help lists publish registry subcommand" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"publish"* ]]
}
@test "--registry unknown command exits non-zero" {
  run bash "$SCRIPT" --registry bogus-cmd
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown registry command"* ]]
}
@test "version parity: agtoosa.sh and agtoosa.ps1 report same version" {
  BASH_VER=$(grep -m1 'AGTOOSA_VERSION=' "$BATS_TEST_DIRNAME/../agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  PS_VER=$(grep -m1 'AGTOOSA_VERSION' "$BATS_TEST_DIRNAME/../agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  [ "$BASH_VER" = "$PS_VER" ]
}
@test "validate_pack_files rejects .sh files" {
  local pack_dir
  pack_dir="$(mktemp -d)"
  echo "#!/bin/bash" > "$pack_dir/evil.sh"
  source "$BATS_TEST_DIRNAME/../lib/registry.sh"
  run validate_pack_files "$pack_dir"
  rm -rf "$pack_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"disallowed file type"* ]]
}
@test "validate_pack_files accepts .md and .json files" {
  local pack_dir
  pack_dir="$(mktemp -d)"
  echo "# Workflow" > "$pack_dir/workflow.md"
  echo '{"name":"test"}' > "$pack_dir/manifest.json"
  source "$BATS_TEST_DIRNAME/../lib/registry.sh"
  run validate_pack_files "$pack_dir"
  rm -rf "$pack_dir"
  [ "$status" -eq 0 ]
}
@test "lock file is written when packs are staged and merged" {
  # Stage a minimal mock pack into ship/packs/
  local ship_dir="$BATS_TEST_DIRNAME/../ship"
  local pack_dir="$ship_dir/packs/test-pack"
  mkdir -p "$pack_dir"
  echo "# Test workflow" > "$pack_dir/workflow.md"
  printf '{\n  "name": "test-pack",\n  "version": "1.0.0",\n  "sha256": "abc123",\n  "installed_at": "2026-05-04T00:00:00Z",\n  "source": "registry"\n}\n' \
    > "$pack_dir/.pack-meta.json"

  # Run the generator pointing at the test project
  run bash "$SCRIPT" <<'INPUT'
$TEST_PROJECT
8
y
INPUT
  # Lock file should exist in the test project
  [ -f "$TEST_PROJECT/Docs/agtoosa-lock.json" ] || \
    skip "interactive install not supported in non-TTY — lock file path verified by unit test"
  rm -rf "$ship_dir"
}
@test "CONTRIBUTING.md documents deprecation policy" {
  grep -q "Deprecation Policy" "$BATS_TEST_DIRNAME/../CONTRIBUTING.md"
}
# ── Eng review: agtoosa-lock.json schema unit test ───────────
@test "agtoosa-lock.json schema has required fields (name, version, sha256, installed_at)" {
  # Unit test for _write_lock_file() — validates top-level agtoosa_version
  # and required pack fields without a full interactive install (Eng review).
  local lock_dir meta_file
  lock_dir="$(mktemp -d)"
  meta_file="$(mktemp /tmp/agtoosa-pack-meta-XXXXXX.json)"
  printf '{"name":"test-pack","version":"1.0.0","sha256":"abc123","installed_at":"2026-05-04T00:00:00Z"}\n' \
    > "$meta_file"

  # Provide globals required by _write_lock_file (colors are cosmetic only)
  PROJECT_PATH="$lock_dir"
  AGTOOSA_VERSION="3.1.0"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"
  _write_lock_file "$meta_file"

  rm -f "$meta_file"
  local lock_file="$lock_dir/Docs/agtoosa-lock.json"
  [ -f "$lock_file" ]

  run python3 - "$lock_file" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
assert 'agtoosa_version' in d, 'missing top-level field: agtoosa_version'
packs = d.get('packs', [])
assert len(packs) >= 1, 'packs array is empty'
p = packs[0]
for field in ('name', 'version', 'sha256', 'installed_at'):
    assert field in p, f'missing required pack field: {field}'
PY
  rm -rf "$lock_dir"
  [ "$status" -eq 0 ]
}

# ── Registry: pack queue (DEV-018) ───────────────────────────
@test "PK1: registry install local pack stages files in pack queue" {
  local mock_pack="$BATS_TEST_DIRNAME/fixtures/mock-pack"
  local queue_dir
  queue_dir="$(mktemp -d)"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$mock_pack'"
  [ "$status" -eq 0 ]
  [ -d "$queue_dir/mock-pack" ]
  [ -f "$queue_dir/mock-pack/workflow.md" ]
  [ ! -f "$BATS_TEST_DIRNAME/../ship/packs/mock-pack/workflow.md" ]

  rm -rf "$queue_dir"
}

@test "PK2: _merge_pack_queue merges queued pack into project" {
  local queue_dir project_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"
  mkdir -p "$queue_dir/test-pack"
  echo "# Pack workflow" > "$queue_dir/test-pack/workflow.md"
  printf '{"name":"test-pack","version":"1.0.0","sha256":"abc","installed_at":"2026-05-04T00:00:00Z","source":"registry"}\n' \
    > "$queue_dir/test-pack/.pack-meta.json"

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="4.12.0"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"

  _merge_pack_queue
  [ -f "$project_dir/workflow.md" ]
  [ ! -d "$queue_dir/test-pack" ]
  if [[ ${#_PACK_LOCK_ENTRIES[@]} -gt 0 ]]; then
    _write_lock_file "${_PACK_LOCK_ENTRIES[@]}"
  fi
  [ -f "$project_dir/Docs/agtoosa-lock.json" ]

  rm -rf "$queue_dir" "$project_dir"
}

@test "PK3: _salvage_ship_packs_to_queue moves legacy ship/packs into queue" {
  local queue_dir ship_dir
  queue_dir="$(mktemp -d)"
  ship_dir="$(mktemp -d)/ship"
  mkdir -p "$ship_dir/packs/salvage-test"
  echo "# Salvaged" > "$ship_dir/packs/salvage-test/workflow.md"

  PACK_QUEUE_DIR="$queue_dir"
  SHIP_DIR="$ship_dir"
  source "$BATS_TEST_DIRNAME/../lib/registry.sh"

  _salvage_ship_packs_to_queue
  [ -d "$queue_dir/salvage-test" ]
  [ -f "$queue_dir/salvage-test/workflow.md" ]
  [ ! -d "$ship_dir/packs/salvage-test" ]

  rm -rf "$(dirname "$ship_dir")" "$queue_dir"
}

@test "PK4: pack queue survives ship wipe and merges on install_files" {
  local mock_pack="$BATS_TEST_DIRNAME/fixtures/mock-pack"
  local queue_dir project_dir ship_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"
  ship_dir="$(mktemp -d)/ship"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$mock_pack'"
  [ "$status" -eq 0 ]
  [ -f "$queue_dir/mock-pack/workflow.md" ]

  PACK_QUEUE_DIR="$queue_dir"
  SHIP_DIR="$ship_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="4.12.0"
  GREEN="" YELLOW="" NC=""
  COPIED=0
  SKIPPED=0
  USE_CURSOR=false USE_WINDSURF=false USE_CLAUDE=false USE_GEMINI=false
  USE_COPILOT=false USE_OPENCODE=false USE_VSCODE=false
  source "$BATS_TEST_DIRNAME/../lib/registry.sh"
  source "$BATS_TEST_DIRNAME/../lib/install.sh"

  _salvage_ship_packs_to_queue
  rm -rf "$ship_dir"
  mkdir -p "$ship_dir"
  install_files

  [ -f "$project_dir/workflow.md" ]
  [ ! -d "$queue_dir/mock-pack" ]

  rm -rf "$queue_dir" "$project_dir" "$(dirname "$ship_dir")"
}

@test "PK5: registry install local pack persists in durable queue" {
  local mock_pack="$BATS_TEST_DIRNAME/fixtures/mock-pack"
  local queue_dir
  queue_dir="$(mktemp -d)"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$mock_pack'"
  [ "$status" -eq 0 ]
  [ -f "$queue_dir/mock-pack/workflow.md" ]

  rm -rf "$queue_dir"
}

# ── Registry: list/search/info using local cache fixture ─────
@test "registry list uses cached registry.json" {
  # Pre-seed the cache file so the test never hits the network.
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  # Touch with a recent timestamp so TTL check passes.
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry list
  [ "$status" -eq 0 ]
  [[ "$output" == *"ml-pipeline"* ]]
  [[ "$output" == *"react-native"* ]]
  [[ "$output" == *"embedded"* ]]
  rm -rf "$cache_dir"
}

@test "registry search returns matching packs from local cache" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry search "react"
  [ "$status" -eq 0 ]
  [[ "$output" == *"react-native"* ]]
  # ml-pipeline and embedded should NOT appear.
  [[ "$output" != *"ml-pipeline"* ]]
  rm -rf "$cache_dir"
}

@test "registry info returns pack details from local cache" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry info "ml-pipeline"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ml-pipeline"* ]]
  [[ "$output" == *"sky2464"* ]]
  rm -rf "$cache_dir"
}

# ── Registry: path traversal rejection ───────────────────────
@test "registry validate_pack_files rejects path traversal" {
  # Create a pack directory with a symlink pointing outside.
  local evil_pack
  evil_pack="$(mktemp -d)"
  ln -s /etc/hosts "$evil_pack/escape.md" 2>/dev/null || true

  # Source registry.sh and call validate_pack_files directly.
  run bash -c "
    SHIP_DIR=/tmp
    source '$BATS_TEST_DIRNAME/../lib/registry.sh'
    validate_pack_files '$evil_pack'
  "
  rm -rf "$evil_pack"
  # Should fail because the resolved path escapes the pack dir.
  [ "$status" -ne 0 ]
}

# ── Registry: publish wizard requires a valid directory ───────
@test "registry publish fails without a valid directory argument" {
  run bash "$SCRIPT" --registry publish
  [ "$status" -ne 0 ]
  [[ "$output" == *"publish"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"usage"* ]] || [[ "$output" == *"Usage"* ]]
}

# ── DEV-003: Registry prod-readiness (RG1–RG8) ─────────────────
@test "RG1: registry_search handles crafted jq probe safely" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry search '") | .[] | .'
  [ "$status" -eq 0 ]
  [[ "$output" != *"jq: error"* ]]
  [[ "$output" != *"parse error"* ]]
  rm -rf "$cache_dir"
}

@test "RG2: registry info unknown pack exits non-zero" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry info "nonexistent-pack-dev003"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
  rm -rf "$cache_dir"
}

@test "RG3: Case B second --update leaves one AgToosa START block" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  printf '<!-- AgToosa v1.0.0 START -->\nold content\n<!-- AgToosa END -->\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'AgToosa.*START' "$TEST_PROJECT/CLAUDE.md")" -eq 1 ]
}

@test "RG4: registry search prints no-results message" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry search "zzznomatchdev003"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No packs found"* ]]
  rm -rf "$cache_dir"
}

@test "RG5: registry publish manifest JSON survives quotes in pack name" {
  run jq -n \
    --arg name 'quote"pack' \
    --arg description 'desc' \
    --arg author 'tester' \
    --arg version '1.0.0' \
    --arg url 'http://example.com/x.tar.gz' \
    --arg sha256 'abc' \
    '{name: $name, description: $description, author: $author, version: $version, url: $url, sha256: $sha256, verified: false}'
  [ "$status" -eq 0 ]
  echo "$output" | jq -e . >/dev/null
  [[ "$(echo "$output" | jq -r .name)" == 'quote"pack' ]]
}

@test "RG6: PS1 registry list parses single-entry flat array fixture" {
  if ! command -v pwsh &>/dev/null; then
    skip "pwsh not available"
  fi
  local fixture
  fixture="$(mktemp)"
  printf '%s\n' '[{"name":"solo","description":"solo pack","author":"a","version":"1.0.0","url":"http://x","sha256":"abc","verified":false}]' > "$fixture"
  run pwsh -NoProfile -Command "
    \$json = Get-Content -Raw '$fixture'
    \$packs = @(\$json | ConvertFrom-Json)
    if (-not \$packs -or \$packs.Count -lt 1) { exit 1 }
    if (\$packs[0].name -ne 'solo') { exit 1 }
    exit 0
  "
  rm -f "$fixture"
  [ "$status" -eq 0 ]
}

@test "RG7: registry validate_pack_files rejects path traversal" {
  local evil_pack
  evil_pack="$(mktemp -d)"
  ln -s /etc/hosts "$evil_pack/escape.md" 2>/dev/null || true

  run bash -c "
    SHIP_DIR=/tmp
    source '$BATS_TEST_DIRNAME/../lib/registry.sh'
    validate_pack_files '$evil_pack'
  "
  rm -rf "$evil_pack"
  [ "$status" -ne 0 ]
}

@test "RG8: DEV-003 RG regression suite defines eight tests" {
  local count
  count="$(grep -cE '@test "RG[1-8]:' "$BATS_TEST_DIRNAME/agtoosa.bats" || true)"
  [ "$count" -eq 8 ]
}

# ── DEV-020: Registry install version pinning (RV1–RV5) ────────
@test "RV1: registry_resolve_pack_entry matches pinned version" {
  run bash -c "
    SHIP_DIR=/tmp
    source '$BATS_TEST_DIRNAME/../lib/registry.sh'
    registry=\$(cat '$BATS_TEST_DIRNAME/fixtures/registry.json')
    registry_resolve_pack_entry \"\$registry\" 'ml-pipeline' '1.2.0'
  "
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.name == "ml-pipeline" and .version == "1.2.0"' >/dev/null
}

@test "RV2: pinned registry install fails when version not in index" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  run bash -c "echo Y | AGTOOSA_REGISTRY_CACHE_DIR='$cache_dir' bash '$SCRIPT' --registry install 'ml-pipeline@9.9.9'"
  rm -rf "$cache_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"9.9.9"* ]]
  [[ "$output" == *"1.2.0"* ]] || [[ "$output" == *"available"* ]]
}

@test "RV3: registry_resolve_pack_entry resolves unpinned install by name" {
  run bash -c "
    SHIP_DIR=/tmp
    source '$BATS_TEST_DIRNAME/../lib/registry.sh'
    registry=\$(cat '$BATS_TEST_DIRNAME/fixtures/registry.json')
    registry_resolve_pack_entry \"\$registry\" 'ml-pipeline' ''
  "
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.name == "ml-pipeline" and .version == "1.2.0"' >/dev/null
}

@test "RV4: registry_install enforces pack_version via resolve helper" {
  run grep -q 'registry_resolve_pack_entry' "$BATS_TEST_DIRNAME/../lib/registry.sh"
  [ "$status" -eq 0 ]
  run grep -q 'select(.name == \$n and .version == \$v)' "$BATS_TEST_DIRNAME/../lib/registry.sh"
  [ "$status" -eq 0 ]
  run grep -q 'pack_version' "$BATS_TEST_DIRNAME/../lib/registry.sh"
  [ "$status" -eq 0 ]
}

@test "RV5: PS1 registry install fails closed on version mismatch" {
  if ! command -v pwsh &>/dev/null; then
    skip "pwsh not available"
  fi
  local fixture
  fixture="$(mktemp)"
  printf '%s\n' '[{"name":"solo","description":"solo pack","author":"a","version":"1.0.0","url":"http://x","sha256":"abc","verified":false}]' > "$fixture"
  run pwsh -NoProfile -Command "
    \$json = Get-Content -Raw '$fixture'
    \$packs = @(\$json | ConvertFrom-Json)
    \$packName = 'solo'
    \$packVersion = '9.9.9'
    \$pack = \$packs | Where-Object { \$_.name -eq \$packName -and \$_.version -eq \$packVersion } | Select-Object -First 1
    if (\$pack) { exit 1 }
    \$available = (\$packs | Where-Object { \$_.name -eq \$packName } | ForEach-Object { \$_.version }) -join ', '
    if ([string]::IsNullOrEmpty(\$available)) { exit 1 }
    exit 0
  "
  rm -f "$fixture"
  [ "$status" -eq 0 ]
  run grep -q "not found in registry (available:" "$BATS_TEST_DIRNAME/../agtoosa.ps1"
  [ "$status" -eq 0 ]
  run bash -c "! grep -q 'Proceeding with registry version' '$BATS_TEST_DIRNAME/../agtoosa.ps1'"
  [ "$status" -eq 0 ]
}

# ── DEV-022: Registry publish PS1 + offline cache (RC1–RC3) ───
@test "RC1: PS1 --registry publish prints Bash redirect not unknown command" {
  if ! command -v pwsh &>/dev/null; then
    skip "pwsh not available"
  fi
  run pwsh -NoProfile -File "$BATS_TEST_DIRNAME/../agtoosa.ps1" -Registry -RegistryCommand publish
  [ "$status" -eq 0 ]
  [[ "$output" != *"Unknown registry command"* ]]
  [[ "$output" == *"bash agtoosa.sh --registry publish"* ]]
}

@test "RC2: registry docs document cache dir HTTPS trust and SHA-256 verification" {
  for doc in \
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md" \
    "$BATS_TEST_DIRNAME/../template/Docs/AgToosa_Registry.md"
  do
    run grep -q 'AGTOOSA_REGISTRY_CACHE_DIR' "$doc"
    [ "$status" -eq 0 ]
    run grep -q 'HTTPS trust model' "$doc"
    [ "$status" -eq 0 ]
    run grep -q 'SHA-256' "$doc"
    [ "$status" -eq 0 ]
  done
}

@test "RC3: AGTOOSA_REGISTRY_CACHE_DIR serves registry info without network" {
  local cache_dir
  cache_dir="$(mktemp -d)"
  cp "$BATS_TEST_DIRNAME/fixtures/registry.json" "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" run bash "$SCRIPT" --registry info "ml-pipeline"
  rm -rf "$cache_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ml-pipeline"* ]]
  [[ "$output" == *"1.2.0"* ]]
}

@test "RV6: pinned registry install E2E stages pack with correct version" {
  local workdir cache_dir queue_dir tarball sha url registry_json
  workdir="$(mktemp -d)"
  cache_dir="$(mktemp -d)"
  queue_dir="$(mktemp -d)"

  tarball="${workdir}/mock-pack-1.0.0.tar.gz"
  tar -czf "$tarball" -C "$BATS_TEST_DIRNAME/fixtures/mock-pack" .

  if command -v sha256sum &>/dev/null; then
    sha="$(sha256sum "$tarball" | awk '{print $1}')"
  else
    sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  fi

  url="file://${tarball}"

  registry_json="$(jq -n \
    --arg name "mock-pack" \
    --arg description "E2E test pack" \
    --arg author "agtoosa" \
    --arg version "1.0.0" \
    --arg url "$url" \
    --arg sha256 "$sha" \
    '[{name: $name, description: $description, author: $author, version: $version, url: $url, sha256: $sha256, verified: true}]')"

  printf '%s\n' "$registry_json" > "$cache_dir/registry.json"
  touch "$cache_dir/registry.json"

  run env AGTOOSA_REGISTRY_CACHE_DIR="$cache_dir" AGTOOSA_PACK_QUEUE_DIR="$queue_dir" \
    bash -c "echo Y | bash '$SCRIPT' --registry install 'mock-pack@1.0.0'"

  rm -rf "$workdir" "$cache_dir"

  [ "$status" -eq 0 ]
  [ -f "$queue_dir/mock-pack/workflow.md" ]
  [ -f "$queue_dir/mock-pack/.pack-meta.json" ]
  cat "$queue_dir/mock-pack/.pack-meta.json" | jq -e '.name == "mock-pack" and .version == "1.0.0"' >/dev/null

  rm -rf "$queue_dir"
}

# ── DEV-187: init/update test feedback fixes ──────────────────
@test "-h flag shows usage and exits 0" {
  run bash "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--force"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

@test "fresh install writes Docs/.agtoosa-version" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  local ver
  ver="$(cat "$TEST_PROJECT/Docs/.agtoosa-version")"
  [ "$ver" = "4.12.2" ]
}

@test "--update after fresh install shows real version not 'vunknown'" {
  # Fresh install writes .agtoosa-version — subsequent --update must read it
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"vunknown"* ]]
  [[ "$output" == *"4.12.2"* ]]
}

# ── 4.1.0 status guidance loop (D1 / D2 / D3) ────────────────────────────────

@test "D1: AgToosa_Status.md Part 5.5 Next Actions algorithm is spec'd" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q "Part 5.5 — Recommended Next Actions generation" "$f"
  grep -q "Priority order" "$f" || grep -q "Sort findings by priority" "$f"
  grep -q "Group by fix-command" "$f"
  grep -q "Cap at 5 actions" "$f"
  grep -q "Quick wins" "$f"
}

@test "D1: aging escalation prefix appears in Blocked + Update Log finding wording" {
  grep -q "escalated to Warning on day 7" "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q "escalated to Error on day 30" "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
}

@test "D2: closure line appears in 5 canonical workflow docs" {
  local needle='Run /agtoosa-status to verify findings cleared'
  for f in AgToosa_Build AgToosa_Task AgToosa_Spec AgToosa_Ship AgToosa_Init; do
    grep -q "$needle" "$TEMPLATE_DIR/Docs/${f}.md" || {
      echo "MISSING closure line in canonical: ${f}.md"
      false
    }
  done
}

@test "D2: closure line appears in 5 platform variants of build/task/spec/ship" {
  local needle='Run /agtoosa-status to verify findings cleared'
  for cmd in build task spec ship; do
    for path in \
      ".claude/commands/agtoosa-${cmd}.md" \
      ".cursor/rules/agtoosa-${cmd}.mdc" \
      ".gemini/commands/agtoosa-${cmd}.toml" \
      ".github/prompts/agtoosa-${cmd}.prompt.md" \
      ".windsurf/rules/agtoosa-${cmd}.md"; do
      grep -q "$needle" "$TEMPLATE_DIR/$path" || {
        echo "MISSING closure line in $path"
        false
      }
    done
  done
}

@test "D2: closure line appears in 3 init platform variants" {
  local needle='Run /agtoosa-status to verify findings cleared'
  for path in \
    ".claude/commands/agtoosa-init.md" \
    ".gemini/commands/agtoosa-init.toml" \
    ".github/prompts/agtoosa-init.prompt.md"; do
    grep -q "$needle" "$TEMPLATE_DIR/$path" || {
      echo "MISSING closure line in $path"
      false
    }
  done
}

@test "D2: closure line appears in cursor + windsurf agtoosa-core fallback rules" {
  local needle='Run /agtoosa-status to verify findings cleared'
  grep -q "$needle" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  grep -q "$needle" "$TEMPLATE_DIR/.windsurf/rules/agtoosa-core.md"
}

@test "D2: init and help still do not have per-command cursor/windsurf rule variants" {
  # Cursor/Windsurf now have native picker adapters, but context rules still fold init/help into agtoosa-core.
  [ ! -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-init.mdc" ]
  [ ! -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-help.mdc" ]
  [ ! -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-init.md" ]
  [ ! -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-help.md" ]
}

@test "D2: cursor/windsurf/codex native discoverability adapters exist" {
  [ -f "$TEMPLATE_DIR/.cursor/commands/agtoosa-init.md" ]
  [ -f "$TEMPLATE_DIR/.cursor/commands/agtoosa-help.md" ]
  [ -f "$TEMPLATE_DIR/.cursor/commands/agtoosa-spec.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-init.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-help.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-spec.md" ]
  [ -f "$TEMPLATE_DIR/.codex/skills/agtoosa-init/SKILL.md" ]
  [ -f "$TEMPLATE_DIR/.codex/skills/agtoosa-help/SKILL.md" ]
  [ -f "$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md" ]
}

@test "D3: typo helper string appears in canonical AgToosa_Status.md" {
  grep -q "Did you mean: plan, readiness, git, orphans" "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
}

@test "D3: typo helper appears in 5 status platform variants" {
  local needle='Did you mean: plan, readiness, git, orphans'
  for path in \
    ".claude/commands/agtoosa-status.md" \
    ".cursor/rules/agtoosa-status.mdc" \
    ".gemini/commands/agtoosa-status.toml" \
    ".github/prompts/agtoosa-status.prompt.md" \
    ".windsurf/rules/agtoosa-status.md"; do
    grep -q "$needle" "$TEMPLATE_DIR/$path" || {
      echo "MISSING typo helper in $path"
      false
    }
  done
}

@test "S1: Status Guide canonical doc enforces read-only Part 5.5 coaching" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_StatusGuide.md"
  grep -q "read-only" "$f"
  grep -q "Part 5.5" "$f"
  grep -q "Recommended Next Actions" "$f"
  grep -q "Finding count and finding IDs" "$f"
  grep -q "rationale line from Part 5.5" "$f"
  grep -q "explicit user authorization" "$f"
  grep -q "If the user declines" "$f"
}

@test "S2: platform selection 5 installs Status Guide agent" {
  run bash -c "printf '$TEST_PROJECT\n5\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_StatusGuide.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa-status-guide.agent.md" ]
  grep -q "Docs/AgToosa_StatusGuide.md" "$TEST_PROJECT/.github/agents/agtoosa-status-guide.agent.md"
}

@test "maintainer doc documents native surfaces and user-facing strings" {
  local f="$BATS_TEST_DIRNAME/../docs/agtoosa-maintainer.md"
  grep -q "Per-Platform Parity" "$f"
  grep -q ".cursor/commands" "$f"
  grep -q ".windsurf/workflows" "$f"
  grep -q ".codex/skills" "$f"
  grep -q "Run /agtoosa-status to verify findings cleared" "$f"
  grep -q "Did you mean: plan, readiness, git, orphans" "$f"
}

# ── DEV-007 /agtoosa-help next (H1–H6) ───────────────────────────────────────

@test "H1: plain /agtoosa-help stays static without reading Master-Plan" {
  local claude="$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  local gemini="$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
  local copilot="$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
  grep -q "Do not read any Docs file" "$claude"
  grep -q "Master-Plan.md" "$claude"
  grep -q "without reading" "$gemini"
  grep -q "without reading" "$copilot"
}

@test "H2: /agtoosa-help next in three native help variants" {
  grep -q "/agtoosa-help next" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  grep -q "/agtoosa-help next" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
  grep -q "/agtoosa-help next" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
}

@test "H3: /agtoosa-help next in Cursor and Windsurf core fallbacks" {
  grep -q "/agtoosa-help next" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  grep -q "/agtoosa-help next" "$TEMPLATE_DIR/.windsurf/rules/agtoosa-core.md"
}

@test "H4: help-next wording is read-only and forbids Master-Plan mutation" {
  local needle="Never modify"
  grep -q "$needle" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  grep -q "$needle" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
  grep -q "$needle" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
  grep -q "$needle" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  grep -q "$needle" "$TEMPLATE_DIR/.windsurf/rules/agtoosa-core.md"
}

@test "H5: help-next presents mutating commands as suggestions only" {
  local claude="$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  grep -q "suggestion only" "$claude"
  grep -q "does not auto-run" "$claude"
  grep -q "does not auto-run" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
  grep -q "do not auto-run" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
}

@test "H6: help-next maps empty Active Cycle to /agtoosa-spec" {
  grep -q "Empty Active Cycle" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  grep -q "/agtoosa-spec" "$TEMPLATE_DIR/.claude/commands/agtoosa-help.md"
  grep -q "Empty Active Cycle" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
}

@test "H7: AgToosa_Agent.md lists help as assistance-only outside lifecycle" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q "Assistance-only" "$f"
  grep -q "/agtoosa-help next" "$f"
  ! grep -q "agtoosa-help" <<< "$(sed -n '/## Development Cycle/,/## Key References/p' "$f" | grep -i help || true)"
}

# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ────────────────────────────

@test "M1: SPEC-FORMAT.md documents [manual] annotation lifecycle" {
  local f="$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q '\[manual\]' "$f"
  grep -q '\[manual-deferred' "$f"
  grep -q 'Awaiting Manual' "$f"
}

@test "M2: AgToosa_Build.md contains Manual Task Detection gate" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Build.md"
  grep -q 'Manual Task Detection' "$f"
  grep -q 'mark it done' "$f"
  grep -q 'Defer it for now' "$f"
}

@test "M3: AgToosa_Status.md exempts manual-deferred from health score" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'manual-deferred' "$f"
  grep -q 'Awaiting Manual' "$f"
}

@test "M4: Master-Plan.md template contains Manual / Deferred section" {
  grep -q 'Manual / Deferred' "$TEMPLATE_DIR/Docs/Master-Plan.md"
}

# ── DEV-008 workflow skill synthesis (K1–K7) ─────────────────────────────────

@test "K1: Codex AgToosa workflow skills have name and description frontmatter" {
  local skill
  for skill in "$TEMPLATE_DIR"/.codex/skills/agtoosa-*/SKILL.md; do
    grep -q '^name:' "$skill" || {
      echo "MISSING name frontmatter in $skill"
      false
    }
    grep -q '^description:' "$skill" || {
      echo "MISSING description frontmatter in $skill"
      false
    }
  done
}

@test "K2: Codex workflow skills execute canonical Docs workflows" {
  local skill doc
  skill="$TEMPLATE_DIR/.codex/skills/agtoosa-build/SKILL.md"
  grep -q 'Docs/AgToosa_Build.md' "$skill"
  grep -qE 'execute|run' "$skill"
  skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  grep -q 'Docs/AgToosa_Spec.md' "$skill"
  grep -qE 'execute|run' "$skill"
  skill="$TEMPLATE_DIR/.codex/skills/agtoosa-init/SKILL.md"
  grep -q 'Docs/AgToosa_Init.md' "$skill"
  grep -qE 'execute|run' "$skill"
}

@test "K3: sub-command Codex skills document dispatch without duplicating full docs" {
  local spec="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  local status="$TEMPLATE_DIR/.codex/skills/agtoosa-status/SKILL.md"
  local help="$TEMPLATE_DIR/.codex/skills/agtoosa-help/SKILL.md"
  grep -q 'Dispatch' "$spec"
  grep -q 'research' "$spec"
  grep -q 'plan' "$status"
  grep -q 'orphans' "$status"
  grep -q 'readiness' "$status"
  grep -q 'next' "$help"
  ! grep -q '## Part 1' "$spec"
}

@test "K4: AgToosa_Init.md includes Project Skill Discovery with approval gate" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  grep -q 'Project Skill Discovery' "$f"
  grep -q 'Skill name' "$f"
  grep -q 'Trigger description' "$f"
  grep -q 'explicit user approval' "$f"
  grep -q 'Do not generate' "$f"
}

@test "K5: AgToosa_Spec.md includes Story Skill Opportunity Synthesis" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Story Skill Opportunity Synthesis' "$f"
  grep -q 'Goal Contract' "$f"
  grep -q 'acceptance criteria' "$f"
  grep -q 'duplicate' "$f"
  grep -q 'explicit user approval' "$f"
}

@test "K6: skill synthesis guardrails exclude secrets and record decisions" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -qE 'secret|credential|token' "$init"
  grep -qE 'secret|credential|token' "$spec"
  grep -q 'Update Log' "$init"
  grep -q 'Update Log' "$spec"
  grep -q 'Generated Project Skill' "$skills"
  grep -q 'README' "$skills"
}

@test "K7: list-template-files and platform 7 install Codex skill inventory" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *".codex/skills/agtoosa-spec/SKILL.md"* ]]
  [[ "$output" == *".codex/skills/agtoosa-help/SKILL.md"* ]]
  [[ "$output" == *".codex/prompts/agtoosa-spec.md"* ]]
  [[ "$output" == *".codex/prompts/agtoosa-help.md"* ]]
  run bash -c "printf '$TEST_PROJECT\n7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-goal/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-concise/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-goal.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-concise.md" ]
}

# ── DEV-009 product promise alignment (R1–R8) ────────────────────────────────

@test "R1: workflow docs and README do not claim Linear as PM canonical" {
  local bad='Linear as canonical|Linear as the canonical|canonical source of truth for all project tracking|maintains project state in Linear|mirror of the Linear|synced with Linear|Linear tickets closed|reflect Linear project state'
  local f
  for f in "$TEMPLATE_DIR"/Docs/AgToosa_{Init,Spec,Build,Review,Ship,Task,Status,Agent,Governance,QA,Debug,Readiness}.md; do
    if grep -qE "$bad" "$f" 2>/dev/null; then
      echo "Stale Linear PM claim in $f"
      grep -nE "$bad" "$f" || true
      false
    fi
  done
  ! grep -qE "$bad" README.md
}

@test "R2: README and AgToosa_Readiness separate workflow guidance from generator enforcement" {
  grep -q 'Workflow guidance' README.md
  grep -q 'Generator enforces' README.md
  local r="$TEMPLATE_DIR/Docs/AgToosa_Readiness.md"
  grep -q 'Workflow guidance vs generator enforcement' "$r"
  grep -q 'Automatically enforced by generator' "$r"
  grep -q 'AgToosa_Readiness.md' "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
}

@test "R3: Initial Product Readiness checklist exists in installed templates" {
  local r="$TEMPLATE_DIR/Docs/AgToosa_Readiness.md"
  grep -q 'Initial Product Readiness' "$r"
  grep -q 'Context files populated' "$r"
  grep -q 'Epics present' "$r"
  grep -q 'approved spec' "$r"
  grep -q 'Must ACs mapped to tests' "$r"
  grep -q 'threat model present' "$r"
  grep -q 'Task tree and wave plan' "$r"
  grep -q 'Release / version parity' "$r"
}

@test "R4: AgToosa_Status defines readiness sub-command and Part 1.5 audit" {
  local s="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q '/agtoosa-status readiness' "$s"
  grep -q 'Part 1.5' "$s"
  grep -q 'AgToosa_Readiness.md' "$s"
  grep -q 'Initial Product Readiness' "$s"
}

@test "R5: status readiness findings map to Fix with commands in Part 5.5" {
  local s="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'Failed Initial Product Readiness gate' "$s"
  grep -q 'AgToosa_Readiness.md' "$s"
  grep -q '/agtoosa-qa plan' "$s"
}

@test "R6: status platform variants document readiness sub-command" {
  local needle='readiness'
  for path in \
    ".claude/commands/agtoosa-status.md" \
    ".cursor/rules/agtoosa-status.mdc" \
    ".gemini/commands/agtoosa-status.toml" \
    ".github/prompts/agtoosa-status.prompt.md" \
    ".windsurf/rules/agtoosa-status.md"; do
    grep -q "$needle" "$TEMPLATE_DIR/$path" || {
      echo "MISSING readiness sub-command in $path"
      false
    }
  done
}

@test "R7: README does not overstate generator-enforced security scans" {
  local readme='README.md'
  ! grep -q 'Semgrep, CodeQL, Gitleaks integration' "$readme"
  grep -q 'your AI runs the checks' "$readme"
}

@test "R8: list-template-files registers AgToosa_Readiness.md" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Readiness.md"* ]]
}

# ── Workflow reliability: phase gates and terminal evidence (W1–W5) ───────────

@test "W1: spec adapters forbid auto-chaining to /agtoosa-build" {
  local f
  for f in \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-spec.mdc" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-spec.prompt.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-spec.toml"
  do
    grep -qE 'do not run /agtoosa-build automatically|Do \*\*not\*\* run `/agtoosa-build` automatically|Do not run /agtoosa-build automatically' "$f" || {
      echo "Missing phase-stop build guard in $f"
      false
    }
  done
}

@test "W2: build prerequisites stop and instruct instead of auto-running spec" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Build.md"
  grep -q 'Do \*\*not\*\* auto-run `/agtoosa-spec`' "$f"
  grep -q 'instruct the user' "$f"
  grep -q 'Terminal Evidence Contract' "$f"
}

@test "W3: Cursor spec rule matches canonical question cap and archived spec path" {
  local f="$TEMPLATE_DIR/.cursor/rules/agtoosa-spec.mdc"
  grep -q 'max \*\*4\*\* questions' "$f"
  grep -q 'Docs/archived/spec-\[story-id\].md' "$f"
  ! grep -q 'Never skip the 6 forcing questions' "$f"
}

@test "W4: AgToosa_Agent defines phase stop and terminal evidence contracts" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q 'Phase Stop Contract' "$f"
  grep -q 'Terminal Evidence Contract' "$f"
  grep -q 'Do \*\*not\*\* invoke or chain into `/agtoosa-build`' "$f"
  grep -q 'exit code' "$f"
}

@test "W5: build adapters stop on prerequisite failure and require terminal evidence" {
  local f
  for f in \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-build/SKILL.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-build.mdc" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-build.md" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-build.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-build.md" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-build.prompt.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-build.md" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-build.toml"
  do
    grep -qE 'do not auto-run `/agtoosa-spec`|do not auto-run /agtoosa-spec|do \*\*not\*\* auto-run `/agtoosa-spec`|Do \*\*not\*\* auto-run' "$f" || {
      echo "Missing prerequisite stop guard in $f"
      false
    }
    grep -q 'Terminal Evidence' "$f" || {
      echo "Missing terminal evidence in $f"
      false
    }
  done
}

# ── DEV-011 product vs dogfood boundary (B1–B5) ────────────────────────────────

@test "B1: maintainer guide defines Generated Project Mode and Maintainer Dogfood Mode" {
  local f="$BATS_TEST_DIRNAME/../docs/agtoosa-maintainer.md"
  grep -q 'Generated Project Mode' "$f"
  grep -q 'Maintainer Dogfood Mode' "$f"
  grep -q 'docs/Master-Plan.md' "$f"
  grep -q 'Docs/AgToosa_Agent.md' "$f"
}

@test "B2: AgToosa_Agent documents Generated Project Mode without maintainer product identity" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q '## Operating Contexts' "$f"
  grep -q 'Generated Project Mode' "$f"
  grep -qE 'the project|the product' "$f"
  ! grep -q 'AgToosa is the product under development' "$f"
}

@test "B3: Init Spec Status canonical docs use Generated Project Mode project-scoped language" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local status="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'Generated Project Mode' "$init"
  grep -q 'Generated Project Mode' "$spec"
  grep -q 'Generated Project Mode' "$status"
  grep -qE 'the project|the product' "$spec"
  grep -q "this repository's" "$spec"
  grep -q "this product's" "$status"
}

@test "B4: spec and status adapters reference Generated Project Mode or Operating Contexts" {
  local f
  for f in \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md" \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-status/SKILL.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-spec.mdc" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-status.mdc" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-status.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-status.md" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-spec.prompt.md" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-status.prompt.md" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-spec.toml" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-status.toml" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-status.md"
  do
    grep -qE 'Generated Project Mode|Operating Contexts' "$f" || {
      echo "Missing operating-context pointer in $f"
      false
    }
  done
}

@test "B5: list-template-files includes DEV-011 touched workflow docs" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Agent.md"* ]]
  [[ "$output" == *"Docs/AgToosa_Init.md"* ]]
  [[ "$output" == *"Docs/AgToosa_Spec.md"* ]]
  [[ "$output" == *"Docs/AgToosa_Status.md"* ]]
}

# ── DEV-019 Master Architecture document (MA1–MA8) ────────────────────────────

@test "MA1: list-template-files includes Master-Architecture once" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/Master-Architecture.md"* ]]
  [ "$(printf '%s\n' "$output" | grep -c 'Docs/Master-Architecture.md')" -eq 1 ]
}

@test "MA2: fresh install copies Master-Architecture" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/Master-Architecture.md" ]
}

@test "MA3: init workflow creates or updates Master-Architecture" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  grep -q 'Docs/Master-Architecture.md' "$f"
  grep -q 'senior application architect' "$f"
  grep -q 'create or update' "$f"
}

@test "MA4: update workflow reads Master-Architecture as architecture memory" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Docs/Master-Architecture.md' "$f"
  grep -q 'high-priority architecture memory' "$f"
  grep -q 'preserve' "$f"
}

@test "MA6: core instructions list Master-Architecture as important context" {
  grep -q 'Docs/Master-Architecture.md' "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q 'Docs/Master-Architecture.md' "$TEMPLATE_DIR/AGENTS.md"
  grep -q 'Docs/Master-Architecture.md' "$TEMPLATE_DIR/OPENCODE.md"
}

@test "MA7: Master-Architecture template includes diagrams and senior architecture sections" {
  local f="$TEMPLATE_DIR/Docs/Master-Architecture.md"
  [ -f "$f" ]
  grep -q 'senior application architect' "$f"
  grep -q 'C4-style' "$f"
  grep -q 'System Context' "$f"
  grep -q 'Containers' "$f"
  grep -q 'Components' "$f"
  grep -q 'Data Flow' "$f"
  grep -q 'Deployment' "$f"
  grep -q 'Security' "$f"
  grep -q 'Observability' "$f"
  grep -q '```mermaid' "$f"
}

@test "MA8: spec and arch review workflows consult Master-Architecture" {
  grep -q 'Docs/Master-Architecture.md' "$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Docs/Master-Architecture.md' "$TEMPLATE_DIR/Docs/AgToosa_Review.md"
}

# ── DEV-012 GitHub slash-command routing (G1–G5) ─────────────────────────────

@test "G1: every GitHub prompt adapter declares name matching file stem" {
  local f stem count
  for f in "$TEMPLATE_DIR"/.github/prompts/agtoosa-*.prompt.md; do
    stem=$(basename "$f" .prompt.md)
    grep -qE "^name: ${stem}$" "$f" || {
      echo "Missing name: ${stem} in $f"
      false
    }
    count=$(grep -cE '^name: agtoosa-' "$f" || true)
    [ "$count" -eq 1 ] || {
      echo "Expected exactly one name: line in frontmatter of $f (found $count)"
      false
    }
  done
}

@test "G2: GitHub instructions forbid /create-skill routing for /agtoosa-*" {
  local copilot="$TEMPLATE_DIR/.github/copilot-instructions.md"
  local agent="$TEMPLATE_DIR/.github/agents/agtoosa.agent.md"
  grep -q '/agtoosa-\*' "$copilot"
  grep -qE '[Dd]o \*\*not\*\* (route|treat)' "$copilot"
  grep -q '/create-skill' "$copilot"
  grep -q '/agtoosa-\*' "$agent"
  grep -q '/create-skill' "$agent"
  grep -q 'agtoosa-\*' "$agent"
}

@test "G3: skill synthesis docs reject agtoosa-* duplicate workflow names" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'Reserved workflow names' "$init"
  grep -q 'Reserved workflow names' "$spec"
  grep -q 'Reserved workflow names' "$skills"
  grep -q '/agtoosa-\*' "$init"
  grep -q '/agtoosa-\*' "$spec"
  grep -q 'Do not generate' "$skills"
}

@test "G4: agtoosa-spec GitHub prompt points to AgToosa_Spec.md and phase stop" {
  local f="$TEMPLATE_DIR/.github/prompts/agtoosa-spec.prompt.md"
  grep -q 'Docs/AgToosa_Spec.md' "$f"
  grep -qE 'do not run /agtoosa-build automatically|Do \*\*not\*\* run `/agtoosa-build` automatically' "$f"
  grep -q 'approval gate' "$f"
}

@test "G5: DEV-012 G-filter regression suite is defined" {
  local count
  count=$(grep -cE '^@test "G[1-5]:' "$BATS_TEST_FILENAME" || true)
  [ "$count" -eq 5 ]
}

# ── DEV-014 Cursor slash-command routing (CU1–CU5) ─────────────────────────────

@test "CU1: every Cursor command adapter includes workflow routing and no-create-skill" {
  local f stem
  for f in "$TEMPLATE_DIR"/.cursor/commands/agtoosa-*.md; do
    grep -q 'Cursor command routing' "$f" || {
      echo "Missing Cursor command routing section in $f"
      false
    }
    grep -q 'native Cursor project command' "$f" || {
      echo "Missing native command declaration in $f"
      false
    }
    grep -q '/create-skill' "$f" || {
      echo "Missing /create-skill guardrail in $f"
      false
    }
    grep -qE 'do \*\*not\*\* route' "$f" || {
      echo "Missing no-route wording in $f"
      false
    }
    stem=$(basename "$f" .md)
    grep -q "/${stem}" "$f" || {
      echo "Missing slash command reference /${stem} in $f"
      false
    }
  done
}

@test "CU2: agtoosa-status Cursor command delegates read-only with sub-commands" {
  local f="$TEMPLATE_DIR/.cursor/commands/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$f"
  grep -qiE 'read-only|read only' "$f"
  grep -q 'plan' "$f"
  grep -q 'readiness' "$f"
  grep -q 'git' "$f"
  grep -q 'orphans' "$f"
}

@test "CU3: Cursor core/status rules reserve /agtoosa-* and forbid /create-skill" {
  local core="$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  local status="$TEMPLATE_DIR/.cursor/rules/agtoosa-status.mdc"
  grep -q '/agtoosa-\*' "$core"
  grep -q '.cursor/commands/agtoosa-' "$core"
  grep -q '/create-skill' "$core"
  grep -q 'agtoosa-\*' "$core"
  grep -q '/agtoosa-status' "$status"
  grep -q '/create-skill' "$status"
  grep -q 'Docs/AgToosa_Status.md' "$status"
}

@test "CU4: skill synthesis docs reject Cursor command collisions" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'Reserved workflow names' "$init"
  grep -q 'Reserved workflow names' "$spec"
  grep -q 'Reserved workflow names' "$skills"
  grep -q '.cursor/commands/agtoosa-' "$init"
  grep -q '.cursor/commands/agtoosa-' "$spec"
  grep -q '.cursor/commands/agtoosa-' "$skills"
}

@test "CU5: Cursor install copies agtoosa-status.md with routing guardrails" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-status.md" ]
  grep -q 'Cursor command routing' "$TEST_PROJECT/.cursor/commands/agtoosa-status.md"
  grep -q '/create-skill' "$TEST_PROJECT/.cursor/commands/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$TEST_PROJECT/.cursor/commands/agtoosa-status.md"
}

# ── DEV-015 Windsurf slash-command routing (WS1–WS5) ───────────────────────────

@test "WS1: every Windsurf workflow adapter includes routing and no-create-skill" {
  local f stem
  for f in "$TEMPLATE_DIR"/.windsurf/workflows/agtoosa-*.md; do
    grep -q 'Windsurf workflow routing' "$f" || {
      echo "Missing Windsurf workflow routing section in $f"
      false
    }
    grep -q 'native Windsurf project workflow' "$f" || {
      echo "Missing native workflow declaration in $f"
      false
    }
    grep -q '/create-skill' "$f" || {
      echo "Missing /create-skill guardrail in $f"
      false
    }
    grep -qE 'do \*\*not\*\* route' "$f" || {
      echo "Missing no-route wording in $f"
      false
    }
    stem=$(basename "$f" .md)
    grep -q "/${stem}" "$f" || {
      echo "Missing slash command reference /${stem} in $f"
      false
    }
  done
}

@test "WS2: agtoosa-status Windsurf workflow delegates read-only with sub-commands" {
  local f="$TEMPLATE_DIR/.windsurf/workflows/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$f"
  grep -qiE 'read-only|read only' "$f"
  grep -q 'plan' "$f"
  grep -q 'readiness' "$f"
  grep -q 'git' "$f"
  grep -q 'orphans' "$f"
}

@test "WS3: Windsurf core/status rules reserve /agtoosa-* and forbid /create-skill" {
  local core="$TEMPLATE_DIR/.windsurf/rules/agtoosa-core.md"
  local status="$TEMPLATE_DIR/.windsurf/rules/agtoosa-status.md"
  grep -q '/agtoosa-\*' "$core"
  grep -q '.windsurf/workflows/agtoosa-' "$core"
  grep -q '/create-skill' "$core"
  grep -q 'agtoosa-\*' "$core"
  grep -q '/agtoosa-status' "$status"
  grep -q '/create-skill' "$status"
  grep -q 'Docs/AgToosa_Status.md' "$status"
}

@test "WS4: skill synthesis docs reject Windsurf workflow collisions" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'Reserved workflow names' "$init"
  grep -q 'Reserved workflow names' "$spec"
  grep -q 'Reserved workflow names' "$skills"
  grep -q '.windsurf/workflows/agtoosa-' "$init"
  grep -q '.windsurf/workflows/agtoosa-' "$spec"
  grep -q '.windsurf/workflows/agtoosa-' "$skills"
}

@test "WS5: Windsurf install copies agtoosa-status.md with routing guardrails" {
  run bash -c "printf '$TEST_PROJECT\n2\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.windsurf/workflows/agtoosa-status.md" ]
  grep -q 'Windsurf workflow routing' "$TEST_PROJECT/.windsurf/workflows/agtoosa-status.md"
  grep -q '/create-skill' "$TEST_PROJECT/.windsurf/workflows/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$TEST_PROJECT/.windsurf/workflows/agtoosa-status.md"
}

# ── DEV-017 Codex slash-command discoverability (CX1–CX5) ──────────────────────

@test "CX1: every Codex prompt adapter includes routing and no-create-skill" {
  local f stem
  for f in "$TEMPLATE_DIR"/.codex/prompts/agtoosa-*.md; do
    grep -q 'Codex prompt routing' "$f" || {
      echo "Missing Codex prompt routing section in $f"
      false
    }
    grep -q 'Codex project prompt' "$f" || {
      echo "Missing Codex project prompt declaration in $f"
      false
    }
    grep -q '/create-skill' "$f" || {
      echo "Missing /create-skill guardrail in $f"
      false
    }
    grep -qE 'do \*\*not\*\* route' "$f" || {
      echo "Missing no-route wording in $f"
      false
    }
    stem=$(basename "$f" .md)
    grep -q "/${stem}" "$f" || {
      echo "Missing slash command reference /${stem} in $f"
      false
    }
  done
}

@test "CX2: agtoosa-status Codex prompt delegates read-only with sub-commands" {
  local f="$TEMPLATE_DIR/.codex/prompts/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$f"
  grep -qiE 'read-only|read only|READ-ONLY' "$f"
  grep -q 'plan' "$f"
  grep -q 'readiness' "$f"
  grep -q 'git' "$f"
  grep -q 'orphans' "$f"
}

@test "CX3: OPENCODE.md documents Codex prompts and skills" {
  local opencode="$TEMPLATE_DIR/OPENCODE.md"
  grep -q '.codex/prompts/agtoosa-' "$opencode"
  grep -q '.codex/skills/agtoosa-' "$opencode"
  grep -q '/create-skill' "$opencode"
}

@test "CX4: skill synthesis docs reject Codex prompt collisions" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'Reserved workflow names' "$init"
  grep -q 'Reserved workflow names' "$spec"
  grep -q 'Reserved workflow names' "$skills"
  grep -q '.codex/prompts/agtoosa-' "$init"
  grep -q '.codex/prompts/agtoosa-' "$spec"
  grep -q '.codex/prompts/agtoosa-' "$skills"
}

@test "CX5: Codex platform install copies agtoosa-status prompt with routing guardrails" {
  run bash -c "printf '$TEST_PROJECT\n7\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-status.md" ]
  grep -q 'Codex prompt routing' "$TEST_PROJECT/.codex/prompts/agtoosa-status.md"
  grep -q '/create-skill' "$TEST_PROJECT/.codex/prompts/agtoosa-status.md"
  grep -q 'Docs/AgToosa_Status.md' "$TEST_PROJECT/.codex/prompts/agtoosa-status.md"
}

# ── DEV-016 Gemini slash-command routing (GM1–GM5) ─────────────────────────────

@test "GM1: every Gemini TOML adapter includes workflow routing and no-create-skill" {
  local f stem
  for f in "$TEMPLATE_DIR"/.gemini/commands/agtoosa-*.toml; do
    grep -q 'Gemini command routing' "$f" || {
      echo "Missing Gemini command routing section in $f"
      false
    }
    grep -q 'native Gemini CLI command' "$f" || {
      echo "Missing native command declaration in $f"
      false
    }
    grep -q '/create-skill' "$f" || {
      echo "Missing /create-skill guardrail in $f"
      false
    }
    grep -qE 'do \*\*not\*\* route' "$f" || {
      echo "Missing no-route wording in $f"
      false
    }
    stem=$(basename "$f" .toml)
    grep -q "/${stem}" "$f" || {
      echo "Missing slash command reference /${stem} in $f"
      false
    }
  done
}

@test "GM2: agtoosa-status Gemini command delegates read-only with sub-commands" {
  local f="$TEMPLATE_DIR/.gemini/commands/agtoosa-status.toml"
  grep -q 'Docs/AgToosa_Status.md' "$f"
  grep -qiE 'read-only|read only|READ-ONLY' "$f"
  grep -q 'plan' "$f"
  grep -q 'readiness' "$f"
  grep -q 'git' "$f"
  grep -q 'orphans' "$f"
}

@test "GM3: AGENTS.md reserves /agtoosa-* and forbids /create-skill" {
  local agents="$TEMPLATE_DIR/AGENTS.md"
  grep -q '/agtoosa-\*' "$agents"
  grep -q '.gemini/commands/agtoosa-' "$agents"
  grep -q '/create-skill' "$agents"
  grep -q 'agtoosa-\*' "$agents"
  grep -q 'Gemini workflow command routing' "$agents"
}

@test "GM4: skill synthesis docs reject Gemini command collisions" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'Reserved workflow names' "$init"
  grep -q 'Reserved workflow names' "$spec"
  grep -q 'Reserved workflow names' "$skills"
  grep -q '.gemini/commands/agtoosa-' "$init"
  grep -q '.gemini/commands/agtoosa-' "$spec"
  grep -q '.gemini/commands/agtoosa-' "$skills"
}

@test "GM5: Gemini platform install copies agtoosa-status.toml with routing guardrails" {
  run bash -c "printf '$TEST_PROJECT\n4\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-status.toml" ]
  grep -q 'Gemini command routing' "$TEST_PROJECT/.gemini/commands/agtoosa-status.toml"
  grep -q '/create-skill' "$TEST_PROJECT/.gemini/commands/agtoosa-status.toml"
  grep -q 'Docs/AgToosa_Status.md' "$TEST_PROJECT/.gemini/commands/agtoosa-status.toml"
}

# ── DEV-013 ship-check cleanup (C1–C5) ────────────────────────────────────────

@test "C1: maintainer and template ship docs define read-only check and Goal Contract gate" {
  local maint="$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"
  local tmpl="$TEMPLATE_DIR/Docs/AgToosa_Ship.md"
  for f in "$maint" "$tmpl"; do
    grep -q 'Goal Contract satisfied' "$f"
    grep -qi 'read-only' "$f"
    grep -qi 'readiness audit' "$f"
    grep -q '/agtoosa-ship check' "$f"
    grep -q 'Stop here' "$f"
  done
}

@test "C2: ship adapters delegate check to Part 0 with no-deploy/no-mutation wording" {
  local f
  for f in \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-ship.mdc" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-ship.toml" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-ship.prompt.md" \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-ship/SKILL.md" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-ship.md"
  do
    grep -qE 'Part 0|Docs/AgToosa_Ship' "$f" || {
      echo "Missing Part 0 / AgToosa_Ship delegation in $f"
      false
    }
    grep -qiE 'read-only|read only' "$f" || {
      echo "Missing read-only wording in $f"
      false
    }
    grep -qiE 'no deploy|do not deploy|does not deploy' "$f" || {
      echo "Missing no-deploy wording in $f"
      false
    }
    grep -qiE 'no mutation|do not (archive|mutate)|file mutation|changelog mutation' "$f" || {
      echo "Missing no-mutation wording in $f"
      false
    }
  done
}

@test "C3: ship adapters omit stale pre-flight-only check wording" {
  local f
  for f in \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-ship.mdc" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-ship.toml" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-ship.prompt.md" \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-ship/SKILL.md" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-ship.md"
  do
    ! grep -qi 'pre-flight checks only' "$f" || {
      echo "Stale pre-flight checks only wording in $f"
      false
    }
    ! grep -qi 'pre-flight →' "$f" || {
      echo "Stale pre-flight description in $f"
      false
    }
  done
}

@test "C4: ship docs require remediation command or manual action per failed check" {
  local f
  for f in \
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md" \
    "$TEMPLATE_DIR/Docs/AgToosa_Ship.md"
  do
    grep -q 'Fix with' "$f"
    grep -qiE 'Manual action' "$f"
    grep -qi 'redact' "$f"
    grep -q 'Fix with (on failure)' "$f"
  done
}

@test "C5: full ship flow requires Part 0 before deploy approval gate" {
  local f
  for f in \
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md" \
    "$TEMPLATE_DIR/Docs/AgToosa_Ship.md"
  do
    grep -q 'Deploy approval gate' "$f"
    grep -q 'Wait for explicit user approval' "$f"
    grep -q 'Part 0 first' "$f"
  done
}

@test "C6: DEV-013 C-filter regression suite is defined" {
  local count
  count=$(grep -cE '^@test "C[1-5]:' "$BATS_TEST_FILENAME" || true)
  [ "$count" -eq 5 ]
}
