# Test Plan: DEV-125 — /agtoosa-next Lifecycle Dispatcher (A+B Hybrid)

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | NXT-001 | Unit | AgToosa_Next mandates route-hint json | yes |
| AC-002 | NXT-002 | Unit | Build approval override documented | yes |
| AC-003 | NXT-003 | Unit | Single-phase dispatch | yes |
| AC-004 | NXT-004 | Unit | Idle backlog scan | yes |
| AC-005 | NXT-005 | Unit | Cold-start recommendations | yes |
| AC-006 | NXT-006 | Unit | dry sub-command | yes |
| AC-007 | NXT-007 | Integration | product-truth + six targets | yes |
| AC-008 | NXT-008 | Regression | help-next previews + handoff to next | yes |
| AC-009 | NXT-009 | Integration | AgToosa_Next in template file lists | yes |
| AC-011 | NXT-010 | Unit | Quickref Day 1 = init + next | yes |
| AC-012 | NXT-011 | CLI | route-hint JSON includes spec_approved | yes |
| AC-013 | NXT-012 | Unit | Tributary intents documented | yes |

```bash
bats tests/agtoosa.bats -f "NXT-"
bats tests/agtoosa.bats -f "H[4-7]"
```
