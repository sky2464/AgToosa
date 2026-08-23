# Test Plan: DEV-098 — Navigation by User Job

> **Spec:** `docs/archived/spec-DEV-098.md`
> **Status:** ✅ Executed — NAV GREEN
> **Created:** 2026-07-12
> **Executed:** 2026-07-12
> **Test prefix:** `NAV`

## Scope

Job-oriented `docs/index.md` navigation: five sections (Start, Use, Trust, Adapt, Maintain), canonical link-only entries, required guide coverage per section, non-duplication contract, and static-site compatibility under `/AgToosa/`.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | NAV-001 | Five Job Sections Present | Docs contract | Start, Use, Trust, Adapt, Maintain headings exist in order | ✅ Pass `@smoke` |
| AC-002 | NAV-002 | Link-Only Landing Page | Docs contract | Index links to guides without embedding maintained guide bodies | ✅ Pass `@smoke` |
| AC-003 | NAV-003 | Start Section Required Links | Docs contract | Start links to first-15, init, and agent context owners | ✅ Pass |
| AC-004 | NAV-004 | Use Section Required Links | Docs contract | Use links to spec, build, review, ship, and verify owners | ✅ Pass |
| AC-005 | NAV-005 | Trust Section Required Links | Docs contract | Trust links to registry, evidence, and security boundary owners | ✅ Pass |
| AC-006 | NAV-006 | Adapt Section Required Links | Docs contract | Adapt links to pack and extension authoring owners | ✅ Pass |
| AC-007 | NAV-007 | Maintain Section Required Links | Docs contract | Maintain links to update, doctor/revert, and maintainer owners | ✅ Pass |
| AC-008 | NAV-008 | Static Site Regression | Integration | SITE build passes; landing links resolve under `/AgToosa/` | ✅ Pass `@smoke` |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Index embeds a full guide section copied from `AgToosa_Build.md` | NAV-002 | Non-duplication assertion fails |
| Required Start link targets missing file | NAV-003 | Link resolution fails with path |
| Section renamed "Getting Started" instead of "Start" | NAV-001 | Section inventory fails |

## Smoke Set

- `@smoke NAV-001` — five job sections present.
- `@smoke NAV-002` — link-only landing contract.
- `@smoke NAV-008` — static site regression.

Smoke command: `bats tests/agtoosa.bats -f "DEV-098|NAV-"`

## RED Evidence

### RED evidence — 1. RED navigation contract (before index restructure)

```
Command: bats tests/agtoosa.bats -f "DEV-098|NAV-"
Exit code: 1
Failure excerpt:
  not ok 1 DEV-098 @smoke NAV-001: Five Job Sections Present
  #   `grep -qE '^## Start$' "$index"' failed
  ok 2 DEV-098 @smoke NAV-002: Link-Only Landing Page
  not ok 3 DEV-098 NAV-003: Start Section Required Links
  #   `[ -n "$section" ]' failed
  not ok 4–7 NAV-004–NAV-007: section bodies empty (missing ## Use/Trust/Adapt/Maintain)
  not ok 8 DEV-098 @smoke NAV-008: Static Site Regression
  #   `grep -q "Maintain" "$outdir/index.html"' failed
  (7/8 NAV tests failed before index restructure; NAV-002 already satisfied by DEV-076 link-only landing)
```

## GREEN Evidence

### GREEN evidence — 2–3 (landing + SITE regression)

```
Command: bats tests/agtoosa.bats -f "DEV-098|NAV-"
Exit code: 0
Pass excerpt:
  ok 1 DEV-098 @smoke NAV-001: Five Job Sections Present
  ok 2 DEV-098 @smoke NAV-002: Link-Only Landing Page
  ok 3 DEV-098 NAV-003: Start Section Required Links
  ok 4 DEV-098 NAV-004: Use Section Required Links
  ok 5 DEV-098 NAV-005: Trust Section Required Links
  ok 6 DEV-098 NAV-006: Adapt Section Required Links
  ok 7 DEV-098 NAV-007: Maintain Section Required Links
  ok 8 DEV-098 @smoke NAV-008: Static Site Regression
  1..8

Command: bats tests/agtoosa.bats -f "DEV-098|NAV-|SITE-"
Exit code: 0
Pass excerpt:
  ok 1–8 DEV-076 SITE-001–SITE-008
  ok 9–16 DEV-098 NAV-001–NAV-008
  1..16
```
