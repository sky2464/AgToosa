# Spec: DEV-015 — Windsurf Slash Command Routing

> **Story ID:** DEV-015
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.9.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-012 (GitHub Copilot) and DEV-014 (Cursor) fixed a recurring failure mode: `/agtoosa-*` workflow names are misrouted to generic skill-creation flows (for example `/create-skill called '/agtoosa-status' that does:`). Windsurf is the remaining native workflow-picker surface called out in `docs/agtoosa-maintainer.md` that still ships thin `.windsurf/workflows/agtoosa-*.md` adapters without explicit workflow-command routing guardrails.

AgToosa already installs 14 Windsurf workflows and companion rules under `.windsurf/rules/`, including an always-on `agtoosa-core.md` rule. Those files delegate to `Docs/AgToosa_*.md` but do not state that each workflow file is the native Windsurf entry for its `/agtoosa-*` command or forbid `/create-skill` misrouting. This story applies the DEV-014 pattern to Windsurf workflows and core/status rules, extends skill-synthesis reserved-name language to `.windsurf/workflows/agtoosa-*.md`, and adds focused bats coverage (WS1–WS5).

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make Windsurf route `/agtoosa-status` and sibling `/agtoosa-*` workflows to installed AgToosa workflow files instead of generic skill-creation behavior. |
| User outcome | A Windsurf user can invoke `/agtoosa-status` after installation and receive the read-only status workflow, not a generated skill scaffold. |
| Success condition | Windsurf workflow files explicitly define workflow-command routing, always-on Windsurf rules reserve `/agtoosa-*` from `/create-skill`, skill synthesis rejects Windsurf workflow shadowing, and focused bats coverage is green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "WS[1-5]:"` green; Windsurf platform install contains `.windsurf/workflows/agtoosa-status.md` with no-`/create-skill` routing guidance. |
| Non-goals | Changing Windsurf itself; revisiting GitHub or Cursor routing already shipped in DEV-012/DEV-014; adding new AgToosa workflow commands. |
| Assumptions | Windsurf still discovers project workflows from `.windsurf/workflows/<name>.md` and applies `.windsurf/rules/*.md` with `trigger: always_on` for global guardrails. |
| Risks | Windsurf workflow semantics may evolve; tests must assert AgToosa's generated contract only, not Windsurf IDE internals in CI. |

### 1.2 User Stories

**As a** developer using AgToosa in Windsurf, **I want** `/agtoosa-status` to execute the AgToosa status workflow **so that** I can inspect project health without accidentally creating a skill.

**As an** AgToosa maintainer, **I want** Windsurf workflow and rule files to reserve `/agtoosa-*` workflow names **so that** project-skill synthesis cannot shadow installed workflow adapters.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs Windsurf workflow files THE SYSTEM SHALL include explicit routing text that `/agtoosa-*` commands execute installed AgToosa workflow docs and SHALL NOT route to `/create-skill` | Must |
| AC-002 | WHEN a user invokes `/agtoosa-status` in Windsurf THE SYSTEM SHALL read `Docs/AgToosa_Status.md`, run the read-only status workflow, and preserve the sub-command dispatch contract (`plan`, `readiness`, `git`, `orphans`) | Must |
| AC-003 | WHEN Windsurf always-on rules are loaded THE SYSTEM SHALL reserve `/agtoosa-*` and `agtoosa-*` names for installed workflow adapters, not generated project skills | Must |
| AC-004 | WHEN `/agtoosa-init` or `/agtoosa-spec` proposes generated project skills THE SYSTEM SHALL reject candidates that would shadow `.windsurf/workflows/agtoosa-*.md` files or `/agtoosa-*` triggers | Must |
| AC-005 | WHEN DEV-015 ships THE SYSTEM SHALL add focused bats coverage for Windsurf workflow routing, no-`/create-skill` guardrails, installed file presence, and status workflow delegation | Must |

### 1.4 Out of Scope

- Runtime shell changes in `agtoosa.sh`, `agtoosa.ps1`, or `lib/*.sh` unless install inventory drift is discovered
- GitHub Copilot or Cursor adapter changes
- Gemini TOML routing (separate surface; no reported misroute pattern yet)
- Changing `/agtoosa-status` dashboard ranking or health-score behavior

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Files | Change |
|-------|-------|--------|
| Windsurf workflow adapters | `template/.windsurf/workflows/agtoosa-*.md` | Add explicit workflow-routing guardrail: native Windsurf workflow for `/agtoosa-*`; read matching `Docs/AgToosa_*.md`; do not call `/create-skill` for AgToosa workflow names. |
| Windsurf always-on rules | `template/.windsurf/rules/agtoosa-core.md` | Add reserved workflow-command rule covering `/agtoosa-*`, `agtoosa-*`, `.windsurf/workflows/agtoosa-*.md`, and `/create-skill` misrouting. |
| Windsurf status rule | `template/.windsurf/rules/agtoosa-status.md` | Reinforce `/agtoosa-status` delegation to `Docs/AgToosa_Status.md` and read-only behavior. |
| Skill synthesis docs | `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md` | Extend reserved-name language to include Windsurf workflow files and triggers (alongside existing Cursor/GitHub entries). |
| Tests | `tests/agtoosa.bats` | Add WS1–WS5 coverage mirroring DEV-014 CU series for Windsurf. |

Files to inspect but likely unchanged:

- `lib/config.sh` — `.windsurf/workflows/agtoosa-status.md` already registered
- `README.md` — platform support already lists `.windsurf/workflows/`

### 2.2 Data Flow

1. AgToosa installs Windsurf support, including `.windsurf/workflows/agtoosa-status.md`, `.windsurf/rules/agtoosa-core.md`, and `.windsurf/rules/agtoosa-status.md`.
2. User invokes `/agtoosa-status` in Windsurf.
3. Windsurf discovers the workflow file by name in `.windsurf/workflows/`.
4. The workflow file states that `/agtoosa-status` is an installed AgToosa workflow command, not a skill-creation request.
5. The agent reads `Docs/AgToosa_Status.md` and runs the read-only status workflow.
6. Skill synthesis later rejects any candidate named `agtoosa-status`, triggered by `/agtoosa-status`, or colliding with `.windsurf/workflows/agtoosa-*.md`.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| `/agtoosa-status` interpreted as `/create-skill` and creates an unwanted project skill | Spoofing | AC-001 and AC-003 — explicit routing in workflow and core rule files |
| A generated project skill shadows `.windsurf/workflows/agtoosa-status.md` | Tampering | AC-004 — reserved-name checks include Windsurf workflow paths |
| Agent cannot explain why a Windsurf slash command routed incorrectly | Repudiation | AC-005 — WS bats lock guardrail strings in repo |
| Skill creation prompt captures private project context unnecessarily | Information Disclosure | No-`/create-skill` routing prevents accidental skill scaffold generation |
| Windsurf workflow file drift breaks discoverability | Denial of Service | WS tests assert adapters remain registered and delegate to canonical docs |
| Generic skill command gains authority over AgToosa workflow names | Elevation of Privilege | Always-on `agtoosa-core.md` reserves `/agtoosa-*` for installed adapters only |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/.windsurf/workflows/agtoosa-*.md`, `template/.windsurf/rules/agtoosa-core.md`, `template/.windsurf/rules/agtoosa-status.md`, `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Skills.md`, `tests/agtoosa.bats`
Directories in scope: `template/.windsurf/workflows/`, `template/.windsurf/rules/`, `template/Docs/`, `tests/`
Out of scope        : `agtoosa.sh`, `agtoosa.ps1`, `lib/*.sh` unless file inventory is proven stale; GitHub/Cursor routing; Windsurf application internals

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Windsurf workflow routing guardrails
  - [x] 1.1 Update every `template/.windsurf/workflows/agtoosa-*.md` adapter to identify itself as the native Windsurf workflow for its `/agtoosa-*` command — _Requirements: AC-001_
  - [x] 1.2 Add explicit no-`/create-skill` wording to Windsurf workflow adapters — _Requirements: AC-001, AC-003_
  - [x] 1.3 Verify `agtoosa-status.md` delegates to `Docs/AgToosa_Status.md`, preserves `plan`, `readiness`, `git`, and `orphans`, and states read-only behavior — _Requirements: AC-002_
- [x] **2.** Windsurf rule reinforcement
  - [x] 2.1 Update `agtoosa-core.md` to reserve `/agtoosa-*`, `agtoosa-*`, and `.windsurf/workflows/agtoosa-*.md` — _Requirements: AC-003_
  - [x] 2.2 Update `agtoosa-status.md` rule with no-mutation and no-`/create-skill` routing for `/agtoosa-status` — _Requirements: AC-002, AC-003_
- [x] **3.** Skill synthesis collision guardrails
  - [x] 3.1 Update `AgToosa_Init.md` to reject Windsurf workflow-file collisions — _Requirements: AC-004_
  - [x] 3.2 Update `AgToosa_Spec.md` story-skill synthesis rules for Windsurf triggers — _Requirements: AC-004_
  - [x] 3.3 Update `AgToosa_Skills.md` reserved-name guidance with `.windsurf/workflows/agtoosa-*.md` — _Requirements: AC-004_
- [x] **4.** Tests
  - [x] 4.1 Add WS1: every Windsurf workflow adapter includes native routing and no-`/create-skill` wording — _Requirements: AC-001, AC-005_
  - [x] 4.2 Add WS2: `agtoosa-status` Windsurf workflow delegates read-only with sub-commands — _Requirements: AC-002, AC-005_
  - [x] 4.3 Add WS3: Windsurf core/status rules reserve `/agtoosa-*` and forbid `/create-skill` — _Requirements: AC-003, AC-005_
  - [x] 4.4 Add WS4: skill synthesis docs reject Windsurf workflow collisions — _Requirements: AC-004, AC-005_
  - [x] 4.5 Add WS5: Windsurf platform install copies `agtoosa-status.md` with guardrails intact — _Requirements: AC-001, AC-002, AC-005_
  - [x] 4.6 Run WS-filter and full bats suite; record evidence — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 4.5  
**Wave 3 (sequential after Wave 2):** 4.6

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-015.md`
AC coverage: 5 ACs mapped to 5 test IDs
Smoke set: 5 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24
