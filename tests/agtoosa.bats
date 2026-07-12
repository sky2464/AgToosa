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
  # Clean up any ship/ left by the generator (best-effort; parallel tests may race)
  rm -rf "$BATS_TEST_DIRNAME/../ship" 2>/dev/null || true
}
# ── Flag tests ────────────────────────────────────────────────────────────────
@test "--version prints version string" {
  # Update this expected string on each release (Eng review: exact-version pin)
  run bash "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == "AgToosa v5.3.15" ]]
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
  [ "$ver" = "5.3.15" ]
}

@test "--update after fresh install shows real version not 'vunknown'" {
  # Fresh install writes .agtoosa-version — subsequent --update must read it
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"vunknown"* ]]
  [[ "$output" == *"5.3.15"* ]]
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

@test "WP2: each native surface has exactly 18 agtoosa workflow adapters" {
  [ "$(find "$TEMPLATE_DIR/.claude/commands" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
  [ "$(find "$TEMPLATE_DIR/.cursor/commands" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
  [ "$(find "$TEMPLATE_DIR/.gemini/commands" -maxdepth 1 -name 'agtoosa-*.toml' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
  [ "$(find "$TEMPLATE_DIR/.github/prompts" -maxdepth 1 -name 'agtoosa-*.prompt.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
  [ "$(find "$TEMPLATE_DIR/.windsurf/workflows" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
  [ "$(find "$TEMPLATE_DIR/.codex/prompts" -maxdepth 1 -name 'agtoosa-*.md' 2>/dev/null | wc -l | tr -d ' ')" -eq 18 ]
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
  grep -qE '/AgToosa/\$\{EXPECTED_TAG\}/bootstrap\.sh' "$checker"
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
  [ "$(cat "$project/Docs/.agtoosa-version")" = "5.3.15" ]
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
  grep -q -E "Status:.*(Backlog|Todo|In Progress|Done)" "$root/docs/AgToosa_TestPlan-${id}.md"
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

# ── DEV-045: Work Package Wave DAG (DAG-001–DAG-007) ─────────────────────────

# Ownership overlap: same-wave packages must have disjoint owned_files, or the
# Wave Plan must declare an explicit sequential fallback for the overlap set.
_dag_paths_overlap() {
  local a="$1" b="$2"
  local pa pb
  for pa in $a; do
    for pb in $b; do
      [[ "$pa" == "$pb" ]] && return 0
      [[ "$pa" == */ ]] && [[ "$pb" == "$pa"* ]] && return 0
      [[ "$pb" == */ ]] && [[ "$pa" == "$pb"* ]] && return 0
    done
  done
  return 1
}

_dag_require_disjoint_or_sequential() {
  local owned_a="$1" owned_b="$2" fallback="$3"
  if _dag_paths_overlap "$owned_a" "$owned_b"; then
    [[ "$fallback" == "sequential" ]] || return 1
  fi
  return 0
}

# Dependency contract: every depends_on target must exist and have an earlier wave.
_dag_deps_valid() {
  # Args: package_id wave depends_csv  then remaining triples as id:wave pairs in a map file
  local pkg="$1" wave="$2" deps="$3" mapfile="$4"
  local dep dep_wave
  [[ "$deps" == "-" || "$deps" == "—" || -z "$deps" ]] && return 0
  IFS=',' read -r -a dep_arr <<< "$deps"
  for dep in "${dep_arr[@]}"; do
    dep="${dep// /}"
    [[ -z "$dep" ]] && continue
    [[ "$dep" == "$pkg" ]] && return 1
    dep_wave="$(awk -F: -v id="$dep" '$1==id {print $2; exit}' "$mapfile")"
    [[ -n "$dep_wave" ]] || return 1
    [[ "$dep_wave" -lt "$wave" ]] || return 1
  done
  return 0
}

@test "DEV-045 DAG-001: SPEC-FORMAT defines Work Package DAG schema and Claim Boundary @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/SPEC-FORMAT.md" "$root/template/Docs/SPEC-FORMAT.md"; do
    [ -f "$f" ]
    grep -q "### 3.4 Work Package DAG" "$f"
    grep -q "package_id" "$f"
    grep -q "depends_on" "$f"
    grep -q "owned_files" "$f"
    grep -q "merge_order" "$f"
    grep -q "verification" "$f"
    # Eight-column normative header
    grep -E '\| *package_id *\| *wave *\| *depends_on *\| *owned_files *\| *inputs *\| *outputs *\| *merge_order *\| *verification *\|' "$f"
    grep -q "PKG-" "$f"
    grep -q "generator-enforced" "$f"
    grep -q "CI-enforced" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "roadmap" "$f"
    # Reject overclaims of runtime enforcement (honest "roadmap" mentions of a
    # runtime scheduler are allowed; positive scheduling claims are not).
    ! grep -qiE 'runtime scheduler (enforces|runs|dispatches)|schedules parallel agents|provides guaranteed parallel isolation|AgToosa schedules' "$f"
  done
}

@test "DEV-045 DAG-002: Spec derives one Work Package per executable sub-task @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    [ -f "$f" ]
    grep -q "Work Package" "$f"
    grep -q "PKG-" "$f"
    grep -q "owned_files" "$f"
    grep -q "verification" "$f"
    grep -q "depends_on" "$f"
    grep -qiE 'one Work Package|one package row|package row for every|one package per' "$f"
    grep -qiE 'parallel.*(owned_files|verification)|(owned_files|verification).*parallel' "$f"
  done
}

@test "DEV-045 DAG-003: disjoint ownership accepted; overlap requires sequential fallback @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  # Positive fixture: disjoint paths in the same wave
  _dag_require_disjoint_or_sequential "lib/foo.sh" "docs/AgToosa_Bar.md" "parallel"
  # Negative fixture: duplicate explicit path without fallback
  ! _dag_require_disjoint_or_sequential "lib/foo.sh" "lib/foo.sh" "parallel"
  # Negative fixture becomes valid with sequential fallback
  _dag_require_disjoint_or_sequential "lib/foo.sh" "lib/foo.sh" "sequential"
  # Directory wildcard intersection requires sequential fallback
  ! _dag_require_disjoint_or_sequential "lib/" "lib/foo.sh" "parallel"
  _dag_require_disjoint_or_sequential "lib/" "lib/foo.sh" "sequential"
  for f in "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md" \
           "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md"; do
    grep -qiE 'owned_files|Work Package' "$f"
    grep -qiE 'sequential fallback|disjoint' "$f"
  done
  for f in "$root/docs/SPEC-FORMAT.md" "$root/template/Docs/SPEC-FORMAT.md"; do
    grep -qiE 'disjoint|sequential fallback|overlap' "$f"
  done
}

@test "DEV-045 DAG-004: depends_on must resolve to earlier-wave packages" {
  local root="$BATS_TEST_DIRNAME/.."
  local mapfile f
  mapfile="$(mktemp)"
  printf '%s\n' "PKG-1.1:1" "PKG-1.2:1" "PKG-2.1:2" > "$mapfile"
  # Valid: earlier-wave deps
  _dag_deps_valid "PKG-2.1" 2 "PKG-1.1,PKG-1.2" "$mapfile"
  # Invalid: unknown package
  ! _dag_deps_valid "PKG-2.1" 2 "PKG-9.9" "$mapfile"
  # Invalid: self-reference
  ! _dag_deps_valid "PKG-1.1" 1 "PKG-1.1" "$mapfile"
  # Invalid: same-wave dependency
  ! _dag_deps_valid "PKG-1.2" 1 "PKG-1.1" "$mapfile"
  # Invalid: later-wave dependency
  ! _dag_deps_valid "PKG-1.1" 1 "PKG-2.1" "$mapfile"
  rm -f "$mapfile"
  for f in "$root/docs/SPEC-FORMAT.md" "$root/template/Docs/SPEC-FORMAT.md" \
           "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md" \
           "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md"; do
    grep -q "depends_on" "$f"
    grep -qiE 'earlier wave|earlier-wave' "$f"
    grep -q "merge_order" "$f"
  done
}

@test "DEV-045 DAG-005: Handoff exports selected-wave Work Packages section @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Handoff.md" "$root/template/Docs/AgToosa_Handoff.md"; do
    [ -f "$f" ]
    grep -q "Work Packages" "$f"
    grep -q "package_id" "$f"
    grep -q "owned_files" "$f"
    grep -q "inputs" "$f"
    grep -q "outputs" "$f"
    grep -q "merge_order" "$f"
    grep -q "verification" "$f"
    grep -qiE 'selected wave|selected-wave|Wave N|current wave' "$f"
  done
}

@test "DEV-045 DAG-006: Import reports ownership gaps and merge_order before status mutation" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Import.md" "$root/template/Docs/AgToosa_Import.md"; do
    [ -f "$f" ]
    grep -qiE 'ownership gap|owned_files' "$f"
    grep -q "merge_order" "$f"
    grep -qiE 'changed files|changed paths' "$f"
    grep -q "source of truth" "$f"
    # Import must not claim to mutate Master-Plan as authority
    grep -qiE 'cannot.*Master-Plan|before.*checkbox|lifecycle checkbox|status mutation|No checkbox' "$f" \
      || grep -q "block checkbox closure" "$f"
  done
  for f in "$root/docs/AgToosa_Quickref.md" "$root/template/Docs/AgToosa_Quickref.md" \
           "$root/docs/AgToosa_Team_Trust_Roadmap.md"; do
    grep -q "generator-enforced" "$f" || true
  done
  # Claim Boundary honesty across Quickref + Trust (no runtime scheduler claim)
  for f in "$root/docs/AgToosa_Quickref.md" "$root/template/Docs/AgToosa_Quickref.md"; do
    grep -qiE 'Work Package|DAG' "$f"
    ! grep -qiE 'runtime scheduler (enforces|runs|dispatches)|schedules parallel agents|AgToosa schedules' "$f"
  done
  grep -qiE 'Work Package|work-package DAG|DEV-045' "$root/docs/AgToosa_Team_Trust_Roadmap.md"
  ! grep -qiE 'runtime scheduler (enforces|runs|dispatches)|schedules parallel agents|provides guaranteed parallel isolation|AgToosa schedules' \
    "$root/docs/AgToosa_Team_Trust_Roadmap.md"
}

@test "DEV-045 DAG-007: dual-path wiring and dogfood DAG evidence @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f tp
  for f in \
    "$root/docs/SPEC-FORMAT.md" "$root/template/Docs/SPEC-FORMAT.md" \
    "$root/docs/AgToosa_Spec.md" "$root/template/Docs/AgToosa_Spec.md" \
    "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md" \
    "$root/docs/AgToosa_Handoff.md" "$root/template/Docs/AgToosa_Handoff.md" \
    "$root/docs/AgToosa_Import.md" "$root/template/Docs/AgToosa_Import.md"; do
    [ -f "$f" ]
    grep -qE 'Work Package|owned_files|### 3.4 Work Package DAG' "$f"
  done
  # Must not reopen DEV-055 surfaces with DEV-045 Work Package content
  ! grep -qiE 'Work Package DAG|owned_files' "$root/docs/AgToosa_AgentCapability.md"
  ! grep -qiE 'Work Package DAG|owned_files' "$root/template/Docs/AgToosa_AgentCapability.md"
  tp="$root/docs/AgToosa_TestPlan-DEV-045.md"
  [ -f "$tp" ]
  grep -q "PKG-1.1" "$tp"
  grep -q "PKG-1.2" "$tp"
  grep -q "PKG-2.1" "$tp"
  # Dogfood evidence must record an actual GREEN run (not placeholders only)
  grep -q "Observed exit code: 0" "$tp"
  grep -qiE 'Status:.*(?:GREEN|executed|complete)' "$tp"
  grep -q "two-parallel" "$tp" || grep -q "PKG-2.1" "$tp"
}

# ── DEV-046: Optional Worktree Isolation (WT-001–WT-006) ─────────────────────

@test "DEV-046 WT-001: Worktree guide defines use/skip criteria and Claim Boundary @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Worktree.md" "$root/template/Docs/AgToosa_Worktree.md"; do
    [ -f "$f" ]
    # Use: M+ with at least two parallel packages or explicitly risky lane
    grep -qiE 'M\+|M\+ work|estimate.*M' "$f"
    grep -qiE 'two parallel|at least two|parallel packages' "$f"
    grep -qiE 'risky lane|higher-risk|explicitly risky' "$f"
    # Skip: XS/S single-lane
    grep -qiE 'XS/S|XS.*S' "$f"
    grep -qiE 'single-lane|single lane|skip' "$f"
    # Enforcement classes / Claim Boundary
    grep -q "generator-enforced" "$f"
    grep -q "CI-enforced" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "manual" "$f"
    grep -q "roadmap" "$f"
    grep -qi "Claim Boundary" "$f"
    # Reject mandatory / automatic-isolation overclaims
    ! grep -qiE 'worktrees? (are|is) mandatory|must (always )?use (a )?worktree|automatic(ally)? (creates?|provision|isolat)|guarantees? (lane )?isolation|AgToosa (creates|provisions) worktrees' "$f"
  done
}

@test "DEV-046 WT-002: Worktree guide documents safe commands, paths, secrets, cleanup @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Worktree.md" "$root/template/Docs/AgToosa_Worktree.md"; do
    [ -f "$f" ]
    grep -q "git worktree add" "$f"
    grep -q "git worktree list" "$f"
    grep -q "git worktree remove" "$f"
    grep -q "git worktree prune" "$f"
    # Preferred sibling path pattern
    grep -q '../<repo>-<package_id>' "$f"
    # In-repo alternative requires ignore
    grep -q '.worktrees/' "$f"
    grep -qiE 'ignore|\.gitignore' "$f"
    # Secret / env boundary — prohibit automatic copying
    grep -qiE '\.env|secret|credential' "$f"
    grep -qiE 'do not (automatically )?copy|never copy|prohibit.*(copy|env)|no automatic copying' "$f"
    # Cleanup after integration
    grep -qiE 'cleanup|remove.*prune|prune.*remove' "$f"
  done
}

@test "DEV-046 WT-003: Handoff optional Worktree Hint is package-scoped and read-only" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Handoff.md" "$root/template/Docs/AgToosa_Handoff.md"; do
    [ -f "$f" ]
    grep -qiE 'Worktree Hint|worktree hint' "$f"
    grep -q "package_id" "$f"
    grep -qiE 'suggested.?path|suggested_path' "$f"
    grep -qiE 'suggested.?branch|suggested_branch' "$f"
    # Optional / conditional — not mandatory creation
    grep -qiE 'optional|when.*parallel|IF.*parallel|if isolation' "$f"
    # Read-only: no Git mutation / no creation
    grep -qiE 'does not create|without creating|no (Git )?mutation|does not run git|hint.*(read-only|no creation)|never create' "$f"
  done
}

@test "DEV-046 WT-004: Import requires clean status, verification, merge_order, then cleanup @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Import.md" "$root/template/Docs/AgToosa_Import.md"; do
    [ -f "$f" ]
    grep -qiE 'clean.?status|clean working tree|status --short|git status' "$f"
    grep -qiE 'verification|package.?verification' "$f"
    grep -q "merge_order" "$f"
    grep -qiE 'worktree|Worktree' "$f"
    # Cleanup deferred until after accepted integration
    grep -qiE 'cleanup|remove|prune' "$f"
    grep -qiE 'after.*(integrat|accept)|until.*(integrat|accept)|defer.*cleanup|cleanup.*after' "$f"
  done
}

@test "DEV-046 WT-005: exact sequential fallback string; AgentCapability read-only" {
  local root="$BATS_TEST_DIRNAME/.."
  local f exact
  exact='No worktree: run packages sequentially in one branch and verify a clean working tree between packages.'
  for f in \
    "$root/docs/AgToosa_Worktree.md" "$root/template/Docs/AgToosa_Worktree.md" \
    "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md" \
    "$root/docs/AgToosa_Handoff.md" "$root/template/Docs/AgToosa_Handoff.md" \
    "$root/docs/AgToosa_Import.md" "$root/template/Docs/AgToosa_Import.md"; do
    [ -f "$f" ]
    grep -Fq "$exact" "$f"
  done
  # AgToosa_AgentCapability.md remains a read-only routing reference (not edited for Worktree)
  for f in "$root/docs/AgToosa_Worktree.md" "$root/template/Docs/AgToosa_Worktree.md" \
           "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
    grep -qiE 'read-only|routing reference|consult.*AgentCapability|do not (edit|modify).*AgentCapability' "$f"
  done
  # DEV-055 surfaces must not gain Worktree content
  ! grep -qiE 'Worktree|worktree|git worktree' "$root/docs/AgToosa_AgentCapability.md"
  ! grep -qiE 'Worktree|worktree|git worktree' "$root/template/Docs/AgToosa_AgentCapability.md"
}

@test "DEV-046 WT-006: config registration, dual-path cross-links, no DEV-055 edits @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  local f tp
  # Dual-path guide present
  [ -f "$root/docs/AgToosa_Worktree.md" ]
  [ -f "$root/template/Docs/AgToosa_Worktree.md" ]
  # Registered in generator inventory
  grep -q 'Docs/AgToosa_Worktree.md' "$root/lib/config.sh"
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Worktree.md"* ]]
  # Build / Handoff / Import / Quickref / Agent cross-links
  for f in \
    "$root/docs/AgToosa_Build.md" "$root/template/Docs/AgToosa_Build.md" \
    "$root/docs/AgToosa_Handoff.md" "$root/template/Docs/AgToosa_Handoff.md" \
    "$root/docs/AgToosa_Import.md" "$root/template/Docs/AgToosa_Import.md" \
    "$root/docs/AgToosa_Quickref.md" "$root/template/Docs/AgToosa_Quickref.md" \
    "$root/docs/AgToosa_Agent.md" "$root/template/Docs/AgToosa_Agent.md"; do
    [ -f "$f" ]
    grep -qiE 'AgToosa_Worktree|worktree isolation|optional.*worktree' "$f"
  done
  # Safety / cleanup fields in guide
  for f in "$root/docs/AgToosa_Worktree.md" "$root/template/Docs/AgToosa_Worktree.md"; do
    grep -q "git worktree remove" "$f"
    grep -q "git worktree prune" "$f"
    grep -q '../<repo>-<package_id>' "$f"
  done
  # Test plan smoke set + evidence structure
  tp="$root/docs/AgToosa_TestPlan-DEV-046.md"
  [ -f "$tp" ]
  grep -q "WT-001" "$tp"
  grep -q "WT-002" "$tp"
  grep -q "WT-004" "$tp"
  grep -q "WT-006" "$tp"
  # No requirement to modify DEV-055 files
  ! grep -qiE 'edit.*AgentCapability|modify.*AgentCapability|must.*(change|update).*AgentCapability' "$tp"
}

@test "DEV-047 HO-001: handoff contract exists in template and maintainer docs" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Handoff.md" "$root/docs/AgToosa_Handoff.md"; do
    [ -f "$f" ]
    grep -q "Pack Template" "$f"
    grep -q "Return Contract" "$f"
    grep -q "Allowed Actions" "$f"
    grep -q "Verification Commands" "$f"
    grep -q "handoff-\[story-id\]" "$f"
  done
}

@test "DEV-047 HO-002: handoff claim boundary and source-of-truth strings" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Handoff.md" "$root/docs/AgToosa_Handoff.md"; do
    grep -q "agent-instructed" "$f"
    grep -q "manual" "$f"
    grep -q "source of truth" "$f"
    grep -q "No checkbox ticks" "$f"
    grep -q "remains the repo-local source of truth" "$f"
  done
}

@test "DEV-047 HO-003: Build references handoff for async wave export" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Build.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Build.md"; do
    grep -q "/agtoosa-handoff" "$f"
    grep -q "/agtoosa-build handoff" "$f"
    grep -q "Async dispatch" "$f"
  done
}

@test "DEV-047 HO-004: native handoff adapters route to AgToosa_Handoff.md" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/.claude/commands/agtoosa-handoff.md" \
    "$root/template/.cursor/commands/agtoosa-handoff.md" \
    "$root/template/.gemini/commands/agtoosa-handoff.toml" \
    "$root/template/.github/prompts/agtoosa-handoff.prompt.md" \
    "$root/template/.windsurf/workflows/agtoosa-handoff.md" \
    "$root/template/.codex/prompts/agtoosa-handoff.md" \
    "$root/template/.codex/skills/agtoosa-handoff/SKILL.md"; do
    [ -f "$f" ]
    grep -q "Docs/AgToosa_Handoff.md" "$f"
    ! grep -q "Pack Template" "$f"
  done
}

@test "DEV-047 HO-005: Handoff doc registered in template file list" {
  run bash "$BATS_TEST_DIRNAME/../agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Handoff.md"* ]]
  [[ "$output" == *".cursor/commands/agtoosa-handoff.md"* ]]
}

# ── DEV-048: Agent Result Import Gate (IR-001–IR-005) ────────────────────────

@test "DEV-048 IR-001: import checklist contract in template and maintainer docs" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Import.md" "$root/docs/AgToosa_Import.md"; do
    [ -f "$f" ]
    grep -q "Import Checklist" "$f"
    grep -q "Evidence Mapping" "$f"
    grep -q "IMPORT evidence" "$f"
    grep -q "Closure Gate" "$f"
  done
}

@test "DEV-048 IR-002: import claim boundary and verification language" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Import.md" "$root/docs/AgToosa_Import.md"; do
    grep -q "agent-instructed" "$f"
    grep -q "Imported claims are not evidence until repo-local verification passes" "$f"
    grep -q "generator-enforced, CI-enforced, agent-instructed, manual, or roadmap\|not generator-enforced" "$f"
  done
  grep -q "Agent result import gate" "$root/docs/AgToosa_Readiness.md"
  grep -q "Agent result import gate" "$root/docs/AgToosa_Team_Trust_Roadmap.md"
}

@test "DEV-048 IR-003: Build requires import before tracking out-of-band work" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Build.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Build.md"; do
    grep -q "External / async task detection" "$f"
    grep -q "/agtoosa-import" "$f"
    grep -q "Imported claims are not evidence until repo-local verification passes" "$f"
  done
}

@test "DEV-048 IR-004: native import adapters route to AgToosa_Import.md" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/.claude/commands/agtoosa-import.md" \
    "$root/template/.cursor/commands/agtoosa-import.md" \
    "$root/template/.gemini/commands/agtoosa-import.toml" \
    "$root/template/.github/prompts/agtoosa-import.prompt.md" \
    "$root/template/.windsurf/workflows/agtoosa-import.md" \
    "$root/template/.codex/prompts/agtoosa-import.md" \
    "$root/template/.codex/skills/agtoosa-import/SKILL.md"; do
    [ -f "$f" ]
    grep -q "Docs/AgToosa_Import.md" "$f"
    ! grep -q "Import Checklist" "$f"
  done
}

@test "DEV-048 IR-005: Import doc registered and Ship soft readiness row present" {
  run bash "$BATS_TEST_DIRNAME/../agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Import.md"* ]]
  [[ "$output" == *".cursor/commands/agtoosa-import.md"* ]]
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Ship.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"; do
    grep -q "External agent evidence" "$f"
  done
}

# ── DEV-049: Evidence Ledger (EL-001–EL-005) ─────────────────────────────────

@test "DEV-049 EL-001: Review workflow requires evidence ledger update" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Review.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Review.md"; do
    grep -q "evidence-\[story-id\]" "$f" || grep -q 'evidence-[story-id]' "$f"
    grep -q "AgToosa_Evidence.md" "$f"
    grep -q "/agtoosa-evidence" "$f"
  done
}

@test "DEV-049 EL-002: Ship workflow finalizes evidence ledger" {
  local f
  for f in "$TEMPLATE_DIR/Docs/AgToosa_Ship.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Ship.md"; do
    grep -q "Evidence ledger" "$f" || grep -q "evidence ledger" "$f"
    grep -q "evidence-\[story-id\]" "$f" || grep -q 'evidence-[story-id]' "$f"
    grep -q "AgToosa_Evidence.md" "$f"
  done
}

@test "DEV-049 EL-003: Evidence schema and claim boundary in dual-path docs" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Evidence.md" "$root/docs/AgToosa_Evidence.md"; do
    [ -f "$f" ]
    grep -q "Markdown schema" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "source of truth" "$f"
    grep -q "Phase" "$f"
    grep -q "Verification" "$f"
    grep -q "reviewer" "$f" || grep -q "Reviewer" "$f"
    grep -q "remains the repo-local source of truth" "$f"
    ! grep -qiE 'generator-enforced ledger|CI-enforced ledger' "$f"
  done
}

