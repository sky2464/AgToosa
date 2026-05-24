# Spec: DEV-016 — Gemini Slash Command Routing

> **Story ID:** DEV-016
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.11.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-012 (GitHub Copilot), DEV-014 (Cursor), and DEV-015 (Windsurf) fixed a recurring failure mode: `/agtoosa-*` workflow names are misrouted to generic skill-creation flows (for example `/create-skill called '/agtoosa-status' that does:`). Gemini CLI is the remaining native slash-command surface in `docs/agtoosa-maintainer.md` that installs `.gemini/commands/agtoosa-*.toml` adapters without explicit workflow-command routing guardrails.

AgToosa already ships 14 Gemini TOML command files under `template/.gemini/commands/` and routes users through `template/AGENTS.md` plus `Docs/AgToosa_Gemini.md`. Those files delegate to `Docs/AgToosa_*.md` and include phase-stop wording from DEV-010, but they do not state that each TOML file is the native Gemini entry for its `/agtoosa-*` command or forbid `/create-skill` misrouting. Reserved-name language in `AgToosa_Init.md`, `AgToosa_Spec.md`, and `AgToosa_Skills.md` covers Cursor, Windsurf, GitHub, and Codex — not `.gemini/commands/agtoosa-*.toml`. This story applies the DEV-014/015 pattern to Gemini TOML adapters and `AGENTS.md`, extends skill-synthesis collision rules, and adds focused bats coverage (GM1–GM5).

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make Gemini CLI route `/agtoosa-status` and sibling `/agtoosa-*` commands to installed AgToosa TOML adapters instead of generic skill-creation behavior. |
| User outcome | A Gemini CLI user can invoke `/agtoosa-status` after installation and receive the read-only status workflow, not a generated skill scaffold. |
| Success condition | Gemini TOML adapters explicitly define workflow-command routing, `AGENTS.md` reserves `/agtoosa-*` from `/create-skill`, skill synthesis rejects Gemini command shadowing, and focused bats coverage is green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "GM[1-5]:"` green; Gemini platform install (option 4) contains `.gemini/commands/agtoosa-status.toml` with no-`/create-skill` routing guidance. |
| Non-goals | Changing Gemini CLI itself; revisiting GitHub, Cursor, or Windsurf routing already shipped; adding new AgToosa workflow commands; implementing DEV-003 registry. |
| Assumptions | Gemini CLI still discovers project commands from `.gemini/commands/<name>.toml` and applies `AGENTS.md` for global agent instructions. |
| Risks | Gemini TOML or CLI semantics may evolve; tests must assert AgToosa's generated contract only, not Gemini internals in CI. |

### 1.2 User Stories

**As a** developer using AgToosa in Gemini CLI, **I want** `/agtoosa-status` to execute the AgToosa status workflow **so that** I can inspect project health without accidentally creating a skill.

**As an** AgToosa maintainer, **I want** Gemini command files and `AGENTS.md` to reserve `/agtoosa-*` workflow names **so that** project-skill synthesis cannot shadow installed TOML adapters.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs Gemini command TOML files THE SYSTEM SHALL include explicit routing text that `/agtoosa-*` commands execute installed AgToosa workflow docs and SHALL NOT route to `/create-skill` | Must |
| AC-002 | WHEN a user invokes `/agtoosa-status` in Gemini CLI THE SYSTEM SHALL read `Docs/AgToosa_Status.md`, run the read-only status workflow, and preserve the sub-command dispatch contract (`plan`, `readiness`, `git`, `orphans`) | Must |
| AC-003 | WHEN Gemini `AGENTS.md` is loaded THE SYSTEM SHALL reserve `/agtoosa-*` and `agtoosa-*` names for installed `.gemini/commands/agtoosa-*.toml` adapters, not generated project skills | Must |
| AC-004 | WHEN `/agtoosa-init` or `/agtoosa-spec` proposes generated project skills THE SYSTEM SHALL reject candidates that would shadow `.gemini/commands/agtoosa-*.toml` files or `/agtoosa-*` triggers | Must |
| AC-005 | WHEN DEV-016 ships THE SYSTEM SHALL add focused bats coverage for Gemini command routing, no-`/create-skill` guardrails, installed file presence, and status workflow delegation | Must |

### 1.4 Out of Scope

- Runtime shell changes in `agtoosa.sh`, `agtoosa.ps1`, or `lib/*.sh` unless install inventory drift is discovered
- GitHub Copilot, Cursor, or Windsurf adapter changes
- Community template registry (`DEV-003` epic)
- Changing `/agtoosa-status` dashboard ranking or health-score behavior

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| Gemini command adapters | `template/.gemini/commands/agtoosa-*.toml` | Add explicit routing guardrail in each `prompt`: native Gemini CLI command for `/agtoosa-*`; read matching `Docs/AgToosa_*.md`; do not call `/create-skill` for AgToosa workflow names. |
| Gemini global instructions | `template/AGENTS.md` | Add reserved workflow-command rule covering `/agtoosa-*`, `agtoosa-*`, `.gemini/commands/agtoosa-*.toml`, and `/create-skill` misrouting. |
| Gemini platform doc | `template/Docs/AgToosa_Gemini.md` | Reinforce `/agtoosa-status` read-only delegation and sub-command dispatch (optional depth; `AGENTS.md` is primary). |
| Skill synthesis docs | `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md` | Extend reserved-name language to include `.gemini/commands/agtoosa-*.toml` (alongside existing Cursor/Windsurf/GitHub entries). |
| Tests | `tests/agtoosa.bats` | Add GM1–GM5 coverage mirroring DEV-015 WS series for Gemini. |

Files to inspect but likely unchanged:

- `lib/config.sh` — `.gemini/commands/agtoosa-*.toml` already registered
- `README.md` — platform support already lists `.gemini/commands/`

### 2.2 Data Flow

1. AgToosa installs Gemini support, including `.gemini/commands/agtoosa-status.toml` and `AGENTS.md`.
2. User invokes `/agtoosa-status` in Gemini CLI.
3. Gemini discovers the command by filename stem in `.gemini/commands/`.
4. The TOML `prompt` states that `/agtoosa-status` is an installed AgToosa workflow command, not a skill-creation request.
5. The agent reads `Docs/AgToosa_Status.md` and runs the read-only status workflow.
6. Skill synthesis later rejects any candidate named `agtoosa-status`, triggered by `/agtoosa-status`, or colliding with `.gemini/commands/agtoosa-*.toml`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| `/agtoosa-status` interpreted as `/create-skill` and creates an unwanted project skill | Spoofing | AC-001 and AC-003 — explicit routing in TOML adapters and `AGENTS.md` |
| A generated project skill shadows `.gemini/commands/agtoosa-status.toml` | Tampering | AC-004 — reserved-name checks include Gemini command paths |
| Agent cannot explain why a Gemini slash command routed incorrectly | Repudiation | AC-005 — GM bats lock guardrail strings in repo |
| Skill creation prompt captures private project context unnecessarily | Information Disclosure | No-`/create-skill` routing prevents accidental skill scaffold generation |
| Gemini TOML adapter drift breaks discoverability | Denial of Service | GM tests assert adapters remain registered and delegate to canonical docs |
| Generic skill command gains authority over AgToosa workflow names | Elevation of Privilege | `AGENTS.md` reserves `/agtoosa-*` for installed adapters only |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/.gemini/commands/agtoosa-*.toml`, `template/AGENTS.md`, `template/Docs/AgToosa_Gemini.md`, `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md`, `tests/agtoosa.bats`
Directories in scope: `template/.gemini/commands/`, `template/Docs/`, `tests/`
Out of scope        : `agtoosa.sh`, `agtoosa.ps1`, `lib/*.sh` unless file inventory is proven stale; GitHub/Cursor/Windsurf routing; DEV-003 registry; Gemini application internals

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Gemini TOML routing guardrails
  - [x] 1.1 Update every `template/.gemini/commands/agtoosa-*.toml` adapter to identify itself as the native Gemini CLI command for its `/agtoosa-*` command — _Requirements: AC-001_
  - [x] 1.2 Add explicit no-`/create-skill` wording to Gemini TOML adapters — _Requirements: AC-001, AC-003_
  - [x] 1.3 Verify `agtoosa-status.toml` delegates to `Docs/AgToosa_Status.md`, preserves `plan`, `readiness`, `git`, and `orphans`, and states read-only behavior — _Requirements: AC-002_
- [x] **2.** Gemini global instruction reinforcement
  - [x] 2.1 Update `template/AGENTS.md` to reserve `/agtoosa-*`, `agtoosa-*`, and `.gemini/commands/agtoosa-*.toml` — _Requirements: AC-003_
  - [x] 2.2 Update `AgToosa_Gemini.md` with status read-only and no-`/create-skill` routing for `/agtoosa-status` — _Requirements: AC-002, AC-003_
- [x] **3.** Skill synthesis collision guardrails
  - [x] 3.1 Update `AgToosa_Init.md` to reject Gemini command-file collisions — _Requirements: AC-004_
  - [x] 3.2 Update `AgToosa_Spec.md` story-skill synthesis rules for Gemini triggers — _Requirements: AC-004_
  - [x] 3.3 Update `AgToosa_Skills.md` reserved-name guidance with `.gemini/commands/agtoosa-*.toml` — _Requirements: AC-004_
- [x] **4.** Tests
  - [x] 4.1 Add GM1: every Gemini TOML adapter includes native routing and no-`/create-skill` wording — _Requirements: AC-001, AC-005_
  - [x] 4.2 Add GM2: `agtoosa-status` Gemini command delegates read-only with sub-commands — _Requirements: AC-002, AC-005_
  - [x] 4.3 Add GM3: `AGENTS.md` reserves `/agtoosa-*` and forbids `/create-skill` — _Requirements: AC-003, AC-005_
  - [x] 4.4 Add GM4: skill synthesis docs reject Gemini command collisions — _Requirements: AC-004, AC-005_
  - [x] 4.5 Add GM5: Gemini platform install (option 4) copies `agtoosa-status.toml` with guardrails intact — _Requirements: AC-001, AC-002, AC-005_
  - [x] 4.6 Run GM-filter and full bats suite; record evidence — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 4.5  
**Wave 3 (sequential after Wave 2):** 4.6

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-016.md`  
AC coverage: 5 ACs mapped to 5 test IDs  
Smoke set: 5 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24 (build authorized via `/agtoosa-build DEV-016`)
