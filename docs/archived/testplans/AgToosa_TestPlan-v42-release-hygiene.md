# Test Plan: v4.2.0 Release Hygiene (DEV-005)

> **Spec:** `docs/archived/spec-DEV-005.md`
> **Coverage target:** 100% (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-22

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | M1 bats: SPEC-FORMAT manual lifecycle grep assertions | yes |
| AC-002 | T-002 | Integration | M2 bats: AgToosa_Build Manual Task Detection grep assertions | yes |
| AC-003 | T-003 | Integration | M3 bats: AgToosa_Status manual-deferred exemption grep assertions | yes |
| AC-004 | T-004 | Integration | M4 bats: Master-Plan Manual / Deferred section grep assertion | yes |
| AC-005 | T-005 | Unit | CHANGELOG: Status Guide + help-next bullets under `[Unreleased]` only | yes |
| AC-006 | T-006 | Unit | CHANGELOG: no `### Coming next (4.2.0)` under `[4.1.0]` | no |
| AC-007 | T-007 | Integration | Full bats: D1–D3 + version parity tests remain green | no |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Remove `[manual]` from template SPEC-FORMAT → M1 must fail |
| T-005-N | Duplicate Unreleased bullet in 4.1.0 section → manual review catches duplication |

## Execution Commands

```bash
bats tests/agtoosa.bats -f "M[1-4]"
bats tests/agtoosa.bats -f "D[1-3]|version|maintainer doc"
```
