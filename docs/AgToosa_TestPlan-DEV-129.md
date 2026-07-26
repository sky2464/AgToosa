# Test Plan: DEV-129 — Smart Upgrade UX Polish

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | CLN-018 | Integration | Compact cleanup plan groups deselected platforms when ≥10 candidates | yes |
| AC-002 | CLN-019 | Integration | `--cleanup --verbose` lists individual orphan files | no |
| AC-003 | UPG-008 | Integration | Narrowing prompts; cancel preserves lock | no |
| AC-004 | UPG-009 | Integration | Enter keeps all platforms without deselecting prompt | no |
| AC-008 | UPG-008–009, CLN-018–019 | Regression | All four tests green in bats | yes |
