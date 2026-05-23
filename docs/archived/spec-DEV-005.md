# Spec: DEV-005 — v4.2.0 release hygiene

> **Story ID:** DEV-005
> **Epic:** DEV-004 — Testing & QA Harness
> **Status:** 🏁 Shipped
> **Estimate:** XS
> **Spec created:** 2026-05-22

## Context

Release 4.2.0 shipped manual-task workflow support across four template docs (`SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md`) but left two maintainer-repo gaps open: no bats parity tests for that behavior (unlike the D1–D3 block added in 4.1.0), and two forward-looking features still listed under `## [4.1.0] → ### Coming next (4.2.0)` instead of `## [Unreleased]`. Dream reports (2026-05-14 through 2026-05-20) track these as Priority 2 and Priority 3. Version parity and README pins were fixed separately; this story closes the remaining release-debt items only.

**Smart Interview (skipped — answers inferred from codebase + dream reports):**

| Question | Finding |
|----------|---------|
| Status quo | `tests/agtoosa.bats` ends at D3/maintainer parity tests (line ~1269); no `M1`–`M4` tests. CHANGELOG still promises unshipped Status Guide and `/agtoosa-help next` inside the released 4.1.0 section. |
| Narrowest scope | Append four grep-based bats tests (template content already exists) + move two CHANGELOG bullets to `[Unreleased]`. No generator or template content changes. |
| Urgency | Maintainer CI coverage gap; changelog misrepresents shipped vs planned scope. |
| Failure modes | Tests grep wrong strings → false green; CHANGELOG move drops history → mitigated by preserving bullet text verbatim. |
| Security surface | None — read-only test assertions and doc edits only. |

## 1. Requirements

### 1.1 User Stories

**As a** AgToosa maintainer, **I want** bats coverage and accurate CHANGELOG backlog for v4.2.0 manual-task semantics **so that** CI guards template parity and readers see what shipped vs what is planned.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `bats tests/agtoosa.bats -f "M1"` runs THE SYSTEM SHALL pass asserting `[manual]`, `[manual-deferred`, and `Awaiting Manual` appear in `template/Docs/SPEC-FORMAT.md` | Must |
| AC-002 | WHEN `bats tests/agtoosa.bats -f "M2"` runs THE SYSTEM SHALL pass asserting `Manual Task Detection` and defer prompt wording appear in `template/Docs/AgToosa_Build.md` | Must |
| AC-003 | WHEN `bats tests/agtoosa.bats -f "M3"` runs THE SYSTEM SHALL pass asserting `manual-deferred` and `Awaiting Manual` appear in `template/Docs/AgToosa_Status.md` | Must |
| AC-004 | WHEN `bats tests/agtoosa.bats -f "M4"` runs THE SYSTEM SHALL pass asserting `Manual / Deferred` appears in `template/Docs/Master-Plan.md` | Must |
| AC-005 | WHEN a reader opens `CHANGELOG.md` THE SYSTEM SHALL list the Status Guide sub-agent and `/agtoosa-help next` items under `## [Unreleased]` only | Must |
| AC-006 | WHEN a reader opens `CHANGELOG.md` THE SYSTEM SHALL NOT contain a `### Coming next (4.2.0)` subsection under `## [4.1.0]` | Should |
| AC-007 | WHEN the full bats suite runs after changes THE SYSTEM SHALL report zero failures for existing D1–D3 and version parity tests | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | M1 greps stale/wrong path → test passes while template regresses |
| AC-002 | M2 matches incidental substring in unrelated section |
| AC-005 | Items duplicated in both 4.1.0 and Unreleased |
| AC-007 | New tests break shellcheck or bats syntax |

### 1.3 Out of Scope

- Implementing the Status Guide sub-agent or `/agtoosa-help next` (backlog only — moved to `[Unreleased]`)
- Changing v4.2.0 template manual-task content (already shipped)
- Bumping `AGTOOSA_VERSION` or cutting a new release tag
- README / install snippet edits (already at 4.2.0)

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  - (none — tests appended to existing file)

Files to change:
  - tests/agtoosa.bats              — append M1–M4 test block after line ~1269 (after maintainer parity test)
  - CHANGELOG.md                    — move two bullets; remove ### Coming next (4.2.0) subsection
  - docs/Master-Plan.md           — enrollment + Active Tasks (this spec workflow)
  - docs/archived/spec-DEV-005.md — this file

Key interfaces:
  - @test "M1: …" through @test "M4: …" — mirror D1–D3 grep patterns against TEMPLATE_DIR
```

### 2.2 Data Flow

1. `/agtoosa-spec` writes this spec and enrolls DEV-005 in Active Cycle.
2. `/agtoosa-build` appends M1–M4 tests using dream-report-ready assertions.
3. `/agtoosa-build` edits CHANGELOG: cut two bullets from 4.1.0 "Coming next", paste under `[Unreleased]`, delete empty subsection.
4. `/agtoosa-build` runs `bats tests/agtoosa.bats -f "M[1-4]"` then targeted full-suite smoke.
5. `/agtoosa-build` ticks checkboxes and updates Tasks Done counter in Master-Plan.
6. `/agtoosa-ship` archives spec and closes story when review passes.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Tests assert wrong template path | Tampering | Use `$TEMPLATE_DIR/Docs/...` same as D1–D3 |
| CHANGELOG edit loses planned work | Repudiation | Move bullets verbatim; do not delete feature descriptions |
| False confidence from grep-only tests | Information disclosure | Pair with full bats run (AC-007) |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : tests/agtoosa.bats, CHANGELOG.md, docs/Master-Plan.md, docs/archived/spec-DEV-005.md
Directories in scope: tests/, docs/
Out of scope        : template/Docs/* content, agtoosa.sh, agtoosa.ps1, lib/*, README.md, platform variants
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Bats: Add M1–M4 manual-task parity tests
  - [x] 1.1 Add M1 test — SPEC-FORMAT manual lifecycle strings — _Requirements: AC-001_
  - [x] 1.2 Add M2 test — AgToosa_Build Manual Task Detection gate — _Requirements: AC-002_
  - [x] 1.3 Add M3 test — AgToosa_Status manual-deferred exemption — _Requirements: AC-003_
  - [x] 1.4 Add M4 test — Master-Plan Manual / Deferred section — _Requirements: AC-004_
- [x] **2.** Docs: CHANGELOG backlog cleanup
  - [x] 2.1 Move Status Guide + `/agtoosa-help next` bullets to `## [Unreleased]` — _Requirements: AC-005_
  - [x] 2.2 Remove empty `### Coming next (4.2.0)` from `## [4.1.0]` — _Requirements: AC-006_
- [x] **3.** Validation
  - [x] 3.1 Run `bats tests/agtoosa.bats -f "M[1-4]"` — all green — _Requirements: AC-001, AC-002, AC-003, AC-004_
  - [x] 3.2 Run version + D1–D3 bats subset — no regressions — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 1.4, 2.1, 2.2
**Wave 2 (sequential after Wave 1):** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-v42-release-hygiene.md`
AC coverage: 7 ACs mapped to 7 test IDs
Smoke set: 5 tests tagged @smoke (T-001 through T-005)

## ✅ Spec Approved

Approved: 2026-05-22 12:00
