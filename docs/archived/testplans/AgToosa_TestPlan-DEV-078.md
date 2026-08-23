# Test Plan: DEV-078 — First-15-Minutes Maintenance Gate

> **Spec:** `docs/archived/spec-DEV-078.md`
> **Status:** ✅ Done (shipped v5.3.8)
> **Created:** 2026-07-11
> **Test prefix:** `F15`

## Scope

Deterministic, fixture-based coverage for scoped release pins, local proof links, canonical proof-repository URLs, actionable failures, no-network private mode, and read-only execution. Live public URL availability is existing behavior, not asserted as deterministic.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | F15-001 | Current first-15 pins match the canonical version | Integration | Scoped tags equal `v${AGTOOSA_VERSION}` | ✅ Pass |
| AC-001, AC-004 | F15-002 | A stale release pin fails with exact diagnostics | Negative fixture | Non-zero exit names file, stale tag, and expected tag | ✅ Pass |
| AC-002 | F15-003 | Relative proof links resolve from their documents | Integration/fixture | Every scoped relative target exists; a missing fixture target fails | ✅ Pass |
| AC-003 | F15-004 | First-15 proof repository URL is canonical | Consistency | README, proof docs, and checker contain one normalized URL | ✅ Pass |
| AC-004 | F15-005 | Multiple maintenance findings remain actionable | Negative fixture | Accumulated output identifies each file and observed/expected value | ✅ Pass |
| AC-005 | F15-006 | Private maintenance mode is offline | Security/regression | Network shim is never invoked in private mode | ✅ Pass |
| AC-005 | F15-007 | Public mode retains availability checks | Regression | Existing anonymous URL checks run only after deterministic checks pass | ✅ Pass |
| AC-006 | F15-008 | Maintenance gate is read-only and flow-neutral | Integrity | Scoped file hashes and onboarding step order are unchanged after the check | ✅ Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| One command uses the prior patch tag | F15-002 | Non-zero with observed and expected versions |
| Relative link contains a valid sibling path | F15-003 | Resolves from the containing file, not repository root |
| Proof URL differs only by trailing `.git` or slash | F15-004 | Normalize allowed suffixes before comparison |
| Two stale values occur together | F15-005 | Both are reported before exit |
| `curl` shim fails if invoked during private mode | F15-006 | Gate still passes when local content is valid |
| Checker mutates a proof document | F15-008 | Hash comparison fails |

## Smoke Set

- `@smoke F15-001` — canonical release-pin parity.
- `@smoke F15-003` — relative proof-link integrity.
- `@smoke F15-006` — private mode performs no network calls.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-078|F15-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-078\|F15-"` | 1 | `not ok 1 F15-001: grep --ref v5.3.7 failed (docs still pinned v5.2.7)`; `not ok 2 F15-002: [ "$status" -ne 0 ] failed` (no maintenance gate yet); 6/8 failed before implementation |
| 2. Deterministic maintenance checks | `bats tests/agtoosa.bats -f "F15-001\|F15-002\|F15-003\|F15-004\|F15-005\|F15-006\|F15-007\|F15-008"` | 1 | `grep: unrecognized option '--ref'`; `unexpected EOF while looking for matching backtick` during checker bring-up |
| 3. Repair current drift only | `bats tests/agtoosa.bats -f "F15-001\|F15-003\|F15-004\|F15-008"` | 1 | Scoped docs repaired to v5.3.7; checker syntax/unbound-array fixes required before GREEN |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-078\|F15-"` | 0 | `ok 1` through `ok 8` — all F15 tests pass |
| 2. Deterministic maintenance checks | `bats tests/agtoosa.bats -f "F15-001\|F15-002\|F15-003\|F15-004\|F15-005\|F15-006\|F15-007\|F15-008"` | 0 | `ok - scoped release pins match v5.3.7`; stale/missing fixtures exit non-zero with file + observed + expected |
| 3. Repair current drift only | `bats tests/agtoosa.bats -f "F15-001\|F15-003\|F15-004\|F15-008"` | 0 | `first-15-minutes.md` and `public-launch-proof.md` pins aligned to `v5.3.7` |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-078\|F15-"` | 0 | `1..8` all `ok`; private mode prints `Skipping anonymous public URL checks` with no `curl` shim invocation |
