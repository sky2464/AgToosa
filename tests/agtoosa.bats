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
  [[ "$output" == "AgToosa v5.3.0" ]]
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
# ── Platform coverage ────────────────────────────────
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
# ── Generator: inject_version ────────────────────────────
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
# ── Generator: extract_version ───────────────────────────
@test "extract_version: same-version reinstall with --force keeps customizations" {
  # Install first
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Reinstall with --force — same version should be kept (extract_version detects it)
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  [[ "$output" == *"keeping your customizations"* ]]
}
# ── Generator: version_lt ────────────────────────────────
@test "version_lt: older version triggers update with --force" {
  mkdir -p "$TEST_PROJECT"
  # Create a file with an older version marker (shell-style comment for .cursorrules)
  printf '# AgToosa v1.0.0\n# old content\n' > "$TEST_PROJECT/.cursorrules"
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT' --force"
  [ "$status" -eq 0 ]
  # Output should indicate upgrade happened
  [[ "$output" == *"v1.0.0 →"* ]]
}
# ── Generator: backup_file ───────────────────────────────
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
# ── Generator: copy_platform_file (new file) ─────────────
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
# ── Generator: copy_platform_file (force + backup) ───────
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
# ── CLI validation: unknown flag ─────────────────────────────────────
@test "unknown flag exits 1 with error message" {
  run bash "$SCRIPT" --foo
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
  [[ "$output" == *"Usage:"* ]]
}
# ── CLI validation: non-existent path ────────────────────────────────
@test "non-existent project path exits with error" {
  run bash -c "printf '/tmp/agtoosa-nonexistent-99999\n' | bash '$SCRIPT'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}
# ── CLI validation: self-targeting block ─────────────────────────────
@test "self-targeting AgToosa source directory is blocked" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash -c "printf '$src_dir\n' | bash '$SCRIPT'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Target path cannot be the AgToosa source directory"* ]]
}

@test "self-targeting interactive install includes maintainer guidance" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash -c "printf '$src_dir\n' | bash '$SCRIPT'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"agtoosa-maintainer.md"* ]]
  [[ "$output" == *"downstream"* ]]
  [[ "$output" == *"Do not create Docs/"* ]]
}
# ── CLI validation: invalid selection warning ───────────────────────
@test "invalid selection number shows warning but continues" {
  # '9' is out of range → warning; then no valid platform → no-platform prompt → default N → exit 0
  run bash -c "printf '$TEST_PROJECT\n9\n\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Unknown selection"* ]]
}
# ── CLI validation: empty platform selection ────────────────────────
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
# ── CLI validation: multi-platform combo ────────────────────────────
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
# ── Generator: merge_platform_file Case B (older version) ──────
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
# ── Generator: merge_platform_file Case C (old-format, no START/END) ──
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
# ── Generator: merge_platform_file Case D + --force ────────────
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
# ── Generator: --dry-run --force combined ──────────────────────
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
# ── Generator: --dry-run messages for existing platform files ──
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
# ── Generator: Context/ stubs preserved on re-run ──────────────
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
# ── Generator: .gitignore warning absent when no backups ────────
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
# ── Generator: merge_settings_json invalid JSON fallback ───────
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
# ── Generator: manual copy instructions ────────────────────────
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

@test "--update on AgToosa source directory includes maintainer guidance" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash "$SCRIPT" --update "$src_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"agtoosa-maintainer.md"* ]]
  [[ "$output" == *"downstream"* ]]
  [[ "$output" == *"Do not create Docs/"* ]]
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
@test "agtoosa-update check mode remains read-only while reporting goal gaps" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q '/agtoosa-update check' "$f"
  grep -q 'read-only' "$f"
  grep -q 'no shell commands' "$f"
  grep -q 'Goal clarity gaps' "$f"
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
  run python3 - "$project_dir/Docs/agtoosa-lock.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
packs = d.get('packs', [])
assert len(packs) == 1, f'expected 1 pack entry, got {len(packs)}'
assert packs[0]['name'] == 'test-pack', packs[0]
PY
  [ "$status" -eq 0 ]

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

# ── Install version marker (v3.1.1 regression) ──────────────────
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
  [ "$ver" = "5.3.0" ]
}

@test "--update after fresh install shows real version not 'vunknown'" {
  # Fresh install writes .agtoosa-version — subsequent --update must read it
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"vunknown"* ]]
  [[ "$output" == *"5.3.0"* ]]
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

