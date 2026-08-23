# Test Plan: AgToosa Status Guide sub-agent (DEV-006)

> **Spec:** `docs/archived/spec-DEV-006.md`
> **Coverage target:** 100% (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-22

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | StatusGuide doc states read-only status; no file/git mutation during audit | yes |
| AC-002 | T-002 | Unit | StatusGuide doc requires Part 5.5 algorithm (no improvised ordering) | yes |
| AC-003 | T-003 | Unit | StatusGuide doc requires rationale + finding IDs in coach output | yes |
| AC-004 | T-004 | Unit | StatusGuide doc requires explicit user authorization before fix commands | yes |
| AC-005 | T-005 | Unit | StatusGuide doc describes decline path (skip command, next action) | yes |
| AC-006 | T-006 | Integration | Bats: platform 5 install copies `agtoosa-status-guide.agent.md` | yes |
| AC-007 | T-007 | Integration | Bats: S1–S2 Status Guide parity tests pass | no |
| AC-008 | T-008 | Unit | AgToosa_Agent.md lists Status Guide with pointer to AgToosa_StatusGuide.md | no |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Remove “read-only” from StatusGuide → T-001 grep fails |
| T-004-N | Remove “authorization” gate wording → T-004 grep fails |
| T-006-N | Drop agent from lib/config.sh → install test fails |

## Execution Commands

```bash
bats tests/agtoosa.bats -f "S[1-2]|status-guide|Status Guide"
bats tests/agtoosa.bats -f "platform selection 5"
```
