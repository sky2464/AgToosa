# Test Plan — DEV-061 Deterministic lifecycle verifier

> Spec reference: `docs/archived/spec-DEV-061.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | VF-001, VF-002, VF-003, VF-004, VF-005 | Integration/Security | ✅ green |
| AC-002 | VF-001, VF-002, VF-003, VF-004, VF-005 | Integration/Docs contract | ✅ green |
| AC-003 | VF-001, VF-002, VF-003, VF-004, VF-005 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-061
Command: bats tests/agtoosa.bats -f "DEV-061" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-061
Command: bats tests/agtoosa.bats -f "DEV-061"
Exit code: 0

## Smoke set

@smoke VF-001
