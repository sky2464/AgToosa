# Spec: DEV-075 — Docs: Subagent and Persona Guide Suite

> **Story ID:** DEV-075
> **Type:** Docs
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Priority:** P1
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11
> **Prerequisite gate:** DEV-055 must ship before DEV-075 enrollment

## Context

DEV-047 and DEV-048 define bounded handoff and evidence-backed import, DEV-050 defines cross-model review, and DEV-055 describes platform capability routing. The missing surface is a task-oriented guide suite that shows how those contracts fit together without inventing a runtime orchestrator or copying the canonical workflow documents.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a concise guide suite for subagent and persona use, anchored by one end-to-end spec → two bounded lanes → handoff/import → cross-model review walkthrough. |
| User outcome | A developer can choose a safe multi-agent or solo path, follow the canonical workflows, and understand what evidence is required before closure. |
| Success condition | The walkthrough covers two bounded lanes and their merge; three audience guides cover subagent-heavy, security-sensitive, and solo-developer use; all guides link to canonical workflow docs and state honest enforcement boundaries. |
| Proof / evidence | ADP contract tests map every AC; guide links and required safety language pass; a reviewer can trace every walkthrough stage to an existing canonical workflow. |
| Non-goals | New orchestration behavior, automatic agent launch, new personas, model APIs, or duplicated workflow specifications. |
| Assumptions | DEV-047, DEV-048, DEV-050, and DEV-055 remain the canonical contracts; public guides live under lowercase `docs/` and are not installed project workflow files. |
| Risks | Examples drift from canonical docs, imply parallelism on unsupported hosts, or encourage premature task closure. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** developer using subagents, **I want** an end-to-end bounded-lane example **so that** I can delegate work without losing scope or acceptance-criteria traceability.

**As a** security-sensitive team, **I want** explicit least-privilege and evidence guidance **so that** delegation does not expose secrets or authorize unsafe changes.

**As a** solo developer, **I want** a sequential persona path **so that** I can gain review separation without needing multiple paid agents.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader follows the end-to-end walkthrough THE SYSTEM SHALL show an approved spec becoming exactly two bounded lanes, separate handoff packs, imported results, and a cross-model review outcome in that order | Must |
| AC-002 | WHEN either walkthrough lane is defined THE SYSTEM SHALL identify its mapped ACs, files in scope, allowed actions, verification commands, return contract, and overlap-resolution rule | Must |
| AC-003 | WHEN a delegated lane returns THE SYSTEM SHALL require `/agtoosa-import` mapping and repo-local verification before any task or story is marked complete | Must |
| AC-004 | WHEN cross-model review is demonstrated THE SYSTEM SHALL distinguish writer and read-only reviewer roles, include sequential and explicit-skip fallbacks, and record the path actually used | Must |
| AC-005 | WHEN a reader opens any audience guide THE SYSTEM SHALL find a named audience, recommended lifecycle path, trust boundary, fallback, and links to the canonical Handoff, Import, Cross-Model Review, and Agent Capability docs where relevant | Must |
| AC-006 | WHEN the security-sensitive guide describes delegation THE SYSTEM SHALL require secret redaction, least-privilege scopes, STRIDE review, and explicit authorization before protected CI, credentials, or agent settings are changed | Must |
| AC-007 | WHEN the guide suite is discovered from the repository entry surface THE SYSTEM SHALL link to each guide and SHALL NOT duplicate canonical command or enforcement contracts in README or guide navigation | Should |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | The walkthrough skips import and treats “agent done” as closure. |
| FM-002 | AC-002 | Two lanes edit the same file without an ownership or merge rule. |
| FM-003 | AC-003 | Returned logs are accepted without a runnable local verification command. |
| FM-004 | AC-004 | A same-writer persona is described as an independent cross-model review. |
| FM-005 | AC-005 | Guide prose forks the canonical workflow contract and later drifts. |
| FM-006 | AC-006 | A handoff pack contains secret values or silently authorizes CI/settings edits. |
| FM-007 | AC-007 | Guides exist but cannot be reached from README. |

### 1.5 Out of Scope

- Changing `/agtoosa-handoff`, `/agtoosa-import`, `/agtoosa-review`, or capability-routing behavior.
- Launching, polling, billing, or authenticating external agents.
- Adding default project specialists or new virtual review personas.
- Claiming that two lanes are parallel when the selected host only supports sequential execution.
- Copying the public guide suite into generated projects.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Guide content and walkthrough sequence | documentation / agent-instructed |
| Handoff pack creation and import checklist | agent-instructed (existing canonical workflows) |
| External or subagent launch | manual / host-dependent |
| Cross-model independence and reviewer identity | recorded evidence, not machine-attested |
| ADP documentation contract checks | CI-enforced only when repository CI runs them |
| Automatic multi-agent orchestration | out of scope |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `docs/examples/subagent-handoff-review.md` — end-to-end two-lane walkthrough.
- `docs/guides/subagent-heavy-workflows.md` — delegation, ownership, fallback, and merge guidance.
- `docs/guides/security-sensitive-projects.md` — least-privilege and evidence guidance.
- `docs/guides/solo-developer-workflows.md` — sequential personas and low-overhead path.

