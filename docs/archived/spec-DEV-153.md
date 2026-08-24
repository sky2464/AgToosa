# Spec: DEV-153 — Bats Tiering & Smoke-Set Extraction

> **Story ID:** DEV-153
> **Epic:** DEV-001 — Core Generator Engine / DEV-004 — Test Modernization
> **Status:** 🟦 Todo
> **Estimate:** M
> **Clarity:** `ready`
> **Spec created:** 2026-08-23
> **Extends:** DEV-152 (Bats Cleanup); foundation for parallel test execution in CI

> **Milestone:** v5.3.63 (active)

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Current state | 228 tests tagged @smoke (over-broad); no @regression tier; sequential execution only |
| Smoke-set scope | 45–75 tests (&lt;2s per test) are true smoke candidates; remaining 1164 tests → regression tiers |
| Feature lanes | 5 independent parallelizable groups (Flag/Bootstrap, Copy/Install, Platform, Issues, Template) + 1 sequential (Ship Regression Waves) |
| Parallelization gain | ~15× speedup on smoke (120–180s baseline → 8–12s 4-way parallel) |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Smoke-set approach? | B — Smoke-set first + categorize by feature lane; trim @smoke from 228 → 45–75 tests |
| Q2 | Target release? | A — v5.3.63, same cycle as DEV-150/151/DEV-152 |

#### Documented assumptions

