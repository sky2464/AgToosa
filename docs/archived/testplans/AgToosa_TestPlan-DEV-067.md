# Test Plan — DEV-067 Executable workflows with TDD evidence

> Spec reference: `docs/archived/spec-DEV-067.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | WC-001, WC-002, WC-003 | Integration/Security | ✅ green |
| AC-002 | WC-001, WC-002, WC-003 | Integration/Docs contract | ✅ green |
| AC-003 | WC-001, WC-002, WC-003 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-067
Command: bats tests/agtoosa.bats -f "DEV-067" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-067
Command: bats tests/agtoosa.bats -f "DEV-067"
Exit code: 0

## Smoke set

@smoke WC-001
