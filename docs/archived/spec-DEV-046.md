# Spec: DEV-046 — Optional Worktree Isolation

> **Story ID:** DEV-046
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Prerequisite gate:** DEV-045 must ship before DEV-046 enrollment

## Context

DEV-045 will define dependency-aware packages, owned files, and merge order, but separate packages may still execute in one working tree. Concurrent agents in that tree can overwrite uncommitted changes or inspect the wrong branch even when package ownership is disjoint.

DEV-046 adds optional Git worktree guidance for higher-risk, multi-lane stories. It deliberately does not make worktrees mandatory for XS/S or single-lane work and does not turn AgToosa into a branch-orchestration runtime. Worktree creation, branch selection, integration, and cleanup remain user-controlled. DEV-045 must ship first so this story can consume its package IDs and merge order without inventing a second lane schema.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish an optional per-package worktree isolation contract with decision criteria, safe Git commands, path/ignore guidance, import ordering, cleanup, and a sequential fallback. |
| User outcome | Maintainers can isolate risky parallel lanes when the extra safety is worthwhile without imposing worktree ceremony on every story. |
| Success condition | `AgToosa_Worktree.md` is installed and discoverable; Build, Handoff, and Import use the DEV-045 package contract; focused tests `WT-001`–`WT-006` pass; and a future two-worktree dogfood checklist is recorded. |
| Proof / evidence | Planned RED/GREEN blocks and manual dogfood evidence in `docs/AgToosa_TestPlan-DEV-046.md`, focused bats output, and changed-branch/cleanup records. |
| Non-goals | Automatic `git worktree` execution, hosted branch orchestration, mandatory worktrees, CI provisioning, or changes to DEV-055 capability routing. |
| Assumptions | DEV-045 has shipped; the user has a Git version with `git worktree`; package work can be placed on separate branches; preferred worktree paths are outside the primary checkout. |
| Risks | Optional guidance is mistaken for a requirement; commands run in the wrong checkout; stale worktrees consume disk; branches integrate out of order. |
| Unresolved questions | None. The preferred path pattern is `../<repo>-<package_id>`; `.worktrees/<package_id>` is an explicitly ignored alternative. |

### 1.2 User Stories

**As an** orchestrator with two parallel DEV-045 packages, **I want** a safe worktree setup checklist **so that** agents cannot disturb each other's uncommitted working state.

**As a** solo developer on a small or single-lane story, **I want** explicit skip criteria **so that** optional isolation does not add unnecessary Git ceremony.

