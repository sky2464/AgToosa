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
| AC-004 | LR-004 | Integration | `CHANGELOG.md` and `docs/AgToosa_Changelog.md` show DEV-034 under `5.2.5` and DEV-033 under `5.2.4`; `[Unreleased]` has no DEV-034 | yes |
| AC-006 | LR-005 | Integration | DEV-029 PR-path manual verification completion is recorded and Manual / Deferred row cleared | no |
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
bats tests/agtoosa.bats -f "DEV-034"                    # 6/6 passing (pre-ship + post-ship LR-001/LR-004 updated)
bats tests/agtoosa.bats -f "^version parity:|MR5:|DEV-033" # 6/6 passing
bats tests/agtoosa.bats                                 # 358/358 passing (rm -rf ship before run)

Release decision:
- `5.2.4` shipped DEV-030 + DEV-033; version pins aligned.
- `5.2.5` shipped DEV-034; version pins bumped; LR-004 asserts 5.2.5 block + empty Unreleased for DEV-034.
- DEV-029 task 4.1 complete: PR #29 → run `27050231744`; Manual / Deferred cleared.
```
