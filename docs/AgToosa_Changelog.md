# AgToosa Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned per [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [5.3.3] — 2026-07-08

### Added

- 2026-07-08 — feature — DEV-047 Async Agent Handoff Packs (`/agtoosa-handoff`) + DEV-048 Agent Result Import Gate (`/agtoosa-import`); dual-path docs, adapters, HO/IR bats — `docs/archived/spec-DEV-047.md` · `docs/archived/spec-DEV-048.md` · `docs/archived/review-DEV-047-048.md`

---

## [5.3.2] — 2026-07-08

### Added

- 2026-07-08 — feature — DEV-074 PS1 non-interactive install parity (`-Path`/`-Platforms`/`-Yes`), `ConvertTo-PlatformList`, bats DEV-074 + Pester NI-001–NI-005 — `docs/archived/spec-DEV-074.md`

---

## [5.3.1] — 2026-07-08

### Fixed

- 2026-07-08 — fix — v5.3.1 patch: pack lock provenance, re-install data loss, multi-root pack smuggle, npm/bootstrap durable pack queue (`AGTOOSA_PACK_QUEUE_DIR`), PowerShell hooks deep-merge and merge containment — `CHANGELOG.md`

---

## [5.3.0] — 2026-06-10

### Added

- 2026-06-10 — feature — DEV-042–DEV-043 + DEV-061–DEV-073 proof engine + supply chain wave: deterministic verifier, CI gate template, phase-event log, tar-slip hardening, pack containment, pinned install chain, executable workflows, adapter/governance fixes, token diet, non-interactive CLI/npm wrapper, spec amend/living specs, doctor/uninstall — `docs/archived/cycle-2026-06-10-release-5.3.0.md`

---

## [5.2.7] — 2026-06-08

### Added

- 2026-06-08 — chore — DEV-041 public launch publication proof: public repo, release, raw bootstraps, registry, Homebrew tap, support/community surfaces, proof repo, idempotent release workflows, Dependency-Check workflow fix, and bounded CI setup steps — `docs/archived/spec-DEV-041.md`

---

## [5.2.6] — 2026-06-07

### Added

- 2026-06-07 — chore — DEV-035-DEV-040 launch readiness buildout: public/private launch gate, Windows/registry parity, truthful launch docs, distribution hardening, first-15-minutes proof, and team trust roadmap — `docs/AgToosa_Launch_Readiness_Spec_Bundle.md`

---

## [5.2.6] — 2026-06-06

### Added

- 2026-06-06 — chore — **DEV-035 — PSScriptAnalyzer CI gate for agtoosa.ps1.** `windows-smoke` runs pinned PSScriptAnalyzer `PSUseApprovedVerbs` on `agtoosa.ps1`; PA-001–PA-003 bats — `docs/archived/spec-DEV-035.md`

---

## [5.2.5] — 2026-06-05

### Changed

- 2026-06-05 — chore — **DEV-034 — Maintainer release-state reconciliation.** LR bats + cycle compaction; Master-Plan ledger reconciled after v5.2.4 ship — `docs/archived/spec-DEV-034.md`

---

## [5.2.4] — 2026-06-05

### Fixed

- 2026-06-05 — fix — `/agtoosa-update` self-target uncertainty: operating-context detection, dogfood stop-before-Apply, CLI guidance; DEV-030 T-001–T-011 bats — `docs/archived/spec-DEV-030.md`
- 2026-06-05 — fix — DEV-033 agtoosa.ps1 approved PowerShell verbs: `Copy-StageFiles`, `Initialize-PackQueueDir`, `Move-ShipPacksToQueue`; DEV-033 PV-001–PV-003 bats — `docs/archived/spec-DEV-033.md`

---

## [5.2.3] — 2026-05-25

### Added

- 2026-05-25 — feature — Project-specific specialist subagents: `AgToosa_Specialists.md`, init/update/spec orchestration, approval-gated roster; DEV-031 T-001–T-015 bats — `docs/archived/spec-DEV-031.md`

---

## [5.2.2] — 2026-05-25

### Added

- 2026-05-25 — chore — Patch-first release cadence (ADR-005): default PATCH bumps on 5.x MINOR train; ship/review/maintainer docs; DEV-032 VP-001–VP-005 bats — `docs/archived/spec-DEV-032.md`

---

## [5.2.1] — 2026-05-25

### Added

- 2026-05-24 — feature — Plan-mode spec interview for `/agtoosa-spec`: research-first, infer-before-ask, adaptive cap 8 / quick cap 2, decision-complete checklist; DEV-028 T-001–T-010 bats (DEV-028) — `docs/archived/spec-DEV-028.md`
- 2026-05-24 — feature — Agentic `/agtoosa-update`: Detect → Plan → Apply → Verify, ask-then-apply, CLI-backed Apply; T-001–T-009 bats (DEV-027) — `docs/archived/spec-DEV-027.md`
- 2026-05-24 — fix — Codex agent mode spec execution contract on skill + prompt; CS1–CS5 bats (DEV-026) — `docs/archived/spec-DEV-026.md`
- 2026-05-24 — chore — Maintainer docs path normalization: `docs/` prefixes in workflow mirrors, Path conventions in `docs/agtoosa-maintainer.md`, PN1–PN5 bats (DEV-025) — `docs/archived/spec-DEV-025.md`
- 2026-05-24 — fix — Maintainer status/readiness doc parity for dogfood: Part 1.5 in `docs/AgToosa_Status.md`, new `docs/AgToosa_Readiness.md`, MD1–MD5 bats (DEV-024) — `docs/archived/spec-DEV-024.md`

