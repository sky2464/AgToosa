# Test Plan — DEV-115 `--cleanup` Safety Follow-Up

> **Story:** DEV-115  
> **Tests:** CLN-015–CLN-017 in `tests/agtoosa.bats`

| ID | AC | Test | Command |
|----|-----|------|---------|
| CLN-015 | AC-003 | Neither copilot nor vscode — shared prompts flagged | `bats -f CLN-015` |
| CLN-016 | AC-001 | `--only backups` skips orphan categories | `bats -f CLN-016` |
| CLN-017 | AC-002 | Deselected claude preserves `.claude/settings.json` | `bats -f CLN-017` |

## GREEN evidence

```bash
bats tests/agtoosa.bats -f "CLN-"
# 17/17 PASS (2026-07-12)
```
