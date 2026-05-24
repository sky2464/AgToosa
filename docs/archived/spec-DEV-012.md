# Spec: DEV-012 — GitHub Slash Command Routing

> **Story ID:** DEV-012
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟨 In Progress
> **Estimate:** S
> **Spec created:** 2026-05-23

## Context

Users report that typing `/agtoosa-spec` in the GitHub Copilot surface does not reliably route to the AgToosa specification workflow. Instead, Copilot may surface or execute a generic `/create-skill` flow, producing text like `/create-skill called '/agtoosa-review' that does: ...`.

This is fixable. The generated GitHub prompt files already exist under `template/.github/prompts/agtoosa-*.prompt.md`, but the adapter contract is weaker than the current Copilot prompt-file contract: prompt files can define an explicit `name` used after typing `/`, and AgToosa's project-skill synthesis docs do not explicitly reserve `agtoosa-*` workflow command names from generated project skills.

The fix is to make command routing deterministic across GitHub Copilot prompt files and generated-skill guardrails:

1. Every GitHub prompt file declares the exact slash command name.
2. GitHub instructions state that `/agtoosa-*` commands are workflow prompts, not `/create-skill` requests.
3. Skill synthesis refuses to generate or suggest skills named `agtoosa-*` or triggered by `/agtoosa-*` unless updating the installed AgToosa workflow adapter itself.
4. Bats locks the prompt metadata and no-create-skill guardrails.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `/agtoosa-spec` and sibling `/agtoosa-*` commands route to AgToosa workflow prompts in GitHub Copilot instead of generic skill creation. |
| User outcome | A user can type `/agtoosa-spec` and get the spec workflow, not a prompt asking to create a skill named after another AgToosa command. |
| Success condition | GitHub prompt files have explicit names; instructions reserve `agtoosa-*` workflow names; skill synthesis refuses duplicate workflow command triggers; G1-G5 bats green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "G[1-5]:"` green; representative generated project contains `.github/prompts/agtoosa-spec.prompt.md` with `name: agtoosa-spec`. |
| Non-goals | Implementing GitHub Copilot itself; changing Claude/Cursor/Gemini command semantics; removing Story Skill Opportunity Synthesis. |
| Assumptions | GitHub Copilot prompt files are still the supported AgToosa surface for GitHub slash-command discoverability. |
| Risks | GitHub Copilot prompt-file frontmatter is preview-era behavior and may evolve; tests should assert AgToosa's generated contract, not Copilot internals. |

### 1.2 User Stories

**As a** developer using AgToosa with GitHub Copilot, **I want** `/agtoosa-spec` to invoke the spec workflow **so that** I can start planning without Copilot misclassifying the command as skill creation.

**As an** AgToosa maintainer, **I want** `agtoosa-*` workflow names reserved from generated project skills **so that** skill synthesis cannot create duplicate command triggers that shadow installed workflow prompts.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs GitHub prompt files THE SYSTEM SHALL include explicit `name: agtoosa-...` metadata matching each prompt filename | Must |
| AC-002 | WHEN GitHub Copilot reads AgToosa repository instructions THE SYSTEM SHALL treat `/agtoosa-*` as workflow command prompts and SHALL NOT treat them as `/create-skill` requests | Must |
| AC-003 | WHEN `/agtoosa-init` or `/agtoosa-spec` proposes generated project skills THE SYSTEM SHALL reject candidates named `agtoosa-*` or triggered by `/agtoosa-*` unless the decision is to update an existing AgToosa workflow adapter | Must |
| AC-004 | WHEN `/agtoosa-spec` is invoked through GitHub Copilot THE SYSTEM SHALL read `Docs/AgToosa_Spec.md` and execute the spec workflow, preserving phase-stop and approval-gate behavior | Must |
| AC-005 | WHEN DEV-012 ships THE SYSTEM SHALL add focused bats coverage for GitHub prompt `name` metadata and `agtoosa-*` duplicate-skill guardrails | Must |

### 1.4 Out of Scope

- Runtime changes in `agtoosa.sh` or `agtoosa.ps1`
- New GitHub app or MCP server integration
- Renaming existing AgToosa commands
- Creating user-specific Copilot configuration outside the generated repo
- Replacing Codex workflow skills

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

| Layer | Files | Change |
|-------|-------|--------|
| GitHub prompt adapters | `template/.github/prompts/agtoosa-*.prompt.md` | Add explicit `name: agtoosa-*` frontmatter to every AgToosa prompt file; for agent prompts, prefer current `agent: agent` metadata while preserving compatible behavior if `mode: agent` is still kept. |
| GitHub repo instructions | `template/.github/copilot-instructions.md`, `template/.github/agents/agtoosa.agent.md` | Add routing rule: `/agtoosa-*` means execute the matching workflow prompt/doc; do not call `/create-skill` for these names. |
| Skill synthesis docs | `template/Docs/AgToosa_{Init,Spec,Skills}.md`, `template/OPENCODE.md` if needed | Reserve `agtoosa-*` names and `/agtoosa-*` triggers for installed workflow adapters; generated project skills must use non-conflicting names. |
| Codex workflow skill | `template/.codex/skills/agtoosa-spec/SKILL.md` | Clarify Story Skill Opportunity Synthesis must not propose skills that shadow AgToosa workflow commands. |
| Tests | `tests/agtoosa.bats` | Add G1-G5 coverage. |

Files to inspect but likely unchanged:

- `lib/config.sh` if file inventory changes are not needed.
- `README.md` only if GitHub setup docs need a user-facing note.

### 2.2 Data Flow

1. User types `/agtoosa-spec` in GitHub Copilot Chat.
2. Copilot discovers `.github/prompts/agtoosa-spec.prompt.md` by explicit `name: agtoosa-spec`.
3. The prompt instructs Copilot to read `Docs/AgToosa_Spec.md`, dispatch any sub-command, run the spec workflow, and stop at the approval gate.
4. If skill synthesis runs during the workflow, it checks proposed names/triggers against reserved `agtoosa-*` workflow names and chooses **Do not generate** or **Update existing** for duplicates.
5. No `/create-skill` flow is invoked unless the user explicitly asks to create a non-AgToosa project skill.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| `/agtoosa-spec` is interpreted as `/create-skill` and creates an unwanted project skill | Spoofing | AC-001 explicit prompt names; AC-002 routing rule |
| Generated project skill shadows `/agtoosa-review` or another workflow command | Tampering | AC-003 reserved-name guardrail and dedupe rule |
| Agent cannot explain why the wrong command ran | Repudiation | Tests assert routing metadata and guardrail strings |
| Skill synthesis embeds command text or private workflow context into an unnecessary generated skill | Information Disclosure | Existing secret-safety rules plus duplicate rejection |
| Prompt metadata drift breaks slash discovery on GitHub surfaces | Denial of Service | AC-005 bats over all `.github/prompts/agtoosa-*.prompt.md` files |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/.github/prompts/agtoosa-*.prompt.md`, `template/.github/copilot-instructions.md`, `template/.github/agents/agtoosa.agent.md`, `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md`, `template/.codex/skills/agtoosa-spec/SKILL.md`, `tests/agtoosa.bats`
Directories in scope: `template/.github/prompts/`, `template/.github/agents/`, `template/Docs/`, `template/.codex/skills/agtoosa-spec/`
Out of scope        : `agtoosa.sh`, `agtoosa.ps1`, `lib/*.sh`, user-level GitHub Copilot config, non-GitHub platform behavior except shared skill-synthesis docs

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** GitHub prompt metadata
  - [x] 1.1 Add explicit `name: agtoosa-*` frontmatter to all GitHub prompt adapters — _Requirements: AC-001, AC-004_
  - [x] 1.2 Verify `agtoosa-spec.prompt.md` keeps phase-stop and approval-gate text — _Requirements: AC-004_
