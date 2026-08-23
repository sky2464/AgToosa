# Test Plan: DEV-016 — Gemini Slash Command Routing

> **Spec:** `docs/archived/spec-DEV-016.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "GM[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (GM1) | Integration | Every Gemini TOML adapter includes native `/agtoosa-*` command routing and no-`/create-skill` wording | yes |
| AC-002 | T-002 (GM2) | Integration | Gemini `agtoosa-status` command delegates to `Docs/AgToosa_Status.md`, remains read-only, lists status sub-commands | yes |
| AC-003 | T-003 (GM3) | Integration | `AGENTS.md` reserves `/agtoosa-*` and forbids `/create-skill` routing | yes |
| AC-004 | T-004 (GM4) | Integration | Skill synthesis docs reject Gemini command collisions and `/agtoosa-*` duplicate triggers | yes |
| AC-005 | T-005 (GM5) | Integration | Gemini platform install (option 4) copies `.gemini/commands/agtoosa-status.toml` with guardrails intact | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| T-001-N | Remove no-`/create-skill` wording from a Gemini TOML file → GM1 fails |
| T-002-N | Remove `Docs/AgToosa_Status.md` from `agtoosa-status.toml` → GM2 fails |
| T-003-N | Remove reserved `/agtoosa-*` wording from `AGENTS.md` → GM3 fails |
| T-004-N | Remove Gemini command-collision text from skill synthesis docs → GM4 fails |
| T-005-N | Remove `.gemini/commands/agtoosa-status.toml` from Gemini install inventory → GM5 fails |

## Commands

```bash
# Narrow DEV-016 filter first
bats tests/agtoosa.bats -f "GM[1-5]:"

# Full regression after targeted pass
bats tests/agtoosa.bats
```
