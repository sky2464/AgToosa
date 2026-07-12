# Spec: DEV-098 — Docs: Navigation by User Job

> **Story ID:** DEV-098
> **Type:** Docs
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟦 Todo — Rev4 Wave 3 (enrolled)
> **Estimate:** XS
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-076 (shipped static documentation site proof)
> **Extends:** DEV-076 — adds job-oriented navigation without a second documentation source

## Context

DEV-076 proved that canonical `docs/` markdown can render as a static GitHub Pages artifact without duplicating guide bodies. `docs/index.md` currently offers only a minimal "Start here" section. Rev4 requires documentation organized by user job — Start, Use, Trust, Adapt, Maintain — as a navigation layer over existing markdown, not a rewrite of canonical guides.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Restructure `docs/index.md` into five job-oriented sections that link to canonical guides without duplicating their bodies. |
| User outcome | A reader can find the right guide by what they are trying to do (start, use daily workflow, evaluate trust, adapt with packs, maintain upgrades) from one landing page and the static site. |
| Success condition | `docs/index.md` contains Start, Use, Trust, Adapt, and Maintain sections; each entry links to an existing canonical markdown path; SITE tests prove no guide-body duplication and Pages build still passes. |
| Proof / evidence | NAV tests cover section inventory, link resolution, non-duplication, and static-site compatibility under `/AgToosa/`. |
| Non-goals | Rewriting canonical guides, adding search, analytics, accounts, or a new documentation platform. |
| Assumptions | DEV-076 workflow and SITE tests remain authoritative for build-only proof; canonical content stays under `docs/`. |
| Risks | Landing page becomes a second maintained copy of guide content; broken relative links under project Pages base path. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** new user, **I want** a Start section on the docs landing page **so that** I can reach install and first-15 proof without hunting filenames.

**As a** daily practitioner, **I want** Use and Trust sections **so that** lifecycle and verification guides are grouped by job.

**As a** maintainer, **I want** Adapt and Maintain sections **so that** packs, upgrades, and doctor guidance are discoverable from one index.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader opens `docs/index.md` THE SYSTEM SHALL present five top-level job sections named Start, Use, Trust, Adapt, and Maintain in that order | Must |
| AC-002 | WHEN a section lists a guide THE SYSTEM SHALL link to the guide's canonical markdown path under `docs/` and SHALL NOT embed a maintained duplicate of the guide body | Must |
| AC-003 | WHEN the Start section is rendered THE SYSTEM SHALL link at minimum to first-15 proof, install/update entry points, and agent operating context | Must |
| AC-004 | WHEN the Use section is rendered THE SYSTEM SHALL link at minimum to spec, build, review, ship, and verify lifecycle guides | Must |
| AC-005 | WHEN the Trust section is rendered THE SYSTEM SHALL link at minimum to verification, registry trust boundary, and evidence or security boundary docs | Must |
| AC-006 | WHEN the Adapt section is rendered THE SYSTEM SHALL link at minimum to registry/catalog authoring and pack guidance | Must |
| AC-007 | WHEN the Maintain section is rendered THE SYSTEM SHALL link at minimum to update, doctor, uninstall/revert, and contributing or maintainer guidance | Must |
| AC-008 | WHEN the static documentation site builds THE SYSTEM SHALL render the updated landing page under the repository Pages base path without breaking representative internal links | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | A section is missing, misnamed, or out of order. |
| FM-002 | AC-002 | Landing page copies substantive guide paragraphs that drift. |
| FM-003 | AC-003–AC-007 | A required job area has no link to its canonical owner doc. |
| FM-004 | AC-008 | Root-relative links work in GitHub preview but fail under `/AgToosa/`. |
| FM-005 | AC-002 | A link points to a non-existent markdown path. |

### 1.5 Out of Scope

- Rewriting canonical markdown for site theme or SEO
- Full information architecture beyond the five job sections
- Hosted search, comments, analytics, or authentication
- Committing generated HTML or `_site/` output
- Automatically enabling GitHub Pages repository settings

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Job-oriented landing navigation | documentation |
| Canonical guide bodies | unchanged source files under `docs/` |
| Static build on matching pull requests | CI-enforced when DEV-076 workflow runs |
| Site adoption or usefulness | unproven product outcome |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/index.md` — five job sections with canonical links only
- `tests/agtoosa.bats` — NAV inventory, link, non-duplication, and SITE regression checks

No new workflow file unless SITE regression requires a comment update in the existing DEV-076 workflow.

Representative link targets (canonical owners, not duplicated bodies):

| Section | Example canonical targets |
|---------|----------------------------|
| Start | `examples/first-15-minutes.md`, `AgToosa_Agent.md`, `AgToosa_Init.md` |
| Use | `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`, `agtoosa-verify.sh` reference via `AgToosa_Agent.md` |
| Trust | `AgToosa_Registry.md`, `AgToosa_Evidence.md`, governance/security boundary docs |
| Adapt | `registry-pack-authoring.md`, `extension-authoring-guide.md`, `AgToosa_Catalog.md` |
| Maintain | `AgToosa_Update.md`, doctor/help surfaces, `AgToosa_Revert.md`, `agtoosa-maintainer.md` |

### 2.2 Data Flow

1. Author updates `docs/index.md` with five sections and link-only entries.
2. NAV tests verify section headings, required links, and absence of duplicated guide bodies.
3. SITE regression confirms Pages build and `/AgToosa/` link resolution still pass.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Landing page becomes a stale second source of truth | Tampering | Link-only contract enforced by NAV non-duplication tests. |
| Broken discovery links after rename | Repudiation | Focused link inventory fails until index is repaired. |
| Navigation exposes maintainer-only paths to generated projects | Information Disclosure | Link only public canonical docs paths. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `docs/index.md`, NAV bats, optional SITE regression touch
Directories in scope: `docs/`, `tests/`
Out of scope        : guide rewrites, search platform, analytics, committed site output

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED navigation contract
  - [x] 1.1 Add NAV section inventory and required-link fixtures — _Requirements: AC-001, AC-003–AC-007_
  - [x] 1.2 Add non-duplication and broken-link negative fixtures — _Requirements: AC-002, AC-005_
- [x] **2.** Landing page update
  - [x] 2.1 Restructure `docs/index.md` into five job sections with canonical links — _Requirements: AC-001–AC-007_
- [x] **3.** Static site regression
  - [x] 3.1 Confirm SITE build and `/AgToosa/` link checks still pass — _Requirements: AC-008_
  - [x] 3.2 Record RED/GREEN NAV evidence — _Requirements: AC-001–AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1  
**Wave 3 (sequential after Wave 2):** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-098.md`
AC coverage: 8 ACs mapped to 8 NAV test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-098)
