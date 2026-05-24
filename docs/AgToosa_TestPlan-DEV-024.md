# Test Plan: DEV-024 — Maintainer Status Readiness Doc Parity

> **Spec:** `docs/archived/spec-DEV-024.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-24

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 (MD1, MD4) | Integration | `docs/AgToosa_Status.md` defines readiness sub-command, Part 1.5, and seven gates consistent with template | yes |
| AC-002 | T-002 (MD2) | Integration | `docs/AgToosa_Readiness.md` exists with seven-gate table and maintainer version-parity gate | yes |
| AC-003 | T-003 (MD3) | Integration | Maintainer Dogfood Mode callout; no generic Generated Project Mode-only wording | yes |
| AC-004 | T-004 (MD1–MD5) | Integration | MD1–MD5 bats section exists and passes | yes |
| AC-005 | T-005 (manual) | Integration | Full `/agtoosa-status` includes Initial Product Readiness table (manual dogfood check at review) | no |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Remove Part 1.5 from `docs/AgToosa_Status.md` → MD1 fails |
| T-002-N | Delete `docs/AgToosa_Readiness.md` → MD2 fails |
| T-003-N | Reintroduce Generated Project Mode-only callout without maintainer pointer → MD3 fails |
| T-004-N | Remove readiness from Part 5.5 mapping in maintainer status doc → MD4 fails |

## Execution Commands

```bash
bats tests/agtoosa.bats -f "MD[1-5]:"
bats tests/agtoosa.bats
```
