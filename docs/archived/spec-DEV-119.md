# Spec: DEV-119 — Feature: Recoverable Project Transaction

> **Story ID:** DEV-119
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** 🟦 Todo
> **Estimate:** L
> **Priority:** P0
> **Clarity:** `ready`
> **Depends on:** DEV-092 (transactional apply), DEV-093 (install state + lock reconcile)
> **Spec created:** 2026-07-26
> **Spec deepened:** 2026-07-26

## Context

DEV-092 introduced staging-outside-project and hash-aware commit for install/update apply. DEV-093 writes `.agtoosa/state.json` and reconciles `Docs/agtoosa-lock.json` after successful apply. The commit loop in `lib/apply.sh` still writes targets sequentially; a failure after the first successful `mv` can leave a **partially updated** project tree while staging is discarded — the worst case for operator trust.

DEV-119 closes that gap with a **project transaction journal**: capture pre-images before each commit write, roll back on late failure, expose deterministic recovery for incomplete transactions, extend fault-injection fixtures, and preserve DEV-092 idempotent reruns. Scope is **generator-orchestrated filesystem mutations** (install, update, registry-driven apply, and shared `apply_commit_staging` paths) — not agent-authored edits during `/agtoosa-build` (parked for DEV-123).

### Brownfield baseline

| Area | Current state | DEV-119 delta |
|------|---------------|---------------|
| Staging | Outside project; abort cleans staging only | Unchanged |
| Commit | Sequential per-file write; failure mid-loop may partial-write | Journal + rollback on any late failure |
| Recovery | Manual restore; DEV-091 MAJOR manifest is separate | `--transaction-recover` for incomplete journals |
| Fault injection | `AGTOOSA_APPLY_FAIL_ON=<relpath>` before write | Retain + document; assert rollback tree hash |
| State write | After full commit success (DEV-093) | Only after journal `committed` |
| Claim | AC-002 “unchanged on failure” | Strengthen to include late-commit failures |

**Repo evidence:** `lib/apply.sh` `apply_commit_staging` (lines 271–365), `lib/state.sh`, `tests/agtoosa.bats` TAP/STF sections, `docs/archived/spec-DEV-092.md`, `docs/archived/spec-DEV-093.md`.

### Plan-Mode Spec Interview (findings)

Research replaced interview questions where confidence ≥80% (portfolio map + codebase):

| Checklist area | Finding |
|----------------|---------|
| Status quo | Apply can partial-write on late commit failure; operators may re-run or hand-fix |
| Narrowest scope | Journal + rollback for `apply_commit_staging` paths only (bash generator) |
| Urgency | P0 competitive portfolio; blocks trustworthy install/update on large template drops |
| 10-star | Full agent write journal + hosted recovery — **non-goals** |
| Failure modes | Partial template mix; stale state.json after failed commit; unbounded journal dirs |
| Security | Journal may contain project file snapshots — gitignore + path containment |

