# Spec: DEV-025 — Maintainer Docs Path Normalization

> **Story ID:** DEV-025
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v5.0.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-024 review (Engineering Manager warning) noted that maintainer workflow mirrors under `docs/AgToosa_*.md` still mix `Docs/` (generated-project convention) and `docs/` (on-disk paths in the AgToosa repository). DEV-011 and DEV-024 already use **Maintainer Dogfood Mode** callouts and `docs/` in readiness gates, but core workflow files (`AgToosa_Status.md`, `AgToosa_Spec.md`, `AgToosa_Build.md`, etc.) inherited `Docs/` prefixes when synced from `template/Docs/`.

Agents executing `/agtoosa-*` in this repository read `docs/AgToosa_*.md` directly. Inconsistent paths cause failed file lookups, confused cross-repo copy-paste, and false readiness signals. This chore normalizes maintainer mirrors to **`docs/`** everywhere while leaving **`template/Docs/`** unchanged for generated installs.

This story opens the **v5.0.0** milestone as the first enrolled DEV-002 workflow-templates epic item after the v4.14.x maintainer parity train.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Normalize on-disk path references in maintainer workflow mirrors from `Docs/` to `docs/`. |
| User outcome | Maintainers and agents running AgToosa workflows in this repo see one consistent path vocabulary matching the filesystem. |
| Success condition | All in-scope `docs/AgToosa_*.md` workflow mirrors use `docs/` for repo-local paths; `docs/agtoosa-maintainer.md` documents the dual convention; bats **PN1–PN5** green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "PN[1-5]:"` green; `rg 'Docs/' docs/AgToosa_{Agent,Build,Init,Spec,Ship,Status}.md` returns no matches (except explicit cross-context notes). |
| Non-goals | Renaming the on-disk `docs/` directory; changing `template/Docs/` or platform adapters; bulk-rewriting archived specs or historical test plans. |
| Assumptions | Generated projects continue to install `Docs/` (capital D) per generator behavior. |
| Risks | Over-eager replace could break intentional `template/Docs/` references in maintainer docs; mitigated by scoped file list and PN5 regression. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** workflow docs in `docs/` to reference `docs/Master-Plan.md` and sibling paths consistently **so that** agents do not look for non-existent `Docs/` directories in this repository.

**As an** AgToosa maintainer, **I want** the path convention documented in `docs/agtoosa-maintainer.md` **so that** future mirror syncs from `template/Docs/` preserve the correct prefix per operating context.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN any in-scope maintainer workflow mirror under `docs/AgToosa_*.md` references a file in this repository THE SYSTEM SHALL use the `docs/` path prefix (lowercase) for Master-Plan, Context, archived specs, adr, and workflow doc paths | Must |
| AC-002 | WHEN `docs/agtoosa-maintainer.md` is read THE SYSTEM SHALL document **Generated Project Mode** (`Docs/`) vs **Maintainer Dogfood Mode** (`docs/`) path conventions with at least one example per mode | Must |
| AC-003 | WHEN `template/Docs/` or generated-install paths are referenced in maintainer docs THE SYSTEM SHALL label them explicitly as template or generated-project paths and SHALL NOT imply they exist on disk at `Docs/` in this repository | Must |
| AC-004 | WHEN DEV-025 ships THE SYSTEM SHALL add bats **PN1–PN5** asserting maintainer path normalization without weakening template parity tests (e.g. R4, B1) | Must |
| AC-005 | WHEN `docs/Master-Plan.md` is updated for v5.0.0 THE SYSTEM SHALL enroll DEV-025 in **Active Cycle** under milestone `v5.0.0` and set DEV-002 epic **Current** to this story | Must |

### 1.4 Out of Scope

- `template/**` file edits (except if a one-line cross-reference is required — prefer none)
- Platform adapters (`.cursor/`, `.claude/`, etc.) in `template/`
- Renaming `docs/` → `Docs/` on disk (case-only directory rename)
- Historical `docs/archived/spec-*.md` and `docs/AgToosa_TestPlan-DEV-*.md` for shipped stories (unless a broken self-reference is found)
- Generator runtime (`agtoosa.sh`, `lib/*.sh`) behavior changes

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `docs/AgToosa_Agent.md` | Replace `Docs/` → `docs/` for repo-local paths; keep explicit `template/Docs/` when citing shipped pack |
| `docs/AgToosa_{Build,Init,Spec,Ship,Status,Review,QA,Task,Update,Debug,Revert,Claude,Gemini,Skills,Governance,StatusGuide,Readiness,Registry,Concise}.md` | Same normalization in workflow mirrors |
| `docs/SPEC-FORMAT.md`, `docs/CONTEXT-FORMAT.md`, `docs/ADR-FORMAT.md`, `docs/DEEPENING.md`, `docs/LANGUAGE.md` | Maintainer-facing format guides: use `docs/` in examples; add one-line Generated vs Maintainer path note where missing |
| `docs/agtoosa-maintainer.md` | New **Path conventions** subsection under Maintainer Dogfood Mode |
| `docs/Master-Plan.md` | Enroll DEV-025; v5.0.0 active cycle; epic DEV-002 current |
| `tests/agtoosa.bats` | PN1–PN5 focused tests |
| `docs/AgToosa_TestPlan-DEV-025.md` | AC → test mapping |
| `CHANGELOG.md` | `[Unreleased]` planned entry |

**Normalization rules:**

1. `Docs/Master-Plan.md` → `docs/Master-Plan.md`
2. `Docs/Context/` → `docs/Context/`
3. `Docs/archived/` → `docs/archived/`
4. `Docs/adr/` → `docs/adr/`
5. `Docs/AgToosa_*.md` → `docs/AgToosa_*.md` (when referring to maintainer copies)
6. `Docs/SPEC-FORMAT.md` etc. → `docs/SPEC-FORMAT.md`
7. Leave `template/Docs/...` and phrases like "shipped in `template/Docs/`" unchanged
8. Leave `docs/AgToosa_TestPlan-DEV-0XX.md` files that describe **template** adapter tests unchanged unless they document maintainer dogfood

### 2.2 Data Flow

1. Maintainer runs `/agtoosa-spec` → agent reads `docs/AgToosa_Spec.md` → paths point to `docs/archived/spec-*.md` and `docs/Master-Plan.md`.
2. `/agtoosa-build` and `/agtoosa-status` read the same consistent paths.
3. Bats PN* grep-lock critical workflow files so a blind template sync cannot reintroduce `Docs/` in maintainer mirrors without failing CI.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent reads wrong path and skips Master-Plan update | Repudiation | AC-001, AC-004 PN2–PN4 |
| Maintainer normalizes `template/Docs/` by mistake | Tampering | AC-003 explicit labeling; PN5 template regression |
| Dual convention undocumented; drift recurs on next sync | Denial of Service | AC-002 maintainer guide section |
| Bulk replace breaks intentional cross-repo citations | Information Disclosure | Scoped file list; manual review of exceptions in AC-003 |

### 2.4 Build Scope

Files in scope: `docs/AgToosa_*.md` (workflow mirrors listed in §2.1), `docs/SPEC-FORMAT.md`, `docs/CONTEXT-FORMAT.md`, `docs/ADR-FORMAT.md`, `docs/DEEPENING.md`, `docs/LANGUAGE.md`, `docs/agtoosa-maintainer.md`, `docs/Master-Plan.md`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-025.md`, `docs/AgToosa_TestPlan-DEV-025.md`, `CHANGELOG.md`

Directories in scope: `docs/`, `tests/`

Out of scope: `template/**`, `lib/**`, `agtoosa.sh`, `agtoosa.ps1`, `docs/archived/spec-DEV-*.md` (historical), `docs/AgToosa_TestPlan-DEV-0*.md` (historical template-focused plans)

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Path convention documentation
  - [x] 1.1 Add **Path conventions** subsection to `docs/agtoosa-maintainer.md` (Generated `Docs/` vs Maintainer `docs/`) — _AC-002_
  - [x] 1.2 Update format guides (`SPEC-FORMAT`, `CONTEXT-FORMAT`, `ADR-FORMAT`, `DEEPENING`, `LANGUAGE`) with maintainer `docs/` examples — _AC-002_
- [x] **2.** Workflow mirror normalization
  - [x] 2.1 Normalize core phase docs: `AgToosa_{Agent,Spec,Build,Review,Ship,Status}.md` — _AC-001, AC-003_
  - [x] 2.2 Normalize utility docs: `AgToosa_{Init,QA,Task,Update,Debug,Revert,Claude,Gemini,Skills,Governance,StatusGuide,Readiness,Registry,Concise}.md` — _AC-001_
  - [x] 2.3 Grep audit: zero stray `Docs/` in scope files except allowed `template/Docs/` citations — _AC-001, AC-003_
- [x] **3.** Bats PN1–PN5 and enrollment
  - [x] 3.1 Implement PN1–PN5 in `tests/agtoosa.bats` — _AC-004_
  - [x] 3.2 Add `docs/AgToosa_TestPlan-DEV-025.md` — _AC-004_
  - [x] 3.3 Run `bats tests/agtoosa.bats -f "PN[1-5]:"` and record evidence — _AC-004_
  - [x] 3.4 Confirm `docs/Master-Plan.md` v5.0.0 enrollment (this spec) — _AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1  
**Wave 2 (parallel):** 1.2, 2.2  
**Wave 3 (sequential):** 2.3, 3.1, 3.2, 3.3, 3.4

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-025.md`

## ✅ Spec Approved

Approved: 2026-05-24
