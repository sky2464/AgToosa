# Spec: DEV-102 — Docs: Offline and Network-Dependency Matrix

> **Story ID:** DEV-102
> **Type:** Docs
> **Epic:** DEV-001 — Core Generator & CLI
> **Status:** 🟦 Todo — Rev4 Wave 3 (enrolled)
> **Estimate:** XS
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

AgToosa is local-first, but several CLI commands can reach the network (registry fetch, public launch-readiness checks, remote install bootstrap). Users and maintainers need one canonical matrix documenting offline capability, optional network dependency, and mitigation (local pack path, cache dir, private mode) per command. DEV-102 publishes that matrix as a single documentation artifact with focused contract tests.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a single offline/network-dependency matrix for AgToosa CLI commands and primary modes. |
| User outcome | A user can determine whether a command works offline, needs network, or has an offline alternative before running it in a restricted environment. |
| Success condition | One matrix document lists CLI commands/modes with dependency class (offline, network-required, network-optional with offline fallback); NET tests verify coverage and forbid contradictory rows. |
| Proof / evidence | NET tests check matrix presence, required command rows, dependency classes, and cross-links from Agent/Registry docs. |
| Non-goals | Implementing new offline modes, package mirrors, or changing command network behavior. |
| Assumptions | `agtoosa.sh` and `agtoosa.ps1` expose the command inventory documented in `AgToosa_Agent.md`; local pack install and `AGTOOSA_REGISTRY_CACHE_DIR` remain offline mitigations. |
| Risks | Matrix drifts when commands are added; PowerShell parity rows are omitted. |
| Unresolved questions | None. |

### 1.2 User Stories

**As an** air-gapped user, **I want** an offline/network matrix **so that** I know which commands I can run without egress.

**As a** maintainer, **I want** one canonical matrix **so that** offline guidance is not scattered across registry, update, and readiness docs.

**As a** security reviewer, **I want** network-optional commands to name their fallback **so that** trust boundaries are explicit.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader opens the network-dependency matrix THE SYSTEM SHALL present one canonical document covering bash and PowerShell CLI entry points | Must |
| AC-002 | WHEN a primary CLI command or mode is listed THE SYSTEM SHALL assign exactly one dependency class: `offline`, `network-required`, or `network-optional` | Must |
| AC-003 | WHEN a command is `network-optional` THE SYSTEM SHALL document the offline fallback or cache/local path if one exists | Must |
| AC-004 | WHEN the matrix is maintained THE SYSTEM SHALL include at minimum: install, update, verify, doctor, registry list/info/install/publish, catalog validate, and launch-readiness public/private modes | Must |
| AC-005 | WHEN Agent or Registry docs mention network behavior THE SYSTEM SHALL link to the canonical matrix instead of maintaining conflicting per-doc tables | Must |
| AC-006 | WHEN CLI commands change THE SYSTEM SHALL fail focused matrix coverage tests until the matrix and cross-links are updated | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Multiple competing matrices drift across docs. |
| FM-002 | AC-002 | A command has ambiguous or missing dependency class. |
| FM-003 | AC-003 | Registry install marked offline without documenting local-pack and cache requirements. |
| FM-004 | AC-004 | New command ships with no matrix row. |
| FM-005 | AC-005 | Registry doc duplicates a stale network table. |
| FM-006 | AC-002 | PowerShell-only command omitted from matrix. |

### 1.5 Out of Scope

- Building a package mirror or corporate proxy integration
- Changing registry fetch implementation
- Network performance or retry policy work
- Telemetry or phone-home documentation (none exists)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Network-dependency matrix | documentation |
| Actual command network behavior | generator/runtime truth |
| Matrix coverage tests | CI-enforced when NET tests run |
| Air-gapped success in every environment | user environment dependent |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/AgToosa_Network_Matrix.md` — canonical CLI network-dependency matrix
- `template/Docs/AgToosa_Network_Matrix.md` — generated-project mirror (if installed to projects)
- `docs/AgToosa_Agent.md` — link to matrix from command overview
- `docs/AgToosa_Registry.md` — replace duplicate offline notes with matrix link where appropriate
- `lib/config.sh` — register matrix doc in `DOCS_FILES` if installed
- `tests/agtoosa.bats` — NET coverage tests

Matrix columns (minimum):

| Command / mode | Bash | PowerShell | Class | Offline fallback / notes |

### 2.2 Data Flow

1. Inventory primary CLI commands from agent and registry documentation.
2. Classify each command with offline/network-required/network-optional and mitigations.
3. Publish single matrix document; add discovery links from Agent and Registry docs.
4. NET tests verify required rows and link presence.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| User assumes verify needs network | Spoofing | Matrix lists verify/doctor as offline where true. |
| Stale matrix hides new network call | Tampering | Coverage tests fail when command inventory changes. |
| Scattered contradictory guidance | Repudiation | One canonical matrix with linking contract. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : network matrix doc, template mirror, Agent/Registry links, `lib/config.sh` registration, NET bats
Directories in scope: `docs/`, `template/Docs/`, `lib/`, `tests/`
Out of scope        : new offline features, registry transport changes, proxy tooling

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED matrix contract
  - [x] 1.1 Add NET required-row and dependency-class fixtures — _Requirements: AC-002, AC-004, AC-006_
  - [x] 1.2 Add cross-link and non-duplication fixtures — _Requirements: AC-005_
- [x] **2.** Author matrix
  - [x] 2.1 Write `AgToosa_Network_Matrix.md` and template mirror — _Requirements: AC-001–AC-004_
  - [x] 2.2 Add Agent/Registry discovery links; register in `DOCS_FILES` if applicable — _Requirements: AC-005_
- [x] **3.** Evidence
  - [x] 3.1 Record RED/GREEN NET evidence — _Requirements: AC-001–AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-102.md`
AC coverage: 6 ACs mapped to 6 NET test IDs
Smoke set: 2 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-102)
