# Test Plan: DEV-045 — Work Package Wave DAG

> **Spec:** `docs/archived/spec-DEV-045.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DAG-001|DAG-002|DAG-003|DAG-005|DAG-007"`
> **Status:** 🟩 Done (build evidence recorded)
> **Prerequisite gate:** DEV-055 shipped v5.3.7 — cleared 2026-07-11
> **Execution state:** RED then GREEN captured 2026-07-11 during Maintainer Dogfood build

## Coverage Target

The build proves one normative Work Package schema across the maintainer and template copies, safe dependency/ownership rules, and consistent Spec/Build/Handoff/Import consumption. The tests prove documented and CI-visible contracts; they do not prove a runtime scheduler or guaranteed agent isolation.

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | DAG-001 | Docs contract | Both SPEC-FORMAT copies define all eight Work Package columns and the normative example | `@smoke` GREEN |
| AC-002 | DAG-002 | Docs/Integration | Spec task derivation emits one package per executable sub-task and requires ownership plus verification for parallel packages | `@smoke` GREEN |
| AC-003 | DAG-003 | Bats/Negative | Disjoint same-wave ownership is accepted; overlapping ownership requires an explicit sequential fallback | `@smoke` GREEN |
| AC-004 | DAG-004 | Bats/Negative | Dependencies resolve to existing earlier-wave packages; invalid, circular, and same/later-wave references are rejected by the contract | GREEN |
| AC-005 | DAG-005 | Docs/Integration | Handoff's selected-wave pack contains all required Work Package fields | `@smoke` GREEN |
| AC-006 | DAG-006 | Docs/Integration | Import compares changed files to ownership, reports gaps, and presents declared merge order before status mutation | GREEN |
| AC-007 | DAG-001, DAG-006 | Docs contract | Claim Boundary uses generator-enforced, CI-enforced, agent-instructed, manual, and roadmap without runtime-enforcement claims | GREEN |
| AC-008 | DAG-007 | Regression/Evidence | DEV-045 wiring is present in both path variants and the dogfood DAG is recorded with focused GREEN output | `@smoke` GREEN |

### Planned Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| DAG-001 | `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md` | Eight columns, package ID convention, and Claim Boundary terms are present in both copies | A missing/renamed column or runtime-scheduler overclaim fails | GREEN |
| DAG-002 | Spec workflow copies | Every executable sub-task maps to one package; parallel rows have `owned_files` and `verification` | A parallel package with either field empty fails | GREEN |
| DAG-003 | Build schema fixtures | Disjoint path sets may stay in one wave | Duplicate explicit paths and intersecting directory wildcards require sequential fallback | GREEN |
| DAG-004 | DAG fixtures | Earlier-wave dependencies and deterministic merge order pass | Unknown, self, circular, same-wave, or later-wave dependencies fail | GREEN |
| DAG-005 | Handoff workflow copies | Selected-wave export contains package ID, ownership, inputs/outputs, merge order, and verification | Exporting packages from an unselected wave or omitting a field fails | GREEN |
| DAG-006 | Import workflow copies | Out-of-scope paths are gaps and accepted packages are presented in merge order | Import evidence cannot directly mark Master-Plan tasks complete | GREEN |
| DAG-007 | Cross-surface regression + test plan | Dual-path wiring and two-parallel/one-dependent dogfood evidence are present | Missing dogfood/evidence placeholders or DEV-055 file edits fail | GREEN |

## Smoke Set

- `DAG-001` — canonical schema and claim boundary
- `DAG-002` — task-to-package generation
- `DAG-003` — overlap safety and fallback
- `DAG-005` — selected-wave handoff contract
- `DAG-007` — end-to-end wiring and dogfood evidence

## Dogfood DAG (two-parallel / one-dependent) — executed

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification | State |
|------------|------|------------|-------------|--------|---------|-------------|--------------|-------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` | Approved DEV-045 spec | DEV-045 RED contract tests | 1 | `bats tests/agtoosa.bats -f "DEV-045"` | GREEN — RED authored then suite greened |
| PKG-1.2 | 1 | — | `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md` | Approved DEV-045 spec | Normative Work Package schema | 1 | `bats tests/agtoosa.bats -f "DAG-001"` | GREEN — dual-path `### 3.4` shipped |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | Spec/Build/Handoff/Import/Quickref/Trust copies | Wave 1 outputs | Integrated DAG workflow contract | 2 | `bats tests/agtoosa.bats -f "DEV-045"` | GREEN — workflow wiring + Claim Boundary |

