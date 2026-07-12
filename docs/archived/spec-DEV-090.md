# Spec: DEV-090 — Feature: Unified Install/Update Plan Engine + JSON Dry-Run

> **Story ID:** DEV-090
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** 🟦 Todo
> **Estimate:** M
> **Priority:** P0
> **Spec created:** 2026-07-12

## Context

Install dry-run (`lib/dryrun.sh`) and update dry-run (`lib/update.sh`) use separate code paths with similar but inconsistent categorization (overwrite, merge, preserve, skip). Rev4 prioritizes safe upgrades with categorized plans and `--json` output for automation. `docs/updates/rev4-conflict-resolutions.md` §6 requires correcting workflow doc references from `.agtoosa-lock.json` to **`Docs/agtoosa-lock.json`** (code already writes the `Docs/` path). ADR-004 drift for `platforms[]` and pack SHA revalidation is explicitly deferred to DEV-093; this story unifies plan generation and fixes documented lock paths only.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Unify install and update dry-run planning behind `lib/plan.sh` with human and JSON output, and align update workflow docs with the canonical lock file path. |
| User outcome | Operators preview the same categorized plan for fresh install and `--update`, optionally consume JSON in CI/fleet scripts, and read consistent lock-file paths in `AgToosa_Update.md`. |
| Success condition | `lib/plan.sh` drives both install `--dry-run` and `update --dry-run`; JSON dry-run validates against a documented plan schema; `template/Docs/AgToosa_Update.md` and `docs/AgToosa_Update.md` reference `Docs/agtoosa-lock.json` exclusively; PLN bats green. |
| Proof / evidence | PLN bats for plan parity, categories, JSON schema, idempotent second dry-run, and doc path fixes; test-plan RED/GREEN. |
| Non-goals | Transactional apply, rollback manifest (later wave), ADR-004 platforms[] revalidation (DEV-093), automatic apply without user confirmation. |
| Assumptions | Existing merge/backup semantics in `lib/copy.sh` and `lib/update.sh` remain authoritative for real apply; plan engine is read-only. |
| Risks | JSON plan drifts from actual apply behavior; refactor breaks interactive install; missed stale lock path references outside Update doc. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** maintainer planning an update, **I want** a categorized dry-run plan **so that** I know which files overwrite, merge, preserve, or need manual action.

**As an** automation engineer, **I want** `--dry-run --format json` **so that** fleet scripts can gate updates without parsing colored terminal text.

**As a** documentation reader, **I want** lock file paths to match generator behavior **so that** I do not search the wrong directory during troubleshooting.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `lib/plan.sh` is sourced THE SYSTEM SHALL expose a single function that computes categorized file actions for a target project path and operation (`install` \| `update`) | Must |
| AC-002 | WHEN `agtoosa.sh --dry-run` runs for a fresh install THE SYSTEM SHALL use `lib/plan.sh` instead of inline logic in `lib/dryrun.sh` and SHALL print human-readable lines equivalent to current categories (new, overwrite, merge, backup+replace, skip, up-to-date) | Must |
| AC-003 | WHEN `agtoosa.sh --update --dry-run` runs THE SYSTEM SHALL use the same `lib/plan.sh` categorization rules as install dry-run for overlapping file types | Must |
| AC-004 | WHEN `--dry-run --format json` is requested THE SYSTEM SHALL emit one JSON document with `operation`, `project_path`, `generator_version`, and `actions[]` entries containing `path`, `category`, and `detail` | Must |
| AC-005 | WHEN a second identical dry-run executes without intervening changes THE SYSTEM SHALL produce an equivalent plan (idempotent preview) | Must |
| AC-006 | WHEN `template/Docs/AgToosa_Update.md` and `docs/AgToosa_Update.md` reference the lock file THE SYSTEM SHALL use the path `Docs/agtoosa-lock.json` exclusively and SHALL NOT reference `.agtoosa-lock.json` at repository root | Must |
| AC-007 | WHEN `template/Docs/AgToosa_Init.md` references the lock file in install detection prose THE SYSTEM SHALL use `Docs/agtoosa-lock.json` for consistency with rev4-conflict-resolutions §6 | Must |
| AC-008 | WHEN dry-run JSON is emitted THE SYSTEM SHALL write JSON to stdout only and SHALL NOT perform file mutations | Must |
| AC-009 | WHEN `tests/agtoosa.bats` runs DEV-090 coverage THE SYSTEM SHALL assert install/update plan parity, JSON parseability, lock path doc fixes, and idempotent second dry-run | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Plan logic duplicated; install and update diverge again. |
| FM-002 | AC-002 | Install dry-run regresses merge/skip messaging. |
| FM-003 | AC-003 | Update dry-run omits files install dry-run would show. |
| FM-004 | AC-004 | JSON interleaved with human color codes; parsers fail. |
| FM-005 | AC-005 | Second dry-run shows different categories without code changes. |
| FM-006 | AC-006 | Update workflow still cites root `.agtoosa-lock.json`; users grep wrong path. |
| FM-007 | AC-008 | Dry-run accidentally writes files when JSON requested. |

