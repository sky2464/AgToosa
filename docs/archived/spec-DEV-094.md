# Spec: DEV-094 — Feature: Assistant Compatibility Contract

> **Story ID:** DEV-094
> **Type:** Feature
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟦 Todo — Rev4 Wave 2 (approved)
> **Estimate:** M
> **Priority:** P1
> **Extends:** DEV-055 (Agent Capability Matrix) — **does not merge**
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

DEV-055 shipped `AgToosa_AgentCapability.md` for **lifecycle routing**: which installed surfaces support handoff, review, cross-model, and specialists. Rev4 adds a separate **compatibility contract** with three test tiers per assistant platform:

| Tier | Meaning |
|------|---------|
| Install-tested | Generator creates/merges expected files correctly |
| Render-tested | Target assistant recognizes commands/rules files |
| Scenario-tested | Fixed proof task yields required workflow artifacts |

This story publishes `Docs/AgToosa_Compatibility_Contract.md` and maintainer test hooks. It **extends** DEV-055 via cross-links; it does **not** merge routing tables or edit DEV-055 shipped artifacts beyond additive cross-links.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a three-tier assistant compatibility contract distinct from the lifecycle capability matrix. |
| User outcome | Users and maintainers understand what "supported" means per platform without conflating install success with scenario proof. |
| Success condition | Compatibility doc defines Install/Render/Scenario tiers, per-platform rows, evidence requirements, and honest claim boundaries; DEV-055 cross-link only; ACC bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-094.md`; ACC-001–ACC-008 bats; scheduled scenario cadence documented not claimed executed. |
| Non-goals | Merging DEV-055 matrix; runtime assistant probing; generic "supported" badge without tier; hosted compatibility dashboard. |
| Assumptions | DEV-055 remains canonical for routing; platforms in `lib/config.sh` are the row set; scenario tests are maintainer-run. |
| Risks | Terminology collision with DEV-055; overclaiming Scenario tier for platforms with only Install evidence. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** prospective adopter, **I want** tiered compatibility labels **so that** I know whether my assistant is install-tested vs scenario-proven.

**As a** maintainer, **I want** contract tests locking tier language **so that** README and matrix do not imply Scenario proof without evidence.

**As a** DEV-055 reader, **I want** a cross-link to compatibility tiers **so that** routing and compatibility stay separate concerns.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_Compatibility_Contract.md` is installed THE SYSTEM SHALL define Install-tested, Render-tested, and Scenario-tested tiers with distinct evidence requirements | Must |
| AC-002 | WHEN the contract lists a platform THE SYSTEM SHALL record tier status, last evidence date, proof command or fixture pointer, and explicit gaps | Must |
| AC-003 | WHEN a platform lacks Scenario-tested evidence THE SYSTEM SHALL NOT label it Scenario-tested or equivalent ("fully supported") | Must |
| AC-004 | WHEN `Docs/AgToosa_AgentCapability.md` is installed THE SYSTEM SHALL cross-link to `AgToosa_Compatibility_Contract.md` and SHALL NOT duplicate the full tier table inline | Must |
| AC-005 | WHEN `AgToosa_Compatibility_Contract.md` references DEV-055 THE SYSTEM SHALL state that lifecycle routing remains in AgentCapability and compatibility tiers remain in this doc | Must |
| AC-006 | WHEN `agtoosa.sh --update` installs workflow docs THE SYSTEM SHALL register `Docs/AgToosa_Compatibility_Contract.md` via `lib/config.sh` | Must |
| AC-007 | WHEN `tests/agtoosa.bats` runs DEV-094 coverage THE SYSTEM SHALL assert doc inventory, tier definitions, per-platform rows for `lib/config.sh` platforms, DEV-055 cross-link, and no-merge boundary | Must |
| AC-008 | WHEN shipping THE SYSTEM SHALL record ACC RED/GREEN without claiming all platforms are Scenario-tested | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-003 | Cursor labeled Scenario-tested with only install bats. |
| FM-002 | AC-004 | Full tier table copied into AgentCapability. |
| FM-003 | AC-005 | Docs imply capability matrix was replaced. |
| FM-004 | AC-002 | Row lacks evidence pointer — unauditable claim. |
| FM-005 | AC-007 | New platform in config without compatibility row. |

### 1.5 Out of Scope

- Editing DEV-055 matrix rows or AM bats (beyond one additive cross-link line)
- Live assistant API probing
- Automated Scenario test execution in default CI (document cadence only)
- Merging compatibility into Specialists platform table
- DEV-088 doctor output

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Compatibility contract doc | generator-enforced install |
| Install-tested tier | CI-enforced-able via existing install bats |
| Render-tested tier | manual / scheduled maintainer evidence |
| Scenario-tested tier | manual / scheduled — explicit date + pointer required |
| Lifecycle routing | DEV-055 agent-instructed — unchanged |

## 2. Design

### 2.1 Architecture Blueprint

Files to create/change:

- `template/Docs/AgToosa_Compatibility_Contract.md` — canonical tier definitions and platform table
- `docs/AgToosa_Compatibility_Contract.md` — maintainer mirror
- `template/Docs/AgToosa_AgentCapability.md` — additive cross-link paragraph only
- `docs/AgToosa_AgentCapability.md` — maintainer mirror cross-link
- `lib/config.sh` — register compatibility doc
- `tests/agtoosa.bats` — ACC tests

**Not in scope:** structural edits to DEV-055 matrix content.

### 2.2 Data Flow

1. Maintainer updates compatibility rows when install/render/scenario evidence is recorded.
2. Install/update copies doc to project `Docs/`.
3. ACC bats verify tier keywords, row coverage, and cross-link presence.
4. Users read AgentCapability for routing → follow link to Compatibility for tier truth.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| False Scenario-tested claim | Spoofing | AC-003 bats on forbidden phrases; evidence date required |
| Divergent copies of tier table | Tampering | Single canonical doc; grep duplicate table in AgentCapability fails |
| Stale evidence dates | Repudiation | Row requires `last_evidence_at` field |
| Platform row omits known gap | Information Disclosure | `gaps` column mandatory |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : Compatibility contract doc, config registration, additive AgentCapability link, ACC bats
Out of scope        : DEV-055 matrix merge, runtime probing, Master-Plan edits, scenario CI wiring

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED contract tests
  - [ ] 1.1 Tier definitions and platform row coverage — _Requirements: AC-001, AC-002, AC-007_
  - [ ] 1.2 No false Scenario claims and DEV-055 boundary — _Requirements: AC-003, AC-004, AC-005_
- [ ] **2.** Documentation kit
  - [ ] 2.1 Author compatibility contract + mirrors — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 2.2 Additive AgentCapability cross-link — _Requirements: AC-004, AC-005_
  - [ ] 2.3 Register in `lib/config.sh` — _Requirements: AC-006_
- [ ] **3.** Evidence
  - [ ] 3.1 ACC RED/GREEN — _Requirements: AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (parallel):** 2.1, 2.2
**Wave 3 (sequential):** 2.3, 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-094.md`
AC coverage: 8 ACs mapped to 8 planned ACC test IDs
Smoke set: 4 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- DEV-055 non-merge boundary explicit: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 (DEV-004 assistant compatibility contract)
