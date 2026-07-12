# Spec: DEV-045 — Work Package Wave DAG

> **Story ID:** DEV-045
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟦 Todo
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Enrolled:** 2026-07-11 — prerequisite DEV-055 shipped v5.3.7; awaiting Spec Approved

## Context

DEV-067 shipped wave-by-wave TDD execution, and `docs/SPEC-FORMAT.md` defines a task tree plus a Wave Plan. Those waves currently identify task IDs only; they do not declare package ownership, dependencies, inputs, outputs, integration order, or package-specific verification. DEV-047 and DEV-048 provide bounded handoff and import workflows, but their packs do not yet carry a shared work-package schema.

DEV-045 closes only that schema and workflow-wiring gap. It adds dependency-aware work packages to the existing markdown lifecycle; it does not add a runtime scheduler or agent launcher. DEV-055 owns lifecycle routing and shipped v5.3.7. This story must not reopen `AgToosa_AgentCapability.md`, its AM tests, or its active build artifacts.

### Brownfield Spec Drift Baseline

| Field | Value |
|-------|-------|
| User outcome / proof | Orchestrators can declare auditable parallel lanes with explicit file ownership, dependencies, and verification; bats `DAG-001`–`DAG-007` green; dogfood two-parallel/one-dependent case recorded |
| Repo evidence inventory | `docs/SPEC-FORMAT.md` §3.2 Wave Plan (task IDs only); `docs/AgToosa_Handoff.md` (`wave` sub-command, no Work Packages section); `docs/AgToosa_Import.md` (AC mapping, no ownership-gap gate); `docs/AgToosa_Build.md` (wave TDD, no package fan-out gate); DEV-047/048 shipped handoff/import; DEV-055 shipped routing matrix; `tests/agtoosa.bats` `DEV-045 CW-008` artifact check only |
| Current-state baseline | Wave Plan lists sub-task IDs without `owned_files`, `depends_on`, or `merge_order`; Handoff exports wave context but not package rows; Import maps artifacts to tasks/ACs without comparing changed paths to package ownership; no `### 3.4 Work Package DAG` in SPEC-FORMAT |
| Intended change deltas | Add normative `### 3.4 Work Package DAG` schema; wire Spec/Build/Handoff/Import to consume the same eight columns; add `DAG-001`–`DAG-007` contract bats; document honest Claim Boundary (agent-instructed dispatch, manual integration) |
| Drift evidence | Roadmap placeholder (2026-06) deepened to functional EARS on 2026-07-11; prerequisite gate cleared when DEV-055 shipped v5.3.7; implementation intentionally deferred until enrollment |
| Claim Boundary | Schema copy = **generator-enforced**; DAG bats when run in CI = **CI-enforced**; package derivation and fan-out checks = **agent-instructed**; agent selection and branch integration = **manual**; runtime scheduler = **roadmap** |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth |

### Smart interview findings (2026-07-11 enrollment)

| Checklist area | Finding |
|----------------|---------|
| Status quo | Wave Plan + TDD waves exist; parallel subagent fan-out is possible via DEV-055 routing but lacks file-ownership contracts |
| Narrowest v1 | Markdown schema + workflow wiring + bats; no scheduler, worktrees (DEV-046), or verifier hard-fail |
| Urgency | Critical path after DEV-055 per DEV-002 epic charter and roadmap dependency graph; blocks DEV-046/057 |
| Failure modes | Overlapping same-wave ownership; missing dependencies; handoff scope creep; import accepting out-of-scope edits; false runtime-enforcement claims |
| Security | Package rows may reference paths and verification commands only — no secret values in handoff/import evidence |
| Test evidence | RED/GREEN `DAG-001`–`DAG-007` + dogfood table in test plan |
| Rollout | Template + maintainer mirrors; XS stories may keep sequential Wave Plan without full DAG ceremony |

