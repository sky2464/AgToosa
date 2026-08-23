# Test Plan — DEV-062 AgToosa Gate CI workflow template

> Spec reference: `docs/archived/spec-DEV-062.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | VF-005, WC-011 | Integration/Security | ✅ green |
| AC-002 | VF-005, WC-011 | Integration/Docs contract | ✅ green |
| AC-003 | VF-005, WC-011 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-062
Command: bats tests/agtoosa.bats -f "DEV-062" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-062
Command: bats tests/agtoosa.bats -f "DEV-062"
Exit code: 0

## Smoke set

@smoke VF-005
