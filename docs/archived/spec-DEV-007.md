# Spec: DEV-007 — /agtoosa-help next on-demand assistance helper

> **Story ID:** DEV-007
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped
> **Estimate:** S
> **Spec created:** 2026-05-23

## Context

`/agtoosa-help` currently prints a static command reference. It is useful as an assistance command, but it is not a main AgToosa workflow phase and should not be loaded or run unless the user explicitly asks for help. After DEV-006 shipped the Status Guide, the only remaining Planned item in `CHANGELOG.md` is `/agtoosa-help next`, and ADR-005 names it as the follow-up.

This story adds the smallest useful version of `/agtoosa-help next`: a read-only, context-aware helper that looks at current project state and tells the user the next AgToosa command to run. It must stay an on-demand helper, not a phase gate and not an auto-dispatcher.

**Smart Interview findings:**

| Question | Finding |
|----------|---------|
| Status quo | `/agtoosa-help` has three native variants (`.claude`, `.gemini`, `.github`) plus Cursor/Windsurf core fallbacks; no canonical `Docs/AgToosa_Help.md` exists. |
| Narrowest scope | Add `next` guidance to existing help surfaces and core fallbacks; read status/context; recommend one next command; no command execution. |
| Urgency | `CHANGELOG.md` still lists `/agtoosa-help next` as the only Planned item after DEV-006. |
| Failure modes | Help becomes a main workflow phase; help auto-runs mutating commands; variants drift across platforms. |
| Security surface | Read-only local files and git/status context only; no secrets, external APIs, or dependency changes. |

## 1. Requirements

### 1.1 User Stories

**As a** developer using AgToosa, **I want** `/agtoosa-help next` to inspect the current project state and suggest the next command **so that** I can recover orientation without running the full Status Guide manually.

**As an** AgToosa maintainer, **I want** help to remain an on-demand assistance helper **so that** it does not become a main workflow phase or mutate project state.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-help` is invoked without `next` THE SYSTEM SHALL display the static command reference without requiring a project status read | Must |
| AC-002 | WHEN `/agtoosa-help next` is invoked THE SYSTEM SHALL read current project state and recommend exactly one next AgToosa command with a short rationale | Must |
| AC-003 | WHEN `/agtoosa-help next` reads project state THE SYSTEM SHALL remain read-only and SHALL NOT modify files, git state, or Master-Plan state | Must |
| AC-004 | WHEN the recommended next command is mutating THE SYSTEM SHALL present it as a suggestion only and SHALL NOT auto-run it | Must |
| AC-005 | WHEN help variants are installed THE SYSTEM SHALL expose `/agtoosa-help next` in Claude, Gemini, GitHub Copilot, and Cursor/Windsurf core fallback help text | Must |
| AC-006 | WHEN the active cycle is empty THE SYSTEM SHALL recommend `/agtoosa-spec` as the next command | Must |
| AC-007 | WHEN an active story has completed build tasks and a passing review THE SYSTEM SHALL recommend `/agtoosa-ship` | Should |
| AC-008 | WHEN DEV-007 ships THE SYSTEM SHALL remove `/agtoosa-help next` from `CHANGELOG.md` Planned and add a completed changelog entry | Should |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Plain help becomes slow or stateful because it always loads project context |
| AC-002 | Help gives vague advice instead of one actionable command |
| AC-003 | Help mutates Master-Plan during an assistance read |
| AC-004 | Help auto-runs `/agtoosa-spec`, `/agtoosa-build`, or `/agtoosa-ship` without authorization |
| AC-005 | Cursor/Windsurf drift because help has no per-command variant there |
| AC-006 | Empty-cycle users remain stuck after asking for next help |

### 1.3 Out of Scope

- Creating a new main lifecycle phase.
- Creating native Cursor/Windsurf `agtoosa-help` command files.
- Running Status Guide automatically as a sub-agent unless the user explicitly asks for Status Guide.
- Changing `/agtoosa-status` Part 5.5 ranking.
- Implementing an LLM router or persistent help daemon.

## 2. Design

### 2.1 Architecture Blueprint

```
Files to change:
  - template/.claude/commands/agtoosa-help.md
  - template/.gemini/commands/agtoosa-help.toml
  - template/.github/prompts/agtoosa-help.prompt.md
  - template/.cursor/rules/agtoosa-core.mdc
  - template/.windsurf/rules/agtoosa-core.md
  - template/Docs/AgToosa_Agent.md
  - docs/AgToosa_Agent.md
  - tests/agtoosa.bats
  - CHANGELOG.md

