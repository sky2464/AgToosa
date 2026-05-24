# Spec: DEV-027 — Agentic `/agtoosa-update`

> **Story ID:** DEV-027
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v5.1.0 — 2026-05-24)
> **Estimate:** M
> **Spec created:** 2026-05-24

## Context

`/agtoosa-update` currently has a split contract. The canonical generated workflow says it is a pure read command that produces a project briefing with no shell commands or external tools. Several native adapters and skills describe it as refreshing or syncing AgToosa workflow files. The real mutating update path already exists in the generator CLI as `bash agtoosa.sh --update <project>`.

This story resolves that mismatch by making `/agtoosa-update` an agentic update workflow: it detects whether the project is behind, plans the update, asks for explicit approval, runs the CLI update, and verifies the result. A read-only `check` mode remains available for users who only want a briefing.

Research summary from repo and platform review:

- `lib/update.sh` is the behavior owner for mutating installs: it overwrites generated workflow docs, smart-merges platform entry points, refreshes known native dirs, updates lock metadata, and writes `Docs/.agtoosa-version`.
- `template/Docs/AgToosa_Update.md` is the canonical agent-facing workflow and must stop claiming the default command is pure read-only.
- Platform adapters under `template/.claude/`, `.cursor/`, `.gemini/`, `.github/`, `.windsurf/`, and `.codex/` must agree on the Detect → Plan → Apply → Verify contract.
- The CLI should remain the source of truth for file mutation; the agent workflow should orchestrate preflight, approval, execution, and verification.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `/agtoosa-update` safely perform the same effective update job as `bash agtoosa.sh --update` when a project is behind, while preserving an approval gate. |
| User outcome | A user can run `/agtoosa-update` in an installed project, see what will change, approve it, and have the agent run and verify the real CLI update. |
| Success condition | The canonical workflow and all native adapters define Detect → Plan → Apply → Verify; default drift handling is ask-then-apply; `check` remains read-only; tests lock the contract. |
| Proof / evidence | Focused bats coverage for canonical wording, adapter parity, CLI preservation behavior, preflight/migration wording, and verification expectations passes. |
| Non-goals | Replacing `agtoosa.sh --update`; silently mutating files without approval; changing user-owned preservation rules; implementing a full release manager; solving external platform picker limitations. |
| Assumptions | The user approves ask-then-apply as the default. Generated projects can run shell commands only when the current assistant environment supports them and the user approves mutation. |
| Risks | Agent may mutate without approval, skip CLI update, hide drift, or claim update success without verification. Mitigate with explicit workflow gates, adapter parity, and bats assertions. |

### 1.2 User Stories

**As a** generated-project user, **I want** `/agtoosa-update` to run the real AgToosa update after showing a plan and getting approval **so that** my project can catch up to the latest workflow baseline without leaving the AI assistant.

**As an** AgToosa maintainer, **I want** the update workflow and platform adapters to share one testable contract **so that** future template edits do not regress into read-only briefing or silent mutation.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-update` is invoked without a sub-command THE SYSTEM SHALL execute the Detect → Plan → Apply → Verify workflow and default to ask-then-apply when drift is detected | Must |
| AC-002 | WHEN drift is detected THE SYSTEM SHALL prepare to run `bash agtoosa.sh --update <project>` and SHALL present the planned overwrites, smart merges, native dir refreshes, preserved files, and expected backups before mutation | Must |
| AC-003 | WHEN `/agtoosa-update` reaches the Apply stage THE SYSTEM SHALL ask for explicit approval before running any mutating command | Must |
| AC-004 | WHEN the user approves Apply THE SYSTEM SHALL run the CLI update as the source of truth, then verify version marker, lock metadata when present, platform surfaces, preserved files, and duplicate marker safety | Must |
| AC-005 | WHEN `/agtoosa-update check` is invoked THE SYSTEM SHALL remain read-only and produce the project briefing without running shell commands or mutating files | Must |
| AC-006 | WHEN `/agtoosa-update plan`, `apply`, or `verify` is invoked THE SYSTEM SHALL run only that named stage plus required prerequisites and SHALL document its stop condition | Must |
| AC-007 | WHEN platform adapters or generated skills mention `/agtoosa-update` THE SYSTEM SHALL describe the same Detect → Plan → Apply → Verify contract and SHALL NOT describe the default workflow as pure read-only | Must |
| AC-008 | WHEN preflight detects dirty git state, malformed AgToosa markers, existing backup files, missing `Docs/`, lock-file issues, platform drift, or major-version migration risk THE SYSTEM SHALL surface the risk before Apply and recommend `--dry-run` or manual review as appropriate | Should |
| AC-009 | WHEN major-version drift or known breaking changes are detected THE SYSTEM SHALL surface migration guidance from changelog/installed version context before Apply | Should |

### 1.4 Out of Scope

- Changing the existing preservation list for user-owned files
- Rewriting `lib/update.sh` copy/merge semantics unless needed for verification output
- Adding network dependency checks to the generated project workflow
- Auto-approving update plans
- Updating global Codex prompt discovery behavior

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `template/Docs/AgToosa_Update.md` | Redefine the canonical workflow as Detect → Plan → Apply → Verify; add sub-command behavior for `check`, `plan`, `apply`, and `verify`; preserve `check` as read-only |
| Platform adapters under `template/` | Update native command/rule/prompt/workflow/skill wording so all surfaces route to the canonical update workflow and describe ask-then-apply accurately |
| `tests/agtoosa.bats` | Add DEV-027 assertions for canonical workflow wording, adapter parity, preflight/migration wording, and `--update` preservation/verification expectations |
| `lib/update.sh` / `agtoosa.sh` | Change only if build discovers the CLI lacks evidence needed for verification; otherwise keep CLI mutation behavior as-is |
| `docs/AgToosa_TestPlan-DEV-027.md` | Map ACs to focused tests |
| `docs/Master-Plan.md` | Enroll DEV-027 as the active approved story |

Canonical workflow stages:

1. **Detect:** Read installed project state, installed AgToosa version, lock file if present, platform sentinels, project context, Master-Plan, active specs, changelog, and architecture memory.
2. **Plan:** Determine drift and planned actions; include workflow docs, platform entry points, native dirs, lock/version metadata, preserved files, backups, and risks.
3. **Apply:** Ask for explicit approval; after approval, run the real CLI update command for the target project.
4. **Verify:** Confirm version marker, lock metadata when present, platform surfaces, preserved user files, and single AgToosa marker block behavior.

Sub-command behavior:

- `check`: Detect only plus project briefing; no shell commands or mutation.
- `plan`: Detect + Plan; no mutation.
- `apply`: Detect + Plan + approval + Apply + Verify.
- `verify`: Verify an already-updated project; no Apply.

### 2.2 Data Flow

1. User invokes `/agtoosa-update` in a generated project.
2. The platform adapter routes the invocation to `Docs/AgToosa_Update.md`.
3. The workflow detects project state and determines whether the installed baseline is behind.
4. The workflow produces an update plan and risk preflight.
5. If mutation is needed, the workflow asks for explicit approval.
6. After approval, the agent runs `bash agtoosa.sh --update <project>` or the repo-appropriate equivalent documented by the local install.
7. The workflow verifies the update and reports concise evidence plus any unresolved risks.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent silently mutates project files during default update | Elevation of Privilege | AC-003 approval gate before Apply |
| Adapter says read-only while skill performs mutation | Repudiation | AC-007 adapter parity assertions |
| Agent performs a handcrafted update instead of the CLI update | Tampering | AC-002 and AC-004 require `agtoosa.sh --update` as source of truth |
| Dirty worktree or malformed markers cause surprising overwrite/merge behavior | Tampering | AC-008 preflight risk report before Apply |
| Major-version drift hides breaking workflow changes | Denial of Service | AC-009 migration guidance before Apply |
| Verification prints sensitive project context | Information Disclosure | Verification reports filenames/status only; no secret or config value dumping |

### 2.4 Build Scope

Files in scope: `template/Docs/AgToosa_Update.md`, `/agtoosa-update` platform adapters under `template/`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-027.md`, `docs/AgToosa_TestPlan-DEV-027.md`, `docs/Master-Plan.md`

