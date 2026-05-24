# Test Plan: DEV-013 — Ship Check Cleanup

> **Spec:** `docs/archived/spec-DEV-013.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-24

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 (C1) | Integration | Ship docs define `/agtoosa-ship check` as a read-only readiness audit that stops after reporting | yes |
| AC-002 | T-002 (C1) | Integration | Maintainer and template ship docs both include the same Goal Contract and readiness-gate checks | yes |
| AC-003 | T-003 (C2, C3) | Integration | Native ship adapters delegate `check` to Part 0 and avoid deployment/archive/mutation wording | yes |
| AC-004 | T-004 (C4) | Integration | Failed readiness checks require a remediation command or manual action | yes |
| AC-005 | T-005 (C5) | Integration | Full `/agtoosa-ship` still runs Part 0 before deploy approval | no |
| AC-006 | T-006 (C1-C5) | Integration | Focused C-series bats coverage exists and runs as the DEV-013 smoke suite | yes |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Remove read-only wording from `/agtoosa-ship check` docs -> C1 fails |
| T-002-N | Remove Goal Contract verification from `docs/AgToosa_Ship.md` while leaving it in the template -> C1 fails |
| T-003-N | Reintroduce "pre-flight checks only" in a native ship adapter -> C3 fails |
| T-004-N | Remove remediation-command/manual-action wording from the readiness failure path -> C4 fails |
| T-005-N | Move deployment approval before Part 0 readiness gate -> C5 fails |

## Execution Commands

```bash
# Narrow DEV-013 filter first
bats tests/agtoosa.bats -f "C[1-5]:"

# Full suite when environment allows
bats tests/agtoosa.bats
```

**Evidence note:** Record the C1-C5 focused result in the review report. If the full suite is blocked by local environment constraints, include the exact failed command and residual failure summary in the review/ship notes.