Files to create:
  - docs/adr/ADR-006-help-on-demand-assistance.md
  - docs/AgToosa_TestPlan-help-next.md
```

Key behavior:

- Plain `/agtoosa-help` stays static and fast.
- `/agtoosa-help next` performs a read-only context read, then recommends one next command.
- The helper may reference Status Guide as a deeper option, but does not invoke it automatically.

### 2.2 Data Flow

1. User invokes `/agtoosa-help`.
2. If no sub-command is supplied, the agent prints the static command reference.
3. If the sub-command is `next`, the agent reads `Docs/Master-Plan.md`, recent changelog/planned items, and current git status without mutations.
4. The agent chooses exactly one recommended next command using simple state ordering:
   - Empty active cycle -> `/agtoosa-spec`
   - Active story with unchecked tasks -> `/agtoosa-build`
   - Active story with all tasks complete and no review -> `/agtoosa-review`
   - Active story reviewed with no critical findings -> `/agtoosa-ship`
   - Unclear or multiple findings -> `/agtoosa-status` or Status Guide for deeper diagnosis
5. The agent prints the recommendation, rationale, and a reminder that no command has been run.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Help mutates project state while “just helping” | Tampering | AC-003 read-only rule and bats grep |
| Help auto-runs a mutating command | Elevation | AC-004 suggestion-only rule |
| Help variants drift and confuse users | Repudiation | AC-005 parity tests across 3 help variants plus 2 core fallbacks |
| Prompt-injected repo text causes command execution | Spoofing/Elevation | Read status context only; recommend but never execute |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : template help variants, cursor/windsurf core fallbacks, Agent docs, tests/agtoosa.bats, CHANGELOG.md
Directories in scope: template/.claude/, template/.gemini/, template/.github/, template/.cursor/, template/.windsurf/, docs/, tests/
Out of scope        : /agtoosa-status algorithm changes, new Cursor/Windsurf help files, generator install logic, runtime CLI flags
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Help behavior wording
  - [x] 1.1 Update Claude `/agtoosa-help` with static default and `next` read-only helper behavior — _Requirements: AC-001–AC-004, AC-006_
  - [x] 1.2 Update Gemini `/agtoosa-help` with matching behavior — _Requirements: AC-001–AC-004, AC-006_
  - [x] 1.3 Update GitHub Copilot `/agtoosa-help` with matching behavior — _Requirements: AC-001–AC-004, AC-006_
- [x] **2.** Fallback parity
  - [x] 2.1 Mirror help-next guidance into Cursor core fallback — _Requirements: AC-005_
  - [x] 2.2 Mirror help-next guidance into Windsurf core fallback — _Requirements: AC-005_
- [x] **3.** Framework references
  - [x] 3.1 Update Agent docs to list `/agtoosa-help next` as assistance-only — _Requirements: AC-001, AC-002_
  - [x] 3.2 Keep `/agtoosa-help` outside the main workflow diagrams/tables — _Requirements: AC-001_
- [x] **4.** Bats parity
  - [x] 4.1 Add tests for help-next in the three native help variants — _Requirements: AC-005_
  - [x] 4.2 Add tests for Cursor/Windsurf core fallback wording — _Requirements: AC-005_
  - [x] 4.3 Add tests for read-only and suggestion-only wording — _Requirements: AC-003, AC-004_
- [x] **5.** Planned item closure
  - [x] 5.1 Update `CHANGELOG.md` when built so `/agtoosa-help next` leaves Planned — _Requirements: AC-008_
- [x] **6.** Validation
  - [x] 6.1 Run focused help-next bats tests and full bats suite — _Requirements: AC-005_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3, 2.1, 2.2  
**Wave 2 (sequential):** 3.1, 3.2, 4.1, 4.2, 4.3  
**Wave 3 (ship phase):** 5.1, 6.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-help-next.md`  
AC coverage: 8 ACs mapped to 8 test IDs  
Smoke set: 6 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-23 15:22