- Current 228 @smoke tests include slow regression waves (v5.3.10–v5.3.62) that belong in @regression tier.
- Fast tests (&lt;1s): GIP-001–011, GIS, F15-001/003/006, flags, bootstrap, copy/install = ~45 tests.
- High-value compliance (&lt;2s): OPP, MET, VCA, platform schema = ~30 tests.
- Feature lanes are independent (no cross-lane state sharing); safe for 4-way parallelization.
- CI jobs can be staged: PR gate runs `bats --filter @smoke` (~8–12s); main/release runs full suite or split @regression.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Extract a fast smoke-set (~8–12s) and create a regression tier for ship waves, enabling parallel test execution and faster PR feedback |
| User outcome | PR feedback cycle reduced from 30–40 min to ~8–12 min (smoke-set); CI resources freed; maintainers can parallelize by feature lane |
| Success condition | Smoke-set trimmed to 45–75 tests marked @smoke; @regression tier applied to 103+ tests; CI jobs updated; AC-001–AC-005 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-153.md`; bats `--filter @smoke` runs &lt;15s; bats `--filter @regression` isolated; CI job templates verified |
| Non-goals | Change test logic or assertions; rewrite slow tests for speed; split bats into multiple files; add new test coverage |
| Assumptions | v5.3.53 is current; DEV-152 cleanup completes first (clean version-pin state); bats supports `--filter` by tag (native feature) |
| Risks | Over-aggressive smoke-set trim misses critical checks (mitigated by AC-001 business logic coverage); @regression tests dominate main/release runtime (~15–30s for 103 tests, sequential) |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** PR CI to run a ~8–12 second smoke-set **so that** feedback is faster and developer iteration is unblocked.

**As a** maintainer, **I want** regression waves isolated from smoke-set **so that** I can parallelize smoke tests and sequence regression tests independently.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN bats smoke-set is defined THE SYSTEM SHALL include 45–75 tests covering core bootstrap, copy/install, platform wiring, issues sync, and key compliance gates (@smoke tag) | Must |
| AC-002 | WHEN @regression marker is applied THE SYSTEM SHALL tag 103+ ship regression wave tests (v5.3.10–v5.3.62 SR-001–003) separating them from smoke path | Must |
| AC-003 | WHEN `bats --filter @smoke` runs THE SYSTEM SHALL complete in &lt;15 seconds on a 4-core machine (target: 8–12s) | Must |
| AC-004 | WHEN pull request triggers CI THE SYSTEM SHALL run smoke-set only via `bats --filter @smoke` (no @regression tests); when main branch or release tag triggers CI THE SYSTEM SHALL run full suite or parallel @regression job | Must |
| AC-005 | WHEN `docs/AgToosa_TestPlan.md` is read THE SYSTEM SHALL explain smoke-set scope, @regression tier, feature lanes, and parallel execution guidance | Should |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| Smoke-set scope | test-coverage-enforced | AC-001 defines test count and categories |
| Feature lanes | CI-architecture-enforced | 5 parallelizable groups mapped; sequencing for regression waves |
| @regression marker | bats-semantic-enforced | Available via `bats --filter @regression`; applies to 103+ tests |
| CI jobs | provider-enforced | GitHub Actions `.github/workflows/test.yml` implements parallelization |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `tests/agtoosa.bats` (@smoke tags) | Trim from 228 → 75 tests; keep fast tests (&lt;1s) + high-value compliance (&lt;2s); remove slow SR waves |
| `tests/agtoosa.bats` (@regression tags) | Apply to 103+ ship regression waves (v5.3.10–v5.3.62 SR-001–003); isolate from smoke path |
| `.github/workflows/test.yml` | PR job: `bats --filter @smoke`; main/release job: `bats --filter @regression` + remaining (or full suite with 4-way parallel) |
| `docs/AgToosa_TestPlan.md` | Add "Smoke-Set & Regression Tiers" section; explain feature lanes, parallelization strategy, and test author guidance |

### 2.2 Smoke-Set Definition

**Target:** 45–75 tests, &lt;2s per test, ~8–12s wall time with 4-way parallelism

| Category | Count | Tests | Speed |
|----------|-------|-------|-------|
| **Flags & Bootstrap** | 5 | `--version`, `--help`, bootstrap variants | &lt;0.1s |
| **Copy/Install** | 10 | Core docs, Docs/, template install validation | &lt;1s total |
| **Platform Wiring** | 8 | DAG schema, WT, F15 core samples | &lt;1.5s |
| **Issues/Tracker** | 10 | GIP-001–002, GIP-010, GIP-003, GIS fast path | &lt;0.5s |
| **Feature Proof** | 12 | F15-001/003/006, PRF-001/003/006, auth gates | &lt;1s |
| **Compliance Gates** | 15 | OPP-001/003, MET-001/003, VCA-001/003, HSV samples | &lt;2s |
| **Template Wiring** | 8 | CW sample fast-path tests | &lt;1.5s |
| **Upgrade/Version** | 7 | UPG core samples, version-guard sanity | &lt;1s |

**Total:** ~75 tests, &lt;12s sequential (8–10s with parallelism)

### 2.3 Feature Lanes for Parallel Execution

**Parallelizable groups (independent state):**

1. **Flag/Bootstrap Lane** (~5 tests, &lt;2s)
   - Tests: `--version`, `--help`, bootstrap entry points
   - Parallelizable: Yes

2. **Copy/Install Lane** (~15 tests, ~5s)
   - Tests: Core install, Docs/, template sync
   - Parallelizable: Yes (isolated temp projects)

3. **Platform Lane** (~20 tests, ~3–5s)
   - Tests: DAG-001–007, WT-001–006, F15 schema, CI health
   - Parallelizable: Yes (read-only fixture tests)

4. **Issues/Tracker Lane** (~23 tests, ~4–8s)
   - Tests: GIS-001–012, GIP-001–011 (mock gh API)
   - Parallelizable: Partial (mock isolation)

5. **Template Lane** (~45 tests, ~6–10s)
   - Tests: CW-001–025 competitive spec waves
   - Parallelizable: Yes (file comparison only)

6. **Regression Waves (Sequential)** (~103 tests, 15–30s)
   - Tests: v5.3.10–v5.3.62 SR-001–003 per wave
   - Parallelizable: No (version dependency)
   - **Recommendation:** Run in separate CI job or after smoke passes

### 2.4 Build Scope

**In scope:**
- `tests/agtoosa.bats` smoke-set re-tagging (remove @smoke from SR waves; keep fast tests)
- `tests/agtoosa.bats` @regression tagging (103+ ship regression tests)
- `.github/workflows/test.yml` updates (PR: smoke only; main/release: full or split)
- `docs/AgToosa_TestPlan.md` update (smoke-set scope, feature lanes, parallelization guide)

**Out of scope:**
- Change test logic or add new tests
- Rewrite slow tests
- Implement agent-based test parallelization (bats `--filter` is sufficient)
- Modify `lib/` or `agtoosa.sh` test infrastructure

### 2.5 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Over-aggressive smoke trim misses critical checks | Tampering | AC-001 defines coverage; business logic review before tagging |
| PR smoke-gate passes but main regression fails | Integrity | @regression tests run on main/release; `--filter` semantics verified |
| Feature lane cross-contamination | Information disclosure | Smoke-set test independence verified; no state sharing between lanes |

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Analyze current @smoke tags and categorize
  - [ ] 1.1 Grep all `@smoke`-tagged tests; categorize by speed (&lt;1s, 1–2s, &gt;2s) — _AC-001_
  - [ ] 1.2 Identify SR waves in @smoke (v5.3.10–v5.3.62) for removal — _AC-001_
  - [ ] 1.3 Map 45–75 fast/compliant tests for retention — _AC-001_

- [ ] **2.** Re-tag smoke-set
  - [ ] 2.1 Keep @smoke on: GIP/GIS (23), flags (5), bootstrap, copy/install (10), platform (8), F15 (12), compliance (15), template (8) = ~75 total — _AC-001_
  - [ ] 2.2 Remove @smoke from: v5.3.10–v5.3.62 SR-001–003 waves (~103 tests, lines 7220–8000+, 13113–15437) — _AC-001_
  - [ ] 2.3 Validate final @smoke count: `grep -c "@smoke"` ≤ 75 — _AC-001_

- [ ] **3.** Create @regression tier
  - [ ] 3.1 Apply `@regression` tag to all v5.3.10–v5.3.62 ship waves (103+ tests) — _AC-002_
  - [ ] 3.2 Apply `@regression` tag to slow integration tests (&gt;2s non-smoke) — _AC-002_
  - [ ] 3.3 Verify bats supports `--filter @regression` and isolates from smoke path — _AC-002_

- [ ] **4.** Update CI workflows
  - [ ] 4.1 Locate `.github/workflows/test.yml` (or CI test entry point); review current job structure — _AC-004_
  - [ ] 4.2 Add PR job: `bats --filter @smoke` (target &lt;15s) — _AC-004_
  - [ ] 4.3 Add main/release job: `bats --filter @regression` or full suite (can be separate job or sequential) — _AC-004_
  - [ ] 4.4 Test locally: `bats --filter @smoke` should complete &lt;15s on 4-core — _AC-003_

- [ ] **5.** Document parallelization
  - [ ] 5.1 Create/update `docs/AgToosa_TestPlan.md` with "Smoke-Set & Regression Tiers" section — _AC-005_
  - [ ] 5.2 Document feature lanes (5 parallelizable + 1 sequential) and parallelization strategy — _AC-005_
  - [ ] 5.3 Add guidance for test authors: when to use @smoke vs @regression vs untagged — _AC-005_

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-153.md`

### Success Metrics

- Smoke-set count: 45–75 tests
- Smoke-set runtime: &lt;15s on 4-core (target 8–12s with parallelism)
- @regression tests: 103+ identified and tagged
- CI jobs implemented and tested
- Documentation complete and reviewed

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass |
| Goal / AC / tasks aligned | Pass |
| Parallelization architecture sound | Pass |
| Claim Boundary classified | Pass |
| No TBD placeholders | Pass |

## ✅ Spec Ready for Approval

**Recommendation:** Approve for enrollment in v5.3.63 cycle, contingent on DEV-152 (cleanup) completion.  
**Wave plan:** DEV-152 (cleanup) → DEV-153 (tiering) sequential dependency ensures clean version-pin state before smoke-set extraction.  
**Expected outcome:** 8–12 minute PR smoke-gate; 15–30 minute full suite; ~15× faster feedback on PR code changes.
