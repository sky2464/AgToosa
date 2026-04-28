# Changelog

All notable changes to AgToosa will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned per [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

_(nothing yet)_

---

## [2.4.0] — 2026-05-14

### Added
- `/agtoosa-task` command (`Docs/AgToosa_Task.md`): lightweight Linear issue capture for bugs, chores, spikes, and fixes without a full spec cycle; includes type-specific DoD checklists and Discovery Triage origin tracking (DEV-167)
- Platform-native command files for `/agtoosa-task` on all 6 platforms: `.claude/commands/agtoosa-task.md`, `.cursor/rules/agtoosa-task.mdc`, `.gemini/commands/agtoosa-task.toml`, `.github/prompts/agtoosa-task.prompt.md`, `.windsurf/rules/agtoosa-task.md`, `.roo/rules/agtoosa-task.md`
- Linear Issue Standard anatomy in `AgToosa_Agent.md`: canonical title format `[Type]: [description]`, required description sections (Context, Scope, ACs, DoD, Related), Epic→Story→Task hierarchy table, field defaults, Phase Comment Protocol, and Discovery Triage Protocol (DEV-164, DEV-165)
- Epic creation instructions in `/agtoosa-init` Step 9: agent now creates Linear Epic issues with correct labels/status and records IDs in `Docs/Master-Plan.md` (DEV-165)
- Story creation with T-shirt sizing and cycle enrollment in `/agtoosa-spec` Steps 9–10: agent creates a Linear Story issue (parent: Epic), records estimate, and enrolls in the active cycle if selected (DEV-165, DEV-168)
- Task sub-issue creation in `/agtoosa-build` Part 1 Step 6: agent creates Linear Task issues (parent: Story) per build task; transitions Story to `In Progress`; posts "Build 🏗️ Started" phase comment (DEV-165, DEV-166, DEV-171)
- Discovery Triage Protocol in `/agtoosa-build`: classify out-of-scope findings, size them, and route to create-issue / expand-scope / ignore — preventing silent scope creep (DEV-169)
- Status transition protocol across phase commands: Story moves `Todo → In Progress → In Review → Done` (or back) at Build/Review/Ship boundaries; rollback resets to `In Review` (DEV-166)
- Phase progress comments on Linear Story issues at every phase transition: Spec ✅ Approved, Build 🏗️ Started, Task 🟢 N/M complete, Review 🔍 Started, Review ✅/🔴 verdict, Ship 🚀 Deployed / Rollback 🔙 Triggered (DEV-171)
- Rich `Docs/Master-Plan.md` template: replaced stub with 8-section structured template (Project Charter, Epics, Active Cycle, Active Tasks, Backlog, Blocked, Completed This Cycle, Update Log) (DEV-170)
- `/agtoosa-task` added to Utility Commands table in `AgToosa_Agent.md` and to all platform entry-point "Optional utilities" lines

### Changed
- All 7 platform entry-point files updated: "Optional utility" → "Optional utilities" with both `/agtoosa-revert` and `/agtoosa-task` listed
- Help command files (`.claude/commands/agtoosa-help.md`, `.github/prompts/agtoosa-help.prompt.md`, `.gemini/commands/agtoosa-help.toml`) updated with `/agtoosa-task` row
- `lib/config.sh` `OPTIONAL_TEMPLATE_FILES` expanded with all 6 new agtoosa-task platform files; all specific platform arrays updated to match

---

## [2.3.0] — 2026-04-27

### Added
- Platform-native command files for Claude Code: `.claude/commands/` (8 slash commands — init, spec, build, qa, review, ship, revert, help), `.claude/settings.json` (Stop / PreToolUse / PostToolUse hooks), `.claude/skills/agtoosa-review.md`
- Platform-native rule files for Cursor: `.cursor/rules/` (7 MDX files — core, spec, build, qa, review, ship, revert)
- Platform-native command files for Gemini CLI: `.gemini/commands/` (8 TOML files)
- Platform-native rule files for Windsurf: `.windsurf/rules/` (7 MD files)
- Platform-native rule files for Roo: `.roo/rules/` (7 MD files)
- Platform-native prompt files for GitHub Copilot: `.github/prompts/` (8 prompt files) and `.github/agents/agtoosa.agent.md`
- Generator expansion: `lib/generate.sh` stages all new platform file sets into `ship/`; `lib/install.sh` installs them into the target project
- `lib/config.sh` — 7 new file-list arrays (`WINDSURF_RULE_FILES`, `ROO_RULE_FILES`, `GEMINI_COMMAND_FILES`, `COPILOT_PROMPT_FILES`, `COPILOT_AGENT_FILES`, `CLAUDE_HOOK_FILES`, `CLAUDE_SKILL_FILES`) and expanded `OPTIONAL_TEMPLATE_FILES`
- `merge_settings_json()` in `lib/copy.sh` — deep-merges AgToosa hooks into an existing `.claude/settings.json` without touching user settings, deduplicating by command string
- 48-test bats suite (up from ~15 at v2.2.0): coverage for all per-platform copy paths, `.claude/settings.json` hook deduplication, dry-run display, `inject_version`, `version_lt`, `backup_file`, `copy_platform_file`, and `merge_platform_file`

### Fixed
- `print_template_files()` no longer emits duplicate paths — removed redundant per-platform arrays already covered by `OPTIONAL_TEMPLATE_FILES`; CI template validation now passes (DEV-160)
- `AGTOOSA_VERSION` correctly set to `2.3.0` (regression from `2.2.0` → `2.1.1` in post-release commit) (DEV-161)

---

## [2.2.0] — 2026-04-27

### Added
- Smart merge/append for platform entry-point files (DEV-156): `inject_version()` wraps content in AgToosa START/END delimiters; `merge_platform_file()` handles 4 cases — new file, in-place block update, old-format migration, and append-to-user-file
- `.bak` backup creation and "✅ (up to date)" no-skip messaging for `merge_platform_file` (DEV-157)
- `/agtoosa-qa` slash command and `AgToosa_QA.md` workflow file
- Sub-command architecture across all four main AgToosa commands (`/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`)
- Gemini CLI / Jules platform support (`AGENTS.md`, `template/AGENTS.md`, `GEMINI.md`)
- OpenCode platform support (`template/OPENCODE.md`)
- `lib/config.sh` — extracted file-list arrays and `print_usage` / `print_template_files` helpers
- `lib/version.sh` — extracted `inject_version`, `extract_version`, and `version_lt` helpers
- CI workflow updates: shellcheck action version bump, non-portable `grep -P` fix (DEV-114)

### Fixed
- 12 generator bugs (DEV-128–139): template pollution, dotfile copy, version badge, security versions, and related issues
- Consistency fixes across README phase clarity, ship revert wording, and platform file alignment (DEV-124–126)
- `/agtoosa-build` test sub-command scope and removed broken TDD guard external link (DEV-118–119)
- Replaced bare `/plan` `/build` `/test` `/review` with `/agtoosa-*` throughout `SECURITY.md` (DEV-116)
- Defined canonical approval and review artifacts for ship readiness gate (DEV-113)
- Bug report template updated to reference `--version` flag correctly

### Changed
- ~20% token reduction across all workflow markdown files (verbosity pass)
- Linear set as canonical source of truth for all project tracking
- `Master-Plan.md` updated to reflect Linear project state and backlog management

---

## [2.1.0] — 2026-04-01

### Added
- Initial AgToosa framework: `agtoosa.sh` interactive generator
- Core workflow files: `AgToosa_Agent.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`, `AgToosa_Init.md`
- Platform entry points: `CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `.github/copilot-instructions.md`, `AGENTS.md`
- `--force`, `--dry-run`, `--version`, `--help` flags
- `install.sh` deprecated stub directing users to `agtoosa.sh`
