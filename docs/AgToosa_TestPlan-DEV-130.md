# Test Plan: DEV-130 — BCL Hardening & CI Wiring

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | BCL-002 | Integration | Corpus index validates via jsonschema against `scenario-corpus-v1.schema.json` | yes |
| AC-002 | BCL-003, BCL-015 | Integration | Pilot run JSON validates via jsonschema; all six platforms covered | yes / no |
| AC-003 | BCL-014 | Integration | Tampered run JSON fails schema validation with non-zero exit | no |
| AC-004 | BCL-015 | Integration | Each of six platform dirs contains `scenario-run.json` | no |
| AC-005 | CI | Integration | `.github/workflows/ci.yml` fast filter includes `BCL` | no |
| AC-006 | CI | Integration | Validate job installs jsonschema before BCL bats | no |
| AC-007 | Manual | Docs | `AgToosa_TestPlan-DEV-121.md` matches R1 model | no |
| AC-008 | BCL-014–015 | Regression | New BCL tests green in full bats suite | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| BCL-014-N | Remove required field from cursor `scenario-run.json` in temp copy | `scenario_validate_run_json` exits non-zero |
