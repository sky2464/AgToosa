# Test Plan — DEV-066 Pinned install chain

> Spec reference: `docs/archived/spec-DEV-066.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | SC-005, SC-006, SC-007 | Integration/Security | ✅ green |
| AC-002 | SC-005, SC-006, SC-007 | Integration/Docs contract | ✅ green |
| AC-003 | SC-005, SC-006, SC-007 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-066
Command: bats tests/agtoosa.bats -f "DEV-066" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-066
Command: bats tests/agtoosa.bats -f "DEV-066"
Exit code: 0

## Smoke set

@smoke SC-005
