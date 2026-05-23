# Test Plan: /agtoosa-help next on-demand assistance helper (DEV-007)

> **Spec:** `docs/archived/spec-DEV-007.md`
> **Coverage target:** 100% (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-23

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 | Unit | Plain `/agtoosa-help` remains static command reference, not status-driven | yes |
| AC-002 | T-002 | Unit | `/agtoosa-help next` recommends exactly one next command with rationale | yes |
| AC-003 | T-003 | Unit | Help-next wording states read-only and no file/git/Master-Plan mutation | yes |
| AC-004 | T-004 | Unit | Help-next wording says mutating commands are suggestions only and not auto-run | yes |
| AC-005 | T-005 | Integration | Help-next appears in Claude, Gemini, GitHub, Cursor core, and Windsurf core surfaces | yes |
| AC-006 | T-006 | Unit | Empty active cycle maps to `/agtoosa-spec` recommendation | yes |
| AC-007 | T-007 | Unit | Reviewed complete story maps to `/agtoosa-ship` recommendation | no |
| AC-008 | T-008 | Unit | CHANGELOG Planned item is removed when DEV-007 ships | no |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Plain help starts reading status context -> grep for static/default wording fails |
| T-003-N | Remove read-only/no mutation wording -> help-next content test fails |
| T-004-N | Add auto-run wording -> suggestion-only test fails |
| T-005-N | Forget Cursor/Windsurf fallback -> parity matrix fails |

## Execution Commands

```bash
bats tests/agtoosa.bats -f "help-next|agtoosa-help next|H[1-3]"
bats tests/agtoosa.bats
```