Files to change:

- `README.md` — short discovery links only.
- `tests/agtoosa.bats` — ADP documentation contract tests.

Canonical references, not copied:

- `docs/AgToosa_Handoff.md`
- `docs/AgToosa_Import.md`
- `docs/AgToosa_CrossModelReview.md`
- `docs/AgToosa_AgentCapability.md`

### 2.2 Data Flow

1. The reader selects a small approved story and its Must ACs.
2. The walkthrough partitions work into Lane A and Lane B with explicit file ownership and a documented overlap rule.
3. `/agtoosa-handoff` produces one bounded pack per lane; the user launches agents manually or runs lanes sequentially.
4. Each lane returns changed-file and test evidence under the handoff return contract.
5. `/agtoosa-import` maps returned artifacts to tasks and ACs and reruns verification locally.
6. The writer/orchestrator resolves integration conflicts without granting either lane authority over `docs/Master-Plan.md`.
7. An independent read-only reviewer, or the documented fallback, performs cross-model review and records the actual review path.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A delegated agent impersonates an independent reviewer | Spoofing | Record writer/reviewer identity and model/platform; describe same-agent personas honestly. |
| A lane edits files owned by the other lane | Tampering | Put file ownership and overlap resolution in each handoff pack. |
| A user cannot prove which lane produced a result | Repudiation | Preserve handoff pointer, import mapping, commands, exits, and reviewer in repo-local evidence. |
| Secrets are pasted into a pack or review prompt | Information Disclosure | Cite paths and redact values; security guide includes an explicit secret checklist. |
| Unsupported parallelism blocks the walkthrough | Denial of Service | Provide sequential execution and explicit-skip fallbacks. |
| A reviewer modifies protected CI or agent settings | Elevation of Privilege | Reviewer is read-only; protected-surface changes require separate explicit authorization. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)
Files in scope      : `docs/examples/subagent-handoff-review.md`, `docs/guides/subagent-heavy-workflows.md`, `docs/guides/security-sensitive-projects.md`, `docs/guides/solo-developer-workflows.md`, `README.md`, `tests/agtoosa.bats`
Directories in scope: `docs/examples/`, `docs/guides/`
Out of scope        : workflow behavior, template adapters, generator logic, verifier logic, external agent APIs

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract tests and shared guide structure
  - [ ] 1.1 Add RED ADP tests for guide inventory, links, required boundaries, and non-duplication — _Requirements: AC-005, AC-006, AC-007_
  - [ ] 1.2 Define a shared audience/path/trust/fallback/reference outline for all three guides — _Requirements: AC-005_
- [ ] **2.** End-to-end walkthrough
  - [ ] 2.1 Write the two-lane spec-to-handoff sequence with bounded ownership and overlap handling — _Requirements: AC-001, AC-002_
  - [ ] 2.2 Add import, local verification, merge, and task-closure checkpoints — _Requirements: AC-003_
  - [ ] 2.3 Add independent review and sequential/skip fallbacks — _Requirements: AC-004_
- [ ] **3.** Audience guides
  - [ ] 3.1 Write the subagent-heavy workflow guide — _Requirements: AC-002, AC-005_
  - [ ] 3.2 Write the security-sensitive guide with least-privilege controls — _Requirements: AC-005, AC-006_
  - [ ] 3.3 Write the solo-developer sequential-persona guide — _Requirements: AC-004, AC-005_
- [ ] **4.** Discovery without duplication
  - [ ] 4.1 Add concise README links to the walkthrough and three guides — _Requirements: AC-007_
  - [ ] 4.2 Review every guide link against its canonical workflow owner — _Requirements: AC-005, AC-007_
- [ ] **5.** Evidence
  - [ ] 5.1 Run focused ADP checks and record RED/GREEN evidence in the test plan — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_

### 3.2 Wave Plan

**Wave 0 (dependency, sequential):** enroll only after DEV-055 ships  
**Wave 1 (parallel):** 1.1, 1.2, 2.1  
**Wave 2 (parallel after Wave 1):** 2.2, 3.1, 3.2, 3.3  
**Wave 3 (sequential after Wave 2):** 2.3, 4.1, 4.2  
**Wave 4 (sequential after Wave 3):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-075.md`
AC coverage: 7 ACs mapped to 9 ADP test IDs
Smoke set: 3 tests tagged `@smoke`