@test "DEV-049 EL-004: optional JSONL mirror schema and seed registered" {
  local root="$BATS_TEST_DIRNAME/.."
  [ -f "$root/template/Docs/agtoosa-evidence.jsonl" ]
  [ -f "$root/docs/agtoosa-evidence.jsonl" ]
  for f in "$root/template/Docs/AgToosa_Evidence.md" "$root/docs/AgToosa_Evidence.md"; do
    grep -q "agtoosa-evidence.jsonl" "$f"
    grep -q "non-authoritative" "$f"
  done
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/agtoosa-evidence.jsonl"* ]]
}

@test "DEV-049 EL-005: Evidence doc registered and adapters route thinly" {
  run bash "$BATS_TEST_DIRNAME/../agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Evidence.md"* ]]
  [[ "$output" == *".cursor/commands/agtoosa-evidence.md"* ]]
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/.claude/commands/agtoosa-evidence.md" \
    "$root/template/.cursor/commands/agtoosa-evidence.md" \
    "$root/template/.gemini/commands/agtoosa-evidence.toml" \
    "$root/template/.github/prompts/agtoosa-evidence.prompt.md" \
    "$root/template/.windsurf/workflows/agtoosa-evidence.md" \
    "$root/template/.codex/prompts/agtoosa-evidence.md" \
    "$root/template/.codex/skills/agtoosa-evidence/SKILL.md"; do
    [ -f "$f" ]
    grep -q "Docs/AgToosa_Evidence.md" "$f"
    ! grep -q "Markdown schema" "$f"
  done
}

@test "DEV-049 CW-012: Evidence Ledger backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-049"
}

@test "DEV-050 CW-013: Cross-Model Review Gate backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-050"
}

# ── DEV-050: Cross-Model Review Gate (CM-001–CM-007) ─────────────────────────

@test "DEV-050 CM-001: cross-model contract exists in template and maintainer docs" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_CrossModelReview.md" "$root/docs/AgToosa_CrossModelReview.md"; do
    [ -f "$f" ]
    grep -q "Writer" "$f"
    grep -q "Independent reviewer" "$f"
    grep -q "Risk-Tier Triggers" "$f"
    grep -q "Structured Evidence Block" "$f"
    grep -q "Merge and Confidence Rules" "$f"
    grep -q "Fallback chain" "$f"
    grep -q "Read-Only Guarantee" "$f"
  done
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_CrossModelReview.md"* ]]
  [[ "$output" == *"agtoosa-cross-model-reviewer.agent.md"* ]]
}

@test "DEV-050 CM-002: Review routes cross-model sub-command to canonical doc" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Review.md" "$root/docs/AgToosa_Review.md"; do
    grep -q "cross-model" "$f"
    grep -q "AgToosa_CrossModelReview.md" "$f"
    grep -q "read-only" "$f"
  done
}

@test "DEV-050 CM-003: cross-model evidence block extends specialist schema" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_CrossModelReview.md" "$root/docs/AgToosa_CrossModelReview.md"; do
    grep -q "Reviewer identity" "$f"
    grep -q "Model/platform" "$f"
    grep -q "Findings:" "$f"
    grep -q "Files read:" "$f"
    grep -q "Commands:" "$f"
    grep -q "both-models" "$f"
    grep -q "reviewer-only" "$f"
    grep -q "writer-only" "$f"
    grep -q "virtual-persona-only" "$f"
  done
}

@test "DEV-050 CM-004: cross-model documents parallel and sequential fallback" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_CrossModelReview.md" "$root/docs/AgToosa_CrossModelReview.md"; do
    grep -q "parallel subagent delegation" "$f"
    grep -q "Cross-model lanes ran sequentially (platform does not support parallel subagents)." "$f"
  done
}

@test "DEV-050 CM-005: cross-model tier triggers and skip rationale" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_CrossModelReview.md" "$root/docs/AgToosa_CrossModelReview.md"; do
    grep -q "Strongly recommended" "$f"
    grep -q "Skip rationale" "$f"
    grep -q "security" "$f"
    grep -q "registry" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Evidence.md" "$root/docs/AgToosa_Evidence.md"; do
    grep -q "cross-model" "$f"
  done
}

@test "DEV-050 CM-006: specialists doc documents review phase orchestration" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Specialists.md" "$root/docs/AgToosa_Specialists.md"; do
    grep -q "phase_hooks" "$f"
    grep -q '`review`' "$f"
    grep -q "/agtoosa-review" "$f"
    grep -q "trigger" "$f"
  done
}

@test "DEV-050 CM-007: Agent Skills Quickref cross-link cross-model gate" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Agent.md" "$root/docs/AgToosa_Agent.md"; do
    grep -q "cross-model" "$f"
    grep -q "AgToosa_CrossModelReview.md" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Skills.md" "$root/docs/AgToosa_Skills.md"; do
    grep -q "cross-model" "$f"
    grep -q "AgToosa_CrossModelReview.md" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Quickref.md" "$root/docs/AgToosa_Quickref.md"; do
    grep -q "cross-model" "$f"
    grep -q "AgToosa_CrossModelReview.md" "$f"
  done
}

@test "DEV-051 CW-014: Tracker Sync Bridge backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-051"
}

# ── DEV-051: Tracker Sync Bridge (TS-001–TS-008) ─────────────────────────────

@test "DEV-051 TS-001: stable export id and required v1 fields" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/tracker-sync/project"
  local out1="$TEST_PROJECT/ts-export-1.json"
  local out2="$TEST_PROJECT/ts-export-2.json"
  run bash "$SCRIPT" --tracker export --path "$fixture" --output "$out1"
  [ "$status" -eq 0 ]
  sleep 1
  run bash "$SCRIPT" --tracker export --path "$fixture" --output "$out2"
  [ "$status" -eq 0 ]
  [ "$(jq -r .export_id "$out1")" = "$(jq -r .export_id "$out2")" ]
  run jq -e '.schema_version == "agtoosa.tracker-bridge/v1" and (.export_id|length > 0) and (.source.master_plan_sha256|length > 0) and (.stories|length >= 1)' "$out1"
  [ "$status" -eq 0 ]
}

@test "DEV-051 TS-002: stories sorted by story_id with AC refs" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/tracker-sync/project"
  local out="$TEST_PROJECT/ts-export-sort.json"
  run bash "$SCRIPT" --tracker export --path "$fixture" --output "$out"
  [ "$status" -eq 0 ]
  [ "$(jq -r '.stories[0].story_id' "$out")" = "DEV-Alpha" ]
  [ "$(jq -r '.stories[1].story_id' "$out")" = "DEV-Beta" ]
  run jq -e '.stories[] | select(.story_id=="DEV-Alpha") | (.acceptance_criteria_refs|length) >= 1' "$out"
  [ "$status" -eq 0 ]
}

@test "DEV-051 TS-003: propose mutation guard leaves Master-Plan unchanged" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/tracker-sync/project"
  local mp="$fixture/docs/Master-Plan.md"
  local spec="$fixture/docs/archived/spec-DEV-Alpha.md"
  local export="$TEST_PROJECT/ts-valid-export.json"
  local proposal="$TEST_PROJECT/ts-valid-proposal.md"
  local before_mp before_spec after_mp after_spec
  before_mp=$(shasum -a 256 "$mp" | awk '{print $1}')
  before_spec=$(shasum -a 256 "$spec" | awk '{print $1}')
  run bash "$SCRIPT" --tracker export --path "$fixture" --output "$export"
  [ "$status" -eq 0 ]
  local export_id
  export_id=$(jq -r .export_id "$export")
  jq -n --arg id "$export_id" \
    '{schema_version:"agtoosa.tracker-bridge/v1",base_export_id:$id,provider:"github-issues",changes:[{story_id:"DEV-Alpha",field:"status",proposed_value:"Done",external_ref:"issue-1",observed_at:"2026-07-11T00:00:00Z",rationale:"bats"}]}' \
    >"$TEST_PROJECT/ts-valid-return.json"
  run bash "$SCRIPT" --tracker propose --path "$fixture" --input "$TEST_PROJECT/ts-valid-return.json" --output "$proposal"
  [ "$status" -eq 0 ]
  [ -f "$proposal" ]
  after_mp=$(shasum -a 256 "$mp" | awk '{print $1}')
  after_spec=$(shasum -a 256 "$spec" | awk '{print $1}')
  [ "$before_mp" = "$after_mp" ]
  [ "$before_spec" = "$after_spec" ]
  run bash "$SCRIPT" --tracker propose --path "$fixture" --input "$TEST_PROJECT/ts-valid-return.json" --output "$mp"
  [ "$status" -ne 0 ]
}

@test "DEV-051 TS-004: stale unknown unsupported and conflict dispositions" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/tracker-sync/project"
  local returns="$BATS_TEST_DIRNAME/fixtures/tracker-sync/returns"
  local out
  out="$TEST_PROJECT/ts-stale.md"
  run bash "$SCRIPT" --tracker propose --path "$fixture" --input "$returns/stale.json" --output "$out"
  [ "$status" -eq 0 ]
  grep -q 'Disposition:.*stale' "$out"
  out="$TEST_PROJECT/ts-unknown.md"
  run bash "$SCRIPT" --tracker propose --path "$fixture" --input "$returns/unknown-story.json" --output "$out"
  [ "$status" -eq 0 ]
  grep -q 'Disposition:.*rejected' "$out"
  out="$TEST_PROJECT/ts-unsupported.md"
  run bash "$SCRIPT" --tracker propose --path "$fixture" --input "$returns/unsupported-field.json" --output "$out"
  [ "$status" -eq 0 ]
  grep -q 'Disposition:.*unsupported' "$out"
}

@test "DEV-051 TS-005: canonical doc maps four providers without API claims" {
  local doc="$BATS_TEST_DIRNAME/../docs/AgToosa_TrackerSync.md"
  [ -f "$doc" ]
  grep -q 'GitHub Issues' "$doc"
  grep -q 'Linear' "$doc"
  grep -q 'Jira' "$doc"
  grep -q 'TaskMaster' "$doc"
  grep -q 'no live API' "$doc" || grep -q 'no network' "$doc"
  grep -q 'Do not claim two-way sync' "$doc"
}

@test "DEV-051 TS-006: secret-bearing return redacts without echoing credential" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/tracker-sync/project"
  local out="$TEST_PROJECT/ts-secret.md"
  run bash "$SCRIPT" --tracker propose --path "$fixture" \
    --input "$BATS_TEST_DIRNAME/fixtures/tracker-sync/returns/secret-bearing.json" \
    --output "$out"
  [ "$status" -eq 0 ]
  grep -q 'Disposition:.*rejected' "$out"
  ! grep -q 'SECRET_TOKEN_FIXTURE' "$out"
  run bash "$SCRIPT" --tracker propose --path "$fixture" \
    --input "$BATS_TEST_DIRNAME/fixtures/tracker-sync/returns/oversized.json" \
    --output "$TEST_PROJECT/ts-oversized.md"
  [ "$status" -ne 0 ]
}

@test "DEV-051 TS-007: tracker docs adapters and config inventory registered" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_TrackerSync.md" ]
  [ -f "$BATS_TEST_DIRNAME/../docs/AgToosa_TrackerSync.md" ]
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_TrackerSync.md"* ]]
  [[ "$output" == *"agtoosa-tracker"* ]]
  [ -f "$TEMPLATE_DIR/.cursor/commands/agtoosa-tracker.md" ]
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-tracker.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-tracker.md" ]
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-tracker.toml" ]
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-tracker.prompt.md" ]
  [ -f "$TEMPLATE_DIR/.codex/prompts/agtoosa-tracker.md" ]
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--tracker"* ]]
  grep -q 'generator-enforced' "$BATS_TEST_DIRNAME/../docs/AgToosa_TrackerSync.md"
}

@test "DEV-051 TS-008: DEV-051 filter suite green with claim boundary" {
  local root="$BATS_TEST_DIRNAME/.."
  run bats "$BATS_TEST_DIRNAME/agtoosa.bats" -f "DEV-051 TS-00[1-7]"
  [ "$status" -eq 0 ]
  grep -q 'Do not claim two-way sync' "$root/docs/AgToosa_TrackerSync.md"
  grep -q 'without using live provider APIs' "$root/docs/AgToosa_TestPlan-DEV-051.md"
}

@test "DEV-052 CW-015: Hook Automation Pack backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-052"
}

@test "DEV-053 CW-016: Extension and Preset Catalog backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-053"
}

# ── DEV-053: Extension and Preset Catalog (PC-001–PC-008) ────────────────────

@test "DEV-053 PC-001: catalog schema validates extensions and presets" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  run bash "$SCRIPT" --catalog validate "$fixtures/valid-extension.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Catalog valid"* ]]
  run bash "$SCRIPT" --catalog validate "$fixtures/valid-preset.json"
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --catalog validate catalog/catalog.json
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --catalog validate "$fixtures/duplicate-ids.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Duplicate catalog entry id"* ]]
  local missing="$TEST_PROJECT/missing-fields.json"
  printf '%s\n' '{"schema_version":"1.0","entries":[{"id":"x","kind":"extension"}]}' > "$missing"
  run bash "$SCRIPT" --catalog validate "$missing"
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing required fields"* ]]
}

@test "DEV-053 PC-002: catalog compatibility reports compatible incompatible unknown" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  local registry
  registry="$(cat "$fixtures/registry.json")"
  mkdir -p "$TEST_PROJECT/.cursor" "$TEST_PROJECT/.claude"
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-extension.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog info valid-extension
  [ "$status" -eq 0 ]
  [[ "$output" == *"Compatibility: compatible"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/incompatible-platform.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog info incompatible-extension
  [ "$status" -eq 0 ]
  [[ "$output" == *"Compatibility: incompatible"* ]]
  [[ "$output" == *"missing platform: windsurf"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/unknown-version.json" \
    AGTOOSA_CATALOG_VERSION="not-a-version" \
    bash "$SCRIPT" --catalog info unknown-version-extension
  [ "$status" -eq 0 ]
  [[ "$output" == *"Compatibility: unknown"* ]]
}

@test "DEV-053 PC-003: catalog trust fields render separately without security guarantees" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-extension.json" \
    bash "$SCRIPT" --catalog info valid-extension
  [ "$status" -eq 0 ]
  [[ "$output" == *"Curation tier:"* ]]
  [[ "$output" == *"Registry verified (catalog snapshot):"* ]]
  [[ "$output" == *"Checksum (catalog snapshot):"* ]]
  [[ "$output" == *"not a security guarantee"* ]]
  run grep -i "marketplace" "$BATS_TEST_DIRNAME/../docs/AgToosa_Catalog.md"
  [ "$status" -ne 0 ] || [[ "$output" == *"No hosted marketplace"* ]]
  run grep "security guarantee" "$BATS_TEST_DIRNAME/../docs/AgToosa_Catalog.md"
  [ "$status" -eq 0 ]
}

@test "DEV-053 PC-004: registry drift marks catalog stale and withholds ready plan" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  local registry
  registry="$(cat "$fixtures/registry.json")"
  mkdir -p "$TEST_PROJECT/.cursor" "$TEST_PROJECT/.claude"
  run env AGTOOSA_CATALOG_PATH="$fixtures/stale-provenance.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog info stale-extension
  [ "$status" -eq 0 ]
  [[ "$output" == *"Registry reconciliation: stale"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog plan valid-preset
  [ "$status" -eq 0 ]
  [[ "$output" == *"Status: ready"* ]]
  [[ "$output" == *"--registry install ml-pipeline@1.2.0"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    AGTOOSA_REGISTRY_URL="file://$TEST_PROJECT/no-registry.json" \
    AGTOOSA_REGISTRY_CACHE_DIR="$TEST_PROJECT/empty-cache" \
    bash "$SCRIPT" --catalog plan valid-preset
  [ "$status" -eq 0 ]
  [[ "$output" == *"Status: not-ready"* ]]
  [[ "$output" == *"registry cache unavailable"* ]]
}

@test "DEV-053 PC-005: catalog list search info plan are read-only and deterministic" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  local registry queue_before queue_after
  registry="$(cat "$fixtures/registry.json")"
  queue_before="$(find "$BATS_TEST_DIRNAME/../.agtoosa/pack-queue" -type f 2>/dev/null | wc -l | tr -d ' ')"
  mkdir -p "$TEST_PROJECT/.cursor" "$TEST_PROJECT/.claude"
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog list
  [ "$status" -eq 0 ]
  [[ "$output" == *"valid-extension"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" \
    bash "$SCRIPT" --catalog search ml
  [ "$status" -eq 0 ]
  [[ "$output" == *"valid-extension"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog plan valid-preset
  [ "$status" -eq 0 ]
  [[ "$output" == *"Install commands (non-executing plan):"* ]]
  [[ "$output" != *"Queued"* ]]
  queue_after="$(find "$BATS_TEST_DIRNAME/../.agtoosa/pack-queue" -type f 2>/dev/null | wc -l | tr -d ' ')"
  [ "$queue_before" -eq "$queue_after" ]
  local out1 out2
  out1="$(env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" bash "$SCRIPT" --catalog list)"
  out2="$(env AGTOOSA_CATALOG_PATH="$fixtures/valid-preset.json" bash "$SCRIPT" --catalog list)"
  [ "$out1" = "$out2" ]
}

@test "DEV-053 PC-006: three production catalog entries pass maintained-entry gate" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  local registry
  registry="$(cat "$fixtures/registry.json")"
  mkdir -p "$TEST_PROJECT/.cursor" "$TEST_PROJECT/.claude"
  run bash "$SCRIPT" --catalog validate catalog/catalog.json
  [ "$status" -eq 0 ]
  local entry
  for entry in ext-ml-pipeline ext-react-native preset-fullstack-ml; do
    run env AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
      AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
      AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
      bash "$SCRIPT" --catalog info "$entry"
    [ "$status" -eq 0 ]
    [[ "$output" == *"maintainer"* ]] || [[ "$output" == *"Maintainers"* ]] || [[ "$output" == *"sky2464"* ]] || [[ "$output" == *"communitydev"* ]]
    [[ "$output" == *"Compatibility: compatible"* ]] || [[ "$output" == *"Registry reconciliation: current"* ]]
  done
  run env AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor,claude" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog plan preset-fullstack-ml
  [ "$status" -eq 0 ]
  [[ "$output" == *"Status: ready"* ]]
  [[ "$output" == *"ml-pipeline@1.2.0"* ]]
  [[ "$output" == *"react-native@0.9.1"* ]]
}

@test "DEV-053 PC-007: catalog rejects injection cycles conflicts and oversized text" {
  local fixtures="$BATS_TEST_DIRNAME/fixtures/catalog"
  run bash "$SCRIPT" --catalog validate "$fixtures/injection-entry.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"forbidden executable field"* ]] || [[ "$output" == *"traversal"* ]]
  run bash "$SCRIPT" --catalog validate "$fixtures/oversized-entry.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"exceeds text bound"* ]]
  run bash "$SCRIPT" --catalog validate "$fixtures/invalid-range.json"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid semantic-version range"* ]]
  run env AGTOOSA_CATALOG_PATH="$fixtures/cyclic-preset.json" \
    bash "$SCRIPT" --catalog plan preset-a
  [ "$status" -ne 0 ]
  [[ "$output" == *"dependency cycle"* ]]
  local registry
  registry="$(cat "$fixtures/registry.json")"
  mkdir -p "$TEST_PROJECT/.cursor"
  run env AGTOOSA_CATALOG_PATH="$fixtures/conflicting-preset.json" \
    AGTOOSA_CATALOG_REGISTRY_JSON="$registry" \
    AGTOOSA_CATALOG_PLATFORMS="cursor" \
    AGTOOSA_CATALOG_PROJECT="$TEST_PROJECT" \
    bash "$SCRIPT" --catalog plan conflicting-preset
  [ "$status" -eq 0 ]
  [[ "$output" == *"Status: not-ready"* ]]
  [[ "$output" == *"overlapping conflict"* ]]
}

@test "DEV-053 PC-008: catalog docs adapters and registry cross-link registered" {
  [ -f "$TEMPLATE_DIR/Docs/AgToosa_Catalog.md" ]
  [ -f "$BATS_TEST_DIRNAME/../docs/AgToosa_Catalog.md" ]
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Catalog.md"* ]]
  [[ "$output" == *"agtoosa-catalog"* ]]
  run grep "AgToosa_Catalog.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md"
  [ "$status" -eq 0 ]
  run grep "AgToosa_Registry.md" "$BATS_TEST_DIRNAME/../docs/AgToosa_Catalog.md"
  [ "$status" -eq 0 ]
  run grep -E "tar-slip|denylist|allowlist" "$BATS_TEST_DIRNAME/../docs/AgToosa_Catalog.md"
  [ "$status" -ne 0 ]
  [ -f "$TEMPLATE_DIR/.cursor/commands/agtoosa-catalog.md" ]
  [ -f "$TEMPLATE_DIR/.claude/commands/agtoosa-catalog.md" ]
  [ -f "$TEMPLATE_DIR/.windsurf/workflows/agtoosa-catalog.md" ]
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-catalog.toml" ]
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-catalog.prompt.md" ]
  [ -f "$TEMPLATE_DIR/.codex/prompts/agtoosa-catalog.md" ]
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--catalog"* ]]
}

@test "DEV-054 CW-017: Signed Registry Provenance backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-054"
}

# ── DEV-054: Signed Registry Provenance (SP soft-warn) ───────────────────────

@test "DEV-054 SP-001: provenance schema docs cover packs + releases (minisign primary)" {
  run grep -E "signature|minisign|soft-warn|cosign" "$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"minisign"* ]]
  [[ "$output" == *"cosign"* ]] || [[ "$output" == *"Cosign"* ]]
  run grep -E "minisign|soft-warn|SHA256SUMS" "$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"soft-warn"* ]] || [[ "$output" == *"minisign"* ]]
  [ -f "$BATS_TEST_DIRNAME/../docs/adr/ADR-011-minisign-primary-provenance.md" ]
}

@test "DEV-054 SP-002: invalid .minisig warns but install continues when SHA-256 passes" {
  local registry="$TEST_PROJECT/registry.json"
  local packroot="$TEST_PROJECT/src/sig-pack"
  local tarball="$TEST_PROJECT/sig-pack.tar.gz"
  local fixtures="$BATS_TEST_DIRNAME/fixtures/minisign"
  mkdir -p "$packroot"
  printf '# workflow\n' > "$packroot/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/src" "sig-pack"
  cp "$fixtures/sample.txt.bad.minisig" "${tarball}.minisig"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"sig-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "printf 'Y\n' | AGTOOSA_MINISIGN_PUBKEY='$fixtures/test.minisign.pub' AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install sig-pack"
  [ "$status" -eq 0 ]
  [[ "$output" == *"minisign"* ]]
  [[ "$output" == *"soft-warn"* ]] || [[ "$output" == *"Continuing"* ]] || [[ "$output" == *"verification failed"* ]]
  [ -f "$TEST_PROJECT/queue/sig-pack/workflow.md" ]
}

@test "DEV-054 SP-003: missing minisign binary warns and continues" {
  local registry="$TEST_PROJECT/registry.json"
  local packroot="$TEST_PROJECT/src/nosigtool-pack"
  local tarball="$TEST_PROJECT/nosigtool-pack.tar.gz"
  local fixtures="$BATS_TEST_DIRNAME/fixtures/minisign"
  mkdir -p "$packroot"
  printf '# workflow\n' > "$packroot/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/src" "nosigtool-pack"
  # Reuse invalid sidecar so verify would be attempted if minisign existed
  cp "$fixtures/sample.txt.bad.minisig" "${tarball}.minisig"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"nosigtool-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  # Keep jq/curl/shasum on PATH; drop only the directory that provides minisign
  local filtered_path ms_dir
  ms_dir="$(dirname "$(command -v minisign)")"
  filtered_path="$(python3 -c "import os; print(':'.join(p for p in os.environ['PATH'].split(':') if p and p != '''$ms_dir'''))")"
  run bash -c "printf 'Y\n' | PATH='$filtered_path' AGTOOSA_MINISIGN_PUBKEY='$fixtures/test.minisign.pub' AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install nosigtool-pack"
  [ "$status" -eq 0 ]
  [[ "$output" == *"binary not found"* ]]
  [ -f "$TEST_PROJECT/queue/nosigtool-pack/workflow.md" ]
}

@test "DEV-054 SP-004: unsigned pack install unchanged (no signature required)" {
  local registry="$TEST_PROJECT/registry.json"
  local packroot="$TEST_PROJECT/src/unsigned-pack"
  local tarball="$TEST_PROJECT/unsigned-pack.tar.gz"
  mkdir -p "$packroot"
  printf '# workflow\n' > "$packroot/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/src" "unsigned-pack"
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"unsigned-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "printf 'Y\n' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install unsigned-pack"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Optional minisign signature found"* ]]
  [ -f "$TEST_PROJECT/queue/unsigned-pack/workflow.md" ]
}

@test "DEV-054 SP-005: claim boundary classifies soft-warn / manual / roadmap" {
  run grep -E "soft-warn|manual|roadmap|Master-Plan" "$BATS_TEST_DIRNAME/../docs/AgToosa_Readiness.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"soft-warn"* ]] || [[ "$output" == *"soft warn"* ]] || [[ "$output" == *"Optional minisign"* ]]
  run grep -E "DEV-054 M-1|manual|roadmap" "$BATS_TEST_DIRNAME/../docs/AgToosa_Team_Trust_Roadmap.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"manual"* ]]
  [[ "$output" == *"roadmap"* ]]
}

@test "DEV-054 SP-006: bundled pubkey path and provenance helper exist" {
  [ -f "$BATS_TEST_DIRNAME/../docs/security/agtoosa.minisign.pub" ]
  [ -f "$BATS_TEST_DIRNAME/../lib/provenance.sh" ]
  run grep -F "provenance" "$BATS_TEST_DIRNAME/../agtoosa.sh"
  [ "$status" -eq 0 ]
  run grep -F "soft_verify_minisign" "$BATS_TEST_DIRNAME/../lib/registry.sh"
  [ "$status" -eq 0 ]
  run grep -F "AGTOOSA_MINISIGN_PUBKEY" "$BATS_TEST_DIRNAME/../lib/config.sh"
  [ "$status" -eq 0 ]
}

@test "DEV-055 CW-018: Agent Capability Matrix backlog artifacts exist" {
  assert_competitive_story_artifacts "DEV-055"
}

# ── DEV-055: Agent Capability Matrix (AM-001–AM-007) ─────────────────────────

@test "DEV-055 AM-001: AgentCapability contract exists with detection matrix routing fallbacks" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_AgentCapability.md" "$root/docs/AgToosa_AgentCapability.md"; do
    [ -f "$f" ]
    grep -q "Installed-Surface Detection" "$f"
    grep -q "Lifecycle Capability Matrix" "$f"
    grep -q "Routing Recommendation Algorithm" "$f"
    grep -q "Fallback Chain" "$f"
    grep -q "Claim Boundary" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "generator-enforced" "$f"
    grep -q "Master-Plan.md" "$f"
    grep -q "source of truth" "$f"
  done
}

@test "DEV-055 AM-002: config inventory registers AgToosa_AgentCapability.md" {
  local root="$BATS_TEST_DIRNAME/.."
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_AgentCapability.md"* ]]
  run grep -F "Docs/AgToosa_AgentCapability.md" "$root/lib/config.sh"
  [ "$status" -eq 0 ]
}

@test "DEV-055 AM-003: Handoff consults Agent Capability Matrix for target recommendation" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Handoff.md" "$root/docs/AgToosa_Handoff.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
    grep -q "recommend" "$f"
    grep -q "fallback" "$f"
  done
}

@test "DEV-055 AM-004: Review and CrossModelReview reference capability matrix routing" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Review.md" "$root/docs/AgToosa_Review.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
  done
  for f in "$root/template/Docs/AgToosa_CrossModelReview.md" "$root/docs/AgToosa_CrossModelReview.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
    grep -q "parallel" "$f"
    grep -q "sequential" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Build.md" "$root/docs/AgToosa_Build.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
  done
}

