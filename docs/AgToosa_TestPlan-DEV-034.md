# Test Plan: DEV-034 — Maintainer release-state reconciliation

> **Spec:** `docs/archived/spec-DEV-034.md`
> **Coverage target:** ledger consistency, release pin parity, and changelog truthfulness
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-034"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-002, AC-005 | LR-001 | Integration | `docs/Master-Plan.md` has coherent Active Cycle, Active Tasks, Backlog, and Completed This Cycle state for DEV-030/031/032/033/034 | yes |
| AC-002, AC-008 | LR-002 | Integration | DEV-033 has a clear shipped disposition and required artifact pointers are present | yes |
| AC-003 | LR-003 | Integration | `agtoosa.sh`, `agtoosa.ps1`, README badge/snippet, Homebrew formula, and bats pins agree with the current release version | yes |
| AC-004 | LR-004 | Integration | `CHANGELOG.md` and `docs/AgToosa_Changelog.md` keep DEV-034 in `[Unreleased]` while DEV-033 lives under the `5.2.4` release block | yes |
| AC-006 | LR-005 | Integration | DEV-029 manual-deferred PR-path row is preserved unless manual completion evidence is recorded | no |
| AC-007 | LR-006 | Integration | DEV-034 focused bats filter covers all required ledger/version drift checks | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-034"
bats tests/agtoosa.bats -f "^version parity:|MR5:|DEV-033"
```

Optional release sanity after any version bump:

```bash
bash agtoosa.sh --version
pwsh -NoProfile -Command "./agtoosa.ps1 --version"
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-034"                    # 6/6 passing
bats tests/agtoosa.bats -f "^version parity:|MR5:|DEV-033" # 6/6 passing
bats tests/agtoosa.bats                                 # attempted; not green in current worktree
                                                            # DEV-034 LR-001-LR-006 passed in full run
                                                            # failures are broad interactive install/update
                                                            # and ship/ teardown harness failures

Release decision:
- `5.2.4` shipped DEV-030 + DEV-033; version pins aligned.
- DEV-034 remains in `[Unreleased]` until its own review/ship as v5.2.5.
- DEV-029 manual-deferred PR-path verification remains tracked.
```
