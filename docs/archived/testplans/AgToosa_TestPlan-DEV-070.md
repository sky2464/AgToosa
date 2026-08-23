# Test Plan — DEV-070 Token economy restructure

> Spec reference: `docs/archived/spec-DEV-070.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | WC-009 | Integration/Security | ✅ green |
| AC-002 | WC-009 | Integration/Docs contract | ✅ green |
| AC-003 | WC-009 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-070
Command: bats tests/agtoosa.bats -f "DEV-070" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-070
Command: bats tests/agtoosa.bats -f "DEV-070"
Exit code: 0

## Smoke set

@smoke WC-009
