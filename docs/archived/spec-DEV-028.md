# Spec: DEV-028 — Plan-Mode Spec Interview for /agtoosa-spec

> **Story ID:** DEV-028
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟨 In Progress
> **Estimate:** M
> **Spec created:** 2026-05-24

## Context

Users report that `/agtoosa-spec` currently does not ask enough useful questions before writing a spec. The canonical workflow includes a Smart Interview section, but the behavior is too easy for agents to treat as optional: several native adapters only route to the workflow, and the current four-question budget can prematurely collapse product intent, scope, security, test evidence, and rollout decisions into assumptions.

This story strengthens `/agtoosa-spec` into a plan-mode-style interview workflow. The agent must research first, infer what it can from repository context, ask only high-value unresolved questions, adapt the next question from previous answers, and stop only when the spec is decision-complete or the user explicitly accepts documented assumptions.

Research summary:

- GitHub Copilot Plan Mode emphasizes research, a proposed plan, open questions, and iterative review before implementation: https://docs.github.com/en/copilot/how-tos/chat-with-copilot/chat-in-ide#using-plan-mode
- GitHub Copilot prompt files provide reusable per-interaction instructions through `.prompt.md` files, matching AgToosa's generated Copilot prompt surface: https://docs.github.com/en/copilot/concepts/prompting/response-customization?tool=webui#about-prompt-files
- Claude Code Plan Mode separates analysis/planning from editing and requires user approval before implementation: https://code.claude.com/docs/en/permission-modes#analyze-before-you-edit-with-plan-mode
- Cursor CLI Plan Mode asks clarifying questions to refine a plan before coding: https://cursor.com/changelog/cli-jan-16-2026#plan-mode-in-cli
- AgToosa already has the right cross-platform surfaces registered in `lib/config.sh`; the missing contract is behavioral, not inventory.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `/agtoosa-spec` behave like a planning interview before it writes or finalizes a spec. |
| User outcome | A user invoking `/agtoosa-spec` receives a researched, clarified, decision-complete specification instead of a shallow draft with hidden assumptions. |
| Success condition | Canonical spec workflow and all native spec adapters require plan-mode interview behavior; bats fail if the adaptive question budget, decision-complete fields, adapter parity, or phase-stop wording regresses. |
| Proof / evidence | DEV-028 focused bats coverage passes for canonical workflow wording, adapter parity, and phase-stop behavior; existing W1/W3, CS*, G*, CU*, WS*, GM*, and Codex skill regressions remain green. |
| Non-goals | Implementing a new runtime engine; changing generator file inventory; auto-running `/agtoosa-build`; changing `/agtoosa-init` interview semantics; solving external platform slash-picker behavior. |
| Assumptions | DEV-028 stays in Backlog until DEV-027 review/ship decisions finish. Adaptive cap 8 is enough for normal specs while preserving momentum. |
| Risks | Agents may over-ask instead of inferring, skip security/rollout/test decisions, or duplicate canonical workflow bodies across adapters. Mitigate with a compact canonical contract, adapter references, and grep-based regression tests. |
| Unresolved questions | None for spec scope; build may choose exact bats test IDs. |

### 1.2 User Stories

**As a** generated-project user, **I want** `/agtoosa-spec` to ask smart clarifying questions before creating a spec **so that** the resulting spec captures what actually needs to be built.

