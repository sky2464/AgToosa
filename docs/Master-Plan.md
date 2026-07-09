# Master-Plan

> **Source of truth for active work.** Completed work lives in `docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-07-08 (/agtoosa-build — DEV-054 M-1 manual-done)

## Project Charter

| Field | Value |
|-------|-------|
| Product | `AgToosa` |
| GitHub repo | `https://github.com/sky2464/AgToosa` |
| Milestone | `v5.3.6` (next) — PATCH train per `docs/adr/ADR-005-release-cadence.md` |
| Active cycle | — |
| Cycle capacity | `8 story points` |
| Current phase | 🏁 v5.3.5 shipped — DEV-054 complete |

## Active Cycle

> Stories committed to the current sprint/cycle.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| — | — | — | — | — | — |

<!-- Archived to docs/archived/cycle-2026-07-08-release-5.3.5.md -->
<!-- Archived to docs/archived/cycle-2026-07-08-release-5.3.4.md -->
<!-- Archived to docs/archived/cycle-2026-07-08-release-5.3.3.md -->
<!-- DEV-074 shipped 2026-07-08 v5.3.2 — see Completed This Cycle -->

<!-- Archived to docs/archived/cycle-2026-06-10-release-5.3.0.md -->
<!-- Archived to docs/archived/cycle-2026-06-07-release-5.2.7.md -->
<!-- Archived to docs/archived/cycle-2026-06-07-release-5.2.6.md -->
<!-- Archived to docs/archived/cycle-2026-06-05-release-5.2.5.md -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.2.0.md -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.1.0.md (DEV-027) -->
<!-- Prior: docs/archived/cycle-2026-05-24-release-5.0.1.md (DEV-026) -->

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

<!--
**DEV-054 — Signed Registry Provenance** (spec: `docs/archived/spec-DEV-054.md`) — shipped 2026-07-08 v5.3.5

- [x] **1.** RED contract bats (SP-001–SP-005)
- [x] **2.** Provenance schema docs + ADR-011 + Trust/Readiness/Registry claim updates
- [x] **3.** Optional soft-warn minisign verify in registry (+ bootstrap)
- [x] **4.** Bundled pubkey path + config registration + fixture keys for tests
- [x] **5.** GREEN bats + test-plan evidence; M-1 minisign keygen + release sidecars `[manual-done]`
-->

<!--
**DEV-049 — Evidence Ledger** (spec: `docs/archived/spec-DEV-049.md`) — shipped 2026-07-08 v5.3.4

- [x] **1.** RED contract bats (EL-001–EL-005)
- [x] **2.** Canonical Evidence doc + JSONL seed + maintainer mirrors
- [x] **3.** Wire Review, Ship, Agent, Quickref, Readiness, Roadmap, Import pointer
- [x] **4.** Register config + optional thin `/agtoosa-evidence` adapters
- [x] **5.** GREEN bats + test-plan evidence
-->

<!--
**DEV-047 — Async Agent Handoff Packs** (spec: `docs/archived/spec-DEV-047.md`) — shipped 2026-07-08 v5.3.3

- [x] **1.** RED contract bats (HO-001–HO-005)
- [x] **2.** Canonical Handoff doc + maintainer mirror
- [x] **3.** Wire Build, Agent, Quickref, Readiness, Roadmap
- [x] **4.** Register config + platform adapters + entry points
- [x] **5.** GREEN bats + test-plan evidence

**DEV-048 — Agent Result Import Gate** (spec: `docs/archived/spec-DEV-048.md`) — shipped 2026-07-08 v5.3.3

- [x] **1.** RED contract bats (IR-001–IR-005)
- [x] **2.** Canonical Import doc + maintainer mirror
- [x] **3.** Wire Build, Ship, Agent, Quickref, Readiness, Roadmap
- [x] **4.** Register config + platform adapters + entry points
- [x] **5.** GREEN bats + test-plan evidence
-->

<!--
**DEV-074 — PS1 non-interactive install parity + Pester suite** (spec: `docs/archived/spec-DEV-074.md`) — shipped 2026-07-08 v5.3.2

- [x] **1.** RED contract tests
- [x] **2.** Implement PS1 non-interactive install
- [x] **3.** Docs sync
- [x] **4.** GREEN Pester + evidence
- [x] **5.** Verify
-->

<!--
**DEV-042 — Spec Quality Analyzer** (spec: `docs/archived/spec-DEV-042.md`) — shipped 2026-06-10 v5.3.0

