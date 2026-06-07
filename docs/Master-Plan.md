# Master-Plan

> **Source of truth for active work.** Completed work lives in `docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-06-06 (/agtoosa-build DEV-035)

## Project Charter

| Field | Value |
|-------|-------|
| Product | `AgToosa` |
| GitHub repo | `https://github.com/sky2464/AgToosa` |
| Milestone | `v5.2.6` (next) — patch-first per `docs/adr/ADR-005-release-cadence.md` |
| Active cycle | Release 5.2.6 — PSScriptAnalyzer CI gate |
| Cycle capacity | `40 story points` |
| Current phase | ✅ DEV-035 build complete — PSScriptAnalyzer CI gate ready for review |

## Active Cycle

> Stories committed to the current sprint/cycle.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| DEV-035 | Chore: PSScriptAnalyzer CI gate for agtoosa.ps1 | Chore | XS | ✅ Done | 8/8 |

<!-- Archived to docs/archived/cycle-2026-06-05-release-5.2.5.md -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.2.0.md -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.1.0.md (DEV-027) -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.0.1.md (DEV-026) -->

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

**DEV-035 — PSScriptAnalyzer CI gate for agtoosa.ps1** (spec: `docs/archived/spec-DEV-035.md`)

- [x] **1.** CI workflow — PSScriptAnalyzer step
  - [x] 1.1 Add pinned `PSScriptAnalyzer` install + `Invoke-ScriptAnalyzer` step to `windows-smoke` — _AC-001, AC-002, AC-006_
  - [x] 1.2 Scope analyzer to `PSUseApprovedVerbs` — _AC-002_
  - [x] 1.3 Verify step fails on intentional violation — _AC-002_
- [x] **2.** Regression coverage
  - [x] 2.1 Add DEV-035 bats PA-001–PA-003 — _AC-003, AC-004_
  - [x] 2.2 Finalize `docs/AgToosa_TestPlan-DEV-035.md` evidence table — _AC-005_
- [x] **3.** Validation
  - [x] 3.1 Run `bats tests/agtoosa.bats -f "DEV-035"` — _AC-004_
  - [x] 3.2 Confirm `windows-smoke` job structure (workflow YAML review) — _AC-001_

<!--
**DEV-029 — Stop branch-protection workflow failure emails** (spec: `docs/archived/spec-DEV-029.md`) — shipped 2026-05-25 v5.2.1

- [x] **1.** Workflow push-safe + PR guards
- [x] **2.** Regression coverage (DEV-029 T-001–T-005)
- [x] **3.** Post-merge verification — run `26419089522` success on push (`PR Hygiene Checks`, 7s)
  - [x] 3.1 Push to `main` yields successful run — _AC-001_
  - [x] 3.2 `gh run list --workflow branch-protection.yml` shows success — _AC-001_
- [x] **4.** PR path regression — PR #29 / run `27050231744` success (`require-labels`, `require-description`, `link-issue`, `all-checks-pass`; `push-main-ok` skipped)
  - [x] 4.1 PR to `main` still runs label/description/issue checks — _AC-002_
-->

<!--
**DEV-032 — Patch-first release versioning** (spec: `docs/archived/spec-DEV-032.md`) — shipped 2026-05-25 v5.2.2

- [x] **1.** Policy ADR and maintainer checklist — _AC-002, AC-006_
  - [x] 1.1 Add `docs/adr/ADR-005-release-cadence.md` — _AC-006_
  - [x] 1.2 Cross-link ADR-004 → ADR-005 — _AC-006_
  - [x] 1.3 Extend `docs/agtoosa-maintainer.md` Release Checklist — _AC-002_
- [x] **2.** Template + maintainer workflow mirrors — _AC-003, AC-004, AC-005_
  - [x] 2.1 `template/Docs/AgToosa_Ship.md` version bump section — _AC-003_
  - [x] 2.2 `docs/AgToosa_Ship.md` mirror — _AC-003_
  - [x] 2.3 `template/Docs/AgToosa_Review.md` PATCH-first ship suggestion — _AC-004_
  - [x] 2.4 `docs/AgToosa_Review.md` mirror — _AC-004_
  - [x] 2.5 Readiness gate 7 wording (template + docs) — _AC-005_
- [x] **3.** Master-Plan and regression tests — _AC-005, AC-007_
  - [x] 3.1 Milestone + DEV-032 row — _AC-005_
  - [x] 3.2 DEV-032 bats VP-001–VP-005 — _AC-007_
-->

<!--
**DEV-033 — agtoosa.ps1 PSScriptAnalyzer approved verbs** (spec: `docs/archived/spec-DEV-033.md`) — shipped 2026-06-05 v5.2.4

- [x] **1.** Rename helpers in `agtoosa.ps1`
  - [x] 1.1 `Stage-Files` → `Copy-StageFiles` — _AC-001, AC-003_
  - [x] 1.2 `Ensure-PackQueueDir` → `Initialize-PackQueueDir` — _AC-001, AC-003_
  - [x] 1.3 `Salvage-ShipPacksToQueue` → `Move-ShipPacksToQueue` — _AC-001, AC-003_
- [x] **2.** Docs + tests
  - [x] 2.1 Update audit doc reference — _AC-005_
  - [x] 2.2 DEV-033 bats PV-001–PV-003 — _AC-004_
- [x] **3.** Verify PSScriptAnalyzer + PK smoke — _AC-001, AC-002_
  - [x] 3.1 Run `bats tests/agtoosa.bats -f "DEV-033"` and focused registry/install smoke — _AC-002, AC-004_
  - [x] 3.2 Confirm PSScriptAnalyzer clean on `agtoosa.ps1` — _AC-001_
-->

