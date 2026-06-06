# Test Plan: DEV-031 — Project-Specific Specialist Subagents

> **Spec:** `docs/archived/spec-DEV-031.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`, default 80% minimum)
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-031|AgToosa_Specialists|specialist|specialists.md"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | `AgToosa_Specialists.md` in `lib/config.sh` `DOCS_FILES` and template tree | yes |
| AC-002 | T-002 | Integration | Canonical doc defines id, trigger, purpose, phase_hooks, inputs, tools/MCP, custom_mode, outputs, validation, safety_notes, platform targets | yes |
| AC-003 | T-003 | Integration | `AgToosa_Init.md` Project Specialist Discovery: platform detect, approval gate, roster path | yes |
| AC-004 | T-004 | Integration | Init/spec/update reject `agtoosa-*`, secrets, one-off, duplicate, unvalidated wording | yes |
| AC-005 | T-005 | Integration | Canonical doc lists `.codex/skills/`, `.claude/skills/`, `.github/agents/`, Cursor/Windsurf/Gemini fallbacks | yes |
| AC-006 | T-006 | Integration | `config.sh` / install inventory does not include `Context/specialists.md` or project specialist skill paths | yes |
| AC-007 | T-007 | Integration | `AgToosa_Update.md` post-Verify specialist proposal separate from baseline CLI update | no |
| AC-008 | T-008 | Integration | `AgToosa_Update.md` check/plan Specialist Compatibility Check read-only | yes |
| AC-009 | T-009 | Integration | `AgToosa_Spec.md` reads `specialists.md`, filters spec phase + trigger | yes |
| AC-010 | T-010 | Integration | Spec doc requires structured evidence block fields | yes |
| AC-011 | T-011 | Integration | Spec doc parallel vs sequential fallback note | yes |
| AC-012 | T-012 | Integration | Spec merge targets: Goal Contract, ACs, architecture, STRIDE, tasks, test plan | no |
| AC-013 | T-013 | Integration | No `template/Docs/Context/specialists.md` and no generic specialist agents/skills in template | yes |
| AC-014 | T-014 | Integration | Adapters reference `AgToosa_Specialists.md`; preserve `/agtoosa-*` routing | yes |
| AC-015 | T-015 | Integration | DEV-031 bats section exists and focused filter passes | yes |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-003-N | Remove approval gate from init specialist discovery | T-003 fails |
| T-004-N | Remove `agtoosa-*` rejection from canonical or init doc | T-004 fails |
| T-006-N | Add `Docs/Context/specialists.md` to `DOCS_FILES` | T-006 fails |
| T-013-N | Add default `specialists.md` under `template/Docs/Context/` | T-013 fails |
| T-014-N | Adapter embeds full discovery table duplicating canonical doc | T-014 fails (manual review + grep heuristics) |

## Smoke Set

T-001, T-002, T-003, T-004, T-005, T-006, T-008, T-009, T-010, T-011, T-013, T-014, T-015

## Regression

- DEV-008 K1–K7 project skill discovery tests must remain green
- DEV-028 plan-mode interview tests unaffected
- Full suite: `bats tests/agtoosa.bats`

## Commands

```bash
# Focused DEV-031
bats tests/agtoosa.bats -f "DEV-031|AgToosa_Specialists|specialist"

# DEV-008 skill discovery regression
bats tests/agtoosa.bats -f "DEV-008|K[1-7]"

# Full suite
bats tests/agtoosa.bats
```

## Evidence (2026-05-25)

| Run | Result |
|-----|--------|
| `bats -f "DEV-031"` | 15/15 pass |
| `bats tests/agtoosa.bats` | 343/344 pass — 1 pre-existing failure: `self-targeting interactive install` (DEV-030 scope, `agtoosa.sh` install path) |