### Spec Quality Analyzer (2026-07-11)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass — 7 Must, 1 Should; each Must has failure mode |
| Goal / scope / AC / task / test-plan alignment | Pass — no contradictions |
| Must AC → test-plan mapping | Pass — AC-001–AC-008 mapped to DAG-001–DAG-007 |
| Claim Boundary classified | Pass — §1.6 table complete |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass — none in Must ACs |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Extend approved specs with a Work Package Wave DAG that declares each package's wave, dependencies, owned files, inputs, outputs, merge order, and verification command. |
| User outcome | Orchestrators and async agents can divide a story into auditable lanes without guessing which files a lane owns or when its result may be integrated. |
| Success condition | `SPEC-FORMAT.md` defines the schema; Spec, Build, Handoff, and Import consume the same fields; focused tests `DAG-001`–`DAG-007` pass; and the test plan records a two-parallel-package/one-dependent-package dogfood case. |
| Proof / evidence | RED/GREEN evidence captured during the future build in `docs/AgToosa_TestPlan-DEV-045.md`, focused bats output, schema fixtures, and the dogfood package table. |
| Non-goals | Runtime scheduling, automatic agent dispatch, mandatory worktrees, changes to DEV-055 routing, or hosted orchestration. |
| Assumptions | Wave Plan, Terminal Evidence, Handoff, and Import remain available; package execution remains host-dependent and agent-instructed. |
| Risks | A schema that is too heavy for small stories; false parallel-safety claims; divergent field names across workflow docs. |
| Unresolved questions | None. Package IDs use `PKG-<task-id>` (for example, `PKG-1.1`). |

### 1.2 User Stories

**As an** AgToosa orchestrator, **I want** every parallel task bound to explicit dependencies and owned files **so that** I can reject unsafe fan-out before agents start.

**As a** maintainer exporting a wave handoff, **I want** the selected work-package rows included in the pack **so that** each async agent receives its inputs, expected outputs, and verification command.

**As an** importer, **I want** returned changes checked against package ownership and merge order **so that** out-of-scope edits and premature integration are reported before lifecycle state changes.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/SPEC-FORMAT.md` is read THE SYSTEM SHALL define a `### 3.4 Work Package DAG` table with `package_id`, `wave`, `depends_on`, `owned_files`, `inputs`, `outputs`, `merge_order`, and `verification` columns | Must |
| AC-002 | WHEN `/agtoosa-spec tasks` derives work from an approved spec THE SYSTEM SHALL emit one Work Package row for every executable sub-task, including non-empty `owned_files` and `verification` values for every package proposed for parallel execution | Must |
| AC-003 | WHEN two packages share a wave THE SYSTEM SHALL require disjoint `owned_files` sets or replace their parallel relationship with an explicit sequential fallback in the Wave Plan | Must |
| AC-004 | WHEN a package declares `depends_on` THE SYSTEM SHALL require every referenced package to exist and to have an earlier wave, with `merge_order` resolving integration order within each wave | Must |
| AC-005 | WHEN `/agtoosa-handoff wave` exports work THE SYSTEM SHALL include the selected wave's package IDs, owned files, inputs, outputs, merge order, and verification commands in a Work Packages section | Must |
| AC-006 | WHEN `/agtoosa-import` evaluates returned work THE SYSTEM SHALL compare changed files with `owned_files`, report ownership gaps, and present results in declared `merge_order` before lifecycle checkboxes may change | Should |
| AC-007 | WHEN work-package enforcement is described THE SYSTEM SHALL classify installed schema text as generator-enforced, bats/CI assertions as CI-enforced when configured, package generation and dispatch as agent-instructed, user integration as manual, and runtime scheduling as roadmap | Must |
| AC-008 | WHEN `tests/agtoosa.bats` runs DEV-045 coverage THE SYSTEM SHALL assert dual-path schema parity, Spec/Build/Handoff/Import wiring, dependency ordering, a disjoint-ownership positive fixture, and an overlapping-ownership sequential-fallback fixture | Must |

### 1.4 Failure Modes