### 1.5 Out of Scope

- Rollback manifest and timestamped backup bundles (later Rev4 story).
- Major-version migration wizard interactive prompts.
- `platforms[]` lock revalidation and pack SHA policy (DEV-093).
- PowerShell plan JSON parity (DEV-105 may follow).
- Changing actual install/update apply semantics beyond plan extraction.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Dry-run plan preview | local machine read-only |
| JSON plan output | local machine; CI-enforced when PLN bats run |
| Apply mutations | unchanged generator behavior |
| Lock file authority table | documentation alignment (rev4 §5 full table in DEV-093) |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `lib/plan.sh` — `compute_agtoosa_plan(project_path, operation)` returning categorized actions; `emit_plan_human()` and `emit_plan_json()`.
- `docs/schemas/plan-result-v1.json` — JSON Schema for dry-run plan documents (optional companion to inline contract in plan.sh header).

Files to change:

- `lib/dryrun.sh` — delegate to `lib/plan.sh` for preview lines.
- `lib/update.sh` — use `lib/plan.sh` for `--dry-run` branch before `run_update`.
- `agtoosa.sh` — source `plan.sh`; accept `--format json` with `--dry-run` for install and update.
- `template/Docs/AgToosa_Update.md`, `docs/AgToosa_Update.md` — lock path corrections.
- `template/Docs/AgToosa_Init.md`, `docs/AgToosa_Init.md` — lock path in detection prose.
- `tests/agtoosa.bats` — PLN-001–PLN-009 coverage.

Key interfaces:

- `compute_agtoosa_plan "$PROJECT_PATH" "install"|"update"` — bash array or temp file of actions.
- Categories: `new`, `overwrite`, `merge`, `backup_replace`, `skip`, `up_to_date`, `manual` (reserved for docs-only actions).

### 2.2 Data Flow

1. User invokes `agtoosa.sh --dry-run` or `agtoosa.sh --update --dry-run` (optional `--format json`).
2. `agtoosa.sh` sets operation mode and sources `lib/plan.sh`.
3. Plan engine iterates template ship manifest vs target tree using shared rules from copy/version helpers.
4. Human mode prints colored lines via `emit_plan_human`; JSON mode prints single document via `emit_plan_json`.
5. No files mutated; exit `0` unless invalid flags or missing project path on update.
6. Update workflow docs reference `Docs/agtoosa-lock.json` for lock metadata reads.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Plan JSON leaks secrets from target repo | Information Disclosure | Emit paths and categories only; no file contents. |
| Plan engine evaluates untrusted project files | Elevation of Privilege | Read metadata/version markers only; no source execution. |
| JSON plan trusted for apply without user review | Tampering | Dry-run remains non-mutating; apply still requires separate command. |
| Incorrect plan causes wrong apply expectation | Repudiation | PLN parity tests lock install/update dry-run equivalence class. |
| Huge project tree stalls plan | Denial of Service | Stream manifest from ship dir; reasonable timeouts in CI. |
| Doc path fix points users to wrong lock location | Spoofing | Grep-based PLN tests forbid `.agtoosa-lock.json` in Update/Init docs. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `lib/plan.sh`, `lib/dryrun.sh`, `lib/update.sh`, `agtoosa.sh`, `template/Docs/AgToosa_Update.md`, `template/Docs/AgToosa_Init.md`, `docs/AgToosa_Update.md`, `docs/AgToosa_Init.md`, `tests/agtoosa.bats`
Directories in scope: `lib/`, `template/Docs/`, `docs/`, `tests/`
Out of scope        : apply semantics rewrite, DEV-093 lock revalidation, PS1 plan engine, rollback manifest

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Plan engine RED coverage
  - [ ] 1.1 Add PLN bats for install/update dry-run parity and JSON parseability — _Requirements: AC-002, AC-003, AC-004, AC-009_
  - [ ] 1.2 Add PLN bats for idempotent second dry-run and no-mutation guard — _Requirements: AC-005, AC-008, AC-009_
  - [ ] 1.3 Add PLN doc grep bats for `Docs/agtoosa-lock.json` path — _Requirements: AC-006, AC-007, AC-009_
