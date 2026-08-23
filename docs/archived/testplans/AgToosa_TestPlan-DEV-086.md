# Test Plan: DEV-086 — Canonical Proof Product Experience

> **Spec:** `docs/archived/spec-DEV-086.md`
> **Status:** 🟢 Build complete — PRF bats GREEN
> **Created:** 2026-07-12
> **Test prefix:** `PRF`

## Scope

Fixture-based coverage for single README proof CTA, first-15 verify success step, golden proof-journey artifacts, extended launch-readiness checks, actionable failures, private no-network mode, and read-only execution. Live public URL availability remains existing public-mode behavior, not asserted as deterministic.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | PRF-001 | README has one primary proof CTA | Docs contract | Single hero CTA routes to canonical proof journey; alternates are secondary | ✅ GREEN |
| AC-001, AC-008 | PRF-002 | Secondary install paths are labeled alternatives | Docs contract | Homebrew/npm/clone paths exist but are not equal primary CTAs | ✅ GREEN |
| AC-002 | PRF-003 | First-15 walkthrough ends on verifier success | Docs contract | Final step runs verifier; exit `0` stated as success condition | ✅ GREEN |
| AC-003 | PRF-004 | Golden proof-journey fixtures match expected markers | Fixture/integration | Manifest lists commands, artifacts, verifier invocation | ✅ GREEN |
| AC-003, AC-005 | PRF-005 | Stale proof-journey fixture fails with diagnostics | Negative fixture | Non-zero exit names file, observed, and expected marker | ✅ GREEN |
| AC-004 | PRF-006 | Launch gate extends proof-journey checks | Integration | Checker validates CTA, verify step, canonical proof URL | ✅ GREEN |
| AC-005 | PRF-007 | Multiple proof findings remain actionable | Negative fixture | Accumulated output identifies each file and observed/expected | ✅ GREEN |
| AC-006 | PRF-008 | Private proof maintenance is offline | Security/regression | Network shim never invoked in private mode | ✅ GREEN |
| AC-007 | PRF-009 | Proof maintenance is read-only and flow-neutral | Integrity | Scoped file hashes and step order unchanged after check | ✅ GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| README regains a second primary install hero | PRF-001 | Contract test fails |
| Walkthrough removes verify step | PRF-003 | PRF-006 maintenance gate fails |
| Proof URL differs only by trailing `.git` or slash | PRF-006 | Normalize allowed suffixes before comparison |
| Two stale proof markers occur together | PRF-007 | Both reported before exit |
| Checker mutates first-15 document | PRF-009 | Hash comparison fails |

## Smoke Set

- `@smoke PRF-001` — single primary proof CTA.
- `@smoke PRF-003` — verifier success step present.
- `@smoke PRF-006` — extended private maintenance gate.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-086|PRF-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Golden fixture RED coverage | `bats tests/agtoosa.bats -f "DEV-086\|PRF-"` | 1 | `not ok 1 PRF-001` missing primary CTA; `not ok 6 PRF-006` no `check_proof_journey_consistency`; 7/9 failed |
| 2. Proof product surfaces | `bats tests/agtoosa.bats -f "PRF-001\|PRF-002\|PRF-003"` | 1 | `PRF-001`/`PRF-002` README contract failures; `PRF-003` missing `bash Docs/agtoosa-verify.sh` |
| 3. Extended maintenance gate | `bats tests/agtoosa.bats -f "PRF-006\|PRF-007\|PRF-008\|PRF-009"` | 1 | `PRF-006`/`PRF-007`/`PRF-005` checker diagnostics missing expected markers |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-086\|PRF-"` | 1 | RED recorded before implementation |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Golden fixture RED coverage | `bats tests/agtoosa.bats -f "DEV-086\|PRF-"` | 0 | `1..9` all `ok` |
| 2. Proof product surfaces | `bats tests/agtoosa.bats -f "PRF-001\|PRF-002\|PRF-003"` | 0 | `ok 1` through `ok 3` |
| 3. Extended maintenance gate | `bats tests/agtoosa.bats -f "PRF-006\|PRF-007\|PRF-008\|PRF-009"` | 0 | `ok 6` through `ok 9`; private checker prints `proof-journey maintenance complete` |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-086\|PRF-"` | 0 | `1..9` all `ok`; `bash scripts/check-launch-readiness.sh --mode private` exit 0 |
