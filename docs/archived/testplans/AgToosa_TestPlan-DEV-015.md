# Test Plan: DEV-015 — Windsurf Slash Command Routing

> **Spec:** `docs/archived/spec-DEV-015.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "WS[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (WS1) | Integration | Every Windsurf workflow adapter includes native `/agtoosa-*` workflow routing and no-`/create-skill` wording | yes |
| AC-002 | T-002 (WS2) | Integration | Windsurf `agtoosa-status` workflow delegates to `Docs/AgToosa_Status.md`, remains read-only, lists status sub-commands | yes |
| AC-003 | T-003 (WS3) | Integration | Windsurf core/status rules reserve `/agtoosa-*` and forbid `/create-skill` routing | yes |
| AC-004 | T-004 (WS4) | Integration | Skill synthesis docs reject Windsurf workflow collisions and `/agtoosa-*` duplicate triggers | yes |
| AC-005 | T-005 (WS5) | Integration | Windsurf platform install copies `.windsurf/workflows/agtoosa-status.md` with guardrails intact | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| T-001-N | Remove no-`/create-skill` wording from a Windsurf workflow file → WS1 fails |
| T-002-N | Remove `Docs/AgToosa_Status.md` from `agtoosa-status.md` → WS2 fails |
| T-003-N | Remove reserved `/agtoosa-*` wording from `agtoosa-core.md` → WS3 fails |
| T-004-N | Remove Windsurf workflow-collision text from skill synthesis docs → WS4 fails |
| T-005-N | Remove `.windsurf/workflows/agtoosa-status.md` from Windsurf install inventory → WS5 fails |

## Commands

```bash
# Narrow DEV-015 filter first
bats tests/agtoosa.bats -f "WS[1-5]:"

# Full regression after targeted pass
bats tests/agtoosa.bats
```
