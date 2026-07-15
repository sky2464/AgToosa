# Spec: DEV-117 — Cycle Continuity Guard

> **Story ID:** DEV-117
> **Epic:** DEV-004 — Testing & QA Harness
> **Status:** 🔍 In Review (review approved — pending ship)
> **Estimate:** S
> **Clarity:** ready
> **Spec created:** 2026-07-13
> **Parent:** DEV-007 (status empty-cycle guidance) · DEV-109 (lifecycle next-step sync) · DEV-116 (Lifecycle Compass)

## Context

After DEV-116 shipped, the Active Cycle was deliberately empty while the maintainer chose the next scoped story. The verifier emitted `G3-idle`, and the status workflow treated every empty cycle as a warning with a Plan Completeness deduction. That makes an intentional pause look like missing process discipline and encourages placeholder work merely to improve a score.

An empty cycle still needs a visible next step, but it must distinguish an explicitly declared pause from an accidental omission. DEV-117 introduces a small, auditable `Cycle state` contract: `Idle` is neutral for the empty-cycle finding only; it does not suppress unrelated signals such as stale activity, high-priority backlog, or git drift.

**Smart interview decisions (recorded — 2026-07-13):**

| Decision | Choice |
|----------|--------|
| Story | DEV-117: Cycle Continuity Guard |
| State contract | Structured Project Charter field: `Cycle state | Active` or `Idle — <reason>` |
| Idle behavior | Explicit idle is informational and neutral for verifier/status empty-cycle handling |
| Guardrail | An unmarked empty cycle remains a warning; `Idle` does not suppress independent risk findings |
| Estimate | S |
| Enrollment | Active Cycle now; stop at Spec Approved gate |

**Story Skill Opportunity Synthesis (2026-07-13):**

| Skill name | Trigger | Purpose | Decision | Reason |
|------------|---------|---------|----------|--------|
| `cycle-continuity-audit` | Maintainer checks cycle state | Interpret `Cycle state` | Do not generate | One-shot verifier/status contract; existing lifecycle workflows own the task |

