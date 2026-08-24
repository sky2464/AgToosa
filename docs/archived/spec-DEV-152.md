# Spec: DEV-152 — Bats Cleanup & Version Pin Consolidation

> **Story ID:** DEV-152
> **Epic:** DEV-001 — Core Generator Engine / DEV-004 — Test Modernization
> **Status:** 🟦 Todo
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-08-23
> **Extends:** `tests/agtoosa.bats` refactoring; foundation for DEV-153 (Bats Tiering)

> **Milestone:** v5.3.63 (active)

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Debt scope | 170 stale version-pin references (v5.3.2–v5.3.62); no conflict markers; no duplicate test definitions |
| Consolidation target | Extract v5.3.8–v5.3.18 Wave 2–4 pins + DEV-119–124 ship regression waves to regression suite |
| Dependency | Cleanup must complete before DEV-153 (smoke-set extraction depends on clean pin state) |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Scope: All three items (pins + dedup + conflicts)? | A — Yes, all three; agent finds clean state on dedup/conflicts so pins are primary work |
| Q2 | Target release? | A — v5.3.63, same cycle as DEV-150/151 |

#### Documented assumptions

- Stale version pins are primarily in old ship regression waves (lines 7321–15437); bulk cleanup consolidates these.
- Bats suite compiles and runs today; cleanup is debt removal, not bug fix.
- Version matrix fixture or parameterization approach is chosen during build phase based on `lib/` context.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Remove technical debt from the bats test suite by consolidating 170 stale version-pin references into a regression fixture and parameterized values |
| User outcome | Test maintainers have a clear, current version reference; future tests inherit correct version context automatically |
| Success condition | All 170 version-pin hardcodes consolidated; bats suite compiles clean; AC-001–AC-004 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-152.md`; bats compile; `grep -c "v5\.3\.[0-9]"` returns only active pins |
| Non-goals | Rewrite test logic; change test semantics; split tests into separate files (keep in `agtoosa.bats` unless dedup requires isolation) |
| Assumptions | v5.3.53 is current version; version pins in ranges 7321–15437 are the bulk consolidation target |
| Risks | Over-consolidation removes context (must preserve original shipwave markers); regex replacements introduce syntax errors (mitigated by pre-commit bats compile) |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `grep -n "v5\.3\.[0-9]"` scans `tests/agtoosa.bats` THE SYSTEM SHALL return only active version references (&lt;10 hardcoded pins allowed for current version context; all others parameterized or removed) | Must |
| AC-002 | WHEN version pin consolidation completes THE SYSTEM SHALL move v5.3.8–v5.3.18 Wave 2–4 regression tests (lines 7321–7860) to regression suite or mark with `@regression` tag for parallel execution boundary | Must |
| AC-003 | WHEN ship regression wave consolidation completes THE SYSTEM SHALL consolidate DEV-119–124 old milestone pins (lines 13113–15437) and mark with `@regression` tag or isolate to regression-only run | Must |
| AC-004 | WHEN `bats --compile tests/agtoosa.bats` runs THE SYSTEM SHALL exit 0 with no syntax errors | Must |
| AC-005 | WHEN DEV-152 is shipped THE SYSTEM SHALL include brief cleanup summary in release notes or CHANGELOG | Should |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `tests/agtoosa.bats` (lines 7321–7341) | Extract v5.3.8–v5.3.9 batch regression pins; parameterize or remove |
| `tests/agtoosa.bats` (lines 7490–7860) | Extract v5.3.10–v5.3.18 Wave 2–4 pins; tag with `@regression` |
| `tests/agtoosa.bats` (lines 13113–14708) | Consolidate v5.3.20, v5.3.26, v5.3.31 ship pins; tag with `@regression` |
| `tests/agtoosa.bats` (lines 14709–15437) | Consolidate DEV-119–124 pins (v5.3.32–v5.3.39); tag with `@regression` |
| Version reference strategy | Candidate: `AGTOOSA_VERSION` environment variable in test preamble, or ship-wave fixture matrix |

### 2.2 Cleanup Strategy

**Three-phase approach:**

1. **Phase 1:** Grep and catalog all 170 hardcoded version refs (lines, context, wave/DEV association)
2. **Phase 2:** Consolidate by wave (v5.3.8–9, v5.3.10–18, v5.3.20+, v5.3.31+, v5.3.32–39) and tag with `@regression`
3. **Phase 3:** Validate clean state: `bats --compile`, `grep` for stale refs, spot-check @regression boundaries

### 2.3 Build Scope

**In scope:**
- `tests/agtoosa.bats` consolidation (lines 7321–15437, version pins)
- Tagging with `@regression` marker (or creating separate regression suite)
- Pre-commit validation: `bats --compile tests/agtoosa.bats`

**Out of scope:**
- Rewrite test logic or assertions
- Split bats into multiple files
- Change master/main test semantics
- Revert or fix the 92 pre-existing test failures (separate DEV-154 or backlog item)

### 2.4 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Accidental removal of important milestone context | Tampering | Phase 1 catalog captures context; `@regression` tag preserves wave association |
| Regex replacement introduces syntax errors | Integrity | `bats --compile` pre-commit gate; careful sed/awk patterns with review |
| Over-consolidation hides future regression needs | Information disclosure | Keep @regression markers visible; document consolidation in CHANGELOG |

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Catalog and analyze 170 stale version pins
  - [ ] 1.1 Grep all `v5\.3\.[0-9]` refs; categorize by version + line ranges — _AC-001_
  - [ ] 1.2 Identify v5.3.8–v5.3.18 Wave 2–4 pins (lines 7321–7860) — _AC-002_
  - [ ] 1.3 Identify DEV-119–124 old milestone pins (lines 13113–15437) — _AC-003_
  
- [ ] **2.** Consolidate version pins
  - [ ] 2.1 Lines 7321–7341 (v5.3.8–9): extract or parameterize — _AC-001_
  - [ ] 2.2 Lines 7490–7860 (v5.3.10–18 Wave 2–4): tag with `@regression` or extract — _AC-002_
  - [ ] 2.3 Lines 13113–14708 (v5.3.20, v5.3.26, v5.3.31): consolidate; tag `@regression` — _AC-003_
  - [ ] 2.4 Lines 14709–15437 (DEV-119–124 v5.3.32–39): consolidate; tag `@regression` — _AC-003_

- [ ] **3.** Parameterize version reference (candidate approach)
  - [ ] 3.1 Option A: `AGTOOSA_VERSION` env var preamble; replace hardcodes with `$AGTOOSA_VERSION`
  - [ ] 3.2 Option B: Ship-wave fixture matrix (lines 1–50); reference matrix in wave sections
  - [ ] 3.3 Choose approach during build; document in CHANGELOG

- [ ] **4.** Validate clean state
  - [ ] 4.1 Run `bats --compile tests/agtoosa.bats` — _AC-004_
  - [ ] 4.2 Verify `grep -c "v5\.3\.[0-9]"` ≤ 10 (active refs only) — _AC-001_
  - [ ] 4.3 Spot-check @regression boundaries (lines 7220–8000, 13113–15437) — _AC-002, AC-003_

- [ ] **5.** Update docs
  - [ ] 5.1 `docs/Master-Plan.md` → mark DEV-152 complete — _AC-005_
  - [ ] 5.2 Add cleanup summary to CHANGELOG (optional) — _AC-005_

## 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-152.md`

### Success Metrics

- Bats compiles clean (exit 0)
- Stale version-pin refs reduced from 170 → &lt;10 active refs
- @regression marker applied to 103+ consolidation-target tests
- No new test failures introduced

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass |
| Goal / AC / tasks aligned | Pass |
| No TBD placeholders | Pass |

## ✅ Spec Ready for Approval

**Recommendation:** Approve for enrollment in v5.3.63 cycle alongside DEV-150/151.  
**Prerequisite:** DEV-152 should complete before DEV-153 (tiering) to ensure clean version-pin state.
