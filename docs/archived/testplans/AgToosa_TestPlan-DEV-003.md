# Test Plan: DEV-003 — Registry Prod-Readiness

> **Spec:** `docs/archived/spec-DEV-003.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "RG[1-8]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | RG3 (partial) | Integration | Case B uses injected markers (verified via re-run stability) | yes |
| AC-002 | T-002 (RG3) | Integration | Two `--update` passes leave one AgToosa START block | yes |
| AC-003 | T-003 (RG2) | Integration | `registry info` unknown pack exits non-zero | yes |
| AC-004 | T-004 (RG4) | Integration | `registry search` prints no-results for non-matching query | yes |
| AC-005 | T-005 (RG5) | Unit | `registry_publish` JSON built with jq survives quotes in pack name | yes |
| AC-006 | T-006 (RG6) | Integration | PS1 registry list parses single-entry flat array fixture | yes |
| AC-007 | T-007 (RG1–RG8 suite) | Regression | DEV-003 RG-filter defined (8 tests) | yes |
| AC-008 | T-001 (RG1) | Security | Crafted jq probe in `registry_search` does not crash | yes |

## Negative / Edge Scenarios

| ID | Scenario |
|----|----------|
| RG1-N | Revert `jq --arg` in search → RG1 fails |
| RG3-N | Remove `inject_version` from Case B → second update duplicates START blocks |
| RG2-N | Allow empty jq output in info → unknown pack exits 0 |
| RG5-N | Revert publish to printf → quote in pack name breaks JSON |

## Commands

```bash
bats tests/agtoosa.bats -f "RG[1-8]:"
bats tests/agtoosa.bats
```