@test "R2: README and AgToosa_Readiness separate workflow guidance from enforcement" {
  grep -q 'Workflow guidance' README.md
  grep -q 'Generator enforces' README.md
  local r="$TEMPLATE_DIR/Docs/AgToosa_Readiness.md"
  grep -q 'Workflow guidance vs enforcement' "$r"
  grep -q 'Machine-checked' "$r"
  grep -q 'agtoosa-verify.sh' "$r"
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

@test "W3: Cursor spec rule matches canonical plan-mode interview and archived spec path" {
  local f="$TEMPLATE_DIR/.cursor/rules/agtoosa-spec.mdc"
  grep -q 'Plan-Mode Spec Interview Contract' "$f"
  grep -q 'adaptive cap \*\*8\*\*' "$f"
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

# ── DEV-023: Workflow Template Native Slash Parity Audit (WP1–WP5) ─────────────

@test "WP1: config inventory paths exist on disk for all six native surfaces" {
  # shellcheck source=/dev/null
  source "$BATS_TEST_DIRNAME/../lib/config.sh"
  local rel
  for rel in "${CLAUDE_COMMAND_FILES[@]}" \
    "${CURSOR_COMMAND_FILES[@]}" \
    "${GEMINI_COMMAND_FILES[@]}" \
    "${COPILOT_PROMPT_FILES[@]}" \
    "${WINDSURF_WORKFLOW_FILES[@]}" \
    "${CODEX_PROMPT_FILES[@]}"; do
    [ -f "$TEMPLATE_DIR/$rel" ] || {
      echo "Missing template file for inventory path: $rel"
      false
    }
  done
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  for rel in "${CLAUDE_COMMAND_FILES[@]}" \
    "${CURSOR_COMMAND_FILES[@]}" \
    "${GEMINI_COMMAND_FILES[@]}" \
    "${COPILOT_PROMPT_FILES[@]}" \
    "${WINDSURF_WORKFLOW_FILES[@]}" \
    "${CODEX_PROMPT_FILES[@]}"; do
    [[ "$output" == *"$rel"* ]] || {
      echo "list-template-files missing: $rel"
      false
    }
  done
}

@test "WP2: each native surface has exactly 14 agtoosa workflow adapters" {
  [ "$(find "$TEMPLATE_DIR/.claude/commands" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
  [ "$(find "$TEMPLATE_DIR/.cursor/commands" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
  [ "$(find "$TEMPLATE_DIR/.gemini/commands" -maxdepth 1 -name 'agtoosa-*.toml' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
  [ "$(find "$TEMPLATE_DIR/.github/prompts" -maxdepth 1 -name 'agtoosa-*.prompt.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
  [ "$(find "$TEMPLATE_DIR/.windsurf/workflows" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
  [ "$(find "$TEMPLATE_DIR/.codex/prompts" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 14 ]
}

@test "WP3: ship adapters on all six surfaces delegate check to Part 0 read-only audit" {
  local f
  for f in \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-ship.toml" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-ship.prompt.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-ship.md" \
    "$TEMPLATE_DIR/.codex/prompts/agtoosa-ship.md"
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

@test "WP4: skill synthesis docs list collision guardrails for all six native surfaces" {
  local doc
  for doc in \
    "$TEMPLATE_DIR/Docs/AgToosa_Init.md" \
    "$TEMPLATE_DIR/Docs/AgToosa_Spec.md" \
    "$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  do
    grep -q 'Reserved workflow names' "$doc"
    grep -q '.claude/commands/agtoosa-' "$doc"
    grep -q '.cursor/commands/agtoosa-' "$doc"
    grep -q '.gemini/commands/agtoosa-' "$doc"
    grep -q '.github/prompts/agtoosa-' "$doc"
    grep -q '.windsurf/workflows/agtoosa-' "$doc"
    grep -q '.codex/prompts/agtoosa-' "$doc"
    grep -q '/create-skill' "$doc" || grep -q 'agtoosa-\*' "$doc"
  done
}

@test "WP5: OPENCODE.md documents Codex prompts and reserves /agtoosa-* from /create-skill" {
  local f="$TEMPLATE_DIR/OPENCODE.md"
  grep -q '.codex/prompts/agtoosa-' "$f"
  grep -q '.codex/skills/agtoosa-' "$f"
  grep -q '/agtoosa-\*' "$f"
  grep -q '/create-skill' "$f"
  grep -q 'do \*\*not\*\* route' "$f"
}

# ── DEV-024 maintainer status/readiness doc parity (MD1–MD5) ───────────────────

@test "MD1: maintainer AgToosa_Status defines readiness sub-command and Part 1.5" {
  local s="$BATS_TEST_DIRNAME/../docs/AgToosa_Status.md"
  grep -q '/agtoosa-status readiness' "$s"
  grep -q 'Part 1.5' "$s"
  grep -q 'docs/AgToosa_Readiness.md' "$s"
  grep -q 'Initial Product Readiness' "$s"
  grep -q 'initial readiness' "$s"
}

@test "MD2: maintainer AgToosa_Readiness exists with seven gates and generator version parity" {
  local r="$BATS_TEST_DIRNAME/../docs/AgToosa_Readiness.md"
  [ -f "$r" ]
  grep -q 'Initial Product Readiness' "$r"
  grep -q 'Context files populated' "$r"
  grep -q 'AGTOOSA_VERSION' "$r"
  grep -q 'CHANGELOG.md' "$r"
  grep -q 'Maintainer Dogfood' "$r"
}

@test "MD3: maintainer status doc uses Maintainer Dogfood Mode not Generated Project Mode only" {
  local s="$BATS_TEST_DIRNAME/../docs/AgToosa_Status.md"
  grep -q 'Maintainer Dogfood Mode' "$s"
  grep -q 'agtoosa-maintainer.md' "$s"
  ! grep -q 'Generated Project Mode' "$s" || {
    echo "docs/AgToosa_Status.md must not use Generated Project Mode-only callout"
    false
  }
}

@test "MD4: maintainer status Part 5.5 maps readiness failures and matches template gates" {
  local maint="$BATS_TEST_DIRNAME/../docs/AgToosa_Status.md"
  local tmpl="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'Failed Initial Product Readiness gate' "$maint"
  grep -q '/agtoosa-qa plan' "$maint"
  grep -q 'Did you mean: plan, readiness, git, orphans' "$maint"
  grep -q '−5 per failed Initial Product Readiness gate' "$maint"
  grep -q 'Context files populated' "$maint"
  grep -q 'Context files populated' "$tmpl"
}

@test "MD5: maintainer readiness gate 7 references generator version sources" {
  local r="$BATS_TEST_DIRNAME/../docs/AgToosa_Readiness.md"
  grep -q 'agtoosa.sh' "$r"
  grep -q 'agtoosa.ps1' "$r"
  grep -q 'AGTOOSA_VERSION' "$r"
}

# ── DEV-025 maintainer docs path normalization (PN1–PN5) ───────────────────────

@test "PN1: maintainer guide documents Generated Docs vs Maintainer docs path conventions" {
  local f="$BATS_TEST_DIRNAME/../docs/agtoosa-maintainer.md"
  grep -q 'Path conventions' "$f"
  grep -q 'Maintainer Dogfood Mode' "$f"
  grep -q '`docs/`' "$f"
  grep -q '`Docs/`' "$f"
  grep -q 'template/Docs/' "$f"
}

@test "PN2: maintainer core workflow mirrors use docs/ not Docs/ for Master-Plan" {
  local files=(
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Agent.md"
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Build.md"
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Init.md"
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Spec.md"
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"
    "$BATS_TEST_DIRNAME/../docs/AgToosa_Status.md"
  )
  local f
  for f in "${files[@]}"; do
    ! grep -q 'Docs/Master-Plan.md' "$f"
    grep -q 'docs/Master-Plan.md' "$f"
  done
}

@test "PN3: maintainer AgToosa_Status uses docs/ paths throughout" {
  local s="$BATS_TEST_DIRNAME/../docs/AgToosa_Status.md"
  ! grep -q 'Docs/' "$s"
  grep -q 'docs/Master-Plan.md' "$s"
  grep -q 'docs/archived/spec-' "$s"
}

@test "PN4: maintainer AgToosa_Skills cites template/Docs for generated Codex workflows" {
  local sk="$BATS_TEST_DIRNAME/../docs/AgToosa_Skills.md"
  grep -q 'template/Docs/AgToosa_' "$sk"
  grep -q 'Maintainer Dogfood Mode' "$sk"
  ! grep -q 'Docs/Master-Plan.md' "$sk"
}

@test "PN5: template pack still uses Docs/ canonical paths (regression)" {
  local t="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  [ -f "$t" ]
  grep -q 'Docs/Master-Plan.md' "$t"
  # Canonical template path must remain capital-D Docs (not rewritten to docs/)
  [[ "$t" == *'/Docs/'* ]]
}

# ── DEV-026 Codex agent mode spec execution (CS1–CS5) ─────────────────────────

@test "CS1: Codex spec skill and prompt require agent-mode execution contract terms" {
  local skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  local prompt="$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md"
  local f term
  for f in "$skill" "$prompt"; do
    grep -q 'Agent Mode Execution Contract' "$f" || {
      echo "Missing Agent Mode Execution Contract in $f"
      false
    }
    for term in 'Plan-Mode Spec Interview' 'research' 'Goal Contract' 'task planning' 'test plan' 'approval gate'; do
      grep -qi "$term" "$f" || {
        echo "Missing execution contract term '$term' in $f"
        false
      }
    done
    grep -qiE 'do not skip|Do \*\*not\*\* skip|forbidden' "$f" || {
      echo "Missing forbidden-skip guard in $f"
      false
    }
  done
}

@test "CS2: Codex spec skill and prompt preserve sub-command dispatch" {
  local skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  local prompt="$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md"
  local f sub
  for f in "$skill" "$prompt"; do
    for sub in research plan quick tasks to-issues; do
      grep -q "$sub" "$f" || {
        echo "Missing sub-command dispatch for '$sub' in $f"
        false
      }
    done
  done
}

@test "CS3: Codex spec adapter keeps Docs/AgToosa_Spec.md canonical without Part duplication" {
  local skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  local prompt="$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md"
  local f
  for f in "$skill" "$prompt"; do
    grep -q 'Docs/AgToosa_Spec.md' "$f" || {
      echo "Missing canonical Docs/AgToosa_Spec.md reference in $f"
      false
    }
    if grep -q '^## Part 1' "$f" || grep -q '^## Part 2' "$f"; then
      echo "Duplicated canonical Part 1/2 workflow section header in $f"
      false
    fi
  done
}

@test "CS4: DEV-026 contract forbids shallow dispatcher skips for full flow" {
  local skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  grep -qiE 'routing summary|shallow dispatcher|not a routing' "$skill" || {
    echo "Missing shallow-dispatcher guard in skill"
    false
  }
  grep -q 'Parts 1' "$skill"
  grep -qi 'STRIDE\|threat model\|architecture' "$skill"
}

@test "CS5: Codex spec prompt included in W1 phase-stop build guard" {
  local f="$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md"
  grep -qE 'do not run /agtoosa-build automatically|Do \*\*not\*\* run `/agtoosa-build` automatically|Do not run /agtoosa-build automatically' "$f" || {
    echo "Missing phase-stop build guard in $f"
    false
  }
}

# ── DEV-027 Agentic /agtoosa-update (T-001–T-009) ─────────────────────────────

@test "T-001: canonical update workflow defines Detect Plan Apply Verify and ask-then-apply" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Detect' "$f"
  grep -q 'Plan' "$f"
  grep -q 'Apply' "$f"
  grep -q 'Verify' "$f"
  grep -q 'ask-then-apply' "$f"
}

@test "T-002: canonical update workflow documents CLI update and planned changes" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'agtoosa.sh --update' "$f"
  grep -q 'overwrites' "$f"
  grep -q 'smart merge' "$f"
  grep -q 'native dir' "$f"
  grep -q 'preserved files' "$f"
  grep -q 'backup' "$f"
}

@test "T-003: canonical update workflow requires explicit approval before Apply" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -qiE 'explicit approval|approval gate' "$f"
  grep -q 'before running any mutating' "$f"
}

@test "T-004: canonical update verification covers marker lock platform preserve duplicate" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q '.agtoosa-version' "$f"
  grep -q 'lock' "$f"
  grep -q 'platform' "$f"
  grep -q 'preserved' "$f"
  grep -q 'duplicate marker' "$f"
}

@test "T-005: agtoosa-update check sub-command is read-only briefing only" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q '/agtoosa-update check' "$f"
  grep -q 'read-only' "$f"
  grep -q 'no shell commands' "$f"
  grep -q 'no mutation' "$f"
}

@test "T-006: agtoosa-update plan apply verify sub-command stop conditions documented" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q '/agtoosa-update plan' "$f"
  grep -q '/agtoosa-update apply' "$f"
  grep -q '/agtoosa-update verify' "$f"
  grep -q 'stop condition' "$f"
}

@test "T-007: update adapters share Detect Plan Apply Verify and forbid default pure read-only" {
  local f
  for f in \
    "$TEMPLATE_DIR/Docs/AgToosa_Update.md" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-update.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-update.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-update.mdc" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-update.toml" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-update.prompt.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-update.md" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-update.md" \
    "$TEMPLATE_DIR/.codex/prompts/agtoosa-update.md" \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-update/SKILL.md"; do
    grep -q 'Detect' "$f" || { echo "Missing Detect in $f"; false; }
    grep -q 'Plan' "$f" || { echo "Missing Plan in $f"; false; }
    grep -q 'Apply' "$f" || { echo "Missing Apply in $f"; false; }
    grep -q 'Verify' "$f" || { echo "Missing Verify in $f"; false; }
    if grep -q 'pure read command' "$f"; then
      echo "Forbidden pure read-only default in $f"
      false
    fi
  done
}

@test "T-008: update preflight covers git markers backups Docs lock platform drift migration" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'dirty git' "$f"
  grep -q 'malformed' "$f"
  grep -q 'backup' "$f"
  grep -q 'missing `Docs/`' "$f"
  grep -q 'lock-file' "$f"
  grep -q 'platform drift' "$f"
  grep -q 'major-version migration' "$f"
  grep -q 'dry-run' "$f"
}

@test "T-009: update migration guidance surfaces breaking changes before Apply" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'major-version' "$f"
  grep -q 'breaking change' "$f"
  grep -q 'changelog' "$f"
  grep -q 'before Apply' "$f"
}

# ── DEV-030 /agtoosa-update self-target uncertainty (T-001–T-011) ─────────────

@test "DEV-030 T-001: canonical update requires operating context before drift Apply" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Stage 1a' "$f"
  grep -q 'Operating context' "$f"
  grep -q 'before' "$f"
  grep -q 'Apply' "$f"
}

@test "DEV-030 T-002: canonical update classifies Maintainer Dogfood via maintainer guide and generator surfaces" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Maintainer Dogfood' "$f"
  grep -q 'agtoosa-maintainer.md' "$f"
  grep -q 'agtoosa.sh' "$f"
  grep -q 'template/' "$f"
}

@test "DEV-030 T-003: Maintainer Dogfood stops before Apply and forbids downstream path prompt" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Stop before Apply' "$f"
  grep -q 'downstream project path' "$f"
}

@test "DEV-030 T-004: Maintainer report states CLI update unavailable and lists next actions" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'CLI baseline update' "$f"
  grep -q 'Not available' "$f"
  grep -q '/agtoosa-status' "$f"
  grep -q '/agtoosa-spec' "$f"
}

@test "DEV-030 T-005: Generated Project retains DEV-027 Detect Plan Apply Verify flow" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Generated Project' "$f"
  grep -q 'Stage 1b' "$f"
  grep -q 'Detect' "$f"
  grep -q 'ask-then-apply' "$f"
}

@test "DEV-030 T-006: maintainer mirror documents operating context with docs paths" {
  local f="$BATS_TEST_DIRNAME/../docs/AgToosa_Update.md"
  grep -q 'Stage 1a' "$f"
  grep -q 'docs/agtoosa-maintainer.md' "$f"
  grep -q 'Maintainer Dogfood' "$f"
}

@test "DEV-030 T-007: PowerShell self-target messages include maintainer guidance" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q 'Write-SelfTargetGuidance' "$f"
  grep -q 'agtoosa-maintainer.md' "$f"
  grep -q 'Do not create Docs/' "$f"
}

@test "DEV-030 T-008: update adapters route to canonical AgToosa_Update without overriding dogfood stop" {
  local f
  for f in \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-update.md" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-update.md" \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-update/SKILL.md"; do
    grep -q 'AgToosa_Update.md' "$f" || { echo "Missing AgToosa_Update.md route in $f"; false; }
    if grep -q 'hand-edit workflow files' "$f"; then
      echo "Forbidden hand-edit override in $f"
      false
    fi
  done
}

@test "DEV-030 T-009: maintainer AgToosa_Update.md mirrors operating-context stop" {
  local f="$BATS_TEST_DIRNAME/../docs/AgToosa_Update.md"
  grep -q 'Stop before Apply' "$f"
  grep -q 'docs/Master-Plan.md' "$f"
}

@test "DEV-030 T-010: bash self-target helper documents maintainer guidance strings" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.sh"
  grep -q '_print_self_target_guidance' "$f"
  grep -q 'agtoosa-maintainer.md' "$f"
}

@test "DEV-030 T-011: DEV-030 section registered in bats file" {
  grep -q 'DEV-030' "$BATS_TEST_DIRNAME/agtoosa.bats"
}

# ── DEV-028 Plan-mode spec interview (DEV-028 T-001–T-010) ───────────────────

@test "DEV-028 T-001: canonical spec workflow contains Plan-Mode Spec Interview Contract" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q '## Plan-Mode Spec Interview Contract' "$f"
  grep -q 'Plan-Mode Spec Interview' "$f"
}

@test "DEV-028 T-002: contract requires research before user questions" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Research first' "$f"
  grep -q 'Docs/Master-Plan.md' "$f"
  grep -q 'scan the codebase' "$f"
}

@test "DEV-028 T-003: contract requires one question at a time and contextual options" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'One question at a time' "$f"
  grep -q '2–3 concrete options' "$f"
  grep -q 'recommended' "$f"
  grep -q 'free-text override' "$f"
}