<!--
**DEV-030 — Fix `/agtoosa-update` self-target uncertainty** (spec: `docs/archived/spec-DEV-030.md`) — shipped 2026-06-05 v5.2.4

- [x] **1.** Canonical update workflow — operating context
  - [x] 1.1 Add Stage 1a operating-context detection in `template/Docs/AgToosa_Update.md` — _AC-001, AC-002_
  - [x] 1.2 Maintainer Dogfood stop + report (no Apply, no downstream path prompt) — _AC-003, AC-004_
  - [x] 1.3 Preserve DEV-027 flow for Generated Project Mode — _AC-005_
  - [x] 1.4 Mirror to `docs/AgToosa_Update.md` — _AC-001, AC-004, AC-005_
- [x] **2.** CLI and PowerShell self-target guidance
  - [x] 2.1 Extend `agtoosa.sh` self-target messages — _AC-006, AC-009_
  - [x] 2.2 Extend `agtoosa.ps1` self-target messages — _AC-006, AC-010_
- [x] **3.** Adapter spot-check (conditional)
  - [x] 3.1 T-008 passed — no adapter edits required — _AC-007_
- [x] **4.** Regression coverage
  - [x] 4.1 DEV-030 bats doc assertions — _AC-001–AC-004, AC-008_
  - [x] 4.2 Extended self-target guidance bats — _AC-006, AC-009, AC-010_
  - [x] 4.3 Focused filter + DEV-027 T-001–T-009 regression — _AC-005, AC-007_
- [x] **5.** Validation and bookkeeping
  - [x] 5.1 Full bats when focused green — _AC-008_
  - [x] 5.2 `docs/AgToosa_TestPlan-DEV-030.md` evidence — _AC-008_
  - [x] 5.3 Master-Plan task progress — _AC-001_
-->

<!--
**DEV-034 — Maintainer release-state reconciliation** (spec: `docs/archived/spec-DEV-034.md`) — shipped 2026-06-05 v5.2.5

- [x] **1.** Audit current release ledger
- [x] **2.** Reconcile Master-Plan and changelog state
- [x] **3.** Align version and release pins if shipping
- [x] **4.** Add regression coverage (DEV-034 LR-001–LR-006)
- [x] **5.** Review and handoff — review-DEV-034.md; shipped v5.2.5
-->

<!--
**DEV-031 — Project-specific specialist subagents** (spec: `docs/archived/spec-DEV-031.md`) — shipped 2026-05-25 v5.2.3

- [x] **1.** Canonical specialist contract — _AC-001–AC-002_
- [x] **2.** Init Phase E specialist discovery — _AC-003–AC-005_
- [x] **3.** Update Specialist Compatibility Check — _AC-007–AC-008_
- [x] **4.** Spec orchestration step 1a — _AC-009–AC-012_
- [x] **5.** Agent + Skills + Codex adapters — _AC-014_
- [x] **6.** Maintainer mirrors + DEV-031 bats T-001–T-015 — _AC-013, AC-015_
-->

<!--
**DEV-028 — Plan-mode spec interview** (spec: `docs/archived/spec-DEV-028.md`) — shipped 2026-05-24 v5.2.0

<!--
**DEV-027 — Agentic /agtoosa-update** (spec: `docs/archived/spec-DEV-027.md`) — shipped 2026-05-24 v5.1.0

<!--
**DEV-026 — Codex agent mode spec workflow execution** (spec: `docs/archived/spec-DEV-026.md`) — shipped 2026-05-24 v5.0.1

<!--
**DEV-025 — Maintainer docs path normalization** (spec: `docs/archived/spec-DEV-025.md`) — shipped 2026-05-24 v5.0.0

<!--
**DEV-024 — Maintainer status readiness doc parity** (spec: `docs/archived/spec-DEV-024.md`) — shipped 2026-05-24 v4.14.1

<!--
**DEV-019 — Master Architecture document** (spec: `docs/archived/spec-DEV-019.md`) — shipped 2026-05-24 v4.13.0

<!--
**DEV-018 — Registry pack queue** (spec: `docs/archived/spec-DEV-018.md`) — shipped 2026-05-24 v4.12.0

**DEV-020 — Registry install version pinning** (spec: `docs/archived/spec-DEV-020.md`) — shipped 2026-05-24 v4.12.0

**DEV-021 — E2E pinned registry install test (RV6)** (spec: `docs/archived/spec-DEV-021.md`) — shipped 2026-05-24 v4.12.1
-->

<!--
**DEV-016 — Gemini slash command routing** (spec: `docs/archived/spec-DEV-016.md`) — shipped 2026-05-24

- [x] **1.** Gemini TOML routing guardrails (14 adapters)
- [x] **2.** AGENTS.md + AgToosa_Gemini.md
- [x] **3.** Skill synthesis collision guardrails
- [x] **4.** GM1–GM5 bats; full suite 246/246 green

<!--
**DEV-003 — Registry prod-readiness (audit closure)** (spec: `docs/archived/spec-DEV-003.md`) — shipped 2026-05-24

- [x] **1.** Case B merge fix
  - [x] 1.1 Update `merge_platform_file` Case B to append via `inject_version` — _AC-001_
  - [x] 1.2 Add RG3: Case B second `--update` leaves one START block — _AC-002, AC-007_
- [x] **2.** Registry bash UX and safety
  - [x] 2.1 `registry_info`: exit 1 when jq returns empty — _AC-003_
  - [x] 2.2 `registry_search`: explicit no-results message — _AC-004_
  - [x] 2.3 `registry_publish`: emit manifest with `jq -n` — _AC-005_
  - [x] 2.4 Add RG2, RG4, RG5, RG8 — _AC-003, AC-004, AC-005, AC-007, AC-008_
