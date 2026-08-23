# Test Plan: DEV-017 — Codex AgToosa Slash Discoverability

> **Spec:** `docs/archived/spec-DEV-017.md`
> **Smoke tag:** `@smoke` on CX1–CX5 (Must ACs)

| ID | Test | Tier | Maps to |
|----|------|------|---------|
| CX1 | Every Codex prompt adapter includes routing and no-create-skill | @smoke | AC-001 |
| CX2 | agtoosa-status Codex prompt delegates read-only with sub-commands | @smoke | AC-002 |
| CX3 | OPENCODE.md documents Codex prompts and skills | @smoke | AC-003 |
| CX4 | Skill synthesis docs reject Codex prompt collisions | @smoke | AC-004 |
| CX5 | Codex platform install copies agtoosa-status prompt | @smoke | AC-005 |

```bash
# Narrow DEV-017 filter first
bats tests/agtoosa.bats -f "CX[1-5]:"
```
