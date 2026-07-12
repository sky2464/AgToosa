# Test Plan: DEV-102 — Offline and Network-Dependency Matrix

> **Spec:** `docs/archived/spec-DEV-102.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `NET`

## Scope

Single canonical CLI network-dependency matrix: offline, network-required, and network-optional classes; offline fallbacks; required command coverage; Agent/Registry cross-links; drift detection when commands change.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | NET-001 | Canonical Matrix Document Present | Docs contract | `AgToosa_Network_Matrix.md` exists with bash and PowerShell columns | Planned `@smoke` |
| AC-002 | NET-002 | Dependency Class Per Command | Docs contract | Each listed command has exactly one dependency class | Planned `@smoke` |
| AC-003 | NET-003 | Offline Fallback Documented | Docs contract | Network-optional rows name cache/local-pack or private-mode fallback | Planned |
| AC-004 | NET-004 | Required Command Coverage | Docs contract | install, update, verify, doctor, registry, catalog, readiness modes listed | Planned |
| AC-005 | NET-005 | Agent and Registry Cross-Links | Docs contract | Agent/Registry link to matrix; no duplicate competing tables | Planned |
| AC-006 | NET-006 | Matrix Drift Detection | Negative fixture | New CLI command without matrix row fails coverage test | Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Registry install marked `offline` without local-pack note | NET-003 | Contract failure |
| Duplicate network table in Registry body | NET-005 | Non-duplication assertion fails |
| `verify` listed as network-required | NET-002 | Class mismatch fails (verify is offline) |

## Smoke Set

- `@smoke NET-001` — canonical matrix present.
- `@smoke NET-002` — dependency class per command.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-102|NET-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED matrix contract | `bats tests/agtoosa.bats -f "DEV-102\|NET-"` | 1 | `AgToosa_Network_Matrix.md` not found |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-102\|NET-"` | 0 | All NET tests pass |