Directories in scope: `template/.claude/`, `template/.cursor/`, `template/.gemini/`, `template/.github/`, `template/.windsurf/`, `template/.codex/`, `template/Docs/`, `tests/`, `docs/`

Out of scope: generated `ship/`, unrelated workflow docs, release/version bump files, registry download semantics, and platform discovery claims not specific to `/agtoosa-update`

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Canonical workflow contract
  - [x] 1.1 Rewrite `template/Docs/AgToosa_Update.md` around Detect → Plan → Apply → Verify — _Requirements: AC-001, AC-002, AC-003, AC-004_
  - [x] 1.2 Define `check`, `plan`, `apply`, and `verify` sub-command behavior and stop conditions — _Requirements: AC-005, AC-006_
  - [x] 1.3 Add preflight risk and major-version migration guidance wording — _Requirements: AC-008, AC-009_
- [x] **2.** Platform adapter parity
  - [x] 2.1 Update Claude, Cursor, Gemini, Copilot, Windsurf, and Codex/OpenCode update adapters to route to the canonical contract — _Requirements: AC-001, AC-007_
  - [x] 2.2 Fix descriptions that currently imply `/agtoosa-update` is only read-only or directly syncs files without approval — _Requirements: AC-003, AC-007_
- [x] **3.** Verification contract
  - [x] 3.1 Document post-Apply verification evidence for version marker, lock metadata, platform surfaces, preserved files, and duplicate marker safety — _Requirements: AC-004_
  - [x] 3.2 Keep CLI mutation delegated to `agtoosa.sh --update`; only add runtime evidence if required by tests — _Requirements: AC-002, AC-004_
- [x] **4.** Regression coverage
  - [x] 4.1 Add bats assertions for canonical Detect → Plan → Apply → Verify wording and sub-command behavior — _Requirements: AC-001, AC-005, AC-006_
  - [x] 4.2 Add adapter parity assertions across all native update surfaces — _Requirements: AC-007_
  - [x] 4.3 Add focused coverage for preflight/migration wording and existing `--update` preservation/duplicate marker behavior — _Requirements: AC-004, AC-008, AC-009_
- [x] **5.** Validation and bookkeeping
  - [x] 5.1 Run DEV-027 focused bats filter and relevant existing `--update` tests — _Requirements: AC-001, AC-004, AC-007_
  - [x] 5.2 Update `docs/AgToosa_TestPlan-DEV-027.md` evidence with actual test names — _Requirements: AC-004_
  - [x] 5.3 Update `docs/Master-Plan.md` task progress during build — _Requirements: AC-001_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 3.1, 3.2  
**Wave 3 (sequential after Wave 2):** 4.1, 4.2, 4.3  
**Wave 4 (sequential after Wave 3):** 5.1, 5.2, 5.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-027.md`

AC coverage: 9 ACs mapped to 9 test IDs

Smoke set: 7 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-05-24 15:11
