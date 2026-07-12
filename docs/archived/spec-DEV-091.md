# Spec: DEV-091 — Feature: Migration Wizard + Rollback Manifest

> **Story ID:** DEV-091
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator & Install
> **Status:** ⬜ Backlog — Cycle C after DEV-090 (Rev4 Wave 1b remainder)
> **Estimate:** L
> **Priority:** P0
> **Depends on:** DEV-090 (install/update plan schema and lock-path correction)
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Enrollment wave:** Rev4 Wave 1b / Cycle C (after DEV-090) — corrected R1 from mislabeled Wave 2

## Context

ADR-004 item 5 calls for an interactive migration wizard on `--update` when a MAJOR version delta is detected. Rev4 elevates safe upgrades: users need a categorized dry-run plan, explicit confirmation before generated-file replacement, timestamped rollback manifest, and `--accept-breaking` for automation.

DEV-090 standardizes the non-executing install/update plan schema and corrects `Docs/agtoosa-lock.json` references. DEV-091 builds the MAJOR-version gate, wizard UX, rollback manifest writer, and JSON plan output on top of that schema.

This story does not replace marker-based merge for PATCH/MINOR updates; it adds a MAJOR boundary with explicit consent.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship a MAJOR-version migration wizard with dry-run categorization, rollback manifest, and explicit breaking-change acceptance. |
| User outcome | Users preview overwrite/merge/preserve/manual actions, confirm MAJOR updates deliberately, and retain a timestamped rollback manifest under `.agtoosa/rollback/`. |
| Success condition | MAJOR delta blocks apply until `--accept-breaking` or interactive confirm; dry-run emits DEV-090 plan schema; rollback manifest written on apply; user content outside markers preserved; MWZ bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-091.md`; MWZ-001–MWZ-010 bats; dry-run and apply fixtures with manifest inspection. |
| Non-goals | Rewriting Shell/PowerShell core; SaaS rollback service; automatic git revert; transactional apply (DEV-092); state file (DEV-093). |
| Assumptions | DEV-090 plan schema is stable; `extract_version` and marker merge remain authoritative for non-MAJOR paths; `.agtoosa/` is gitignored. |
| Risks | Wizard overwrites user edits; manifest omits files; `--accept-breaking` used without dry-run visibility in CI. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** project maintainer facing a MAJOR AgToosa bump, **I want** a categorized dry-run and explicit confirmation **so that** breaking template changes do not surprise me.

**As a** platform engineer, **I want** `--accept-breaking` and JSON plan output **so that** fleet update scripts can gate on the same schema as humans.

**As a** cautious adopter, **I want** a timestamped rollback manifest listing backed-up paths **so that** I can manually restore after a bad update.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `--update` detects installed MAJOR < target MAJOR THE SYSTEM SHALL enter migration wizard mode and SHALL NOT apply changes without explicit confirmation or `--accept-breaking` | Must |
| AC-002 | WHEN migration wizard runs THE SYSTEM SHALL emit a dry-run plan using the DEV-090 schema with actions categorized as `overwrite`, `merge`, `preserve`, or `manual` | Must |
| AC-003 | WHEN migration apply proceeds THE SYSTEM SHALL write `.agtoosa/rollback/<timestamp>.json` listing every backed-up or replaced generated path, source/target versions, and UTC timestamp | Must |
| AC-004 | WHEN user content exists outside AgToosa HTML-comment markers THE SYSTEM SHALL classify those paths as `preserve` and SHALL NOT overwrite them during MAJOR migration apply | Must |
| AC-005 | WHEN `--accept-breaking` is supplied without prior dry-run THE SYSTEM SHALL still print the categorized plan summary before apply | Must |
| AC-006 | WHEN `--dry-run` is selected during MAJOR migration THE SYSTEM SHALL make no filesystem mutations and SHALL NOT write a rollback manifest | Must |
| AC-007 | WHEN `--json` is supplied THE SYSTEM SHALL emit the plan object on stdout using the DEV-090 schema without ANSI color codes | Must |
| AC-008 | WHEN PATCH or MINOR version deltas occur THE SYSTEM SHALL retain existing update behavior without requiring `--accept-breaking` | Must |
| AC-009 | WHEN shipping THE SYSTEM SHALL record MWZ RED/GREEN evidence and update `AgToosa_Update.md` with MAJOR wizard steps | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | MAJOR update applies silently like PATCH. |
| FM-002 | AC-003 | Apply completes with no rollback manifest. |
| FM-003 | AC-004 | User prose inside platform file but outside markers is overwritten. |
| FM-004 | AC-006 | Dry-run writes backups or manifest. |
| FM-005 | AC-007 | JSON output mixes human table and breaks parsers. |
| FM-006 | AC-002 | Plan omits `manual` rows for removed workflows. |
| FM-007 | AC-008 | MINOR bump incorrectly requires `--accept-breaking`. |

### 1.5 Out of Scope

- Transactional/idempotent apply (DEV-092)
- `.agtoosa/state.json` operational hashes (DEV-093)
- Automatic `git revert` or `/agtoosa-revert` integration
- Hosted rollback UI
- PowerShell wizard parity beyond existing `agtoosa.ps1` update entry points (bash is primary; PS1 documents manual path)
- DEV-090 schema authorship

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| MAJOR gate and wizard | generator-enforced on `--update` |
| Dry-run plan | deterministic generator output |
| Rollback manifest | evidenced artifact — manual restore |
| Automatic rollback execution | not claimed — user or `/agtoosa-revert` |
| Marker-outside content preservation | generator-enforced when markers correct |
| Fleet `--accept-breaking` | manual/CI policy — generator provides flag only |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `lib/update.sh` — MAJOR detection; wizard gate; manifest writer hook
- `lib/migrate.sh` (new) — plan categorization; confirmation prompts; `--accept-breaking` handling
- `lib/dryrun.sh` — extend dry-run to emit DEV-090 JSON schema for migration paths
- `agtoosa.sh` — `--accept-breaking`, `--json` wiring on `--update`
- `template/Docs/AgToosa_Update.md` — MAJOR wizard section, rollback manifest docs
- `docs/AgToosa_Update.md` — maintainer mirror
- `template/.gitignore` — ensure `.agtoosa/rollback/` ignored
- `tests/agtoosa.bats` — MWZ fixtures
- `tests/fixtures/migration/` — MAJOR delta project roots

Rollback manifest schema (illustrative):

```json
{
  "schema_version": 1,
  "agtoosa_from": "5.3.13",
  "agtoosa_to": "6.0.0",
  "created_at": "2026-07-12T14:30:00Z",
  "entries": [
    {"path": "Docs/AgToosa_Build.md", "action": "merge", "backup": ".agtoosa/rollback/20260712T143000Z/Docs/AgToosa_Build.md.bak"}
  ]
}
```

### 2.2 Data Flow

1. `--update` reads installed version from `Docs/.agtoosa-version` and target from generator.
2. If MAJOR delta → build categorized plan via `lib/migrate.sh` using template inventory + marker scan.
3. Print plan (human table or `--json`).
4. If `--dry-run` → exit 0 without writes.
5. If not `--accept-breaking` and non-interactive → exit 1 with instructions.
6. On confirm/flag → backup affected files → apply marker merge/overwrite per row → write `.agtoosa/rollback/<ts>.json` → update version marker and lock per DEV-090.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Malicious project path traversal in manifest | Tampering | Normalize paths; reject `..` segments |
| Rollback manifest omits sensitive overwritten file | Repudiation | Manifest lists every generator-owned mutation |
| `--accept-breaking` in CI without human review | Elevation of Privilege | Document risk; require dry-run artifact in runbooks |
| Backup fills disk | Denial of Service | Size cap warning; user confirmation |
| Wizard prints secrets from project files | Information Disclosure | Plan lists paths only, not file bodies |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `lib/update.sh`, `lib/migrate.sh`, `lib/dryrun.sh`, `agtoosa.sh`, Update docs, MWZ bats/fixtures
Directories in scope: `lib/`, `template/Docs/`, `tests/fixtures/migration/`
Depends on          : DEV-090 (plan schema, lock path)
Out of scope        : DEV-092 transactional apply, DEV-093 state file, auto git revert, Master-Plan edits

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED fixtures
  - [ ] 1.1 MAJOR gate blocks without `--accept-breaking` — _Requirements: AC-001, AC-008_
  - [ ] 1.2 Dry-run plan schema and no-write assertions — _Requirements: AC-002, AC-006, AC-007_
  - [ ] 1.3 Rollback manifest and preserve-outside-markers — _Requirements: AC-003, AC-004_
- [ ] **2.** Migration wizard implementation
  - [ ] 2.1 `lib/migrate.sh` plan builder on DEV-090 schema — _Requirements: AC-002, AC-007_
  - [ ] 2.2 MAJOR gate, confirm, and `--accept-breaking` — _Requirements: AC-001, AC-005_
  - [ ] 2.3 Backup + manifest writer — _Requirements: AC-003, AC-004_
- [ ] **3.** Documentation
  - [ ] 3.1 Update `AgToosa_Update.md` MAJOR flow — _Requirements: AC-009_
- [ ] **4.** Evidence
  - [ ] 4.1 Record MWZ RED/GREEN — _Requirements: AC-009_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (sequential):** 2.1 → 2.2 → 2.3
**Wave 3 (sequential):** 3.1, 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-091.md`
AC coverage: 9 ACs mapped to 10 planned MWZ test IDs
Smoke set: 4 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## Spec Revision Log

| Rev | Date | What changed | Why | Approved-by |
|-----|------|--------------|-----|-------------|
| R1 | 2026-07-12 | Status/enrollment labels: Wave 2 → Wave 1b / Cycle C after DEV-090; no Must AC changes | Align with Master-Plan and roadmap-spec-index; hard-dep deferral | Wave 1b fan-in |

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 1b remainder / Cycle C after DEV-090 (ADR-004 item 5); Active Cycle deferred until DEV-090 ships

## ✅ Amendment R1 Approved

Approved: 2026-07-12 — wave-label correction only; no Must AC changes.
