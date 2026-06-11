# Test Plan — DEV-065 Registry pack containment

> Spec reference: `docs/archived/spec-DEV-065.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | SC-002, SC-003, SC-004, PS-001 | Integration/Security | ✅ green |
| AC-002 | SC-002, SC-003, SC-004, PS-001 | Integration/Docs contract | ✅ green |
| AC-003 | SC-002, SC-003, SC-004, PS-001 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-065
Command: bats tests/agtoosa.bats -f "DEV-065" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-065
Command: bats tests/agtoosa.bats -f "DEV-065"
Exit code: 0

## Smoke set

@smoke SC-002
