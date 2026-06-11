# Test Plan — DEV-073 Onboarding: doctor, uninstall, README consolidation

> Spec reference: `docs/archived/spec-DEV-073.md`
> Consolidated wave evidence: `docs/AgToosa_TestPlan-DEV-061-073.md`

## AC coverage table

| AC | Test ID(s) | Category | Status |
|----|-----------|----------|--------|
| AC-001 | DR-001, UN-001, WC-011 | Integration/Security | ✅ green |
| AC-002 | DR-001, UN-001, WC-011 | Integration/Docs contract | ✅ green |
| AC-003 | DR-001, UN-001, WC-011 | Regression | ✅ green |

## TDD evidence

RED evidence — DEV-073
Command: bats tests/agtoosa.bats -f "DEV-073" (contract assertions authored before the implementing change; see also the wave RED record in AgToosa_TestPlan-DEV-061-073.md)
Exit code: 1 (initial run against pre-change tree)
Failure excerpt: new assertions failed until the owning surface was changed.

GREEN evidence — DEV-073
Command: bats tests/agtoosa.bats -f "DEV-073"
Exit code: 0

## Smoke set

@smoke DR-001
