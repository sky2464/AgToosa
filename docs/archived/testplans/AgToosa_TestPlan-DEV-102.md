# Test Plan: DEV-102 — Offline and Network-Dependency Matrix

> **Spec:** `docs/archived/spec-DEV-102.md`
> **Status:** 🟩 GREEN — Wave 3 build
> **Created:** 2026-07-12
> **Test prefix:** `NET`

## Scope

Single canonical CLI network-dependency matrix: offline, network-required, and network-optional classes; offline fallbacks; required command coverage; Agent/Registry cross-links; drift detection when commands change.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | NET-001 | Canonical Matrix Document Present | Docs contract | `AgToosa_Network_Matrix.md` exists with bash and PowerShell columns | ✅ GREEN `@smoke` |
| AC-002 | NET-002 | Dependency Class Per Command | Docs contract | Each listed command has exactly one dependency class | ✅ GREEN `@smoke` |
| AC-003 | NET-003 | Offline Fallback Documented | Docs contract | Network-optional rows name cache/local-pack or private-mode fallback | ✅ GREEN |
| AC-004 | NET-004 | Required Command Coverage | Docs contract | install, update, verify, doctor, registry, catalog, readiness modes listed | ✅ GREEN |
| AC-005 | NET-005 | Agent and Registry Cross-Links | Docs contract | Agent/Registry link to matrix; no duplicate competing tables | ✅ GREEN |
| AC-006 | NET-006 | Matrix Drift Detection | Negative fixture | New CLI command without matrix row fails coverage test | ✅ GREEN |

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

```
RED evidence — 1.1 / 1.2
Command: bats tests/agtoosa.bats -f "DEV-102|NET-"
Exit code: 1
Failure excerpt: not ok NET-001…NET-006 — `[ -f "$f" ]' failed / AgToosa_Network_Matrix.md not found;
NET-005 Agent/Registry missing AgToosa_Network_Matrix.md link
```

## GREEN Evidence

```
GREEN evidence — 2.1 / 2.2 / 3.1
Command: bats tests/agtoosa.bats -f "DEV-102|NET-"
Exit code: 0
Pass excerpt: ok 1–6 NET-001–NET-006
Also green: CORE-001–007, NAV-001–008, TRUST-001–006 (no index/DOCS_FILES regressions)
```