**Documented assumption (no user override yet):** “Project-wide” means all generator-orchestrated project paths in apply/update/migrate commit lists, not arbitrary repo files or agent workflow edits.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Extend DEV-092/093 with a recoverable project transaction journal, late-write rollback, deterministic recovery CLI, and fault-injection proof. |
| User outcome | Failed install/update leaves the project restorable to the pre-apply tree; operators can recover incomplete transactions without hand-editing dozens of workflow files. |
| Success condition | Late-commit failure restores pre-transaction bytes; `--transaction-recover` deterministically completes recovery for `aborted` journals; second identical apply remains zero-delta; RPT bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-119.md`; RPT-001–RPT-012 bats; RED/GREEN terminal evidence. |
| Non-goals | Distributed transactions; databases; registry-protocol redesign; automatic git revert; agent build/review write journaling (DEV-123); PowerShell full parity in v1. |
| Assumptions | DEV-092/093 remain shipped; journal lives under gitignored `.agtoosa/transactions/`; bash path is authoritative for v1. |
| Risks | Disk use during large applies; journal/state ordering bugs; false confidence if recovery skips user-owned files outside generator manifest. |
| Unresolved questions | None — scope assumption recorded above. |

### 1.2 User Stories

**As a** maintainer running `--update`, **I want** late apply failures to roll back already-written files **so that** my project is not left in a mixed template version state.

**As an** operator, **I want** a documented recovery command for incomplete transactions **so that** I can restore deterministically without guessing which files changed.

**As an** AgToosa engineer, **I want** fault-injection bats for late-commit failure **so that** rollback stays CI-enforced.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `apply_commit_staging` begins mutating project paths THE SYSTEM SHALL create a transaction journal under `.agtoosa/transactions/<transaction-id>/` before the first project write | Must |
| AC-002 | WHEN a commit would create or overwrite a project file THE SYSTEM SHALL append a journal record with relative path, operation (`create`/`overwrite`), and pre-image snapshot path or `absent` marker captured before the write | Must |
| AC-003 | WHEN any project write fails after earlier writes in the same transaction THE SYSTEM SHALL restore every journaled path to its pre-transaction content, delete paths that were `create`, set journal status `aborted`, and exit non-zero without writing DEV-093 state or lock reconcile | Must |
| AC-004 | WHEN all commit writes succeed THE SYSTEM SHALL set journal status `committed`, then invoke DEV-093 state and lock reconcile in existing order | Must |
| AC-005 | WHEN the user runs `agtoosa.sh --transaction-recover [project-path]` and an `aborted` or `incomplete` journal exists THE SYSTEM SHALL restore the project tree to the journal’s pre-transaction snapshot deterministically and mark the journal `recovered` | Must |
| AC-006 | WHEN apply completes successfully and an identical apply reruns immediately THE SYSTEM SHALL preserve DEV-092 zero-delta / unchanged behavior | Must |
| AC-007 | WHEN `AGTOOSA_APPLY_FAIL_ON` targets a path after prior commits in the same transaction THE SYSTEM SHALL trigger AC-003 rollback and bats SHALL assert stable project tree hash vs pre-apply baseline | Must |
| AC-008 | WHEN transaction artifacts are written THE SYSTEM SHALL keep `.agtoosa/transactions/` gitignored and SHALL NOT add journal files to template install lists | Must |
| AC-009 | WHEN DEV-091 rollback manifests exist THE SYSTEM SHALL treat them as separate from transaction journals and SHALL NOT merge manifest semantics into journal schema | Must |
| AC-010 | WHEN multiple incomplete journals exist THE SYSTEM SHALL recover the newest incomplete journal by `started_at` unless the user passes `--transaction-id` | Must |
| AC-011 | WHEN recovery completes THE SYSTEM SHALL NOT run git commands or mutate `docs/Master-Plan.md` | Must |
| AC-012 | WHEN shipping THE SYSTEM SHALL record RPT RED/GREEN evidence with command, exit code, and tree-hash proof | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-003 | Late failure leaves mixed old/new workflow files. |
| FM-002 | AC-005 | Recovery restores wrong journal or partial paths. |
| FM-003 | AC-004 | State.json records success while journal still `incomplete`. |
| FM-004 | AC-008 | Journal committed to git with sensitive project content. |
| FM-005 | AC-006 | Rollback breaks hash-compare idempotency. |
| FM-006 | AC-009 | MAJOR migration manifest confused with transaction journal. |
| FM-007 | AC-002 | Pre-image missing for overwritten file → recovery corrupts content. |
| FM-008 | AC-010 | Ambiguous recovery when multiple aborted journals exist. |

### 1.5 Out of Scope

- Agent `/agtoosa-build` file mutation journaling
- Network or multi-machine transaction coordination
- Automatic scheduled journal compaction (document manual cleanup only in v1)
- PowerShell parity (document bash-only recovery in v1)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Journal create + pre-image capture | generator-enforced (bash) |
| Late-failure rollback | generator-enforced + CI-enforced (bats) |
| `--transaction-recover` | generator-enforced |
| Agent workflow recovery | roadmap (DEV-123) |
| Cross-filesystem atomicity | best-effort — documented limitation |

## 2. Design

### 2.1 Architecture Blueprint

New / changed files:

- `lib/transaction.sh` (new) — journal open, record, rollback, recover, status
- `lib/apply.sh` — hook journal around commit loop; call rollback on failure
- `agtoosa.sh` — `--transaction-recover`, `--transaction-status`; help text
- `template/.gitignore` — `.agtoosa/transactions/`
- `.gitignore` — maintainer mirror
- `template/Docs/AgToosa_Update.md` — transaction journal + recovery section
- `docs/Master-Architecture.md` — data-flow note (install path)
- `tests/agtoosa.bats` — RPT fixtures
- `tests/fixtures/transaction/` — pre/post hash baselines, fail-on-Nth-write
- `docs/adr/ADR-018-recoverable-project-transaction.md` — accept on ship

Journal schema (illustrative):

```json
{
  "schema_version": 1,
  "transaction_id": "20260726T173000Z-abc12",
  "status": "open|committed|aborted|recovered",
  "started_at": "2026-07-26T17:30:00Z",
  "ended_at": null,
  "agtoosa_version": "5.3.31",
  "apply_command": "update",
  "entries": [
    {"path": "Docs/AgToosa_Build.md", "op": "overwrite", "before": "snapshots/Docs/AgToosa_Build.md", "sha256_before": "…"}
  ]
}
```

### 2.2 Data Flow

1. Plan / staging (DEV-092) unchanged.
2. `transaction_open` → create journal dir + manifest `journal.json` status `open`.
3. For each commit target: `transaction_record_before` → snapshot or `absent`; then write file.
4. On write error → `transaction_rollback` → restore snapshots → status `aborted` → exit 1 (no state write).
5. On success → status `committed` → DEV-093 hooks.
6. Operator `agtoosa.sh --transaction-recover` → load newest incomplete journal → rollback → `recovered`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Journal snapshots leak secrets into world-readable dirs | Information Disclosure | Gitignore; restrictive dir perms; path containment |
| Symlink escape via snapshot restore | Elevation of Privilege | Reuse apply path containment; refuse symlinks |
| Recovery overwrites user work outside generator manifest | Tampering | Journal only paths from commit list |
| Unbounded journal growth fills disk | Denial of Service | Document retention; fail with clear error |
| Repudiation of failed apply | Repudiation | Journal status + timestamps; evidence in test plan |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope: `lib/transaction.sh`, `lib/apply.sh`, `agtoosa.sh`, gitignore files, `template/Docs/AgToosa_Update.md`, `docs/Master-Architecture.md`, `tests/agtoosa.bats`, `tests/fixtures/transaction/`, `docs/adr/ADR-018-recoverable-project-transaction.md`

Directories in scope: `lib/`, `tests/fixtures/transaction/`, `.agtoosa/` (gitignore only)

Out of scope: `lib/migrate.sh` manifest writer behavior (except cross-reference docs), PowerShell recovery, agent orchestration, `docs/Master-Plan.md` runtime edits, product-truth contract

Depends on: DEV-092 `apply_commit_staging`, DEV-093 `state_write_after_apply` / `lock_reconcile`

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED fixtures and schema
  - [ ] 1.1 Journal schema + gitignore contract — _Requirements: AC-001, AC-008_
  - [ ] 1.2 Late-failure partial-write fixture (pre-DEV-119 RED) — _Requirements: AC-003, AC-007_
  - [ ] 1.3 Recovery CLI contract tests — _Requirements: AC-005, AC-010, AC-011_
- [ ] **2.** Transaction journal implementation
  - [ ] 2.1 `lib/transaction.sh` open/record/rollback — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 2.2 Wire `apply_commit_staging` hooks + success path — _Requirements: AC-003, AC-004_
  - [ ] 2.3 `--transaction-recover` and `--transaction-status` in `agtoosa.sh` — _Requirements: AC-005, AC-010, AC-011_
- [ ] **3.** Idempotency and docs
  - [ ] 3.1 Regression: DEV-092 zero-delta + DEV-093 state ordering — _Requirements: AC-006, AC-004_
  - [ ] 3.2 Update docs + ADR-018 Accepted + architecture note — _Requirements: AC-009_
- [ ] **4.** Evidence
  - [ ] 4.1 RPT RED/GREEN + ship regression — _Requirements: AC-012_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3  
**Wave 2 (sequential):** 2.1 → 2.2 → 2.3  
**Wave 3 (parallel):** 3.1, 3.2  
**Wave 4:** 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-119.md`  
AC coverage: 12 Must ACs → RPT-001–RPT-012  
Smoke set: RPT-003, RPT-005, RPT-007, RPT-006

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/fixtures/transaction/`, `tests/agtoosa.bats` (RPT RED stubs) | Approved spec | RED fixtures | 1 | `test -d tests/fixtures/transaction` |
| PKG-1.2 | 1 | — | `template/.gitignore`, `.gitignore` | AC-008 | transactions gitignore | 1 | `grep -q 'transactions' template/.gitignore` |
| PKG-2.1 | 2 | PKG-1.1 | `lib/transaction.sh` | Journal schema | open/record/rollback API | 2 | `bats tests/agtoosa.bats -f 'RPT-00[123]'` |
| PKG-2.2 | 2 | PKG-2.1 | `lib/apply.sh` | transaction API | wired commit loop | 3 | `bats tests/agtoosa.bats -f 'RPT-00[347]'` |
| PKG-2.3 | 2 | PKG-2.1 | `agtoosa.sh` | transaction API | recover/status flags | 3 | `bats tests/agtoosa.bats -f 'RPT-00[589]'` |
| PKG-3.1 | 3 | PKG-2.2 | `lib/apply.sh`, `lib/state.sh` (read-only ordering check) | DEV-092/093 | idempotent rerun | 4 | `bats tests/agtoosa.bats -f 'RPT-006|DEV-092.*TAP-004'` |
| PKG-3.2 | 3 | PKG-2.3 | `template/Docs/AgToosa_Update.md`, `docs/Master-Architecture.md`, `docs/adr/ADR-018-recoverable-project-transaction.md` | Implemented behavior | docs + ADR Accepted | 4 | `grep -q 'transaction' template/Docs/AgToosa_Update.md` |
| PKG-4.1 | 4 | PKG-3.1, PKG-3.2 | `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-119.md` | All packages | GREEN evidence | 5 | `bats tests/agtoosa.bats -f 'DEV-119|RPT-'` |

### 3.5 Story Skill Opportunity

| Skill name | Trigger | Purpose | Decision |
|------------|---------|---------|----------|
| _(none)_ | — | Generator-enforced journal + CLI is the reusable mechanism | **Do not generate** |

## Spec Quality Analyzer

- Must ACs unambiguous and testable: **yes**
- Goal / AC / scope alignment: **yes**
- Claim boundaries classified: **yes**
- Every Must AC maps to test plan: **yes**
- Placeholders remaining: **none**

## ✅ Spec Approved

Approved: 2026-07-26 13:08