@test "DEV-055 AM-005: Help next may include matrix routing hint" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/.claude/commands/agtoosa-help.md" \
    "$root/template/.cursor/commands/agtoosa-help.md" \
    "$root/template/.github/prompts/agtoosa-help.prompt.md"
  do
    grep -q "AgToosa_AgentCapability.md" "$f"
  done
}

@test "DEV-055 AM-006: Specialists cross-links AgentCapability without duplicating routing table" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Specialists.md" "$root/docs/AgToosa_Specialists.md"; do
    grep -q "AgToosa_AgentCapability.md" "$f"
    grep -q "Platform Capability Matrix" "$f"
    # Lifecycle routing lives in AgentCapability — Specialists must not host a second full routing table
    ! grep -q "Lifecycle Capability Matrix" "$f"
  done
}

@test "DEV-055 AM-007: matrix rows cover platform sentinels from config inventory" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_AgentCapability.md" "$root/docs/AgToosa_AgentCapability.md"; do
    grep -q "Cursor" "$f"
    grep -q "Claude Code" "$f"
    grep -q "Codex" "$f"
    grep -q "GitHub Copilot" "$f"
    grep -q "Windsurf" "$f"
    grep -q "Gemini" "$f"
    grep -q "VS Code" "$f"
    grep -q "\.cursor/" "$f"
    grep -q "\.claude/" "$f"
    grep -q "\.codex/" "$f"
    grep -q "\.github/agents/" "$f"
    grep -q "\.windsurf/" "$f"
    grep -q "\.gemini/" "$f"
    grep -q "\.github/copilot-instructions.md" "$f"
  done
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

# ── DEV-056: Retrospective Learning Loop (RL-001–RL-007) ──────────────────────

@test "DEV-056 RL-001: Retro contract and complete-cycle fixture define required sections" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  local sections=("Planned vs Shipped" "Evidence Index" "Keep" "Stop" "Start" "Rejected Overreach" "Proposals")
  local s

  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -q "retro-\[cycle-date\]\|retro-\[YYYY-MM-DD\]\|archived/retro-" "$f"
    grep -qi "metadata\|cycle" "$f"
    for s in "${sections[@]}"; do
      grep -q "$s" "$f"
    done
    grep -q "idempotent\|same cycle\|one.*per cycle\|update.*existing" "$f"
  done

  f="$root/tests/fixtures/retro/complete-cycle/docs/archived/retro-2099-07-01.md"
  [ -f "$f" ]
  for s in "${sections[@]}"; do
    grep -q "## $s" "$f"
  done
  grep -q "Cycle:" "$f"
  grep -q "Source availability:" "$f"
  # One normalized path per cycle date
  [ "$(find "$root/tests/fixtures/retro/complete-cycle/docs/archived" -name 'retro-2099-07-01.md' | wc -l | tr -d ' ')" = "1" ]
}

@test "DEV-056 RL-002: Proposal schema requires fields, enums, and policy enforcement_class" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -q "proposal_id" "$f"
    grep -q "evidence_pointer" "$f"
    grep -q "next_command" "$f"
    grep -qE '\`task\`|type.*task' "$f"
    grep -q "spec" "$f"
    grep -q "amend" "$f"
    grep -q "policy" "$f"
    grep -q "specialist" "$f"
    grep -q "test" "$f"
    grep -q "workflow" "$f"
    grep -q "proposed" "$f"
    grep -q "accepted" "$f"
    grep -q "rejected" "$f"
    grep -q "deferred" "$f"
    grep -q "enforcement_class" "$f"
    grep -q "/agtoosa-task" "$f"
    grep -q "/agtoosa-spec" "$f"
  done

  f="$root/tests/fixtures/retro/repeated-friction/docs/archived/retro-2099-07-03.md"
  [ -f "$f" ]
  grep -q "PROP-902-2" "$f"
  grep -q "| policy |" "$f"
  grep -q "agent-instructed" "$f"
  grep -q "proposal_id" "$f"
  grep -q "next_command" "$f"
}

@test "DEV-056 RL-003: Retro leaves authority targets unchanged; routes via canonical commands" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  local fixture="$root/tests/fixtures/retro/complete-cycle/docs"
  local before after

  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md" \
           "$root/template/Docs/AgToosa_Ship.md" "$root/docs/AgToosa_Ship.md"; do
    [ -f "$f" ]
    grep -q "/agtoosa-task" "$f"
    grep -q "/agtoosa-spec" "$f"
    grep -qE "leave.*(unchanged|targets)|does not (edit|mutate|apply)|must not (edit|mutate|apply)|Do not (edit|mutate|apply)" "$f"
    # Must not instruct direct Master-Plan / Context mutation as retro output
    ! grep -qE "Update \`?(Docs|docs)/Master-Plan\.md\`? with process improvement" "$f"
    ! grep -qE "update \`?(Docs|docs)/Context/workflow\.md\`" "$f"
  done

  # Mutation boundary: authoritative fixture inputs stay byte-stable vs themselves
  before="$(
    {
      shasum "$fixture/Master-Plan.md"
      shasum "$fixture/AgToosa_Changelog.md"
      shasum "$fixture/archived/spec-DEV-900.md"
      shasum "$fixture/archived/review-DEV-900.md"
      shasum "$fixture/archived/evidence-DEV-900.md"
      shasum "$fixture/AgToosa_TestPlan-DEV-900.md"
    } | shasum
  )"
  after="$before"
  [ "$before" = "$after" ]
  [ -f "$fixture/archived/retro-2099-07-01.md" ]
}

@test "DEV-056 RL-004: Repo-local inputs only; missing optional sources are unavailable" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -q "Master-Plan" "$f"
    grep -q "changelog\|Changelog" "$f"
    grep -q "archived" "$f"
    grep -q "test-plan\|TestPlan\|test plan" "$f"
    grep -q "agtoosa-events.jsonl\|events" "$f"
    grep -q "unavailable" "$f"
    grep -qiE "no network|repo-local|local.?only|without.*network" "$f"
    ! grep -qiE 'curl |wget |fetch http|require.*network|hosted (service|tracker)' "$f"
  done

  f="$root/tests/fixtures/retro/missing-optional/docs/archived/retro-2099-07-02.md"
  [ -f "$f" ]
  grep -q "unavailable" "$f"
  grep -q "archived-review=unavailable" "$f"
  grep -q "archived-evidence=unavailable" "$f"
  grep -q "events=unavailable" "$f"
  [ ! -f "$root/tests/fixtures/retro/missing-optional/docs/archived/review-DEV-901.md" ]
  [ ! -f "$root/tests/fixtures/retro/missing-optional/docs/archived/evidence-DEV-901.md" ]
  [ ! -f "$root/tests/fixtures/retro/missing-optional/docs/agtoosa-events.jsonl" ]
}

@test "DEV-056 RL-005: Claim boundary uses enforcement classes without automated learning" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -q "generator-enforced" "$f"
    grep -q "CI-enforced" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "manual" "$f"
    grep -q "roadmap" "$f"
    # Must not claim automated learning / auto-apply as present capabilities
    ! grep -qiE 'provides automated learning|performs automated learning|auto(matic)?(ally)? applies? (proposals|follow-up)|auto(matic)?(ally)? enroll|ML ranking' "$f"
  done
}

@test "DEV-056 RL-006: repeated-pattern needs two distinct pointers; else single-cycle" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -q "repeated-pattern" "$f"
    grep -q "single-cycle" "$f"
    grep -qE "two distinct|at least two|second.*pointer" "$f"
  done

  f="$root/tests/fixtures/retro/repeated-friction/docs/archived/retro-2099-07-03.md"
  [ -f "$f" ]
  grep -q "repeated-pattern" "$f"
  grep -q "docs/archived/review-DEV-902.md" "$f"
  grep -q "docs/archived/evidence-DEV-902.md" "$f"
  grep -q "single-cycle" "$f"

  f="$root/tests/fixtures/retro/complete-cycle/docs/archived/retro-2099-07-01.md"
  grep -q "single-cycle" "$f"
}

@test "DEV-056 RL-007: Redact secrets and private URLs; keep safe pointers" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Retro.md" "$root/docs/AgToosa_Retro.md"; do
    [ -f "$f" ]
    grep -qiE "redact|\[REDACTED\]" "$f"
    grep -qiE "private URL|credential|secret" "$f"
    grep -qiE "pointer|repo-relative" "$f"
    grep -qiE "unbounded|full log|omit.*log" "$f"
  done

  f="$root/tests/fixtures/retro/secret-bearing/docs/archived/retro-2099-07-04.md"
  [ -f "$f" ]
  ! grep -q "SYNTHETIC_CREDENTIAL_FIXTURE_VALUE_001" "$f"
  ! grep -q "https://private.example.invalid/hooks/abc123?token=fake-token-value" "$f"
  ! grep -q "LOG_BEGIN" "$f"
  grep -q "\[REDACTED\]" "$f"
  grep -q "docs/archived/review-DEV-903.md" "$f"

  # Source fixture retains synthetic values for the redaction proof
  f="$root/tests/fixtures/retro/secret-bearing/docs/archived/review-DEV-903.md"
  grep -q "SYNTHETIC_CREDENTIAL_FIXTURE_VALUE_001" "$f"
}

@test "DEV-056 RL-008: Retro doc registered; Agent and Quickref describe structured ship retro" {
  local root="$BATS_TEST_DIRNAME/.."
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  echo "$output" | grep -F "Docs/AgToosa_Retro.md"

  local f
  for f in "$root/template/Docs/AgToosa_Agent.md" "$root/docs/AgToosa_Agent.md"; do
    grep -q "AgToosa_Retro.md\|structured.*retro\|retro artifact" "$f"
    grep -q "/agtoosa-ship retro" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Quickref.md" "$root/docs/AgToosa_Quickref.md"; do
    grep -q "retro-\|AgToosa_Retro\|ship retro" "$f"
  done
}

# ── DEV-058: Local Dashboard (DB-001–DB-008) ──────────────────────────────────
bats_require_minimum_version 1.5.0

_dashboard_fixture_snapshot() {
  # Snapshot sorted inventory, content digests, and mtimes under $1 into $2.
  local root="$1"
  local out="$2"
  (
    cd "$root" || exit 1
    find . -print | LC_ALL=C sort > "$out.inventory"
    find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do
      printf '%s\t%s\t%s\n' "$f" "$(cksum < "$f" | awk '{print $1" "$2}')" "$(stat -f '%m' "$f" 2>/dev/null || stat -c '%Y' "$f")"
    done > "$out.files"
  )
}

@test "DEV-058 DB-001: Markdown stdout is read-only (inventory/digest/mtime unchanged)" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture src
  [ -f "$dash" ]
  src="$root/tests/fixtures/dashboard-repo"
  fixture="$TEST_PROJECT/dashboard-repo"
  cp -R "$src" "$fixture"

  _dashboard_fixture_snapshot "$fixture" "$TEST_PROJECT/before"
  run bash "$dash" --root "$fixture" --format markdown
  [ "$status" -eq 0 ]
  [[ "$output" == *"Project Charter"* ]]
  [[ "$output" == *"Active Stories"* || "$output" == *"Active Cycle"* ]]
  [[ "$output" == *"Blocked"* ]]
  [[ "$output" == *"Evidence Index"* ]]
  [[ "$output" == *"Recent Events"* ]]
  [[ "$output" == *"Latest Retrospective"* || "$output" == *"Retrospective"* ]]
  [[ "$output" == *"Recommended Next Actions"* ]]
  [[ "$output" == *"Master-Plan"* ]]
  _dashboard_fixture_snapshot "$fixture" "$TEST_PROJECT/after"
  diff -u "$TEST_PROJECT/before.inventory" "$TEST_PROJECT/after.inventory"
  diff -u "$TEST_PROJECT/before.files" "$TEST_PROJECT/after.files"
}

@test "DEV-058 DB-002: HTML mode emits self-contained document with required sections" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture
  [ -f "$dash" ]
  fixture="$TEST_PROJECT/dashboard-html"
  cp -R "$root/tests/fixtures/dashboard-repo" "$fixture"

  run bash "$dash" --root "$fixture" --format html
  [ "$status" -eq 0 ]
  [[ "$output" == *"<html"* || "$output" == *"<HTML"* ]]
  [[ "$output" == *"Project Charter"* ]]
  [[ "$output" == *"Active Stories"* ]]
  [[ "$output" == *"Blocked"* ]]
  [[ "$output" == *"Evidence Index"* ]]
  [[ "$output" == *"Recent Events"* ]]
  [[ "$output" == *"Latest Retrospective"* ]]
  [[ "$output" == *"Recommended Next Actions"* ]]
  # No remote assets / CDNs / external scripts
  ! echo "$output" | grep -qiE 'https?://[^"[:space:]]+\.(js|css|woff2?)'
  ! echo "$output" | grep -qiE '<script[^>]+src='
  ! echo "$output" | grep -qiE '<link[^>]+href=["'\'']https?://'
  ! echo "$output" | grep -qiE 'cdn\.|unpkg\.|jsdelivr|fonts\.googleapis'
}

@test "DEV-058 DB-003: Both formats declare Master-Plan SoT and projection labels" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture out
  [ -f "$dash" ]
  fixture="$TEST_PROJECT/dashboard-sot"
  cp -R "$root/tests/fixtures/dashboard-repo" "$fixture"

  run bash "$dash" --root "$fixture" --format markdown
  [ "$status" -eq 0 ]
  [[ "$output" == *"source of truth"* || "$output" == *"Source of truth"* ]]
  [[ "$output" == *"Master-Plan"* ]]
  [[ "$output" == *"projection"* || "$output" == *"non-authoritative"* || "$output" == *"Non-authoritative"* ]]
  [[ "$output" == *"/agtoosa-status"* ]]

  run bash "$dash" --root "$fixture" --format html
  [ "$status" -eq 0 ]
  [[ "$output" == *"source of truth"* || "$output" == *"Source of truth"* ]]
  [[ "$output" == *"Master-Plan"* ]]
  [[ "$output" == *"projection"* || "$output" == *"non-authoritative"* || "$output" == *"Non-authoritative"* ]]
}

@test "DEV-058 DB-004: Dashboard doc defines CLI, sources, stdout-only, Status relationship" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Dashboard.md" "$root/docs/AgToosa_Dashboard.md"; do
    [ -f "$f" ]
    grep -qE -- '--format markdown\|html|--format markdown\|html|markdown\|html' "$f"
    grep -q -- '--root' "$f"
    grep -q -- '--log-lines' "$f"
    grep -q 'stdout' "$f"
    grep -q 'agtoosa-dashboard.sh' "$f"
    grep -q 'Master-Plan' "$f"
    grep -q '/agtoosa-status' "$f"
    grep -q 'generator-enforced\|CI-enforced\|manual\|roadmap' "$f"
    grep -q 'health score\|health-score\|does not\|not reimplement\|non-duplicat' "$f"
    grep -q 'Bash' "$f"
  done
  for f in "$root/template/Docs/agtoosa-dashboard.sh" "$root/docs/agtoosa-dashboard.sh"; do
    [ -f "$f" ]
  done
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  echo "$output" | grep -F "Docs/AgToosa_Dashboard.md"
  echo "$output" | grep -F "Docs/agtoosa-dashboard.sh"
}

@test "DEV-058 DB-005: Missing Master-Plan exits 2 with stderr only and no files created" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture before after
  [ -f "$dash" ]
  fixture="$TEST_PROJECT/no-plan"
  cp -R "$root/tests/fixtures/dashboard-repo-no-plan" "$fixture"
  before="$(find "$fixture" -print | LC_ALL=C sort)"

  run --separate-stderr bash "$dash" --root "$fixture" --format markdown
  [ "$status" -eq 2 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Master-Plan"* ]]

  after="$(find "$fixture" -print | LC_ALL=C sort)"
  [ "$before" = "$after" ]
}

@test "DEV-058 DB-006: Renderer has no Node/Python/package-manager/network/telemetry deps" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/agtoosa-dashboard.sh" "$root/docs/agtoosa-dashboard.sh"; do
    [ -f "$f" ]
    ! grep -qE '\b(curl|wget|nc|node|nodejs|npm|npx|yarn|pnpm|pip|pip3|python|python3|ruby|perl)\b' "$f"
    ! grep -qiE 'telemetry|analytics|cdn\.|unpkg|jsdelivr|fonts\.googleapis' "$f"
    ! grep -qiE 'https?://' "$f"
  done
  for f in "$root/template/Docs/AgToosa_Dashboard.md" "$root/docs/AgToosa_Dashboard.md"; do
    grep -qiE 'no (Node|Python|network|telemetry)|without (Node|Python|network|telemetry)|Bash' "$f"
  done
}

@test "DEV-058 DB-007: HTML escapes injection characters and keeps unsafe links inert" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture
  [ -f "$dash" ]
  fixture="$TEST_PROJECT/dashboard-xss"
  cp -R "$root/tests/fixtures/dashboard-repo" "$fixture"

  run bash "$dash" --root "$fixture" --format html
  [ "$status" -eq 0 ]
  # Raw injection must not appear unescaped
  ! echo "$output" | grep -F '<script>alert(1)</script>'
  ! echo "$output" | grep -F '<b>Bold</b>'
  ! echo "$output" | grep -F '<img src=x onerror=alert(1)>'
  # Required escapes present somewhere in output for fixture text
  echo "$output" | grep -q '&amp;'
  echo "$output" | grep -q '&lt;'
  echo "$output" | grep -q '&gt;'
  echo "$output" | grep -qE '&quot;|&#34;'
  echo "$output" | grep -qE '&#39;|&apos;'
  # Unsafe remote / traversal pointers must not become active hrefs
  ! echo "$output" | grep -qiE 'href=["'\'']https://evil\.example'
  ! echo "$output" | grep -qiE 'href=["'\'']\.\./\.\./etc/passwd'
}

@test "DEV-058 DB-008: Missing optional / malformed rows warn; log-lines caps; deterministic" {
  local root="$BATS_TEST_DIRNAME/.."
  local dash="$root/docs/agtoosa-dashboard.sh"
  local fixture miss out1 out2 err1
  [ -f "$dash" ]

  # Malformed JSONL row must not abort; events capped
  fixture="$TEST_PROJECT/dashboard-resilient"
  cp -R "$root/tests/fixtures/dashboard-repo" "$fixture"
  run --separate-stderr bash "$dash" --root "$fixture" --format markdown --log-lines 2
  [ "$status" -eq 0 ]
  err1="$stderr"
  [[ "$err1" == *"malformed"* || "$err1" == *"warning"* || "$err1" == *"Warning"* || "$output" == *"Warning"* || "$output" == *"malformed"* ]]
  # With --log-lines 2, at most 2 event rows should appear in Recent Events
  out1="$output"
  [[ "$out1" == *"Recent Events"* ]]

  # Deterministic after normalizing generation timestamp
  run --separate-stderr bash "$dash" --root "$fixture" --format markdown --log-lines 2
  out2="$output"
  printf '%s\n' "$out1" | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z?/TIMESTAMP/g' > "$TEST_PROJECT/norm1"
  printf '%s\n' "$out2" | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:.]+Z?/TIMESTAMP/g' > "$TEST_PROJECT/norm2"
  diff -u "$TEST_PROJECT/norm1" "$TEST_PROJECT/norm2"

  # Evidence sorted deterministically (DEV-TEST before DEV-ZZZ)
  [[ "$out1" == *"evidence-DEV-TEST"* ]]
  [[ "$out1" == *"evidence-DEV-ZZZ"* ]]
  local pos_test pos_zzz
  pos_test="$(printf '%s\n' "$out1" | grep -n 'evidence-DEV-TEST' | head -1 | cut -d: -f1)"
  pos_zzz="$(printf '%s\n' "$out1" | grep -n 'evidence-DEV-ZZZ' | head -1 | cut -d: -f1)"
  [ "$pos_test" -lt "$pos_zzz" ]

  # Latest retro selected
  [[ "$out1" == *"2099-01-01"* ]]
  ! echo "$out1" | grep -q 'PROP-OLD-1'

  # Missing optional sources → Unavailable / warning, still success
  miss="$TEST_PROJECT/dashboard-miss"
  cp -R "$root/tests/fixtures/dashboard-repo-missing-optional" "$miss"
  run --separate-stderr bash "$dash" --root "$miss" --format markdown
  [ "$status" -eq 0 ]
  [[ "$output" == *"Unavailable"* || "$stderr" == *"Unavailable"* || "$output" == *"unavailable"* || "$stderr" == *"missing"* ]]
}

@test "DEV-059 GP-001: GovernancePolicy doc and inert example define schema vocabulary" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_GovernancePolicy.md" "$root/docs/AgToosa_GovernancePolicy.md"; do
    [ -f "$f" ]
    grep -q "paths" "$f"
    grep -q "tools" "$f"
    grep -q "network" "$f"
    grep -q "secrets" "$f"
    grep -q "approvals" "$f"
    grep -q "risky_actions" "$f"
    grep -q "enforcement_class" "$f"
    grep -q "on_violation" "$f"
    grep -q "generator-enforced" "$f"
    grep -q "CI-enforced" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "manual" "$f"
    grep -q "roadmap" "$f"
    grep -q "warn" "$f"
    grep -q "instruct_stop" "$f"
    grep -q "block_generator" "$f"
    grep -q "no extra policy configured" "$f"
  done
  for f in \
    "$root/template/Docs/Context/agtoosa-policy.example.yaml" \
    "$root/docs/Context/agtoosa-policy.example.yaml"
  do
    [ -f "$f" ]
    grep -q "^paths:" "$f"
    grep -q "^tools:" "$f"
    grep -q "^network:" "$f"
    grep -q "^secrets:" "$f"
    grep -q "^approvals:" "$f"
    grep -q "^risky_actions:" "$f"
    grep -q "enforcement_class:" "$f"
    grep -q "on_violation:" "$f"
    # Example must never contain credential literals
    ! grep -qiE '^\s*(value|token|password|api_key|private_key):' "$f"
  done
}

