# Spec: DEV-093 — Feature: Install State File + Lock Reconciliation

> **Story ID:** DEV-093
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator & Install
> **Status:** 🚫 Blocked — Rev4 Wave 2 enrolled (hard-dep DEV-092)
> **Estimate:** M
> **Priority:** P1
> **Depends on:** DEV-092 (transactional apply)
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

AgToosa projects currently expose provenance across three surfaces: `Docs/.agtoosa-version` (committed semver marker), `Docs/agtoosa-lock.json` (committed pack/platform pins per ADR-004), and informal operational knowledge. Rev4 conflict resolution assigns `.agtoosa/state.json` as the **operational** surface: installed version, adapter selection, generated-file hashes, last apply timestamp, and evidence references — **gitignored**, not committed.

ADR-004 lock drift (`platforms[]`, pack SHA revalidation on update) is addressed here alongside DEV-090 path corrections. DEV-088 (doctor) will summarize all three surfaces with explicit labels; this story owns state file write/reconcile and lock alignment after apply.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Maintain `.agtoosa/state.json` and reconcile it with `Docs/agtoosa-lock.json` after transactional apply. |
| User outcome | Operators inspect local operational state without polluting git; lock file stays authoritative for reproducibility; doctor can cite consistent hashes. |
| Success condition | State written on successful apply; gitignored; lock `platforms[]` and pack SHA fields align with apply; reconcile fixes drift; STF bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-093.md`; STF-001–STF-009 bats; lock/state fixture pairs. |
| Non-goals | Committing state to git; hosted state sync; replacing lock file authority; doctor UI (DEV-088). |
| Assumptions | DEV-092 apply completes atomically; lock path is `Docs/agtoosa-lock.json`; `.agtoosa/` gitignored. |
| Risks | State/lock divergence after manual edits; stale hashes after user merges; duplicate truth claims. |
| Unresolved questions | None — authority table binding per `rev4-conflict-resolutions.md` §5. |

### 1.2 User Stories

**As a** maintainer, **I want** a gitignored state file with last-apply metadata **so that** local operational detail does not enter version control.

**As a** release engineer, **I want** lock reconciliation after update **so that** `platforms[]` and pack SHAs match what was actually installed.

**As a** doctor user, **I want** state and lock fields to use the same canonical names **so that** summaries are not contradictory.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN transactional apply succeeds THE SYSTEM SHALL write or update `.agtoosa/state.json` with `agtoosa_version`, `platforms`, `packs`, `generated_file_hashes`, `last_apply_at`, and `last_apply_command` | Must |
| AC-002 | WHEN `.agtoosa/state.json` is written THE SYSTEM SHALL ensure `.agtoosa/` remains gitignored and SHALL NOT add state to committed template lists | Must |
| AC-003 | WHEN `Docs/agtoosa-lock.json` exists THE SYSTEM SHALL reconcile `platforms` and pack `name`, `version`, `sha256`, `installed_at` fields to match post-apply reality | Must |
| AC-004 | WHEN lock file is absent on first install THE SYSTEM SHALL create `Docs/agtoosa-lock.json` per ADR-004 schema at `Docs/agtoosa-lock.json` | Must |
| AC-005 | WHEN pack SHA revalidation fails on update THE SYSTEM SHALL abort apply before state/lock write and SHALL report pack id and expected vs observed SHA | Must |
| AC-006 | WHEN user manually edits generated files THE SYSTEM SHALL record updated hashes in state on next apply without falsely claiming lock pins changed | Must |
| AC-007 | WHEN state and lock disagree after reconcile THE SYSTEM SHALL prefer lock for committed reproducibility fields and state for operational `generated_file_hashes` | Must |
| AC-008 | WHEN shipping THE SYSTEM SHALL record STF RED/GREEN and cross-link authority table in Update/Doctor docs | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-002 | `state.json` committed; template registers it for install. |
| FM-002 | AC-003 | Lock lists platform not actually installed. |
| FM-003 | AC-005 | Tampered pack applies; state records false SHA. |
| FM-004 | AC-007 | Doctor claims single file is both lock and state authority. |
| FM-005 | AC-001 | Apply succeeds but state missing. |
| FM-006 | AC-004 | Lock written to `.agtoosa-lock.json` wrong path. |

### 1.5 Out of Scope

- Doctor command output (DEV-088)
- DEV-090 doc path correction authorship
- Remote state backup
- Evidence ledger content (DEV-049)
- MAJOR migration manifest (DEV-091)

### 1.6 Claim Boundary

| Surface | Authority | Committed |
|---------|-----------|-----------|
| `Docs/.agtoosa-version` | Installed AgToosa semver marker | Yes |
| `Docs/agtoosa-lock.json` | Pack pins, platforms, reproducibility | Yes (when used) |
| `.agtoosa/state.json` | Operational hashes, last apply, evidence refs | No (gitignored) |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `lib/state.sh` (new) — read/write state.json; hash inventory
- `lib/lock.sh` (new or extend `lib/registry.sh`) — reconcile lock with apply result
- `lib/apply.sh` — invoke state+lock write on success (post DEV-092)
- `lib/update.sh` — pack SHA revalidation hook
- `template/.gitignore` — `.agtoosa/state.json` explicit entry
- `.gitignore` — maintainer mirror
- `template/Docs/AgToosa_Update.md` — authority table
- `tests/agtoosa.bats` — STF fixtures

State schema (illustrative):

```json
{
  "schema_version": 1,
  "agtoosa_version": "6.0.0",
  "platforms": ["cursor", "claude"],
  "packs": [{"name": "official-web", "version": "1.0.0", "sha256": "…"}],
  "generated_file_hashes": {"Docs/AgToosa_Build.md": "sha256:…"},
  "last_apply_at": "2026-07-12T15:00:00Z",
  "last_apply_command": "update"
}
```

### 2.2 Data Flow

1. Transactional apply (DEV-092) completes commit list.
2. Compute SHA-256 for each generator-owned path in commit list → `generated_file_hashes`.
3. Write `.agtoosa/state.json` atomically.
4. Reconcile `Docs/agtoosa-lock.json`: platforms from selection; packs from registry install with SHA verify.
5. On SHA mismatch → abort before step 3 (apply already rolled back by DEV-092).

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| State file committed with environment paths | Information Disclosure | Gitignore + bats assert not in template file lists |
| Lock SHA bypass | Tampering | Revalidate before write; STF negative fixture |
| State overwrites lock authority | Elevation of Privilege | AC-007 separation; doctor labels (DEV-088) |
| Corrupt state JSON breaks apply | Denial of Service | Validate schema; recreate on parse error with WARN |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `lib/state.sh`, `lib/lock.sh`, `lib/apply.sh`, gitignore, Update doc, STF bats
Depends on          : DEV-092 transactional apply, DEV-090 lock path
Out of scope        : DEV-088 doctor, committing state, Master-Plan edits

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED fixtures
  - [ ] 1.1 State write and gitignore contract — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Lock reconcile and path — _Requirements: AC-003, AC-004_
  - [ ] 1.3 Pack SHA failure abort — _Requirements: AC-005_
- [ ] **2.** State and lock implementation
  - [ ] 2.1 `lib/state.sh` writer hooked to apply — _Requirements: AC-001, AC-006_
  - [ ] 2.2 Lock reconcile + SHA revalidation — _Requirements: AC-003, AC-004, AC-005, AC-007_
- [ ] **3.** Docs and evidence
  - [ ] 3.1 Authority table in Update doc — _Requirements: AC-008_
  - [ ] 3.2 STF RED/GREEN — _Requirements: AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (sequential):** 2.1 → 2.2 → 3.1 → 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-093.md`
AC coverage: 8 ACs mapped to 9 planned STF test IDs
Smoke set: 4 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 Active Cycle (2026-07-12) — blocked until DEV-092 GREEN