### Added (prior)

- 2026-05-24 — fix — Registry publish PS1 redirect + offline cache trust docs; RC1–RC3 bats (DEV-022) — `docs/archived/spec-DEV-022.md`
- 2026-05-24 — fix — Registry pack queue: durable `.agtoosa/pack-queue/` staging, merge on install, legacy `ship/packs` salvage, PS1 parity; PK1–PK5 bats (DEV-018) — `docs/archived/spec-DEV-018.md`
- 2026-05-24 — fix — Registry install version pinning: fail-closed `pack@version` in Bash and PS1; RV1–RV5 bats (DEV-020) — `docs/archived/spec-DEV-020.md`
- 2026-05-24 — fix — Codex slash discoverability: `.codex/prompts/agtoosa-*.md` adapters, generator install wiring, OPENCODE.md; CX1–CX5 bats (DEV-017) — `docs/archived/spec-DEV-017.md`
- 2026-05-24 — fix — Gemini slash-command routing: native `/agtoosa-*` TOML guardrails, `AGENTS.md` reservation, synthesis collision checks; GM1–GM5 bats (DEV-016) — `docs/archived/spec-DEV-016.md`
- 2026-05-24 — fix — Registry prod-readiness: Case B merge, registry UX, PS1 array parsing, publish `jq -n`; RG1–RG8 bats (DEV-003) — `docs/archived/spec-DEV-003.md`

### Added (prior)

- 2026-05-24 — fix — Windsurf slash-command routing: native `/agtoosa-*` workflow guardrails, core/status rules, synthesis collision checks; WS1–WS5 bats (DEV-015) — `docs/archived/spec-DEV-015.md`

### Added (prior)

- 2026-05-24 — fix — Cursor slash-command routing: native `/agtoosa-*` command guardrails, core/status rules, synthesis collision checks; CU1–CU5 bats (DEV-014) — `docs/archived/spec-DEV-014.md`

### Added (prior)

- 2026-05-24 — fix — `/agtoosa-ship check` read-only Part 0 readiness audit; ship adapter alignment; C1–C6 bats (DEV-013) — `docs/archived/spec-DEV-013.md`

### Added (prior)

- 2026-05-24 — feature — GitHub slash-command routing: prompt `name` metadata, `/agtoosa-*` Copilot routing guardrails, reserved workflow skill names; G1–G5 bats (DEV-012) — `docs/archived/spec-DEV-012.md`

### Added (prior)

- 2026-05-24 — feature — product vs dogfood boundary: Generated Project Mode + Maintainer Dogfood Mode; B1–B5 bats (DEV-011) — `docs/archived/spec-DEV-011.md`

### Added (prior)

- 2026-05-24 — feature — workflow reliability: phase gates + terminal evidence; W1–W5 bats (DEV-010) — `docs/archived/spec-DEV-010.md`

### Added (prior)

- 2026-05-22 — test — M1–M4 bats parity for v4.2.0 manual-task workflow (DEV-005) — `docs/archived/spec-DEV-005.md`
- 2026-05-23 — feature — AgToosa Status Guide sub-agent for read-only status coaching with authorization gates (DEV-006) — `docs/archived/spec-DEV-006.md`
- 2026-05-23 — feature — `/agtoosa-help next` on-demand read-only assistance helper across platform help surfaces (DEV-007) — `docs/archived/spec-DEV-007.md`
- 2026-05-23 — feature — workflow skill synthesis: Codex skill contract, init/spec project-skill discovery, K1–K7 bats (DEV-008) — `docs/archived/spec-DEV-008.md`

### Changed

- 2026-05-22 — docs — CHANGELOG planned features moved to `[Unreleased]` (DEV-005)

---

## [2.4.0] — 2026-05-14

### Added
- `/agtoosa-task` command (`docs/AgToosa_Task.md`): lightweight Linear issue capture for bugs, chores, spikes, and fixes without a full spec cycle; includes type-specific DoD checklists and Discovery Triage origin tracking
- Linear Issue Standard anatomy: canonical title format `[Type]: [description]`, required description sections (Context, Scope, ACs, DoD, Related), Epic→Story→Task hierarchy, Phase Comment Protocol, and Discovery Triage Protocol — all documented in `docs/AgToosa_Agent.md`
- Epic creation in `/agtoosa-init`: agent creates Linear Epic issues with correct labels/status and records IDs in `docs/Master-Plan.md`
- Story creation with T-shirt sizing and cycle enrollment in `/agtoosa-spec`: agent creates a Linear Story issue (parent: Epic), records estimate, and enrolls in the active cycle
- Task sub-issue creation in `/agtoosa-build`: agent creates Linear Task issues per build task; transitions Story to `In Progress`; posts "Build 🏗️ Started" phase comment
- Discovery Triage Protocol in `/agtoosa-build`: classify out-of-scope findings, size them, and route to create-issue / expand-scope / ignore
- Status transition protocol: Story moves `Todo → In Progress → In Review → Done` at Build/Review/Ship boundaries; rollback resets to `In Review`
- Phase progress comments on Linear Story issues at every transition: Spec ✅ Approved, Build 🏗️ Started, Task 🟢 N/M, Review 🔍 Started/verdict, Ship 🚀/Rollback 🔙
- Rich `docs/Master-Plan.md` template: 8-section structured document (Project Charter, Epics, Active Cycle, Active Tasks, Backlog, Blocked, Completed This Cycle, Update Log)

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
