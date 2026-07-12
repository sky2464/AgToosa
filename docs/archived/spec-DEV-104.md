# Spec: DEV-104 — Feature: --reinstall --clean (ADR-004 Option C)

> **Story ID:** DEV-104
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator & CLI
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-090 (lock file path and provenance corrections)
> **ADR:** ADR-004 Option C — optional immutable fresh reinstall for users who want deterministic clean state

## Context

ADR-004 adopted marker-based in-place `--update` as the default safe path (Option A) but noted Option C — immutable fresh reinstall — as an optional flag for users who want a deterministic clean state and are willing to re-apply customizations manually. DEV-090 corrects `Docs/agtoosa-lock.json` references and provenance surfaces. DEV-104 implements `--reinstall --clean` in bash and PowerShell with explicit confirmation, archival of replaced generated files, lock-file rewrite, and bats coverage. It does not replace `--update` as the default upgrade path.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add an optional `--reinstall --clean` flow that regenerates AgToosa outputs from the current generator version into a clean deterministic state. |
| User outcome | A user who accepts fresh-state trade-offs can reinstall AgToosa files without marker-merge ambiguity, with a recorded archive and rollback pointer. |
| Success condition | `--reinstall --clean` archives prior generated files, regenerates from template, rewrites `Docs/agtoosa-lock.json`, requires explicit confirmation, and is parity-tested in bash and PowerShell. |
| Proof / evidence | RCL tests cover confirmation gate, archive manifest, regenerated file set, lock rewrite, idempotent second run, and user-content-outside-markers warning. |
| Non-goals | Making clean reinstall the default update path, silently deleting user edits, or network bootstrap changes. |
| Assumptions | DEV-090 lock path (`Docs/agtoosa-lock.json`) is authoritative; marker merge remains default for `--update`. |
| Risks | Users lose customizations without heeding warnings; archive path collisions; PowerShell parity drift. |
| Unresolved questions | Default archive directory name is fixed at implementation (e.g. `.agtoosa/reinstall-archive/<timestamp>/`). |

### 1.2 User Stories

**As a** user recovering from a corrupted install, **I want** `--reinstall --clean` **so that** I can regenerate AgToosa files from a known generator version.

**As a** security reviewer, **I want** explicit confirmation and archival **so that** clean reinstall cannot run silently.

**As a** Windows user, **I want** PowerShell parity **so that** reinstall behavior matches bash.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a user invokes `--reinstall --clean` THE SYSTEM SHALL require explicit confirmation before modifying generated AgToosa files | Must |
| AC-002 | WHEN clean reinstall proceeds THE SYSTEM SHALL archive existing generated files to a timestamped directory and write a manifest listing archived paths | Must |
| AC-003 | WHEN clean reinstall completes THE SYSTEM SHALL regenerate AgToosa outputs from the current generator version equivalent to a fresh install for the selected platforms | Must |
| AC-004 | WHEN clean reinstall completes THE SYSTEM SHALL rewrite `Docs/agtoosa-lock.json` with the current `AGTOOSA_VERSION`, platforms, and pack pins | Must |
| AC-005 | WHEN user-edited content exists outside AgToosa markers THE SYSTEM SHALL warn that clean reinstall may not preserve those edits and SHALL NOT claim marker-merge preservation | Must |
| AC-006 | WHEN `--reinstall --clean` runs twice without intervening changes THE SYSTEM SHALL be idempotent and report no effective change on the second run | Must |
| AC-007 | WHEN `--reinstall --clean` is implemented THE SYSTEM SHALL provide equivalent behavior in `agtoosa.sh` and `agtoosa.ps1` | Must |
| AC-008 | WHEN help or update docs describe upgrade paths THE SYSTEM SHALL position `--update` as default and `--reinstall --clean` as optional destructive fresh state per ADR-004 | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Clean reinstall runs non-interactively without `--yes` equivalent and deletes files. |
| FM-002 | AC-002 | Archive step skipped; user cannot recover prior generated files. |
| FM-003 | AC-003 | Partial regeneration leaves mixed old/new file set. |
| FM-004 | AC-004 | Lock file not rewritten or written to wrong path. |
| FM-005 | AC-005 | Documentation implies clean reinstall preserves custom edits like `--update`. |
| FM-006 | AC-006 | Second run mutates files unexpectedly. |
| FM-007 | AC-007 | PowerShell missing flag or divergent archive behavior. |
| FM-008 | AC-008 | README lists clean reinstall as default upgrade. |

