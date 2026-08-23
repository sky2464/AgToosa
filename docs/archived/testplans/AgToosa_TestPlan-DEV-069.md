# Test Plan — DEV-069 Governance gate wiring

> Spec reference: `docs/archived/spec-DEV-069.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | WC-007, WC-008 | Integration/Security | ✅ green |
| AC-002 | WC-007, WC-008 | Integration/Docs contract | ✅ green |
| AC-003 | WC-007, WC-008 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-069
Command: bats tests/agtoosa.bats -f "DEV-069" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-069
Command: bats tests/agtoosa.bats -f "DEV-069"
Exit code: 0

## Smoke set

@smoke WC-007
