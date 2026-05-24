# Spec: DEV-013 — Ship Check Cleanup

> **Story ID:** DEV-013
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.7.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

`/agtoosa-ship check` is intended to be the readiness-gate-only form of the ship workflow. The current contract is close, but several pieces have drifted:

1. `template/Docs/AgToosa_Ship.md` includes Goal Contract verification, while `docs/AgToosa_Ship.md` does not.
2. Some platform adapters call `check` a "pre-flight" command and summarize partial criteria instead of delegating cleanly to Part 0.
3. The readiness gate mixes audit-only behavior with wording that immediately presents a deployment approval gate.
4. Bats coverage does not lock the exact `check` contract across the canonical ship docs and native adapter files.

This story cleans up the contract without removing the sub-command. `/agtoosa-ship check` remains useful as a read-only audit that can be run before a full `/agtoosa-ship`, but its output must stop after readiness findings and must not imply deployment, archiving, version bumping, or changelog mutation.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `/agtoosa-ship check` a clear, read-only readiness audit with aligned docs, adapters, and tests. |
| User outcome | A user can run `/agtoosa-ship check` to learn whether a story is ready to ship, without the agent mutating files or asking for deployment approval. |
| Success condition | Canonical ship docs and native adapters describe `check` consistently; docs and template copies agree on the Part 0 gate; bats locks the no-mutation and no-deploy contract. |
| Proof / evidence | Focused DEV-013 bats filter green; full `bats tests/agtoosa.bats` green when environment permits; grep confirms no stale "pre-flight checks only" adapter text remains for `check`. |
| Non-goals | Removing `/agtoosa-ship check`; changing deployment mechanics; changing `/agtoosa-ship docs` or `/agtoosa-ship retro` semantics beyond wording needed for parity. |
| Assumptions | Existing generated projects may already expose `check`, so preserving the sub-command is less disruptive than folding it into full `/agtoosa-ship`. |
| Risks | Over-tightening the readiness gate could block valid releases if docs require evidence a project cannot produce; the implementation should phrase fallback evidence clearly. |

### 1.2 User Stories

**As a** developer preparing a release, **I want** `/agtoosa-ship check` to audit readiness without deploying **so that** I can fix gaps before asking for ship approval.