- [x] **2.** GitHub routing guardrails
  - [x] 2.1 Update Copilot instructions with the `/agtoosa-*` workflow-routing rule — _Requirements: AC-002_
  - [x] 2.2 Update the AgToosa GitHub agent file with the same no-`/create-skill` rule — _Requirements: AC-002_
- [x] **3.** Skill synthesis dedupe
  - [x] 3.1 Update init/spec synthesis docs to reserve `agtoosa-*` workflow names and `/agtoosa-*` triggers — _Requirements: AC-003_
  - [x] 3.2 Update `AgToosa_Skills.md` and the `agtoosa-spec` Codex workflow skill with the duplicate-shadowing rule — _Requirements: AC-003_
- [x] **4.** Tests
  - [x] 4.1 Add G1: every GitHub prompt adapter has `name: agtoosa-*` matching its file stem — _Requirements: AC-001, AC-005_
  - [x] 4.2 Add G2: GitHub instructions forbid `/create-skill` routing for `/agtoosa-*` commands — _Requirements: AC-002, AC-005_
  - [x] 4.3 Add G3: skill synthesis docs reject `agtoosa-*` generated project skill duplicates — _Requirements: AC-003, AC-005_
  - [x] 4.4 Add G4: `agtoosa-spec` GitHub prompt still points to `Docs/AgToosa_Spec.md` and phase stop — _Requirements: AC-004, AC-005_
  - [x] 4.5 Run G-filter and full bats; record evidence — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 3.1, 3.2, 4.1, 4.2, 4.3, 4.4  
**Wave 3 (sequential after Wave 2):** 4.5

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-012.md`
AC coverage: 5 ACs mapped to 5 test IDs
Smoke set: 5 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24
