# Test Plan — DEV-111 Smart One-Command Install UX

> **Story:** DEV-111  
> **Tests:** SAU-001–SAU-010 in `tests/agtoosa.bats`

| ID | AC | Test | Command |
|----|-----|------|---------|
| SAU-001 | AC-001 | Re-run enters upgrade mode | `bats -f SAU-001` |
| SAU-002 | AC-002 | Enter keeps detected Cursor | `bats -f SAU-002` |
| SAU-003 | AC-002 | Union add platform 3 | `bats -f SAU-003` |
| SAU-004 | AC-005 | Populated Context preserved | `bats -f SAU-004` |
| SAU-005 | AC-005 | Placeholder Context refreshed | `bats -f SAU-005` |
| SAU-006 | AC-006 | Summary buckets, no --force hint | `bats -f SAU-006` |
| SAU-007 | AC-004 | Master-Plan preserve in plan | `bats -f SAU-007` |
| SAU-008 | AC-006 | Merge count in summary | `bats -f SAU-008` |
| SAU-009 | AC-007 | --force CI path | `bats -f SAU-009` |
| SAU-010 | AC-003 | --update vs plain parity | `bats -f SAU-010` |

## GREEN evidence

```bash
bats tests/agtoosa.bats -f "SAU-"
# 10/10 PASS (2026-07-12)
```