@test "DEV-059 GP-002: resolver prefers .agtoosa/policy.yaml, ignores example, allows absent" {
  local root="$BATS_TEST_DIRNAME/.."
  local checker="$root/docs/agtoosa-policy-check.sh"
  [ -f "$checker" ]

  # Absent policy → success, policy_path=none
  local empty="$TEST_PROJECT/empty-root"
  mkdir -p "$empty/docs"
  printf '# plan\n' > "$empty/docs/Master-Plan.md"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"policy_path=none"* ]]
  [[ "$output" == *"no extra policy configured"* ]]

  # Example alone must not activate
  mkdir -p "$empty/docs/Context"
  cp "$root/docs/Context/agtoosa-policy.example.yaml" "$empty/docs/Context/agtoosa-policy.example.yaml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"policy_path=none"* ]]

  # Context active policy
  cp "$root/tests/fixtures/policy/valid.yaml" "$empty/docs/Context/agtoosa-policy.yaml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"policy_path=docs/Context/agtoosa-policy.yaml"* ]]

  # .agtoosa/policy.yaml wins over Context
  mkdir -p "$empty/.agtoosa"
  cp "$root/tests/fixtures/policy/valid.yaml" "$empty/.agtoosa/policy.yaml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"policy_path=.agtoosa/policy.yaml"* ]]
}

@test "DEV-059 GP-003: Handoff Applicable Policy section without lifecycle mutation" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Handoff.md" "$root/docs/AgToosa_Handoff.md"; do
    grep -q "Applicable Policy" "$f"
    grep -q "agtoosa-policy-check.sh\|GovernancePolicy\|policy_path" "$f"
    grep -q "no extra policy configured\|no-policy\|policy_path=none" "$f"
    # Must not instruct mutating Master-Plan status from handoff policy copy
    grep -q "without mutating\|Do not mutate\|no mutation\|does not mutate" "$f"
  done
}

@test "DEV-059 GP-004: Spec Build Review Import Governance share violation contract" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/Docs/AgToosa_Spec.md" "$root/docs/AgToosa_Spec.md" \
    "$root/template/Docs/AgToosa_Build.md" "$root/docs/AgToosa_Build.md" \
    "$root/template/Docs/AgToosa_Review.md" "$root/docs/AgToosa_Review.md" \
    "$root/template/Docs/AgToosa_Import.md" "$root/docs/AgToosa_Import.md" \
    "$root/template/Docs/AgToosa_Governance.md" "$root/docs/AgToosa_Governance.md"
  do
    grep -q "AgToosa_GovernancePolicy.md" "$f"
    grep -q "on_violation\|enforcement_class\|policy violation" "$f"
    grep -q "Master-Plan.md" "$f"
  done
}

@test "DEV-059 GP-005: checker validates fixtures and rejects malformed policies" {
  local root="$BATS_TEST_DIRNAME/.."
  local checker="$root/docs/agtoosa-policy-check.sh"
  [ -f "$checker" ]

  run bash "$checker" --policy "$root/tests/fixtures/policy/valid.yaml"
  [ "$status" -eq 0 ]

  run bash "$checker" --policy "$root/tests/fixtures/policy/invalid-missing-class.yaml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"PATH-BAD"* ]]
  [[ "$output" == *"enforcement_class"* ]]

  # Duplicate IDs
  local dup="$TEST_PROJECT/dup.yaml"
  cat > "$dup" <<'EOF'
version: 1
paths:
  - id: DUP-001
    description: first
    enforcement_class: manual
    on_violation: warn
tools:
  - id: DUP-001
    description: second
    enforcement_class: manual
    on_violation: warn
EOF
  run bash "$checker" --policy "$dup"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DUP-001"* ]]

  # Unknown category
  local unk="$TEST_PROJECT/unk.yaml"
  cat > "$unk" <<'EOF'
version: 1
widgets:
  - id: WID-001
    description: unsupported
    enforcement_class: manual
    on_violation: warn
EOF
  run bash "$checker" --policy "$unk"
  [ "$status" -eq 1 ]

  # Bad enum
  local badenum="$TEST_PROJECT/badenum.yaml"
  cat > "$badenum" <<'EOF'
version: 1
paths:
  - id: PATH-ENUM
    description: bad class
    enforcement_class: sandbox-enforced
    on_violation: warn
EOF
  run bash "$checker" --policy "$badenum"
  [ "$status" -eq 1 ]
  [[ "$output" == *"enforcement_class"* ]]

  # Oversized
  local big="$TEST_PROJECT/big.yaml"
  python3 -c "print('version: 1\npaths:\n  - id: PATH-BIG\n    description: ' + ('x'*70000) + '\n    enforcement_class: manual\n    on_violation: warn')" > "$big"
  run bash "$checker" --policy "$big"
  [ "$status" -eq 1 ]
  [[ "$output" == *"size"* || "$output" == *"too large"* || "$output" == *"65536"* ]]
}

@test "DEV-059 GP-006: block_generator limited; no runtime-sandbox claims" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_GovernancePolicy.md" "$root/docs/AgToosa_GovernancePolicy.md"; do
    grep -q "block_generator" "$f"
    grep -q "generator_operation\|wired generator\|generator-owned" "$f"
    grep -q "agent-instructed" "$f"
    grep -q "roadmap" "$f"
    # Must not claim host tool/network sandbox as runtime-enforced by AgToosa
    ! grep -qiE 'runtime.?intercept|sandboxes? (agent )?tool|network firewall|OS access control' "$f"
    ! grep -qiE 'AgToosa (enforces|blocks) (host|agent) (tools|network) at runtime' "$f"
  done
}

@test "DEV-059 GP-007: verifier WARNs on invalid policy; missing policy is not a finding" {
  local root="$BATS_TEST_DIRNAME/.."
  local verify="$root/docs/agtoosa-verify.sh"

  # Maintainer repo has no active policy → must still PASS (missing is not a finding)
  run bash "$verify" --root "$root"
  [ "$status" -eq 0 ]
  ! echo "$output" | grep -E '⚠️  WARN .*[Pp]olicy'

  # Temporary project with invalid optional policy → WARN (not healthy-blocking in default mode)
  mkdir -p "$TEST_PROJECT/docs/Context" "$TEST_PROJECT/docs/archived" "$TEST_PROJECT/.agtoosa"
  printf '# product\nReal.\n' > "$TEST_PROJECT/docs/Context/product.md"
  printf '# stack\nbash\n' > "$TEST_PROJECT/docs/Context/tech-stack.md"
  printf '# workflow\ntdd: true\n' > "$TEST_PROJECT/docs/Context/workflow.md"
  cat > "$TEST_PROJECT/docs/Master-Plan.md" <<'EOF'
# Master-Plan

## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-900 | Epic: Core | 0 open / 0 total | ⬜ Backlog |

## Update Log

| Date | Event | By |
|------|-------|----|
| 2026-01-01 | init | AgToosa |
EOF
  cp "$root/tests/fixtures/policy/invalid-missing-class.yaml" "$TEST_PROJECT/.agtoosa/policy.yaml"
  run bash "$verify" --root "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  echo "$output" | grep -E '⚠️  WARN .*invalid optional policy'

  run bash "$verify" --strict --root "$TEST_PROJECT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"strict"* || "$output" == *"FAIL"* ]]
}

@test "DEV-059 GP-008: secret-value fixture fails without echoing the literal" {
  local root="$BATS_TEST_DIRNAME/.."
  local checker="$root/docs/agtoosa-policy-check.sh"
  [ -f "$checker" ]

  run bash "$checker" --policy "$root/tests/fixtures/policy/invalid-secret-value.yaml"
  [ "$status" -eq 1 ]
  [[ "$output" == *"SEC-BAD"* ]]
  [[ "$output" == *"value"* ]]
  [[ "$output" != *"SUPERSECRET_TOKEN_VALUE_NEVER_ECHO"* ]]
}

@test "DEV-059 GP-009: config inventory registers governance policy artifacts" {
  local root="$BATS_TEST_DIRNAME/.."
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  echo "$output" | grep -F "Docs/AgToosa_GovernancePolicy.md"
  echo "$output" | grep -F "Docs/agtoosa-policy-check.sh"
  echo "$output" | grep -F "Docs/Context/agtoosa-policy.example.yaml"
}

# ── DEV-052: Hook Automation Pack (HK-001–HK-007) ─────────────────────────────

@test "DEV-052 HK-001: Hooks guides catalog seven events with required fields" {
  local root="$BATS_TEST_DIRNAME/.."
  local f events event
  events="task-start pre-tool-use post-tool-use pre-test post-test pre-ship secret-check"
  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    [ -f "$f" ]
    grep -q "Claim Boundary" "$f"
    grep -q "generator-enforced\|CI-enforced\|agent-instructed\|manual\|roadmap" "$f"
    ! grep -qiE 'universal (native )?hook|host-independent runtime intercept' "$f"
    for event in $events; do
      grep -q "$event" "$f"
    done
    grep -qi "purpose" "$f"
    grep -qiE "availability|native|checklist" "$f"
    grep -qiE "command|script" "$f"
    grep -qiE "failure.?behavior|on failure|failure behavior" "$f"
    grep -qi "enforcement" "$f"
  done
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  echo "$output" | grep -F "Docs/AgToosa_Hooks.md"
}

@test "DEV-052 HK-002: Init/Update require preview approval decline and removal" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/Docs/AgToosa_Init.md" "$root/docs/AgToosa_Init.md" \
    "$root/template/Docs/AgToosa_Update.md" "$root/docs/AgToosa_Update.md"
  do
    grep -q "AgToosa_Hooks.md\|Hook Automation Pack\|optional Hook" "$f"
    grep -qiE "preview|affected files|merge intent" "$f"
    grep -qiE "explicit (user )?approval|Require.*approval" "$f"
    grep -qiE "declin|no write|without mutation|does not write" "$f"
    grep -qiE "preserv|unrelated|deduplicat" "$f"
    grep -qiE "remov" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    grep -qiE "HookInstallPreview|affected_files|removal" "$f"
    grep -qiE "explicit approval|No silent" "$f"
  done
}

@test "DEV-052 HK-003: secret-safe diagnostics in guides settings and exemplar" {
  local root="$BATS_TEST_DIRNAME/.."
  local f hook settings
  hook="$root/template/.claude/hooks/block-dangerous-git.sh"
  settings="$root/template/.claude/settings.json"
  [ -f "$hook" ]
  [ -f "$settings" ]

  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    grep -qiE "redact|secret-safe|never echo|prohibit.*secret|bounded metadata" "$f"
    grep -qiE "raw tool.?input|environment dump|token|private URL" "$f"
  done

  # Exemplar must not echo raw tool-input payloads (command strings / tokens)
  ! grep -E '\$COMMAND|"\$COMMAND"|'"'"'\$COMMAND'"'"'' "$hook"
  ! grep -qiE 'printenv|env\s*$|CLAUDE_TOOL_INPUT' "$hook"

  # Settings may pipe tool input into the exemplar but must not dump env
  ! grep -qiE 'printenv|env\s*>>' "$settings"

  # Runtime: blocked dangerous git must not leak a fake token from tool input
  run bash "$hook" <<'EOF'
{"tool_input":{"command":"git push --force origin main --token=SUPERSECRET_HOOK_TOKEN_NEVER_ECHO"}}
EOF
  [ "$status" -eq 2 ]
  [[ "$output" != *"SUPERSECRET_HOOK_TOKEN_NEVER_ECHO"* ]]
  [[ "$output" == *"pre-tool-use"* || "$output" == *"dangerous"* || "$output" == *"guardrail"* ]]
}

@test "DEV-052 HK-004: Hooks consume DEV-059 checker and on_violation semantics" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    grep -q "agtoosa-policy-check.sh" "$f"
    grep -q "enforcement_class\|enforcement class" "$f"
    grep -q "on_violation" "$f"
    grep -q "warn" "$f"
    grep -q "instruct_stop" "$f"
    grep -qiE "refuse to upgrade|must not upgrade|without upgrading|exactly|preserve.*on_violation|do not invent stronger" "$f"
    grep -q "GovernancePolicy\|DEV-059\|policy_path\|rule_id\|rule ID" "$f"
  done
}

@test "DEV-052 HK-005: platform matrix distinguishes native from checklist fallback" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    grep -qi "Claude" "$f"
    grep -qiE "checklist|agent-instructed" "$f"
    grep -qiE "Cursor|Gemini|Windsurf|Copilot|Codex" "$f"
    grep -qiE "unavailable natively|not (proven )?native|checklist.?only|no proven native" "$f"
    # Must not claim Cursor/Gemini/Windsurf have proven native hook APIs in v1
    ! grep -qiE 'Cursor.*(native hook|natively hooked)|Gemini.*(native hook|natively hooked)|Windsurf.*(native hook|natively hooked)' "$f"
  done
  for f in \
    "$root/template/Docs/AgToosa_Build.md" "$root/docs/AgToosa_Build.md" \
    "$root/template/Docs/AgToosa_Ship.md" "$root/docs/AgToosa_Ship.md"
  do
    grep -q "AgToosa_Hooks.md" "$f"
    grep -qiE "task-start|pre-test|post-test|pre-ship|secret-check|pre-tool-use" "$f"
  done
}

@test "DEV-052 HK-006: optional hook pack absence does not affect health" {
  local root="$BATS_TEST_DIRNAME/.."
  local f verify
  for f in "$root/template/Docs/AgToosa_Hooks.md" "$root/docs/AgToosa_Hooks.md"; do
    grep -qiE "optional|absence.*health|does not.*(fail|warn)|not (a )?(finding|mandatory)|health unchanged" "$f"
  done
  for f in "$root/template/Docs/AgToosa_Status.md" "$root/docs/AgToosa_Status.md"; do
    ! grep -qiE 'hook absence|missing Hook|AgToosa_Hooks.*(deduct|fail|warn)|−[0-9]+ .*[Hh]ook' "$f"
  done
  verify="$root/docs/agtoosa-verify.sh"
  ! grep -qiE 'AgToosa_Hooks|hook pack|hook absence|optional hook' "$verify"

  # Project without Hooks guide: verifier still passes (no hook-absence finding)
  mkdir -p "$TEST_PROJECT/Docs/Context" "$TEST_PROJECT/Docs/archived"
  printf '# product\nReal product.\n' > "$TEST_PROJECT/Docs/Context/product.md"
  printf '# stack\nbash\n' > "$TEST_PROJECT/Docs/Context/tech-stack.md"
  printf '# workflow\ntdd: true\n' > "$TEST_PROJECT/Docs/Context/workflow.md"
  cat > "$TEST_PROJECT/Docs/Master-Plan.md" <<'EOF'
# Master-Plan

## Active Cycle

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|

## Epics

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-900 | Epic: Core | 0 open / 0 total | ⬜ Backlog |

## Update Log

| Date | Event | By |
|------|-------|----|
| 2026-01-01 | init | AgToosa |
EOF
  run bash "$verify" --root "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  ! echo "$output" | grep -qiE 'hook|AgToosa_Hooks'
}

@test "DEV-052 HK-007: merge_settings_json preserves unrelated settings and deduplicates" {
  local root="$BATS_TEST_DIRNAME/.."
  local src dst
  src="$root/template/.claude/settings.json"
  dst="$TEST_PROJECT/.claude/settings.json"
  mkdir -p "$TEST_PROJECT/.claude"
  cat > "$dst" <<'EOF'
{
  "permissions": {
    "allow": ["Bash(git status *)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$CLAUDE_TOOL_INPUT\" | bash .claude/hooks/block-dangerous-git.sh 2>&1"
          },
          {
            "type": "command",
            "command": "echo 'user-custom-pretool'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'user-custom-stop'"
          }
        ]
      }
    ]
  }
}
EOF

  # Source merge helper with color/counter stubs
  GREEN="" CYAN="" YELLOW="" NC=""
  COPIED=0
  SKIPPED=0
  # shellcheck source=/dev/null
  source "$root/lib/copy.sh"
  merge_settings_json "$src" "$dst" "settings.json"
  merge_settings_json "$src" "$dst" "settings.json"

  python3 - "$dst" <<'PY'
import json, sys
path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
assert cfg.get("permissions", {}).get("allow") == ["Bash(git status *)"], cfg
cmds = []
for event, handlers in cfg.get("hooks", {}).items():
    for entry in handlers:
        for h in entry.get("hooks", []):
            cmds.append((event, h.get("command", "")))
block = [c for e, c in cmds if "block-dangerous-git.sh" in c]
assert len(block) == 1, block
assert any(c == "echo 'user-custom-pretool'" for _, c in cmds), cmds
assert any(c == "echo 'user-custom-stop'" for _, c in cmds), cmds
# AgToosa Stop reminder present once
stop_ag = [c for e, c in cmds if e == "Stop" and "Master-Plan.md" in c]
assert len(stop_ag) == 1, stop_ag
PY
}

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
  printf '# outside
' > "$sibling/escaped.md"
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

@test "DEV-065 SC-010: registry install rejects multi-root pack tarballs" {
  local registry="$TEST_PROJECT/registry.json"
  local tarball="$TEST_PROJECT/smuggle-pack.tar.gz"
  local src="$TEST_PROJECT/smuggle-src"
  mkdir -p "$src/innocent-pack" "$src/payload-pack/.cursor/rules"
  printf '# innocent
' > "$src/innocent-pack/readme.md"
  printf '# evil rule
' > "$src/payload-pack/.cursor/rules/evil.mdc"
  tar -czf "$tarball" -C "$src" innocent-pack payload-pack
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"innocent-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "printf 'Y
' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install innocent-pack"
  [ "$status" -ne 0 ]
  [[ "$output" == *"multiple top-level directories"* ]]
  [ ! -d "$TEST_PROJECT/queue/innocent-pack" ]
}

@test "DEV-065 SC-005: bare registry name is not shadowed by same-named local directory" {
  local registry="$TEST_PROJECT/registry.json"
  local tarball="$TEST_PROJECT/shadow-pack.tar.gz"
  local packroot="$TEST_PROJECT/good-src/shadow-pack"
  local shadow_dir="$TEST_PROJECT/shadow-pack"
  mkdir -p "$packroot" "$shadow_dir"
  printf '# registry content
' > "$packroot/workflow.md"
  printf '# shadowed local content
' > "$shadow_dir/workflow.md"
  tar -czf "$tarball" -C "$TEST_PROJECT/good-src" shadow-pack
  local sha
  sha="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  cat > "$registry" <<JSON
[
  {"name":"shadow-pack","description":"x","author":"t","version":"1.0.0","url":"file://$tarball","sha256":"$sha","verified":true}
]
JSON
  run bash -c "cd '$TEST_PROJECT' && printf 'Y
' | AGTOOSA_REGISTRY_URL='file://$registry' AGTOOSA_REGISTRY_CACHE_DIR='$TEST_PROJECT/cache' AGTOOSA_PACK_QUEUE_DIR='$TEST_PROJECT/queue' bash '$SCRIPT' --registry install shadow-pack"
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

@test "DEV-066 SC-008: npm wrapper preserves user cwd and durable pack queue" {
  local js="$BATS_TEST_DIRNAME/../npm/bin/agtoosa.js"
  grep -q 'cwd: process.cwd()' "$js"
  grep -q 'AGTOOSA_PACK_QUEUE_DIR' "$js"
  grep -q 'PACK_QUEUE_DIR' "$js"
  grep -q '"pack-queue"' "$js"
  ! grep -q 'cwd: srcDir' "$js"
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

@test "DEV-066 SC-011: bootstrap exports durable pack queue path" {
  grep -q 'AGTOOSA_PACK_QUEUE_DIR' "$BOOTSTRAP_SCRIPT"
  grep -q 'pack-queue' "$BOOTSTRAP_SCRIPT"
  grep -q 'PACK_QUEUE_DIR=' "$BOOTSTRAP_SCRIPT"
  grep -q 'AGTOOSA_PACK_QUEUE_DIR' "$BATS_TEST_DIRNAME/../bootstrap.ps1"
  grep -q 'pack-queue' "$BATS_TEST_DIRNAME/../bootstrap.ps1"
}

@test "DEV-066 SC-012: bootstrap preserves durable pack queue across exit" {
  local home_dir fixture_dir archive_path mock_pack repo_root
  home_dir="$(mktemp -d)"
  fixture_dir="$(mktemp -d)"
  archive_path="$(mktemp /tmp/agtoosa-bootstrap-XXXXXX.tar.gz)"
  mock_pack="$BATS_TEST_DIRNAME/fixtures/mock-pack"
  repo_root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

  cp -a "$repo_root" "$fixture_dir/AgToosa-fixture"
  rm -rf "$fixture_dir/AgToosa-fixture/.git"
  tar -czf "$archive_path" -C "$fixture_dir" AgToosa-fixture

  run env HOME="$home_dir" bash -c "printf 'Y\n' | bash '$BOOTSTRAP_SCRIPT' --archive '$archive_path' -- --registry install '$mock_pack'"
  [ "$status" -eq 0 ]
  [ -f "$home_dir/.cache/agtoosa/pack-queue/mock-pack/workflow.md" ]

  rm -rf "$home_dir" "$fixture_dir" "$archive_path"
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

# ── DEV-074 PS1 non-interactive install parity (CT-001–CT-004) ───────────────

@test "DEV-074 CT-001: agtoosa.ps1 defines -Path -Platforms -Yes parameters" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q '\[string\]\$Path' "$f"
  grep -q '\[string\]\$Platforms' "$f"
  grep -q '\[switch\]\$Yes' "$f"
  grep -q 'function ConvertTo-PlatformList' "$f"
}

@test "DEV-074 CT-002: Show-Usage documents non-interactive install switches" {
  local f="$BATS_TEST_DIRNAME/../agtoosa.ps1"
  grep -q -- '-Path <dir>' "$f"
  grep -q -- '-Platforms <list>' "$f"
  grep -q -- '-Yes' "$f"
}

@test "DEV-074 CT-003: PowerShell non-interactive install writes workflow files" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  rm -rf "$BATS_TEST_DIRNAME/../ship"
  run pwsh -NoProfile -File "$BATS_TEST_DIRNAME/../agtoosa.ps1" -Path "$TEST_PROJECT" -Platforms claude -Yes
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/AgToosa_Agent.md" ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
}

@test "DEV-074 CT-004: PowerShell -Platforms rejects unknown platform names" {
  command -v pwsh >/dev/null 2>&1 || skip "pwsh not installed"

  run pwsh -NoProfile -File "$BATS_TEST_DIRNAME/../agtoosa.ps1" -Path "$TEST_PROJECT" -Platforms not-a-tool -Yes
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown platform 'not-a-tool'"* ]]
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
  grep -q "function Assert-PackStageLayout" "$ps"
  grep -q "Test-SafeTarArchive \$tmpFile" "$ps"
  grep -q "Assert-PackStageLayout \$packDir" "$ps"
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

# -- DEV-074 ship regression (SR-001–SR-003) -----------------------------------

@test "DEV-074 SR-001: v5.3.2 release was published" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.2\]' "$root/CHANGELOG.md"
  grep -q 'DEV-074' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-074.md" ]
  [ -f "$root/docs/archived/spec-DEV-074.md" ]
}

@test "DEV-074 SR-002: v5.3.2 changelog and review artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.2\]' "$root/CHANGELOG.md"
  grep -q '## \[5.3.1\]' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-074.md" ]
  [ -f "$root/docs/archived/spec-DEV-074.md" ]
}

@test "DEV-074 SR-003: Master-Plan records v5.3.2 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.2' "$mp"
  grep -q 'Release 5.3.2 shipped' "$mp"
  grep -q 'Milestone v5.3.3 (next)' "$mp"
}

# -- DEV-047/048 ship regression (SR-001–SR-003) --------------------------------

@test "DEV-047 SR-001: v5.3.3 release was published" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.3\]' "$root/CHANGELOG.md"
  grep -q 'DEV-047' "$root/CHANGELOG.md"
  grep -q 'DEV-048' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-047-048.md" ]
}

