# Test Plan — DEV-114 `--cleanup` False-Positive Hotfix

> **Story:** DEV-114  
> **Tests:** CLN-012–CLN-014 in `tests/agtoosa.bats`

| ID | AC | Test | Command |
|----|-----|------|---------|
| CLN-012 | AC-001 | Copilot selected, vscode absent — prompts not orphans | `bats -f CLN-012` |
| CLN-013 | AC-003, AC-004 | TestPlan preserved; legacy orphan still flagged | `bats -f CLN-013` |
| CLN-014 | AC-002 | Copilot + vscode both selected — no orphan prompts | `bats -f CLN-014` |

## miToosa recovery (manual verification)

```bash
bash agtoosa.sh --cleanup /path/to/miToosa --dry-run
# Expect: no AgToosa_TestPlan-* in plan; no vscode orphan_platform for agtoosa prompts when copilot in lock
```

## GREEN evidence

```bash
bats tests/agtoosa.bats -f "CLN-"
# 14/14 PASS (2026-07-12)
```
