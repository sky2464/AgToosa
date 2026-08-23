# Test Plan: DEV-132 — Preserve Evidence JSONL on Re-install and Update

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | EVJ-001 | Integration | Re-install preserves custom `Docs/agtoosa-evidence.jsonl` content | yes |
| AC-002 | EVJ-002 | Integration | `--update` preserves custom evidence JSONL | yes |
| AC-003 | EVJ-003 | Integration | `--reinstall` preserves custom evidence JSONL | no |
| AC-004 | EVJ-004 | Integration | `--uninstall` retains evidence JSONL | no |
| AC-005 | EVJ-005 | Integration | PowerShell install preserves evidence JSONL | no |
| AC-006 | EVJ-006 | Unit | `lib/plan.sh` classifies evidence JSONL as preserve when present | no |
| AC-007 | All above | Regression | Filter `EVJ-` exits 0 | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| EVJ-001 | Fresh install (no existing jsonl) | Seed/template copy still allowed when file absent |
