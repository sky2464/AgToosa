# Spec: DEV-024 — Maintainer Status Readiness Doc Parity

> **Story ID:** DEV-024
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.14.1 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-009 shipped `/agtoosa-status readiness` and `Docs/AgToosa_Readiness.md` in the **template pack** only; maintainer `docs/` mirrors were explicitly out of scope. The AgToosa repository dogfoods workflows from `docs/AgToosa_Status.md`, which still lacks Part 1.5 readiness, lists `readiness` only in the typo helper, and has no `docs/AgToosa_Readiness.md`. Maintainer `/agtoosa-status` therefore under-reports health versus generated projects and contradicts R4-style contract tests that apply to `template/Docs/`.

DEV-013 established the pattern: align `docs/AgToosa_*.md` with `template/Docs/` for dogfood surfaces that agents execute directly. This story applies that pattern to status + readiness, with a **Maintainer Dogfood Mode** callout instead of copying Generated Project Mode verbatim.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Bring maintainer `docs/AgToosa_Status.md` and `docs/AgToosa_Readiness.md` to parity with the shipped template readiness contract. |
| User outcome | Maintainers running `/agtoosa-status` or `/agtoosa-status readiness` in this repo get the same seven-gate audit and health deductions as downstream generated projects. |
| Success condition | Part 1.5 + readiness sub-command present in `docs/AgToosa_Status.md`; `docs/AgToosa_Readiness.md` exists with maintainer-appropriate version-parity gate; MD1–MD5 bats green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "MD[1-5]:"` green; manual `/agtoosa-status` shows Initial Product Readiness table on full dashboard. |
| Non-goals | Changing template pack behavior; new platform adapters; runtime generator changes; re-syncing every `docs/AgToosa_*.md` mirror. |
| Assumptions | `template/Docs/AgToosa_Status.md` and `AgToosa_Readiness.md` remain canonical for generated installs. |
| Risks | Blind copy of Generated Project Mode wording confuses maintainer agents; mitigated by explicit Maintainer Dogfood callout. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** `/agtoosa-status readiness` documented and executable from `docs/` **so that** dogfood health checks match the product we ship.

**As an** AgToosa maintainer, **I want** bats to lock maintainer/template status-readiness parity **so that** DEV-009 regressions cannot recur in `docs/` mirrors.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/AgToosa_Status.md` is read THE SYSTEM SHALL define `/agtoosa-status readiness`, Part 1.5 seven-gate audit, readiness health deductions, and Part 5.5 mapping consistent with `template/Docs/AgToosa_Status.md` | Must |
| AC-002 | WHEN `docs/AgToosa_Readiness.md` exists THE SYSTEM SHALL provide the seven-gate checklist and workflow-vs-generator matrix aligned with the template, with gate 7 referencing `AGTOOSA_VERSION` / `CHANGELOG.md` / `docs/Master-Plan.md` Milestone for this repository | Must |
| AC-003 | WHEN `docs/AgToosa_Status.md` describes operating context THE SYSTEM SHALL use **Maintainer Dogfood Mode** language (not imply this repo is a generic generated app) and SHALL point to `docs/agtoosa-maintainer.md` | Must |
| AC-004 | WHEN DEV-024 ships THE SYSTEM SHALL add bats **MD1–MD5** asserting maintainer status/readiness parity without weakening existing R4 template assertions | Must |
| AC-005 | WHEN the full `/agtoosa-status` dashboard runs in maintainer dogfood THE SYSTEM SHALL include the Initial Product Readiness table after plan findings (read-only) | Should |

### 1.4 Out of Scope

- Template or platform adapter edits (already shipped in DEV-009)
- `lib/config.sh` inventory changes
- Programmatic readiness enforcement in `agtoosa.sh`
- Bulk sync of unrelated `docs/AgToosa_*.md` files

## 2. Design

### 2.1 Architecture Blueprint

| File | Change |
|------|--------|
| `docs/AgToosa_Status.md` | Merge Part 1.5, sub-command table, health-score readiness deductions, Part 5.5 mapping, sub-command output rules from template; add Maintainer Dogfood callout |
| `docs/AgToosa_Readiness.md` | New maintainer mirror of `template/Docs/AgToosa_Readiness.md` with gate 7 scoped to generator version parity |
| `tests/agtoosa.bats` | MD1–MD5 focused parity tests |
| `docs/Master-Plan.md` | Story enrollment (this spec) |
| `CHANGELOG.md` | `[Unreleased]` planned entry |

### 2.2 Data Flow

1. Maintainer invokes `/agtoosa-status` in Cursor (or other surface) → adapter reads `docs/AgToosa_Status.md`.
2. Agent runs Part 1 (Master-Plan), Part 1.5 (readiness gates via `docs/AgToosa_Readiness.md`), Part 2 (git), Part 3 (orphans).
3. Health score applies −5 per failed readiness gate (cap −35) plus existing category rules.
4. Bats MD* grep-lock critical strings so template and maintainer docs cannot drift silently.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Maintainer agents skip readiness because docs omit Part 1.5 | Repudiation | AC-001, AC-004 bats |
| Wrong operating-context wording causes maintainer to treat repo as downstream app | Spoofing | AC-003 Maintainer Dogfood callout |
| Doc-only change ships without regression signal | Denial of Service | AC-004 MD1–MD5 |
| Readiness gate 7 compares wrong version sources | Tampering | AC-002 explicit `AGTOOSA_VERSION` + Milestone + CHANGELOG mapping |

### 2.4 Build Scope

Files in scope: `docs/AgToosa_Status.md`, `docs/AgToosa_Readiness.md`, `tests/agtoosa.bats`, `docs/Master-Plan.md`, `CHANGELOG.md`, `docs/archived/spec-DEV-024.md`, `docs/AgToosa_TestPlan-DEV-024.md`

Directories in scope: `docs/`, `tests/`

Out of scope: `template/**`, `lib/config.sh`, `agtoosa.sh`, `agtoosa.ps1`, platform adapters

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Maintainer status doc sync
  - [x] 1.1 Merge Part 1.5, readiness sub-command, health deductions, and Part 5.5 from template into `docs/AgToosa_Status.md` — _AC-001_
  - [x] 1.2 Add Maintainer Dogfood Mode callout (reference `docs/agtoosa-maintainer.md`) — _AC-003_
- [x] **2.** Maintainer readiness checklist
  - [x] 2.1 Create `docs/AgToosa_Readiness.md` from template with gate 7 scoped to `AGTOOSA_VERSION` / Milestone / CHANGELOG — _AC-002_
- [x] **3.** Bats MD1–MD5
  - [x] 3.1 Implement MD1–MD5 in `tests/agtoosa.bats` — _AC-004_
  - [x] 3.2 Add `docs/AgToosa_TestPlan-DEV-024.md` — _AC-004_
  - [x] 3.3 Run `bats tests/agtoosa.bats -f "MD[1-5]:"` and record evidence — _AC-004, AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1  
**Wave 2 (sequential):** 1.2, 3.1, 3.2, 3.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-024.md`

## ✅ Spec Approved

Approved: 2026-05-24
