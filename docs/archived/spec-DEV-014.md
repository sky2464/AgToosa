# Spec: DEV-014 — Cursor Slash Command Routing

> **Story ID:** DEV-014
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.8.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

Users report that, after AgToosa is installed in Cursor, typing `/agtoosa-status` can route to a generic skill-creation flow instead of the AgToosa status workflow. The observed output is:

`/create-skill called '/agtoosa-status' that does:`

That means the generated Cursor integration is not making the `/agtoosa-*` workflow command contract strong enough for Cursor to treat installed AgToosa commands as workflow commands. DEV-012 fixed the same class of failure for GitHub Copilot by making slash-command routing explicit and reserving `agtoosa-*` names from generated project skills. DEV-014 applies that lesson to Cursor's native project command and rule surfaces.

Current Cursor documentation says project commands are plain Markdown files in `.cursor/commands`, triggered with a `/` prefix by filename. AgToosa already ships `.cursor/commands/agtoosa-status.md` and sibling command files, but those files only contain a short description and workflow pointer. The fix should make Cursor command intent explicit in each command file, ensure always-on Cursor rules reserve `/agtoosa-*` from `/create-skill`, and add bats coverage that installs Cursor and proves the command files and guardrail strings are present.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make Cursor route `/agtoosa-status` and sibling `/agtoosa-*` commands to installed AgToosa workflow command files instead of generic `/create-skill` behavior. |
| User outcome | A Cursor user can type `/agtoosa-status` after installation and receive the read-only status workflow, not a generated skill scaffold. |
| Success condition | Cursor command files explicitly define workflow-command routing, Cursor always-on rules forbid `/create-skill` routing for `/agtoosa-*`, skill synthesis rejects Cursor command shadowing, and focused bats coverage is green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "CU[1-5]:"` green; Cursor platform install contains `.cursor/commands/agtoosa-status.md` with no-`/create-skill` routing guidance. |
| Non-goals | Changing Cursor itself; changing GitHub prompt routing already handled by DEV-012; creating user-level Cursor commands outside the generated project. |
| Assumptions | Cursor still resolves project commands from `.cursor/commands/<command>.md` by filename, and `.cursor/rules/*.mdc` remains the project rule format for always-on routing guardrails. |
| Risks | Cursor command semantics may keep evolving; tests must assert AgToosa's generated contract and not depend on Cursor internals that cannot run in CI. |

### 1.2 User Stories

**As a** developer using AgToosa in Cursor, **I want** `/agtoosa-status` to execute the AgToosa status workflow **so that** I can inspect project health without accidentally creating a skill.

**As an** AgToosa maintainer, **I want** Cursor command and rule files to reserve `/agtoosa-*` workflow names **so that** project-skill synthesis cannot shadow installed workflow commands.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs Cursor command files THE SYSTEM SHALL include explicit routing text that `/agtoosa-*` commands execute installed AgToosa workflow docs and SHALL NOT route to `/create-skill` | Must |
| AC-002 | WHEN a user invokes `/agtoosa-status` in Cursor THE SYSTEM SHALL read `Docs/AgToosa_Status.md`, run the read-only status workflow, and preserve the sub-command dispatch contract | Must |
| AC-003 | WHEN Cursor always-on rules are loaded THE SYSTEM SHALL reserve `/agtoosa-*` and `agtoosa-*` names for installed workflow commands, not generated project skills | Must |
| AC-004 | WHEN `/agtoosa-init` or `/agtoosa-spec` proposes generated project skills THE SYSTEM SHALL reject candidates that would shadow Cursor `.cursor/commands/agtoosa-*.md` files or `/agtoosa-*` triggers | Must |
| AC-005 | WHEN DEV-014 ships THE SYSTEM SHALL add focused bats coverage for Cursor command routing, no-`/create-skill` guardrails, installed file presence, and status workflow delegation | Must |

### 1.4 Out of Scope

- Runtime shell changes in `agtoosa.sh`, `agtoosa.ps1`, or `lib/*.sh` unless install inventory drift is discovered
- GitHub Copilot prompt metadata changes
- Replacing Cursor project commands with another command system
- Changing `/agtoosa-status` dashboard ranking or health-score behavior
- Adding new AgToosa workflow commands

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

| Layer | Files | Change |
|-------|-------|--------|
| Cursor command adapters | `template/.cursor/commands/agtoosa-*.md` | Add explicit command-routing guardrail: this file is the native Cursor command for `/agtoosa-*`; read the matching `Docs/AgToosa_*.md`; do not call `/create-skill` for AgToosa workflow names. |
| Cursor always-on rules | `template/.cursor/rules/agtoosa-core.mdc` | Add reserved workflow-command rule covering `/agtoosa-*`, `agtoosa-*`, `.cursor/commands/agtoosa-*.md`, and `/create-skill` misrouting. |
| Cursor status rule | `template/.cursor/rules/agtoosa-status.mdc` | Reinforce that `/agtoosa-status` delegates to `Docs/AgToosa_Status.md` and remains read-only. |
| Skill synthesis docs | `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md` | Extend reserved-name language to include Cursor command files and command triggers. |
| Tests | `tests/agtoosa.bats` | Add CU1-CU5 coverage for Cursor command routing and no-`/create-skill` guardrails. |

Files to inspect but likely unchanged:

- `lib/config.sh` because `.cursor/commands/agtoosa-status.md` is already registered.
- `README.md` because platform support already lists `.cursor/commands/`.

### 2.2 Data Flow

1. AgToosa installs Cursor support into a project, including `.cursor/commands/agtoosa-status.md`, `.cursor/rules/agtoosa-core.mdc`, and `.cursor/rules/agtoosa-status.mdc`.
2. User types `/agtoosa-status` in Cursor chat.
3. Cursor discovers the project command file by filename in `.cursor/commands/`.
4. The command file states that `/agtoosa-status` is an installed AgToosa workflow command, not a skill-creation request.
5. Cursor reads `Docs/AgToosa_Status.md` and executes the status workflow with no file, git, or Master-Plan mutations.
6. If skill synthesis later runs, it rejects any generated project skill named `agtoosa-status`, triggered by `/agtoosa-status`, or colliding with any `.cursor/commands/agtoosa-*.md` workflow command.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| `/agtoosa-status` is interpreted as `/create-skill` and creates an unwanted project skill | Spoofing | AC-001 and AC-003 make command routing explicit in Cursor command and core rule files |
| A generated project skill shadows `.cursor/commands/agtoosa-status.md` | Tampering | AC-004 extends reserved-name checks to Cursor command-file collisions |
| Agent cannot explain why a Cursor slash command routed incorrectly | Repudiation | AC-005 adds bats coverage for command-file and rule guardrail text |
| Skill creation prompt captures private project context unnecessarily | Information Disclosure | No-`/create-skill` routing prevents accidental skill scaffold generation for workflow commands |
| Cursor command file drift breaks `/agtoosa-status` discoverability | Denial of Service | CU tests assert installed command files remain registered and delegate to canonical docs |
| Generic skill command gains authority over AgToosa workflow names | Elevation of Privilege | Always-on core rule reserves `/agtoosa-*` for installed workflow adapters only |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/.cursor/commands/agtoosa-*.md`, `template/.cursor/rules/agtoosa-core.mdc`, `template/.cursor/rules/agtoosa-status.mdc`, `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md`, `tests/agtoosa.bats`
Directories in scope: `template/.cursor/commands/`, `template/.cursor/rules/`, `template/Docs/`, `tests/`
Out of scope        : `agtoosa.sh`, `agtoosa.ps1`, `lib/*.sh` unless file inventory is proven stale; GitHub prompt routing; Cursor application internals

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Cursor command routing guardrails
  - [x] 1.1 Update every `template/.cursor/commands/agtoosa-*.md` adapter to identify itself as the native Cursor command for its `/agtoosa-*` workflow — _Requirements: AC-001_
  - [x] 1.2 Add explicit no-`/create-skill` wording to Cursor command adapters for AgToosa workflow names — _Requirements: AC-001, AC-003_
  - [x] 1.3 Verify `agtoosa-status.md` delegates to `Docs/AgToosa_Status.md`, preserves `plan`, `readiness`, `git`, and `orphans`, and states read-only behavior — _Requirements: AC-002_
- [x] **2.** Cursor rule reinforcement
  - [x] 2.1 Update `agtoosa-core.mdc` to reserve `/agtoosa-*`, `agtoosa-*`, and `.cursor/commands/agtoosa-*.md` for installed workflow adapters — _Requirements: AC-003_
  - [x] 2.2 Update `agtoosa-status.mdc` with no-mutation and no-`/create-skill` routing language for `/agtoosa-status` — _Requirements: AC-002, AC-003_
- [x] **3.** Skill synthesis collision guardrails
  - [x] 3.1 Update `AgToosa_Init.md` project-skill synthesis rules to reject Cursor command-file collisions — _Requirements: AC-004_
  - [x] 3.2 Update `AgToosa_Spec.md` story-skill synthesis rules to reject `/agtoosa-*` Cursor command triggers — _Requirements: AC-004_
  - [x] 3.3 Update `AgToosa_Skills.md` reserved-name guidance with Cursor `.cursor/commands/agtoosa-*.md` examples — _Requirements: AC-004_
- [x] **4.** Tests
  - [x] 4.1 Add CU1: every Cursor command adapter includes explicit native `/agtoosa-*` workflow routing and no-`/create-skill` wording — _Requirements: AC-001, AC-005_
  - [x] 4.2 Add CU2: `agtoosa-status` Cursor command delegates to `Docs/AgToosa_Status.md`, is read-only, and lists all status sub-commands — _Requirements: AC-002, AC-005_
  - [x] 4.3 Add CU3: Cursor core/status rules reserve `/agtoosa-*` and forbid `/create-skill` routing — _Requirements: AC-003, AC-005_
  - [x] 4.4 Add CU4: skill synthesis docs reject Cursor command collisions — _Requirements: AC-004, AC-005_
  - [x] 4.5 Add CU5: Cursor platform install copies `.cursor/commands/agtoosa-status.md` and the guardrail text survives install/update — _Requirements: AC-001, AC-002, AC-005_
  - [x] 4.6 Run CU-filter and full bats suite; record evidence — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 4.5  
**Wave 3 (sequential after Wave 2):** 4.6

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-014.md`
AC coverage: 5 ACs mapped to 5 test IDs
Smoke set: 5 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24