### 1.5 Out of Scope

- Replacing `--update` or migration wizard (DEV-090+ migration scope)
- Automatic restoration of user edits from archive
- Uninstalling registry packs from remote registry
- `--reinstall` without `--clean` (in-place reinstall semantics undefined here)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| `--reinstall --clean` behavior | generator-enforced after implementation |
| Archive manifest | local filesystem evidence |
| User edit preservation | not guaranteed — explicit warning only |
| Default safe upgrade | remains `--update` marker merge |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `agtoosa.sh` — parse `--reinstall --clean`; confirmation; dispatch clean reinstall
- `agtoosa.ps1` — PowerShell parity
- `lib/install.sh` — archive + regenerate helper (or dedicated `lib/reinstall.sh`)
- `lib/version.sh` / lock writer — rewrite `Docs/agtoosa-lock.json` per DEV-090
- `docs/AgToosa_Update.md` — document optional clean reinstall vs default update
- `template/Docs/AgToosa_Update.md` — mirror
- `tests/agtoosa.bats` — RCL integration tests in isolated fixtures

### 2.2 Data Flow

1. User runs `bash agtoosa.sh --reinstall --clean` (with confirmation flag).
2. CLI warns about non-preservation of unmarked edits; requires confirmation.
3. Existing generated files copied to `.agtoosa/reinstall-archive/<timestamp>/` with manifest.
4. Generator performs fresh install pass for selected platforms.
5. `Docs/agtoosa-lock.json` rewritten with current version and platform list.
6. Summary printed with archive path and lock path.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Silent destructive reinstall | Tampering | Explicit confirmation gate; RCL negative test without confirm. |
| Archive omits sensitive generated file | Information Disclosure | Manifest lists all archived paths; archive dir gitignored if needed. |
| Partial write leaves broken project | Denial of Service | Stage then apply; non-zero exit on failure before declaring success. |
| User mistakes clean reinstall for safe update | Spoofing | Docs and CLI position `--update` as default. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `agtoosa.sh`, `agtoosa.ps1`, install/reinstall lib helpers, update docs, RCL bats
Directories in scope: `lib/`, `docs/`, `template/Docs/`, `tests/`
Dependency gate     : DEV-090 lock path corrections landed
Out of scope        : default update replacement, automatic user-edit restore, remote registry changes

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED reinstall contract
  - [ ] 1.1 Add RCL confirmation, archive, and warning fixtures — _Requirements: AC-001, AC-002, AC-005_
  - [ ] 1.2 Add regeneration, lock rewrite, and idempotency fixtures — _Requirements: AC-003, AC-004, AC-006_
- [ ] **2.** Implement clean reinstall
  - [ ] 2.1 Bash archive + regenerate + lock rewrite — _Requirements: AC-001–AC-006_
  - [ ] 2.2 PowerShell parity — _Requirements: AC-007_
- [ ] **3.** Documentation and evidence
  - [ ] 3.1 Update AgToosa_Update docs for ADR-004 Option C positioning — _Requirements: AC-008_
  - [ ] 3.2 Record RED/GREEN RCL evidence — _Requirements: AC-001–AC-008_

### 3.2 Wave Plan

**Wave 0 (dependency):** DEV-090 lock path green  
**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-104.md`
AC coverage: 8 ACs mapped to 8 RCL test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: archive directory naming at implementation

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-104)
