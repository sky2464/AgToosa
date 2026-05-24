# Spec: DEV-026 — Codex Agent Mode Spec Workflow Execution

> **Story ID:** DEV-026
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v5.0.1 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

Users invoking `/agtoosa-spec` in Codex agent mode report that the workflow does not actually run the required interview, QA/research steps, Goal Contract synthesis, or planning work. The current generated Codex skill is intentionally short and delegates to `Docs/AgToosa_Spec.md`, but that thin dispatcher can be interpreted as a routing hint rather than an execution contract in agent mode.

The behavior owner is the generated Codex surface under `template/.codex/skills/agtoosa-spec/SKILL.md` and, secondarily, `template/.codex/prompts/agtoosa-spec.md`. The canonical workflow remains `template/Docs/AgToosa_Spec.md`; this story must not fork the source of truth or duplicate the whole workflow. The fix is to make the Codex adapter explicit enough that agent mode must execute the workflow phases, ask the smart interview questions when gaps remain, run research, include the Goal Contract, derive tasks, generate the test plan, and stop at the approval gate.

Research summary from repo inspection:

- `template/Docs/AgToosa_Spec.md` already requires context gathering, external research, Story Goal Contract, Smart Interview Protocol, STRIDE threat modeling, task planning, test plan skeleton, and Story Skill Opportunity Synthesis.
- `template/.codex/skills/agtoosa-spec/SKILL.md` currently says to read and run the workflow, but does not enumerate the required phase outputs that prove execution in agent mode.
- Existing bats coverage checks that the skill references `Docs/AgToosa_Spec.md`, dispatches subcommands, and does not duplicate `## Part 1`, but it does not lock the agent-mode execution contract.
- The likely failure mode is instruction under-specification, not missing template inventory or shell copy behavior.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make generated Codex agent mode execute `/agtoosa-spec` as a full workflow, not a shallow dispatcher. |
| User outcome | When a user types `/agtoosa-spec` in Codex agent mode, the agent performs research, Goal Contract synthesis, smart interview, spec generation, task planning, test plan generation, and approval gating. |
| Success condition | Codex spec skill and prompt contain an explicit agent-mode execution contract; bats fail if required phase terms disappear; no adapter claims it may skip interview/research/QA/Goals for the full flow. |
| Proof / evidence | Focused bats coverage for DEV-026 green; existing K2/K3/W1/WP4/Codex inventory tests remain green. |
| Non-goals | Changing the canonical spec workflow semantics; auto-approving specs; auto-running `/agtoosa-build`; duplicating all of `Docs/AgToosa_Spec.md` inside the Codex adapter; changing non-Codex platform behavior unless needed for parity wording. |
| Assumptions | Codex agent mode reads generated project skills and/or prompts, then follows local workflow docs. The adapter needs concrete phase obligations even when the full workflow lives in `Docs/AgToosa_Spec.md`. |
| Risks | Over-duplicating workflow text creates drift; under-specifying the adapter preserves the failure. Mitigate with a short, testable execution contract that names outputs but delegates details to the canonical doc. |

### 1.2 User Stories

**As a** project user running Codex agent mode, **I want** `/agtoosa-spec` to execute the full AgToosa specification workflow **so that** I receive a researched, interview-backed, Goal-aligned spec rather than a routing summary.

**As an** AgToosa maintainer, **I want** bats coverage for the Codex agent-mode execution contract **so that** future template edits cannot regress `/agtoosa-spec` into a shallow dispatcher.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a generated Codex agent-mode user invokes `/agtoosa-spec` with no sub-command THE SYSTEM SHALL instruct the agent to execute the full flow: context/research, Goal Contract, Smart Interview, executable spec, architecture/threat model, task planning, test plan skeleton, and approval gate | Must |
| AC-002 | WHEN a generated Codex agent-mode user invokes `/agtoosa-spec research`, `plan`, `quick`, `tasks`, or `to-issues` THE SYSTEM SHALL dispatch that sub-command while preserving the canonical phase obligations and stop conditions from `Docs/AgToosa_Spec.md` | Must |
| AC-003 | WHEN the Codex spec adapter is maintained THE SYSTEM SHALL keep `Docs/AgToosa_Spec.md` as the canonical source of truth and SHALL NOT duplicate the full workflow body or introduce a second divergent Part 1/Part 2 implementation | Must |
| AC-004 | WHEN DEV-026 ships THE SYSTEM SHALL add bats coverage proving the Codex skill and prompt include the agent-mode execution contract terms for interview, research, Goal Contract, QA/test plan, task planning, and approval gate | Must |
| AC-005 | WHEN `/agtoosa-spec` completes successfully in Codex agent mode THE SYSTEM SHALL stop at spec approval and SHALL NOT auto-run `/agtoosa-build` or mark the spec approved without user approval | Must |

### 1.4 Out of Scope