| AC | Failure mode |
|----|--------------|
| AC-001 | Workflow authors invent incompatible package fields because no normative schema exists. |
| AC-002 | A parallel task has no ownership or verification boundary, so its agent must guess scope and completion. |
| AC-003 | Same-wave packages own the same file and are still presented as safe to run concurrently. |
| AC-004 | A missing, circular, or same/later-wave dependency permits work to start before required inputs exist. |
| AC-005 | A handoff omits package boundaries, allowing an async result to exceed the approved build scope. |
| AC-006 | Import accepts changed files outside package ownership or ignores declared merge order. |
| AC-007 | Documentation implies AgToosa schedules or enforces parallel agents at runtime. |
| AC-008 | Canonical and installed workflow copies drift without a focused regression failure. |

### 1.5 Out of Scope

- Any edit to `docs/AgToosa_AgentCapability.md`, `template/Docs/AgToosa_AgentCapability.md`, DEV-055 specs/evidence, or AM tests
- Git worktree provisioning or isolation (DEV-046)
- Governance policy-as-code (DEV-059)
- A verifier hard-fail for DAG violations
- Automatic launch, monitoring, or cancellation of external agents
- Version bumps, release publication, or hosted orchestration

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Shipping the canonical and installed schema copies | generator-enforced |
| Focused DAG contract checks when run in repository CI | CI-enforced |
| Deriving and checking Work Package rows during Spec/Build/Handoff/Import | agent-instructed |
| Selecting agents and integrating package branches | manual |
| Runtime DAG scheduling or guaranteed parallel isolation | roadmap |

Until DEV-045 ships with recorded GREEN evidence, Work Package Wave DAG support remains roadmap. `docs/Master-Plan.md` remains the repo-local lifecycle source of truth; handoff and import artifacts cannot change story or task status by themselves.

## 2. Design

### 2.1 Architecture Blueprint

Files to change during the future build:

- `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md` — define `### 3.4 Work Package DAG` after the existing `### 3.3 Test Plan` section
- `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Spec.md` — derive packages from the approved task tree and Wave Plan
- `docs/AgToosa_Build.md`, `template/Docs/AgToosa_Build.md` — check ownership and dependency readiness before fan-out
- `docs/AgToosa_Handoff.md`, `template/Docs/AgToosa_Handoff.md` — export selected package rows after DEV-055 has shipped
- `docs/AgToosa_Import.md`, `template/Docs/AgToosa_Import.md` — report ownership gaps and apply merge order
- `docs/AgToosa_Quickref.md`, `template/Docs/AgToosa_Quickref.md` — summarize DAG readiness
- `docs/AgToosa_Team_Trust_Roadmap.md` — update the capability claim only after evidence exists
- `tests/agtoosa.bats` — add `DAG-001`–`DAG-007`
- `docs/AgToosa_TestPlan-DEV-045.md` — capture future TDD and dogfood evidence

Key interfaces:

- `WorkPackage`: `{ package_id, wave, depends_on, owned_files, inputs, outputs, merge_order, verification }`
- `/agtoosa-spec tasks`: task tree + Wave Plan → Work Package table
- `/agtoosa-handoff wave <N>`: Work Package table → selected-wave pack section
- `/agtoosa-import`: returned changed-file set + package row → ownership-gap and merge-order report

Normative schema target:

```markdown
| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `lib/foo.sh` | — | `lib/foo.sh` | 1 | `bats tests/agtoosa.bats -f "foo"` |
| PKG-1.2 | 1 | — | `docs/AgToosa_Bar.md` | — | `docs/AgToosa_Bar.md` | 1 | `test -s docs/AgToosa_Bar.md` |
| PKG-2.1 | 2 | PKG-1.1, PKG-1.2 | `tests/agtoosa.bats` | Wave 1 outputs | `tests/agtoosa.bats` | 2 | `bats tests/agtoosa.bats -f "DEV-045"` |
```

### 2.2 Data Flow

