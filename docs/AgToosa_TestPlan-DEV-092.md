# Test Plan: DEV-092 — Transactional Apply + Idempotency

> **Spec:** `docs/archived/spec-DEV-092.md`
> **Status:** 🟦 Planned — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `TAP`

## Scope

Fixture-based coverage for transactional staging, fail-abort integrity, SHA/hash compare skip, second-run-zero-delta, apply summary counts, dry-run cleanliness, and shared install/update apply helper.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | TAP-001 | Apply stages before project mutation | Integration | Temp staging dir used; project paths untouched until commit | ⬜ Planned |
| AC-002 | TAP-002 | Mid-apply failure leaves tree unchanged | Negative fixture | Injected copy fail → exit non-zero; hash of pre-apply tree matches | ⬜ Planned `@smoke` |
| AC-003 | TAP-003 | Identical content hash skips write | Integration | Second file unchanged; summary shows `unchanged` | ⬜ Planned `@smoke` |
| AC-004 | TAP-004 | Second identical run zero delta | Integration | Back-to-back apply → zero bytes written; mtime optional assert | ⬜ Planned `@smoke` |
| AC-005 | TAP-005 | Apply summary reports action counts | Integration | stdout contains `written`, `merged`, `unchanged`, `failed` keys | ⬜ Planned |
| AC-006 | TAP-006 | Dry-run creates no staging in project | Regression | No `.agtoosa` staging artifacts; tree hash stable | ⬜ Planned |
| AC-007 | TAP-007 | Install and update share apply helper | Contract | `lib/apply.sh` sourced from both paths (grep/bats) | ⬜ Planned |
| AC-008 | TAP-008 | DEV-092 filter documents evidence | Meta | Bats filter `DEV-092` exists | ⬜ Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Permission denied on one target file | TAP-002 | Abort; earlier files not left inconsistent |
| Empty project first install | TAP-004 | First run writes; second run zero delta |
| Pack adds new file then re-run | TAP-004 | Second run unchanged after first success |

## Smoke Set

- `@smoke TAP-002` — fail-abort integrity.
- `@smoke TAP-003` — hash-compare skip.
- `@smoke TAP-004` — second-run-zero-delta.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-092|TAP-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED fixtures | `bats tests/agtoosa.bats -f "DEV-092\|TAP-"` | 1 | `not ok TAP-002: tree hash changed after injected failure` |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Implementation | `bats tests/agtoosa.bats -f "DEV-092\|TAP-"` | 0 | `ok 1` through `ok 8`; TAP-004 zero-delta confirmed |
