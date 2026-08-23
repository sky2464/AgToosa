# Test Plan: DEV-106 — Built with AgToosa Showcase

> **Spec:** `docs/archived/spec-DEV-106.md`
> **Status:** 🟢 Implemented
> **Created:** 2026-07-12
> **Test prefix:** `SHOW`

## Scope

Built with AgToosa showcase page: curated-not-certified disclaimer, submission rules, eligibility criteria, link-out listings, case-study kit cross-link, index discovery, forbidden endorsement phrases.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | SHOW-001 | Curated Not Certified Disclaimer | Docs contract | Page states listings are not official certification | Pass `@smoke` |
| AC-002 | SHOW-002 | Submission Rules Completeness | Docs contract | Rules require repo link, description, AgToosa proof, contact path | Pass `@smoke` |
| AC-003 | SHOW-003 | Eligibility and Exclusion Criteria | Docs contract | Inclusion and exclusion criteria documented | Pass |
| AC-004 | SHOW-004 | Link-Out Listings Only | Docs contract | No inline third-party README bodies | Pass |
| AC-005 | SHOW-005 | Case Study Kit Cross-Link | Docs contract | Links to `AgToosa_CaseStudy.template.md` without duplicating body | Pass |
| AC-006 | SHOW-006 | Index Discovery Link | Docs contract | `docs/index.md` links to showcase | Pass |
| AC-007 | SHOW-007 | Forbidden Endorsement Phrases | Negative | "AgToosa certified/approved" phrases fail | Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Showcase embeds external README section | SHOW-004 | Link-only assertion fails |
| Submission rules omit contact/issue path | SHOW-002 | Completeness failure |
| Page title "AgToosa Certified Projects" | SHOW-007 | Forbidden phrase fails |

## Smoke Set

- `@smoke SHOW-001` — curated not certified disclaimer.
- `@smoke SHOW-002` — submission rules completeness.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-106|SHOW-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED showcase contract | `bats tests/agtoosa.bats -f "DEV-106\|SHOW-"` | 1 | `not ok 1 … SHOW-001` — `[ -f "$f" ]' failed` (`built-with-agtoosa.md` missing); all 7 SHOW tests fail the same presence check |

```
1..7
not ok 1 DEV-106 @smoke SHOW-001: Curated Not Certified Disclaimer
#   `[ -f "$f" ]' failed
not ok 2 DEV-106 @smoke SHOW-002: Submission Rules Completeness
#   `[ -f "$f" ]' failed
not ok 3 DEV-106 SHOW-003: Eligibility and Exclusion Criteria
#   `[ -f "$f" ]' failed
not ok 4 DEV-106 SHOW-004: Link-Out Listings Only
#   `[ -f "$f" ]' failed
not ok 5 DEV-106 SHOW-005: Case Study Kit Cross-Link
#   `[ -f "$f" ]' failed
not ok 6 DEV-106 SHOW-006: Index Discovery Link
#   `[ -f "$page" ]' failed
not ok 7 DEV-106 SHOW-007: Forbidden Endorsement Phrases
#   `[ -f "$f" ]' failed
```

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-106\|SHOW-"` | 0 | All 7 SHOW tests pass |

```
1..7
ok 1 DEV-106 @smoke SHOW-001: Curated Not Certified Disclaimer
ok 2 DEV-106 @smoke SHOW-002: Submission Rules Completeness
ok 3 DEV-106 SHOW-003: Eligibility and Exclusion Criteria
ok 4 DEV-106 SHOW-004: Link-Out Listings Only
ok 5 DEV-106 SHOW-005: Case Study Kit Cross-Link
ok 6 DEV-106 SHOW-006: Index Discovery Link
ok 7 DEV-106 SHOW-007: Forbidden Endorsement Phrases
```