Integration result: Wave 1 packages completed in parallel (disjoint ownership); Wave 2 depended on both; focused `DEV-045` bats exit 0 after Task 4.1 evidence write.

## TDD Evidence

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Expected RED: newly authored `DAG-001`–`DAG-007` assertions fail against the pre-implementation tree
- Observed exit code: `1`
- Failure excerpt:
  ```
  ok 1 DEV-045 CW-008: Work Package Wave DAG backlog artifacts exist
  not ok 2 DEV-045 DAG-001: ... `grep -q "### 3.4 Work Package DAG" "$f"' failed
  not ok 3 DEV-045 DAG-002: ... `grep -q "Work Package" "$f"' failed
  not ok 4–8 DAG-003–DAG-007 failed (missing Work Package wiring)
  EXIT:1
  ```

**GREEN evidence — Task 1.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Expected GREEN: all focused DEV-045 tests pass after Tasks 1.2–4.1
- Observed exit code: `0`
- Passing excerpt: `ok 1–8 DEV-045 CW-008 + DAG-001–DAG-007` (recorded after Task 4.1)

### Task 1.2 — Normative schema

**RED evidence — Task 1.2**

- Status: **RED captured** (covered by Task 1.1 DAG-001/DAG-004 failures before schema)
- Command: `bats tests/agtoosa.bats -f "DAG-001|DAG-004"`
- Observed exit code: `1`
- Failure excerpt: `grep -q "### 3.4 Work Package DAG"` / missing `depends_on` in Spec/Build

**GREEN evidence — Task 1.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DAG-001|DAG-004"`
- Observed exit code: `0`
- Passing excerpt: both SPEC-FORMAT copies define eight-column `### 3.4 Work Package DAG` + earlier-wave dependency rules

### Task 2.1 — Package derivation

**RED evidence — Task 2.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DAG-002|DAG-003|DAG-004"`
- Observed exit code: `1`
- Failure excerpt: Spec lacked Work Package derivation language

**GREEN evidence — Task 2.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DAG-002|DAG-003|DAG-004"`
- Observed exit code: `0`
- Passing excerpt: Spec emits one package per sub-task; overlap → sequential fallback; earlier-wave `depends_on`

### Task 2.2 — Build consumption

**RED evidence — Task 2.2**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DAG-003|DAG-004"`
- Observed exit code: `1`
- Failure excerpt: Build lacked ownership / earlier-wave fan-out gate

**GREEN evidence — Task 2.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DAG-003|DAG-004"`
- Observed exit code: `0`
- Passing excerpt: Build documents Work Package fan-out gate + sequential fallback + Claim Boundary

### Task 3.1 — Handoff package export

**RED evidence — Task 3.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DAG-005"`
- Observed exit code: `1`
- Failure excerpt: `grep -q "Work Packages" "$f"' failed`

**GREEN evidence — Task 3.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DAG-005"`
- Observed exit code: `0`
- Passing excerpt: both Handoff copies export §8 Work Packages for the selected wave

### Task 3.2 — Import ownership gate

**RED evidence — Task 3.2**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DAG-006"`
- Observed exit code: `1`
- Failure excerpt: Import lacked ownership-gap / merge_order language

**GREEN evidence — Task 3.2**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DAG-006"`
- Observed exit code: `0`
- Passing excerpt: Import reports ownership gaps, preserves source of truth, orders by `merge_order`

### Task 4.1 — Closure and dogfood

**RED evidence — Task 4.1**

- Status: **RED captured**
- Command: `bats tests/agtoosa.bats -f "DAG-007"`
- Observed exit code: `1`
- Failure excerpt: missing `Observed exit code: 0` / incomplete dogfood evidence placeholders

**GREEN evidence — Task 4.1**

- Status: **GREEN**
- Command: `bats tests/agtoosa.bats -f "DEV-045"`
- Observed exit code: `0`
- Passing excerpt: CW-008 + DAG-001–DAG-007 all `ok`; dogfood table Status GREEN; Claim Boundary honest (no runtime scheduler overclaim)

## Exact Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-045"
bats tests/agtoosa.bats -f "DAG-"
bats tests/agtoosa.bats -f "DAG-001|DAG-002|DAG-003|DAG-005|DAG-007"
bash agtoosa.sh --verify .
bash docs/agtoosa-verify.sh --strict
bats tests/agtoosa.bats
git diff --check
```