- [x] **3.** PowerShell registry hardening
  - [x] 3.1 Wrap all registry `ConvertFrom-Json` results with `@()` — _AC-006_
  - [x] 3.2 Add RG6: PS1 parses single-entry fixture array — _AC-006, AC-007_
- [x] **4.** Verification
  - [x] 4.1 Add RG1 (jq injection), RG7 (path traversal unchanged) — _AC-007, AC-008_
  - [x] 4.2 Run RG filter + full bats; record evidence — _AC-007_
-->

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.
> When you complete a step, run `/agtoosa-build` and choose (A) to mark it done.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|
| *(Empty — good!)* | | | |

## Blocked

> **Status:** 🟢 None blocked
> Update this section and change status pill if an issue is blocked during `/agtoosa-build`.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|

*(Empty — good!)*

## Backlog

> Priority-ordered list of upcoming stories and issues. Updated by `/agtoosa-spec` and `/agtoosa-task`.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|
| DEV-035 | Chore: PSScriptAnalyzer CI gate for agtoosa.ps1 | Chore | XS | DEV-004 | High | ✅ Done |
| DEV-031 | Feature: Project-specific specialist subagents | Feature | M | DEV-002 | High | 🏁 Shipped |
| DEV-032 | Chore: Patch-first release versioning (5.x line) | Chore | S | DEV-001 | High | 🏁 Shipped |
| DEV-030 | Fix: `/agtoosa-update` self-target uncertainty | Fix | S | DEV-002 | High | 🏁 Shipped |
| DEV-033 | Fix: agtoosa.ps1 PSScriptAnalyzer approved verbs | Fix | XS | DEV-001 | Medium | 🏁 Shipped |
| DEV-034 | Chore: Maintainer release-state reconciliation | Chore | S | DEV-004 | High | 🏁 Shipped |

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-001 | Epic: Core Generator Engine | 0 open / 0 total | ⬜ Backlog |
| DEV-002 | Epic: Workflow Templates | 0 open / 10 total | 🟦 Todo |
| DEV-003 | Epic: Community Template Registry | 0 open / 0 total | ⬜ Backlog |
| DEV-004 | Epic: Testing & QA Harness | 1 open / 2 total | 🟦 Todo |

### Epic Charters

*   **DEV-001 - Epic: Core Generator Engine**
    *   **Goal:** Core interactive CLI generator providing project scaffolding, version-pin checks, deep copy/merge paths, backups, and dry-run execution.
    *   **Scope:** `agtoosa.sh`, `agtoosa.ps1`, and all `lib/*.sh` core modules.
    *   **Success Criteria:** Zero-friction installation and error-free multi-platform scaffolding on clean or existing directories.

*   **DEV-002 - Epic: Workflow Templates**
    *   **Goal:** Comprehensive AI-native rule files, prompts, skills, and templates keeping AI agents fully aligned with the four-phase lifecycle.
    *   **Scope:** Markdown specifications and rules files across Claude, Gemini, Cursor, Windsurf, Copilot, and OpenCode under `template/`.
    *   **Success Criteria:** Perfect parity of phase commands and zero-drift version badges across all platform templates.

    *   **Last shipped:** DEV-025 — Maintainer docs path normalization → `docs/archived/spec-DEV-025.md`
    *   **Last shipped:** DEV-024 — Maintainer status readiness doc parity → `docs/archived/spec-DEV-024.md`
    *   **Last shipped:** DEV-023 — Workflow Template Native Slash Parity Audit → `docs/archived/spec-DEV-023.md`
    *   **Last shipped:** DEV-027 — Agentic `/agtoosa-update` → `docs/archived/spec-DEV-027.md`
    *   **Current:** _(shipped DEV-028 v5.2.0 — see `docs/archived/spec-DEV-028.md`)_

*   **DEV-003 - Epic: Community Template Registry**
    *   **Goal:** Discoverable and secure package manager cache allowing developers to list, search, install, and publish community packs.
    *   **Scope:** Pack registry parsing, cached JSON validation, SHA-256 integrity rules, and command staging wrappers in `lib/registry.sh`.
    *   **Success Criteria:** Secure Offline/Online installation of approved community templates with zero path-traversal risk.
    *   **Last shipped:** DEV-022 — publish PS1 + offline cache → `docs/archived/spec-DEV-022.md`
    *   **Last shipped:** DEV-021 — E2E pinned install test (RV6) → `docs/archived/spec-DEV-021.md`
    *   **Last shipped:** DEV-020 — registry `@version` install enforcement → `docs/archived/spec-DEV-020.md`
    *   **Last shipped:** DEV-018 — durable pack queue → `docs/archived/spec-DEV-018.md`
    *   **Current:** _(pick next story via `/agtoosa-spec`)_

*   **DEV-004 - Epic: Testing & QA Harness**
    *   **Goal:** Comprehensive end-to-end integration and version verification suites validating the robustness of the entire framework.
    *   **Scope:** `tests/agtoosa.bats` and CI regression pipelines.
    *   **Success Criteria:** 100% green coverage on 340+ bats scenarios and version checks on every release step.
    *   **Current:** DEV-035 — PSScriptAnalyzer CI gate → `docs/archived/spec-DEV-035.md`
    *   **Last shipped:** DEV-034 — release ledger reconciliation → `docs/archived/spec-DEV-034.md`
    *   **Last shipped:** DEV-005 — M1–M4 bats + CHANGELOG hygiene → `docs/archived/spec-DEV-005.md`

## Completed This Cycle