**As an** AgToosa maintainer, **I want** the plan-mode interview contract locked across Copilot, Cursor, Codex, Claude, Gemini, and Windsurf surfaces **so that** agents cannot regress `/agtoosa-spec` into a shallow dispatcher.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-spec` is invoked without a sub-command THE SYSTEM SHALL run a Plan-Mode Spec Interview before writing the final spec | Must |
| AC-002 | WHEN the Plan-Mode Spec Interview starts THE SYSTEM SHALL explore the codebase, context files, Master-Plan, active specs, and relevant external sources before asking user questions | Must |
| AC-003 | WHEN the agent asks an interview question THE SYSTEM SHALL ask one question at a time, derive 2-3 concrete options from repo/research context when possible, mark one recommended default, and allow free-text override | Must |
| AC-004 | WHEN an answer is already inferable with high confidence THE SYSTEM SHALL state the finding and not ask that question | Must |
| AC-005 | WHEN the full `/agtoosa-spec` interview runs THE SYSTEM SHALL use an adaptive cap of 8 core questions and SHALL keep `/agtoosa-spec quick` capped at 2 questions | Must |
| AC-006 | IF decision-complete clarity is still missing after 8 core questions THEN THE SYSTEM SHALL stop and ask whether to continue the interview or proceed with documented assumptions | Must |
| AC-007 | WHEN `/agtoosa-spec` generates the spec THE SYSTEM SHALL include decision-complete coverage for Goal Contract, non-goals, acceptance criteria, scope boundary, affected surfaces, risk/failure modes, security/trust boundaries, test evidence, rollout/compatibility, and unresolved assumptions | Must |
| AC-008 | WHEN native spec adapters are maintained THE SYSTEM SHALL reference the Plan-Mode Spec Interview Contract and SHALL keep `Docs/AgToosa_Spec.md` as the canonical source of truth without duplicating full workflow bodies | Must |
| AC-009 | WHEN `/agtoosa-spec` reaches completion THE SYSTEM SHALL stop at the approval gate and SHALL NOT auto-run `/agtoosa-build` or mark the spec approved without user approval | Must |
| AC-010 | WHEN DEV-028 ships THE SYSTEM SHALL add bats coverage for the canonical contract, adapter parity, question budgets, decision-complete fields, and phase-stop regression | Must |

### 1.4 Out of Scope

- Adding or removing template inventory entries in `lib/config.sh`
- Changing `agtoosa.sh`, `agtoosa.ps1`, install, update, or registry behavior
- Changing `/agtoosa-init` discovery depth or Project Skill Discovery
- Running external issue creation during spec
- Auto-approving DEV-028 or enrolling it into the active cycle before DEV-027 is resolved

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `template/Docs/AgToosa_Spec.md` | Add a Plan-Mode Spec Interview Contract and replace the current weak forcing-question wording with adaptive cap 8 behavior |
| `docs/AgToosa_Spec.md` | Mirror the maintainer dogfood wording with lowercase `docs/` paths |
| `template/Docs/AgToosa_Agent.md` | Update shared Smart Interview budget row for `/agtoosa-spec` and clarify decision-complete behavior if needed |
| Native spec adapters under `template/` | Add compact parity wording that `/agtoosa-spec` must research, interview, plan, generate spec/tasks/test plan, and stop at approval |
| `tests/agtoosa.bats` | Add DEV-028 assertions for canonical wording, budget, decision-complete fields, adapter parity, and phase stop |
| `docs/AgToosa_TestPlan-DEV-028.md` | Map all Must ACs to regression tests |
| `docs/Master-Plan.md` | Add DEV-028 to Backlog and Update Log only; leave DEV-027 active |

Native spec adapters in scope:

- `template/.codex/skills/agtoosa-spec/SKILL.md`
- `template/.codex/prompts/agtoosa-spec.md`
- `template/.github/prompts/agtoosa-spec.prompt.md`
- `template/.cursor/rules/agtoosa-spec.mdc`
- `template/.cursor/commands/agtoosa-spec.md`
- `template/.windsurf/rules/agtoosa-spec.md`
- `template/.windsurf/workflows/agtoosa-spec.md`
- `template/.claude/commands/agtoosa-spec.md`
- `template/.gemini/commands/agtoosa-spec.toml`

The canonical contract should state:

1. Read context and scan the codebase before asking.
2. Ask only about genuine gaps.
3. Ask one question at a time.
4. Derive options from repository evidence and research; mark one recommended default.
5. Adapt each next question from previous answers.
6. Stop after 8 core questions unless the user explicitly continues.
7. Do not write the final spec until the decision-complete checklist is satisfied or assumptions are documented and accepted.
8. Stop at the approval gate after spec/tasks/test plan output.

### 2.2 Data Flow

1. User invokes `/agtoosa-spec` in a generated project or maintainer dogfood context.
2. The platform adapter routes to `Docs/AgToosa_Spec.md` or `docs/AgToosa_Spec.md`.
3. The agent performs read-only grounding: context files, Master-Plan, active specs, codebase scan, architecture docs, and external research when current platform/dependency behavior matters.
4. The agent builds a gap list against the decision-complete checklist.
5. The agent asks at most 8 core questions, one at a time, skipping inferable answers and documenting findings.
6. The agent generates the spec, task tree, test plan skeleton, and approval gate.
7. The workflow stops for user approval and does not auto-run build.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent writes a spec without clarifying critical scope | Tampering | AC-001, AC-006, AC-007 decision-complete gate |
| Agent asks generic questions already answerable from repo context | Denial of Service | AC-002 and AC-004 infer-first rules |
| Adapter behavior drifts across platforms | Repudiation | AC-008 adapter parity tests |
| Agent skips security or trust-boundary discussion | Elevation of Privilege | AC-007 requires security/trust-boundary coverage |
| Agent auto-runs build after spec approval gate | Elevation of Privilege | AC-009 phase-stop assertions |
| Duplicated workflow bodies diverge from canonical spec doc | Tampering | AC-008 forbids full-body duplication in adapters |

### 2.4 Build Scope

Files in scope: `template/Docs/AgToosa_Spec.md`, `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Agent.md`, `/agtoosa-spec` native adapters under `template/`, `tests/agtoosa.bats`, `docs/AgToosa_TestPlan-DEV-028.md`, `docs/archived/spec-DEV-028.md`, `docs/Master-Plan.md`

Directories in scope: `template/Docs/`, `template/.claude/`, `template/.cursor/`, `template/.gemini/`, `template/.github/`, `template/.windsurf/`, `template/.codex/`, `docs/`, `tests/`

Out of scope: `agtoosa.sh`, `agtoosa.ps1`, `lib/`, generated `ship/`, release/version files, and non-spec workflow adapters.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Canonical plan-mode contract
  - [x] 1.1 Add the Plan-Mode Spec Interview Contract to `template/Docs/AgToosa_Spec.md` — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_
  - [x] 1.2 Mirror the contract in `docs/AgToosa_Spec.md` with maintainer `docs/` path conventions — _Requirements: AC-001, AC-002, AC-007_
  - [x] 1.3 Update shared Smart Interview budget wording in `template/Docs/AgToosa_Agent.md` if needed — _Requirements: AC-005, AC-006_
- [x] **2.** Native adapter parity
  - [x] 2.1 Update Codex skill and prompt spec adapters with compact plan-mode execution wording — _Requirements: AC-008, AC-009_
  - [x] 2.2 Update GitHub Copilot prompt and Cursor rule/command spec adapters — _Requirements: AC-008, AC-009_
  - [x] 2.3 Update Claude, Gemini, and Windsurf spec adapters — _Requirements: AC-008, AC-009_
- [x] **3.** Regression coverage
  - [x] 3.1 Add DEV-028 bats assertions for canonical Plan-Mode Spec Interview Contract wording — _Requirements: AC-001, AC-002, AC-003, AC-004_
  - [x] 3.2 Add bats assertions for adaptive cap 8, quick cap 2, and continue/proceed gate after budget exhaustion — _Requirements: AC-005, AC-006_
  - [x] 3.3 Add bats assertions for decision-complete fields and adapter parity across all native spec surfaces — _Requirements: AC-007, AC-008_
  - [x] 3.4 Confirm existing phase-stop tests still cover `/agtoosa-build` non-chaining — _Requirements: AC-009, AC-010_
- [x] **4.** Validation and bookkeeping
  - [x] 4.1 Run DEV-028 focused bats filter — _Requirements: AC-010_
  - [x] 4.2 Run relevant regression filters: W1/W3, CS*, G*, CU*, WS*, GM*, K2/K3/CX1 where available — _Requirements: AC-008, AC-009, AC-010_
  - [x] 4.3 Update `docs/AgToosa_TestPlan-DEV-028.md` evidence with actual test names and results — _Requirements: AC-010_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (sequential after Wave 2):** 3.1, 3.2, 3.3, 3.4  
**Wave 4 (sequential after Wave 3):** 4.1, 4.2, 4.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-028.md`

AC coverage: 10 ACs mapped to 10 test IDs

Smoke set: 9 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-05-24 (explicit user approval; build completed via `/agtoosa-build DEV-028`)
