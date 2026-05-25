# Test Plan: DEV-029 — Stop Branch-Protection Workflow Failure Emails

> **Spec:** `docs/archived/spec-DEV-029.md`
> **Coverage target:** workflow contract (structural bats)
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-029"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001, T-002, T-003 | Integration | Push trigger + `push-main-ok` job on push events | yes |
| AC-002 | T-004, T-005 | Integration | PR jobs guarded and label check preserved | yes |
| AC-003 | T-003, T-004 | Integration | Push path does not run PR validation jobs | yes |
| AC-004 | T-001 | Integration | Workflow display name `PR Hygiene Checks` | yes |

## Manual verification (post-merge)

| ID | Scenario | Command / evidence |
|----|----------|-------------------|
| M-001 | Push to `main` succeeds (no “No jobs were run”) | GitHub Actions UI or `gh run list --repo sky2464/AgToosa --workflow branch-protection.yml --limit 5` |
| M-002 | PR to `main` runs all four PR jobs | Open/update PR; confirm `require-labels`, `require-description`, `link-issue`, `all-checks-pass` |

## Commands

```bash
# Narrow DEV-029 filter
bats tests/agtoosa.bats -f "DEV-029"

# Full regression after targeted pass
bats tests/agtoosa.bats
```
