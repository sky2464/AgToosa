# Spec: DEV-034 — Maintainer release-state reconciliation

> **Story ID:** DEV-034
> **Epic:** DEV-004 — Testing & QA Harness
> **Status:** ✅ Done
> **Estimate:** S
> **Spec created:** 2026-06-06

## Context

The maintainer ledger drifted after the recent `5.2.x` patch train. `docs/Master-Plan.md` still named DEV-030 as the Active Cycle while DEV-031/DEV-032 were shipped and DEV-033 moved through build/review/ship. During DEV-034 build, DEV-030 + DEV-033 were accepted as shipped in `5.2.4`; DEV-034 now compacts the cycle so the next milestone is `v5.2.5` and the only active story is the reconciliation story awaiting review.

This story closes the workflow-state gap before new feature work. The output is a coherent maintainer source of truth: active cycle, active tasks, backlog, completed-cycle pointers, changelog, test-plan evidence, and version pins agree with the actual story state.

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Reconcile maintainer release/workflow state so `docs/Master-Plan.md`, release pins, changelog, and DEV-033/DEV-034 artifacts agree. |
| User outcome | Maintainers can run `/agtoosa-status`, `/agtoosa-review`, and `/agtoosa-ship` without stale active-cycle, orphaned-spec, or version-ledger ambiguity. |
| Success condition | DEV-033 has a clear shipped disposition; `docs/Master-Plan.md` has one coherent active-cycle state; `[Unreleased]` reflects pending DEV-034 work; version pins remain aligned; focused ledger tests pass. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-034"` green, plus focused version parity and DEV-033 smoke evidence recorded in `docs/AgToosa_TestPlan-DEV-034.md`. |
| Non-goals | Adding a new product feature; changing generator copy/update behavior; modifying platform adapters; resolving DEV-029 manual PR-path verification unless the user completes it. |
| Assumptions | DEV-034 is a PATCH-scope chore on the active `5.2.x` line. Existing dirty working-tree edits are user/maintainer work and must be reconciled without reverting unrelated changes. |
| Risks | Ledger cleanup can accidentally hide pending work. Mitigate by preserving DEV-029 manual-deferred state, keeping DEV-033 evidence explicit, and adding grep-based consistency tests. |

## 1. Requirements

### 1.1 User Stories

**As an** AgToosa maintainer, **I want** the release ledger to identify the true active/pending/shipped stories **so that** the next workflow command starts from the correct state.

**As an** AgToosa maintainer, **I want** version pins and release notes to agree **so that** patch releases do not ship with stale `AGTOOSA_VERSION`, README, bats, or formula metadata.

