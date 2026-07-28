# Test Plan: DEV-143 — Tracker Unlinked Status Finding

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | TUS-001 | Integration | `status-check` emits `agtoosa.tracker-status-check/v1`; lib has no network fetch | yes |
| AC-002 | TUS-002 | Integration | Auto-merge `.agtoosa/tracker/gh-issues.json` increases item count | yes |
| AC-003 | TUS-003 | Integration | `new_external` items appear in `unlinked_external` with `finding.emit` true | yes |
| AC-004 | TUS-004 | Integration | Mirror-labeled issue excluded; not counted unlinked | yes |
| AC-005 | TUS-005 | Integration | Greenfield fixture: no signals, no caches → `finding.emit` false | yes |
| AC-006 | TUS-006 | Integration | When emit true, `finding.severity` is `info` | yes |
| AC-007 | TUS-007 | Docs | `AgToosa_Status.md` documents Info finding + no deduction + Part 5.5 row | no |
| AC-008 | TUS-008 | Integration | DEV-143 filter suite green | yes |

### Negative cases

| Test ID | Case | Expected |
|---------|------|----------|
| TUS-004 | Issue with `agtoosa:DEV-Alpha` label | Not in `unlinked_external` |
| TUS-005 | Empty fixture repo | `finding.emit` false, exit 0 |

## Planned smoke command

```bash
bats tests/agtoosa.bats -f "DEV-143 TUS"
```

## Evidence

| Test ID | Result | Notes |
|---------|--------|-------|
| TUS-001 | GREEN | Schema v1 + no network fetch in `lib/tracker-discover.sh` |
| TUS-002 | GREEN | `with-cache` fixture merges `gh-issues.json`; `new_external >= 1` |
| TUS-003 | GREEN | `github:example/bootstrap-fixture#42` unlinked; `finding.emit` true |
| TUS-004 | GREEN | Mirror issue `#7` excluded from `unlinked_external` |
| TUS-005 | GREEN | Greenfield fixture: `finding.emit` false, `has_tracker_signals` false |
| TUS-006 | GREEN | `finding.severity` == `info` when emit true |
| TUS-007 | GREEN | `AgToosa_Status.md` documents Info finding + no deduction |
| TUS-008 | GREEN | Filter suite `DEV-143 TUS-00[1-7]` all pass |