**As an** importer, **I want** each worktree branch verified and merged in package order **so that** a dependent lane cannot land before its inputs.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_Worktree.md` is installed THE SYSTEM SHALL define when to use worktrees (M+ work with at least two parallel packages or an explicitly risky lane), when to skip them (XS/S single-lane work), and the enforcement class of each step | Must |
| AC-002 | WHEN worktree isolation is selected THE SYSTEM SHALL document exact `git worktree add`, `git worktree list`, verification, `git worktree remove`, and `git worktree prune` flows; use `../<repo>-<package_id>` by default; and require an ignore rule before an in-repo `.worktrees/` alternative is used | Must |
| AC-003 | IF a handoff contains parallel DEV-045 packages THEN WHEN `/agtoosa-handoff wave` assembles the pack THE SYSTEM SHALL offer an optional Worktree Hint that maps each `package_id` to a suggested path and branch without creating either | Should |
| AC-004 | WHEN `/agtoosa-import` integrates worktree results THE SYSTEM SHALL require a clean-status and package-verification check for each branch, present integration in `merge_order`, and defer cleanup until accepted results are integrated | Must |
| AC-005 | WHEN worktrees are skipped THE SYSTEM SHALL state exactly `No worktree: run packages sequentially in one branch and verify a clean working tree between packages.` and preserve `AgToosa_AgentCapability.md` as a read-only routing reference | Must |
| AC-006 | WHEN isolation enforcement is described THE SYSTEM SHALL classify guidance and checklists as agent-instructed, Git command execution and merge approval as manual, installed documentation as generator-enforced, focused checks as CI-enforced when configured, and automatic provisioning as roadmap | Must |
| AC-007 | WHEN `tests/agtoosa.bats` runs DEV-046 coverage THE SYSTEM SHALL assert dual-path Worktree documentation, `lib/config.sh` registration, Build/Handoff/Import cross-links, safety and cleanup fields, the exact fallback string, and no modification requirement for DEV-055 files | Must |

### 1.4 Failure Modes

| AC | Failure mode |
|----|--------------|
| AC-001 | Worktrees appear mandatory, adding friction to small or sequential changes. |
| AC-002 | Setup omits path validation or cleanup, causing wrong-tree edits, tracked worktree directories, or stale metadata. |
| AC-003 | A handoff presents a suggested worktree as already created or mandatory. |
| AC-004 | A dependent branch is integrated before its prerequisites or before its package verification passes. |
| AC-005 | Users without worktrees receive no safe fallback and assume parallel execution is still isolated. |
| AC-006 | Documentation claims the generator creates or guarantees isolated branches. |
| AC-007 | The guide is absent from generator inventory or workflow copies drift without a regression failure. |

### 1.5 Out of Scope

- Changes to the DEV-045 Work Package schema; DEV-046 consumes it
- Any edit to DEV-055 specs, evidence, AM tests, or either `AgToosa_AgentCapability.md` copy
- Automatic branch creation, checkout, merge, removal, or conflict resolution
- CI-created worktrees, remote branch orchestration, or hosted agent coordination
- Copying environment files or secrets into worktrees
- Version bumps and release publication

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Installing `AgToosa_Worktree.md` through generator inventory | generator-enforced |
| Focused Worktree contract tests when run in CI | CI-enforced |
| Recommendation, setup checklist, branch checks, and fallback selection | agent-instructed |
| Running Git commands and approving integration/cleanup | manual |
| Automatic worktree provisioning and guaranteed lane isolation | roadmap |

Until DEV-046 ships with recorded GREEN evidence, AgToosa may describe worktrees only as a future optional capability. Worktree branches and handoff packs do not replace `docs/Master-Plan.md` or authorize lifecycle status changes outside the normal Import/Build flow.

## 2. Design

### 2.1 Architecture Blueprint

Files to create during the future build:

- `template/Docs/AgToosa_Worktree.md` — canonical generated-project guidance
- `docs/AgToosa_Worktree.md` — maintainer mirror with lowercase `docs/` paths

Files to change during the future build:

- `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md` — decision gate and sequential fallback
- `template/Docs/AgToosa_Handoff.md`, `docs/AgToosa_Handoff.md` — optional package-to-worktree hints
- `template/Docs/AgToosa_Import.md`, `docs/AgToosa_Import.md` — per-branch checks, merge order, and cleanup gate
- `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md` — optional-isolation summary
- `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md` — discoverability and manual-control boundary
- `lib/config.sh` — register `Docs/AgToosa_Worktree.md`
- `tests/agtoosa.bats` — add `WT-001`–`WT-006`
- `docs/AgToosa_TestPlan-DEV-046.md` — capture future automated and manual evidence

Key interfaces:

- `WorktreeDecision`: `{ package_ids, use_or_skip, reason, fallback }`
- `WorktreeHint`: `{ package_id, suggested_path, suggested_branch }`
- `WorktreeIntegrationCheck`: `{ package_id, branch, clean_status, verification, merge_order, cleanup_status }`

The canonical guide owns command details. Existing platform entry points continue delegating Build/Handoff/Import behavior to canonical docs; they do not duplicate the checklist or create a new `/agtoosa-worktree` command.

### 2.2 Data Flow

1. Build reads the active DEV-045 wave and evaluates the documented use/skip criteria.
2. If isolation is selected, the user reviews package IDs, branch names, and target paths, then manually creates each worktree.
3. Handoff may record a suggested path and branch for each package; the hint performs no Git mutation.
4. Each agent works only in its assigned worktree and returns its normal Handoff/Import evidence.
5. Import checks clean status and package verification per branch, then presents accepted branches in DEV-045 `merge_order`.
6. The user integrates accepted branches and only then runs documented remove/prune cleanup.
7. If isolation is skipped, packages run sequentially in one branch with a clean-tree check between packages.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A path or branch is presented as another package's lane | Spoofing | Derive names from known `package_id` values and display `git worktree list` before work begins. |
| An unverified branch is integrated | Tampering | Require clean status plus the package verification command before merge approval. |
| No record proves which branch produced a result | Repudiation | Import evidence records package ID, path, branch, verification, and merge order. |
| Secrets are copied from the primary checkout | Information Disclosure | Prohibit automatic copying of `.env`, credentials, or untracked files; store paths only. |
| Stale worktrees or locks consume resources | Denial of Service | Include remove/prune steps and do not clean up before accepted work is integrated. |
| An agent runs destructive Git in the wrong tree | Elevation of Privilege | Keep Git mutations manual, require path/status checks, and retain existing dangerous-Git guardrails where available. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope      : `template/Docs/AgToosa_Worktree.md`, `docs/AgToosa_Worktree.md`, `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md`, `template/Docs/AgToosa_Handoff.md`, `docs/AgToosa_Handoff.md`, `template/Docs/AgToosa_Import.md`, `docs/AgToosa_Import.md`, `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md`, `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md`, `lib/config.sh`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-046.md`, `docs/AgToosa_TestPlan-DEV-046.md`

Directories in scope: none beyond the listed files

Out of scope        : DEV-045 schema files, DEV-055 files and AM tests, platform adapter bodies, automatic Git/worktree code, verifier changes, release/version files

The future build may begin only after DEV-045 has shipped and recorded its dogfood evidence.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and guide
  - [ ] 1.1 Add failing `WT-001`–`WT-006` assertions before implementation — _Requirements: AC-007_
  - [ ] 1.2 Create both Worktree guide copies with decision, command, safety, fallback, cleanup, and Claim Boundary contracts — _Requirements: AC-001, AC-002, AC-005, AC-006_
- [ ] **2.** Installation and lifecycle wiring
  - [ ] 2.1 Register the guide and add Quickref/Agent discoverability without creating a new command — _Requirements: AC-001, AC-006, AC-007_
  - [ ] 2.2 Wire Build, Handoff, and Import to optional hints, per-branch checks, merge order, and sequential fallback — _Requirements: AC-003, AC-004, AC-005_
- [ ] **3.** Proof and closure
  - [ ] 3.1 Execute and record a two-worktree setup/integration/cleanup checklist — _Requirements: AC-002, AC-004_ `[manual]`
  - [ ] 3.2 Run future GREEN validation and replace all test-plan placeholders with observed evidence — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2

**Wave 2 (parallel after Wave 1):** 2.1, 2.2

**Wave 3 (sequential after Wave 2):** 3.1 `[manual]`

**Wave 4 (sequential after Wave 3):** 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-046.md`

AC coverage: 7 ACs mapped to 6 test IDs (`WT-001`–`WT-006`)

Smoke set: 4 tests tagged `@smoke` (`WT-001`, `WT-002`, `WT-004`, `WT-006`)