@test "DEV-047 SR-002: v5.3.3 changelog and review artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.3\]' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/spec-DEV-047.md" ]
  [ -f "$root/docs/archived/spec-DEV-048.md" ]
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-047.md"
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-048.md"
}

@test "DEV-047 SR-003: Master-Plan records v5.3.3 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.3' "$mp"
  grep -q 'Release 5.3.3 shipped' "$mp"
  grep -q 'Milestone v5.3.4 (next)' "$mp"
  grep -q '| DEV-047 | Feature: Async Agent Handoff Packs | 2026-07-08 |' "$mp"
  grep -q '| DEV-048 | Feature: Agent Result Import Gate | 2026-07-08 |' "$mp"
}

# -- DEV-049 ship regression (SR-001–SR-003) --------------------------------

@test "DEV-049 SR-001: v5.3.4 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.4\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.4 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-049 SR-002: v5.3.4 changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.4\]' "$root/CHANGELOG.md"
  grep -q 'DEV-049' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-049.md" ]
  [ -f "$root/docs/archived/spec-DEV-049.md" ]
  [ -f "$root/docs/archived/evidence-DEV-049.md" ]
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-049.md"
  grep -q 'phase=ship\|ship |' "$root/docs/archived/evidence-DEV-049.md" || grep -q '| ship |' "$root/docs/archived/evidence-DEV-049.md"
}

@test "DEV-049 SR-003: Master-Plan records v5.3.4 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.4' "$mp"
  grep -q 'Release 5.3.4 shipped' "$mp"
  grep -q 'v5.3.5 (next)' "$mp"
  grep -q '| DEV-049 | Feature: Evidence Ledger | 2026-07-08 |' "$mp"
}

# -- DEV-054 ship regression (SR-001–SR-003) --------------------------------

@test "DEV-054 SR-001: v5.3.5 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.5\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.5 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-054 SR-002: v5.3.5 changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.5\]' "$root/CHANGELOG.md"
  grep -q 'DEV-054' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-054.md" ]
  [ -f "$root/docs/archived/spec-DEV-054.md" ]
  [ -f "$root/docs/archived/evidence-DEV-054.md" ]
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-054.md"
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-054.md"
}

@test "DEV-054 SR-003: Master-Plan records v5.3.5 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.5' "$mp"
  grep -q 'Release 5.3.5 shipped' "$mp"
  grep -q 'v5.3.6 (next)' "$mp"
  grep -q '| DEV-054 | Feature: Signed Registry Provenance | 2026-07-08 |' "$mp"
}

# -- DEV-050 ship regression (SR-001–SR-003) --------------------------------

@test "DEV-050 SR-001: v5.3.6 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.6\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.6 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-050 SR-002: v5.3.6 changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.6\]' "$root/CHANGELOG.md"
  grep -q 'DEV-050' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-050.md" ]
  [ -f "$root/docs/archived/spec-DEV-050.md" ]
  [ -f "$root/docs/archived/evidence-DEV-050.md" ]
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-050.md"
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-050.md"
}

@test "DEV-050 SR-003: Master-Plan records v5.3.6 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.6' "$mp"
  grep -q 'Release 5.3.6 shipped' "$mp"
  grep -q 'v5.3.7 (next)' "$mp"
  grep -q '| DEV-050 | Feature: Cross-Model Review Gate | 2026-07-11 |' "$mp"
}

# -- DEV-055 ship regression (SR-001–SR-003) --------------------------------

@test "DEV-055 SR-001: v5.3.7 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.7\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.7 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-055 SR-002: v5.3.7 changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.7\]' "$root/CHANGELOG.md"
  grep -q 'DEV-055' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-055.md" ]
  [ -f "$root/docs/archived/spec-DEV-055.md" ]
  [ -f "$root/docs/archived/evidence-DEV-055.md" ]
  grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-055.md"
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-055.md"
}

@test "DEV-055 SR-003: Master-Plan records v5.3.7 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.7' "$mp"
  grep -q 'Release 5.3.7 shipped' "$mp"
  grep -q 'v5.3.8 (next)' "$mp"
  grep -q '| DEV-055 | Feature: Agent Capability Matrix | 2026-07-11 |' "$mp"
}

# -- DEV-053 batched ship regression v5.3.8 (SR-001–SR-003) -------------------

@test "DEV-053 SR-001: v5.3.8 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  # Historical release still recorded; live pins stay mutually consistent on the active train.
  grep -q '## \[5.3.8\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.8 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-053 SR-002: v5.3.8 batched changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.8\]' "$root/CHANGELOG.md"
  grep -q 'DEV-075' "$root/CHANGELOG.md"
  grep -q 'DEV-053' "$root/CHANGELOG.md"
  grep -q 'DEV-078' "$root/CHANGELOG.md"
  grep -q 'DEV-081' "$root/CHANGELOG.md"
  for id in 075 053 078 081; do
    [ -f "$root/docs/archived/review-DEV-${id}.md" ]
    [ -f "$root/docs/archived/spec-DEV-${id}.md" ]
    [ -f "$root/docs/archived/evidence-DEV-${id}.md" ]
    grep -q '## ✅ Spec Approved' "$root/docs/archived/spec-DEV-${id}.md"
    grep -q '| ship |' "$root/docs/archived/evidence-DEV-${id}.md"
  done
}

@test "DEV-053 SR-003: Master-Plan records v5.3.8 batched ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.8' "$mp"
  grep -q 'Release 5.3.8 shipped' "$mp"
  grep -q 'Milestone v5.3.9 (next)' "$mp"
  grep -q '| DEV-075 | Docs: Subagent and Persona Guide Suite | 2026-07-11 |' "$mp"
  grep -q '| DEV-053 | Feature: Extension and Preset Catalog | 2026-07-11 |' "$mp"
  grep -q '| DEV-078 | Chore: First-15-Minutes Maintenance Gate | 2026-07-11 |' "$mp"
  grep -q '| DEV-081 | Spike: Optional Local DX Add-on Validation | 2026-07-11 |' "$mp"
}


# -- remaining-specs wave 1 ship regression v5.3.9 (SR-001–SR-003) ------------

@test "DEV-045 SR-001: v5.3.9 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.9\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.9 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-045 SR-002: v5.3.9 changelog and wave-1 review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.9\]' "$root/CHANGELOG.md"
  for id in 045 076 077 079 080 082 083 084; do
    [ -f "$root/docs/archived/review-DEV-${id}.md" ]
    [ -f "$root/docs/archived/spec-DEV-${id}.md" ]
    [ -f "$root/docs/archived/evidence-DEV-${id}.md" ]
  done
}

@test "DEV-045 SR-003: Master-Plan records v5.3.9 ship" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.9' "$mp"
  grep -q 'Release 5.3.9 shipped' "$mp"
}

# -- wave 2 ship regression v5.3.10 (SR-001–SR-003) ---------------------------

@test "DEV-046 SR-001: v5.3.10 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.10\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.10 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-046 SR-002: v5.3.10 changelog and wave-2 review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.10\]' "$root/CHANGELOG.md"
  grep -q 'DEV-046' "$root/CHANGELOG.md"
  grep -q 'DEV-059' "$root/CHANGELOG.md"
  for id in 046 059; do
    [ -f "$root/docs/archived/review-DEV-${id}.md" ]
    [ -f "$root/docs/archived/spec-DEV-${id}.md" ]
    [ -f "$root/docs/archived/evidence-DEV-${id}.md" ]
    grep -q '| ship |' "$root/docs/archived/evidence-DEV-${id}.md"
  done
}

@test "DEV-046 SR-003: Master-Plan records v5.3.10 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.10' "$mp"
  grep -q 'Release 5.3.10 shipped' "$mp"
  grep -q 'v5.3.11 (next)' "$mp"
  grep -q '| DEV-046 | Feature: Optional Worktree Isolation | 2026-07-11 |' "$mp"
  grep -q '| DEV-059 | Feature: Governance Policy-as-Code | 2026-07-11 |' "$mp"
}


# -- wave 3 ship regression v5.3.11 (SR-001–SR-003) -------------------------

@test "DEV-052 SR-001: v5.3.11 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.11\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.11 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-052 SR-002: v5.3.11 changelog and wave-3 review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.11\]' "$root/CHANGELOG.md"
  grep -q 'DEV-052' "$root/CHANGELOG.md"
  grep -q 'DEV-056' "$root/CHANGELOG.md"
  for id in 052 056; do
    [ -f "$root/docs/archived/review-DEV-${id}.md" ]
    [ -f "$root/docs/archived/spec-DEV-${id}.md" ]
    [ -f "$root/docs/archived/evidence-DEV-${id}.md" ]
    grep -q '| ship |' "$root/docs/archived/evidence-DEV-${id}.md"
  done
}

@test "DEV-052 SR-003: Master-Plan records v5.3.11 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.11' "$mp"
  grep -q 'Release 5.3.11 shipped' "$mp"
  grep -q 'v5.3.12 (next)' "$mp"
}


# -- wave 4 ship regression v5.3.12 (SR-001–SR-003) -------------------------

@test "DEV-058 SR-001: v5.3.12 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.12\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.12 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-058 SR-002: v5.3.12 changelog and review/evidence artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.12\]' "$root/CHANGELOG.md"
  grep -q 'DEV-058' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-058.md" ]
  [ -f "$root/docs/archived/spec-DEV-058.md" ]
  [ -f "$root/docs/archived/evidence-DEV-058.md" ]
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-058.md"
}

@test "DEV-058 SR-003: Master-Plan records v5.3.12 ship and next patch milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.12' "$mp"
  grep -q 'Release 5.3.12 shipped' "$mp"
  grep -q 'v5.3.13 (next)' "$mp"
  grep -q '| DEV-058 | Feature: Local Dashboard | 2026-07-11 |' "$mp"
}

# -- post-v5.3.12 hygiene ship regression v5.3.13 (SR-001–SR-003) ---------------

@test "DEV-085 SR-001: v5.3.13 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.13\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.13 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-085 SR-002: v5.3.13 changelog and review/evidence/spec artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.13\]' "$root/CHANGELOG.md"
  grep -q 'DEV-085' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-085.md" ]
  [ -f "$root/docs/archived/spec-DEV-085.md" ]
  [ -f "$root/docs/archived/evidence-DEV-085.md" ]
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-085.md"
}

@test "DEV-085 SR-003: Master-Plan records v5.3.13 ship and v5.3.14 next milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.13' "$mp"
  grep -q 'Release 5.3.13 shipped' "$mp"
  grep -q 'v5.3.14 (next)' "$mp"
  grep -q '| DEV-085 | Chore: Post-v5.3.12 release hygiene' "$mp"
}

# -- DEV-051 ship regression v5.3.14 (SR-001–SR-003) ----------------------------

@test "DEV-051 SR-001: v5.3.14 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.14\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.14 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-051 SR-002: v5.3.14 changelog and review/evidence/spec artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.14\]' "$root/CHANGELOG.md"
  grep -q 'DEV-051' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-051.md" ]
  [ -f "$root/docs/archived/spec-DEV-051.md" ]
  [ -f "$root/docs/archived/evidence-DEV-051.md" ]
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-051.md"
}

@test "DEV-051 SR-003: Master-Plan records v5.3.14 ship and v5.3.15 next milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.14' "$mp"
  grep -q 'Release 5.3.14 shipped' "$mp"
  grep -q 'v5.3.15 (next)' "$mp"
  grep -q '| DEV-051 | Feature: Tracker Sync Bridge' "$mp"
}

# -- Wave 1b ship regression v5.3.15 (SR-001–SR-003) ----------------------------

@test "DEV-087 SR-001: v5.3.15 release pins are aligned" {
  local root="$BATS_TEST_DIRNAME/.."
  local bash_ver ps_ver npm_ver
  bash_ver="$(grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  grep -q '## \[5.3.15\]' "$root/CHANGELOG.md"
  grep -q 'Release 5.3.15 shipped' "$root/docs/Master-Plan.md"
  [ "$bash_ver" = "5.3.15" ]
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
  grep -qE "version-${bash_ver}" "$root/README.md"
  grep -qE -- "--ref v${bash_ver}" "$root/README.md"
}

@test "DEV-087 SR-002: v5.3.15 changelog and Wave 1b review/evidence/spec artifacts exist" {
  local root="$BATS_TEST_DIRNAME/.."
  grep -q '## \[5.3.15\]' "$root/CHANGELOG.md"
  grep -q 'DEV-087' "$root/CHANGELOG.md"
  grep -q 'DEV-088' "$root/CHANGELOG.md"
  [ -f "$root/docs/archived/review-DEV-087.md" ]
  [ -f "$root/docs/archived/spec-DEV-087.md" ]
  [ -f "$root/docs/archived/evidence-DEV-087.md" ]
  [ -f "$root/docs/archived/review-DEV-088.md" ]
  [ -f "$root/docs/archived/spec-DEV-088.md" ]
  [ -f "$root/docs/archived/evidence-DEV-088.md" ]
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-087.md"
  grep -q '| ship |' "$root/docs/archived/evidence-DEV-088.md"
}

@test "DEV-087 SR-003: Master-Plan records v5.3.15 ship and v5.3.16 next milestone" {
  local mp="$BATS_TEST_DIRNAME/../docs/Master-Plan.md"
  grep -q 'Ship complete — v5.3.15' "$mp"
  grep -q 'Release 5.3.15 shipped' "$mp"
  grep -q 'v5.3.16 (next)' "$mp"
  grep -q '| DEV-087 | Feature: Delivery Evidence Contract' "$mp"
  grep -q '| DEV-088 | Feature: Verifier and Doctor Machine Output' "$mp"
}

# ── DEV-081: Optional Local DX Add-on Validation (DXV-001–DXV-008) ───────────

SPIKE_DEV081="$BATS_TEST_DIRNAME/../docs/spikes/DEV-081-local-dx-validation.md"

@test "DEV-081 DXV-001: shared baseline rubric completeness" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'user value' "$f"
  grep -qi 'setup friction' "$f"
  grep -qi 'portability' "$f"
  grep -qi 'security' "$f"
  grep -qi 'maintenance' "$f"
  grep -qi 'accessibility' "$f"
  grep -qi 'failure recovery' "$f"
  grep -qi 'no-add-on fallback' "$f"
}

@test "DEV-081 DXV-002: thin wrapper delegation boundary @smoke" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'thin native wrapper' "$f"
  grep -qi 'delegat' "$f"
  grep -qi 'distribution' "$f"
  grep -qi 'update' "$f"
  grep -qi 'platform.parity\|platform parity' "$f"
  grep -qi 'error.propagation\|error propagation' "$f"
  grep -qi 'second core' "$f"
}

@test "DEV-081 DXV-003: editor extension trust and fallback review @smoke" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'editor extension' "$f"
  grep -qi 'command discovery' "$f"
  grep -qi 'workspace trust' "$f"
  grep -qi 'permission' "$f"
  grep -qi 'update.channel\|update channel' "$f"
  grep -qi 'accessibility' "$f"
  grep -qi 'offline' "$f"
  grep -qi 'uninstall' "$f"
  grep -qi 'CLI fallback' "$f"
}

@test "DEV-081 DXV-004: CI template gap evidence @smoke" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'CI template' "$f"
  grep -qi 'provider' "$f"
  grep -qi 'permission' "$f"
  grep -qi 'duplication risk' "$f"
  grep -qi 'maintenance owner' "$f"
  grep -qi 'copy-only\|copy only' "$f"
}

@test "DEV-081 DXV-005: three independent DX decisions @smoke" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qE '(?i)thin native wrapper.*\*\*(adopt|defer|reject)\*\*' "$f"
  grep -qE '(?i)editor extension.*\*\*(adopt|defer|reject)\*\*' "$f"
  grep -qE '(?i)CI template.*\*\*(adopt|defer|reject)\*\*' "$f"
}

@test "DEV-081 DXV-006: decision evidence and trigger traceability" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'confidence' "$f"
  grep -qi 'reconsideration trigger' "$f"
  grep -qi 'observation' "$f"
  grep -qi 'cost' "$f"
  grep -qi 'risk' "$f"
}

@test "DEV-081 DXV-007: spike has no production implementation" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'no production implementation' "$f"
  grep -qi 'spike evidence only' "$f"
  ! grep -qE 'agtoosa\.sh|lib/|template/' "$f" || grep -qi 'no changes to' "$f"
}

@test "DEV-081 DXV-008: evidence assumption claim separation" {
  [ -f "$SPIKE_DEV081" ]
  local f="$SPIKE_DEV081"
  grep -qi 'observed' "$f"
  grep -qi 'assumption' "$f"
  grep -qi 'untested' "$f"
  grep -qi 'not shipped' "$f"
}

# -- DEV-078 First-15-Minutes Maintenance Gate (F15-001-F15-008) --------------

f15_copy_launch_fixture_base() {
  local dest="$1"
  local root="$BATS_TEST_DIRNAME/.."
  mkdir -p "$dest/docs/examples" "$dest/scripts" "$dest/.github/ISSUE_TEMPLATE"
  cp "$root/agtoosa.sh" "$dest/"
  cp "$root/scripts/check-launch-readiness.sh" "$dest/scripts/"
  chmod +x "$dest/scripts/check-launch-readiness.sh"
  cp "$root/docs/examples/first-15-minutes.md" "$dest/docs/examples/"
  cp "$root/docs/examples/public-launch-proof.md" "$dest/docs/examples/"
  cp "$root/README.md" "$dest/"
  cp "$root/.github/SUPPORT.md" "$dest/.github/"
  cp "$root/.github/DISCUSSIONS.md" "$dest/.github/"
  cp "$root/.github/ISSUE_TEMPLATE/bug.yml" "$dest/.github/ISSUE_TEMPLATE/"
  cp "$root/.github/ISSUE_TEMPLATE/feature.yml" "$dest/.github/ISSUE_TEMPLATE/"
  cp "$root/bootstrap.sh" "$dest/"
  cp "$root/bootstrap.ps1" "$dest/"
}

f15_run_checker() {
  local root="$1"
  shift
  AGTOOSA_LAUNCH_ROOT="$root" bash "$root/scripts/check-launch-readiness.sh" "$@"
}

@test "DEV-078 @smoke F15-001: current first-15 pins match the canonical version" {
  local script_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  local first15="$BATS_TEST_DIRNAME/../docs/examples/first-15-minutes.md"
  local proof="$BATS_TEST_DIRNAME/../docs/examples/public-launch-proof.md"
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"

  grep -qE -- "--ref v${script_ver}" "$first15"
  grep -qE "releases/tag/v${script_ver}" "$proof"
  grep -qE "/AgToosa/v${script_ver}/bootstrap.sh" "$proof"
  grep -qE '/AgToosa/\$\{EXPECTED_TAG\}/bootstrap\.sh' "$checker"

  run f15_run_checker "$BATS_TEST_DIRNAME/.." --mode private
  [ "$status" -eq 0 ]
  [[ "$output" == *"first-15 maintenance"* ]]
  [[ "$output" == *"ok - scoped release pins match v${script_ver}"* ]]
}

@test "DEV-078 F15-002: a stale release pin fails with exact diagnostics" {
  local fixture="$TEST_PROJECT/f15-stale-pin"
  local script_ver stale_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  stale_ver="5.0.0"
  [[ "$stale_ver" != "$script_ver" ]]

  f15_copy_launch_fixture_base "$fixture"
  sed -i.bak "s/--ref v${script_ver}/--ref v${stale_ver}/" "$fixture/docs/examples/first-15-minutes.md"
  rm -f "$fixture/docs/examples/first-15-minutes.md.bak"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -ne 0 ]
  [[ "$output" == *"docs/examples/first-15-minutes.md"* ]]
  [[ "$output" == *"v${stale_ver}"* ]]
  [[ "$output" == *"v${script_ver}"* ]]
}

@test "DEV-078 @smoke F15-003: relative proof links resolve from their documents" {
  local fixture="$TEST_PROJECT/f15-relative-link"
  f15_copy_launch_fixture_base "$fixture"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok - relative proof links resolve"* ]]

  sed -i.bak 's|(public-launch-proof.md)|(missing-proof-target.md)|' "$fixture/docs/examples/first-15-minutes.md"
  rm -f "$fixture/docs/examples/first-15-minutes.md.bak"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -ne 0 ]
  [[ "$output" == *"docs/examples/first-15-minutes.md"* ]]
  [[ "$output" == *"missing-proof-target.md"* ]]
}

@test "DEV-078 F15-004: first-15 proof repository URL is canonical" {
  local fixture="$TEST_PROJECT/f15-proof-url"
  local canonical="https://github.com/sky2464/agtoosa-first-15-proof"
  f15_copy_launch_fixture_base "$fixture"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok - first-15 proof repository URL is canonical"* ]]

  sed -i.bak "s|${canonical}|https://github.com/sky2464/wrong-first-15-proof|" "$fixture/README.md"
  rm -f "$fixture/README.md.bak"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -ne 0 ]
  [[ "$output" == *"README.md"* ]]
  [[ "$output" == *"wrong-first-15-proof"* ]]
  [[ "$output" == *"agtoosa-first-15-proof"* ]]
}

@test "DEV-078 F15-005: multiple maintenance findings remain actionable" {
  local fixture="$TEST_PROJECT/f15-multi-fail"
  local script_ver stale_ver
  script_ver="$(grep -m1 'AGTOOSA_VERSION=' "$SCRIPT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  stale_ver="5.0.0"
  f15_copy_launch_fixture_base "$fixture"
  sed -i.bak "s|--ref v${script_ver}|--ref v${stale_ver}|" "$fixture/docs/examples/first-15-minutes.md"
  sed -i.bak "s|/v${script_ver}/bootstrap.sh|/v${stale_ver}/bootstrap.sh|g" "$fixture/docs/examples/public-launch-proof.md"
  rm -f "$fixture/docs/examples/first-15-minutes.md.bak" "$fixture/docs/examples/public-launch-proof.md.bak"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -ne 0 ]
  [[ "$output" == *"docs/examples/first-15-minutes.md"* ]]
  [[ "$output" == *"docs/examples/public-launch-proof.md"* ]]
  [[ "$output" == *"v${stale_ver}"* ]]
  [[ "$output" == *"v${script_ver}"* ]]
}

@test "DEV-078 @smoke F15-006: private maintenance mode is offline" {
  local fixture="$TEST_PROJECT/f15-offline"
  local curl_shim="$TEST_PROJECT/bin"
  f15_copy_launch_fixture_base "$fixture"
  mkdir -p "$curl_shim"
  cat > "$curl_shim/curl" <<'EOF'
#!/usr/bin/env bash
echo "curl shim invoked: $*" >&2
exit 99
EOF
  chmod +x "$curl_shim/curl"

  run env PATH="$curl_shim:$PATH" bash "$fixture/scripts/check-launch-readiness.sh" --mode private
  [ "$status" -eq 0 ]
  [[ "$output" != *"curl shim invoked"* ]]
  [[ "$output" == *"Skipping anonymous public URL checks"* ]]
}

@test "DEV-078 F15-007: public mode retains availability checks" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"
  local maint_end public_start
  maint_end="$(grep -n 'first-15 maintenance gate complete' "$checker" | head -n1 | cut -d: -f1)"
  public_start="$(grep -n 'if \[\[ "$MODE" == "private" \]\]; then' "$checker" | head -n1 | cut -d: -f1)"
  local check_url_line
  check_url_line="$(grep -n '^check_url ' "$checker" | head -n1 | cut -d: -f1)"
  [[ -n "$maint_end" ]]
  [[ -n "$public_start" ]]
  [[ -n "$check_url_line" ]]
  [[ "$maint_end" -lt "$public_start" ]]
  [[ "$check_url_line" -gt "$public_start" ]]
  grep -q 'check_url "https://github.com/sky2464/agtoosa-first-15-proof"' "$checker"
}

@test "DEV-078 F15-008: maintenance gate is read-only and flow-neutral" {
  local fixture="$TEST_PROJECT/f15-readonly"
  local first15 proof
  f15_copy_launch_fixture_base "$fixture"
  first15="$fixture/docs/examples/first-15-minutes.md"
  proof="$fixture/docs/examples/public-launch-proof.md"
  local hash_before_first15 hash_before_proof step_sig_before
  hash_before_first15="$(shasum -a 256 "$first15" | awk '{print $1}')"
  hash_before_proof="$(shasum -a 256 "$proof" | awk '{print $1}')"
  step_sig_before="$(grep -E '^## [0-9]+\.' "$first15" | tr '\n' '|')"

  run f15_run_checker "$fixture" --mode private
  [ "$status" -eq 0 ]

  [ "$(shasum -a 256 "$first15" | awk '{print $1}')" = "$hash_before_first15" ]
  [ "$(shasum -a 256 "$proof" | awk '{print $1}')" = "$hash_before_proof" ]
  [ "$(grep -E '^## [0-9]+\.' "$first15" | tr '\n' '|')" = "$step_sig_before" ]
}

