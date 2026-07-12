# Test Plan: DEV-103 — External Registry Publication Runbook

> **Spec:** `docs/archived/spec-DEV-103.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `PUB`

## Scope

External registry publication runbook: pre-submit, submit (4.2), and confirm (4.3) phases; checklist tied to OPP evidence; state-machine alignment; discovery links; forbidden publication claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | PUB-001 | Three Publication Phases Documented | Docs contract | Pre-submit, submit, confirm sections present | Planned `@smoke` |
| AC-002 | PUB-002 | Pre-Submit Checklist Completeness | Docs contract | Manifest, OPP, content-policy, owner, compatibility gates listed | Planned `@smoke` |
| AC-003 | PUB-003 | Submission Steps Without Auto-Publish Claim | Docs contract | Submit section lists record fields; no automatic publication claim | Planned |
| AC-004 | PUB-004 | Confirmation Requires External Record | Docs contract | Published state requires independent accepted record | Planned |
| AC-005 | PUB-005 | State Machine Alignment | Docs contract | local candidate → submitted → published matches DEV-080 | Planned |
| AC-006 | PUB-006 | Pilot Checklist Discovery Link | Docs contract | `official-pack-pilot-checklist.md` links to runbook for 4.2/4.3 | Planned |
| AC-007 | PUB-007 | Forbidden Publication Phrases | Negative | "Open PR = published" and similar phrases fail | Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Runbook skips OPP green requirement | PUB-002 | Checklist completeness fails |
| Inventory update instructions omit confirmation step | PUB-004 | Contract failure |
| Phrase "locally published" in runbook | PUB-007 | Forbidden-claim assertion fails |

## Smoke Set

- `@smoke PUB-001` — three publication phases.
- `@smoke PUB-002` — pre-submit checklist.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-103|PUB-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED runbook contract | `bats tests/agtoosa.bats -f "DEV-103\|PUB-"` | 1 | `registry-external-publication-runbook.md` not found |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-103\|PUB-"` | 0 | All PUB tests pass |
