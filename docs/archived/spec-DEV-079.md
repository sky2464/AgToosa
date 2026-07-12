# Spec: DEV-079 — Docs: Verifier and CI Adoption Examples

> **Story ID:** DEV-079
> **Type:** Docs
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Priority:** P2
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

AgToosa ships a deterministic verifier and `Docs/agtoosa-gate.yml.example`, but adoption guidance is spread across README, Quickref, Readiness, and comments in the workflow template. Users need one copy-in guide that distinguishes local machine checks from an enabled CI gate, uses the right path for generated projects versus this maintainer repository, and avoids claiming provider-specific support that is not maintained.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish copy-in verifier and CI-gate adoption examples with explicit, accurate enforcement boundaries. |
| User outcome | A user can run the verifier locally, safely copy the maintained GitHub Actions gate, confirm it is active, and understand what AgToosa does and does not enforce. |
| Success condition | One canonical adoption guide owns commands and boundary explanations; README/Quickref/Readiness route to it; maintained gate mirrors remain pinned, least privilege, and fail closed when the verifier is absent. |
| Proof / evidence | VCA tests cover command paths, safe copy flow, enforcement labels, provider-maintenance policy, gate mirror parity, permissions, pins, and discovery links. |
| Non-goals | Automatic workflow installation, hosted verification, new verifier checks, or copy-ready configurations for unmaintained CI providers. |
| Assumptions | GitHub Actions is the only maintained provider-specific gate example in this story; other CI systems can invoke the verifier through provider-neutral guidance. |
| Risks | Documentation calls an uninstalled template CI-enforced, unsafe copy commands overwrite workflows, or provider examples silently rot. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** solo developer, **I want** exact local verifier commands and exit semantics **so that** I can adopt machine checks before configuring CI.

**As a** team maintainer, **I want** a safe GitHub Actions copy-in sequence **so that** pull requests are gated without AgToosa silently writing protected workflow files.

**As a** non-GitHub CI user, **I want** provider-neutral requirements and honest support labels **so that** I do not mistake pseudocode for a maintained integration.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader follows the local-adoption example THE SYSTEM SHALL show generated-project and maintainer-repository verifier paths, normal and strict modes, and exit-code meanings without claiming CI enforcement | Must |
| AC-002 | WHEN a reader follows the GitHub Actions adoption example THE SYSTEM SHALL require destination inspection, explicit user copy of the shipped example, diff review, commit/push, and observation of a real workflow result before calling the gate enabled | Must |
| AC-003 | WHEN adoption status is described THE SYSTEM SHALL classify the installed verifier as a local machine check, the uncopied gate as a template, and the copied/running workflow as CI-enforced | Must |
| AC-004 | IF provider-specific CI guidance is presented as copy-ready THEN THE SYSTEM SHALL require a checked-in maintained example, a named owning surface, and focused contract coverage; OTHERWISE THE SYSTEM SHALL label guidance provider-neutral and unmaintained | Must |
| AC-005 | WHEN commands are shown THE SYSTEM SHALL use `Docs/` paths for generated projects and `docs/` paths for Maintainer Dogfood Mode, with no ambiguous mixed-context command | Must |
| AC-006 | WHEN README, Quickref, or Readiness mentions verifier adoption THE SYSTEM SHALL link to the canonical adoption guide or gate example and SHALL NOT reproduce a competing full procedure | Should |
| AC-007 | WHEN the maintained gate example runs THE SYSTEM SHALL use least-privilege permissions, immutable action pins, preserve verifier exit status, and fail with an actionable message when no verifier exists | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | A local command uses maintainer lowercase paths in a generated project and fails. |
| FM-002 | AC-002 | `cp` silently overwrites an existing workflow or the guide calls the gate active before CI runs. |
| FM-003 | AC-003 | Merely installing `Docs/agtoosa-gate.yml.example` is advertised as CI enforcement. |
| FM-004 | AC-004 | An untested GitLab/CircleCI snippet is presented as maintained copy-ready support. |
| FM-005 | AC-005 | One code block mixes `Docs/` and `docs/` without context labels. |
| FM-006 | AC-006 | README, Quickref, and the guide contain three drifting procedures. |
| FM-007 | AC-007 | Workflow action tags float, write permissions expand, or a missing verifier passes. |

### 1.5 Out of Scope

- Automatically creating or modifying `.github/workflows/` in generated projects.
- Adding or changing verifier gates, exit codes, or CLI dispatch.
- Hosted dashboards, status callbacks, telemetry, or remote attestation.
- Copy-ready GitLab CI, CircleCI, Jenkins, Azure Pipelines, or other provider files without maintained repository artifacts and tests.
- Branch-protection configuration or claims that a repository administrator enabled required checks.
- Measuring adoption beyond voluntary/public evidence.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| `Docs/agtoosa-verify.sh` installed with the pack | generator-enforced file inventory |
| Verifier findings and exit status when invoked | machine-enforced locally |
| `Docs/agtoosa-gate.yml.example` before copy | documentation/template only |
| Copied workflow after a successful CI run | CI-enforced for configured events |
| Required branch protection | manual repository administration |
| Non-GitHub provider integration | provider-neutral guidance only unless separately maintained |
| Adoption rate or security outcome | not measured by this story |