@test "DEV-028 T-004: contract requires inferable answers as findings not re-asked" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q "Infer, don't re-ask" "$f"
  grep -q 'state it as a \*\*finding\*\*' "$f"
}

@test "DEV-028 T-005: full flow adaptive cap 8 and quick cap 2" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'at most \*\*8 core interview questions\*\*' "$f"
  grep -q 'at most \*\*2\*\* questions' "$f"
  grep -q '/agtoosa-spec quick' "$f"
}

@test "DEV-028 T-006: budget exhaustion continue or proceed with assumptions gate" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Interview budget reached (8 questions)' "$f"
  grep -q 'Continue the interview' "$f"
  grep -q 'Proceed with documented assumptions' "$f"
}

@test "DEV-028 T-007: decision-complete checklist covers required fields" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Decision-complete checklist' "$f"
  for term in 'Goal Contract' 'Non-goals' 'Acceptance criteria' 'Scope boundary' 'Affected surfaces' 'Risk / failure modes' 'Security / trust boundaries' 'Test evidence' 'Rollout / compatibility' 'Unresolved assumptions'; do
    grep -q "$term" "$f" || {
      echo "Missing decision-complete field: $term"
      false
    }
  done
}

@test "DEV-028 T-008: native spec adapters reference plan-mode contract without Part duplication" {
  local f
  for f in \
    "$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md" \
    "$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.cursor/rules/agtoosa-spec.mdc" \
    "$TEMPLATE_DIR/.cursor/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.windsurf/rules/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.claude/commands/agtoosa-spec.md" \
    "$TEMPLATE_DIR/.github/prompts/agtoosa-spec.prompt.md" \
    "$TEMPLATE_DIR/.gemini/commands/agtoosa-spec.toml"
  do
    grep -q 'Plan-Mode Spec Interview' "$f" || {
      echo "Missing Plan-Mode Spec Interview reference in $f"
      false
    }
    grep -q 'Docs/AgToosa_Spec.md' "$f" || {
      echo "Missing canonical Docs/AgToosa_Spec.md reference in $f"
      false
    }
    if grep -q '^## Part 1' "$f" || grep -q '^## Part 2' "$f"; then
      echo "Duplicated canonical Part 1/2 workflow section header in $f"
      false
    fi
  done
}

@test "DEV-028 T-009: spec adapters preserve phase stop and forbid auto-build" {
  run bats "$BATS_TEST_DIRNAME/agtoosa.bats" -f "W1: spec adapters forbid"
  [ "$status" -eq 0 ]
}

@test "DEV-028 T-010: maintainer spec mirror contains plan-mode contract" {
  local f="$BATS_TEST_DIRNAME/../docs/AgToosa_Spec.md"
  grep -q '## Plan-Mode Spec Interview Contract' "$f"
  grep -q 'at most \*\*8 core interview questions\*\*' "$f"
}

# ── DEV-029 branch-protection push-safe workflow (DEV-029 T-001–T-005) ────────

@test "DEV-029 T-001: branch-protection workflow display name is PR Hygiene Checks" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/branch-protection.yml"
  grep -q '^name: PR Hygiene Checks' "$f"
}

@test "DEV-029 T-002: branch-protection triggers pull_request and push on main" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/branch-protection.yml"
  grep -q 'pull_request:' "$f"
  grep -q 'push:' "$f"
  grep -q 'branches: \[main\]' "$f"
}

@test "DEV-029 T-003: push-main-ok runs only on push events" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/branch-protection.yml"
  grep -q 'push-main-ok:' "$f"
  awk '/^  push-main-ok:/{found=1} found && /^  [a-z]/ && !/^  push-main-ok:/{exit} found && /if: github.event_name == .push./{ok=1; exit} END{exit !ok}' "$f"
}

@test "DEV-029 T-004: PR hygiene jobs run only on pull_request events" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/branch-protection.yml"
  for job in require-labels require-description link-issue all-checks-pass; do
    awk -v job="$job" '
      $0 ~ "^  " job ":" { found=1 }
      found && /^  [a-zA-Z0-9_-]+:/ && $0 !~ "^  " job ":" { exit }
      found && /if: github.event_name == .pull_request./ { ok=1; exit }
      END { exit !ok }
    ' "$f" || {
      echo "Missing pull_request guard on job: $job"
      false
    }
  done
}

@test "DEV-029 T-005: require-labels still fails when PR has no labels" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/branch-protection.yml"
  grep -q 'Check PR has at least one label' "$f"
  grep -q 'pull_request.labels' "$f"
  grep -q 'label_count' "$f"
  grep -q 'PR must have at least one label' "$f"
}

# ── DEV-031 project-specific specialist subagents (T-001–T-015) ─────────────

@test "DEV-031 T-001: AgToosa_Specialists.md in DOCS_FILES and template" {
  grep -q 'Docs/AgToosa_Specialists.md' "$BATS_TEST_DIRNAME/../lib/config.sh"
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Specialists.md" ]
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Specialists.md"* ]]
}

@test "DEV-031 T-002: canonical specialists doc defines contract fields" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Specialists.md"
  grep -q 'phase_hooks' "$f"
  grep -q 'tools/MCP' "$f"
  grep -q 'custom_mode' "$f"
  grep -q 'safety_notes' "$f"
  grep -q 'Structured Evidence Block' "$f"
  grep -q '.github/agents/' "$f"
  grep -q '.claude/skills/' "$f"
  grep -q 'sequential' "$f"
}

@test "DEV-031 T-003: AgToosa_Init.md includes Project Specialist Discovery with approval" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  grep -q 'Project Specialist Discovery' "$f"
  grep -q 'AgToosa_Specialists.md' "$f"
  grep -q 'specialists.md' "$f"
  grep -q 'explicit user approval' "$f"
  grep -q 'platform_targets' "$f"
}

@test "DEV-031 T-004: specialist guardrails reject agtoosa-* and secrets" {
  local init="$TEMPLATE_DIR/Docs/AgToosa_Init.md"
  local spec="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  local specialists="$TEMPLATE_DIR/Docs/AgToosa_Specialists.md"
  grep -qE 'agtoosa-\*|/agtoosa-\*' "$specialists"
  grep -qE 'secret|credential|token' "$specialists"
  grep -q 'agtoosa-\*' "$init"
  grep -qE 'secret|credential|token' "$init"
  grep -q 'Spec Specialist Orchestration' "$spec"
}

@test "DEV-031 T-005: specialists doc lists platform native targets" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Specialists.md"
  grep -q '.codex/skills/' "$f"
  grep -q '.cursor/rules/' "$f"
  grep -q '.windsurf/workflows/' "$f"
  grep -q '.gemini/commands/' "$f"
}

@test "DEV-031 T-006: DOCS_FILES does not ship project specialists roster" {
  local cfg="$BATS_TEST_DIRNAME/../lib/config.sh"
  grep -q 'Docs/AgToosa_Specialists.md' "$cfg"
  ! grep -q 'Context/specialists.md' "$cfg"
  ! grep -qE 'specialist.*SKILL' "$cfg"
}

@test "DEV-031 T-007: AgToosa_Update.md post-Verify specialist proposal separate from CLI" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Specialist Compatibility Check' "$f"
  grep -q 'Stage 4b' "$f"
  grep -q 'separate' "$f"
  grep -q 'Never touched' "$f"
  grep -q 'specialists.md' "$f"
}

@test "DEV-031 T-008: AgToosa_Update check and plan include read-only specialist check" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Update.md"
  grep -q 'Specialist Compatibility Check' "$f"
  grep -q '`check`' "$f"
  grep -q '`plan`' "$f"
  grep -q 'read-only' "$f"
}

@test "DEV-031 T-009: AgToosa_Spec.md orchestrates spec-phase specialists" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Spec Specialist Orchestration' "$f"
  grep -q 'specialists.md' "$f"
  grep -q 'phase_hooks' "$f"
  grep -q 'trigger' "$f"
}

@test "DEV-031 T-010: AgToosa_Spec.md requires structured evidence block" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Findings:' "$f"
  grep -q 'Files read:' "$f"
  grep -q 'Spec sections affected' "$f"
}

@test "DEV-031 T-011: AgToosa_Spec.md documents parallel and sequential fallback" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'parallel' "$f"
  grep -q 'Sequential fallback' "$f"
}

@test "DEV-031 T-012: AgToosa_Spec.md merges specialist evidence into spec sections" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Spec.md"
  grep -q 'Goal Contract' "$f"
  grep -q 'STRIDE' "$f"
  grep -q 'test plan skeleton' "$f"
}

@test "DEV-031 T-013: template does not ship default specialists roster" {
  [ ! -f "$TEMPLATE_DIR/Docs/Context/specialists.md" ]
  ! find "$TEMPLATE_DIR" -path '*/.github/agents/*-specialist*.agent.md' 2>/dev/null | grep -q .
  ! find "$TEMPLATE_DIR/.codex/skills" -mindepth 1 -maxdepth 1 -type d ! -name 'agtoosa-*' 2>/dev/null | grep -q .
}

@test "DEV-031 T-014: workflow adapters route to canonical specialists doc" {
  local init_skill="$TEMPLATE_DIR/.codex/skills/agtoosa-init/SKILL.md"
  local update_skill="$TEMPLATE_DIR/.codex/skills/agtoosa-update/SKILL.md"
  local spec_skill="$TEMPLATE_DIR/.codex/skills/agtoosa-spec/SKILL.md"
  grep -q 'AgToosa_Init.md' "$init_skill"
  grep -q 'AgToosa_Specialists.md' "$init_skill"
  grep -q 'AgToosa_Update.md' "$update_skill"
  grep -q 'Specialist Compatibility' "$update_skill"
  grep -q 'AgToosa_Spec.md' "$spec_skill"
  grep -q 'AgToosa_Specialists.md' "$spec_skill"
  grep -q '/agtoosa-spec' "$TEMPLATE_DIR/.codex/prompts/agtoosa-spec.md"
  ! grep -q '## Part 1' "$spec_skill"
}

@test "DEV-031 T-015: AgToosa_Agent and AgToosa_Skills document specialist lifecycle" {
  local agent="$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  local skills="$TEMPLATE_DIR/Docs/AgToosa_Skills.md"
  grep -q 'AgToosa_Specialists.md' "$agent"
  grep -q 'structured evidence block' "$agent"
  grep -q 'Project Specialists' "$skills"
  grep -q 'never overwrites' "$skills"
}

# ── DEV-032 Patch-first release versioning (DEV-032 VP-001–VP-005) ───────────

@test "DEV-032 VP-001: maintainer release checklist patch-first default" {
  local f="$BATS_TEST_DIRNAME/../docs/agtoosa-maintainer.md"
  grep -q 'Bump decision tree (patch-first' "$f"
  grep -q 'PATCH\*\* (default)' "$f"
  grep -q 'ADR-005-release-cadence' "$f"
}

@test "DEV-032 VP-002: template ship workflow version bump section" {
  local f="$BATS_TEST_DIRNAME/../template/Docs/AgToosa_Ship.md"
  grep -q 'Version bump (maintainer dogfood)' "$f"
  grep -q 'patch-first' "$f"
  grep -q 'PATCH+1' "$f"
}

@test "DEV-032 VP-003: maintainer ship mirror version bump section" {
  local f="$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"
  grep -q 'Version bump (maintainer dogfood)' "$f"
  grep -q 'ADR-005-release-cadence' "$f"
}

