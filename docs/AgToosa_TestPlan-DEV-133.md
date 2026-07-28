# Test Plan: DEV-133 — GitHub Branch Hygiene for Cursor Agent Sprawl

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | BRH-001 | Unit | Script exists; `--dry-run` is default; prints usage without `gh` network when listing logic is sourced | yes |
| AC-002 | BRH-002 | Unit | Script defines `--apply`, `--close-prs`, `--prefix` flags | no |
| AC-003 | BRH-003 | Unit | Denylist blocks `main` and `master` in filter function | yes |
| AC-004 | BRH-004 | Docs | `branch-hygiene.yml` workflow exists with schedule + workflow_dispatch | no |
| AC-005 | BRH-005 | Docs | `agtoosa-maintainer.md` documents branch hygiene section | no |
| AC-006 | BRH-006 | Regression | Filter `BRH-` exits 0 | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| BRH-003 | Branch named `main` | Never eligible for deletion |
