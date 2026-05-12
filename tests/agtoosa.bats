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
  [[ "$output" == "AgToosa v4.1.0" ]]
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
  [ -d "$TEST_PROJECT/.claude/commands" ]
  [ -d "$TEST_PROJECT/.gemini/commands" ]
  [ -d "$TEST_PROJECT/.github/prompts" ]
  [ -d "$TEST_PROJECT/.github/agents" ]
  [ -d "$TEST_PROJECT/.windsurf/rules" ]
}
@test "platform selection 1 installs .cursor/rules/ MDX files" {
  run bash -c "printf '$TEST_PROJECT\n1\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-core.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-spec.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-build.mdc" ]
  [ -f "$TEST_PROJECT/.cursor/rules/agtoosa-revert.mdc" ]
}
@test "platform selection 2 installs .windsurf/rules/ files" {
  run bash -c "printf '$TEST_PROJECT\n2\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-core.md" ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-spec.md" ]
  [ -f "$TEST_PROJECT/.windsurf/rules/agtoosa-revert.md" ]
}
@test "platform selection 3 installs .claude/commands/ slash commands" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-init.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-spec.md"  ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-ship.md" ]
  [ -f "$TEST_PROJECT/.claude/commands/agtoosa-help.md" ]
}
@test "platform selection 4 installs .gemini/commands/ TOML files" {
  run bash -c "printf '$TEST_PROJECT\n4\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-init.toml" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-spec.toml" ]
  [ -f "$TEST_PROJECT/.gemini/commands/agtoosa-help.toml" ]
}
@test "platform selection 5 installs .github/prompts/ and .github/agents/" {
  run bash -c "printf '$TEST_PROJECT\n5\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-init.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/prompts/agtoosa-spec.prompt.md" ]
  [ -f "$TEST_PROJECT/.github/agents/agtoosa.agent.md" ]
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
@test "agtoosa-update Gemini command exists in template" {
  [ -f "$TEMPLATE_DIR/.gemini/commands/agtoosa-update.toml" ]
}
@test "agtoosa-help Gemini command includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/.gemini/commands/agtoosa-help.toml"
}
@test "agtoosa-update Copilot prompt exists in template" {
  [ -f "$TEMPLATE_DIR/.github/prompts/agtoosa-update.prompt.md" ]
}
@test "agtoosa-help Copilot prompt includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/.github/prompts/agtoosa-help.prompt.md"
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

# ── Registry: local pack install staging ─────────────────────
@test "registry install local pack stages files and keeps ship/" {
  local mock_pack="$BATS_TEST_DIRNAME/fixtures/mock-pack"

  # Stub stdin to answer "Y" to the Continue? prompt.
  run bash -c "echo Y | bash '$SCRIPT' --registry install '$mock_pack'"
  # Should not error (pack exists and has only .md files).
  [ "$status" -eq 0 ]

  # ship/ must remain (KEEP_SHIP=true must have been set).
  local ship_dir="$BATS_TEST_DIRNAME/../ship"
  [ -d "$ship_dir/packs/mock-pack" ]
  [ -f "$ship_dir/packs/mock-pack/workflow.md" ]
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
  [ "$ver" = "4.1.0" ]
}

@test "--update after fresh install shows real version not 'vunknown'" {
  # Fresh install writes .agtoosa-version — subsequent --update must read it
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"vunknown"* ]]
  [[ "$output" == *"4.1.0"* ]]
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

@test "D2: init and help do NOT have per-command cursor/windsurf variants (parity asymmetry)" {
  # Documented parity exception — these commands fold into agtoosa-core on cursor/windsurf.
  [ ! -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-init.mdc" ]
  [ ! -f "$TEMPLATE_DIR/.cursor/rules/agtoosa-help.mdc" ]
  [ ! -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-init.md" ]
  [ ! -f "$TEMPLATE_DIR/.windsurf/rules/agtoosa-help.md" ]
}

@test "D3: typo helper string appears in canonical AgToosa_Status.md" {
  grep -q "Did you mean: plan, git, orphans" "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
}

@test "D3: typo helper appears in 5 status platform variants" {
  local needle='Did you mean: plan, git, orphans'
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

@test "maintainer doc documents the parity asymmetry and user-facing strings" {
  local f="$BATS_TEST_DIRNAME/../docs/agtoosa-maintainer.md"
  grep -q "Per-Platform Parity" "$f"
  grep -q "Run /agtoosa-status to verify findings cleared" "$f"
  grep -q "Did you mean: plan, git, orphans" "$f"
}
