# Spec: DEV-103 — Chore: External Registry Publication Runbook

> **Story ID:** DEV-103
> **Type:** Chore
> **Epic:** DEV-003 — Community Template Registry
> **Status:** 🟩 Built — Rev4 Wave 3 (PUB green)
> **Estimate:** S
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12
> **Depends on:** DEV-080 (shipped pilots; tasks 4.2/4.3 manual-deferred)
> **Extends:** DEV-080 — operationalizes manual external publication with a submission checklist

## Context

DEV-080 automated local pack proof through task 4.1 but deferred external registry submission (4.2) and acceptance confirmation (4.3) as manual actions. Maintainers need a runbook that turns those manual tasks into a repeatable checklist without implying that local artifacts equal external publication. DEV-103 authors the runbook, links it from the pilot checklist and registry docs, and adds PUB contract tests for checklist completeness and honesty boundaries.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish an external registry publication runbook with a submission checklist for DEV-080 tasks 4.2 and 4.3. |
| User outcome | A maintainer can submit and confirm official packs against `agtoosa-registry` with explicit preconditions, evidence links, and state transitions. |
| Success condition | Runbook exists with pre-submit, submit, and confirm sections; checklist items map to OPP/DEV-053 evidence; documentation forbids published claims before confirmation; PUB tests enforce completeness. |
| Proof / evidence | PUB tests verify runbook presence, checklist fields, state-machine alignment, and link discovery from pilot checklist. |
| Non-goals | Automating external registry approval, CI publish to remote registry, or changing local install behavior. |
| Assumptions | External registry remains a separate repository/process; official pilots stay `local-candidate` until runbook confirmation steps complete. |
| Risks | Runbook is treated as proof of publication; checklist omits security or manifest gates. |
| Unresolved questions | Final external registry URL and submission channel are confirmed at enrollment. |

### 1.2 User Stories

**As a** pack maintainer, **I want** a publication runbook **so that** I can complete DEV-080 tasks 4.2/4.3 without improvising each release.

**As a** registry user, **I want** honest state labels **so that** "submitted" is not confused with "published."

**As an** AgToosa reviewer, **I want** checklist items tied to existing OPP evidence **so that** submission repeats proven local proof.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a maintainer opens the publication runbook THE SYSTEM SHALL document three phases: pre-submit validation, external submission (DEV-080 task 4.2), and acceptance confirmation (DEV-080 task 4.3) | Must |
| AC-002 | WHEN the pre-submit checklist is presented THE SYSTEM SHALL require manifest validation, OPP green evidence, content-policy review, maintainer ownership, and compatibility declarations before submission | Must |
| AC-003 | WHEN submission steps are documented THE SYSTEM SHALL list required registry record fields, artifact pointers, and reviewer contact path without claiming automatic publication | Must |
| AC-004 | WHEN confirmation steps are documented THE SYSTEM SHALL require independent verification of the accepted external record before changing inventory state to published or available | Must |
| AC-005 | WHEN publication state is described THE SYSTEM SHALL align with the DEV-080 state machine: local candidate → submitted → published | Must |
| AC-006 | WHEN pilot checklist or registry inventory references external publication THE SYSTEM SHALL link to the runbook as the canonical procedure | Must |
| AC-007 | WHEN the runbook is maintained THE SYSTEM SHALL fail focused checks if it uses phrases that equate open PRs or local artifacts with external publication | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Runbook merges submit and confirm into one ambiguous step. |
| FM-002 | AC-002 | Submission proceeds without OPP green or manifest validation reference. |
| FM-003 | AC-003 | Runbook implies `agtoosa.sh --registry publish` externally publishes packs. |
| FM-004 | AC-004 | Inventory updated to published on PR open only. |
| FM-005 | AC-005 | State machine diverges from DEV-080 checklist. |
| FM-006 | AC-006 | Pilot checklist still says "see README" with no runbook link. |
| FM-007 | AC-007 | Runbook says "merge PR = published." |

### 1.5 Out of Scope

- Automated external registry CI or GitHub Action publish
- Marketplace onboarding or billing
- Changing DEV-053 schema or local `--registry publish` behavior
- Verifying third-party registry uptime in CI

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Publication runbook | documentation / manual procedure |
| Local OPP proof | CI-enforced in this repository |
| External registry acceptance | manual / external |
| Pack install safety | generator-enforced; unchanged |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/registry-external-publication-runbook.md` — canonical submission and confirmation runbook
- `docs/official-pack-pilot-checklist.md` — link tasks 4.2/4.3 to runbook
- `docs/AgToosa_Registry.md` — discovery link under official pilot section
- `template/Docs/AgToosa_Registry.md` — mirror link if applicable
- `tests/agtoosa.bats` — PUB checklist and honesty tests

Runbook outline:

1. **Pre-submit** — manifest validate, OPP green, checklist sign-off, evidence links
2. **Submit (4.2)** — open external registry PR/record; set state to `submitted` only
3. **Confirm (4.3)** — verify accepted external record; update inventory to `published` only after confirmation

### 2.2 Data Flow

1. Maintainer completes local OPP proof and pilot checklist.
2. Runbook pre-submit section gates external action.
3. Maintainer performs manual external submission; records `submitted` state and PR/record URL.
4. After external acceptance, maintainer confirms record independently and updates inventory/docs to `published`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Local artifact presented as external publication | Spoofing | State machine and forbidden-claim tests. |
| Submission without security/content review | Elevation of Privilege | Pre-submit checklist requires policy review references. |
| Maintainer cannot audit what was submitted | Repudiation | Runbook requires evidence links and record URLs. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : runbook, pilot checklist link, registry doc link, PUB bats
Directories in scope: `docs/`, `template/Docs/`, `tests/`
Out of scope        : external registry automation, install behavior changes, marketplace

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED runbook contract
  - [x] 1.1 Add PUB phase and checklist completeness fixtures — _Requirements: AC-001, AC-002, AC-006_
  - [x] 1.2 Add state-machine and forbidden-claim fixtures — _Requirements: AC-004, AC-005, AC-007_
- [x] **2.** Author runbook
  - [x] 2.1 Write `registry-external-publication-runbook.md` with pre-submit, submit, confirm sections — _Requirements: AC-001–AC-005_
  - [x] 2.2 Link from pilot checklist and registry inventory — _Requirements: AC-006_
- [x] **3.** Evidence
  - [x] 3.1 Record RED/GREEN PUB evidence — _Requirements: AC-001–AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-103.md`
AC coverage: 7 ACs mapped to 7 PUB test IDs
Smoke set: 2 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: external registry URL at enrollment

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-103)
