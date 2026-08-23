# Test Plan: DEV-014 — Cursor Slash Command Routing

> **Spec:** `docs/archived/spec-DEV-014.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "CU[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (CU1) | Integration | Every Cursor command adapter includes native `/agtoosa-*` workflow routing and no-`/create-skill` wording | yes |
| AC-002 | T-002 (CU2) | Integration | Cursor `agtoosa-status` command delegates to `Docs/AgToosa_Status.md`, remains read-only, and lists status sub-commands | yes |
| AC-003 | T-003 (CU3) | Integration | Cursor core/status rules reserve `/agtoosa-*` and forbid `/create-skill` routing | yes |
| AC-004 | T-004 (CU4) | Integration | Skill synthesis docs reject Cursor command collisions and `/agtoosa-*` duplicate triggers | yes |
| AC-005 | T-005 (CU5) | Integration | Cursor platform install copies `.cursor/commands/agtoosa-status.md` with guardrails intact | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| T-001-N | Remove no-`/create-skill` wording from a Cursor command file -> CU1 fails |
| T-002-N | Remove `Docs/AgToosa_Status.md` from `agtoosa-status.md` -> CU2 fails |
| T-003-N | Remove reserved `/agtoosa-*` wording from `agtoosa-core.mdc` -> CU3 fails |
| T-004-N | Remove Cursor command-collision text from skill synthesis docs -> CU4 fails |
| T-005-N | Remove `.cursor/commands/agtoosa-status.md` from Cursor install inventory -> CU5 fails |

## Commands

```bash
# Narrow DEV-014 filter first
bats tests/agtoosa.bats -f "CU[1-5]:"

# Full regression after targeted pass
bats tests/agtoosa.bats
```
