# Spec: DEV-099 — Docs: Core vs Optional Pack Boundary

> **Story ID:** DEV-099
> **Type:** Docs
> **Epic:** DEV-002 — Lifecycle & Workflow Primitives
> **Status:** ⬜ Backlog
> **Estimate:** XS
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-077 (shipped authoring and onboarding surfaces)
> **Extends:** DEV-077 — documents what is core install output versus optional pack/registry content

## Context

AgToosa's generator installs a large `Docs/` tree and many platform adapter files from `lib/config.sh` arrays (`DOCS_FILES`, `OPTIONAL_TEMPLATE_FILES`, `CONTEXT_FILES`). Rev4 requires a small core contract: lifecycle primitives belong in core; stack, compliance, and specialty behavior belongs in packs. DEV-099 publishes `Docs/AgToosa_Core_Contract.md` (and maintainer mirror) tied directly to those arrays so documentation and generator inventory cannot silently diverge.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a canonical core contract document that maps core versus optional install surfaces to `lib/config.sh` file-list arrays. |
| User outcome | A user or contributor can determine which files are core lifecycle output, which are optional platform adapters, and which capabilities require packs without reading generator source. |
| Success condition | `AgToosa_Core_Contract.md` exists in template and maintainer docs; it lists core commands and file inventories derived from config arrays; focused tests fail when arrays and document drift. |
| Proof / evidence | CORE tests verify document presence, array parity, core command inventory, and honest pack-boundary language. |
| Non-goals | Changing install behavior, removing optional files, or redefining registry trust rules. |
| Assumptions | `lib/config.sh` remains the authoritative install inventory; core lifecycle is Init, Spec, Build, Review, Ship, Verify, Doctor per Rev4. |
| Risks | Document lists stale paths after generator changes; optional files are mislabeled as core. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** new adopter, **I want** a core contract document **so that** I know the minimum AgToosa surface before adding packs.

**As a** pack author, **I want** explicit optional boundaries **so that** I do not duplicate core lifecycle files in packs.

**As a** maintainer, **I want** array-to-doc parity tests **so that** inventory drift is caught in CI.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader opens `AgToosa_Core_Contract.md` THE SYSTEM SHALL name the seven core lifecycle commands (Init, Spec, Build, Review, Ship, Verify, Doctor) and SHALL state that specialty behavior belongs in packs | Must |
| AC-002 | WHEN the core contract lists installed documentation THE SYSTEM SHALL derive the `Docs/` inventory from `DOCS_FILES` in `lib/config.sh` without manual path invention | Must |
| AC-003 | WHEN the core contract lists optional platform surfaces THE SYSTEM SHALL derive optional adapter paths from `OPTIONAL_TEMPLATE_FILES` in `lib/config.sh` | Must |
| AC-004 | WHEN the core contract lists context files THE SYSTEM SHALL derive context inventory from `CONTEXT_FILES` in `lib/config.sh` | Must |
| AC-005 | WHEN `lib/config.sh` arrays change THE SYSTEM SHALL fail focused parity tests until `AgToosa_Core_Contract.md` and its template mirror are updated | Must |
| AC-006 | WHEN the contract describes enforcement THE SYSTEM SHALL distinguish generator-installed core files, optional adapters, registry pack additions, and manual maintainer actions | Must |
| AC-007 | WHEN README or authoring guides reference core scope THE SYSTEM SHALL link to `AgToosa_Core_Contract.md` without duplicating the full inventory inline | Should |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Core contract omits a lifecycle command or implies packs are required for baseline use. |
| FM-002 | AC-002–AC-004 | Document lists paths not present in config arrays or omits newly added array entries. |
| FM-003 | AC-005 | Generator adds files without updating the contract or tests. |
| FM-004 | AC-006 | Optional adapters are labeled "core-enforced lifecycle." |
| FM-005 | AC-007 | README carries a second full inventory that drifts. |

### 1.5 Out of Scope

- Shrinking `DOCS_FILES` or removing optional adapters
- Changing registry install or pack validation behavior
- Defining community versus verified pack labels (DEV-101)
- Automated pack generation

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Core contract document | documentation |
| `lib/config.sh` arrays | generator source of truth |
| Array-to-doc parity | CI-enforced when CORE tests run |
| Pack content boundaries | registry + pack docs; referenced, not redefined |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/AgToosa_Core_Contract.md` — canonical core versus optional boundary
- `template/Docs/AgToosa_Core_Contract.md` — generated-project mirror
- `lib/config.sh` — register new doc in `DOCS_FILES` if not already present
- `README.md` — concise link to core contract (no full inventory copy)
- `tests/agtoosa.bats` — CORE parity and inventory tests

### 2.2 Data Flow

1. Read `DOCS_FILES`, `OPTIONAL_TEMPLATE_FILES`, and `CONTEXT_FILES` from `lib/config.sh`.
2. Author `AgToosa_Core_Contract.md` with core commands section and array-derived inventories.
3. CORE tests compare document sections to live arrays.
4. On array change, tests fail until document and template mirror update.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Documentation invents paths not installed by generator | Spoofing | Array-derived inventories only; parity tests. |
| Optional surface presented as mandatory core | Tampering | Explicit enforcement-class table in contract. |
| Inventory drift undetected after release | Repudiation | CI parity tests on config array changes. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `docs/AgToosa_Core_Contract.md`, template mirror, `lib/config.sh` registration, README link, CORE bats
Directories in scope: `docs/`, `template/Docs/`, `lib/`, `tests/`
Out of scope        : install behavior changes, pack trust labeling, registry commands

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED parity contract
  - [ ] 1.1 Add CORE document presence and array parity fixtures — _Requirements: AC-002–AC-005_
  - [ ] 1.2 Add core-command inventory and enforcement-class fixtures — _Requirements: AC-001, AC-006_
- [ ] **2.** Author core contract
  - [ ] 2.1 Write `AgToosa_Core_Contract.md` and template mirror from config arrays — _Requirements: AC-001–AC-004, AC-006_
  - [ ] 2.2 Register doc in `DOCS_FILES` and add README discovery link — _Requirements: AC-007_
- [ ] **3.** Evidence
  - [ ] 3.1 Record RED/GREEN CORE evidence — _Requirements: AC-001–AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-099.md`
AC coverage: 7 ACs mapped to 7 CORE test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-099)
