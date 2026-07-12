# Test Plan: DEV-106 — Built with AgToosa Showcase

> **Spec:** `docs/archived/spec-DEV-106.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `SHOW`

## Scope

Built with AgToosa showcase page: curated-not-certified disclaimer, submission rules, eligibility criteria, link-out listings, case-study kit cross-link, index discovery, forbidden endorsement phrases.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | SHOW-001 | Curated Not Certified Disclaimer | Docs contract | Page states listings are not official certification | Planned `@smoke` |
| AC-002 | SHOW-002 | Submission Rules Completeness | Docs contract | Rules require repo link, description, AgToosa proof, contact path | Planned `@smoke` |
| AC-003 | SHOW-003 | Eligibility and Exclusion Criteria | Docs contract | Inclusion and exclusion criteria documented | Planned |
| AC-004 | SHOW-004 | Link-Out Listings Only | Docs contract | No inline third-party README bodies | Planned |
| AC-005 | SHOW-005 | Case Study Kit Cross-Link | Docs contract | Links to `AgToosa_CaseStudy.template.md` without duplicating body | Planned |
| AC-006 | SHOW-006 | Index Discovery Link | Docs contract | `docs/index.md` links to showcase | Planned |
| AC-007 | SHOW-007 | Forbidden Endorsement Phrases | Negative | "AgToosa certified/approved" phrases fail | Planned |

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
| 1. RED showcase contract | `bats tests/agtoosa.bats -f "DEV-106\|SHOW-"` | 1 | `built-with-agtoosa.md` not found |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-106\|SHOW-"` | 0 | All SHOW tests pass |
