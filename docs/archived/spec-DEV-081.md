# Spec: DEV-081 — Optional Local DX Add-on Validation

> **Story ID:** DEV-081
> **Epic:** DEV-001 — Core Generator Engine
> **Type:** Spike
> **Priority:** P2
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

AgToosa is a repo-native workflow generator whose Bash and PowerShell entry points remain the product boundary. A thin native wrapper, an editor extension, and more CI templates might improve local discoverability or setup, but they have different costs, risks, and users. Treating them as one “DX” feature would hide those differences and could trigger an unjustified core rewrite.

This spike gathers reproducible evidence and makes three independent decisions. It does not implement, ship, or promise any add-on.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Validate the user value and maintenance cost of a thin native wrapper, an editor extension, and additional CI templates, then decide adopt, defer, or reject for each option separately. |
| User outcome | Users get evidence-based local-DX priorities without destabilizing the portable Bash/PowerShell core or being forced to install an add-on. |
| Success condition | Each option has a representative scenario, evaluation rubric, reproducible findings, security/maintenance analysis, and an independent decision with a follow-on trigger. |
| Proof / evidence | Required before spike closure: source-cited research, scripted or manually reproducible observations, decision matrices, and reviewer notes. No evidence has been collected. |
| Non-goals | Production implementation, packaging, publication, core rewrite, or any parked roadmap item in §1.4. |
| Assumptions | The current CLI and repo-local docs remain the baseline; optional add-ons must preserve a complete no-add-on path. |
| Risks | Novelty may be mistaken for user value; a prototype may be mistaken for supported code; editor or CI permissions may be understated; three decisions may be improperly bundled. |
| Unresolved questions | Which representative editors, operating systems, and CI providers are available for observation will be fixed when the spike is enrolled. |

### 1.2 User Stories

**As a** new local user, **I want** faster command discovery and setup only when it measurably improves the current path **so that** I do not inherit unnecessary tooling.

**As an** AgToosa maintainer, **I want** separate evidence for wrapper, editor, and CI options **so that** one attractive option does not force adoption of the others.

**As a** security-conscious team, **I want** add-on permissions, update channels, and fallback behavior evaluated before implementation **so that** convenience does not silently expand the trust boundary.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the spike begins THE SYSTEM SHALL define a shared baseline journey and rubric covering user value, setup friction, portability, security, maintenance cost, accessibility, failure recovery, and no-add-on fallback | Must |
| AC-002 | WHEN the thin native wrapper is evaluated THE SYSTEM SHALL measure only delegation to existing supported entry points and SHALL document startup, distribution, update, platform-parity, and error-propagation findings without proposing a second core | Must |
| AC-003 | WHEN the editor extension is evaluated THE SYSTEM SHALL document command discovery, workspace trust, permissions, update-channel, accessibility, offline, and uninstall findings while preserving full CLI functionality without the extension | Must |
| AC-004 | WHEN additional CI templates are evaluated THE SYSTEM SHALL identify the concrete provider/use-case gaps, permission requirements, duplication risk, maintenance owner, and copy-only versus generated boundary for each candidate template | Must |
| AC-005 | WHEN evidence collection ends THE SYSTEM SHALL issue an independent adopt, defer, or reject decision for each of the three options with cited observations, confidence, costs, risks, and reconsideration triggers | Must |
| AC-006 | WHEN any option receives an adopt recommendation THE SYSTEM SHALL create a separately scoped future implementation proposal and SHALL NOT modify production generator, wrapper, extension, or CI behavior within this spike | Must |
| AC-007 | WHEN spike findings are published THE SYSTEM SHALL distinguish observed evidence, assumptions, and untested conditions and SHALL NOT claim an optional add-on capability has shipped | Must |

**Failure modes:**

| AC | Failure mode | Required response |
|----|--------------|-------------------|
| AC-001 | Each option is scored against different unstated criteria | Rework the findings against one shared rubric. |
| AC-002 | “Thin wrapper” duplicates install or registry logic | Reject that design direction as a second core. |
| AC-003 | Extension recommendation assumes broad workspace permissions without analysis | Mark the recommendation incomplete. |
| AC-004 | A CI template is proposed without a provider-specific gap or owner | Defer it; generic template count is not user value. |
| AC-005 | One combined go/no-go decision covers all three options | Split it into three independent decisions. |
| AC-006 | Spike artifacts alter production behavior | Revert the behavior change and move it to a separately approved story. |
| AC-007 | Mockups or disposable observations are described as shipped functionality | Correct the claim to planned or observed-only. |

### 1.4 Out of Scope

- Any SaaS or hosted control plane
- SSO or RBAC
- An MCP runtime
- An autonomous build runtime
- A federated registry
- A marketplace or extension marketplace publication
- Silent telemetry, background analytics, or automatic usage reporting
- A Go or Rust rewrite
- Production implementation of a native wrapper
- Production implementation or publication of an editor extension
- Adding or changing production CI templates
- Replacing the Bash/PowerShell core, changing command semantics, or introducing a second implementation core

The parked roadmap items and all production implementations above are exclusions, not DEV-081 subtasks.

### 1.5 Claim Boundary