1. `/agtoosa-spec tasks` reads the approved Build Scope, task tree, and Wave Plan.
2. It writes one package row per executable sub-task and resolves package dependencies from wave sequencing.
3. Before parallel fan-out, `/agtoosa-build` compares same-wave `owned_files`; overlap converts the affected packages to an explicit sequential fallback.
4. `/agtoosa-handoff wave <N>` exports only Wave N rows plus their declared inputs and verification commands.
5. Returned work enters `/agtoosa-import`, which compares changed files to package ownership and reports gaps without mutating `docs/Master-Plan.md`.
6. The user integrates accepted results in `merge_order`; only the normal Build/Import workflow may then update lifecycle state.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A result impersonates a different package | Spoofing | Require a known `package_id` and matching handoff row before import. |
| An agent edits files outside its lane | Tampering | Compare returned paths with `owned_files`; report every extra path as a gap. |
| No record identifies the package used | Repudiation | Handoff and import evidence cite `package_id`, wave, and verification command. |
| Inputs or commands expose secret values | Information Disclosure | Permit paths, artifact names, and redacted commands only; never embed secret values. |
| DAG ceremony blocks small work | Denial of Service | Guidance may keep XS/single-task stories sequential while retaining the ordinary Wave Plan. |
| A package gains sensitive-file authority implicitly | Elevation of Privilege | Require explicit ownership and manual approval for security-sensitive paths; never infer them from a directory wildcard. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope      : `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md`, `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Spec.md`, `docs/AgToosa_Build.md`, `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Handoff.md`, `template/Docs/AgToosa_Handoff.md`, `docs/AgToosa_Import.md`, `template/Docs/AgToosa_Import.md`, `docs/AgToosa_Quickref.md`, `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Team_Trust_Roadmap.md`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-045.md`, `docs/AgToosa_TestPlan-DEV-045.md`

Directories in scope: none beyond the listed files

Out of scope        : DEV-055 files and AM tests, `lib/config.sh`, platform runtime code, worktree automation, verifier changes, release/version files

The future build may begin only after DEV-055 is shipped. Shared Build/Handoff surfaces are sequenced after that prerequisite; this backlog deepening does not alter them.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and RED coverage
  - [ ] 1.1 Add failing `DAG-001`–`DAG-007` fixtures and assertions before implementation — _Requirements: AC-008_
  - [ ] 1.2 Add the normative Work Package schema and examples to both SPEC-FORMAT copies — _Requirements: AC-001, AC-004, AC-007_
- [ ] **2.** Package derivation and execution
  - [ ] 2.1 Define Spec task-to-package derivation, dependency checks, and overlap fallback — _Requirements: AC-002, AC-003, AC-004_
  - [ ] 2.2 Make Build consume ownership, dependencies, and package verification before fan-out — _Requirements: AC-003, AC-004, AC-007_
- [ ] **3.** Async boundary
  - [ ] 3.1 Add the selected-wave Work Packages section to Handoff — _Requirements: AC-005_
  - [ ] 3.2 Add ownership-gap and merge-order reporting to Import — _Requirements: AC-006, AC-007_
- [ ] **4.** Closure
  - [ ] 4.1 Sync Quickref/Trust wording, run future GREEN validation, and record the two-parallel/one-dependent dogfood evidence — _Requirements: AC-007, AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2

**Wave 2 (sequential after Wave 1):** 2.1

**Wave 3 (parallel after Wave 2):** 2.2, 3.1

**Wave 4 (sequential after Wave 3):** 3.2

**Wave 5 (sequential after Wave 4):** 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-045.md`

AC coverage: 8 ACs mapped to 7 test IDs (`DAG-001`–`DAG-007`)

Smoke set: 5 tests tagged `@smoke` (`DAG-001`, `DAG-002`, `DAG-003`, `DAG-005`, `DAG-007`)

## ✅ Spec Approved

Approved: 2026-07-11 21:25
Enrollment: remaining-specs fan-out wave 1 (build/review/ship)
