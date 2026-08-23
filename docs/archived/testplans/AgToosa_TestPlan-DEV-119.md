# Test Plan: DEV-119 — Recoverable Project Transaction

> **Spec:** `docs/archived/spec-DEV-119.md`
> **Focused suite:** `bats tests/agtoosa.bats -f 'DEV-119|RPT-'`
> **Status:** Build complete — GREEN pending ship evidence
> **Coverage threshold:** 100% Must AC mapping (`docs/Context/workflow.md`)
> **Test prefix:** `RPT`

## Test Strategy

Fixture-based integration tests exercise transaction journal creation, pre-image capture, late-commit rollback, recovery CLI, gitignore contract, DEV-091 manifest separation, idempotent rerun regression, and multi-journal selection. Tests use disposable temp projects, tree hashes, and `AGTOOSA_APPLY_FAIL_ON` injection — no network, no git mutations.

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | RPT-001 | Integration | Journal directory and manifest created before first project write | yes |
| AC-002 | RPT-002 | Integration | Pre-image snapshot or `absent` recorded per commit entry | yes |
| AC-003 | RPT-003 | Negative | Late commit failure rolls back all prior writes; journal `aborted`; no state write | yes |
| AC-004 | RPT-004 | Integration | Successful commit sets `committed` then state/lock reconcile order | |
| AC-005 | RPT-005 | Integration | `--transaction-recover` restores tree to pre-apply hash | yes |
| AC-006 | RPT-006 | Regression | Second identical apply zero delta (DEV-092 parity) | yes |
| AC-007 | RPT-007 | Security | Injected fail-on path triggers rollback; tree hash matches baseline | yes |
| AC-008 | RPT-008 | Integration | `.agtoosa/transactions/` gitignored; not in template file lists | |
| AC-009 | RPT-009 | Integration | DEV-091 rollback manifest paths distinct from journal schema | |
| AC-010 | RPT-010 | Integration | Newest incomplete journal selected; `--transaction-id` override | |
| AC-011 | RPT-011 | Integration | Recovery does not invoke git or edit Master-Plan | |
| AC-012 | RPT-012 | Meta | DEV-119 filter + RED/GREEN evidence rows documented | |

## Negative / Edge Scenarios

| AC | Scenario | Test ID |
|----|----------|---------|
| AC-003 | Fail on last of three staged files; first two restored byte-identical | RPT-003 |
| AC-005 | Recover after operator manually deletes one target file post-abort | RPT-005 |
| AC-007 | `AGTOOSA_APPLY_FAIL_ON` set to middle commit path | RPT-007 |
| AC-010 | Two aborted journals; recover without flag picks newest `started_at` | RPT-010 |
| AC-002 | Create-new-file op rolls back to absent (file removed) | RPT-002 |

## Fixture Matrix

| Fixture | Purpose |
|---------|---------|
| `transaction/baseline-tree/` | Known small install tree + hash |
| `transaction/late-fail.env` | `AGTOOSA_APPLY_FAIL_ON` for Nth path |
| `transaction/multi-journal/` | Two aborted journal manifests |

## Execution Order

1. Land RPT-001–RPT-012 stubs and fixtures (RED).
2. Implement `lib/transaction.sh` (RPT-001/002).
3. Wire `apply_commit_staging` (RPT-003/004/007).
4. CLI recover/status (RPT-005/010/011).
5. Regression + docs (RPT-006/008/009).
6. Record GREEN evidence (RPT-012).

## Validation Commands

```bash
bats tests/agtoosa.bats -f 'DEV-119|RPT-'
bats tests/agtoosa.bats -f 'DEV-092.*TAP-004'
bats tests/agtoosa.bats -f 'DEV-093.*STF-001'
bash docs/agtoosa-verify.sh --root .
```

## Evidence Plan

### RED (required before implementation)

Record command, UTC timestamp, exit code, and failure excerpt proving at least RPT-003 fails against pre-DEV-119 `lib/apply.sh` (partial-write or missing journal).

### GREEN (required for ship)

Record full `bats tests/agtoosa.bats -f 'DEV-119|RPT-'` exit 0, tree-hash assertions, and regression TAP-004 / STF-001 pass.