@test "DEV-032 VP-004: review workflow PATCH-first ship suggestion" {
  local f="$BATS_TEST_DIRNAME/../template/Docs/AgToosa_Review.md"
  grep -q 'Ship version suggestion' "$f"
  grep -q 'PATCH+1' "$f"
}

@test "DEV-032 VP-005: ADR-005 patch-first release cadence" {
  local f="$BATS_TEST_DIRNAME/../docs/adr/ADR-005-release-cadence.md"
  grep -q 'patch-first' "$f"
  grep -q 'Default to PATCH' "$f"
  grep -q 'ADR-004' "$f"
}

# ── DEV-033 PowerShell approved verbs (DEV-033 PV-001–PV-003) ────────────────

@test "DEV-033 PV-001: agtoosa.ps1 defines approved-verb helper names" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q '^function Copy-StageFiles' "$f"
  grep -q '^function Initialize-PackQueueDir' "$f"
  grep -q '^function Move-ShipPacksToQueue' "$f"
}

@test "DEV-033 PV-002: agtoosa.ps1 no longer references legacy helper names" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  ! grep -Eq '\b(Stage-Files|Ensure-PackQueueDir|Salvage-ShipPacksToQueue)\b' "$f"
}

@test "DEV-033 PV-003: PowerShell install smoke exercises renamed staging helpers" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  rm -rf "$BATS_TEST_DIRNAME/../ship"
  run bash -c "printf '$TEST_PROJECT\n\nY\nY\n' | pwsh -NoProfile -File '$BATS_TEST_DIRNAME/../agtoosa.ps1'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
}

# ── Maintainer review fixes: install parity + release workflow drift ─────────

@test "MR1: Bash Claude install copies configured hook script" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/settings.json" ]
  [ -f "$TEST_PROJECT/.claude/hooks/block-dangerous-git.sh" ]
  [ -x "$TEST_PROJECT/.claude/hooks/block-dangerous-git.sh" ]
  grep -q 'block-dangerous-git.sh' "$TEST_PROJECT/.claude/settings.json"
}

@test "MR2: PowerShell all-platform install mirrors native Bash inventory" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  run bash -c "printf '$TEST_PROJECT\n8\nY\n' | pwsh -NoProfile -File '$BATS_TEST_DIRNAME/../agtoosa.ps1'"
  [ "$status" -eq 0 ]

  [ -f "$TEST_PROJECT/Docs/AgToosa_Status.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_StatusGuide.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Readiness.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Debug.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Concise.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Specialists.md" ]
  [ -f "$TEST_PROJECT/Docs/SPEC-FORMAT.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Governance.md" ]
  [ -f "$TEST_PROJECT/Docs/Context/tech-stack.md" ]

  [ -f "$TEST_PROJECT/.claude/settings.json" ]
  [ -f "$TEST_PROJECT/.claude/hooks/block-dangerous-git.sh" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-status.md" ]
  [ -f "$TEST_PROJECT/.cursor/commands/agtoosa-status.md" ]
  [ -f "$TEST_PROJECT/.windsurf/workflows/agtoosa-status.md" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-status.toml" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-status.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa-status-guide.agent.md" ]
  [ -f "$TEST_PROJECT/.codex/skills/agtoosa-status/SKILL.md" ]
  [ -f "$TEST_PROJECT/.codex/prompts/agtoosa-status.md" ]
}

@test "MR3: PowerShell fresh install does not write lock file without packs" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/empty-pack-queue' pwsh -NoProfile -File '$BATS_TEST_DIRNAME/../agtoosa.ps1'"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/Docs/agtoosa-lock.json" ]
}

@test "MR4: advanced release accepts README pinned snippets and creates next patch milestone" {
  local f="$BATS_TEST_DIRNAME/../.github/workflows/release-advanced.yml"
  ! grep -q 'README contains a hardcoded bootstrap tag' "$f"
  grep -q 'patch + 1' "$f"
  ! grep -q 'i === 1 ? parseInt(v) + 1' "$f"
}

@test "MR5: Homebrew formula version tracks AGTOOSA_VERSION without placeholder sha" {
  local formula="$BATS_TEST_DIRNAME/../Formula/agtoosa.rb"
  local bash_ver formula_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  formula_ver="$(grep -m1 '^  version ' "$formula" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

  [ "$formula_ver" = "$bash_ver" ]
  ! grep -q 'PLACEHOLDER_SHA256' "$formula"
  grep -Eq 'sha256 "[0-9a-f]{64}"|url "https://github.com/sky2464/AgToosa.git", branch: "main"' "$formula"
}

@test "MR6: PowerShell install deep-merges settings.json hooks (parity with bash)" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q '^function Merge-SettingsJson' "$f"
  grep -q 'Merge-SettingsJson.*settings\.json' "$f"
  ! grep -q 'Copy-FileWithGuard.*settings\.json' "$f"
}

# ── DEV-034 Maintainer release-state reconciliation (LR-001–LR-006) ─────────

@test "DEV-034 LR-001: Master-Plan active cycle excludes shipped stories" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  local active
  active="$(awk '/^## Active Cycle/{flag=1; next} /^## Active Tasks/{flag=0} flag' "$mp")"

  ! echo "$active" | grep -q 'DEV-034'
  ! echo "$active" | grep -q 'DEV-030'
  ! echo "$active" | grep -q 'DEV-033'
  ! echo "$active" | grep -q 'DEV-031'
  ! echo "$active" | grep -q 'DEV-032'
}

@test "DEV-034 LR-002: DEV-033 shipped disposition is explicit" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'DEV-033.*🏁 Shipped' "$mp"
  grep -q 'DEV-033.*agtoosa.ps1 PSScriptAnalyzer approved verbs.*2026-06-05' "$mp"
  [ -f "$BATS_TEST_DIRNAME/../docs/archived/spec-DEV-033.md" ]
  [ -f "$BATS_TEST_DIRNAME/../docs/archived/review-DEV-033.md" ]
  [ -f "$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-033.md" ]
}

@test "DEV-034 LR-003: release version pins remain aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver readme_badge readme_ref formula_ver bats_pin
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  readme_badge="$(grep -m1 'badge/version-' "$root/README.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  readme_ref="$(grep -m1 -E -- '--ref v[0-9]' "$root/README.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  formula_ver="$(grep -m1 '^  version ' "$root/Formula/agtoosa.rb" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  bats_pin="$(grep -m1 'AgToosa v' "$root/tests/agtoosa.bats" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

  [ "$ps_ver" = "$bash_ver" ]
  [ "$readme_badge" = "$bash_ver" ]
  [ "$readme_ref" = "$bash_ver" ]
  [ "$formula_ver" = "$bash_ver" ]
  [ "$bats_pin" = "$bash_ver" ]
}

@test "DEV-034 LR-004: changelog release block and Unreleased match ship state" {
  local changelog="$BATS_TEST_DIRNAME/../CHANGELOG.md"
  local mirror="$BATS_TEST_DIRNAME/../docs/AgToosa_Changelog.md"
  grep -q '## \[5.2.5\]' "$changelog"
  grep -q 'DEV-034.*Maintainer release-state reconciliation' "$changelog"
  grep -q '## \[5.2.4\]' "$changelog"
  grep -q 'DEV-030.*self-target uncertainty' "$changelog"
  grep -q 'DEV-033.*approved PowerShell verbs' "$changelog"
  grep -q '## \[5.2.5\]' "$mirror"
  grep -q 'DEV-034.*Maintainer release-state reconciliation' "$mirror"
  grep -q '## \[5.2.4\]' "$mirror"
  ! awk '/^## \[Unreleased\]/{u=1; next} /^## \[/ && u{exit} u' "$changelog" | grep -q 'DEV-034'
}

@test "DEV-034 LR-005: DEV-029 PR-path manual verification completion recorded" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q '27050231744' "$mp"
  ! grep -q 'DEV-029 | 4 |' "$mp"
}

@test "DEV-034 LR-006: DEV-034 test plan maps all LR checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-034.md"
  grep -q 'LR-001' "$tp"
  grep -q 'LR-002' "$tp"
  grep -q 'LR-003' "$tp"
  grep -q 'LR-004' "$tp"
  grep -q 'LR-005' "$tp"
  grep -q 'LR-006' "$tp"
}

# -- DEV-035 Launch P0 publication and quickstart gate (LG-001-LG-006) --------

@test "DEV-035 LG-001: README labels public launch commands truthfully" {
  local readme="$BATS_TEST_DIRNAME/../README.md"

  ! grep -q "Private staging status" "$readme"
  grep -q "Public launch: pinned release" "$readme"
  grep -q "development-only main branch" "$readme"

  local pinned_line main_line
  pinned_line="$(grep -n "Public launch: pinned release" "$readme" | head -n1 | cut -d: -f1)"
  main_line="$(grep -n "development-only main branch" "$readme" | head -n1 | cut -d: -f1)"
  [[ -n "$pinned_line" ]]
  [[ -n "$main_line" ]]
  [[ "$pinned_line" -lt "$main_line" ]]
}

@test "DEV-035 LG-002: launch readiness checker exposes private and public modes" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"

  [[ -x "$checker" ]]
  grep -q -- "--mode private" "$checker"
  grep -q -- "--mode public" "$checker"
  grep -q "AGTOOSA_LAUNCH_MODE" "$checker"
}

@test "DEV-035 LG-003: private launch readiness mode passes without public URL access" {
  run bash "$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh" --mode private
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode: private"* ]]
  [[ "$output" == *"Skipping anonymous public URL checks"* ]]
}

@test "DEV-035 LG-004: public launch mode checks all advertised public surfaces" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"

  grep -q "https://github.com/sky2464/AgToosa" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/releases" "$checker"
  grep -q "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh" "$checker"
  local script_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q "https://raw.githubusercontent.com/sky2464/AgToosa/v${script_ver}/bootstrap.sh" "$checker"
  grep -q "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/issues" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/discussions" "$checker"
  grep -q "https://github.com/sky2464/homebrew-agtoosa" "$checker"
  grep -q "https://github.com/sky2464/agtoosa-first-15-proof" "$checker"
}

@test "DEV-035 LG-005: support templates collect actionable launch support details" {
  local bug="$BATS_TEST_DIRNAME/../.github/ISSUE_TEMPLATE/bug.yml"
  local feature="$BATS_TEST_DIRNAME/../.github/ISSUE_TEMPLATE/feature.yml"
  local support="$BATS_TEST_DIRNAME/../.github/SUPPORT.md"

  grep -q "Operating system" "$bug"
  grep -q "Shell" "$bug"
  grep -q "Install command" "$bug"
  grep -q "Target project context" "$bug"
  grep -q "Affected surface" "$feature"
  grep -q "public support channel" "$support"
}

@test "DEV-035 LG-006: test plan maps all launch gate checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-035.md"

  grep -q "LG-001" "$tp"
  grep -q "LG-002" "$tp"
  grep -q "LG-003" "$tp"
  grep -q "LG-004" "$tp"
  grep -q "LG-005" "$tp"
  grep -q "LG-006" "$tp"
}

# -- DEV-036 Windows and registry parity (WP-001-WP-005) ---------------------

