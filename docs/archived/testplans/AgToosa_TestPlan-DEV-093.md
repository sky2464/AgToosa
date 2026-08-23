# Test Plan: DEV-093 — Install State File + Lock Reconciliation

> **Spec:** `docs/archived/spec-DEV-093.md`
> **Status:** ✅ GREEN — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `STF`

## Scope

Fixture-based coverage for `.agtoosa/state.json` write semantics, gitignore contract, `Docs/agtoosa-lock.json` reconciliation, ADR-004 schema fields, pack SHA revalidation failure, authority separation, and post-apply hash inventory.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | STF-001 | Successful apply writes state.json | Integration | State contains version, platforms, packs, hashes, timestamp, command | ✅ GREEN `@smoke` |
| AC-002 | STF-002 | State file is gitignored not templated | Contract | `.gitignore` covers `.agtoosa/state.json`; not in `lib/config.sh` file lists | ✅ GREEN `@smoke` |
| AC-003 | STF-003 | Lock platforms and packs reconcile after apply | Integration | Lock `platforms[]` and pack rows match selection | ✅ GREEN `@smoke` |
| AC-004 | STF-004 | First install creates Docs/agtoosa-lock.json | Integration | Lock at `Docs/agtoosa-lock.json` with required ADR-004 fields | ✅ GREEN |
| AC-005 | STF-005 | Pack SHA mismatch aborts before state write | Negative | Bad SHA → non-zero exit; no state.json update | ✅ GREEN `@smoke` |
| AC-006 | STF-006 | Manual edit reflected in state hashes on next apply | Integration | Changed file hash updates; lock version unchanged if pins same | ✅ GREEN |
| AC-007 | STF-007 | Authority separation state vs lock | Contract | State holds `generated_file_hashes`; lock holds reproducibility pins | ✅ GREEN |
| AC-008 | STF-008 | Update doc cites authority table | Docs | `AgToosa_Update.md` lists three-surface table | ✅ GREEN |
| AC-003, AC-004 | STF-009 | DEV-093 filter and lock path regression | Meta | No `.agtoosa-lock.json` root path in writer | ✅ GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Corrupt existing state.json | STF-001 | Recreate or WARN; apply still succeeds |
| Lock manually edited platforms | STF-003 | Reconcile restores generator truth or reports drift |
| Apply with zero pack changes | STF-003 | Lock pack array unchanged except `installed_at` if touched |

## Smoke Set

- `@smoke STF-001` — state written on apply.
- `@smoke STF-002` — gitignored not templated.
- `@smoke STF-003` — lock reconcile.
- `@smoke STF-005` — SHA mismatch abort.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-093|STF-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED fixtures | `bats tests/agtoosa.bats -f "DEV-093\|STF-"` | 1 | `not ok 1 DEV-093 @smoke STF-001: Successful apply writes state.json`; `lib/state.sh: No such file`; STF-004 lock missing; STF-008 missing `.agtoosa/state.json` in Update doc |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Implementation | `bats tests/agtoosa.bats -f "DEV-093\|STF-"` | 0 | `ok 1` through `ok 9` (9 tests, 2026-07-12) |
| 3. Docs | `bats tests/agtoosa.bats -f "STF-008"` | 0 | Authority table present in Update doc |
| Regression | `bats tests/agtoosa.bats -f "DEV-092 TAP-\|TAP-"` | 0 | TAP-001–TAP-008 still green |
