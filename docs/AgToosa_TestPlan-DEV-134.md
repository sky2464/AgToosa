# Test Plan: DEV-134 — README Hero Media Pass (Catch-up Formalization)

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-002 | MED-001 | Docs | `WorkflowSummaryScene` exists and `ReadmeLoop` mounts seven story beats | yes |
| AC-002 | MED-002 | Docs | `WorkflowRail` supports `showCaptions`; verify script checks captioned summary | no |
| AC-003 | MED-003 | Asset | Published `agtoosa-hero.gif` exists and README references inline hero | yes |
| AC-001 | MED-004 | Integration | `npm run verify:checkpoint` exits 0 | no |
| AC-004 | All above | Regression | Filter `MED-` exits 0 | yes |

### Evidence

```
GREEN evidence — task-1
Command: cd docs/media/agtoosa-hero && npm run verify:checkpoint
Exit code: 0
Note: 1 expected warning — final licensed-score master intentionally absent at checkpoint.
```
