# Test Plan: DEV-092 — Transactional Apply + Idempotency

> **Spec:** `docs/archived/spec-DEV-092.md`
> **Status:** 🟩 GREEN — Wave 2 build
> **Created:** 2026-07-12
> **Test prefix:** `TAP`

## Scope

Fixture-based coverage for transactional staging, fail-abort integrity, SHA/hash compare skip, second-run-zero-delta, apply summary counts, dry-run cleanliness, and shared install/update apply helper.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | TAP-001 | Apply stages before project mutation | Integration | `lib/apply.sh` exposes staging/commit API | ✅ GREEN |
| AC-002 | TAP-002 | Mid-apply failure leaves tree unchanged | Negative fixture | Injected copy fail → exit non-zero; project files untouched | ✅ GREEN `@smoke` |
| AC-003 | TAP-003 | Identical content hash skips write | Integration | Summary shows `unchanged` | ✅ GREEN `@smoke` |
| AC-004 | TAP-004 | Second identical run zero delta | Integration | `written=0` on second identical commit | ✅ GREEN `@smoke` |
| AC-005 | TAP-005 | Apply summary reports action counts | Integration | stdout contains written/merged/unchanged/failed | ✅ GREEN |
| AC-006 | TAP-006 | Dry-run creates no staging in project | Regression | No staging artifacts; tree hash stable | ✅ GREEN |
| AC-007 | TAP-007 | Install and update share apply helper | Contract | `apply` sourced; install/update/copy call apply_* | ✅ GREEN |
| AC-008 | TAP-008 | DEV-092 filter documents evidence | Meta | Bats filter `DEV-092` exists | ✅ GREEN |

## Smoke Set

- `@smoke TAP-002` — fail-abort integrity.
- `@smoke TAP-003` — hash-compare skip.
- `@smoke TAP-004` — second-run-zero-delta.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-092|TAP-"`

## RED Evidence

```
RED evidence — 1.1 / 1.2 / 1.3
Command: bats tests/agtoosa.bats -f "DEV-092|TAP-"
Exit code: 1
Failure excerpt: not ok TAP-001: [ -f lib/apply.sh ]' failed; TAP-003/005 source apply.sh exit 127
```

## GREEN Evidence

```
GREEN evidence — 2.1 / 2.2 / 3.1
Command: bats tests/agtoosa.bats -f "DEV-092|TAP-"
Exit code: 0
Pass excerpt: ok TAP-001–TAP-008
```
