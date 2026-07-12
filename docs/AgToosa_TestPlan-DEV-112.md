# Test Plan — DEV-112 `--cleanup` Executable

> **Story:** DEV-112  
> **Tests:** CLN-001–CLN-011 in `tests/agtoosa.bats`

| ID | AC | Test | Command |
|----|-----|------|---------|
| CLN-001 | AC-001, AC-005 | Dry-run lists backups | `bats -f CLN-001` |
| CLN-002 | AC-002 | Orphan workflow doc in plan | `bats -f CLN-002` |
| CLN-003 | AC-003 | Deselected platform files | `bats -f CLN-003` |
| CLN-004 | AC-002 | Preserved docs excluded | `bats -f CLN-004` |
| CLN-005 | AC-004 | `--yes` removes candidates | `bats -f CLN-005` |
| CLN-006 | AC-004 | Non-TTY refuses apply | `bats -f CLN-006` |
| CLN-007 | AC-005 | JSON `cleanup-result-v1` | `bats -f CLN-007` |
| CLN-008 | AC-008 | PS1 `-Cleanup` parity | `bats -f CLN-008` |
| CLN-009 | AC-006 | Help + Update docs | `bats -f CLN-009` |
| CLN-010 | AC-005 | Schema ships in template | `bats -f CLN-010` |
| CLN-011 | AC-009 | VS Code-only not orphan | `bats -f CLN-011` |

## GREEN evidence

```bash
bats tests/agtoosa.bats -f "DEV-112|CLN-"
# 11/11 PASS (2026-07-12)
```