**DEV-043 — Brownfield Spec Drift Baseline** (spec: `docs/archived/spec-DEV-043.md`) — shipped 2026-06-10 v5.3.0

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
| DEV-071 | M-1 | 2026-06-09 | Publish the npm wrapper: `cd npm && npm publish` (requires npm account/2FA) `[manual]` |
| DEV-062 | M-1 | 2026-06-09 | Optional: publish the gate as a GitHub Marketplace Action for discoverability `[manual]` |
| DEV-066 | M-1 | 2026-06-09 | Configure required reviewers on the `release` environment in repo settings `[manual]` |
| DEV-066 | M-2 | 2026-06-09 | Mirror the pinned `Formula/agtoosa.rb` to the `sky2464/homebrew-agtoosa` tap `[manual]` |
| DEV-060 | M-1 | 2026-06-09 | Execute benchmark tasks B1–B3 against Spec Kit/OpenSpec/BMAD and publish results under `docs/benchmarks/results/` `[manual]` |

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
| DEV-044 | Feature: EARS-to-Test TDD Gate | Feature | M | DEV-004 | P0 | ✅ Done — delivered via DEV-061 (EARS lint + AC↔test check) and DEV-067 (RED/GREEN evidence gate) |
| DEV-045 | Feature: Work Package Wave DAG | Feature | M | DEV-002 | P1 | ⬜ Backlog — wave-by-wave execution shipped in DEV-067; owned-files/inputs/outputs schema still open |
| DEV-046 | Feature: Optional Worktree Isolation | Feature | M | DEV-001 | P1 | ⬜ Backlog |
| DEV-047 | Feature: Async Agent Handoff Packs | Feature | M | DEV-002 | P0 | 🏁 Shipped — v5.3.3 |
| DEV-048 | Feature: Agent Result Import Gate | Feature | M | DEV-002 | P0 | 🏁 Shipped — v5.3.3 |
| DEV-049 | Feature: Evidence Ledger | Feature | M | DEV-004 | P0 | 🏁 Shipped — v5.3.4 |
| DEV-050 | Feature: Cross-Model Review Gate | Feature | S | DEV-002 | P1 | ⬜ Backlog |
| DEV-051 | Feature: Tracker Sync Bridge | Feature | M | DEV-003 | P1 | ⬜ Backlog |
| DEV-052 | Feature: Hook Automation Pack | Feature | M | DEV-002 | P1 | ⬜ Backlog |
| DEV-053 | Feature: Extension and Preset Catalog | Feature | M | DEV-003 | P1 | ⬜ Backlog |
| DEV-054 | Feature: Signed Registry Provenance | Feature | M | DEV-003 | P0 | 🏁 Shipped — v5.3.5 |
| DEV-055 | Feature: Agent Capability Matrix | Feature | S | DEV-002 | P1 | ⬜ Backlog |
| DEV-056 | Feature: Retrospective Learning Loop | Feature | S | DEV-002 | P2 | ⬜ Backlog |
| DEV-057 | Feature: Multi-Repo Story Overlay | Feature | L | DEV-002 | P2 | ⬜ Backlog |
| DEV-058 | Feature: Local Dashboard | Feature | M | DEV-004 | P2 | ⬜ Backlog |
| DEV-059 | Feature: Governance Policy-as-Code | Feature | M | DEV-004 | P1 | ⬜ Backlog |
| DEV-060 | Docs: Public Benchmark Suite | Docs | M | DEV-004 | P2 | ✅ Done — suite + scoring + claim boundary in `docs/benchmarks/`; competitor runs manual-deferred |
| DEV-035 | Chore: Launch P0 publication and quickstart gate | Chore | M | DEV-004 | P0 | ✅ Done |
| DEV-036 | Fix: Windows and registry parity | Fix | M | DEV-001 / DEV-003 | P1 | ✅ Done |
| DEV-037 | Chore: Truthful launch documentation and positioning | Chore | M | DEV-002 | P1 | ✅ Done |
| DEV-038 | Chore: Distribution hardening and release readiness gate | Chore | M | DEV-004 | P1 | ✅ Done |
| DEV-039 | Docs: First 15 minutes proof and growth positioning | Docs | S | DEV-002 | P2 | ✅ Done |
| DEV-040 | Docs: Team trust roadmap | Docs | S | DEV-003 / DEV-004 | P2 | ✅ Done |
| DEV-031 | Feature: Project-specific specialist subagents | Feature | M | DEV-002 | High | 🏁 Shipped |
| DEV-032 | Chore: Patch-first release versioning (5.x line) | Chore | S | DEV-001 | High | 🏁 Shipped |
| DEV-030 | Fix: `/agtoosa-update` self-target uncertainty | Fix | S | DEV-002 | High | 🏁 Shipped |
| DEV-033 | Fix: agtoosa.ps1 PSScriptAnalyzer approved verbs | Fix | XS | DEV-001 | Medium | 🏁 Shipped |
| DEV-034 | Chore: Maintainer release-state reconciliation | Chore | S | DEV-004 | High | 🏁 Shipped |

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-001 | Epic: Core Generator Engine | 1 open / 1 total | ⬜ Backlog |
| DEV-002 | Epic: Workflow Templates | 9 open / 19 total | 🟦 Todo |
| DEV-003 | Epic: Community Template Registry | 4 open / 4 total | ⬜ Backlog |
| DEV-004 | Epic: Testing & QA Harness | 5 open / 6 total | ⬜ Backlog |

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
    *   **Last shipped:** DEV-005 — M1–M4 bats + CHANGELOG hygiene → `docs/archived/spec-DEV-005.md`

