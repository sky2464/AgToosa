# Test Plan: DEV-048 - Agent Result Import Gate

> **Spec:** `docs/archived/spec-DEV-048.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-048"`
> **Status:** ✅ Done

## Coverage Target

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | IR-001 | Docs | Import Checklist fields present dual-path | yes @smoke |
| AC-002 | IR-001 | Docs | IMPORT evidence + Evidence Mapping | yes @smoke |
| AC-003 | IR-002 | Docs | agent-instructed + verification language; Readiness/Roadmap rows | yes @smoke |
| AC-004 | IR-003 | Docs | Build External/async detection before tracking | yes @smoke |
| AC-005 | IR-005 | Docs | Ship soft External agent evidence row | yes |
| AC-006 | IR-004, IR-005 | Integration | Adapters + config registration | yes @smoke |

Negative / edge: IR-004 asserts adapters do **not** duplicate Import Checklist body.

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-048"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

### RED evidence — DEV-048

Command: `bats tests/agtoosa.bats -f "DEV-048 IR"` (contract assertions before implementation)
Expected: FAIL on missing Import docs / Build wiring (pre-implementation).

### GREEN evidence — DEV-048

Command: `bats tests/agtoosa.bats -f "DEV-048"`
Recorded: 2026-07-08 — IR-001–IR-005 + CW-011 green after docs-first implementation.
