# Test Plan: DEV-141 — Tracker Discovery & Bootstrap

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | TBS-001 | Integration | `discover` emits `agtoosa.tracker-discovery/v1` with signals | yes |
| AC-001 | TBS-002 | Integration | `discover` uses local signals only (no network in lib) | yes |
| AC-002 | TBS-003 | Integration | `bootstrap` mutation guard — Master-Plan hash unchanged | yes |
| AC-003 | TBS-004 | Integration | GitHub mirror labels skipped at merge; bootstrap classifies skips | yes |
| AC-004 | TBS-005 | Integration | GitHub fetch merge proposes backlog row + `/agtoosa-task` hint | yes |
| AC-005 | TBS-006 | Integration | ROADMAP/repo-plans items discovered as `repo_plan` | yes |
| AC-005 | TBS-007 | Integration | Closed GitHub issue → `closed_external` disposition | yes |
| AC-006 | TBS-008 | Docs | Init Phase B.5 + TrackerSync discover/bootstrap docs | no |
| AC-007 | TBS-009 | Docs | Claim boundary lists discover/bootstrap; no API claims | no |
| AC-008 | TBS-010 | Integration | DEV-141 filter suite green | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| TBS-003 | bootstrap `--output` targets Master-Plan.md | Non-zero exit; file unchanged |
| TBS-004 | Issue with `agtoosa:DEV-Alpha` label | Excluded from discovery items |
