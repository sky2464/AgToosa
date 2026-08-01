# Test Plan: DEV-147 — Tracker CI Publish Hardening

> **Spec:** `docs/archived/spec-DEV-147.md`
> **Status:** ⬜ Backlog
> **Created:** 2026-07-29
> **Test prefix:** `GIP`

## Scope

Fixture-based coverage for `agtoosa-issues-sync.sh` dry-run, missing-`gh` guard, mocked upsert create/edit/close paths, milestone resolution, doctor `GIP-003` finding, template parity, and README `AGTOOSA-ROADMAP` marker regression.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | GIP-001 | Dry-run prints deterministic manifest rows | Integration | Exit 0; stable stdout from fixture | ⬜ |
| AC-002 | GIP-002 | Missing gh exits before manifest processing | Negative | Non-zero; clear error message | ⬜ |
| AC-003 | GIP-003 | Mock gh edit path when upsert_key exists | Integration | `issue edit` called; no `issue create` | ⬜ |
| AC-004 | GIP-004 | Mock gh create path when no match | Integration | `issue create` called | ⬜ |
| AC-005 | GIP-005 | Milestone resolve/create before upsert (mocked) | Integration | `gh api` milestone calls recorded | ⬜ |
| AC-006 | GIP-006 | Closed state invokes issue close (mocked) | Integration | `issue close` recorded | ⬜ |
| AC-007 | GIP-007 | Doctor emits GIP-003 when workflow present but script missing | Integration | Warn finding `GIP-003` in doctor JSON | ⬜ |
| AC-008 | GIP-008 | Doctor silent on GIP-003 when workflow absent | Integration | No `GIP-003` finding | ⬜ |
| AC-009 | GIP-009 | Template script and workflow example exist and match | Contract | Files present; key markers match | ⬜ |
| AC-010 | GIP-010 | README AGTOOSA-ROADMAP marker preserved on dry-run | Regression | Start/end markers intact vs GIS-008 | ⬜ |

## Smoke Set

- `@smoke GIP-001` — dry-run deterministic output.
- `@smoke GIP-002` — missing `gh` guard.
- `@smoke GIP-010` — meta regression + test plan present.

Smoke command: `bats tests/agtoosa.bats -f "DEV-147|GIP-"`

## Spec Quality Analyzer Evidence

- All Must ACs (AC-001–AC-009) map to at least one GIP row.
- AC-010 (Should) maps to GIP-010.
- Mock `gh` only — no live network tests.
