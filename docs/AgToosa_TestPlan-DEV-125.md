# Test Plan: DEV-125 — /agtoosa-next Lifecycle Dispatcher

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | NXT-001 | Unit | AgToosa_Next.md mandates `--status-line --route-hint --format json` | yes |
| AC-002 | NXT-002 | Unit | AgToosa_Next.md documents build approval override | yes |
| AC-003 | NXT-003 | Unit | AgToosa_Next.md documents single-phase dispatch + Phase Stop | yes |
| AC-004 | NXT-004 | Unit | AgToosa_Next.md documents idle backlog scan | yes |
| AC-005 | NXT-005 | Unit | AgToosa_Next.md documents cold-start recommendations | yes |
| AC-006 | NXT-006 | Unit | `dry` sub-command in workflow + adapters | yes |
| AC-007 | NXT-007 | Integration | product-truth `command.next` + six target cells exist | yes |
| AC-008 | NXT-008 | Regression | help-next remains read-only; distinct from agtoosa-next | yes |

```bash
bats tests/agtoosa.bats -f "NXT-"
```
