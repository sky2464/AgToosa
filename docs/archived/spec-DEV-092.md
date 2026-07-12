# Spec: DEV-092 — Chore: Transactional Apply + Idempotency

> **Story ID:** DEV-092
> **Type:** Chore
> **Epic:** DEV-001 — Core Generator & Install
> **Status:** 🟦 Todo — Rev4 Wave 2 (approved)
> **Estimate:** M
> **Priority:** P1
> **Depends on:** DEV-090 (install/update plan schema)
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

Install and `--update` apply paths can leave a project partially written if a copy or merge fails mid-flight. Rev4 calls for transactional generation where practical. DEV-090 defines the plan schema used to preview changes; DEV-092 makes apply idempotent and hash-aware so a second run with the same inputs produces zero file delta.

This chore complements DEV-091 (MAJOR wizard) but applies to all apply modes: install, update, and registry-driven copies.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make generator apply transactional and idempotent via staging, hash-compare, and second-run-zero-delta guarantees. |
| User outcome | Failed applies do not corrupt the project; repeated apply with unchanged inputs changes nothing. |
| Success condition | Apply stages to temp dir, validates plan, commits atomically; hash-compare skips unchanged files; second identical run reports zero writes; TAP bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-092.md`; TAP-001–TAP-008 bats; injected failure fixtures. |
| Non-goals | Distributed transactions; database; rollback manifest (DEV-091); state file (DEV-093); pack registry protocol changes. |
| Assumptions | DEV-090 plan enumerates target paths; filesystem supports rename within same volume; bash primary path. |
| Risks | Temp dir disk exhaustion; hash compare misses permission-only changes; Windows path parity gaps. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** maintainer running `--update`, **I want** apply to be all-or-nothing **so that** a failed copy does not leave half-updated workflow files.

**As a** CI operator, **I want** a second identical install to change zero files **so that** drift detection and re-runs are safe.

**As an** AgToosa engineer, **I want** hash-compare before write **so that** unnecessary backups and merge conflicts are avoided.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN apply begins THE SYSTEM SHALL stage all planned writes to a temporary directory before mutating project paths | Must |
| AC-002 | WHEN any staged operation fails THE SYSTEM SHALL abort commit and SHALL leave pre-apply project files unchanged | Must |
| AC-003 | WHEN a target file exists and staged content hash equals existing content hash THE SYSTEM SHALL skip the write and record `unchanged` in apply summary | Must |
| AC-004 | WHEN apply completes successfully with the same generator version, platforms, and packs THE SYSTEM SHALL produce zero byte-level file deltas on immediate second run | Must |
| AC-005 | WHEN apply summary is printed THE SYSTEM SHALL list `written`, `merged`, `unchanged`, and `failed` counts | Must |
| AC-006 | WHEN `--dry-run` is active THE SYSTEM SHALL not create staging directories that mutate the project tree | Must |
| AC-007 | WHEN install and `--update` share apply logic THE SYSTEM SHALL use one transactional apply helper | Must |
| AC-008 | WHEN shipping THE SYSTEM SHALL record TAP RED/GREEN evidence | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-002 | Partial write leaves mixed old/new template versions. |
| FM-002 | AC-004 | Second run rewrites identical files, touching mtimes. |
| FM-003 | AC-003 | Hash compare uses size-only heuristic, missing content change. |
| FM-004 | AC-001 | Staging dir inside project tree collides with target paths. |
| FM-005 | AC-006 | Dry-run creates staging artifacts in project. |
| FM-006 | AC-007 | Update bypasses transactional helper. |

### 1.5 Out of Scope

- MAJOR migration wizard and rollback manifest (DEV-091)
- `.agtoosa/state.json` (DEV-093)
- Git-aware revert automation
- Network transactional guarantees
- PowerShell full parity in v1 (bash path required; PS1 documents limitation)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Staging + atomic commit | generator-enforced on bash apply path |
| Hash-compare skip | generator-enforced |
| Second-run zero delta | CI-enforced-able via bats |
| Cross-filesystem atomic rename | best-effort — documented limitation |
| PowerShell apply parity | roadmap / partial |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `lib/copy.sh` — hash-compare helper; skip unchanged
- `lib/apply.sh` (new) — stage → validate → commit transactional apply
- `lib/install.sh`, `lib/update.sh` — delegate to `lib/apply.sh`
- `lib/dryrun.sh` — ensure no staging dir on dry-run
- `agtoosa.sh` — apply summary output
- `tests/agtoosa.bats` — TAP tests
- `tests/fixtures/apply/` — identical-content and fail-mid-apply fixtures

### 2.2 Data Flow

1. Plan builder (DEV-090) yields ordered operations.
2. `apply.sh` creates temp staging root outside project.
3. For each operation: render content to staging path; on failure → cleanup staging, exit non-zero.
4. Hash-compare staging vs target; build commit list skipping unchanged.
5. Atomic rename/move into project (or sequential commit with rollback on failure).
6. Print summary counts; exit 0.
7. Second run: plan identical → all rows `unchanged` → zero writes.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Staging dir world-readable with secrets | Information Disclosure | `mktemp` with restrictive perms; cleanup on exit |
| Race between compare and commit | Tampering | Commit from staging snapshot; single-threaded bash |
| Disk fill during stage | Denial of Service | Fail fast; surface error in summary |
| Symlink escape from staging | Elevation of Privilege | Reject symlinks in pack/copy paths (existing containment) |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `lib/apply.sh`, `lib/copy.sh`, `lib/install.sh`, `lib/update.sh`, TAP bats/fixtures
Depends on          : DEV-090 plan enumeration
Out of scope        : DEV-091 wizard, DEV-093 state, PS1 full parity, Master-Plan edits

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED fixtures
  - [ ] 1.1 Fail-mid-apply leaves tree unchanged — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Hash-compare skip and second-run-zero-delta — _Requirements: AC-003, AC-004_
  - [ ] 1.3 Dry-run no staging — _Requirements: AC-006_
- [ ] **2.** Transactional apply
  - [ ] 2.1 Implement `lib/apply.sh` stage/commit — _Requirements: AC-001, AC-002, AC-007_
  - [ ] 2.2 Wire hash-compare and summary — _Requirements: AC-003, AC-005_
- [ ] **3.** Evidence
  - [ ] 3.1 Record TAP RED/GREEN — _Requirements: AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (sequential):** 2.1 → 2.2 → 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-092.md`
AC coverage: 8 ACs mapped to 8 planned TAP test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 (DEV-001 transactional apply)