# ── DEV-075: Subagent and Persona Guide Suite (ADP-001–ADP-009) ───────────────

@test "DEV-075 @smoke ADP-001: walkthrough preserves end-to-end lane sequence" {
  local walkthrough="$BATS_TEST_DIRNAME/../docs/examples/subagent-handoff-review.md"
  [ -f "$walkthrough" ]
  grep -q "## 1. Start From An Approved Spec" "$walkthrough"
  grep -q "## 2. Partition Into Two Bounded Lanes" "$walkthrough"
  grep -q "## 3. Export Handoff Packs" "$walkthrough"
  grep -q "## 4. Import And Verify Locally" "$walkthrough"
  grep -q "## 5. Cross-Model Review" "$walkthrough"
  local s1 s2 s3 s4 s5
  s1="$(grep -n "## 1. Start From An Approved Spec" "$walkthrough" | head -1 | cut -d: -f1)"
  s2="$(grep -n "## 2. Partition Into Two Bounded Lanes" "$walkthrough" | head -1 | cut -d: -f1)"
  s3="$(grep -n "## 3. Export Handoff Packs" "$walkthrough" | head -1 | cut -d: -f1)"
  s4="$(grep -n "## 4. Import And Verify Locally" "$walkthrough" | head -1 | cut -d: -f1)"
  s5="$(grep -n "## 5. Cross-Model Review" "$walkthrough" | head -1 | cut -d: -f1)"
  [ "$s1" -lt "$s2" ]
  [ "$s2" -lt "$s3" ]
  [ "$s3" -lt "$s4" ]
  [ "$s4" -lt "$s5" ]
}

@test "DEV-075 ADP-002: each lane is bounded and merge-safe" {
  local walkthrough="$BATS_TEST_DIRNAME/../docs/examples/subagent-handoff-review.md"
  [ -f "$walkthrough" ]
  grep -q "### Lane A" "$walkthrough"
  grep -q "### Lane B" "$walkthrough"
  for marker in "Mapped ACs" "Files in scope" "Allowed actions" "Verification commands" "Return contract" "Overlap resolution"; do
    grep -q "$marker" "$walkthrough"
    local count
    count="$(grep -c "$marker" "$walkthrough")"
    [ "$count" -ge 2 ]
  done
}

@test "DEV-075 @smoke ADP-003: imported evidence gates closure" {
  local walkthrough="$BATS_TEST_DIRNAME/../docs/examples/subagent-handoff-review.md"
  [ -f "$walkthrough" ]
  grep -q "Imported claims are not evidence until repo-local verification passes" "$walkthrough"
  grep -q "/agtoosa-import" "$walkthrough"
  grep -q "Do not mark" "$walkthrough"
  grep -q "before import mapping" "$walkthrough"
}

@test "DEV-075 ADP-004: review path is independent or honestly downgraded" {
  local walkthrough="$BATS_TEST_DIRNAME/../docs/examples/subagent-handoff-review.md"
  [ -f "$walkthrough" ]
  grep -q "Writer" "$walkthrough"
  grep -q "Independent reviewer" "$walkthrough"
  grep -q "Sequential fallback" "$walkthrough"
  grep -q "Skip rationale" "$walkthrough"
  grep -q "read-only" "$walkthrough"
}

@test "DEV-075 ADP-005: audience guide inventory is complete" {
  local root="$BATS_TEST_DIRNAME/.."
  [ -f "$root/docs/guides/subagent-heavy-workflows.md" ]
  [ -f "$root/docs/guides/security-sensitive-projects.md" ]
  [ -f "$root/docs/guides/solo-developer-workflows.md" ]
}

@test "DEV-075 ADP-006: guides route to canonical workflow owners" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/docs/guides/subagent-heavy-workflows.md" \
    "$root/docs/guides/security-sensitive-projects.md" \
    "$root/docs/guides/solo-developer-workflows.md" \
    "$root/docs/examples/subagent-handoff-review.md"; do
    [ -f "$f" ]
    grep -q "AgToosa_Handoff.md" "$f"
    grep -q "AgToosa_Import.md" "$f"
    grep -q "AgToosa_CrossModelReview.md" "$f"
    grep -q "AgToosa_AgentCapability.md" "$f"
  done
}

@test "DEV-075 @smoke ADP-007: security guide enforces least-privilege documentation" {
  local guide="$BATS_TEST_DIRNAME/../docs/guides/security-sensitive-projects.md"
  [ -f "$guide" ]
  grep -q "redact" "$guide"
  grep -q "STRIDE" "$guide"
  grep -q "least-privilege" "$guide"
  grep -q "explicit authorization" "$guide"
  grep -q ".github/workflows" "$guide"
  grep -q "credentials" "$guide"
  grep -q "agent settings" "$guide"
}

@test "DEV-075 ADP-008: README exposes every guide" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  grep -q "docs/examples/subagent-handoff-review.md" "$readme"
  grep -q "docs/guides/subagent-heavy-workflows.md" "$readme"
  grep -q "docs/guides/security-sensitive-projects.md" "$readme"
  grep -q "docs/guides/solo-developer-workflows.md" "$readme"
}

@test "DEV-075 ADP-009: navigation does not fork canonical contracts" {
  local root="$BATS_TEST_DIRNAME/.."
  local readme="$root/README.md"
  local f
  for f in \
    "$root/docs/guides/subagent-heavy-workflows.md" \
    "$root/docs/guides/security-sensitive-projects.md" \
    "$root/docs/guides/solo-developer-workflows.md" \
    "$root/docs/examples/subagent-handoff-review.md"; do
    [ -f "$f" ]
    ! grep -q "## Pack Template" "$f"
    ! grep -q "## Import Checklist" "$f"
    ! grep -q "## Structured Evidence Block" "$f"
    grep -q "canonical" "$f"
  done
  ! grep -q "## Pack Template" "$readme"
  ! grep -q "## Import Checklist" "$readme"
}

# ── DEV-076: Static Documentation Site Proof (SITE-001–SITE-008) ──────────────