- Changing the shell installer or template inventory in `lib/config.sh`
- Changing generated project directory layout
- Solving global Codex slash-command picker behavior
- Adding new AgToosa workflow names
- Running `/agtoosa-qa` automatically during `/agtoosa-spec`; this story requires QA/test plan generation, not a post-build QA execution phase
- Auto-approving DEV-026

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `template/.codex/skills/agtoosa-spec/SKILL.md` | Add a concise **Agent Mode Execution Contract** naming required full-flow outputs and forbidden skips; keep `Docs/AgToosa_Spec.md` canonical |
| `template/.codex/prompts/agtoosa-spec.md` | Mirror the same execution contract at prompt level for environments that route through `.codex/prompts/` |
| `tests/agtoosa.bats` | Add DEV-026-focused assertions for Codex skill/prompt contract terms and non-duplication |
| `docs/AgToosa_TestPlan-DEV-026.md` | Map ACs to focused tests |
| `docs/Master-Plan.md` | Add DEV-026 to Backlog and Update Log |

Adapter wording should explicitly require:

1. Read `Docs/AgToosa_Spec.md` in full before writing outputs.
2. With no sub-command, run Parts 1-4 and produce evidence of each part.
3. Do not skip Smart Interview; ask only genuine gaps, but document inferred answers when skipped.
4. Do not skip Goal Contract synthesis.
5. Do not skip research; for dependencies or current platform behavior, verify live sources when required by the workflow.
6. Generate task planning and test plan skeleton as part of the full flow.
7. Stop at the approval gate; no `/agtoosa-build` chaining.

### 2.2 Data Flow

1. User invokes `/agtoosa-spec` in a generated project using Codex agent mode.
2. Codex discovers either `.codex/skills/agtoosa-spec/SKILL.md` or `.codex/prompts/agtoosa-spec.md`.
3. The adapter tells Codex to read `Docs/AgToosa_Spec.md` and execute the matching full or sub-command flow.
4. The adapter-level execution contract requires visible outputs for research, Goal Contract, interview decisions, spec, architecture/threat model, tasks, test plan, and approval gate.
5. The workflow writes the spec/test artifacts and updates `Docs/Master-Plan.md`, then stops for user approval.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent treats the Codex skill as a dispatcher and skips workflow phases | Tampering | AC-001, AC-004 contract assertions name every required phase |
| Agent invents an alternate abbreviated spec process | Repudiation | AC-003 keeps `Docs/AgToosa_Spec.md` canonical and forbids duplicating divergent Part sections |
| Agent skips research and relies on stale dependency/platform assumptions | Information Disclosure | AC-001 requires research phase; canonical workflow still requires live dependency checks |
| Agent silently skips user interview or Goal Contract | Denial of Service | AC-001/AC-004 require Smart Interview and Goal Contract terms in Codex surfaces |
| Agent auto-runs build after spec | Elevation of Privilege | AC-005 preserves phase stop and approval gate |

### 2.4 Build Scope

Files in scope: `template/.codex/skills/agtoosa-spec/SKILL.md`, `template/.codex/prompts/agtoosa-spec.md`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-026.md`, `docs/AgToosa_TestPlan-DEV-026.md`, `docs/Master-Plan.md`

Directories in scope: `template/.codex/`, `tests/`, `docs/`

Out of scope: `lib/config.sh`, `agtoosa.sh`, `agtoosa.ps1`, non-Codex platform adapters, generated `ship/`, release/version files unless the later build changes release behavior

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Codex adapter execution contract
  - [x] 1.1 Add an **Agent Mode Execution Contract** to `template/.codex/skills/agtoosa-spec/SKILL.md` — _Requirements: AC-001, AC-003, AC-005_
  - [x] 1.2 Mirror the contract in `template/.codex/prompts/agtoosa-spec.md` — _Requirements: AC-001, AC-002, AC-005_
- [x] **2.** Regression coverage
  - [x] 2.1 Add bats assertions that Codex spec skill and prompt include required phase terms: Smart Interview, research, Goal Contract, task planning, test plan, and approval gate — _Requirements: AC-001, AC-004_
  - [x] 2.2 Preserve non-duplication checks so the adapter does not embed full `## Part 1` / `## Part 2` workflow bodies — _Requirements: AC-003_
  - [x] 2.3 Confirm W1 phase-stop coverage still passes for Codex spec surfaces — _Requirements: AC-005_
- [x] **3.** Verification and bookkeeping
  - [x] 3.1 Run focused DEV-026 bats filter and existing Codex workflow-skill tests — _Requirements: AC-004, AC-005_
  - [x] 3.2 Update DEV-026 test plan evidence if test IDs or names differ from this spec — _Requirements: AC-004_
  - [x] 3.3 Update `docs/Master-Plan.md` from Backlog to Active Cycle only when the story is explicitly enrolled — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3  
**Wave 3 (sequential after Wave 2):** 3.1, 3.2, 3.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-026.md`

AC coverage: 5 ACs mapped to 5 test IDs

Smoke set: 5 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-05-24 14:45
