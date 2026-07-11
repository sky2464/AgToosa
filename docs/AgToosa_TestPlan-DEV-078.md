# Test Plan: DEV-078 — First-15-Minutes Maintenance Gate

> **Spec:** `docs/archived/spec-DEV-078.md`
> **Status:** ⬜ Backlog — Not executed
> **Created:** 2026-07-11
> **Test prefix:** `F15`

## Scope

Deterministic, fixture-based coverage for scoped release pins, local proof links, canonical proof-repository URLs, actionable failures, no-network private mode, and read-only execution. Live public URL availability is existing behavior, not asserted as deterministic.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | F15-001 | Current first-15 pins match the canonical version | Integration | Scoped tags equal `v${AGTOOSA_VERSION}` | ⬜ Not run |
| AC-001, AC-004 | F15-002 | A stale release pin fails with exact diagnostics | Negative fixture | Non-zero exit names file, stale tag, and expected tag | ⬜ Not run |
| AC-002 | F15-003 | Relative proof links resolve from their documents | Integration/fixture | Every scoped relative target exists; a missing fixture target fails | ⬜ Not run |
| AC-003 | F15-004 | First-15 proof repository URL is canonical | Consistency | README, proof docs, and checker contain one normalized URL | ⬜ Not run |
| AC-004 | F15-005 | Multiple maintenance findings remain actionable | Negative fixture | Accumulated output identifies each file and observed/expected value | ⬜ Not run |
| AC-005 | F15-006 | Private maintenance mode is offline | Security/regression | Network shim is never invoked in private mode | ⬜ Not run |
| AC-005 | F15-007 | Public mode retains availability checks | Regression | Existing anonymous URL checks run only after deterministic checks pass | ⬜ Not run |
| AC-006 | F15-008 | Maintenance gate is read-only and flow-neutral | Integrity | Scoped file hashes and onboarding step order are unchanged after the check | ⬜ Not run |

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

## RED Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-078|F15-"` | Not recorded | Not run; deterministic maintenance assertions are pending |
| 2. Deterministic maintenance checks | `bats tests/agtoosa.bats -f "F15-001|F15-002|F15-003|F15-004|F15-005|F15-006|F15-007|F15-008"` | Not recorded | Not run; checker behavior is pending |
| 3. Repair current drift only | `bats tests/agtoosa.bats -f "F15-001|F15-003|F15-004|F15-008"` | Not recorded | Not run; scoped documentation drift is not yet repaired |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-078|F15-"` | Not recorded | Not run; final evidence pending |

## GREEN Evidence — Unexecuted Placeholders

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-078|F15-"` | Not recorded | Not run |
| 2. Deterministic maintenance checks | `bats tests/agtoosa.bats -f "F15-001|F15-002|F15-003|F15-004|F15-005|F15-006|F15-007|F15-008"` | Not recorded | Not run |
| 3. Repair current drift only | `bats tests/agtoosa.bats -f "F15-001|F15-003|F15-004|F15-008"` | Not recorded | Not run |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-078|F15-"` | Not recorded | Not run |

No test or network check has been executed for this backlog story.