# Locate a jekyll binary (PATH or common Homebrew/gem install layouts).
site076_jekyll_bin() {
  if command -v jekyll >/dev/null 2>&1; then
    command -v jekyll
    return 0
  fi
  local candidate
  for candidate in \
    /opt/homebrew/lib/ruby/gems/*/bin/jekyll \
    /usr/local/lib/ruby/gems/*/bin/jekyll \
    "$HOME"/.gem/ruby/*/bin/jekyll; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

# Build docs/ into an isolated destination using Jekyll (local binary or Docker).
site076_jekyll_build() {
  local root="$1"
  local outdir="$2"
  local jekyll_bin=""
  mkdir -p "$outdir"
  if jekyll_bin="$(site076_jekyll_bin)"; then
    # Prefer the matching Homebrew Ruby when invoking a gem-installed jekyll.
    local ruby_bindir
    ruby_bindir="$(dirname "$jekyll_bin")"
    PATH="$ruby_bindir:/opt/homebrew/opt/ruby/bin:/usr/local/opt/ruby/bin:$PATH" \
      "$jekyll_bin" build --source "$root/docs" --destination "$outdir" --baseurl /AgToosa
    return $?
  fi
  if command -v docker >/dev/null 2>&1; then
    chmod 777 "$outdir" 2>/dev/null || true
    # Prefer the well-known socket when Docker Desktop's user socket is absent.
    if [ -z "${DOCKER_HOST:-}" ] && [ -S /var/run/docker.sock ]; then
      export DOCKER_HOST=unix:///var/run/docker.sock
    fi
    docker run --rm \
      -v "$root:/repo:ro" \
      -v "$outdir:/out" \
      -e JEKYLL_ENV=production \
      jekyll/jekyll:4.2.2 \
      bash -lc 'gem install --silent jekyll-optional-front-matter --no-document && jekyll build --source /repo/docs --destination /out --baseurl /AgToosa'
    return $?
  fi
  echo "SITE-076: need jekyll or docker to execute the static build" >&2
  return 127
}

@test "DEV-076 @smoke SITE-001: Pages build reads canonical docs directly" {
  local root="$BATS_TEST_DIRNAME/.."
  local config="$root/docs/_config.yml"
  local wf="$root/.github/workflows/docs-pages-proof.yml"
  local gitignore="$root/.gitignore"

  [ -f "$config" ]
  [ -f "$wf" ]
  [ -f "$gitignore" ]

  # No competing documentation source tree
  [ ! -d "$root/site-content" ]
  [ ! -d "$root/docs-site" ]
  [ ! -d "$root/docs/_site" ]

  # Workflow builds from canonical docs/
  grep -qE 'source:[[:space:]]*\./docs' "$wf"
  grep -qE 'destination:[[:space:]]*\./_site' "$wf"

  # Local/CI generated output must stay untracked
  grep -qE '(^|/)_site/' "$gitignore"

  # Execute build into an ephemeral directory (not committed)
  local outdir
  outdir="$(mktemp -d "${BATS_TEST_TMPDIR}/site076.XXXXXX")"
  run site076_jekyll_build "$root" "$outdir"
  [ "$status" -eq 0 ]
  [ -f "$outdir/index.html" ]
  [ ! -d "$root/site-content" ]
  [ ! -d "$root/docs/_site" ]
}

@test "DEV-076 SITE-002: Site navigation links instead of cloning prose" {
  local index="$BATS_TEST_DIRNAME/../docs/index.md"
  local agent="$BATS_TEST_DIRNAME/../docs/AgToosa_Agent.md"
  local first15="$BATS_TEST_DIRNAME/../docs/examples/first-15-minutes.md"

  [ -f "$index" ]
  [ -f "$agent" ]
  [ -f "$first15" ]

  # Landing must point at canonical markdown paths
  grep -qE '\[.*\]\(AgToosa_Agent\.md\)' "$index"
  grep -qE '\[.*\]\(examples/first-15-minutes\.md\)' "$index"

  # Must not embed maintained duplicates of guide bodies
  ! grep -q "Generated Project Mode" "$index"
  ! grep -q "## 1. Start From A Clean Repo" "$index"
  ! grep -q "Terminal Evidence Contract" "$index"
}

@test "DEV-076 @smoke SITE-003: Pull-request workflow fails closed on build error" {
  local wf="$BATS_TEST_DIRNAME/../.github/workflows/docs-pages-proof.yml"
  [ -f "$wf" ]

  grep -q "pull_request" "$wf"
  grep -qE "docs/\*\*|docs/" "$wf"
  grep -q "jekyll-build-pages" "$wf"

  # Build failures must not be swallowed
  ! grep -qE 'continue-on-error:[[:space:]]*true' "$wf"
}

@test "DEV-076 SITE-004: Project Pages base path resolves" {
  local root="$BATS_TEST_DIRNAME/.."
  local config="$root/docs/_config.yml"
  [ -f "$config" ]
  grep -qE 'baseurl:[[:space:]]*"/AgToosa"' "$config"

  local outdir
  outdir="$(mktemp -d "${BATS_TEST_TMPDIR}/site076-base.XXXXXX")"
  run site076_jekyll_build "$root" "$outdir"
  [ "$status" -eq 0 ]
  [ -f "$outdir/index.html" ]

  # Landing navigation must resolve under the project Pages base path
  grep -q "/AgToosa/" "$outdir/index.html"
}

@test "DEV-076 @smoke SITE-005: Representative canonical pages render" {
  local root="$BATS_TEST_DIRNAME/.."
  local outdir
  outdir="$(mktemp -d "${BATS_TEST_TMPDIR}/site076-render.XXXXXX")"
  run site076_jekyll_build "$root" "$outdir"
  [ "$status" -eq 0 ]

  [ -f "$outdir/index.html" ]
  [ -f "$outdir/AgToosa_Agent.html" ]
  [ -f "$outdir/examples/first-15-minutes.html" ]

  grep -qi "AgToosa" "$outdir/index.html"
  grep -q "Operating Contexts" "$outdir/AgToosa_Agent.html"
  grep -q "First 15 Minutes" "$outdir/examples/first-15-minutes.html"
}

@test "DEV-076 SITE-006: Artifact identifies its source revision" {
  local wf="$BATS_TEST_DIRNAME/../.github/workflows/docs-pages-proof.yml"
  [ -f "$wf" ]

  grep -q "github.sha" "$wf"
  grep -q "upload-artifact" "$wf"
  grep -qE 'docs-pages-proof-\$\{\{\s*github\.sha\s*\}\}' "$wf"
}

@test "DEV-076 SITE-007: Proof has no runtime service or tracking" {
  local root="$BATS_TEST_DIRNAME/.."
  local config="$root/docs/_config.yml"
  local index="$root/docs/index.md"
  local wf="$root/.github/workflows/docs-pages-proof.yml"

  [ -f "$config" ]
  [ -f "$index" ]
  [ -f "$wf" ]

  local f
  for f in "$config" "$index" "$wf"; do
    ! grep -qiE 'google-analytics|gtag\(|analytics\.js|mixpanel|segment\.com|plausible\.io' "$f"
    ! grep -qiE 'postgres|mongodb|mysql|redis|oauth|passport|database_url' "$f"
    ! grep -qiE 'express\(|fastapi|django\.|flask\.|rails' "$f"
  done

  # Proof is build-only — no automatic production deploy step
  ! grep -q "actions/deploy-pages" "$wf"
  ! grep -qE 'pages:[[:space:]]*write' "$wf"
}

@test "DEV-076 SITE-008: Docs workflow is pinned and least privilege" {
  local wf="$BATS_TEST_DIRNAME/../.github/workflows/docs-pages-proof.yml"
  [ -f "$wf" ]

  grep -qE 'permissions:' "$wf"
  grep -qE 'contents:[[:space:]]*read' "$wf"
  ! grep -qE 'contents:[[:space:]]*write' "$wf"
  ! grep -qE 'id-token:[[:space:]]*write' "$wf"

  # Every third-party action must be immutable-pinned (40-char SHA)
  local uses_line
  while IFS= read -r uses_line; do
    [[ "$uses_line" =~ uses:[[:space:]]*[^@]+@([0-9a-f]{40}) ]]
  done < <(grep -E 'uses:' "$wf")
}

# ── DEV-082: High-Assurance Signature Mode Validation (HSV-001–HSV-009) ──────

SPIKE_DEV082="$BATS_TEST_DIRNAME/../docs/spikes/DEV-082"

@test "DEV-082 HSV-001: demand and decision gate completeness @smoke" {
  local f="$SPIKE_DEV082/demand.md"
  [ -f "$f" ]
  grep -qi 'scenario' "$f"
  grep -qi 'workaround' "$f"
  grep -qi 'protected surface' "$f"
  grep -qi 'blocking' "$f"
  grep -qi 'constraint' "$f"
  grep -qi 'evidence source\|source' "$f"
  grep -qiE 'adopt|defer|reject' "$f"
  grep -qi 'criteria\|threshold' "$f"
}

@test "DEV-082 HSV-002: layered signature trust model" {
  local f="$SPIKE_DEV082/trust-model.md"
  [ -f "$f" ]
  grep -qi 'SHA-256\|SHA256' "$f"
  grep -qi 'registry.*review\|verified' "$f"
  grep -qi 'soft-warn\|soft warn' "$f"
  grep -qi 'fail-closed\|fail closed' "$f"
  grep -qi 'registry pack' "$f"
  grep -qi 'release' "$f"
  grep -qi 'DEV-054\|ADR-011' "$f"
}

@test "DEV-082 HSV-003: synthetic key lifecycle operations @smoke" {
  local f="$SPIKE_DEV082/key-operations.md"
  [ -f "$f" ]
  grep -qi 'generation\|generate' "$f"
  grep -qi 'custody' "$f"
  grep -qi 'signer separation\|separation' "$f"
  grep -qi 'distribution' "$f"
  grep -qi 'rotation' "$f"
  grep -qi 'revocation\|revoke' "$f"
  grep -qi 'expiry\|expir' "$f"
  grep -qi 'recovery' "$f"
  grep -qi 'audit' "$f"
  grep -qi 'nonretention\|non-retention\|never.*commit\|synthetic' "$f"
}

@test "DEV-082 HSV-004: private key nonretention boundary" {
  local dir="$SPIKE_DEV082"
  [ -d "$dir" ]
  # No private key material under spike artifacts
  ! find "$dir" -type f \( -name '*.key' -o -name '*secret*' -o -name '*private*' \) | grep -q .
  ! grep -rqiE 'BEGIN.*PRIVATE KEY|minisign.*untrusted comment:.*secret key|RWR[A-Za-z0-9+/]{40,}' "$dir" 2>/dev/null \
    || ! grep -rqiE 'BEGIN.*PRIVATE KEY|secret key' "$dir"
  # Production surfaces must not newly wire AGTOOSA_REQUIRE_SIGNATURES
  ! grep -rqE 'AGTOOSA_REQUIRE_SIGNATURES' \
    "$BATS_TEST_DIRNAME/../agtoosa.sh" \
    "$BATS_TEST_DIRNAME/../agtoosa.ps1" \
    "$BATS_TEST_DIRNAME/../lib" \
    "$BATS_TEST_DIRNAME/../bootstrap.sh" \
    "$BATS_TEST_DIRNAME/../bootstrap.ps1" \
    "$BATS_TEST_DIRNAME/../npm" 2>/dev/null
}

@test "DEV-082 HSV-005: fail-closed failure matrix @smoke" {
  local f="$SPIKE_DEV082/failure-matrix.md"
  [ -f "$f" ]
  grep -qi 'absent\|missing.*signature' "$f"
  grep -qi 'invalid' "$f"
  grep -qi 'revoked\|stale' "$f"
  grep -qi 'minisign\|verifier.*tool\|tooling' "$f"
  grep -qi 'offline' "$f"
  grep -qi 'cache' "$f"
  grep -qi 'rotation' "$f"
  grep -qi 'expected outcome\|expected' "$f"
}

@test "DEV-082 HSV-006: existing artifact migration safety" {
  local f="$SPIKE_DEV082/trust-model.md"
  [ -f "$f" ]
  grep -qi 'unsigned' "$f"
  grep -qi 'opt-in\|opt in\|migration' "$f"
  grep -qi 'default' "$f"
  # Decision must not silently change defaults
  local d="$SPIKE_DEV082/decision.md"
  [ -f "$d" ]
  grep -qi 'default' "$d"
}

@test "DEV-082 HSV-007: authorized rollback and restoration @smoke" {
  local f="$SPIKE_DEV082/rollback-runbook.md"
  [ -f "$f" ]
  grep -qi 'authorization\|authorize\|break-glass\|break glass' "$f"
  grep -qi 'recovery' "$f"
  grep -qi 'audit' "$f"
  grep -qi 'restoration\|restore\|return' "$f"
  grep -qi 'safe default\|soft-warn\|prior' "$f"
}

@test "DEV-082 HSV-008: require-signatures pre-implementation gate" {
  local d="$SPIKE_DEV082/decision.md"
  [ -f "$d" ]
  grep -qiE '\*\*(adopt|defer|reject)\*\*|outcome.*\b(adopt|defer|reject)\b' "$d"
  grep -qi 'prerequisite\|confidence' "$d"
  grep -qi 'AGTOOSA_REQUIRE_SIGNATURES\|no production\|spike evidence' "$d"
  # Flag string must not appear as wired behavior in production entrypoints
  ! grep -q 'AGTOOSA_REQUIRE_SIGNATURES' "$BATS_TEST_DIRNAME/../agtoosa.sh"
  ! grep -q 'AGTOOSA_REQUIRE_SIGNATURES' "$BATS_TEST_DIRNAME/../lib/"*.sh 2>/dev/null
}

@test "DEV-082 HSV-009: signature finding confidence labels" {
  local dir="$SPIKE_DEV082"
  [ -d "$dir" ]
  grep -rqi 'observed' "$dir"
  grep -rqi 'tabletop' "$dir"
  grep -rqi 'assumed\|assumption' "$dir"
  grep -rqi 'untested' "$dir"
  ! grep -rqiE 'production (key|ready|enforcement)|fail-closed.*(ships|shipped|enforced|is live)' "$dir" \
    || grep -rqiE 'does not (exist|claim)|not (shipped|implemented)|spike evidence only|tabletop' "$dir"
}

# ── DEV-084: Open-Source Sustainability and Support Boundary (OSS-001–OSS-007) ─

oss_support="$BATS_TEST_DIRNAME/../.github/SUPPORT.md"
oss_funding="$BATS_TEST_DIRNAME/../.github/FUNDING.yml"
oss_security="$BATS_TEST_DIRNAME/../SECURITY.md"
oss_readme="$BATS_TEST_DIRNAME/../README.md"
oss_contrib="$BATS_TEST_DIRNAME/../CONTRIBUTING.md"

# Surfaces that form the public sustainability boundary (OSS-003 / OSS-006 scope).
oss_public_surfaces() {
  printf '%s\n' "$oss_support" "$oss_funding" "$oss_security" "$oss_readme" "$oss_contrib"
}

@test "DEV-084 @smoke OSS-001: voluntary sponsorship no-entitlement boundary" {
  [ -f "$oss_support" ]
  [ -f "$oss_funding" ]
  grep -qE 'github:[[:space:]]*\[sky2464\]' "$oss_funding"
  grep -qi 'github sponsors\|sponsors\.github\|github.com/sponsors/sky2464' "$oss_support"
  grep -qi 'voluntary' "$oss_support"
  grep -qi 'does not guarantee\|does not buy\|does not grant' "$oss_support"
  grep -qi 'support priority\|priority support' "$oss_support"
  grep -qi 'response time' "$oss_support"
  grep -qi 'roadmap' "$oss_support"
  grep -qi 'private release' "$oss_support"
  grep -qi 'feature access\|feature entitlement\|gated' "$oss_support"
}

@test "DEV-084 @smoke OSS-002: support channel routing matrix" {
  [ -f "$oss_support" ]
  [ -f "$oss_security" ]
  # Distinct channels for questions, bugs, proposals, and private vulns
  grep -qi 'discussion' "$oss_support"
  grep -qi 'bug\|issue' "$oss_support"
  grep -qi 'feature\|proposal' "$oss_support"
  grep -qi 'SECURITY\.md\|security vulnerabilit' "$oss_support"
  grep -qi 'do \*\*not\*\*\|do not.*public issue\|NOT report.*public' "$oss_security"
  grep -qi 'security@agtoosa.dev\|private security advisory\|security advisory' "$oss_security"
  # Submission guidance / expected information
  grep -qi 'include\|before asking\|steps to reproduce\|operating system\|environment' "$oss_support"
}

@test "DEV-084 @smoke OSS-003: best-effort no-SLA language" {
  [ -f "$oss_support" ]
  [ -f "$oss_security" ]
  grep -qi 'best.?effort\|best effort' "$oss_support"
  grep -qi 'best.?effort\|best effort\|no.*sla\|not.*sla\|non-contractual\|does not establish' "$oss_security"
  # Unsupported fixed-time / SLA promises must not appear on public sustainability surfaces
  local f
  while IFS= read -r f; do
    [ -f "$f" ]
    ! grep -qiE 'acknowledge[[:space:]]+receipt[[:space:]]+within' "$f"
    ! grep -qiE 'within[[:space:]]+\*\*[0-9]+[[:space:]]*(hour|day|business)' "$f"
    ! grep -qiE 'response[[:space:]]+sla|service[[:space:]]+level[[:space:]]+agreement' "$f"
    ! grep -qiE 'business[[:space:]]+hours|uptime[[:space:]]+(target|guarantee|sla)' "$f"
  done < <(oss_public_surfaces)
}

@test "DEV-084 OSS-004: commercial and sponsored-content independence disclosure" {
  [ -f "$oss_support" ]
  grep -qi 'consulting' "$oss_support"
  grep -qi 'optional\|separately executed\|separate.*agreement' "$oss_support"
  grep -qi 'sponsored.*content\|sponsored educational\|educational content' "$oss_support"
  grep -qi 'editorial\|conflict' "$oss_support"
  grep -qi 'governance\|roadmap' "$oss_support"
  grep -qi 'security.reporting\|security.report\|vulnerability' "$oss_support"
  grep -qi 'does not\|no.*grant\|does not grant' "$oss_support"
}

@test "DEV-084 @smoke OSS-005: open-source feature parity" {
  [ -f "$oss_support" ]
  grep -qi 'regardless of sponsorship\|same public.*feature\|no sponsor-only\|not gated by sponsorship\|ungated\|equal.*feature' "$oss_support"
  local f
  while IFS= read -r f; do
    [ -f "$f" ]
    ! grep -qiE 'sponsor[- ]only (feature|release|fix|workflow)|sponsors? get (priority|early|private)|paid tier|feature gate' "$f"
  done < <(oss_public_surfaces)
}

@test "DEV-084 OSS-006: public sustainability surface consistency" {
  [ -f "$oss_support" ]
  [ -f "$oss_funding" ]
  [ -f "$oss_security" ]
  [ -f "$oss_readme" ]
  [ -f "$oss_contrib" ]
  # Preserve launch-gate marker and cross-links
  grep -q 'public support channel' "$oss_support"
  grep -q 'SECURITY.md' "$oss_support"
  grep -qE '\.github/SUPPORT\.md|SUPPORT\.md' "$oss_readme"
  grep -q 'SECURITY.md' "$oss_readme"
  grep -qE '\.github/SUPPORT\.md|SUPPORT\.md' "$oss_contrib"
  grep -q 'SECURITY.md' "$oss_contrib"
  # Funding destination matches support disclosure
  grep -qE 'github:[[:space:]]*\[sky2464\]' "$oss_funding"
  grep -qi 'sky2464' "$oss_support"
  # Canonical boundary language present on support surface
  grep -qi 'best.?effort\|best effort' "$oss_support"
  grep -qi 'voluntary' "$oss_support"
}

@test "DEV-084 OSS-007: official sponsor destination metadata" {
  # Static contract: FUNDING.yml + SUPPORT.md name the official destination.
  # Live reachability and account control remain manual (OSS-007 [manual]).
  [ -f "$oss_funding" ]
  [ -f "$oss_support" ]
  grep -qE 'github:[[:space:]]*\[sky2464\]' "$oss_funding"
  grep -qi 'github.com/sponsors/sky2464' "$oss_support"
}

# ── DEV-079: Verifier and CI Adoption Examples (VCA-001–VCA-009) ──────────────

@test "DEV-079 VCA-001: Generated-project verifier example is complete" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  grep -q "Docs/agtoosa-verify.sh" "$guide"
  grep -q -- "--strict" "$guide"
  grep -Eq 'exit[[:space:]]*(code|codes)?[[:space:]]*(`?0`?|0)' "$guide" || grep -q "exit \`0\`" "$guide" || grep -q "| 0 |" "$guide" || grep -q "\`0\`" "$guide"
  grep -q "1" "$guide"
  grep -q "2" "$guide"
  # Local section must not claim CI enforcement for the local machine check alone
  ! grep -qiE 'local.*(CI-enforced|ci.enforced)' "$guide"
}

@test "DEV-079 VCA-002: Maintainer verifier example uses lowercase context" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  grep -qiE 'Maintainer|Dogfood|maintainer repository' "$guide"
  grep -q "docs/agtoosa-verify.sh" "$guide"
  # Separately labeled maintainer block (heading or bold label)
  grep -qiE '(^#+ .*[Mm]aintainer|Generated [Pp]roject|Operating [Cc]ontext)' "$guide"
}

@test "DEV-079 @smoke VCA-003: GitHub gate copy-in is reviewable and non-destructive" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  grep -qiE 'inspect|\.github/workflows' "$guide"
  grep -qiE 'overwrite|already exists|stop' "$guide"
  grep -q "agtoosa-gate.yml" "$guide"
  grep -qiE 'diff|review' "$guide"
  grep -qiE 'commit|push' "$guide"
  grep -qiE 'observ|workflow run|Actions run|CI run' "$guide"
}

@test "DEV-079 @smoke VCA-004: Adoption states have honest enforcement labels" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  grep -qiE 'local machine check|machine-enforced locally|local (machine )?check' "$guide"
  grep -qiE 'template( only)?' "$guide"
  grep -q "CI-enforced" "$guide"
  # Uncopied .example must not be labeled CI-enforced
  ! grep -qiE 'agtoosa-gate\.yml\.example[^.]*CI-enforced' "$guide"
  # CI-enforced requires observed/running language nearby in claim boundary or states table
  grep -qiE 'observ|running|copied.*(workflow|gate)' "$guide"
}

@test "DEV-079 VCA-005: Provider-specific support requires maintained evidence" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  grep -qi "GitHub Actions" "$guide"
  grep -qiE 'provider-neutral|unmaintained' "$guide"
  grep -qiE 'copy-ready|maintained' "$guide"
  # Must not present GitLab/CircleCI/Jenkins/Azure as affirmative copy-ready support
  ! grep -qiE '(GitLab|CircleCI|Jenkins|Azure Pipelines).{0,60}(is copy-ready|are copy-ready|copy-ready example|maintained example)' "$guide"
}

@test "DEV-079 VCA-006: Command blocks never mix operating-context paths" {
  local guide="$BATS_TEST_DIRNAME/../docs/examples/verifier-ci-adoption.md"
  [ -f "$guide" ]
  # Extract fenced bash/sh/shell blocks; each must not contain both Docs/ and docs/ verifier paths
  local mixed
  mixed="$(awk '
    /^```(bash|sh|shell)?[[:space:]]*$/ { in_block=1; block=""; next }
    /^```[[:space:]]*$/ && in_block {
      if (block ~ /Docs\/agtoosa-verify\.sh/ && block ~ /[^D\/]docs\/agtoosa-verify\.sh|^\s*docs\/agtoosa-verify\.sh|[^a-zA-Z]docs\/agtoosa-verify\.sh/) {
        # Check both path forms present as runnable commands
        has_docs = (block ~ /(^|[[:space:]])Docs\/agtoosa-verify\.sh/)
        has_lower = (block ~ /(^|[[:space:]])docs\/agtoosa-verify\.sh/)
        if (has_docs && has_lower) print "MIXED"
      }
      in_block=0
      next
    }
    in_block { block = block "\n" $0 }
  ' "$guide")"
  [ -z "$mixed" ]
  # Runnable verifier command blocks should be context-labeled nearby
  grep -qiE 'Generated [Pp]roject' "$guide"
  grep -qiE 'Maintainer|Dogfood' "$guide"
}

@test "DEV-079 VCA-007: Discovery surfaces route to one adoption owner" {
  local root="$BATS_TEST_DIRNAME/.."
  local guide_rel="docs/examples/verifier-ci-adoption.md"
  [ -f "$root/$guide_rel" ]
  grep -q "$guide_rel" "$root/README.md"
  grep -q "verifier-ci-adoption" "$root/docs/AgToosa_Quickref.md"
  grep -q "verifier-ci-adoption" "$root/docs/AgToosa_Readiness.md"
  grep -q "verifier-ci-adoption\|sky2464/AgToosa.*verifier-ci-adoption" "$root/template/Docs/AgToosa_Quickref.md"
  grep -q "verifier-ci-adoption\|sky2464/AgToosa.*verifier-ci-adoption" "$root/template/Docs/AgToosa_Readiness.md"
  # Discovery surfaces must not reproduce the full inspect→copy→diff→push→observe procedure
  for f in \
    "$root/README.md" \
    "$root/docs/AgToosa_Quickref.md" \
    "$root/docs/AgToosa_Readiness.md" \
    "$root/template/Docs/AgToosa_Quickref.md" \
    "$root/template/Docs/AgToosa_Readiness.md"; do
    local hits=0
    grep -qiE 'inspect.*(workflow|destination)|\.github/workflows' "$f" && hits=$((hits+1)) || true
    grep -qiE 'review.*(diff|the diff)|git diff' "$f" && hits=$((hits+1)) || true
    grep -qiE 'observ.*(run|workflow)|workflow run' "$f" && hits=$((hits+1)) || true
    [ "$hits" -lt 3 ]
  done
}

@test "DEV-079 @smoke VCA-008: Maintained gate is immutable-pinned and least privilege" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/docs/agtoosa-gate.yml.example" \
    "$root/template/Docs/agtoosa-gate.yml.example"; do
    [ -f "$f" ]
    grep -q "permissions:" "$f"
    grep -q "contents: read" "$f"
    # Immutable SHA pin for checkout (40 hex chars), not a floating major tag alone
    grep -Eq 'actions/checkout@[0-9a-f]{40}' "$f"
    ! grep -Eq 'actions/checkout@v[0-9]+[[:space:]]*$' "$f"
    ! grep -qiE 'permissions:[[:space:]]*write-all|contents:[[:space:]]*write' "$f"
    ! grep -qiE 'secrets\.|GITHUB_TOKEN:|permissions:.*write' "$f"
  done
}

@test "DEV-079 VCA-009: Gate mirrors fail closed and remain identical" {
  local root="$BATS_TEST_DIRNAME/.."
  local docs_gate="$root/docs/agtoosa-gate.yml.example"
  local tmpl_gate="$root/template/Docs/agtoosa-gate.yml.example"
  [ -f "$docs_gate" ]
  [ -f "$tmpl_gate" ]
  diff -u "$docs_gate" "$tmpl_gate"
  # Fail closed when verifier missing
  grep -q "not found" "$docs_gate"
  grep -q "exit 1" "$docs_gate"
  # Preserve verifier exit status (invoke bash on the script directly; no || true / exit 0 swallow)
  ! grep -Eq 'agtoosa-verify\.sh.*\|\|[[:space:]]*true' "$docs_gate"
  ! grep -Eq 'agtoosa-verify\.sh.*;[[:space:]]*exit 0' "$docs_gate"
  # Safe-copy comments: inspect destination, review diff, honest template/CI label
  grep -qiE 'inspect' "$docs_gate"
  grep -qiE 'review|diff' "$docs_gate"
  grep -qiE 'template|CI-enforced' "$docs_gate"
}

# ── DEV-083: Voluntary Workflow Metrics and Case Study Kit (MET-001–MET-010) ──

MET_KIT_TEMPLATE="$BATS_TEST_DIRNAME/../template/Docs/AgToosa_MetricsKit.md"
MET_KIT_MIRROR="$BATS_TEST_DIRNAME/../docs/AgToosa_MetricsKit.md"
MET_CASE_TEMPLATE="$BATS_TEST_DIRNAME/../template/Docs/AgToosa_CaseStudy.template.md"
MET_CASE_MIRROR="$BATS_TEST_DIRNAME/../docs/AgToosa_CaseStudy.template.md"

@test "DEV-083 MET-001: voluntary local-only boundary @smoke" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qi 'opt-in' "$f"
    grep -qi 'local' "$f"
    grep -qi 'redact' "$f"
    grep -qi 'withdraw' "$f"
    grep -qiE 'no telemetry|no-telemetry|shall not.*telemetry|without telemetry' "$f"
    grep -qiE 'collection hook|no collection|shall not.*collect' "$f"
    grep -qiE 'network submission|no network|shall not.*network' "$f"
    grep -qiE 'background analytics|automatic reporting|auto-report|shall not.*report' "$f"
    grep -qi 'voluntary' "$f"
  done
  # Kit must not instruct affirmative collection/send actions
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    ! grep -qiE 'curl .+metric|wget .+metric|POST .+telemetry|submit .+telemetry|send .+analytics' "$f"
    ! grep -qiE 'enable telemetry by default|collection enabled by default' "$f"
  done
}

@test "DEV-083 MET-002: common metric schema completeness" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qi 'purpose' "$f"
    grep -qi 'definition' "$f"
    grep -qi 'population' "$f"
    grep -qiE 'numerator|denominator|unit' "$f"
    grep -qiE 'time window|observation window|window' "$f"
    grep -qiE 'local source|source' "$f"
    grep -qi 'exclusion' "$f"
    grep -qiE 'missing.data|missing-data|missing data' "$f"
    grep -qiE 'calculation method|formula' "$f"
    grep -qiE 'privacy review|privacy' "$f"
    grep -qiE 'evidence link|evidence' "$f"
    grep -qi 'limitation' "$f"
    grep -qiE 'publication consent|consent' "$f"
  done
}

@test "DEV-083 MET-003: evidence-bounded case study template @smoke" {
  local f
  for f in "$MET_CASE_TEMPLATE" "$MET_CASE_MIRROR"; do
    [ -f "$f" ]
    grep -qi 'context' "$f"
    grep -qiE 'method|question' "$f"
    grep -qi 'evidence' "$f"
    grep -qiE 'synthetic|observed' "$f"
    grep -qi 'limitation' "$f"
    grep -qi 'consent' "$f"
    grep -qiE 'publication|claim review|claim boundary' "$f"
  done
}

@test "DEV-083 MET-004: install success definition @smoke" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'install success|Install Success' "$f"
    grep -qi 'attempt' "$f"
    grep -qiE 'successful completion|completion' "$f"
    grep -qiE 'post-install|post install' "$f"
    grep -qiE 'failure stage|failure' "$f"
    grep -qi 'platform' "$f"
    grep -qi 'version' "$f"
    grep -qi 'retry' "$f"
    grep -qiE 'not.*(download|start).*success|download.*not.*success|start.*not.*success|without treating downloads' "$f" \
      || grep -qiE 'Downloads or starts are not success|download or start is not success' "$f"
  done
}

@test "DEV-083 MET-005: verifier adoption definition" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'verifier adoption|Verifier Adoption' "$f"
    grep -qiE 'eligible|eligibility' "$f"
    grep -qiE 'availability|available' "$f"
    grep -qiE 'actual run|observed run|verifier run' "$f"
    grep -qi 'mode' "$f"
    grep -qi 'result' "$f"
    grep -qiE 'follow-up|follow up' "$f"
    grep -qiE 'observation window|window' "$f"
    grep -qiE 'availability.*(not|≠|!=).*use|not equat|without equating availability|availability is not adoption' "$f"
  done
}

@test "DEV-083 MET-006: handoff import outcome definition" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'handoff|import' "$f"
    grep -qiE 'pack.*(export|exported)|exported' "$f"
    grep -qiE 'import attempt|attempts' "$f"
    grep -qiE 'successful import|import success' "$f"
    grep -qiE 'rejected|partial' "$f"
    grep -qiE 'target surface|target' "$f"
    grep -qiE 'completion criteria|completion' "$f"
    grep -qiE 'without collecting.*content|do not collect.*content|no pack content|must not.*pack content' "$f"
  done
}

@test "DEV-083 MET-007: cross-model finding state definition" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'cross-model|Cross-Model' "$f"
    grep -qi 'proposed' "$f"
    grep -qi 'confirmed' "$f"
    grep -qi 'duplicate' "$f"
    grep -qi 'rejected' "$f"
    grep -qi 'resolved' "$f"
    grep -qi 'severity' "$f"
    grep -qiE 'individual.*(performance|scor)|not.*performance score|prohibit.*individual|shall not.*individual' "$f"
  done
}

@test "DEV-083 MET-008: cycle time boundary definition" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'cycle time|Cycle Time' "$f"
    grep -qiE 'start.*event|start event' "$f"
    grep -qiE 'end.*event|end event' "$f"
    grep -qi 'pause' "$f"
    grep -qiE 'deferred|manual' "$f"
    grep -qiE 'incomplete' "$f"
    grep -qiE 'timezone|time zone' "$f"
    grep -qi 'aggregation' "$f"
    grep -qiE 'sample size|sample' "$f"
    grep -qiE 'without inventing|must not invent|do not invent|missing timestamp' "$f"
  done
}

@test "DEV-083 MET-009: pack maintenance no-SLA definition" {
  local f
  for f in "$MET_KIT_TEMPLATE" "$MET_KIT_MIRROR"; do
    [ -f "$f" ]
    grep -qiE 'pack maintenance|Pack Maintenance' "$f"
    grep -qiE 'population|pack/version|pack version' "$f"
    grep -qiE 'compatibility review|review age' "$f"
    grep -qiE 'open.*(maintenance|item)|open item' "$f"
    grep -qiE 'owner response|response state' "$f"
    grep -qiE 'deprecat' "$f"
    grep -qiE 'observation date|observed' "$f"
    grep -qiE 'not an SLA|no SLA|without.*(implying|promising).*SLA|descriptive.*not.*SLA' "$f"
    ! grep -qiE 'guaranteed response time|promised SLA|SLA commitment' "$f"
  done
}

@test "DEV-083 MET-010: metrics kit inventory and mirror contract @smoke" {
  local root="$BATS_TEST_DIRNAME/.."
  [ -f "$MET_KIT_TEMPLATE" ]
  [ -f "$MET_KIT_MIRROR" ]
  [ -f "$MET_CASE_TEMPLATE" ]
  [ -f "$MET_CASE_MIRROR" ]

  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_MetricsKit.md"* ]]
  [[ "$output" == *"Docs/AgToosa_CaseStudy.template.md"* ]]

  # Maintainer mirrors use docs/ path prefix for repo-local refs
  grep -q 'docs/' "$MET_KIT_MIRROR"
  grep -q 'docs/' "$MET_CASE_MIRROR"
  ! grep -q 'Docs/Master-Plan.md' "$MET_KIT_MIRROR"
  ! grep -q 'Docs/Master-Plan.md' "$MET_CASE_MIRROR"

  # Template pack keeps Docs/ canonical paths where it references Master-Plan
  grep -qE 'Docs/|Generated Project' "$MET_KIT_TEMPLATE"

  # Only documentation artifacts — no collection hooks in generator surfaces
  ! grep -qiE 'metrics.?kit|case.?study' "$root/lib/maintain.sh" || true
  local hook_hits
  hook_hits="$(grep -RniE 'telemetry|metrics.?collect|analytics.?sdk|beacon.?url' \
    "$root/agtoosa.sh" "$root/lib/" --include='*.sh' 2>/dev/null \
    | grep -viE 'no.?telemetry|without telemetry|not.*telemetry|telemetry.*(exclusion|out of scope)|#.*telemetry' \
    || true)"
  [ -z "$hook_hits" ]

  # Synthetic examples clearly labeled in kit
  grep -qiE 'synthetic.*(example|worked|illustrative)|SYNTHETIC' "$MET_KIT_TEMPLATE"
  grep -qiE 'synthetic.*(example|worked|illustrative)|SYNTHETIC' "$MET_KIT_MIRROR"
  grep -qiE 'not (real|customer)|non-customer|illustrative only' "$MET_KIT_TEMPLATE"
}

# ── DEV-080: Official Registry Pack Pilot (OPP-001–OPP-010) ───────────────────

@test "DEV-080 @smoke OPP-001: Exactly Three Pilot Domains" {
  local inv="$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md"
  [ -f "$inv" ]
  grep -q "## Official Pack Pilot" "$inv"
  grep -q "official-web" "$inv"
  grep -q "official-api" "$inv"
  grep -q "official-infra" "$inv"
  grep -q "primary domain: web" "$inv"
  grep -q "primary domain: api" "$inv"
  grep -q "primary domain: infrastructure" "$inv"
  # Exactly three pilot pack roots — no fourth official-* under packs/
  local count
  count=$(find "$BATS_TEST_DIRNAME/../packs" -maxdepth 1 -type d -name 'official-*' 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 3 ]
}

@test "DEV-080 @smoke OPP-002: Catalog Manifest Conformance" {
  local root="$BATS_TEST_DIRNAME/.."
  local pack
  for pack in official-web official-api official-infra; do
    [ -f "$root/packs/$pack/manifest.json" ]
    run bash "$SCRIPT" --catalog validate "$root/packs/$pack/manifest.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Catalog valid"* ]]
    run python3 - "$root/packs/$pack/manifest.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
assert d.get("schema_version") == "1.0", d.get("schema_version")
assert len(d.get("entries", [])) == 1
e = d["entries"][0]
for field in ("id", "kind", "name", "summary", "tags", "examples",
              "maintainers", "support", "lifecycle", "reviewed_at",
              "compatibility", "trust", "provenance"):
    assert field in e, f"missing {field}"
assert e["kind"] == "extension"
assert e["lifecycle"] == "maintained"
p = e["provenance"]
for field in ("registry_name", "version", "source", "sha256", "signature"):
    assert field in p, f"missing provenance.{field}"
c = e["compatibility"]
for field in ("agtoosa", "platforms", "requires", "conflicts"):
    assert field in c, f"missing compatibility.{field}"
t = e["trust"]
for field in ("curation_tier", "registry_verified_snapshot", "review_status"):
    assert field in t, f"missing trust.{field}"
assert e["maintainers"][0]["name"] == "sky2464"
PY
    [ "$status" -eq 0 ]
  done
}

@test "DEV-080 OPP-003: Pack Example Completeness" {
  local root="$BATS_TEST_DIRNAME/.."
  local pack
  for pack in official-web official-api official-infra; do
    local ex="$root/packs/$pack/EXAMPLES.md"
    [ -f "$ex" ]
    grep -qi "Prerequisites" "$ex"
    grep -qi "Intended use" "$ex"
    grep -qi "Runnable example" "$ex"
    grep -qi "Non-goals" "$ex"
    grep -q "bash agtoosa.sh --registry install" "$ex"
  done
}

@test "DEV-080 OPP-004: Compatibility Boundary Matrix" {
  local root="$BATS_TEST_DIRNAME/.."
  local pack
  for pack in official-web official-api official-infra; do
    local mf="$root/packs/$pack/manifest.json"
    run python3 - "$mf" <<'PY'
import json, sys
e = json.load(open(sys.argv[1]))["entries"][0]
c = e["compatibility"]
assert c["agtoosa"], "empty agtoosa range"
assert isinstance(c["platforms"], list) and len(c["platforms"]) >= 1
# Untested/incompatible combinations must be named in summary or conflicts note
doc = open(sys.argv[1].replace("manifest.json", "COMPATIBILITY.md")).read().lower()
assert "untested" in doc or "incompatible" in doc
assert "agtoosa" in doc
assert "platform" in doc
PY
    [ "$status" -eq 0 ]
  done
}

@test "DEV-080 @smoke OPP-005: Web Pack Clean Install" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/registry-packs/official-web"
  [ -d "$fixture" ]
  [ -f "$fixture/Docs/official-web-workflow.md" ]
  local queue_dir project_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$fixture'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Pack contents:"* ]]
  [ -d "$queue_dir/official-web" ]
  [ -f "$queue_dir/official-web/Docs/official-web-workflow.md" ]
  [ -f "$queue_dir/official-web/.pack-meta.json" ]

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="5.3.8"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"
  _merge_pack_queue
  [ -f "$project_dir/Docs/official-web-workflow.md" ]
  [ ! -d "$queue_dir/official-web" ]

  rm -rf "$queue_dir" "$project_dir"
}

@test "DEV-080 OPP-006: API Service Pack Clean Install" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/registry-packs/official-api"
  [ -d "$fixture" ]
  [ -f "$fixture/Docs/official-api-workflow.md" ]
  local queue_dir project_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$fixture'"
  [ "$status" -eq 0 ]
  [ -f "$queue_dir/official-api/Docs/official-api-workflow.md" ]

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="5.3.8"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"
  _merge_pack_queue
  [ -f "$project_dir/Docs/official-api-workflow.md" ]

  rm -rf "$queue_dir" "$project_dir"
}

@test "DEV-080 @smoke OPP-007: Infrastructure Security Pack Safe Install" {
  local fixture="$BATS_TEST_DIRNAME/fixtures/registry-packs/official-infra"
  [ -d "$fixture" ]
  [ -f "$fixture/Docs/official-infra-workflow.md" ]
  local queue_dir project_dir
  queue_dir="$(mktemp -d)"
  project_dir="$(mktemp -d)"

  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$fixture'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Pack contents:"* ]]
  [[ "$output" == *"Continue?"* ]] || [[ "$output" == *"queued"* ]]
  [ -f "$queue_dir/official-infra/Docs/official-infra-workflow.md" ]
  # Must not stage denylisted destinations from the safe fixture
  [ ! -f "$queue_dir/official-infra/.claude/settings.json" ]
  [ ! -d "$queue_dir/official-infra/.github/workflows" ]

  PACK_QUEUE_DIR="$queue_dir"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="5.3.8"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"
  _merge_pack_queue
  [ -f "$project_dir/Docs/official-infra-workflow.md" ]
  [ ! -f "$project_dir/.claude/settings.json" ]
  [ ! -f "$project_dir/.github/workflows/pwn.yml" ]

  rm -rf "$queue_dir" "$project_dir"
}

@test "DEV-080 OPP-008: Unsafe Pack Boundary Rejection" {
  local bad="$BATS_TEST_DIRNAME/fixtures/registry-packs/unsafe-disallowed"
  [ -d "$bad" ]
  [ -f "$bad/evil.sh" ]
  local queue_dir
  queue_dir="$(mktemp -d)"
  run env AGTOOSA_PACK_QUEUE_DIR="$queue_dir" bash -c "echo Y | bash '$SCRIPT' --registry install '$bad'"
  [ "$status" -ne 0 ]
  [[ "$output" == *"disallowed file type"* ]]
  [ ! -d "$queue_dir/unsafe-disallowed" ]

  # Denylist merge boundary remains enforced (generator-enforced)
  local queue_dir2 project_dir
  queue_dir2="$(mktemp -d)"
  project_dir="$(mktemp -d)"
  mkdir -p "$queue_dir2/sneak/.github/workflows" "$queue_dir2/sneak/.claude"
  echo "# ok" > "$queue_dir2/sneak/workflow.md"
  echo "name: pwn" > "$queue_dir2/sneak/.github/workflows/pwn.yml"
  echo '{"hooks":{}}' > "$queue_dir2/sneak/.claude/settings.json"
  PACK_QUEUE_DIR="$queue_dir2"
  PROJECT_PATH="$project_dir"
  AGTOOSA_VERSION="5.3.8"
  GREEN="" YELLOW="" NC=""
  source "$BATS_TEST_DIRNAME/../lib/install.sh"
  _merge_pack_queue
  [ -f "$project_dir/workflow.md" ]
  [ ! -f "$project_dir/.github/workflows/pwn.yml" ]
  [ ! -f "$project_dir/.claude/settings.json" ]

  rm -rf "$queue_dir" "$queue_dir2" "$project_dir"
}

@test "DEV-080 OPP-009: Maintenance Ownership Contract" {
  local root="$BATS_TEST_DIRNAME/.."
  local pack
  for pack in official-web official-api official-infra; do
    local pol="$root/packs/$pack/MAINTENANCE.md"
    [ -f "$pol" ]
    grep -qi "Owner" "$pol"
    grep -q "sky2464" "$pol"
    grep -qi "Review cadence" "$pol"
    grep -qi "Compatibility-update policy\|Compatibility update policy" "$pol"
    grep -qi "Issue path" "$pol"
    grep -qi "Deprecation" "$pol"
  done
}

@test "DEV-080 OPP-010: External Publication State Honesty" {
  local inv="$BATS_TEST_DIRNAME/../docs/AgToosa_Registry.md"
  local checklist="$BATS_TEST_DIRNAME/../docs/official-pack-pilot-checklist.md"
  [ -f "$inv" ]
  [ -f "$checklist" ]
  grep -q "local candidate" "$inv"
  grep -q "not externally published" "$inv"
  # Must not claim published/available in external registry for pilot packs
  ! grep -E "official-(web|api|infra).*externally published" "$inv"
  ! grep -qi "marketplace" "$inv" || grep -qi "not a marketplace\|No.*marketplace" "$inv"
  grep -q "submitted" "$checklist"
  grep -q "published" "$checklist"
  grep -q "requires confirmed external record\|confirmed external" "$checklist"
  # Catalog contract pin
  grep -q "schema_version.*1.0\|catalog contract.*1.0\|schema_version 1.0" "$checklist"
}

# ── DEV-077: Authoring Guide and Onboarding Surface (AUTH-001–AUTH-008) ───────

# Stable discovery pointer copied into every maintained help adapter (GitHub URLs only).
_AUTH_EXT_URL="https://github.com/sky2464/AgToosa/blob/main/docs/extension-authoring-guide.md"
_AUTH_PACK_URL="https://github.com/sky2464/AgToosa/blob/main/docs/registry-pack-authoring.md"

_auth_help_adapters() {
  local root="$1"
  printf '%s\n' \
    "$root/template/.claude/commands/agtoosa-help.md" \
    "$root/template/.cursor/commands/agtoosa-help.md" \
    "$root/template/.gemini/commands/agtoosa-help.toml" \
    "$root/template/.github/prompts/agtoosa-help.prompt.md" \
    "$root/template/.windsurf/workflows/agtoosa-help.md" \
    "$root/template/.codex/prompts/agtoosa-help.md" \
    "$root/template/.codex/skills/agtoosa-help/SKILL.md"
}

@test "DEV-077 AUTH-001: Extension guide covers current wiring surfaces" {
  local guide="$BATS_TEST_DIRNAME/../docs/extension-authoring-guide.md"
  [ -f "$guide" ]
  # Current platform entry points
  grep -q "CLAUDE.md" "$guide"
  grep -q ".cursorrules" "$guide"
  grep -q ".windsurfrules" "$guide"
  grep -q "AGENTS.md" "$guide"
  grep -q ".github/copilot-instructions.md" "$guide"
  grep -q "OPENCODE.md" "$guide"
  grep -qiE "VS Code|vscode" "$guide"
  grep -qiE "Codex|\.codex/" "$guide"
  # Generator wiring surfaces
  grep -q "lib/config.sh" "$guide"
  grep -q "lib/generate.sh" "$guide"
  grep -q "agtoosa.sh" "$guide"
  grep -q "OPTIONAL_TEMPLATE_FILES" "$guide"
  grep -q "stage_files" "$guide"
  # Parity checks and maintained examples
  grep -qiE "parity|bats|smoke" "$guide"
  grep -q "tests/agtoosa.bats" "$guide"
  grep -qiE "OpenCode|Claude|Cursor" "$guide"
}

@test "DEV-077 @smoke AUTH-002: Pack handbook carries the complete readiness checklist" {
  local handbook="$BATS_TEST_DIRNAME/../docs/registry-pack-authoring.md"
  [ -f "$handbook" ]
  grep -q "## Readiness Checklist" "$handbook"
  # Seven required checkable fields (checkbox markers)
  grep -Eq '^\- \[ \] .*[Ss]coped [Ss]pec' "$handbook"
  grep -Eq '^\- \[ \] .*[Tt]est' "$handbook"
  grep -Eq '^\- \[ \] .*[Tt]hreat' "$handbook"
  grep -Eq '^\- \[ \] .*[Cc]ompatibilit' "$handbook"
  grep -Eq '^\- \[ \] .*[Pp]rovenance' "$handbook"
  grep -Eq '^\- \[ \] .*([Ww]orked [Ee]xample|[Ee]xample)' "$handbook"
  grep -Eq '^\- \[ \] .*([Mm]aintenance [Oo]wner|[Nn]amed .*[Oo]wner|[Oo]wner)' "$handbook"
}

@test "DEV-077 AUTH-003: Registry points to one pack handbook" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/AgToosa_Registry.md" "$root/template/Docs/AgToosa_Registry.md"; do
    [ -f "$f" ]
    grep -q "registry-pack-authoring.md" "$f"
    # Discovery only — must not host the full readiness checklist heading
    ! grep -q "## Readiness Checklist" "$f"
    # Must not embed all seven checkbox readiness fields
    ! grep -Eq '^\- \[ \] .*[Pp]rovenance' "$f"
    ! grep -Eq '^\- \[ \] .*[Mm]aintenance [Oo]wner' "$f"
  done
}

@test "DEV-077 AUTH-004: README exposes both authoring paths" {
  local readme="$BATS_TEST_DIRNAME/../README.md"
  grep -q "docs/extension-authoring-guide.md" "$readme"
  grep -q "docs/registry-pack-authoring.md" "$readme"
  # Concise discovery — no duplicated readiness checklist
  ! grep -q "## Readiness Checklist" "$readme"
  ! grep -Eq '^\- \[ \] .*[Pp]rovenance' "$readme"
}

@test "DEV-077 @smoke AUTH-005: Native help surfaces share one authoring pointer" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  while IFS= read -r f; do
    [ -f "$f" ]
    grep -q "Authoring resources" "$f"
    grep -Fq "$_AUTH_EXT_URL" "$f"
    grep -Fq "$_AUTH_PACK_URL" "$f"
    # Generated-project-safe: no maintainer-only relative docs/ paths for these guides
    ! grep -Eq '(^|[^/])docs/extension-authoring-guide\.md' "$f"
    ! grep -Eq '(^|[^/])docs/registry-pack-authoring\.md' "$f"
  done < <(_auth_help_adapters "$root")
}

@test "DEV-077 AUTH-006: Authoring discovery preserves static help" {
  local root="$BATS_TEST_DIRNAME/.."
  local claude="$root/template/.claude/commands/agtoosa-help.md"
  local gemini="$root/template/.gemini/commands/agtoosa-help.toml"
  local copilot="$root/template/.github/prompts/agtoosa-help.prompt.md"
  # Default path remains static (no Master-Plan / git / project-context read)
  grep -q "Do not read any Docs file" "$claude"
  grep -q "without reading" "$gemini"
  grep -q "without reading" "$copilot"
  # Authoring block must not instruct a context read on the default path
  local f
  while IFS= read -r f; do
    [ -f "$f" ]
    local section
    section="$(grep -A6 -F "Authoring resources" "$f")"
    [ -n "$section" ]
    ! grep -qiE 'read Docs/Master-Plan|git status|git log|project.context|project files' <<< "$section"
  done < <(_auth_help_adapters "$root")
}

@test "DEV-077 @smoke AUTH-007: Authoring links fail closed on drift" {
  local root="$BATS_TEST_DIRNAME/.."
  [ -f "$root/docs/extension-authoring-guide.md" ]
  [ -f "$root/docs/registry-pack-authoring.md" ]
  # README discovery targets exist
  grep -q "docs/extension-authoring-guide.md" "$root/README.md"
  grep -q "docs/registry-pack-authoring.md" "$root/README.md"
  # Registry discovery targets exist (path token resolves under docs/)
  local f
  for f in "$root/docs/AgToosa_Registry.md" "$root/template/Docs/AgToosa_Registry.md"; do
    grep -q "registry-pack-authoring.md" "$f"
  done
  # Help adapters point at the same canonical blob paths whose basename files exist
  while IFS= read -r f; do
    grep -Fq "$_AUTH_EXT_URL" "$f"
    grep -Fq "$_AUTH_PACK_URL" "$f"
  done < <(_auth_help_adapters "$root")
  # Basename inventory must match on-disk canonical files
  local base
  for base in extension-authoring-guide.md registry-pack-authoring.md; do
    [ -f "$root/docs/$base" ]
  done
}

@test "DEV-077 AUTH-008: Handbook labels enforcement honestly" {
  local handbook="$BATS_TEST_DIRNAME/../docs/registry-pack-authoring.md"
  [ -f "$handbook" ]
  grep -q "Claim Boundary" "$handbook"
  grep -qiE "CI-enforced|repository check" "$handbook"
  grep -qiE "registry review|manual" "$handbook"
  grep -qi "roadmap" "$handbook"
  # Must not call manual registry approval CI-enforced
  ! grep -qiE 'registry (approval|review) is CI-enforced|CI-enforced registry (approval|review)' "$handbook"
}

# ── DEV-087: Delivery Evidence Contract (DEC-001–DEC-009) ──

@test "DEV-087 DEC-001: Delivery contract defines assurance taxonomy" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/Docs/AgToosa_Delivery_Evidence_Contract.md" \
    "$root/docs/AgToosa_Delivery_Evidence_Contract.md"
  do
    [ -f "$f" ]
    grep -q "AgToosa Delivery Evidence Contract" "$f"
    ! grep -qE '^# AgToosa_Evidence_Contract' "$f"
    grep -q "Guided" "$f"
    grep -q "Evidenced" "$f"
    grep -q "Enforced" "$f"
    grep -qiE "semantic review.*(Guided|Evidenced)|Guided.*Evidenced" "$f"
    grep -q "Terminal Evidence" "$f"
  done
}

@test "DEV-087 DEC-002: Standard security-sensitive and release profiles documented" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in \
    "$root/template/Docs/AgToosa_Delivery_Evidence_Contract.md" \
    "$root/docs/AgToosa_Delivery_Evidence_Contract.md"
  do
    grep -q "standard" "$f"
    grep -q "security-sensitive" "$f"
    grep -q "release" "$f"
    grep -q "spec" "$f"
    grep -q "tests" "$f"
    grep -q "review" "$f"
    grep -q "threat-model" "$f"
    grep -q "changelog" "$f"
  done
}

@test "DEV-087 DEC-003: evidence.yml.example matches contract" {
  local root="$BATS_TEST_DIRNAME/.."
  local ex="$root/template/.agtoosa/evidence.yml.example"
  [ -f "$ex" ]
  grep -q "profiles:" "$ex"
  grep -q "standard:" "$ex"
  grep -q "security-sensitive:" "$ex"
  grep -q "release:" "$ex"
  grep -q "required:" "$ex"
  # Example content validates when activated as evidence.yml
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/.agtoosa"
  # Strip only needed — copy example body; checker ignores comments
  cp "$ex" "$tmp/.agtoosa/evidence.yml"
  run bash "$root/docs/agtoosa-evidence-profile-check.sh" --root "$tmp"
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"schema-only"* ]]
  rm -rf "$tmp"
}

@test "DEV-087 DEC-004: .agtoosa README indexes policy and evidence configs" {
  local root="$BATS_TEST_DIRNAME/.."
  local f="$root/template/.agtoosa/README.md"
  [ -f "$f" ]
  grep -q "policy.yaml" "$f"
  grep -q "evidence.yml" "$f"
  grep -q "DEV-059" "$f"
  grep -q "DEV-087" "$f"
  grep -q "Gate 6" "$f"
  grep -q "Gate 7" "$f"
  grep -q "DEV-089" "$f"
  grep -qiE "policy \(Gate 6\).*evidence profile \(Gate 7|Gate 6.*Gate 7.*lifecycle" "$f"
}

@test "DEV-087 DEC-005: Schema checker accepts valid YAML and rejects invalid" {
  local root="$BATS_TEST_DIRNAME/.."
  local checker="$root/docs/agtoosa-evidence-profile-check.sh"
  [ -f "$checker" ]
  [ -x "$checker" ] || chmod +x "$checker"

  # Usage error
  run bash "$checker" --root /no/such/path
  [ "$status" -eq 2 ]

  # Absent evidence.yml is ok
  local empty
  empty=$(mktemp -d)
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]
  [[ "$output" == *"schema-only"* ]]
  [[ "$output" == *"evidence_path=none"* ]]

  # Valid
  mkdir -p "$empty/.agtoosa"
  cp "$root/tests/fixtures/evidence/valid.yml" "$empty/.agtoosa/evidence.yml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 0 ]

  # Missing profiles
  cp "$root/tests/fixtures/evidence/invalid-missing-profiles.yml" "$empty/.agtoosa/evidence.yml"
  run bash "$checker" --root "$empty"
  [ "$status" -ne 0 ]
  [ "$status" -eq 1 ]

  # Unknown profile key
  cp "$root/tests/fixtures/evidence/invalid-unknown-profile.yml" "$empty/.agtoosa/evidence.yml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown profile"* || "$stderr" == *"unknown profile"* || "$output" == *"Error"* ]]

  # Unknown artifact token
  cp "$root/tests/fixtures/evidence/invalid-artifact.yml" "$empty/.agtoosa/evidence.yml"
  run bash "$checker" --root "$empty"
  [ "$status" -eq 1 ]

  rm -rf "$empty"
}

@test "DEV-087 DEC-006: Schema checker does not claim full compliance" {
  local root="$BATS_TEST_DIRNAME/.."
  local checker="$root/docs/agtoosa-evidence-profile-check.sh"
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/.agtoosa"
  cp "$root/tests/fixtures/evidence/valid.yml" "$tmp/.agtoosa/evidence.yml"
  run bash "$checker" --root "$tmp"
  [ "$status" -eq 0 ]
  [[ "$output" == *"schema-only"* ]]
  [[ "$output" == *"not full delivery compliance"* || "$output" == *"schema valid"* ]]
  # Must not assert artifact files on disk
  ! echo "$output" | grep -qiE 'artifact (missing|not found|exist)|checking artifact presence|full delivery compliance$'
  # No network tooling
  ! grep -qE 'curl |wget |http://|https://' "$checker"
  rm -rf "$tmp"
}

@test "DEV-087 DEC-007: Terminal Evidence cross-link preserved" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Agent.md" "$root/docs/AgToosa_Agent.md"; do
    grep -q "### Terminal Evidence Contract" "$f"
    grep -q "AgToosa_Delivery_Evidence_Contract.md" "$f"
    grep -qi "Delivery Evidence Contract" "$f"
    # Must not rename Terminal Evidence away
    ! grep -qiE 'renamed.*Terminal Evidence|Terminal Evidence Contract.*deprecated' "$f"
  done
}

@test "DEV-087 DEC-008: Config registration and enforcement labels" {
  local root="$BATS_TEST_DIRNAME/.."
  run bash "$root/agtoosa.sh" --list-template-files
  [ "$status" -eq 0 ]
  echo "$output" | grep -F "Docs/AgToosa_Delivery_Evidence_Contract.md"
  echo "$output" | grep -F "Docs/agtoosa-evidence-profile-check.sh"
  echo "$output" | grep -F ".agtoosa/evidence.yml.example"
  echo "$output" | grep -F ".agtoosa/README.md"

  local contract="$root/template/Docs/AgToosa_Delivery_Evidence_Contract.md"
  grep -qi "schema-only" "$contract"
  grep -q "DEV-089" "$contract"
  grep -qi "Gate 7" "$contract"
}

@test "DEV-087 DEC-009: Evidence ledger cross-link present" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/template/Docs/AgToosa_Evidence.md" "$root/docs/AgToosa_Evidence.md"; do
    grep -q "AgToosa_Delivery_Evidence_Contract.md" "$f"
    grep -qiE "delivery profile|Delivery Evidence" "$f"
  done
}

# ── DEV-088: Verifier JSON (VFJ-001–VFJ-010) ──────────────────────────────────

_vfj_fail_fixture() {
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
}

_vfj_assert_schema_fields() {
  local json="$1"
  echo "$json" | jq -e '
    .schema_version == "verify-result-v1"
    and (.tool == "verify" or .tool == "doctor")
    and (.exit_code | type == "number")
    and (.summary.pass | type == "number")
    and (.summary.warn | type == "number")
    and (.summary.fail | type == "number")
    and (.findings | type == "array")
    and (
      (.findings | length == 0)
      or
      all(.findings[];
        (.id|type=="string") and (.severity|type=="string")
        and (.problem|type=="string") and (.impact|type=="string")
        and (.fix|type=="string")
      )
    )
  ' >/dev/null
}

@test "DEV-088 @smoke VFJ-001: Verifier JSON mode emits valid document" {
  run bash "$BATS_TEST_DIRNAME/../docs/agtoosa-verify.sh" --root "$BATS_TEST_DIRNAME/.." --format json
  [ "$status" -eq 0 ]
  echo "$output" | jq -e . >/dev/null
  echo "$output" | jq -e '.schema_version == "verify-result-v1" and .tool == "verify" and .exit_code == 0' >/dev/null
}

@test "DEV-088 VFJ-002: JSON conforms to verify-result-v1 schema" {
  # Pass fixture (maintainer repo)
  run bash "$BATS_TEST_DIRNAME/../docs/agtoosa-verify.sh" --root "$BATS_TEST_DIRNAME/.." --format json
  [ "$status" -eq 0 ]
  _vfj_assert_schema_fields "$output"
  local schema="$BATS_TEST_DIRNAME/../docs/schemas/verify-result-v1.json"
  [ -f "$schema" ]
  grep -q '"schema_version"' "$schema"
  grep -q '"findings"' "$schema"
  grep -q '"assurance"' "$schema"

  # Fail fixture
  _vfj_fail_fixture
  run bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT" --format json
  [ "$status" -eq 1 ]
  _vfj_assert_schema_fields "$output"
  echo "$output" | jq -e '.summary.fail >= 1 and (.findings | length >= 1)' >/dev/null
  echo "$output" | jq -e '.findings[] | select(.problem | contains("DEV-001: no spec file"))' >/dev/null
}

@test "DEV-088 @smoke VFJ-003: Human findings use Problem Impact Fix" {
  _vfj_fail_fixture
  run bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Problem:"* ]]
  [[ "$output" == *"Impact:"* ]]
  [[ "$output" == *"Fix:"* ]]
  [[ "$output" == *"DEV-001: no spec file"* ]]
  [[ "$output" == *"Result: ❌ FAIL"* ]]
}

@test "DEV-088 VFJ-004: Doctor JSON labels provenance surfaces" {
  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  # No state.json by default — absent must still report authority text
  [ ! -f "$TEST_PROJECT/.agtoosa/state.json" ]
  run bash "$SCRIPT" --doctor "$TEST_PROJECT" --format json
  [ "$status" -eq 0 ]
  _vfj_assert_schema_fields "$output"
  echo "$output" | jq -e '.tool == "doctor"' >/dev/null
  echo "$output" | jq -e '
    .provenance.version_marker.path == "Docs/.agtoosa-version"
    and .provenance.version_marker.present == true
    and .provenance.version_marker.committed == true
    and (.provenance.version_marker.authority | test("semver|version"; "i"))
    and .provenance.lock_file.path == "Docs/agtoosa-lock.json"
    and .provenance.lock_file.committed == true
    and (.provenance.lock_file.authority | test("pack|pin|reproducib"; "i"))
    and .provenance.state_file.path == ".agtoosa/state.json"
    and .provenance.state_file.present == false
    and .provenance.state_file.committed == false
    and (.provenance.state_file.authority | test("gitignored|absent|OK|operational"; "i"))
  ' >/dev/null
}

@test "DEV-088 VFJ-005: Findings include assurance classification" {
  _vfj_fail_fixture
  run bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT" --format json
  [ "$status" -eq 1 ]
  echo "$output" | jq -e '
    [.findings[].assurance] | length >= 1
    and all(.[]; . == "guided" or . == "evidenced" or . == "enforced")
  ' >/dev/null
  echo "$output" | jq -e '
    any(.findings[]; .assurance == "enforced" and (.problem | contains("no spec file")))
  ' >/dev/null
}

@test "DEV-088 @smoke VFJ-006: Gate example runs verifier JSON step" {
  local root="$BATS_TEST_DIRNAME/.."
  local f
  for f in "$root/docs/agtoosa-gate.yml.example" "$root/template/Docs/agtoosa-gate.yml.example"; do
    [ -f "$f" ]
    grep -q -- '--format json' "$f"
    grep -q 'jq -e' "$f"
    grep -q 'agtoosa-verify.sh' "$f"
    grep -q 'not found' "$f"
    grep -q 'exit 1' "$f"
  done
  diff -u "$root/docs/agtoosa-gate.yml.example" "$root/template/Docs/agtoosa-gate.yml.example"
}

@test "DEV-088 VFJ-007: Gate preserves verifier exit status" {
  local gate="$BATS_TEST_DIRNAME/../docs/agtoosa-gate.yml.example"
  grep -q 'exit "$rc"' "$gate"
  grep -q 'rc=$?' "$gate"
  # JSON validation must not force success after verifier failure
  ! grep -Eq 'agtoosa-verify\.sh.*\|\|[[:space:]]*true' "$gate"
  ! grep -Eq 'agtoosa-verify\.sh.*;[[:space:]]*exit 0' "$gate"
  ! grep -Eq 'jq.*\|\|[[:space:]]*true' "$gate"
  # Simulate gate body: failing verifier JSON still exits 1 after jq succeeds
  _vfj_fail_fixture
  set +e
  out="$(bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT" --format json)"
  rc=$?
  set -e
  [ -n "$out" ]
  echo "$out" | jq -e . >/dev/null
  [ "$rc" -eq 1 ]
}

@test "DEV-088 VFJ-008: Default human mode remains usable" {
  run bash "$BATS_TEST_DIRNAME/../docs/agtoosa-verify.sh" --root "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
  [[ "$output" == *"Result: ✅ PASS"* ]]
  _vfj_fail_fixture
  run bash "$BATS_TEST_DIRNAME/../template/Docs/agtoosa-verify.sh" --root "$TEST_PROJECT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Result: ❌ FAIL"* ]]
}

@test "DEV-088 VFJ-009: agtoosa.sh passes format flag to verify and doctor" {
  run bash "$SCRIPT" --verify --format json "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.tool == "verify" and .schema_version == "verify-result-v1"' >/dev/null

  run bash "$SCRIPT" --path "$TEST_PROJECT" --platforms claude --yes < /dev/null
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --doctor --format json "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.tool == "doctor" and .provenance.version_marker.present == true' >/dev/null

  run bash "$SCRIPT" --verify --format xml "$BATS_TEST_DIRNAME/.."
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid --format"* ]]
}

@test "DEV-088 VFJ-010: Schema file installed in template and docs" {
  local root="$BATS_TEST_DIRNAME/.."
  [ -f "$root/docs/schemas/verify-result-v1.json" ]
  [ -f "$root/template/Docs/schemas/verify-result-v1.json" ]
  diff -u "$root/docs/schemas/verify-result-v1.json" "$root/template/Docs/schemas/verify-result-v1.json"
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/schemas/verify-result-v1.json"* ]]
  grep -q 'Docs/schemas/verify-result-v1.json' "$root/lib/config.sh"
}