### Spec Quality Analyzer (2026-07-13)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC to test-plan mapping | Pass — see test plan |
| Claim Boundary classified | Pass — section 1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make an explicitly idle Active Cycle an auditable, informational lifecycle state rather than a verifier/status warning, while preserving warnings for accidentally empty cycles and unrelated risk. |
| User outcome | Maintainers can finish a release and intentionally pause before selecting the next story without score degradation or pressure to enroll a placeholder. |
| Success condition | `Cycle state` is documented and shipped in the Master-Plan template; an empty `Idle` cycle passes verifier Gate 3 without `G3-idle`; status treats it as Info with no empty-cycle Plan Completeness deduction; unmarked cycles and independent findings retain their current warnings. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-117.md`; focused `DEV-117` / `CCG-` bats; mirror checks; verifier default and strict runs on idle and unmarked fixtures. |
| Non-goals | Auto-enrolling a next story; hiding stale Update Log, high-priority backlog, branch, blocked, or orphan findings; changing phase ordering; introducing a new CLI flag or runtime state store. |
| Assumptions | `docs/Master-Plan.md` remains the repo-local source of truth; status is a documented agent workflow while Gate 3 is deterministic shell behavior. |
| Risks | A permissive marker could conceal neglected work; mitigate by requiring explicit `Cycle state: Idle`, retaining all non-empty-cycle findings, and testing the unmarked case. |
| Unresolved questions | None. |

### 1.2 User Stories

**As an** AgToosa maintainer between planned stories, **I want** to declare an Active Cycle intentionally idle **so that** lifecycle health reports distinguish a deliberate pause from missing planning.

**As an** AgToosa user, **I want** accidental empty cycles and unrelated risks to remain visible **so that** an idle marker cannot conceal neglected delivery work.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a Master Plan Project Charter declares `Cycle state` as `Idle` and its Active Cycle has no real story rows THE SYSTEM SHALL recognize the cycle as intentionally idle and report the state as informational, not as a missing-story warning. | Must |
| AC-002 | WHEN the Master Plan template is installed THE SYSTEM SHALL include a `Cycle state` Project Charter field whose documented values are `Active` and `Idle — <reason>`, with `Idle — awaiting next scoped story` as the empty-cycle default. | Must |
| AC-003 | WHEN `agtoosa-verify.sh` evaluates an explicitly idle empty cycle THE SYSTEM SHALL record Gate 3 as pass, SHALL NOT emit `G3-idle`, and SHALL preserve a successful exit in both default and `--strict` modes. | Must |
| AC-004 | WHEN `agtoosa-verify.sh` evaluates an empty cycle without an explicit idle declaration THE SYSTEM SHALL continue to emit the existing guided `G3-idle` warning. | Must |
| AC-005 | WHEN `/agtoosa-status` parses an explicitly idle empty cycle THE SYSTEM SHALL present an Info finding and SHALL apply no Plan Completeness deduction for the absence of an active story. | Must |
| AC-006 | WHILE `Cycle state` is `Idle` WHEN the dashboard detects an aged Update Log, high-priority backlog with no active story, blocked work, branch drift, orphaned work, or another independent condition THE SYSTEM SHALL retain that condition's existing finding and scoring behavior. | Must |
| AC-007 | WHEN verifier and status workflow behavior changes THE SYSTEM SHALL keep `template/Docs/` and `docs/` mirrors aligned and add focused `CCG-` bats that cover idle, unmarked-empty, strict-mode, status contract, and mirror parity. | Must |
| AC-008 | WHEN DEV-117 ships THE SYSTEM SHALL record RED and GREEN evidence without claiming status workflow enforcement beyond the documented agent contract. | Must |

**Failure modes (Must ACs):**

| Requirement | Failure mode |
|-------------|--------------|
| 001 | Intentional pause is still treated as lifecycle failure |
| 003 | `--strict` fails solely because an idle cycle is explicit |
| 004 | A forgotten Active Cycle silently passes without an auditable declaration |
| 005 | Status score still penalizes `Idle` and drives placeholder enrollment |
| 006 | `Idle` masks genuine project or delivery risk |
| 007 | Installed projects receive drifted verifier/status guidance |

### 1.4 Out of Scope

- Automatic detection of whether a cycle is intentionally idle
- A time-based idle expiry or automatic state transition
- Suppressing stale, backlog, blocked, git, orphan, or readiness findings
- New CLI flags, JSON schema changes, or external tracker synchronization
- Enrolling, building, reviewing, or shipping another story automatically

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | Gate 3 only passes empty cycles when it finds a textual `cycle parked` or `_(none` marker; the current maintainer Master Plan uses `_(none — enroll...)_`, yet status documentation still treats every empty cycle as a warning and deducts 10 Plan Completeness points. |
| Intended change deltas | Structured `Cycle state` vocabulary; deterministic Gate 3 recognition of explicit Idle; status workflow and health-score exemption; focused CCG regression coverage. |
| Drift evidence | `/agtoosa-status` on 2026-07-13: `G3-idle` warning for deliberate post-DEV-116 idle state. |
| Claim Boundary | See section 1.6. |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth. |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Gate 3 detection of explicit idle state and default/strict exit behavior | generator-enforced |
| CCG bats and mirror checks when bats run | CI-enforced |
| `/agtoosa-status` classification, score, and next-action presentation | agent-instructed |
| Setting `Cycle state` to `Idle` or `Active` in a repository Master Plan | manual |
| Runtime enforcement of planning cadence or automatic story enrollment | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `template/Docs/Master-Plan.md` | Add `Cycle state` to Project Charter and document `Active` / `Idle — <reason>` beside the empty-cycle placeholder. |
| `docs/Master-Plan.md` | Use `Cycle state: Active` while DEV-117 is enrolled; set the expected idle form when the cycle is closed at ship. |
| `template/Docs/agtoosa-verify.sh` | Replace loose parked-marker recognition with a bounded Project Charter parse for explicit `Cycle state: Idle`; pass only that declared empty state. |
| `docs/agtoosa-verify.sh` | Mirror the template verifier exactly. |
| `template/Docs/AgToosa_Status.md` | Define explicit Idle as an Info condition, exempt it from the empty-cycle warning/deduction, and retain independent-risk behavior. |
| `docs/AgToosa_Status.md` | Mirror the template status workflow exactly. |
| `tests/agtoosa.bats` | Add DEV-117 `CCG-001` through `CCG-005` fixtures and mirror/strict assertions. |

### 2.2 Data Flow

1. A maintainer sets the Project Charter field to `Cycle state | Idle — <reason>` after completing or intentionally pausing a cycle.
2. Gate 3 parses the Active Cycle and the bounded Project Charter field.
3. If there are no real story rows and the field declares `Idle`, Gate 3 records a pass and skips story-spec checks.
4. If there are no real story rows and the field is absent or not `Idle`, Gate 3 retains `G3-idle` as a guided warning.
5. `/agtoosa-status` reads the same declaration: it reports Info and excludes only the empty-cycle Plan Completeness deduction.
6. Status continues normal evaluation for all other findings; its recommended next action may still recommend `/agtoosa-spec` as informational guidance when no higher-priority finding exists.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A neglected project is marked Idle to avoid scrutiny | Repudiation | Require explicit, visible reason and retain stale-log, backlog, blocked, git, and orphan findings. |
| Free-form marker text matches accidentally | Tampering | Parse the bounded Project Charter `Cycle state` field and only recognize an `Idle` value. |
| Mirrored docs diverge from verifier semantics | Tampering | Add CCG mirror-contract bats and update template first. |
| Strict verification becomes less meaningful | Denial of Service | Keep `--strict` promotion for all real warnings; explicit Idle produces no warning by design. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/Docs/Master-Plan.md`, `docs/Master-Plan.md`, `template/Docs/agtoosa-verify.sh`, `docs/agtoosa-verify.sh`, `template/Docs/AgToosa_Status.md`, `docs/AgToosa_Status.md`, `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-117.md`, `docs/agtoosa-events.jsonl`
Directories in scope: `template/Docs/`, `docs/`, `tests/`
Out of scope        : CLI argument parsing, PowerShell implementation, version wiring, external trackers, automatic enrollment, unrelated status scoring

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Cycle-state contract: add the bounded Project Charter vocabulary and maintainer lifecycle transition.
  - [x] 1.1 Update the template and maintainer Master Plans with `Cycle state` semantics and the current DEV-117 Active state — _Requirements: AC-001, AC-002_
- [x] **2.** Deterministic verifier: recognize only explicit idle cycles and retain accidental-empty warnings.
  - [x] 2.1 Implement and mirror Gate 3 `Cycle state: Idle` parsing with default and strict behavior — _Requirements: AC-003, AC-004, AC-007_
- [x] **3.** Status contract: make explicit idle informational without hiding other risk.
  - [x] 3.1 Update and mirror status parsing, scoring, and next-action rules for `Cycle state: Idle` — _Requirements: AC-005, AC-006, AC-007_
- [x] **4.** Regression proof: add focused CCG coverage and capture evidence.
  - [x] 4.1 Add CCG bats for explicit idle, unmarked empty, strict mode, status contract, and mirror parity; record RED/GREEN evidence — _Requirements: AC-003, AC-004, AC-005, AC-006, AC-007, AC-008_
- [x] **5.** Ship readiness follow-up: close the per-Must smoke-coverage gate.
  - [x] 5.1 Tag `CCG-005` as smoke and align DEV-117 traceability — _Requirements: AC-005, AC-006, AC-007, AC-008_

### Wave Plan

**Wave 1 (sequential):** 1.1
**Wave 2 (parallel):** 2.1, 3.1
**Wave 3 (sequential after Wave 2):** 4.1
**Wave 4 (review follow-up):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-117.md`
AC coverage: 8 ACs mapped to 5 test IDs
Smoke set: 5 tests tagged `@smoke`

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `template/Docs/Master-Plan.md`, `docs/Master-Plan.md` | DEV-117 spec | Cycle state contract | 1 | `rg -n 'Cycle state' template/Docs/Master-Plan.md docs/Master-Plan.md` |
| PKG-2.1 | 2 | PKG-1.1 | `template/Docs/agtoosa-verify.sh`, `docs/agtoosa-verify.sh` | Cycle state contract | Idle-aware Gate 3 | 2 | `bats tests/agtoosa.bats -f 'CCG-001|CCG-002|CCG-003'` |
| PKG-3.1 | 2 | PKG-1.1 | `template/Docs/AgToosa_Status.md`, `docs/AgToosa_Status.md` | Cycle state contract | Idle-aware status contract | 2 | `bats tests/agtoosa.bats -f 'CCG-004'` |
| PKG-4.1 | 3 | PKG-2.1, PKG-3.1 | `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-117.md` | Waves 1-2 outputs | CCG regression evidence | 3 | `bats tests/agtoosa.bats -f 'DEV-117|CCG-'` |
| PKG-5.1 | 4 | PKG-4.1 | `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-117.md` | Ship readiness finding | Per-Must smoke coverage | 4 | `test "$(rg -c '@test ".*@smoke CCG-' tests/agtoosa.bats)" -eq 5` |

### 3.5 Story Skill Opportunity

No story-specific skill will be generated. The proposed check is covered by existing lifecycle workflows and has no repeated independent operator workflow.

## Spec Revision Log

| Revision | Date | Change | Reason | Approval |
|----------|------|--------|--------|----------|
| R1 | 2026-07-13 | Add `docs/agtoosa-events.jsonl` to Build Scope | Build start/complete events are mandatory lifecycle evidence; no requirement or product-scope change | Build-authorized; no Must AC change |
| R2 | 2026-07-14 | Add task 5.1 to tag CCG-005 as smoke | `/agtoosa-ship` found AC-005–AC-007 lacked a tagged smoke path | User-authorized build follow-up; no product-behavior change |

## Capability Delta

Capability: lifecycle-health

| Change | Requirement | Notes |
|--------|-------------|-------|
| Explicit idle state | AC-001 through AC-006 | Idle is auditable and neutral only for empty-cycle handling. |

## Approval Gate

This draft is ready for approval. `/agtoosa-build` must not begin until the approval marker is appended.

## ✅ Spec Approved

Approved by: User
Approved: 2026-07-13 21:25