**As an** agent running `/agtoosa-status`, **I want** completed and shipped stories represented consistently **so that** status findings are about real work rather than bookkeeping drift.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/Master-Plan.md` is read THE SYSTEM SHALL show one coherent active-cycle state and SHALL NOT list shipped stories as active work | Must |
| AC-002 | WHEN DEV-033 is shipped THE SYSTEM SHALL represent it consistently in Backlog, Completed This Cycle, test plan, spec, review, and changelog state | Must |
| AC-003 | WHEN the `5.2.4` release is audited THE SYSTEM SHALL confirm `AGTOOSA_VERSION` in `agtoosa.sh` and `agtoosa.ps1`, README badge/snippet, Homebrew formula version, bats version pins, and `CHANGELOG.md` agree | Must |
| AC-004 | WHEN `CHANGELOG.md` and `docs/AgToosa_Changelog.md` are read THE SYSTEM SHALL make `[Unreleased]` accurately describe pending DEV-034 work or explicitly state none after ship | Must |
| AC-005 | WHEN completed-cycle rows are audited THE SYSTEM SHALL include shipped DEV-031/DEV-032 pointers and SHALL NOT duplicate unshipped DEV-033 as completed unless it has shipped | Must |
| AC-006 | WHEN manual-deferred work is audited THE SYSTEM SHALL preserve DEV-029 PR-path verification in `Manual / Deferred Tasks` unless the user confirms completion | Must |
| AC-007 | WHEN focused DEV-034 bats run THE SYSTEM SHALL assert ledger/version invariants that would catch this drift class before the next release | Must |
| AC-008 | WHEN the final review/ship handoff is written THE SYSTEM SHALL state the remaining next action: ship DEV-033, build DEV-034, or start a new feature only after ledger state is clean | Should |

### 1.3 Out of Scope

- Implementing specialist adapter polish from DEV-031 review warning R-003
- Changing registry behavior or PowerShell helper behavior beyond version/release bookkeeping
- Creating a new release workflow or CI job
- Completing the DEV-029 manual PR-path regression without user-provided/manual GitHub PR evidence

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `docs/archived/spec-DEV-034.md` — this spec
- `docs/AgToosa_TestPlan-DEV-034.md` — AC-to-test mapping and evidence
- `docs/archived/review-DEV-033.md` — only if DEV-033 needs review closure before ship
- `docs/archived/review-DEV-034.md` — review result for this reconciliation story

Files to change:

- `docs/Master-Plan.md` — active cycle, active tasks, backlog, completed-cycle pointers, update log
- `CHANGELOG.md` — `[Unreleased]` / `5.2.4` release note depending on ship decision
- `docs/AgToosa_Changelog.md` — maintainer mirror where applicable
- `agtoosa.sh` — `AGTOOSA_VERSION` only if shipping `5.2.4`
- `agtoosa.ps1` — `$AGTOOSA_VERSION` only if shipping `5.2.4`
- `README.md` — version badge and pinned install snippet only if shipping `5.2.4`
- `Formula/agtoosa.rb` — version only if shipping `5.2.4`
- `tests/agtoosa.bats` — DEV-034 ledger/version consistency assertions and version pins if shipping

### 2.2 Data Flow

1. Audit current repo state with `git status --short`, version-pin greps, `CHANGELOG.md`, and `docs/Master-Plan.md`.
2. Accept the current `5.2.4` state where DEV-030 + DEV-033 are shipped.
3. Update `docs/Master-Plan.md` so active cycle, active tasks, backlog, completed-cycle rows, and manual-deferred rows match that decision.
4. Confirm changelog and version pins agree with the `5.2.4` ship, while DEV-034 remains in `[Unreleased]`.
5. Add focused bats coverage for ledger/version invariants.
6. Run focused tests, version parity, and any DEV-033 smoke needed to prove no behavior drift.
7. Record evidence in `docs/AgToosa_TestPlan-DEV-034.md` and review output.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Shipped work remains marked active | Repudiation | Master-Plan consistency ACs and bats greps for shipped vs active rows |
| Version pins drift across Bash, PowerShell, README, bats, and formula | Tampering | Reuse existing version parity tests and add DEV-034 focused pin checks where missing |
| Pending manual work is silently dropped | Information Disclosure | AC-006 requires preserving DEV-029 manual-deferred PR-path row unless user confirms completion |
| Dirty working-tree changes are overwritten | Tampering | Build must inspect diffs and edit only scoped release-ledger surfaces |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `docs/Master-Plan.md`, `CHANGELOG.md`, `docs/AgToosa_Changelog.md`, `agtoosa.sh`, `agtoosa.ps1`, `README.md`, `Formula/agtoosa.rb`, `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-034.md`, `docs/archived/spec-DEV-034.md`, `docs/archived/review-DEV-033.md`, `docs/archived/review-DEV-034.md`
Directories in scope: `docs/`, `docs/archived/`, `tests/`, `Formula/`
Out of scope        : `template/`, `lib/`, `.github/workflows/`, registry behavior, platform adapters, DEV-029 manual PR verification unless user supplies completion evidence

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Audit current release ledger
  - [x] 1.1 Capture current `git status --short`, version pins, changelog top block, and Master-Plan active/backlog/completed rows — _Requirements: AC-001, AC-002, AC-004, AC-005_
  - [x] 1.2 Ship DEV-030 + DEV-033 together as `5.2.4` (PATCH bundle on active MINOR) — _Requirements: AC-002, AC-003, AC-008_
- [x] **2.** Reconcile Master-Plan and changelog state
  - [x] 2.1 Update Active Cycle, Active Tasks, Backlog, Completed This Cycle, and Update Log to one coherent story state — _Requirements: AC-001, AC-002, AC-005_
  - [x] 2.2 Preserve DEV-029 manual-deferred PR-path row unless completion evidence exists — _Requirements: AC-006_
  - [x] 2.3 Update `CHANGELOG.md` and `docs/AgToosa_Changelog.md` `[Unreleased]` or release block to match the selected ship path — _Requirements: AC-004_
- [x] **3.** Align version and release pins if shipping
  - [x] 3.1 Update `agtoosa.sh`, `agtoosa.ps1`, `README.md`, `Formula/agtoosa.rb`, and bats version pins to `5.2.4` — _Requirements: AC-003_
  - [x] 3.2 Confirm no release pin advances without a matching changelog block and Master-Plan update — _Requirements: AC-003, AC-004_
- [x] **4.** Add regression coverage
  - [x] 4.1 Add DEV-034 bats assertions for active/backlog/completed-cycle consistency — _Requirements: AC-001, AC-002, AC-005, AC-007_
  - [x] 4.2 Add DEV-034 bats assertions for changelog/version parity surfaces not already covered — _Requirements: AC-003, AC-004, AC-007_
  - [x] 4.3 Record focused validation evidence in `docs/AgToosa_TestPlan-DEV-034.md` — _Requirements: AC-007, AC-008_
- [x] **5.** Review and handoff
  - [x] 5.1 Create `docs/archived/review-DEV-033.md` for DEV-033 ship closure — _Requirements: AC-002, AC-008_
  - [x] 5.2 Next action: `/agtoosa-review` DEV-034, then `/agtoosa-ship` DEV-034 as v5.2.5 — _Requirements: AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.2
**Wave 2 (sequential after Wave 1):** 1.2, 2.1, 2.3
**Wave 3 (sequential after Wave 2):** 3.1, 3.2, 4.1, 4.2
**Wave 4 (sequential after Wave 3):** 4.3, 5.1, 5.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-034.md`
AC coverage: 8 ACs mapped to 6 test IDs
Smoke set: 4 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-06-06 (user requested implementation of the next-spec plan)
