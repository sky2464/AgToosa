# Test Plan — DEV-064 Safe tar extraction

> Spec reference: `docs/archived/spec-DEV-064.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | SC-001, SC-005, PS-002 | Integration/Security | ✅ green |
| AC-002 | SC-001, SC-005, PS-002 | Integration/Docs contract | ✅ green |
| AC-003 | SC-001, SC-005, PS-002 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-064
Command: bats tests/agtoosa.bats -f "DEV-064" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-064
Command: bats tests/agtoosa.bats -f "DEV-064"
Exit code: 0

## Smoke set

@smoke SC-001
