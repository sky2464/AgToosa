# Spec: DEV-130 — BCL Hardening & CI Wiring

> **Story ID:** DEV-130  
> **Epic:** DEV-003 — Community Template Registry · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.44
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P0  
> **Parent / extends:** DEV-121 (Behavioral Conformance Lab)  
> **Depends on:** DEV-121 shipped (v5.3.34) · ADR-021  
> **Spec created:** 2026-07-26  
> **Ship target:** v5.3.44

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Follow-up closes DEV-121 review warnings R-121-001–R-121-003 within static BCL contract — no live assistant CI |
| Foundation | BCL-001–BCL-013 already run in full `bats tests/agtoosa.bats` CI job; fast product-truth filter omits `BCL` |
| Fixture gap | Four platforms have static artifact trees but lack committed `scenario-run.json` (cursor + claude have pilots) |
| Validation gap | `lib/scenario.sh` uses embedded structural Python; `contracts/scenario-*.schema.json` exist but are not enforced |
| Non-goals | Hosted lab, live assistant APIs in CI, auto Scenario-tested promotion, dedicated scheduled workflow, pack registry gate hooks (ADR-021 unchanged) |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Narrowest v1 boundary for DEV-130? | **Narrow** — JSON Schema validation + BCL smoke in CI fast path + `scenario-run.json` for all six platforms |
| Q2 | JSON Schema implementation? | **Python jsonschema** — validate against `contracts/scenario-*.schema.json` in `lib/scenario.sh` + CI |

#### Documented assumptions

- Missing four `scenario-run.json` files are **fixture-derived**: produced by running `agtoosa-scenario-run.sh` against each platform's static fixture tree (not live assistant sessions).
- `jsonschema` may be installed in CI via `pip` when absent; local maintainer runs should document the same optional dependency or use CI parity.
- R-121-001 test-plan sync (`docs/AgToosa_TestPlan-DEV-121.md`) is in scope as a small docs chore bundled with this story.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Harden Behavioral Conformance Lab v1 — enforce JSON Schemas, complete six-platform pilot evidence, and wire BCL smokes into CI fast path |
| User outcome | Maintainers get schema-failing diagnostics on bad corpus/run JSON; CI catches BCL regressions earlier; all six platform fixtures include recorded `scenario-run.json` |
| Success condition | BCL-014+ green; BCL smokes in product-truth CI filter; six `scenario-run.json` fixtures validate; DEV-121 test plan synced |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-130.md`; bats `BCL-014+`; `.github/workflows/ci.yml` filter update |
| Non-goals | Live assistant execution in CI; dedicated scenario-verify CI job; scheduled maintainer workflow; pack behavioral gate automation |
| Assumptions | ADR-021 non-goals stand; structural checks may remain as fallback only if jsonschema unavailable (document behavior) |
| Risks | CI dependency on `pip install jsonschema`; golden `scenario-run.json` timestamps may need normalization in tests |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `scenario_validate_corpus` runs THE SYSTEM SHALL validate `scenarios/corpus-v1.json` against `contracts/scenario-corpus-v1.schema.json` using JSON Schema (jsonschema) |
| AC-002 | Must | WHEN `scenario_validate_run_json` runs THE SYSTEM SHALL validate run evidence against `contracts/scenario-run-v1.schema.json` using JSON Schema (jsonschema) |
| AC-003 | Must | WHEN invalid corpus or run JSON is validated THE SYSTEM SHALL exit non-zero with a schema error message |
| AC-004 | Must | WHEN DEV-130 ships THE SYSTEM SHALL commit `scenario-run.json` for all six platforms under `tests/fixtures/scenario-corpus/lifecycle-compass-proof/` |
| AC-005 | Must | WHEN CI product-truth regression runs THE SYSTEM SHALL include BCL `@smoke` tests in the fast bats filter |
| AC-006 | Must | WHEN CI validate job runs THE SYSTEM SHALL install `jsonschema` (or equivalent) before BCL schema tests execute |
| AC-007 | Should | WHEN DEV-130 ships THE SYSTEM SHALL sync `docs/AgToosa_TestPlan-DEV-121.md` to match R1 universal-scenario model (R-121-001) |
| AC-008 | Must | WHEN DEV-130 ships THE SYSTEM SHALL add bats BCL-014+ covering schema pass/fail and six-platform run JSON presence |

## 2. Design

| Area | Change |
|------|--------|
| `lib/scenario.sh` | Replace/extend embedded Python validators with jsonschema loads of `contracts/scenario-*.schema.json`; clear stderr on validation failure |
| `tests/fixtures/scenario-corpus/` | Add `scenario-run.json` for codex, copilot, windsurf, gemini (fixture-derived via runner) |
| `tests/agtoosa.bats` | BCL-014: schema rejects tampered run JSON; BCL-015: all six platforms have valid run JSON; extend BCL-002/003 if needed |
| `.github/workflows/ci.yml` | Add `BCL` to product-truth fast filter; pip install jsonschema before bats |
| `docs/AgToosa_TestPlan-DEV-121.md` | Align with `lifecycle-compass-proof` × six platforms + standalone CLIs |

## 3. Tasks

- [x] **1.** Jsonschema validation in `lib/scenario.sh` — _AC-001–AC-003_
- [x] **2.** Six-platform `scenario-run.json` fixtures — _AC-004_
- [x] **3.** CI fast-path + jsonschema install — _AC-005, AC-006_
- [x] **4.** BCL-014+ bats — _AC-008_
- [x] **5.** Sync DEV-121 test plan — _AC-007_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-130.md`.

---

## ✅ Spec Approved

Approved: 2026-07-27 — user selected /agtoosa-build after spec interview.
