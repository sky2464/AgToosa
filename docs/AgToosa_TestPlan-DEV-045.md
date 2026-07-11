# Test Plan: DEV-045 — Work Package Wave DAG

> **Spec:** `docs/archived/spec-DEV-045.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DAG-001|DAG-002|DAG-003|DAG-005|DAG-007"`
> **Status:** ⬜ Backlog
> **Prerequisite gate:** DEV-055 must ship before DEV-045 enrollment
> **Execution state:** Planned only — no DEV-045 validation command has been executed

## Coverage Target

The future build must prove one normative Work Package schema across the maintainer and template copies, safe dependency/ownership rules, and consistent Spec/Build/Handoff/Import consumption. The tests prove documented and CI-visible contracts; they do not prove a runtime scheduler or guaranteed agent isolation.

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | DAG-001 | Docs contract | Both SPEC-FORMAT copies define all eight Work Package columns and the normative example | planned `@smoke` |
| AC-002 | DAG-002 | Docs/Integration | Spec task derivation emits one package per executable sub-task and requires ownership plus verification for parallel packages | planned `@smoke` |
| AC-003 | DAG-003 | Bats/Negative | Disjoint same-wave ownership is accepted; overlapping ownership requires an explicit sequential fallback | planned `@smoke` |
| AC-004 | DAG-004 | Bats/Negative | Dependencies resolve to existing earlier-wave packages; invalid, circular, and same/later-wave references are rejected by the contract | planned |
| AC-005 | DAG-005 | Docs/Integration | Handoff's selected-wave pack contains all required Work Package fields | planned `@smoke` |
| AC-006 | DAG-006 | Docs/Integration | Import compares changed files to ownership, reports gaps, and presents declared merge order before status mutation | planned |
| AC-007 | DAG-001, DAG-006 | Docs contract | Claim Boundary uses generator-enforced, CI-enforced, agent-instructed, manual, and roadmap without runtime-enforcement claims | planned |
| AC-008 | DAG-007 | Regression/Evidence | DEV-045 wiring is present in both path variants and the dogfood DAG is recorded with focused GREEN output | planned `@smoke` |

### Planned Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| DAG-001 | `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md` | Eight columns, package ID convention, and Claim Boundary terms are present in both copies | A missing/renamed column or runtime-scheduler claim fails | planned — not authored or run |
| DAG-002 | Spec workflow copies | Every executable sub-task maps to one package; parallel rows have `owned_files` and `verification` | A parallel package with either field empty fails | planned — not authored or run |
| DAG-003 | Build schema fixtures | Disjoint path sets may stay in one wave | Duplicate explicit paths and intersecting directory wildcards require sequential fallback | planned — not authored or run |
| DAG-004 | DAG fixtures | Earlier-wave dependencies and deterministic merge order pass | Unknown, self, circular, same-wave, or later-wave dependencies fail | planned — not authored or run |
| DAG-005 | Handoff workflow copies | Selected-wave export contains package ID, ownership, inputs/outputs, merge order, and verification | Exporting packages from an unselected wave or omitting a field fails | planned — not authored or run |
| DAG-006 | Import workflow copies | Out-of-scope paths are gaps and accepted packages are presented in merge order | Import evidence cannot directly mark Master-Plan tasks complete | planned — not authored or run |
| DAG-007 | Cross-surface regression + test plan | Dual-path wiring and two-parallel/one-dependent dogfood evidence are present | Missing dogfood/evidence placeholders or DEV-055 file edits fail | planned — not authored or run |

## Smoke Set

- `DAG-001` — canonical schema and claim boundary
- `DAG-002` — task-to-package generation
- `DAG-003` — overlap safety and fallback
- `DAG-005` — selected-wave handoff contract
- `DAG-007` — end-to-end wiring and dogfood evidence

Smoke is a future focused subset, not evidence that exists today.

## Planned Dogfood DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification | State |
|------------|------|------------|-------------|--------|---------|-------------|--------------|-------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` | Approved DEV-045 spec | DEV-045 RED contract tests | 1 | `bats tests/agtoosa.bats -f "DEV-045"` | planned — not executed |
| PKG-1.2 | 1 | — | `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md` | Approved DEV-045 spec | Normative Work Package schema | 1 | `bats tests/agtoosa.bats -f "DAG-001"` | planned — not executed |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | Spec/Build/Handoff/Import workflow copies | Wave 1 outputs | Integrated DAG workflow contract | 2 | `bats tests/agtoosa.bats -f "DEV-045"` | planned — not executed |

The future evidence must replace each planned state with the actual changed-file set, command output, and integration result.

## TDD Evidence Placeholders

Every block below is deliberately unexecuted. During `/agtoosa-build`, replace bracketed fields with observed commands, nonzero/zero exit codes, and truthful excerpts; do not infer evidence from documentation presence.

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Expected RED: newly authored `DAG-001`–`DAG-007` assertions fail against the pre-implementation tree
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Expected GREEN: all focused DEV-045 tests pass after Tasks 1.2–4.1
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 1.2 — Normative schema

**RED evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-001|DAG-004"`
- Expected RED: schema columns and dependency rules are absent or incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-001|DAG-004"`
- Expected GREEN: dual-path schema and ordering rules satisfy both tests
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.1 — Package derivation

**RED evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-002|DAG-003|DAG-004"`
- Expected RED: Spec does not yet derive complete, safe package rows
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-002|DAG-003|DAG-004"`
- Expected GREEN: derivation, overlap fallback, and dependency ordering pass
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.2 — Build consumption

**RED evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-003|DAG-004"`
- Expected RED: Build does not yet check ownership and dependency readiness before fan-out
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-003|DAG-004"`
- Expected GREEN: Build documents the required gate and sequential fallback
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 3.1 — Handoff package export

**RED evidence — Task 3.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-005"`
- Expected RED: Handoff lacks the selected-wave Work Packages section
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 3.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-005"`
- Expected GREEN: both Handoff copies export the complete selected-wave fields
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 3.2 — Import ownership gate

**RED evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-006"`
- Expected RED: Import lacks ownership-gap and merge-order reporting
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-006"`
- Expected GREEN: Import reports gaps, preserves the source of truth, and orders accepted packages
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 4.1 — Closure and dogfood

**RED evidence — Task 4.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DAG-007"`
- Expected RED: cross-surface wiring or dogfood evidence is incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run]`

**GREEN evidence — Task 4.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Expected GREEN: all focused tests pass and actual dogfood evidence replaces placeholders
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

## Exact Future Validation Commands

Do not run these while DEV-045 is Backlog or DEV-055 is active. Run them after DEV-045 is enrolled, approved, implemented, and its evidence placeholders have been populated.

```bash
bats tests/agtoosa.bats -f "DEV-045"
bats tests/agtoosa.bats -f "DAG-"
bats tests/agtoosa.bats -f "DAG-001|DAG-002|DAG-003|DAG-005|DAG-007"
bash agtoosa.sh --verify .
bash docs/agtoosa-verify.sh --strict
bats tests/agtoosa.bats
git diff --check
```
