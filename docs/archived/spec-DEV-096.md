# Spec: DEV-096 — Chore: Pack Validation CI

> **Story ID:** DEV-096
> **Type:** Chore
> **Epic:** DEV-003 — Community Template Registry
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Priority:** P1
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-080 (shipped three-pack pilot and OPP tests)
> **Blocks:** DEV-095 (official pack expansion)

## Context

DEV-080 proved three official packs with OPP fixture tests, but pack manifests, fixture archives, and recorded SHA-256 values can drift silently after content edits. Rev4 requires pack validation CI before expanding to five packs. This story adds `pack-validate.yml`, detects SHA drift between pack sources and fixtures, enforces fixture parity with live pack trees, and wires focused `bats -f OPP` coverage as a required gate.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Fail CI deterministically when official pack manifests, fixture archives, or SHA metadata drift from canonical pack sources. |
| User outcome | Maintainers discover pack integrity drift before release instead of after users install stale or mismatched fixtures. |
| Success condition | `pack-validate.yml` runs on relevant changes, validates manifests, compares fixture SHA parity, and executes focused OPP bats; non-zero exit reports actionable file-level diagnostics. |
| Proof / evidence | PV tests mutate isolated fixtures to prove SHA drift, manifest failure, and fixture-tree mismatch fail; unchanged pilots pass after repair. |
| Non-goals | External registry availability checks, automatic pack rewrites, or validating community packs beyond the official pilot set. |
| Assumptions | DEV-053 `schema_version` 1.0 remains the catalog contract; official pilot roots live under `packs/official-*`. |
| Risks | Over-broad hashing flags unrelated files; workflow runs only on manual dispatch; SHA comparison is brittle across platforms. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** release maintainer, **I want** pack SHA drift to fail CI **so that** fixture archives stay synchronized with pack sources.

**As a** pack author, **I want** manifest validation in CI **so that** catalog contract violations are caught before review.

**As an** AgToosa maintainer, **I want** focused OPP bats in the pack gate **so that** DEV-095 expansion starts from a green baseline.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN pack sources or fixtures change THE SYSTEM SHALL run `pack-validate.yml` on pull requests that touch `packs/official-*`, `tests/fixtures/registry-packs/official-*`, or pack validation scripts | Must |
| AC-002 | WHEN pack validation runs THE SYSTEM SHALL validate each official pilot manifest with `bash agtoosa.sh --catalog validate` and exit non-zero on schema failure | Must |
| AC-003 | WHEN fixture archives exist THE SYSTEM SHALL compare recorded SHA-256 metadata against the canonical pack source tree and fail when drift is detected without an intentional metadata update | Must |
| AC-004 | WHEN fixture trees are inspected THE SYSTEM SHALL require structural parity with their corresponding pack source roots for allowlisted paths and report missing or extra fixture files | Must |
| AC-005 | WHEN pack validation completes THE SYSTEM SHALL execute `bats tests/agtoosa.bats -f "OPP"` and propagate its exit code | Must |
| AC-006 | WHEN a validation check fails THE SYSTEM SHALL exit non-zero and report the pack name, file path, observed value, and expected value or missing target | Must |
| AC-007 | WHILE private validation mode is selected THE SYSTEM SHALL perform no network request beyond what OPP tests already require for isolated installs | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Pack edits merge without CI because path filters are too narrow. |
| FM-002 | AC-002 | A broken manifest ships because catalog validate is not invoked. |
| FM-003 | AC-003 | Fixture SHA metadata updates but archive bytes do not, or vice versa. |
| FM-004 | AC-004 | Fixture tree omits a newly added pack file. |
| FM-005 | AC-005 | Workflow passes while OPP bats are red. |
| FM-006 | AC-006 | Failure output says only "validation failed" without pack/file context. |
| FM-007 | AC-007 | CI becomes flaky due to unexpected registry network calls. |

### 1.5 Out of Scope

- Validating arbitrary community packs not in the official pilot set
- Automatic fixture regeneration or pack content rewrites
- External registry submission or approval
- Publishing packs to a remote registry in CI
- Replacing full `bats tests/agtoosa.bats` with pack-only runs in main CI

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Manifest schema validation | deterministic CI check |
| Fixture SHA parity | deterministic CI check |
| OPP focused bats | CI-enforced when workflow runs |
| Pack content correctness beyond schema | manual content review |
| External registry state | manual / external |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `.github/workflows/pack-validate.yml` — PR/path-filtered workflow invoking manifest validate, SHA parity, fixture parity, and OPP bats
- `scripts/validate-official-packs.sh` (or equivalent) — deterministic pack-source vs fixture comparison helper
- `tests/agtoosa.bats` — PV contract tests for drift detection and actionable failures
- `docs/official-pack-pilot-checklist.md` — link pack CI gate and repair steps

No change to registry install semantics.

### 2.2 Data Flow

1. A pull request touches official pack sources, fixtures, or validation scripts.
2. `pack-validate.yml` checks out the repo and runs the validation helper.
3. For each `packs/official-*` pilot, validate manifest via `--catalog validate`.
4. Compare fixture archive SHA-256 and tree parity against pack source.
5. Run `bats tests/agtoosa.bats -f "OPP"`.
6. Accumulate failures with pack/file diagnostics; exit non-zero on any failure.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Stale fixture passes as current pack content | Tampering | SHA parity and tree comparison before OPP install tests. |
| Validation script executes untrusted pack shell | Elevation of Privilege | Validate manifests and file metadata only; OPP uses existing isolated install path. |
| Workflow omits failure details | Repudiation | Actionable file-level diagnostics on non-zero exit. |
| Network registry fetch in validation | Denial of Service | Use local fixtures and `AGTOOSA_REGISTRY_CACHE_DIR`; no external publish step. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `.github/workflows/pack-validate.yml`, validation helper script, PV bats, checklist doc update
Directories in scope: `.github/workflows/`, `scripts/`, `packs/official-*`, `tests/fixtures/registry-packs/official-*`, `tests/`
Out of scope        : community pack validation at scale, automatic fixture rewrite, external registry CI

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Fixture-based RED coverage
  - [ ] 1.1 Add SHA drift and manifest failure fixtures — _Requirements: AC-002, AC-003, AC-006_
  - [ ] 1.2 Add fixture parity mismatch and actionable-error fixtures — _Requirements: AC-004, AC-006_
- [ ] **2.** Validation helper and workflow
  - [ ] 2.1 Implement deterministic SHA and tree parity checks — _Requirements: AC-003, AC-004, AC-006_
  - [ ] 2.2 Add `pack-validate.yml` with path filters and OPP bats step — _Requirements: AC-001, AC-005, AC-007_
- [ ] **3.** Evidence
  - [ ] 3.1 Record RED/GREEN PV evidence and verify green OPP baseline — _Requirements: AC-001–AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-096.md`
AC coverage: 7 ACs mapped to 8 PV test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-096)