> Detail lives in `docs/archived/`. This section shows pointer rows only — links to archived spec files.
> Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| DEV-005 | Chore: v4.2.0 release hygiene (M1–M4 bats + CHANGELOG) | 2026-05-22 | [spec-DEV-005.md](archived/spec-DEV-005.md) · [review-DEV-005.md](archived/review-DEV-005.md) |
| DEV-006 | Feature: AgToosa Status Guide sub-agent | 2026-05-23 | [spec-DEV-006.md](archived/spec-DEV-006.md) · [review-DEV-006.md](archived/review-DEV-006.md) |
| DEV-007 | Feature: /agtoosa-help next on-demand assistance helper | 2026-05-23 | [spec-DEV-007.md](archived/spec-DEV-007.md) · [review-DEV-007.md](archived/review-DEV-007.md) |
| DEV-008 | Feature: Workflow skill synthesis for AgToosa projects | 2026-05-23 | [spec-DEV-008.md](archived/spec-DEV-008.md) · [review-DEV-008.md](archived/review-DEV-008.md) |
| DEV-009 | Feature: Initial product promise alignment and readiness gates | 2026-05-23 | [spec-DEV-009.md](archived/spec-DEV-009.md) · [review-DEV-009.md](archived/review-DEV-009.md) |
| DEV-010 | Feature: Workflow reliability (phase gates & terminal evidence) | 2026-05-24 | [spec-DEV-010.md](archived/spec-DEV-010.md) · [review-DEV-010.md](archived/review-DEV-010.md) |
| DEV-011 | Feature: AgToosa Product vs Dogfood Boundary | 2026-05-24 | [spec-DEV-011.md](archived/spec-DEV-011.md) · [review-DEV-011.md](archived/review-DEV-011.md) |
| DEV-012 | Feature: GitHub Slash Command Routing | 2026-05-24 | [spec-DEV-012.md](archived/spec-DEV-012.md) · [review-DEV-012.md](archived/review-DEV-012.md) |
| DEV-013 | Fix: /agtoosa-ship check cleanup | 2026-05-24 | [spec-DEV-013.md](archived/spec-DEV-013.md) · [review-DEV-013.md](archived/review-DEV-013.md) |
| DEV-014 | Fix: Cursor slash command routing | 2026-05-24 | [spec-DEV-014.md](archived/spec-DEV-014.md) · [review-DEV-014.md](archived/review-DEV-014.md) |
| DEV-015 | Fix: Windsurf slash command routing | 2026-05-24 | [spec-DEV-015.md](archived/spec-DEV-015.md) · [review-DEV-015.md](archived/review-DEV-015.md) |
| DEV-003 | Fix: Registry prod-readiness (audit closure) | 2026-05-24 | [spec-DEV-003.md](archived/spec-DEV-003.md) · [review-DEV-003.md](archived/review-DEV-003.md) |
| DEV-016 | Fix: Gemini slash command routing | 2026-05-24 | [spec-DEV-016.md](archived/spec-DEV-016.md) · [review-DEV-016.md](archived/review-DEV-016.md) |
| DEV-017 | Fix: Codex AgToosa slash discoverability | 2026-05-24 | [spec-DEV-017.md](archived/spec-DEV-017.md) · [review-DEV-017.md](archived/review-DEV-017.md) |
| DEV-018 | Fix: Registry pack queue | 2026-05-24 | [spec-DEV-018.md](archived/spec-DEV-018.md) · [review-DEV-018.md](archived/review-DEV-018.md) |
| DEV-020 | Fix: Registry install version pinning | 2026-05-24 | [spec-DEV-020.md](archived/spec-DEV-020.md) · [review-DEV-020.md](archived/review-DEV-020.md) |
| DEV-021 | Fix: E2E pinned registry install test (RV6) | 2026-05-24 | [spec-DEV-021.md](archived/spec-DEV-021.md) · [review-DEV-021.md](archived/review-DEV-021.md) |
| DEV-022 | Fix: Registry publish PS1 + offline cache hardening | 2026-05-24 | [spec-DEV-022.md](archived/spec-DEV-022.md) · [review-DEV-022.md](archived/review-DEV-022.md) |
| DEV-019 | Feature: Master Architecture document | 2026-05-24 | [spec-DEV-019.md](archived/spec-DEV-019.md) · [review-DEV-019.md](archived/review-DEV-019.md) |
| DEV-023 | Fix: Workflow Template Native Slash Parity Audit | 2026-05-24 | [spec-DEV-023.md](archived/spec-DEV-023.md) · [review-DEV-023.md](archived/review-DEV-023.md) |
| DEV-024 | Fix: Maintainer status readiness doc parity | 2026-05-24 | [spec-DEV-024.md](archived/spec-DEV-024.md) · [review-DEV-024.md](archived/review-DEV-024.md) |
| DEV-025 | Chore: Maintainer docs path normalization | 2026-05-24 | [spec-DEV-025.md](archived/spec-DEV-025.md) · [review-DEV-025.md](archived/review-DEV-025.md) |
| DEV-026 | Fix: Codex agent mode spec workflow execution | 2026-05-24 | [spec-DEV-026.md](archived/spec-DEV-026.md) · [review-DEV-026.md](archived/review-DEV-026.md) |
| DEV-027 | Feature: Agentic `/agtoosa-update` | 2026-05-24 | [spec-DEV-027.md](archived/spec-DEV-027.md) · [review-DEV-027.md](archived/review-DEV-027.md) |
| DEV-028 | Feature: Plan-mode spec interview for `/agtoosa-spec` | 2026-05-24 | [spec-DEV-028.md](archived/spec-DEV-028.md) · [review-DEV-028.md](archived/review-DEV-028.md) |
| DEV-029 | Chore: Stop branch-protection workflow failure emails | 2026-05-25 | [spec-DEV-029.md](archived/spec-DEV-029.md) · [review-DEV-029.md](archived/review-DEV-029.md) |
| DEV-032 | Chore: Patch-first release versioning (5.x line) | 2026-05-25 | [spec-DEV-032.md](archived/spec-DEV-032.md) · [review-DEV-032.md](archived/review-DEV-032.md) |
| DEV-031 | Feature: Project-specific specialist subagents | 2026-05-25 | [spec-DEV-031.md](archived/spec-DEV-031.md) · [review-DEV-031.md](archived/review-DEV-031.md) |
| DEV-030 | Fix: `/agtoosa-update` self-target uncertainty | 2026-06-05 | [spec-DEV-030.md](archived/spec-DEV-030.md) · [review-DEV-030.md](archived/review-DEV-030.md) |
| DEV-033 | Fix: agtoosa.ps1 PSScriptAnalyzer approved verbs | 2026-06-05 | [spec-DEV-033.md](archived/spec-DEV-033.md) · [review-DEV-033.md](archived/review-DEV-033.md) |
| DEV-034 | Chore: Maintainer release-state reconciliation | 2026-06-05 | [spec-DEV-034.md](archived/spec-DEV-034.md) · [review-DEV-034.md](archived/review-DEV-034.md) |

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| 2026-05-21 | 🚀 /agtoosa-init workspace initialized | AgToosa |
| 2026-05-22 | ✏️ /agtoosa-spec DEV-005 — v4.2.0 release hygiene spec + tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-22 | 🏗️ Build started — DEV-005, 8 tasks, scope: tests/agtoosa.bats, CHANGELOG.md | AgToosa |
| 2026-05-22 | 🏗️ Build complete — M1–M4 added, CHANGELOG backlog moved to [Unreleased], 15/15 validation tests green | AgToosa |
| 2026-05-22 | 🔍 Review started — 4-persona review on DEV-005 | AgToosa |
| 2026-05-22 | 🔍 Review passed — 0 Critical, 3 Warnings (accepted); report: docs/archived/review-DEV-005.md | AgToosa |
| 2026-05-22 | 🚀 Ship complete — DEV-005 closed; smoke/validation 15/15 green; archived spec + review | AgToosa |
| 2026-05-22 | ✏️ /agtoosa-spec DEV-006 — Status Guide sub-agent spec + 11 tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-22 | ✅ Spec approved — DEV-006; estimate M; enrolled in Release 4.2; 11 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-006, 11 tasks, scope: StatusGuide docs, Copilot agent, config registration, bats parity | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-006 Status Guide implemented; 161/161 bats validation tests green | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-006 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 2 Warnings (accepted); report: docs/archived/review-DEV-006.md | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-006 closed; smoke/validation 161/161 green; archived spec + review | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-007 — /agtoosa-help next on-demand assistance helper spec + 15 tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-007; estimate S; enrolled in Release 4.2; 15 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-007, 18 tasks, scope: help variants, core fallbacks, Agent docs, tests/agtoosa.bats, CHANGELOG.md | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-007 help-next wired; H1–H7 bats green; 178/180 full suite (S2 install pre-existing fail) | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-007 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-007.md | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-008 — workflow skill synthesis spec drafted and added to Backlog (not enrolled) | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-007 closed; smoke H1–H7 7/7 green; archived spec + review | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-008 — workflow skill synthesis enrolled in Release 4.2; estimate M; 15 tasks planned | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-008; estimate M; enrolled in Release 4.2; 15 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-008, 15 tasks, scope: template/.codex/skills, AgToosa_Init/Spec/Skills/Agent, OPENCODE, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-008 workflow skill synthesis; K1–K7 bats green; 189/189 full suite green | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-008 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 3 Warnings (accepted); report: docs/archived/review-DEV-008.md | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-008 closed; smoke K1–K7 7/7 green; 189/189 validation; archived spec + review | AgToosa |
| 2026-05-23 | 🚀 Release 4.2 shipped — v4.2.0 tagged; DEV-005–DEV-008 on main; 189/189 bats green | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-009 — promise alignment + readiness gates; 8 tasks; spec: docs/archived/spec-DEV-009.md | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-009; estimate M; Release 4.3 cycle | AgToosa |
| 2026-05-23 | 🏗️ Build 🏗️ Started — DEV-009, 8 tasks; scope: AgToosa_Readiness, Status, README, SECURITY, lib/config.sh, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | Task 🟢 8/8 complete — DEV-009; R1–R8 + full suite 197/197 green | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-009 promise alignment implemented; validation R1–R8 8/8; full suite 178/197 (install bats pre-existing sandbox failures) | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-009 — 4-persona review | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-009; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-009.md | AgToosa |
| 2026-05-23 | 🚀 Ship 🚀 Deployed — DEV-009; smoke R1–R8 + D3 10/10 green; v4.3.0; archived spec + review | AgToosa |
| 2026-05-23 | 🚀 Release 4.3 shipped — v4.3.0; DEV-009 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-010, 7 tasks; scope: template/Docs, platform adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-020; 0 Critical, 6 Warnings (accepted); report: docs/archived/review-DEV-020.md | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-020 — 4-persona review running | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-020 registry @version pinning; RV1–RV5 5/5 green | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-020; estimate S; Release 4.12; spec: docs/archived/spec-DEV-020.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-020, 14 tasks; scope: lib/registry.sh, agtoosa.ps1, registry docs, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-020 — registry install version pinning; estimate S; enrolled Release 4.12; 14 tasks; spec: docs/archived/spec-DEV-020.md | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-010 phase gates + terminal evidence; W1–W5 bats green; full suite 202/202 green; version pins 4.3.0 | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-010 — 4-persona review running | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-010; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-010.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-010; smoke W1–W5 5/5 green; full suite 202/202; v4.4.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.4 shipped — v4.4.0; DEV-010 on main; version parity bash/ps1; Gemini TOML in W1/W5 | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-011 — product vs dogfood boundary; estimate M; enrolled Release 4.5; 14 tasks; ADR-008 proposed | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-011; estimate M; Release 4.5; 14 tasks planned; test plan: docs/AgToosa_TestPlan-DEV-011.md | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-011; B1–B5 5/5 green; full suite 207/207 green; scope: maintainer guide, template docs, adapters, ADR-008 | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-011 — 4-persona review running | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-011; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-011.md | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-012 — GitHub slash command routing spec drafted; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-012.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-011; smoke B1–B5 5/5 green; full suite 207/207; v4.5.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.5 shipped — v4.5.0; DEV-011 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-012; estimate S; Release 4.6; 11 tasks; test plan: docs/AgToosa_TestPlan-DEV-012.md | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-012, 11 tasks; scope: template/.github/prompts, copilot-instructions, agtoosa.agent, AgToosa_Init/Spec/Skills, agtoosa-spec skill, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-012 GitHub slash routing; G1–G5 5/5 green; full suite 212/212 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-012 — 4-persona review running | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-012; 0 Critical, 5 Warnings (1 fixed, 4 accepted); report: docs/archived/review-DEV-012.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-012; smoke G1–G5 5/5 green; full suite 212/212; v4.6.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.6 shipped — v4.6.0; DEV-012 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-013 — /agtoosa-ship check cleanup; estimate S; enrolled Release 4.7; 14 tasks; test plan: docs/AgToosa_TestPlan-DEV-013.md | AgToosa |
| 2026-05-24 | 🚀 /agtoosa-init re-run — context refresh; milestone v4.6.0; AI configs validated (maintainer dogfood); Epics DEV-001–004 confirmed | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-014 — Cursor slash command routing bug spec drafted; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-014.md | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-014, 14 tasks; scope: template/.cursor/commands, .cursor/rules, AgToosa_Init/Spec/Skills, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-014 Cursor slash routing; CU1–CU5 5/5 green; full suite 223/223 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-014 — 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-014; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-014.md | AgToosa |
| 2026-05-23 | 🏗️ Build 🏗️ Started — DEV-013, 14 tasks; scope: AgToosa_Ship.md, template ship adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-013 ship-check cleanup; C1–C6 6/6 green; full suite 218/218 green | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-013 — 4-persona review | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-013; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-013.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-013; smoke C1–C6 6/6 green; full suite 223/223; v4.7.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.7 shipped — v4.7.0; DEV-013 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-014; smoke CU1–CU5 5/5 green; full suite 223/223; v4.8.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.8 shipped — v4.8.0; DEV-014 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-015 — Windsurf slash command routing; estimate S; enrolled Release 4.9; 14 tasks; test plan: docs/AgToosa_TestPlan-DEV-015.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-015; estimate S; Release 4.9; 14 tasks planned | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-015, 14 tasks; scope: template/.windsurf/workflows, .windsurf/rules, AgToosa_Init/Spec/Skills, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-015 Windsurf slash routing; WS1–WS5 5/5 green; full suite 228/228 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-015 — 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-015; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-015.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-015; smoke WS1–WS5 5/5 green; full suite 228/228; v4.9.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.9 shipped — v4.9.0; DEV-015 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-016 — Gemini slash command routing; estimate S; 14 tasks; test plan: docs/AgToosa_TestPlan-DEV-016.md | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-003 registry prod-readiness; RG1–RG8 8/8 green; full suite 240/241 (pre-existing test 18 flake) | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-016 Gemini slash routing; GM1–GM5 5/5 green; full suite 246/246 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-003 + DEV-016 — 4-persona review (uncommitted maintainer dogfood batch) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-003; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-003.md | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-016; 0 Critical, 6 Warnings (accepted); report: docs/archived/review-DEV-016.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-003 + DEV-016; smoke RG1–RG8 + GM1–GM5 all green; full suite 246/246; bundled in v4.11.0 release train | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-017 — Codex slash discoverability; estimate S; test plan: docs/AgToosa_TestPlan-DEV-017.md | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-017 Codex prompts + generator wiring; CX1–CX5 5/5 green | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-017; 0 Critical; report: docs/archived/review-DEV-017.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-017; smoke CX1–CX5 5/5 green; full suite 246/246; v4.11.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.11 shipped — v4.11.0; DEV-017 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-018, 10 tasks; scope: agtoosa.sh, agtoosa.ps1, lib/registry.sh, lib/install.sh, registry docs, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-018 pack queue; PK1–PK5 5/5 green; PK+registry filter 14/14 green; implementation in b273105; full suite has pre-existing/teardown flakes (ship/ not empty) | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-018 — 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-018; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-018.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-020; smoke RV1–RV5 5/5 green; registry slice 21/21; v4.12.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-018; smoke PK1–PK5 5/5 green; bundled in v4.12.0 release train | AgToosa |
| 2026-05-24 | 🚀 Release 4.12 shipped — v4.12.0; DEV-018 + DEV-020 on release/v4.11.0 branch; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-021 — E2E pinned registry install (RV6); estimate S; spec: docs/archived/spec-DEV-021.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-021; estimate S | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-021; RV6 E2E pinned install; RV1–RV6 6/6 green | AgToosa |
| 2026-05-24 | ✅ Review passed — DEV-021; RV6 E2E; 0 Critical; review: docs/archived/review-DEV-021.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-021; smoke RV6 green; RV1–RV6 6/6; v4.12.1; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-022; smoke RC1–RC3 3/3 green; registry slice 27/27; v4.12.2; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.12.2 patch — v4.12.2; DEV-022; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-019 — Master Architecture document; estimate M; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-019.md | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-022 — 4-persona review (PS1 publish + offline cache) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-022; 0 Critical; report: docs/archived/review-DEV-022.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-019; estimate M; Release 4.13; spec: docs/archived/spec-DEV-019.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-019, 11 tasks; scope: template/Docs, root agent instructions, lib/config.sh, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-019 Master Architecture document; MA1–MA8 focused coverage green; bash syntax green | AgToosa |
| 2026-05-24 | 🔀 Merge release/v4.11.0 → main — DEV-018/020/021 release train integrated with DEV-019 build on main | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-019; 0 Critical; report: docs/archived/review-DEV-019.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-019; smoke MA1–MA8 8/8 green; v4.13.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.13 shipped — v4.13.0; DEV-019 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-023 slash parity audit; WP1–WP5 5/5 green; template Init/Spec/Skills + Codex ship fixes | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-023; 0 Critical; report: docs/archived/review-DEV-023.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-023; smoke WP1–WP5 5/5 green; v4.14.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.14 shipped — v4.14.0; DEV-023 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-024 — maintainer status/readiness doc parity; estimate S; enrolled Release 4.15; 7 tasks; spec: docs/archived/spec-DEV-024.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-024; estimate S; Release 4.15 | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-024, 7 tasks; scope: docs/AgToosa_Status.md, docs/AgToosa_Readiness.md, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-024; MD1–MD5 5/5 green; maintainer status/readiness parity | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-024 — 4-persona review | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-024; 0 Critical, 3 Warnings (accepted); report: docs/archived/review-DEV-024.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-024; smoke MD1–MD5 5/5 green; v4.14.1; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.15 shipped — v4.14.1; DEV-024 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-025 — maintainer `docs/` path normalization; estimate S; v5.0.0 cycle; 10 tasks; spec: docs/archived/spec-DEV-025.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-025; estimate S; Release 5.0 / v5.0.0; test plan: docs/AgToosa_TestPlan-DEV-025.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-025, 10 tasks; scope: docs/AgToosa_*.md, format guides, agtoosa-maintainer.md, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-025; PN1–PN5 5/5 green; MD1–MD5 + B1 regression unchanged | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-025 — 4-persona review | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-025; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-025.md | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-026 — Codex agent mode spec workflow execution; estimate S; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-026.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-026; estimate S; remains Backlog/Todo until explicitly enrolled after DEV-025 | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-025; smoke PN1–PN5 5/5 green; full suite 282/282; v5.0.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 5.0 shipped — v5.0.0; DEV-025 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-026, 8 tasks; scope: template/.codex/skills/agtoosa-spec, template/.codex/prompts/agtoosa-spec.md, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-026; CS1–CS5 + K2/K3/W1/CX1 focused 11/11 green; full suite 287/287 | AgToosa |
| 2026-05-24 | 🔍 Review started — DEV-026; 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Approved — DEV-026; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-026.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-026; smoke CS1–CS5 5/5 green; full suite 287/287; v5.0.1; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 5.0.1 shipped — v5.0.1; DEV-026 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-027 — agentic `/agtoosa-update`; estimate M; enrolled v5.1.0; 13 tasks; spec: docs/archived/spec-DEV-027.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-027; estimate M; v5.1.0; test plan: docs/AgToosa_TestPlan-DEV-027.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-027, 13 tasks; scope: template/Docs/AgToosa_Update.md, platform adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-027; T-001–T-009 + MA4 + `--update` regression green (28/28 filtered); full suite pending review gate | AgToosa |
| 2026-05-24 | 🔍 Review passed — DEV-027; T-001–T-009 green; 0 🔴 Critical; report: `docs/archived/review-DEV-027.md` | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-027; smoke T-001–T-007 7/7 green; DEV-027 bats T-001–T-009 9/9 green; v5.1.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 5.1.0 shipped — v5.1.0; DEV-027; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-028 — plan-mode spec interview; estimate M; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-028.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-028, 13 tasks; scope: template/Docs/AgToosa_Spec.md, docs mirrors, native spec adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-028; DEV-028 T-001–T-010 + W1/W3/CS*/G4/CU1/WS1/GM1 regression green; ready for `/agtoosa-review` | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-028; estimate M; explicit user approval; ready for `/agtoosa-review` | AgToosa |
| 2026-05-24 | 🔍 Review started — DEV-028; 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | 🔍 Review ✅ Passed — DEV-028; 0 🔴 Critical, 4 🟡 Warnings (accepted); report: docs/archived/review-DEV-028.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-028; smoke T-001–T-009 9/9 green; DEV-028 bats T-001–T-010 10/10; full suite 306/306; v5.2.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 5.2.0 shipped — v5.2.0; DEV-028; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-029 — branch-protection push-safe workflow; test plan: docs/AgToosa_TestPlan-DEV-029.md | AgToosa |
| 2026-05-24 | 🏗️ Build started — DEV-029, 4 tasks; scope: .github/workflows/branch-protection.yml, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-029; DEV-029 T-001–T-005 5/5 green; full suite 311/311; tasks 3–4 manual-deferred (post-merge GitHub verification) | AgToosa |
| 2026-05-25 | ✏️ /agtoosa-spec DEV-030 plan — operating-context branch for `/agtoosa-update`; spec: docs/archived/spec-DEV-030.md; estimate S (proposed) | AgToosa |
| 2026-05-25 | ✅ Spec approved — DEV-030; estimate S; explicit user approval; next: `/agtoosa-spec tasks` or `/agtoosa-build` | AgToosa |
| 2026-05-25 | ✏️ /agtoosa-spec DEV-030 tasks — 5 task groups, 12 test IDs; test plan: docs/AgToosa_TestPlan-DEV-030.md | AgToosa |
| 2026-05-25 | 🏗️ Build started — DEV-030, 14 tasks; scope: AgToosa_Update.md, agtoosa.sh, agtoosa.ps1, tests/agtoosa.bats | AgToosa |
| 2026-05-25 | 🏗️ Build complete — DEV-030; focused 17/17 + DEV-027 T-001–T-009 9/9 + full suite 324/324 green; ready for `/agtoosa-review` | AgToosa |
| 2026-05-25 | 📋 /agtoosa-spec DEV-031 — Project-specific specialist subagents; 15 Must ACs; M estimate; backlog only; prior DEV-031 chore → DEV-032 | AgToosa |
| 2026-05-25 15:31 | ✅ /agtoosa-spec — Spec Approved — DEV-031 — docs/archived/spec-DEV-031.md; estimate M; backlog only | AgToosa |
| 2026-05-25 | 🏗️ /agtoosa-build — DEV-031 complete — canonical Specialists doc, init/update/spec orchestration, 15 DEV-031 bats green | AgToosa |
| 2026-05-25 | 🔍 /agtoosa-review — DEV-031 PASS — 0 Critical, 3 Warning (adapter parity optional, DEV-030 test, commit hygiene); review-DEV-031.md | AgToosa |
| 2026-05-25 | 🚀 Ship complete — DEV-031 v5.2.3; CHANGELOG + version pins; DEV-031 T-001–T-015 15/15; smoke pass; Milestone v5.2.4 (next) | AgToosa |
| 2026-05-25 | 📋 /agtoosa-task DEV-032 — review/ship closure for DEV-029 after status findings; spec-DEV-029 threat model + wave plan updated | AgToosa |
| 2026-05-25 | 🏗️ Build complete — DEV-032 patch-first versioning; ADR-005 + ship/review/maintainer docs; Milestone v5.2.1 (next); VP-001–VP-005 5/5 green | AgToosa |
| 2026-05-25 | 🔍 Review passed — DEV-029; 0 Critical; report: docs/archived/review-DEV-029.md; workflow step `if:` push guard fix | AgToosa |
| 2026-05-25 | 🏗️ /agtoosa-build DEV-029 — tasks 3.1–3.2 marked done (A); push run 26419089522 success; task 4.1 PR regression still open | AgToosa |
| 2026-05-25 | 🔧 Fix pushed — workflow step `if` → shell checks (d58bedb); stops 0s parse failures on push | AgToosa |
| 2026-05-25 | 🚀 Ship complete — DEV-029 v5.2.1; CHANGELOG + version pins; full suite 329/329; manual 3–4 still in Manual / Deferred | AgToosa |
| 2026-05-25 | 🔍 Review ✅ Approved — DEV-032; 0 🔴 Critical, 4 🟡 Warnings (accepted); report: docs/archived/review-DEV-032.md | AgToosa |
| 2026-05-25 | 🚀 Ship complete — DEV-032 v5.2.2; CHANGELOG + version pins; DEV-032 VP-001–VP-005 5/5; Milestone v5.2.3 (next) | AgToosa |
| 2026-05-25 | 🔍 Review started — DEV-030; 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-25 | 🔍 Review ✅ Passed — DEV-030; 1 🔴 Critical found+fixed (interactive install self-target guidance); full suite 344/344; report: docs/archived/review-DEV-030.md | AgToosa |
| 2026-05-26 | 🚀 /agtoosa-init re-validation — Maintainer Dogfood; Phases C–F; epics confirmed; DEV-004 success criteria refreshed; specialist/skill proposals deferred (no roster writes) | AgToosa |
| 2026-06-05 | ✏️ /agtoosa-spec tasks — archived DEV-032 + DEV-033 Active Tasks (orphaned vs Active Cycle); DEV-030 sole live task tree | AgToosa |
| 2026-06-06 | ✏️ /agtoosa-spec DEV-034 — Maintainer release-state reconciliation; spec + test plan created; next action: reconcile DEV-033/active-cycle/changelog/version ledger before new feature work | AgToosa |
| 2026-06-05 | 🚀 Ship complete — DEV-030 + DEV-033 v5.2.4; CHANGELOG + version pins; DEV-030 T-001–T-011 + DEV-033 PV-001–PV-003; full suite 358/358; Milestone v5.2.5 (next); review-DEV-033.md | AgToosa |
| 2026-06-05 | 🚀 Release 5.2.4 shipped — v5.2.4; DEV-030 + DEV-033 on main; version parity bash/ps1; stuck-Done backlog cleared | AgToosa |
| 2026-06-06 | 🏗️ /agtoosa-build DEV-034 complete — active-cycle/changelog ledger reconciled after v5.2.4 ship; no `5.2.5` bump yet; DEV-034 LR-001–LR-006 6/6 green; version/DEV-033 slice 6/6 green | AgToosa |
| 2026-06-05 | 🔍 Review ✅ Passed — DEV-034; 0 🔴 Critical, 1 🟡 Warning (accepted); report: docs/archived/review-DEV-034.md | AgToosa |
| 2026-06-05 | 🚀 Ship complete — DEV-034 v5.2.5; CHANGELOG + version pins; DEV-034 LR-001–LR-006 6/6; full suite 358/358; Milestone v5.2.6 (next) | AgToosa |
| 2026-06-05 | 🚀 Release 5.2.5 shipped — v5.2.5; DEV-034 on main; version parity bash/ps1; active cycle archived | AgToosa |
| 2026-06-06 | 🔧 Manual complete — DEV-029 task 4.1; PR #29 → run `27050231744` success; all four PR hygiene jobs ran; Manual / Deferred cleared | AgToosa |
| 2026-06-05 | ✏️ /agtoosa-spec DEV-035 — PSScriptAnalyzer CI gate; XS estimate; enrolled Release 5.2.6; 8 tasks; spec: docs/archived/spec-DEV-035.md | AgToosa |
| 2026-06-06 | 🏗️ /agtoosa-build DEV-035 complete — PSScriptAnalyzer CI gate added to `windows-smoke`; PA-001–PA-003 3/3; version/DEV-033/MR5 slice 6/6; full suite 361/361; local analyzer clean + negative probe detected violation | AgToosa |
