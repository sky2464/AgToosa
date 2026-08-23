# Test Plan: DEV-126 — Spec Interview Hardening

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-005 | DEV-126 T-001 | Unit | User prompt ≠ interview complete in canonical spec | yes |
| AC-001 | DEV-126 T-002 | Unit | Minimum validation floor 2/1 in canonical spec | yes |
| AC-003 | DEV-126 T-003 | Unit | Interview turn-stop in canonical spec | yes |
| AC-004 | DEV-126 T-004 | Unit | SPEC-FORMAT findings section | yes |
| AC-001 | DEV-126 T-005 | Unit | AgToosa_Agent Smart Interview floor + turn-stop | yes |
| AC-006 | DEV-126 T-006 | Unit | Cursor adapter execution contract | yes |
| AC-006 | DEV-126 T-007 | Unit | Codex skill forbidden skips | yes |
| AC-006 | DEV-126 T-008 | Unit | Maintainer Cursor adapter parity | yes |

```bash
bats tests/agtoosa.bats -f "DEV-126"
```
