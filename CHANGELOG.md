# Changelog

All notable changes to AgToosa will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned per [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [3.2.1] — 2026-05-04

### Fixed

- **`/agtoosa-build` full-flow blocked on approval gate** — The Part 1 scope and task-plan gates in `AgToosa_Build.md` were unconditional, causing the AI to pause and wait for user approval even when the user ran `/agtoosa-build` (full flow, which should auto-proceed into TDD). Both gates are now sub-command-aware: `/agtoosa-build scope` keeps a hard approval stop; `/agtoosa-build` (full flow) presents an informational summary and immediately continues into Part 2 without waiting.

---

## [3.2.0] — 2026-05-04

### Fixed

- **Linear hardcoded as project management source of truth** — `Docs/Master-Plan.md` was always the intended PM source of truth (replacing Linear, Jira, GitHub Projects, Trello, etc.), but 30+ template files across all platforms contained directives to create Linear issues, sync Linear, and treat Linear as canonical. All references replaced with `Docs/Master-Plan.md`-centered language. Affected files: `AgToosa_Init.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Task.md`, `AgToosa_QA.md`, `AgToosa_Ship.md`, `AgToosa_Revert.md`, `AgToosa_Governance.md`, `AgToosa_Agent.md`, `AgToosa_Skills.md`, `AgToosa_Update.md`, `Master-Plan.md` template, all platform entry files (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `OPENCODE.md`, `.github/copilot-instructions.md`), and all platform rule/skill/command files for Cursor, Windsurf, Claude, Gemini, GitHub Copilot.

### Tests

- All 127 existing bats tests pass (5 pre-existing registry failures unaffected)

---

## [3.1.1] — 2026-05-04

### Fixed

- **`-h` flag rejected as unknown option** — `agtoosa.sh` flag parser now accepts `-h` as an alias for `--help`; previously emitted `❌ Error: Unknown option '-h'` and exited 1
- **`--update` showed `vunknown` after fresh install** — `install_files()` in `lib/install.sh` now writes `Docs/.agtoosa-version` at the end of every install; previously only `run_update()` wrote this file, so the first `--update` after a fresh install always read "unknown"
- **Misleading post-update hint** — `print_update_summary()` in `lib/update.sh` now includes the full target project path in the `/agtoosa-update` instruction; previously the generic phrasing caused a user to run `/agtoosa-update` inside the AgToosa source repo instead of their project

### Tests

- `bats`: `-h` shows usage and exits 0 (DEV-187)
- `bats`: fresh install writes `Docs/.agtoosa-version` with correct version (DEV-187)
- `bats`: `--update` after fresh install shows real version, not `vunknown` (DEV-187)

---

## [3.1.0] — 2026-05-04

### Added
- Repo-native maintainer guide in `docs/agtoosa-maintainer.md` for working on the AgToosa generator itself
- Native repo entry files for Claude (`CLAUDE.md`), AGENTS-style tools (`AGENTS.md`), Cursor (`.cursorrules`), and Windsurf (`.windsurfrules`) pointing to the shared maintainer guide
- File-type allowlist enforcement in `lib/registry.sh` (`.md`, `.json`, `.toml`, `.mdc` only); rejected files print: `Rejected: <file> — only .md/.json/.toml/.mdc are permitted`
- `agtoosa-lock.json` written on install and updated on `--update`; records pack name, version, sha256
- `--registry publish` contribution wizard for submitting community packs
- Pack staging merge from `ship/packs/` during install
- `template/Docs/AgToosa_Governance.md` — phase-gate protocol and Linear comment strings
- Formal deprecation policy in `CONTRIBUTING.md` (1-release notice before removal)
- 9 new bats tests (122 total)

### Changed
- `GEMINI.md` now contains maintainer guidance instead of remaining empty
- `.github/agents/agtoosa.agent.md` delegates to shared maintainer guide
- `agtoosa.ps1` brought to v3.0.0 feature parity (registry commands, DOCS_FILES expansion, version marker)
- CI now asserts version parity between `agtoosa.sh` and `agtoosa.ps1`
- `--update` now bumps `agtoosa_version` in existing `agtoosa-lock.json`; first run on a 3.0.0 install creates `agtoosa-lock.json` automatically in the project root

---

## [3.0.0] — 2026-05-02

### Added
- v3 Community Template Registry Phase 1 (read path):
  - `bash agtoosa.sh --registry list` — discover available community packs
  - `bash agtoosa.sh --registry search <keyword>` — filter packs by keyword
  - `bash agtoosa.sh --registry info <name>` — show pack details
  - `bash agtoosa.sh --registry install <name>` — download, verify (SHA-256), and install packs
  - Support for local pack installation: `--registry install ./local-pack` (offline mode)
  - Version pinning: `--registry install pack@1.2.0`
  - Registry caching (1 hour) to reduce GitHub load
  - Markdown-only pack constraint for security (no executable code)
  - `Docs/AgToosa_Registry.md` — user-facing registry workflow documentation
- Native Windows installation via PowerShell (`bootstrap.ps1`):
  - Dependency checking for git, bash, curl, tar
  - Automated Git for Windows discovery
  - Direct execution from PowerShell (no bash.exe required for bootstrap)
- Smart dependency checking in `bootstrap.sh`: detects missing bash/git/curl/tar and prints platform-specific install guidance
- Platform detection in bootstrap (macOS, Linux distros, WSL2, Windows) with contextual error messages
- `System Requirements` section in README documenting required tools (bash 4+, git, curl, tar)
- Git availability check in `agtoosa.sh` with helpful error messages if missing

### Changed
- Installation guidance in README now includes native Windows instructions (PowerShell one-liner)
- Bootstrap script exits gracefully with clear instructions if dependencies are missing (instead of silent/cryptic failures)
- Windows users can now choose: native PowerShell installer or WSL2 terminal

### Removed
- Stale plan files from `docs/superpowers/` directory (self-update planning artifacts)

---

## [2.7.0] — 2026-05-01

### Added
- 7 mattpocock/skills integrated: `/agtoosa-diagnose` (6-phase debugging), `/agtoosa-caveman` (token-efficient mode), `grill` (domain language alignment), `to-issues` (vertical-slice issue decomposition), `zoom-out` (codebase context), git-guardrails hook, and reference docs (CONTEXT-FORMAT, ADR-FORMAT, DEEPENING, LANGUAGE)
- All 6 platform support expanded with new command files: Claude Code, Cursor, Windsurf, Gemini CLI, GitHub Copilot, and OpenCode
- `Docs/AgToosa_Diagnose.md`, `Docs/AgToosa_Caveman.md`, `Docs/AgToosa_Skills.md` workflow documentation
- Reference documentation: `Docs/CONTEXT-FORMAT.md`, `Docs/ADR-FORMAT.md`, `Docs/DEEPENING.md`, `Docs/LANGUAGE.md`

### Changed
- **Breaking:** `/agtoosa-caveman` renamed to `/agtoosa-concise` for AgToosa-native branding (token-efficient communication mode)
- **Breaking:** `/agtoosa-diagnose` renamed to `/agtoosa-debug` for AgToosa-native branding (6-phase debugging workflow)
- **Breaking:** `grill` removed as standalone `/agtoosa-spec grill` sub-command; **domain language alignment now integrated into `/agtoosa-spec` Part 1** (Context Gathering & Domain Language Alignment). Context.md validation, terminology alignment, and ADR creation are part of the main spec research flow.
- All platform entry-point files and documentation updated to reference renamed commands and integrated domain language alignment
- `/agtoosa-spec` workflow enhanced with mandatory domain language checks in Part 1
- `/agtoosa-review` architecture checks enhanced with deep module analysis and ubiquitous language validation
- 32 new BATS tests added for new commands and platform coverage (113 total tests, all passing)

### Fixed
- Template file references corrected across all platform-specific command/rule files to match renamed documentation files
- Platform descriptions updated to use AgToosa-native command names throughout
- Spec command descriptions updated to reflect integrated domain language alignment (no longer mentions removed `grill` sub-command)

---

## [2.6.0] — 2026-04-28

### Added
- `--update` mode in `agtoosa.sh` to update an existing project install non-interactively: `bash agtoosa.sh --update /path/to/project`
- New workflow file `Docs/AgToosa_Update.md` and `/agtoosa-update` utility wiring across platform entry-point templates
- Expanded bats coverage for update mode, including error paths, preservation rules, dry-run behavior, and platform merge detection

### Changed
- Update flow now sources and uses `lib/update.sh` end-to-end from the main entrypoint
- CI now installs a pinned bats-core version instead of using an unversioned distro package

### Fixed
- `detect_installed_platforms()` in `lib/update.sh` now returns success explicitly to avoid `set -e` exits during update runs
- Removed deprecated Roo template artifacts (`template/.roorules`, `template/.roo/`) from active template surface

---

## [2.5.0] — 2026-04-28

### Added
- `.mdc` files (Cursor rules) now linted by CI markdownlint step
- Bats test for VS Code + Copilot combo (`5 6`) verifying `.github/` deduplication

### Changed
- Platform option 7 renamed from "OpenCode / Roo / Other" to "OpenCode / Other" — Roo Code sunsets 2026-05-15
- `OPTIONAL_TEMPLATE_FILES` and `ROO_RULE_FILES` array removed; `.roorules` and `.roo/rules/` are no longer generated or installed
- Platform entry-point files `AGENTS.md` and `OPENCODE.md` updated: optional utilities line now includes "Read" prefix to match all other platform files
- `count_existing_files()` in `lib/install.sh` now correctly counts VS Code-specific files when option 6 is selected without option 5
- Bats test for platform selection 6 renamed and strengthened with positive assertions for `.github/copilot-instructions.md`, prompts, and agent file
- `CLAUDE_HOOK_FILES` dead config array removed from `lib/config.sh`
- v2.4.0 CHANGELOG date corrected from 2026-05-14 to 2026-04-28

---

## [2.4.0] — 2026-04-28

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