**As an** AgToosa maintainer, **I want** ship-check wording and adapters aligned **so that** every supported AI surface runs the same gate and test suite prevents drift.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-ship check` is documented THE SYSTEM SHALL define it as a read-only readiness audit that stops after reporting pass/fail findings | Must |
| AC-002 | WHEN the Part 0 readiness gate is rendered in maintainer docs and generated templates THE SYSTEM SHALL include the same Goal Contract, spec approval, AC, review, test, smoke, changelog, and WIP-commit checks | Must |
| AC-003 | WHEN native platform adapters describe `/agtoosa-ship check` THE SYSTEM SHALL delegate to `Docs/AgToosa_Ship.md` Part 0 and SHALL NOT imply deployment, archiving, changelog mutation, or approval-gate execution | Must |
| AC-004 | WHEN `/agtoosa-ship check` fails any readiness item THE SYSTEM SHALL report each failure with the command or manual action that resolves it | Must |
| AC-005 | WHEN `/agtoosa-ship` runs the full flow THE SYSTEM SHALL still run the readiness gate first and present deployment approval only after the gate passes | Should |
| AC-006 | WHEN DEV-013 ships THE SYSTEM SHALL add focused bats coverage for ship-check parity and no-mutation/no-deploy wording | Must |

### 1.4 Out of Scope

- Removing or renaming `/agtoosa-ship check`
- Implementing a shell runtime for slash commands
- Changing release version wiring in `agtoosa.sh` or `agtoosa.ps1`
- Changing status next-action ranking
- Adding new platform entry-point files

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

| Layer | Files | Change |
|-------|-------|--------|
| Canonical workflow docs | `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md` | Align Part 0 text and gate table; make `check` explicitly read-only; separate readiness-pass output from full-flow deploy approval. |
| Native adapters | `template/.claude/commands/agtoosa-ship.md`, `template/.cursor/commands/agtoosa-ship.md`, `template/.cursor/rules/agtoosa-ship.mdc`, `template/.gemini/commands/agtoosa-ship.toml`, `template/.github/prompts/agtoosa-ship.prompt.md`, `template/.codex/skills/agtoosa-ship/SKILL.md`, `template/.windsurf/rules/agtoosa-ship.md`, `template/.windsurf/workflows/agtoosa-ship.md` | Replace stale "pre-flight" summaries with Part 0 delegation and no-mutation/no-deploy wording for `check`. |
| Top-level help surfaces | `template/AGENTS.md`, `template/CLAUDE.md`, `template/OPENCODE.md`, `template/.github/copilot-instructions.md` if needed | Preserve the `check` sub-command listing while avoiding wording drift. |
| Tests | `tests/agtoosa.bats` | Add focused C-series coverage for Part 0 parity and adapter wording. |

Files to inspect but likely unchanged:

- `lib/config.sh` because no template file inventory change is expected.
- `CHANGELOG.md` until ship time; it already carries the planned DEV-013 item under `[Unreleased]`.

### 2.2 Data Flow

1. User invokes `/agtoosa-ship check` from any supported AI surface.
2. The native adapter dispatches to `Docs/AgToosa_Ship.md` Part 0 only.
3. The agent reads the active story, archived spec, archived review, test plan, changelog, and git history.
4. The agent reports pass/fail for each readiness item with exact remediation commands or manual actions.
5. If all checks pass, the agent prints a readiness-only success line and stops. It does not ask for deploy approval unless the user invoked the full `/agtoosa-ship` flow.
6. When the user invokes full `/agtoosa-ship`, the same Part 0 gate runs first; after it passes, the full flow presents the deploy approval gate and proceeds only with explicit approval.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| `check` wording causes an agent to deploy or mutate docs during a readiness audit | Tampering | AC-001 and AC-003 require read-only/no-deploy wording in canonical docs and adapters |
| Different platforms run different ship readiness gates | Repudiation | AC-002 and AC-006 add parity tests over canonical docs and adapters |
| A failed readiness item lacks a fix path, causing users to bypass the gate | Denial of Service | AC-004 requires per-finding remediation command or manual action |
| A full ship skips readiness after `check` exists as a standalone sub-command | Elevation of Privilege | AC-005 keeps Part 0 mandatory for full `/agtoosa-ship` |
| Gate evidence accidentally includes secrets or private deploy output | Information Disclosure | Keep evidence requirements to pass/fail summaries, command names, artifact paths, and redacted logs |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary
Files in scope      : `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md`, `template/.claude/commands/agtoosa-ship.md`, `template/.cursor/commands/agtoosa-ship.md`, `template/.cursor/rules/agtoosa-ship.mdc`, `template/.gemini/commands/agtoosa-ship.toml`, `template/.github/prompts/agtoosa-ship.prompt.md`, `template/.codex/skills/agtoosa-ship/SKILL.md`, `template/.windsurf/rules/agtoosa-ship.md`, `template/.windsurf/workflows/agtoosa-ship.md`, `tests/agtoosa.bats`
Directories in scope: `template/Docs/`, `template/.claude/commands/`, `template/.cursor/`, `template/.gemini/commands/`, `template/.github/prompts/`, `template/.codex/skills/agtoosa-ship/`, `template/.windsurf/`, `tests/`
Out of scope        : `agtoosa.sh`, `agtoosa.ps1`, `lib/*.sh`, deployment provider automation, release version bumps, non-ship workflow semantics

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Canonical ship-check contract
  - [x] 1.1 Align `docs/AgToosa_Ship.md` Part 0 with the generated template copy, including Goal Contract verification — _Requirements: AC-002_
  - [x] 1.2 Update Part 0 to state that `/agtoosa-ship check` is read-only and stops after readiness reporting — _Requirements: AC-001_
  - [x] 1.3 Split readiness-pass output from full-flow deploy approval wording — _Requirements: AC-001, AC-005_
- [x] **2.** Platform adapter cleanup
  - [x] 2.1 Update Claude, Cursor, Gemini, GitHub, Codex, and Windsurf ship adapters to delegate `check` to Part 0 only — _Requirements: AC-003_
  - [x] 2.2 Remove stale "pre-flight checks only" summaries and replace them with "read-only readiness audit" wording — _Requirements: AC-001, AC-003_
  - [x] 2.3 Verify top-level help surfaces still list `check` without conflicting behavior text — _Requirements: AC-003_
- [x] **3.** Failure remediation wording
  - [x] 3.1 Ensure the Part 0 failure path requires one remediation command or manual action per failed check — _Requirements: AC-004_
  - [x] 3.2 Include redaction guidance for evidence captured from deploy/test logs — _Requirements: AC-004_
- [x] **4.** Tests
  - [x] 4.1 Add C1: maintainer and template ship docs both include Goal Contract and read-only `check` wording — _Requirements: AC-001, AC-002, AC-006_
  - [x] 4.2 Add C2: ship adapters delegate `check` to Part 0 and include no-deploy/no-mutation wording — _Requirements: AC-003, AC-006_
  - [x] 4.3 Add C3: stale "pre-flight checks only" text is absent from ship adapters — _Requirements: AC-003, AC-006_
  - [x] 4.4 Add C4: failure path requires remediation commands or manual actions — _Requirements: AC-004, AC-006_
  - [x] 4.5 Add C5: full `/agtoosa-ship` still requires Part 0 before deploy approval — _Requirements: AC-005, AC-006_
  - [x] 4.6 Run the C-filter and full bats suite; record evidence — _Requirements: AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3, 3.1, 3.2  
**Wave 3 (parallel after Wave 2):** 4.1, 4.2, 4.3, 4.4, 4.5  
**Wave 4 (sequential after Wave 3):** 4.6

## ✅ Spec Approved

Approved: 2026-05-23

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-013.md`
AC coverage: 6 ACs mapped to 6 test IDs
Smoke set: 5 tests tagged @smoke
