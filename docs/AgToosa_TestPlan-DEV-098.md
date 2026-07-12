# Test Plan: DEV-098 — Navigation by User Job

> **Spec:** `docs/archived/spec-DEV-098.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `NAV`

## Scope

Job-oriented `docs/index.md` navigation: five sections (Start, Use, Trust, Adapt, Maintain), canonical link-only entries, required guide coverage per section, non-duplication contract, and static-site compatibility under `/AgToosa/`.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | NAV-001 | Five Job Sections Present | Docs contract | Start, Use, Trust, Adapt, Maintain headings exist in order | Planned `@smoke` |
| AC-002 | NAV-002 | Link-Only Landing Page | Docs contract | Index links to guides without embedding maintained guide bodies | Planned `@smoke` |
| AC-003 | NAV-003 | Start Section Required Links | Docs contract | Start links to first-15, init, and agent context owners | Planned |
| AC-004 | NAV-004 | Use Section Required Links | Docs contract | Use links to spec, build, review, ship, and verify owners | Planned |
| AC-005 | NAV-005 | Trust Section Required Links | Docs contract | Trust links to registry, evidence, and security boundary owners | Planned |
| AC-006 | NAV-006 | Adapt Section Required Links | Docs contract | Adapt links to pack and extension authoring owners | Planned |
| AC-007 | NAV-007 | Maintain Section Required Links | Docs contract | Maintain links to update, doctor/revert, and maintainer owners | Planned |
| AC-008 | NAV-008 | Static Site Regression | Integration | SITE build passes; landing links resolve under `/AgToosa/` | Planned `@smoke` |

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

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-098|NAV-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED navigation contract | `bats tests/agtoosa.bats -f "DEV-098\|NAV-"` | 1 | `not ok` for NAV-001–NAV-008 before index restructure |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Static site regression | `bats tests/agtoosa.bats -f "DEV-098\|NAV-\|SITE-"` | 0 | NAV and SITE regression pass |
