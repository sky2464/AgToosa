# Test Plan: DEV-096 — Pack Validation CI

> **Spec:** `docs/archived/spec-DEV-096.md`
> **Status:** ✅ GREEN
> **Created:** 2026-07-12
> **Test prefix:** `PV`

## Scope

Deterministic pack validation CI: workflow path filters, catalog manifest validation, fixture SHA drift detection, fixture-tree parity, focused OPP bats execution, actionable failures, and offline-safe validation mode.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | PV-001 | Pack Validate Workflow Path Filters | CI contract | Workflow triggers on official pack and fixture path changes | ✅ GREEN `@smoke` |
| AC-002 | PV-002 | Manifest Validation Gate | Integration | Invalid manifest exits non-zero via `--catalog validate` | ✅ GREEN `@smoke` |
| AC-003 | PV-003 | Fixture SHA Drift Detection | Negative fixture | Stale SHA metadata fails with pack, file, observed, and expected digest | ✅ GREEN |
| AC-004 | PV-004 | Fixture Tree Parity | Negative fixture | Missing or extra fixture file fails with path diagnostics | ✅ GREEN |
| AC-005 | PV-005 | OPP Bats Invoked In Workflow | CI contract | Workflow step runs `bats tests/agtoosa.bats -f "OPP"` and propagates exit code | ✅ GREEN `@smoke` |
| AC-006 | PV-006 | Actionable Validation Failures | Negative fixture | Multiple findings report pack name and file before exit | ✅ GREEN |
| AC-007 | PV-007 | Validation Mode Stays Offline-Safe | Security/regression | No unexpected registry network fetch beyond existing OPP isolated installs | ✅ GREEN |
| AC-002, AC-003 | PV-008 | Current Pilots Pass Validation | Integration | All three shipped official pilots pass manifest, SHA, parity, and OPP checks | ✅ GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Fixture SHA updated without archive bytes | PV-003 | Non-zero with digest mismatch |
| New pack file not copied to fixture tree | PV-004 | Parity failure names missing path |
| Two drift findings in one run | PV-006 | Both reported before non-zero exit |
| Workflow omits OPP step | PV-005 | Contract test fails |

## Smoke Set

- `@smoke PV-001` — workflow path filters present.
- `@smoke PV-002` — manifest validation gate.
- `@smoke PV-005` — OPP bats wired in workflow.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-096|PV-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-096\|PV-"` | 1 | `not ok` PV-001–PV-008 — missing `pack-validate.yml` and `scripts/validate-official-packs.sh` before GREEN |
| 2. Validation helper and workflow | `bash scripts/validate-official-packs.sh` | 1 | Missing helper (file not found) before GREEN |

RED excerpt (2026-07-12):
```
not ok 13 DEV-096 @smoke PV-001: Pack Validate Workflow Path Filters
#   `[ -f "$wf" ]' failed
not ok 14 DEV-096 @smoke PV-002: Manifest Validation Gate
#   `[ -f "$validator" ]' failed
… (PV-003–PV-008 same missing-file failures)
```

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-096\|PV-"` | 0 | All PV-001–PV-008 pass (filter also matches DEV-033 PV / EPV; those remain green) |
| 3. Evidence | `bats tests/agtoosa.bats -f "OPP"` | 0 | OPP-001–OPP-010 + PV-005 (name contains OPP) green under pack gate |
| 3. Evidence | `bash scripts/validate-official-packs.sh --mode private` | 0 | Three pilots: Catalog valid + sha + Docs/ parity |

GREEN excerpt (2026-07-12):
```
ok 13 DEV-096 @smoke PV-001: Pack Validate Workflow Path Filters
… ok 20 DEV-096 PV-008: Current Pilots Pass Validation
FILTER_EXIT:0
OPP_EXIT:0
VALIDATE_EXIT:0
Pack validation passed for 3 official pack(s)
```