@test "DEV-036 WP-001: PowerShell update detects platforms and updates version marker" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  local project="$TEST_PROJECT/ps-update-parity"
  mkdir -p "$project/Docs" "$project/.claude/commands"
  echo "5.0.0" > "$project/Docs/.agtoosa-version"
  printf 'User notes\n\n<!-- AgToosa v5.0.0 START -->\nold claude block\n<!-- AgToosa END -->\n' > "$project/CLAUDE.md"
  printf 'old command\n' > "$project/.claude/commands/agtoosa-spec.md"

  run pwsh -NoProfile -File "$BATS_TEST_DIRNAME/../agtoosa.ps1" -Update -UpdatePath "$project"
  [ "$status" -eq 0 ]
  grep -q '^User notes' "$project/CLAUDE.md"
  grep -q "Claude Code Instructions" "$project/CLAUDE.md"
  ! grep -q "old claude block" "$project/CLAUDE.md"
  grep -q "AgToosa" "$project/.claude/commands/agtoosa-spec.md"
  [ "$(cat "$project/Docs/.agtoosa-version")" = "5.3.0" ]
}

@test "DEV-036 WP-002: Bash registry install normalizes top-level pack directory" {
  local registry="$TEST_PROJECT/registry.json"
  local packroot="$TEST_PROJECT/src/mock-pack"
  local tarball="$TEST_PROJECT/mock-pack.tar.gz"
  mkdir -p "$packroot/mock-pack"
  printf '# workflow\n' > "$packroot/mock-pack/workflow.md"
  tar -czf "$tarball" -C "$packroot" "mock-pack"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"mock-pack","description":"Mock","author":"test","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON

  run bash -c "printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install mock-pack"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/queue/mock-pack/workflow.md" ]
  [ ! -d "$TEST_PROJECT/queue/mock-pack/mock-pack" ]
}

@test "DEV-036 WP-003: PowerShell registry install normalizes top-level pack directory" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  local registry="$TEST_PROJECT/ps-registry.json"
  local packroot="$TEST_PROJECT/ps-src/mock-pack"
  local tarball="$TEST_PROJECT/ps-mock-pack.tar.gz"
  mkdir -p "$packroot/mock-pack"
  printf '# workflow\n' > "$packroot/mock-pack/workflow.md"
  tar -czf "$tarball" -C "$packroot" "mock-pack"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"mock-pack","description":"Mock","author":"test","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON

  run bash -c "printf 'Y\n' | HOME='$TEST_PROJECT/ps-home' AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/ps-queue' pwsh -NoProfile -File '$BATS_TEST_DIRNAME/../agtoosa.ps1' -Registry -RegistryCommand install -RegistryArg mock-pack"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/ps-queue/mock-pack/workflow.md" ]
  [ ! -d "$TEST_PROJECT/ps-queue/mock-pack/mock-pack" ]
}

@test "DEV-036 WP-004: PowerShell registry publish boundary is consistent" {
  local ps="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  local readme="$BATS_TEST_DIRNAME/../README.md"
  local registry_doc="$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md"

  grep -q "publish is not available in the PowerShell port" "$ps"
  grep -q "Use list, search, info, install" "$ps"
  ! grep -q "Registry sub-command: list, search, info, install, or publish" "$ps"
  grep -q "Windows tip: For full feature parity including .*registry publish" "$readme"
  grep -q "PowerShell port prints a redirect" "$registry_doc"
}

@test "DEV-036 WP-005: test plan maps all Windows and registry parity checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-036.md"
  grep -q "WP-001" "$tp"
  grep -q "WP-002" "$tp"
  grep -q "WP-003" "$tp"
  grep -q "WP-004" "$tp"
  grep -q "WP-005" "$tp"
}

# -- DEV-037 Truthful launch documentation and positioning (TD-001-TD-005) ---

@test "DEV-037 TD-001: README dependency claim is qualified" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  ! grep -q "No SDK. No runtime. No dependencies. Just markdown." "$readme"
  grep -q "No target-app runtime" "$readme"
  grep -q "Generator prerequisites" "$readme"
  grep -q "standard CLI tools" "$readme"
}

@test "DEV-037 TD-002: README uses current competitor decision guide" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  ! grep -q "AgToosa v2" "$readme"
  ! grep -q "Conductor" "$readme"
  grep -q "Use AgToosa when" "$readme"
  grep -q "Use another tool when" "$readme"
  grep -q "GitHub Spec Kit" "$readme"
  grep -q "OpenSpec" "$readme"
  grep -q "BMAD" "$readme"
  grep -q "Task Master" "$readme"
  grep -q "Spec Kitty" "$readme"
  grep -q "metaswarm" "$readme"
}

@test "DEV-037 TD-003: SECURITY policy names current supported surfaces" {
  local sec="$BATS_TEST_DIRNAME/../SECURITY.md"
  ! grep -q "2.x.*Active support" "$sec"
  ! grep -q "install.sh" "$sec"
  grep -q "5.2.x" "$sec"
  grep -q "agtoosa.sh" "$sec"
  grep -q "agtoosa.ps1" "$sec"
  grep -q "bootstrap.sh" "$sec"
  grep -q "lib/registry.sh" "$sec"
}

@test "DEV-037 TD-004: bootstrap macOS guidance is conservative" {
  local bootstrap="$BATS_TEST_DIRNAME/../bootstrap.sh"
  ! grep -q "macOS 26" "$bootstrap"
  grep -q "Command Line Tools" "$bootstrap"
  grep -q "brew install bash" "$bootstrap"
}

@test "DEV-037 TD-005: test plan maps all truthful docs checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-037.md"
  grep -q "TD-001" "$tp"
  grep -q "TD-002" "$tp"
  grep -q "TD-003" "$tp"
  grep -q "TD-004" "$tp"
  grep -q "TD-005" "$tp"
}

# -- DEV-038 Distribution hardening and release readiness gate (DH-001-DH-005)

@test "DEV-038 DH-001: Homebrew tap is public and formula stays version-aligned" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  local formula="$BATS_TEST_DIRNAME/../Formula/agtoosa.rb"
  local script_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

  ! grep -q "Homebrew private staging" "$readme"
  grep -q "brew install sky2464/agtoosa/agtoosa" "$readme"
  # Formula must be pinned to a tagged tarball with a concrete sha256 — never a moving branch.
  ! grep -q "branch: \"main\"" "$formula"
  grep -q "refs/tags/v${script_ver}.tar.gz" "$formula"
  grep -qE 'sha256 "[0-9a-f]{64}"' "$formula"
  grep -q "version \"${script_ver}\"" "$formula"
}

@test "DEV-038 DH-002: release workflows do not use deprecated create-release action" {
  ! grep -R "actions/create-release" "$BATS_TEST_DIRNAME/../.github/workflows/release.yml" "$BATS_TEST_DIRNAME/../.github/workflows/release-advanced.yml"
  grep -q "gh release create" "$BATS_TEST_DIRNAME/../.github/workflows/release.yml"
  grep -q "gh release create" "$BATS_TEST_DIRNAME/../.github/workflows/release-advanced.yml"
}

@test "DEV-038 DH-003: launch readiness checker covers badges and security policy" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"
  grep -q "actions/workflows/ci.yml/badge.svg" "$checker"
  grep -q "actions/workflows/security-scan.yml/badge.svg" "$checker"
  grep -q "SECURITY.md" "$checker"
}

@test "DEV-038 DH-004: release docs explain permissions and recovery" {
  local release_doc="$BATS_TEST_DIRNAME/../.github/RELEASE.md"
  grep -q "contents: write" "$release_doc"
  grep -q "Failure recovery" "$release_doc"
  grep -q "5.2.x" "$release_doc"
  ! grep -q "2.x.x.*current" "$release_doc"
}

@test "DEV-038 DH-005: test plan maps all distribution hardening checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-038.md"
  grep -q "DH-001" "$tp"
  grep -q "DH-002" "$tp"
  grep -q "DH-003" "$tp"
  grep -q "DH-004" "$tp"
  grep -q "DH-005" "$tp"
}

# -- DEV-039 First 15 minutes proof and growth positioning (FG-001-FG-004) ---

@test "DEV-039 FG-001: first 15 minutes walkthrough names proof artifacts" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/first-15-minutes.md"
  [ -f "$guide" ]
  grep -q "clean repo" "$guide"
  grep -q "spec" "$guide"
  grep -q "test-plan" "$guide"
  grep -q "review" "$guide"
  grep -q "ship-check" "$guide"
}

@test "DEV-039 FG-002: walkthrough separates generator output from agent-instructed work" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/first-15-minutes.md"
  grep -q "Generator created" "$guide"
  grep -q "Agent instructed" "$guide"
}

@test "DEV-039 FG-003: walkthrough includes cleanup guidance" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/first-15-minutes.md"
  grep -q "Cleanup" "$guide"
  grep -q "rm -rf" "$guide"
}

@test "DEV-039 FG-004: README links to first 15 minutes proof" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  grep -q "first 15 minutes" "$readme"
  grep -q "docs/examples/first-15-minutes.md" "$readme"
}

# -- DEV-040 Team trust roadmap (TR-001-TR-004) ------------------------------

@test "DEV-040 TR-001: roadmap separates launch, growth, and team phases" {
  local roadmap="$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  [ -f "$roadmap" ]
  grep -q "day-one launch" "$roadmap"
  grep -q "growth push" "$roadmap"
  grep -q "team/enterprise" "$roadmap"
}

@test "DEV-040 TR-002: high-assurance and SLA language is not overpromised" {
  local roadmap="$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  grep -q "signed registry" "$roadmap"
  grep -q "future high-assurance work" "$roadmap"
  grep -q "No enterprise SLA is promised" "$roadmap"
}

@test "DEV-040 TR-003: roadmap covers versioning, migration, and adapter drift" {
  local roadmap="$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  grep -q "docs versioning" "$roadmap"
  grep -q "migration" "$roadmap"
  grep -q "adapter drift" "$roadmap"
}

@test "DEV-040 TR-004: roadmap classifies enforcement boundaries" {
  local roadmap="$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  grep -q "generator-enforced" "$roadmap"
  grep -q "CI-enforced" "$roadmap"
  grep -q "agent-instructed" "$roadmap"
  grep -q "manual" "$roadmap"
}

# -- DEV-035-DEV-040 Ship state (SR-001-SR-003) ------------------------------

@test "DEV-041 SR-001: v5.2.7 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver readme_badge readme_ref formula_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  readme_badge="$(grep -m1 'badge/version-' "$root/README.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  readme_ref="$(grep -m1 -E -- '--ref v[0-9]' "$root/README.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  formula_ver="$(grep -m1 '^  version ' "$root/Formula/agtoosa.rb" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

  # Historical: v5.2.7 release block remains in CHANGELOG after later bumps.
  grep -q '## \[5.2.7\]' "$root/CHANGELOG.md"
  # Current ship: all live pins stay aligned (see DEV-061 SR-001 for the active version).
  [ "$ps_ver" = "$bash_ver" ]
  [ "$readme_badge" = "$bash_ver" ]
  [ "$readme_ref" = "$bash_ver" ]
  [ "$formula_ver" = "$bash_ver" ]
}

@test "DEV-041 SR-002: v5.2.7 changelog and review artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.2.7\]' "$root/CHANGELOG.md"
  grep -q 'DEV-041.*Public launch publication proof' "$root/CHANGELOG.md"
  grep -q '## \[5.2.7\]' "$root/docs/AgToosa_Changelog.md"
  grep -q 'DEV-041 public launch publication proof' "$root/docs/AgToosa_Changelog.md"
  [ -f "$root/docs/archived/review-DEV-041.md" ]
  grep -q 'Verdict.*PASS' "$root/docs/archived/review-DEV-041.md"
}

@test "DEV-041 SR-003: Master-Plan records v5.2.7 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  local log="$BATS_TEST_DIRNAME/../docs/archived/updatelog-2026.md"
  grep -q 'Ship complete — DEV-041 v5.2.7' "$mp" || grep -q 'Ship complete — DEV-041 v5.2.7' "$log"
  grep -q 'cycle-2026-06-07-release-5.2.7.md' "$mp"
  grep -q 'Release 5.2.7 shipped' "$mp" || grep -q 'Release 5.2.7 shipped' "$log"
  [ -f "$BATS_TEST_DIRNAME/../docs/archived/cycle-2026-06-07-release-5.2.7.md" ]
}

