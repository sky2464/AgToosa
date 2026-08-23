# Test Plan — DEV-071 Non-interactive CLI and npm distribution

> Spec reference: `docs/archived/spec-DEV-071.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | NI-001, NI-002, SC-007 | Integration/Security | ✅ green |
| AC-002 | NI-001, NI-002, SC-007 | Integration/Docs contract | ✅ green |
| AC-003 | NI-001, NI-002, SC-007 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-071
Command: bats tests/agtoosa.bats -f "DEV-071" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-071
Command: bats tests/agtoosa.bats -f "DEV-071"
Exit code: 0

## Smoke set

@smoke NI-001