| Surface or claim | Classification | Boundary |
|------------------|----------------|----------|
| Research observations | Manual/research evidence | Valid only for the recorded environment and scenario. |
| Evaluation rubric and decision records | Agent-assisted, human-reviewed | They guide prioritization; they do not create product capability. |
| Thin wrapper | Roadmap candidate | At most a delegating shell around supported entry points; no implementation in this spike. |
| Editor extension | Roadmap candidate | Optional by definition; no required editor dependency or shipped extension is implied. |
| Additional CI templates | Roadmap candidate | No template is available until a separate story implements and verifies it. |
| Current CLI and repo-local workflow | Existing product boundary | Remains complete and authoritative regardless of spike decisions. |

## 2. Design

### 2.1 Architecture Blueprint

Future spike artifacts:

| Surface | Responsibility |
|---------|----------------|
| `docs/spikes/DEV-081/evaluation-rubric.md` | Shared baseline journeys, criteria, scoring rules, environments, and evidence quality |
| `docs/spikes/DEV-081/native-wrapper.md` | Wrapper observations, constraints, costs, risks, and independent decision |
| `docs/spikes/DEV-081/editor-extension.md` | Extension observations, permission/offline/accessibility analysis, and independent decision |
| `docs/spikes/DEV-081/ci-templates.md` | Provider/use-case gap analysis and independent decision |
| `docs/spikes/DEV-081/decision-summary.md` | Cross-reference three decisions without combining their outcomes |
| Disposable external scratch environments | Reproducible observations only; no production artifact copied into the product |

Key interfaces:

- Baseline: documented `agtoosa.sh` / `agtoosa.ps1` and repo-local workflow.
- Evidence record: scenario, environment, method, observation, limitation, source, and date.
- Decision record: option, outcome, confidence, evidence links, risks, costs, and reconsideration trigger.

### 2.2 Data Flow

1. Define the current CLI journey and the shared evaluation rubric before examining an option.
2. Select representative environments and record availability and limitations.
3. Evaluate wrapper, extension, and CI-template scenarios independently against the same rubric.
4. Store observations separately from interpretation; label assumptions and untested conditions.
5. Produce one decision record per option.
6. Review each record for security, portability, maintenance, accessibility, and no-add-on fallback.
7. If an option is recommended for adoption, open a separate proposed story; otherwise record a defer trigger or rejection rationale.
8. Publish the summary without changing production behavior or claiming shipment.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A wrapper binary or extension publisher is impersonated | Spoofing | Evaluate publisher identity, signing/update channels, and distribution trust before any adopt decision. |
| Extension or CI configuration modifies repository content unexpectedly | Tampering | Record required permissions and least-privilege design constraints. |
| Findings omit who performed an observation | Repudiation | Evidence records include environment, method, date, and reviewer. |
| Extension diagnostics or CI examples expose repository data | Information Disclosure | Reject silent collection; use synthetic data and document every data boundary. |
| Optional tooling blocks the baseline workflow | Denial of Service | Require a complete CLI fallback and clean uninstall/recovery path. |
| Wrapper, extension, or CI token gains excessive privileges | Elevation of Privilege | Include permission analysis and least-privilege acceptance gates in any future proposal. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : future DEV-081 rubric, three option reports, and decision summary
Directories in scope: `docs/spikes/DEV-081/` plus disposable observation environments outside production surfaces
Production changes  : none
Out of scope        : all §1.4 exclusions, generator/template/platform wiring, release packaging, and implementation of any recommendation

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Establish the evidence contract
  - [ ] 1.1 Define baseline journeys, representative environments, and the shared rubric — _Requirements: AC-001_
  - [ ] 1.2 Define evidence quality, assumption, limitation, and reproducibility labels — _Requirements: AC-001, AC-007_
- [ ] **2.** Evaluate candidates independently
  - [ ] 2.1 Gather and document thin-wrapper observations without changing production code — _Requirements: AC-002, AC-006, AC-007_
  - [ ] 2.2 Gather and document editor-extension observations without publishing an extension — _Requirements: AC-003, AC-006, AC-007_
  - [ ] 2.3 Gather and document additional-CI-template observations without adding templates — _Requirements: AC-004, AC-006, AC-007_
- [ ] **3.** Decide and review
  - [ ] 3.1 Issue a separate adopt/defer/reject record for each option — _Requirements: AC-005_
  - [ ] 3.2 Review security, portability, accessibility, maintenance, and no-add-on fallback conclusions — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005_
  - [ ] 3.3 Publish a summary that labels evidence, assumptions, and untested conditions — _Requirements: AC-007_
- [ ] **4.** Preserve the spike boundary
  - [ ] 4.1 Draft separate future story proposals only for options recommended for adoption — _Requirements: AC-006_
  - [ ] 4.2 Confirm the spike contains no production implementation or shipped-capability claim — _Requirements: AC-006, AC-007_

### 3.2 Wave Plan

**Wave 1 (sequential foundation):** 1.1, then 1.2  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (parallel after Wave 2):** 3.1, 3.2  
**Wave 4 (sequential after Wave 3):** 3.3, 4.1, 4.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-081.md`
AC coverage: 7 ACs mapped to 8 planned DXV test IDs
Smoke set: 4 planned tests tagged `@smoke`
Evidence state: RED and GREEN are unexecuted placeholders; no validation evidence is claimed.