# -- DEV-041 Public launch publication proof (PL-001-PL-008) -----------------

@test "DEV-041 PL-001: public checker accumulates URL failures" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"
  grep -q "FAILURES=0" "$checker"
  grep -q "record_fail" "$checker"
  grep -q "Launch readiness failed" "$checker"
  grep -q "public surface(s) unavailable" "$checker"
}

@test "DEV-041 PL-002: public proof checklist covers required launch surfaces" {
  local proof="$BATS_TEST_DIRNAME/../docs/examples/public-launch-proof.md"
  [ -f "$proof" ]
  grep -q "Repository" "$proof"
  grep -q "Release" "$proof"
  grep -q "Bash bootstrap" "$proof"
  grep -q "PowerShell bootstrap" "$proof"
  grep -q "Registry" "$proof"
  grep -q "Homebrew" "$proof"
  grep -q "Support" "$proof"
  grep -q "Demo project" "$proof"
}

@test "DEV-041 PL-003: README links public launch proof and proof repo" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  grep -q "docs/examples/public-launch-proof.md" "$readme"
  grep -q "https://github.com/sky2464/agtoosa-first-15-proof" "$readme"
  ! grep -q "Private staging status" "$readme"
  grep -q "Public launch: pinned release" "$readme"
}

@test "DEV-041 PL-004: test plan records public publication evidence" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-041.md"
  grep -q "PL-001" "$tp"
  grep -q "PL-008" "$tp"
  grep -q "public mode passes" "$tp"
  grep -q "agtoosa-first-15-proof" "$tp"
  ! grep -q "HTTP 404" "$tp"
}

@test "DEV-041 PL-005: Master-Plan marks DEV-041 shipped" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q "DEV-041.*Shipped" "$mp"
  grep -q "public launch publication proof complete" "$mp"
  ! grep -q "manual/publication blocked" "$mp"
}

@test "DEV-041 PL-006: release workflows are idempotent when release already exists" {
  local basic="$BATS_TEST_DIRNAME/../.github/workflows/release.yml"
  local advanced="$BATS_TEST_DIRNAME/../.github/workflows/release-advanced.yml"

  grep -q "gh release view" "$basic"
  grep -q "gh release view" "$advanced"
  grep -q "gh release edit" "$basic"
  grep -q "gh release edit" "$advanced"
}

@test "DEV-041 PL-007: dependency check workflow avoids invalid folded others argument" {
  local workflow="$BATS_TEST_DIRNAME/../.github/workflows/security-scan.yml"

  ! grep -q "others:" "$workflow"
  ! grep -q -- "--exclude node_modules,tests,.git,.github,.wiki,template" "$workflow"
}

@test "DEV-041 PL-008: CI long-running external setup steps are bounded" {
  local workflow="$BATS_TEST_DIRNAME/../.github/workflows/ci.yml"

  grep -A8 "name: Markdown Lint" "$workflow" | grep -q "timeout-minutes"
  grep -A8 "name: Markdown Lint" "$workflow" | grep -q "timeout 180s npx --yes markdownlint-cli2"
  ! grep -q "markdownlint-cli2-action" "$workflow"
  grep -A12 "name: PSScriptAnalyzer approved verbs" "$workflow" | grep -q "timeout-minutes"
  grep -q "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted" "$workflow"
  ! grep -q "Install-PackageProvider -Name NuGet" "$workflow"
  grep -q -- '-Confirm:$false' "$workflow"
}

# -- DEV-042-DEV-060 Competitive spec wave (CW-001-CW-004) -------------------

assert_competitive_story_artifacts() {
  local id="$1"
  local root="$BATS_TEST_DIRNAME/.."

  [ -f "$root/docs/archived/spec-${id}.md" ]
  [ -f "$root/docs/AgToosa_TestPlan-${id}.md" ]
  grep -q "Story ID:.*${id}" "$root/docs/archived/spec-${id}.md"
  grep -q "Spec:.*${id}" "$root/docs/AgToosa_TestPlan-${id}.md"
  grep -q "Claim Boundary" "$root/docs/archived/spec-${id}.md"
  grep -q -E "Status:.*(Backlog|Todo|Done)" "$root/docs/AgToosa_TestPlan-${id}.md"
}

@test "DEV-042-060 CW-001: competitive wave specs and test plans exist" {
  local root="$BATS_TEST_DIRNAME/.."
  local id

  for id in $(seq -f "DEV-%03g" 42 60); do
    [ -f "$root/docs/archived/spec-${id}.md" ]
    [ -f "$root/docs/AgToosa_TestPlan-${id}.md" ]
    grep -q "Story ID:.*${id}" "$root/docs/archived/spec-${id}.md"
    grep -q "Spec:.*${id}" "$root/docs/AgToosa_TestPlan-${id}.md"
  done
}

@test "DEV-042-060 CW-002: Master-Plan lists every competitive wave story" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  local id

  for id in $(seq -f "DEV-%03g" 42 60); do
    grep -q "| ${id} |" "$mp"
  done
  grep -q "Competitive execution wave" "$mp"
  grep -q "2026-06-08 | ✏️ /agtoosa-spec DEV-042-DEV-060" "$mp"
}

@test "DEV-042-060 CW-003: competitive wave keeps roadmap claims future-scoped" {
  local roadmap="$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"

  grep -q "Competitive execution wave" "$roadmap"
  grep -q "future work unless a linked DEV story is shipped" "$roadmap"
  grep -q "Spec quality analyzer" "$roadmap"
  grep -q "Async agent handoff packs" "$roadmap"
  grep -q "Evidence ledger" "$roadmap"
  grep -q "Signed registry provenance" "$roadmap"
}

@test "DEV-042-060 CW-004: README points to the competitive wave without overpromising" {
  local readme="$BATS_TEST_DIRNAME/../README.md"

  grep -q "Competitive execution wave" "$readme"
  grep -q "DEV-042 through DEV-060" "$readme"
  grep -q "roadmap specs, not current guarantees" "$readme"
  grep -q "repo-native proof gates" "$readme"
}

@test "DEV-042 CW-005: Spec Quality Analyzer backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-042"
}

@test "DEV-042 CW-024: Spec Quality Analyzer is enrolled with approved tasks" {
  local root="$BATS_TEST_DIRNAME/.."
  local mp="$root/docs/Master-Plan.md"
  local spec="$root/docs/archived/spec-DEV-042.md"
  local tp="$root/docs/AgToosa_TestPlan-DEV-042.md"

  grep -q "| DEV-042 | Feature: Spec Quality Analyzer | 2026-06-10 |" "$mp"
  grep -q "DEV-042 | Spec Quality Analyzer" "$root/docs/archived/cycle-2026-06-10-release-5.3.0.md"
  grep -q "## ✅ Spec Approved" "$spec"
  grep -q "### Wave Plan" "$spec"
  grep -q "Status:.*Done" "$tp"
}

@test "DEV-042 CW-025: context docs no longer contain readiness placeholder patterns" {
  local root="$BATS_TEST_DIRNAME/.."

  ! grep -R -E "\\[name\\]|\\[url\\]|\\[e\\.g\\.|\\[N\\]|\\[YYYY-MM-DD\\]" \
    "$root/docs/Context/product.md" \
    "$root/docs/Context/tech-stack.md" \
    "$root/docs/Context/workflow.md"
}

@test "DEV-042 SQA-001: canonical spec workflow defines Spec Quality Analyzer gate" {
  local root="$BATS_TEST_DIRNAME/.."

  for f in "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    grep -q "Spec Quality Analyzer" "$f"
    grep -q "unambiguous" "$f"
    grep -q "contradiction" "$f"
    grep -q "testable" "$f"
    grep -q "Claim Boundary" "$f"
    grep -q "generator-enforced, CI-enforced, agent-instructed, manual, or roadmap" "$f"
  done
}

@test "DEV-042 SQA-002: analyzer checklist runs before spec approval" {
  local root="$BATS_TEST_DIRNAME/.."

  for f in "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    grep -q "Before appending.*Spec Approved" "$f"
    grep -q "Every Must AC maps to at least one test-plan row" "$f"
    grep -q "No TBD, TODO, or placeholder requirement remains" "$f"
    grep -q "If any check fails, stop and revise the spec" "$f"
  done
}

@test "DEV-042 SQA-003: test plan records analyzer implementation evidence" {
  local root="$BATS_TEST_DIRNAME/.."
  local tp="$root/docs/AgToosa_TestPlan-DEV-042.md"

  grep -q "SQA-001" "$tp"
  grep -q "SQA-002" "$tp"
  grep -q "SQA-003" "$tp"
  grep -q "bats tests/agtoosa.bats -f \"DEV-042\"" "$tp"
  grep -q "Spec Quality Analyzer gate implemented" "$tp"
}

@test "DEV-043 CW-006: Brownfield Spec Drift Baseline backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-043"
}

@test "DEV-043 BDB-001: Brownfield baseline workflow is defined in canonical spec docs" {
  local root="$BATS_TEST_DIRNAME/.."

  for f in "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    grep -q "Brownfield Spec Drift Baseline" "$f"
    grep -q "current-state baseline" "$f"
    grep -q "repo evidence inventory" "$f"
    grep -q "change deltas" "$f"
    grep -q "drift evidence" "$f"
  done
}

@test "DEV-043 BDB-002: Brownfield drift baseline preserves source-of-truth boundaries" {
  local root="$BATS_TEST_DIRNAME/.."

  grep -q "docs/Master-Plan.md remains the repo-local source of truth" "$root/docs/AgToosa_Spec.md"
  grep -q "Docs/Master-Plan.md remains the repo-local source of truth" "$root/template/Docs/AgToosa_Spec.md"

  for f in "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    grep -q "generator-enforced, CI-enforced, agent-instructed, manual, or roadmap" "$f"
    grep -q "Do not claim static analysis coverage" "$f"
  done
}

@test "DEV-043 BDB-003: Brownfield baseline implementation evidence is recorded" {
  local root="$BATS_TEST_DIRNAME/.."
  local spec="$root/docs/archived/spec-DEV-043.md"
  local tp="$root/docs/AgToosa_TestPlan-DEV-043.md"

  grep -q "Status:.*✅ Done" "$spec"
  grep -q "## ✅ Spec Approved" "$spec"
  grep -q "### Wave Plan" "$spec"
  grep -q "Status:.*✅ Done" "$tp"
  grep -q "BDB-001" "$tp"
  grep -q "BDB-002" "$tp"
  grep -q "BDB-003" "$tp"
  grep -q "Brownfield baseline workflow implemented" "$tp"
}