- [ ] **2.** Unified plan implementation
  - [ ] 2.1 Implement `lib/plan.sh` with shared categorization — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 2.2 Wire `lib/dryrun.sh` and `lib/update.sh` to plan engine — _Requirements: AC-002, AC-003, AC-008_
  - [ ] 2.3 Add `--format json` to `agtoosa.sh` dry-run paths — _Requirements: AC-004, AC-008_
- [ ] **3.** Documentation alignment
  - [ ] 3.1 Fix lock file paths in Update and Init workflow docs — _Requirements: AC-006, AC-007_
- [ ] **4.** Evidence
  - [ ] 4.1 Record PLN RED/GREEN evidence — _Requirements: AC-001–AC-009_

### 3.2 Wave Plan

**Wave 1 (sequential within story — shared bats file):** 1.1 → 1.2 → 1.3
**Wave 2 (sequential after Wave 1):** 2.1
**Wave 3 (parallel after Wave 2):** 2.2, 2.3
**Wave 4 (sequential after Wave 3):** 3.1
**Wave 5 (sequential after Wave 4):** 4.1

> Cross-story: Wave 1a fan-out allows DEV-086 · DEV-090 · DEV-105 in parallel; owned files are disjoint across stories.

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-090.md`
AC coverage: 9 ACs mapped to 9 PLN test IDs
Smoke set: 3 tests tagged `@smoke`

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` (PLN parity/JSON) | — | PLN-002–004 stubs | 1 | `bats tests/agtoosa.bats -f "DEV-090\|PLN-"` |
| PKG-1.2 | 1 | — | `tests/agtoosa.bats` (PLN idempotency) | — | PLN-005/008 stubs | 2 | `bats tests/agtoosa.bats -f "PLN-005\|PLN-008"` |
| PKG-1.3 | 1 | — | `tests/agtoosa.bats` (PLN docs) | — | PLN-006/007 stubs | 3 | `bats tests/agtoosa.bats -f "PLN-006\|PLN-007"` |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2, PKG-1.3 | `lib/plan.sh`, `docs/schemas/plan-result-v1.json` | Wave 1 RED | plan engine + schema | 4 | `test -f lib/plan.sh && bats tests/agtoosa.bats -f "PLN-001"` |
| PKG-2.2 | 3 | PKG-2.1 | `lib/dryrun.sh`, `lib/update.sh` | `lib/plan.sh` | dry-run delegation | 5 | `bats tests/agtoosa.bats -f "PLN-002\|PLN-003\|PLN-008"` |
| PKG-2.3 | 3 | PKG-2.1 | `agtoosa.sh` | `lib/plan.sh` | `--format json` dry-run | 6 | `bats tests/agtoosa.bats -f "PLN-004"` |
| PKG-3.1 | 4 | PKG-2.2, PKG-2.3 | `template/Docs/AgToosa_Update.md`, `docs/AgToosa_Update.md`, `template/Docs/AgToosa_Init.md`, `docs/AgToosa_Init.md` | Wave 3 wiring | lock path docs | 7 | `bats tests/agtoosa.bats -f "PLN-006\|PLN-007"` |
| PKG-4.1 | 5 | PKG-3.1 | `docs/AgToosa_TestPlan-DEV-090.md` | GREEN PLN | RED/GREEN evidence | 8 | `grep -q GREEN docs/AgToosa_TestPlan-DEV-090.md` |

> Wave 1 note: PKG-1.1–1.3 share `tests/agtoosa.bats` — sequential within Wave 1. Wave 3: PKG-2.2 and PKG-2.3 are file-disjoint (`lib/*.sh` vs `agtoosa.sh`) and may run in parallel.

## ✅ Spec Approved

Approved: 2026-07-12 09:00
Enrollment: Rev4 Wave 1 — unified plan engine
