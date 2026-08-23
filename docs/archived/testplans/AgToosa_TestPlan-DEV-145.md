# Test Plan: DEV-145 — Tracker Bootstrap Apply

> **Spec:** `docs/archived/spec-DEV-145.md`
> **Status:** 🟩 GREEN
> **Created:** 2026-07-28
> **Test prefix:** `TBA`

## Scope

Fixture-based coverage for bootstrap apply dry-run, selective accept, `--apply-all-new-external`, DEV ID allocation, GitHub-standard title normalization, transaction journal pre-image, and mutation guards.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | TBA-001 | Bootstrap emits proposal JSON with accept default false | Integration | JSON schema valid; accept=false | 🟩 GREEN |
| AC-002 | TBA-002 | Apply without --yes is dry-run only | Integration | Master-Plan unchanged; diff printed | 🟩 GREEN `@smoke` |
| AC-003 | TBA-003 | Apply --yes merges accept:true rows only | Integration | Only accepted rows appended | 🟩 GREEN |
| AC-003 | TBA-004 | --apply-all-new-external accepts all new_external | Integration | All new_external rows appended | 🟩 GREEN |
| AC-004 | TBA-005 | Allocates next free DEV ID | Unit | No ID collision with fixture MP | 🟩 GREEN `@smoke` |
| AC-005 | TBA-006 | Title uses feat/fix/chore/docs prefix not DEV in title | Contract | No `DEV-` in Title column | 🟩 GREEN |
| AC-006 | TBA-007 | Status column records external_ref | Integration | Provider ref in Status | 🟩 GREEN |
| AC-007 | TBA-008 | Transaction journal pre-image on apply | Integration | Journal entry before write | 🟩 GREEN |
| AC-008 | TBA-009 | Mutation guard rejects output targeting Master-Plan | Negative | Non-zero exit | 🟩 GREEN |
| AC-008 | TBA-010 | DEV-145 filter suite green | Meta | Section + test plan present | 🟩 GREEN `@smoke` |

## Smoke Set

- `@smoke TBA-002` — dry-run default.
- `@smoke TBA-005` — DEV ID allocation.
- `@smoke TBA-010` — meta regression.

Smoke command: `bats tests/agtoosa.bats -f "DEV-145|TBA-"`