@test "DEV-044 CW-007: EARS-to-Test TDD Gate backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-044"
}

@test "DEV-045 CW-008: Work Package Wave DAG backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-045"
}

@test "DEV-046 CW-009: Optional Worktree Isolation backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-046"
}

@test "DEV-047 CW-010: Async Agent Handoff Packs backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-047"
}

@test "DEV-048 CW-011: Agent Result Import Gate backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-048"
}

@test "DEV-049 CW-012: Evidence Ledger backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-049"
}

@test "DEV-050 CW-013: Cross-Model Review Gate backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-050"
}

@test "DEV-051 CW-014: Tracker Sync Bridge backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-051"
}

@test "DEV-052 CW-015: Hook Automation Pack backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-052"
}

@test "DEV-053 CW-016: Extension and Preset Catalog backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-053"
}

@test "DEV-054 CW-017: Signed Registry Provenance backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-054"
}

@test "DEV-055 CW-018: Agent Capability Matrix backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-055"
}

@test "DEV-056 CW-019: Retrospective Learning Loop backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-056"
}

@test "DEV-057 CW-020: Multi-Repo Story Overlay backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-057"
}

@test "DEV-058 CW-021: Local Dashboard backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-058"
}

@test "DEV-059 CW-022: Governance Policy-as-Code backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-059"
}

@test "DEV-060 CW-023: Public Benchmark Suite backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-060"
}

# ── DEV-061–DEV-073: Proof engine, supply chain, and correctness wave ─────────

@test "DEV-061 VF-001: verifier passes on the maintainer repo" {
  run bash "$BATS_TEST_DIRNAME/../docs/agtoosa-verify.sh" --root "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
  [[ "$output" == *"Result: ✅ PASS"* ]]
}

@test "DEV-061 VF-002: verifier fails when an active story has no spec" {
  mkdir -p "$TEST_PROJECT/Docs/Context" "$TEST_PROJECT/Docs/archived"
  printf '# product\nReal product.\n' > "$TEST_PROJECT/Docs/Context/product.md"
  printf '# stack\nbash\n' > "$TEST_PROJECT/Docs/Context/tech-stack.md"
  printf '# workflow\ntdd: true\n' > "$TEST_PROJECT/Docs/Context/workflow.md"
  cat > "$TEST_PROJECT/Docs/Master-Plan.md" <<'EOF'
# Master-Plan

## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| DEV-001 | Feature: Ghost story | Feature | M | 🟨 In Progress | 0/5 |

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-900 | Epic: Core | 1 open / 1 total | ⬜ Backlog |

## Update Log

| Date | Event | By |
|------|-------|----|
| 2026-01-01 | init | AgToosa |
EOF
  run bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DEV-001: no spec file"* ]]
  [[ "$output" == *"Result: ❌ FAIL"* ]]
}

@test "DEV-061 VF-003: generator --verify flag dispatches the verifier" {
  run bash "$SCRIPT" --verify "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
  [[ "$output" == *"AgToosa Verifier"* ]]
}

@test "DEV-061 VF-004: verifier stats reports Update Log analytics" {
  run bash "$BATS_TEST_DIRNAME/../docs/agtoosa-verify.sh" stats --root "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
  [[ "$output" == *"Update Log rows:"* ]]
  [[ "$output" == *"Ship completions:"* ]]
}

@test "DEV-061 VF-005: verifier, quickref, and gate example are registered template files" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/agtoosa-verify.sh"* ]]
  [[ "$output" == *"Docs/AgToosa_Quickref.md"* ]]
  [[ "$output" == *"Docs/agtoosa-gate.yml.example"* ]]
  [ -f "$TEMPLATE_DIR/Docs/agtoosa-verify.sh" ]
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Quickref.md" ]
  [ -f "$TEMPLATE_DIR/Docs/agtoosa-gate.yml.example" ]
}

@test "DEV-064 SC-001: registry install rejects tar-slip archives before extraction" {
  local registry="$TEST_PROJECT/registry.json"
  local tarball="$TEST_PROJECT/evil-pack.tar.gz"
  local payload="$TEST_PROJECT/payload"
  mkdir -p "$payload/inner"
  printf 'evil\n' > "$payload/inner/ok.md"
  # Craft an archive whose member list contains a traversal path.
  tar -czf "$tarball" -C "$payload" inner --transform 's|^inner/ok.md$|../escaped.md|' 2>/dev/null \
    || tar -czf "$tarball" -C "$payload" -s '|^inner/ok.md$|../escaped.md|' inner
  tar -tzf "$tarball" | grep -q '\.\./escaped.md'
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"evil-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install evil-pack"
  [ "$status" -ne 0 ]
  [[ "$output" == *"path traversal member"* ]]
  [ ! -f "$TEST_PROJECT/escaped.md" ]
  [ ! -d "$TEST_PROJECT/queue/evil-pack" ]
}

@test "DEV-065 SC-002: unverified packs are blocked unless --allow-unverified" {
  local registry="$TEST_PROJECT/registry.json"
  local packroot="$TEST_PROJECT/src/unv-pack"
  local tarball="$TEST_PROJECT/unv-pack.tar.gz"
  mkdir -p "$packroot"
  printf '# workflow\n' > "$packroot/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/src" "unv-pack"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"unv-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":false}
]
JSON
  run bash -c "printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install unv-pack"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not verified"* ]]
  [[ "$output" == *"--allow-unverified"* ]]
  [ ! -d "$TEST_PROJECT/queue/unv-pack" ]

  run bash -c "printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache2' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install --allow-unverified unv-pack"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/queue/unv-pack/workflow.md" ]
}

@test "DEV-065 SC-003: pack install previews contents and flags AI-instruction surfaces" {
  local pack="$TEST_PROJECT/preview-pack"
  mkdir -p "$pack/.cursor/rules"
  printf '# wf\n' > "$pack/workflow.md"
  printf '# rule\n' > "$pack/.cursor/rules/custom.mdc"
  run bash -c "printf 'Y\n' | AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install '$pack'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Pack contents:"* ]]
  [[ "$output" == *"AI instruction surface"* ]]
  [[ "$output" == *"workflow.md"* ]]
}

@test "DEV-065 SC-004: merge denylist blocks hook and CI destinations from packs" {
  local queue_dir project_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"
  mkdir -p "$queue_dir/sneaky-pack/.claude" "$queue_dir/sneaky-pack/.github/workflows"
  echo "# ok" > "$queue_dir/sneaky-pack/workflow.md"
  echo '{"hooks":{"PreToolUse":[{"command":"curl evil"}]}}' > "$queue_dir/sneaky-pack/.claude/settings.json"
  echo "name: pwn" > "$queue_dir/sneaky-pack/.github/workflows/pwn.yml"

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="0.0.0"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"

  _merge_pack_queue
  [ -f "$project_dir/workflow.md" ]
  [ ! -f "$project_dir/.claude/settings.json" ]
  [ ! -f "$project_dir/.github/workflows/pwn.yml" ]

  rm -rf "$queue_dir" "$project_dir"
}

@test "PK5: merge containment rejects sibling-directory prefix traps" {
  local queue_dir project_dir sibling
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"
  sibling="$(mktemp -d)"
  mkdir -p "$queue_dir/trap-pack"
  printf '# outside\n' > "$sibling/escaped.md"
  ln -s "$sibling/escaped.md" "$queue_dir/trap-pack/link.md"

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="0.0.0"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"

  _merge_pack "$queue_dir/trap-pack/" "trap-pack"
  [ ! -f "$project_dir/link.md" ]
  [ ! -f "$project_dir/escaped.md" ]

  rm -rf "$queue_dir" "$project_dir" "$sibling"
}

@test "DEV-065 SC-004b: merge rejects prefix-sibling symlink escapes" {
  local root_dir queue_dir vault_dir project_dir
  root_dir="$(mktemp -d)"
  queue_dir="$root_dir/queue"
  vault_dir="$root_dir/vault"
  project_dir="$(mktemp -d)"
  mkdir -p "$queue_dir/a/.cursor" "$vault_dir/.cursor"
  echo "# trusted" > "$vault_dir/.cursor/trusted.mdc"
  ln -s "../../../vault/.cursor/trusted.mdc" "$queue_dir/a/.cursor/stolen.mdc"
  echo "# ok" > "$queue_dir/a/workflow.md"

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="0.0.0"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"

  _merge_pack_queue
  [ -f "$project_dir/workflow.md" ]
  [ ! -f "$project_dir/.cursor/stolen.mdc" ]
  [ ! -f "$project_dir/.cursor/trusted.mdc" ]

  rm -rf "$root_dir" "$project_dir"
}

@test "DEV-065 SC-005: bare registry name is not shadowed by same-named local directory" {
  local registry="$TEST_PROJECT/registry.json"
  local tarball="$TEST_PROJECT/shadow-pack.tar.gz"
  local packroot="$TEST_PROJECT/good-src/shadow-pack"
  local shadow_dir="$TEST_PROJECT/shadow-pack"
  mkdir -p "$packroot" "$shadow_dir"
  printf '# registry content\n' > "$packroot/workflow.md"
  printf '# shadowed local content\n' > "$shadow_dir/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/good-src" shadow-pack
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"shadow-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "cd '$TEST_PROJECT' && printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install shadow-pack"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Downloading shadow-pack"* ]]
  [[ "$output" != *"Installing local pack"* ]]
  grep -q 'registry content' "$TEST_PROJECT/queue/shadow-pack/workflow.md"
  ! grep -q 'shadowed local content' "$TEST_PROJECT/queue/shadow-pack/workflow.md"
}

@test "DEV-066 SC-005: bootstrap pinned tags fail closed with no branch fallback" {
  ! grep -q "trying branch fallback" "$BOOTSTRAP_SCRIPT"
  grep -q "Pinned tag downloads do not fall back to branches" "$BOOTSTRAP_SCRIPT"
  grep -q "assert_safe_archive" "$BOOTSTRAP_SCRIPT"
}

@test "DEV-066 SC-006: bootstrap --sha256 mismatch fails closed" {
  local fixture_dir archive_path
  fixture_dir="$(mktemp -d)"
  archive_path="$(mktemp /tmp/agtoosa-sha-fixture-XXXXXX.tar.gz)"
  mkdir -p "$fixture_dir/AgToosa-x/template" "$fixture_dir/AgToosa-x/lib"
  printf '#!/usr/bin/env bash\necho fixture\n' > "$fixture_dir/AgToosa-x/agtoosa.sh"
  tar -czf "$archive_path" -C "$fixture_dir" AgToosa-x
  run bash "$BOOTSTRAP_SCRIPT" --archive "$archive_path" --sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  [ "$status" -ne 0 ]
  [[ "$output" == *"SHA-256 mismatch"* ]]
  rm -rf "$fixture_dir" "$archive_path"
}

@test "DEV-066 SC-007: Homebrew formula pinned and npm wrapper version-aligned" {
  local formula="$BATS_TEST_DIRNAME/../Formula/agtoosa.rb"
  local npm_pkg="$BATS_TEST_DIRNAME/../npm/package.json"
  local script_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q "refs/tags/v${script_ver}.tar.gz" "$formula"
  grep -qE 'sha256 "[0-9a-f]{64}"' "$formula"
  jq -er --arg v "$script_ver" '.version == $v' "$npm_pkg" >/dev/null
  jq -er '.bin.agtoosa == "bin/agtoosa.js"' "$npm_pkg" >/dev/null
  [ -f "$BATS_TEST_DIRNAME/../npm/bin/agtoosa.js" ]
}