## 2. Design

### 2.1 Architecture Blueprint

File to create:

- `docs/examples/verifier-ci-adoption.md` — canonical local and CI adoption guide.

Files to change:

- `template/Docs/agtoosa-gate.yml.example` and `docs/agtoosa-gate.yml.example` — aligned safe-copy comments and maintained contract.
- `template/Docs/AgToosa_Quickref.md` and `docs/AgToosa_Quickref.md` — concise adoption pointer.
- `template/Docs/AgToosa_Readiness.md` and `docs/AgToosa_Readiness.md` — explicit template/local/CI boundary and pointer.
- `README.md` — one discovery link.
- `tests/agtoosa.bats` — VCA docs, mirror, security, path-context, and provider-policy checks.

The adoption guide owns the full procedure. Other surfaces retain short commands or links appropriate to their existing role.

### 2.2 Data Flow

1. The user identifies the operating context: generated project (`Docs/`) or maintainer repository (`docs/`).
2. The user runs the repo-local verifier and interprets exit `0`, `1`, or `2`; strict mode is an explicit choice.
3. For GitHub Actions, the user inspects `.github/workflows/` and the shipped gate example before copying.
4. The user copies the example manually, reviews the diff, commits, and pushes it.
5. GitHub Actions checks out the source and runs the verifier; its exit status becomes the workflow result.
6. Only after observing that result may documentation call the gate CI-enforced; branch-protection setup remains manual.
7. Other CI providers receive only the provider-neutral contract: invoke the repo-local verifier and preserve its exit code.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A badge or prose falsely claims CI is enabled | Spoofing | Require observed workflow evidence before the CI-enforced label. |
| Copying overwrites a customized workflow | Tampering | Inspect destination, refuse silent overwrite, and review the diff. |
| A team cannot prove which gate version ran | Repudiation | Workflow is committed; action revisions are immutable-pinned; CI run links to commit. |
| Workflow exposes repository secrets unnecessarily | Information Disclosure | No secrets required; `contents: read` only. |
| Missing verifier or swallowed exit status lets invalid state pass | Denial of Service | Fail with actionable update guidance and preserve verifier exit status. |
| A pull-request workflow gains write authority | Elevation of Privilege | Least-privilege permissions and no deployment or mutation steps. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)
Files in scope      : `docs/examples/verifier-ci-adoption.md`, gate example mirrors, Quickref mirrors, Readiness mirrors, `README.md`, `tests/agtoosa.bats`
Directories in scope: `docs/examples/`, `docs/`, `template/Docs/`, `tests/`
Out of scope        : verifier behavior, automatic workflow writes, branch protection, hosted services, unmaintained provider-specific examples

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Adoption contract tests
  - [ ] 1.1 Add RED VCA tests for path contexts, exit semantics, copy sequence, and enforcement labels — _Requirements: AC-001, AC-002, AC-003, AC-005_
  - [ ] 1.2 Add provider-policy, gate-security, mirror-parity, and discovery tests — _Requirements: AC-004, AC-006, AC-007_
- [ ] **2.** Canonical adoption guide
  - [ ] 2.1 Write context-specific local verifier examples and exit semantics — _Requirements: AC-001, AC-003, AC-005_
  - [ ] 2.2 Write the safe GitHub Actions copy, review, push, and observed-run sequence — _Requirements: AC-002, AC-003_
  - [ ] 2.3 Add provider-neutral guidance and maintained-example policy — _Requirements: AC-004_
- [ ] **3.** Maintained gate and boundary surfaces
  - [ ] 3.1 Align gate example comments, immutable pins, permissions, and missing-verifier failure across mirrors — _Requirements: AC-002, AC-007_
  - [ ] 3.2 Clarify local/template/CI labels in Readiness mirrors — _Requirements: AC-003, AC-006_
- [ ] **4.** Discovery without procedural duplication
  - [ ] 4.1 Add concise README and Quickref links to the canonical guide — _Requirements: AC-005, AC-006_
  - [ ] 4.2 Confirm no unmaintained provider snippet is labeled copy-ready — _Requirements: AC-004_
- [ ] **5.** Evidence
  - [ ] 5.1 Run focused VCA checks and record RED/GREEN evidence — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3, 3.1  
**Wave 3 (parallel after Wave 2):** 3.2, 4.1, 4.2  
**Wave 4 (sequential after Wave 3):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-079.md`
AC coverage: 7 ACs mapped to 9 VCA test IDs
Smoke set: 3 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-07-11 21:25
Enrollment: remaining-specs fan-out wave 1 (build/review/ship)