## Completed This Cycle

> Detail lives in `docs/archived/`. This section shows pointer rows only — links to archived spec files.
> Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| DEV-054 | Feature: Signed Registry Provenance | 2026-07-08 | [spec-DEV-054.md](archived/spec-DEV-054.md) · [review-DEV-054.md](archived/review-DEV-054.md) · [evidence-DEV-054.md](archived/evidence-DEV-054.md) |
| DEV-049 | Feature: Evidence Ledger | 2026-07-08 | [spec-DEV-049.md](archived/spec-DEV-049.md) · [review-DEV-049.md](archived/review-DEV-049.md) · [evidence-DEV-049.md](archived/evidence-DEV-049.md) |
| DEV-047 | Feature: Async Agent Handoff Packs | 2026-07-08 | [spec-DEV-047.md](archived/spec-DEV-047.md) · [review-DEV-047-048.md](archived/review-DEV-047-048.md) |
| DEV-048 | Feature: Agent Result Import Gate | 2026-07-08 | [spec-DEV-048.md](archived/spec-DEV-048.md) · [review-DEV-047-048.md](archived/review-DEV-047-048.md) |
| DEV-074 | Feature: PS1 non-interactive install parity (`-Path -Platforms -Yes`) + Pester suite | 2026-07-08 | [spec-DEV-074.md](archived/spec-DEV-074.md) · [review-DEV-074.md](archived/review-DEV-074.md) |
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
| DEV-041 | Chore: Public launch publication proof | 2026-06-08 | [spec-DEV-041.md](archived/spec-DEV-041.md) · [review-DEV-041.md](archived/review-DEV-041.md) |
| DEV-042 | Feature: Spec Quality Analyzer | 2026-06-10 | [spec-DEV-042.md](archived/spec-DEV-042.md) · [review-DEV-042-043.md](archived/review-DEV-042-043.md) |
| DEV-043 | Feature: Brownfield Spec Drift Baseline | 2026-06-10 | [spec-DEV-043.md](archived/spec-DEV-043.md) · [review-DEV-042-043.md](archived/review-DEV-042-043.md) |
| DEV-061 | Feature: Deterministic lifecycle verifier | 2026-06-10 | [spec-DEV-061.md](archived/spec-DEV-061.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-062 | Feature: AgToosa Gate CI template | 2026-06-10 | [spec-DEV-062.md](archived/spec-DEV-062.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-063 | Feature: Phase-event log + Update Log rotation | 2026-06-10 | [spec-DEV-063.md](archived/spec-DEV-063.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-064 | Fix: Safe tar extraction | 2026-06-10 | [spec-DEV-064.md](archived/spec-DEV-064.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-065 | Feature: Pack containment | 2026-06-10 | [spec-DEV-065.md](archived/spec-DEV-065.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-066 | Fix: Pinned install chain | 2026-06-10 | [spec-DEV-066.md](archived/spec-DEV-066.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-067 | Fix: Executable workflows | 2026-06-10 | [spec-DEV-067.md](archived/spec-DEV-067.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-068 | Fix: Adapter drift | 2026-06-10 | [spec-DEV-068.md](archived/spec-DEV-068.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-069 | Fix: Governance wiring | 2026-06-10 | [spec-DEV-069.md](archived/spec-DEV-069.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-070 | Feature: Token diet | 2026-06-10 | [spec-DEV-070.md](archived/spec-DEV-070.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-071 | Feature: Non-interactive CLI + npm wrapper | 2026-06-10 | [spec-DEV-071.md](archived/spec-DEV-071.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-072 | Feature: Spec change control + living specs | 2026-06-10 | [spec-DEV-072.md](archived/spec-DEV-072.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-073 | Feature: Doctor + uninstall + README | 2026-06-10 | [spec-DEV-073.md](archived/spec-DEV-073.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
<!-- Older rows through 2026-06-07: docs/archived/updatelog-2026.md -->
| 2026-06-08 | 🏗️ /agtoosa-build DEV-041 public proof complete — repo, release, raw bootstraps, registry, Homebrew tap, support surfaces, and proof repo public; public launch publication proof complete | AgToosa |
| 2026-06-08 | 🔍 Review ✅ Passed — DEV-041; 0 🔴 Critical, 1 🟡 Warning accepted; report: `docs/archived/review-DEV-041.md` | AgToosa |
| 2026-06-08 | 🚀 Ship complete — DEV-041 v5.2.7 Shipped; CHANGELOG + version pins; public launch gate; full suite pending current ship verification; Milestone v5.2.8 (next) | AgToosa |
| 2026-06-08 | 🚀 Release 5.2.7 shipped — v5.2.7; public launch publication proof on main; version parity bash/ps1; active cycle archived | AgToosa |
| 2026-06-08 | ✏️ /agtoosa-spec DEV-042-DEV-060 — Competitive execution wave specs and test plans created; backlog only; implementation requires per-story enrollment and evidence gates | AgToosa |
| 2026-06-08 | ✅ /agtoosa-spec DEV-042 — Spec Quality Analyzer enrolled in Active Cycle; approved backlog spec promoted with task tree and wave plan | AgToosa |
| 2026-06-08 | 🏗️ /agtoosa-build DEV-042 — Spec Quality Analyzer gate implemented in maintainer and template spec workflows; 4/5 tasks complete pending final validation | AgToosa |
| 2026-06-08 | 🏗️ /agtoosa-build DEV-042 complete — Spec Quality Analyzer gate implemented; DEV-042 focused and adjacent validation green; full suite pending final run | AgToosa |
| 2026-06-08 | ✅ /agtoosa-spec DEV-043 — Brownfield Spec Drift Baseline enrolled in Active Cycle; approved backlog spec promoted with task tree and wave plan | AgToosa |
| 2026-06-08 | 🏗️ /agtoosa-build DEV-043 complete — Brownfield current-state baseline workflow implemented in maintainer and template spec workflows; focused validation green pending full suite | AgToosa |
| 2026-06-09 | ✏️ /agtoosa-spec DEV-061–DEV-073 — proof-engine + supply-chain wave enrolled from deep-review top-20 (verifier, CI gate, events, tar safety, pack containment, pinned chain, executable workflows, adapter fixes, governance wiring, token diet, non-interactive CLI/npm, spec amend/living specs, doctor/uninstall/README); consolidated plan: docs/AgToosa_TestPlan-DEV-061-073.md | AgToosa |
| 2026-06-09 | 🏗️ /agtoosa-build DEV-061–DEV-073 complete — Docs/agtoosa-verify.sh + --verify/--doctor/--uninstall + --path/--platforms/--yes wired (bash); PS1 gains Test-SafeTarArchive/Test-PackFiles/Test-PackPathDenied + verified gate; bootstraps fail closed with --sha256; Formula pinned to v5.2.7 tarball+sha256; release workflow publishes SHA256SUMS; mirrors regenerated from canonical templates; 29 new bats (VF/SC/NI/DR/UN/WC/PS) green; verifier self-run PASS on this repo | AgToosa |
| 2026-06-09 | 🧾 Threat models added to spec-DEV-042/043 (verifier Gate 3 found the gap); DEV-044 + DEV-060 closed via wave delivery; npm publish, tap mirror, release-env reviewers, signing keys, and benchmark runs recorded in Manual / Deferred | AgToosa |
| 2026-06-10 | 🔍 Review 🔍 Started — DEV-042–DEV-043 + DEV-061–DEV-073 — 4-persona review running | AgToosa |
| 2026-06-10 | 🔍 Review ✅ Approved — DEV-042–DEV-043; 0 🔴 Critical, 2 🟡 Warning (accepted); report: `docs/archived/review-DEV-042-043.md` | AgToosa |
| 2026-06-10 | 🔍 Review ✅ Approved — DEV-061–DEV-073; 0 🔴 Critical, 5 🟡 Warning (accepted); full suite 458/458; verifier PASS; report: `docs/archived/review-DEV-061-073.md` | AgToosa |
| 2026-06-10 | 🚀 Ship complete — DEV-042–DEV-073 v5.3.0; smoke VF-001/SC-002/NI-001/SC-005 PASS; full suite 461/461; verifier PASS; cycle archived | AgToosa |
| 2026-06-10 | 🚀 Release 5.3.0 shipped — v5.3.0; proof engine + supply chain wave on branch; version parity bash/ps1/npm; Milestone v5.3.1 (next) | AgToosa |

| 2026-07-07 | 🏗️ Merged v5.3.x fix batch — pack lock provenance, re-install data loss, multi-root tarball smuggle, npm pack queue, PowerShell hooks/merge containment (PRs #36–#48, #61–#63) | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.1 patch; Unreleased fixes + bootstrap durable pack queue (PR #64); focused SR bats green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.1 shipped — v5.3.1; version parity bash/ps1/npm; Milestone v5.3.2 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-074 enrolled — PS1 non-interactive install parity; spec approved; test plan `docs/AgToosa_TestPlan-DEV-074.md` | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-074 — Task 🟢 12/12 complete — PS1 `-Path`/`-Platforms`/`-Yes` parity; bats DEV-074 CT-001–CT-004; Pester NI-001–NI-005 green | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-074 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-074; 0 🔴 Critical, 2 🟡 Warning (accepted); report: `docs/archived/review-DEV-074.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.2 — DEV-074 PS1 non-interactive install parity; bats DEV-074 SR-001–SR-003 green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.2 shipped — v5.3.2; version parity bash/ps1/npm; Milestone v5.3.3 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-047 + DEV-048 enrolled — deepened executable specs; Spec ✅ Approved; estimate M each; Active Cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-047 + DEV-048 — Task 🟢 5/5 + 5/5 — Handoff/Import docs, adapters, Build/Ship wiring, HO/IR bats | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-047 + DEV-048; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-047 + DEV-048 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-047 + DEV-048; 0 🔴 Critical, 4 🟡 Warning accepted (1 fixed); report: `docs/archived/review-DEV-047-048.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.3 — DEV-047 + DEV-048 handoff/import; bats DEV-047/048 HO/IR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.3 shipped — v5.3.3; version parity bash/ps1/npm; Milestone v5.3.4 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-049 enrolled — Evidence Ledger deepened (markdown + optional JSONL); estimate M; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-08 | /agtoosa-spec — Spec ✅ Approved — DEV-049 — spec-DEV-049.md; estimate M; enrolled in cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-049 Started — 5 tasks; scope: AgToosa_Evidence.md, Review/Ship wiring, JSONL seed, EL bats, config/adapters | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-049 — Task 🟢 5/5 complete — Evidence ledger docs, Review/Ship wiring, adapters, EL-001–EL-005 green | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-049; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-049 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-049; 0 🔴 Critical, 5 🟡 Warning accepted; report: `docs/archived/review-DEV-049.md`; evidence: `docs/archived/evidence-DEV-049.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.4 — DEV-049 Evidence Ledger; bats DEV-049 EL/SR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.4 shipped — v5.3.4; version parity bash/ps1/npm; Milestone v5.3.5 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-054 enrolled — Signed Registry Provenance deepened (minisign soft-warn, packs+releases); estimate M; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-08 | /agtoosa-spec — Spec ✅ Approved — DEV-054 — spec-DEV-054.md; estimate M; enrolled in cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-054 Started — 5 tasks; scope: registry soft-warn minisign, provenance docs, ADR-011, pubkey path, SP bats | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-054 — Task 🟢 5/5 complete — provenance soft-warn, ADR-011, SP-001–SP-006 green; M-1 remains Manual/Deferred | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-054; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-054 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-054; 0 🔴 Critical, 6 🟡 Warning accepted; report: `docs/archived/review-DEV-054.md`; evidence: `docs/archived/evidence-DEV-054.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.5 — DEV-054 Signed Registry Provenance; bats DEV-054 SP/SR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.5 shipped — v5.3.5; version parity bash/ps1/npm; Milestone v5.3.6 (next) | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build — DEV-054 M-1 `[manual-done]` — maintainer minisign key + pubkey (`4a64308`) + release sidecars (`c4f240b`, `48f3f90`); verify green on bootstrap.sh and agtoosa.sh | AgToosa |