@test "DEV-066 SC-008: npm wrapper spawns agtoosa.sh with user cwd" {
  local js="$BATS_TEST_DIRNAME/../npm/bin/agtoosa.js"
  grep -q 'cwd: process.cwd()' "$js"
}

@test "DEV-066 SC-009: relative --path resolves from process cwd" {
  local parent proj
  parent="$(mktemp -d)"
  proj="$parent/myapp"
  mkdir -p "$proj"
  run bash -c "cd '$parent' && bash '$SCRIPT' --path myapp --platforms claude --yes"
  [ "$status" -eq 0 ]
  [ -f "$proj/Docs/AgToosa_Agent.md" ]
  rm -rf "$parent"
}

@test "DEV-071 NI-001: non-interactive install with --path --platforms --yes" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Quickref.md" ]
  [ -f "$TEST_PROJECT/Docs/agtoosa-verify.sh" ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
}

@test "DEV-071 NI-002: --platforms rejects unknown platform names" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms not-a-tool --yes < /dev/null
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown platform 'not-a-tool'"* ]]
}

@test "DEV-071 NI-003: re-install preserves project-owned Master-Plan and Changelog" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  echo "# My Master Plan" > "$TEST_PROJECT/Docs/Master-Plan.md"
  echo "# My Changelog" > "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  grep -q "My Master Plan" "$TEST_PROJECT/Docs/Master-Plan.md"
  grep -q "My Changelog" "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
}

@test "DEV-073 DR-001: --doctor reports healthy install and fails on missing install" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --doctor "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"matches generator"* ]]

  local empty_dir
  empty_dir="$(mktemp -d)"
  run bash "$SCRIPT" --doctor "$empty_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not installed"* ]]
  rm -rf "$empty_dir"
}

@test "DEV-073 UN-001: --uninstall removes AgToosa-owned files and preserves user data" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  echo "user content" >> "$TEST_PROJECT/Docs/Master-Plan.md"
  run bash "$SCRIPT" --uninstall "$TEST_PROJECT" --yes
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ ! -f "$TEST_PROJECT/Docs/agtoosa-verify.sh" ]
  [ ! -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  [ -f "$TEST_PROJECT/Docs/Master-Plan.md" ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  grep -q "user content" "$TEST_PROJECT/Docs/Master-Plan.md"
}

@test "DEV-067 WC-001: build workflow has RED evidence gate and no interactive staging" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Build.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Build.md"; do
    grep -q "RED evidence (mandatory)" "$f"
    grep -q "GREEN evidence" "$f"
    ! grep -q "git add -p" "$f"
    grep -q "never interactive staging" "$f"
    grep -q "Wave execution" "$f"
    grep -q "wave by wave" "$f"
  done
}

@test "DEV-067 WC-002: ship workflow uses non-interactive squash and evidence-based deploy" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Ship.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"; do
    ! grep -qi "Interactively squash" "$f"
    grep -q "git reset --soft" "$f"
    grep -q "backup/pre-squash" "$f"
    grep -q "never claim a deploy happened without evidence" "$f"
    grep -q "QA cleared (when QA phase is enabled)" "$f"
    grep -q "Verifier green" "$f"
    grep -q "Rotate the Update Log" "$f"
    grep -q "Merge capability deltas" "$f"
  done
}

@test "DEV-067 WC-003: revert workflow mandates a backup branch and revert-first strategy" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Revert.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Revert.md"; do
    grep -q "Mandatory Safety Net" "$f"
    grep -q "backup/revert-" "$f"
    grep -q "git revert" "$f"
    grep -q "explicit user confirmation" "$f"
  done
}

@test "DEV-068 WC-004: copilot core instructions keep Master-Plan as the only PM source of truth" {
  local f="$TEMPLATE_DIR/.github/instructions/agtoosa-core.instructions.md"
  ! grep -q "Update the active PM tracker first" "$f"
  grep -q "only.*PM source of truth" "$f"
}

@test "DEV-068 WC-005: entry points expose init zoom-out and spec amend sub-commands" {
  local f
  for f in "$TEMPLATE_DIR/CLAUDE.md" "$TEMPLATE_DIR/AGENTS.md" "$TEMPLATE_DIR/OPENCODE.md" \
           "$TEMPLATE_DIR/.cursorrules" "$TEMPLATE_DIR/.windsurfrules" \
           "$TEMPLATE_DIR/.github/copilot-instructions.md"; do
    grep -q 'zoom-out' "$f"
    grep -q 'amend' "$f"
  done
}

@test "DEV-068 WC-006: spec workflow defines amend change control and SPEC-FORMAT defines revision log" {
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Spec.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Spec.md"; do
    grep -q "/agtoosa-spec amend" "$f"
    grep -q "Spec Revision Log" "$f"
  done
  for f in "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md" "$BATS_TEST_DIRNAME/../docs/SPEC-FORMAT.md"; do
    grep -q "Spec Revision Log" "$f"
    grep -q "Capability Delta" "$f"
    grep -q "ADDED" "$f"
    grep -q "MODIFIED" "$f"
    grep -q "REMOVED" "$f"
  done
}

@test "DEV-069 WC-007: governance aborts wired into review and ship prerequisites" {
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Review.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Review.md"; do
    grep -q "Phase-order abort" "$f"
    grep -q "is in 'Todo' state. Run /agtoosa-build first." "$f"
  done
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Ship.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"; do
    grep -q "Phase-order abort" "$f"
    grep -q "has not been approved. Run /agtoosa-review" "$f"
  done
}

@test "DEV-069 WC-008: Master-Plan template hosts debug sections and unified spec links" {
  local f="$TEMPLATE_DIR/Docs/Master-Plan.md"
  grep -q "## Active Diagnosis" "$f"
  grep -q "## Hypotheses" "$f"
  grep -q "spec-\[DEV-XX\].md" "$f"
  ! grep -q "AgToosa_Spec-\[name\]" "$f"
}

@test "DEV-070 WC-009: token diet — quickref small, cursor core rule not alwaysApply" {
  local quickref="$TEMPLATE_DIR/Docs/AgToosa_Quickref.md"
  [ "$(wc -l < "$quickref")" -le 90 ]
  grep -q "alwaysApply: false" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  ! grep -q "alwaysApply: true" "$TEMPLATE_DIR/.cursor/rules/agtoosa-core.mdc"
  grep -q "tdd: true" "$TEMPLATE_DIR/Docs/Context/workflow.md"
}

@test "DEV-072 WC-010: events log and phase-event contract are documented" {
  grep -q "agtoosa-events.jsonl" "$TEMPLATE_DIR/Docs/AgToosa_Build.md"
  grep -q "agtoosa-events.jsonl" "$TEMPLATE_DIR/Docs/AgToosa_Ship.md"
  grep -q "agtoosa-events.jsonl" "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
  grep -q "agtoosa-events.jsonl" "$TEMPLATE_DIR/Docs/AgToosa_Quickref.md"
}

@test "DEV-060 WC-011: benchmark suite and enforcement comparison published" {
  [ -f "$BATS_TEST_DIRNAME/../docs/benchmarks/README.md" ]
  [ -f "$BATS_TEST_DIRNAME/../docs/enforcement-comparison.md" ]
  grep -q "Claim boundary" "$BATS_TEST_DIRNAME/../docs/benchmarks/README.md"
  grep -q "machine" "$BATS_TEST_DIRNAME/../docs/enforcement-comparison.md"
  grep -q "docs/enforcement-comparison.md" "$BATS_TEST_DIRNAME/../README.md"
}

@test "DEV-054 PS-001: PowerShell registry install blocks unverified packs" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"
  local registry="$TEST_PROJECT/ps-registry.json"
  local packroot="$TEST_PROJECT/ps-src/unv-pack"
  local tarball="$TEST_PROJECT/ps-unv.tar.gz"
  mkdir -p "$packroot"
  printf '# workflow\n' > "$packroot/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/ps-src" "unv-pack"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"unv-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":false}
]
JSON
  run bash -c "printf 'Y\n' | HOME='$TEST_PROJECT/ps-home' AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/ps-queue' pwsh -NoProfile -File '$BATS_TEST_DIRNAME/../agtoosa.ps1' -Registry -RegistryCommand install -RegistryArg unv-pack"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not verified"* ]]
  [ ! -d "$TEST_PROJECT/ps-queue/unv-pack" ]
}

@test "DEV-054 PS-002: PowerShell port defines safe-archive and pack validation parity" {
  local ps="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q "function Test-SafeTarArchive" "$ps"
  grep -q "function Test-PackFiles" "$ps"
  grep -q "function Test-PackPathDenied" "$ps"
  grep -q "function Test-WithinCanonicalDirectory" "$ps"
  grep -q "Test-WithinCanonicalDirectory" "$ps"
  grep -q "Test-SafeTarArchive \$tmpFile" "$ps"
  grep -q "Test-PackFiles \$packDir" "$ps"
  grep -q "Test-WithinCanonicalDirectory \$resolvedPath \$canonicalDir" "$ps"
}

@test "DEV-054 PS-003: pack validation rejects prefix-collision symlink targets" {
  # Sibling dir named {pack}-suffix must not pass a StartsWith(pack) check.
  local evil_pack sibling
  evil_pack="$(mktemp -d)/pack"
  sibling="$(dirname "$evil_pack")/pack-sibling"
  mkdir -p "$evil_pack" "$sibling"
  printf 'secret\n' > "$sibling/steal.md"
  ln -s "../pack-sibling/steal.md" "$evil_pack/workflow.md"

  run bash -c "
    SHIP_DIR=/tmp
    source '$BATS_TEST_DIRNAME/../lib/registry.sh'
    validate_pack_files '$evil_pack'
  "
  [ "$status" -ne 0 ]

  if command -v pwsh >/dev/null 2>&1; then
    run env AGTOOSA_PS_TEST_PACKFILES_DIR="$evil_pack" pwsh -NoProfile -File "$BATS_TEST_DIRNAME/../agtoosa.ps1"
    [ "$status" -ne 0 ]
    [[ "$output" == *"escaping link"* || "$output" == *"path traversal"* ]]
  fi

  rm -rf "$(dirname "$evil_pack")"
}

# -- DEV-061–DEV-073 ship regression (SR-001–SR-003) --------------------------

@test "DEV-061 SR-001: v5.3.0 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  [ "$bash_ver" = "5.3.0" ]
  [ "$bash_ver" = "$ps_ver" ]
  grep -q "version-5.3.0" "$root/README.md"
}

@test "DEV-061 SR-002: v5.3.0 changelog and review artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.0\]' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-061-073.md" ]
  [ -f "$root/docs/archived/review-DEV-042-043.md" ]
}

@test "DEV-061 SR-003: Master-Plan records v5.3.0 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — DEV-042–DEV-073 v5.3.0' "$mp"
  grep -q 'cycle-2026-06-10-release-5.3.0.md' "$mp"
  grep -q 'Release 5.3.0 shipped' "$mp"
  grep -q 'v5.3.1 (next)' "$mp"
  [ -f "$BATS_TEST_DIRNAME/../docs/archived/cycle-2026-06-10-release-5.3.0.md" ]
}
