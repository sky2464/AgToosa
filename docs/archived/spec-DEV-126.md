# Spec: DEV-126 — Spec Interview Hardening

> **Story ID:** DEV-126  
> **Epic:** DEV-002 — Workflow Templates  
> **Status:** 🟨 In Progress — Build complete  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Spec created:** 2026-07-26  
> **Parent:** DEV-028 (Plan-Mode Spec Interview)

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal | Harden `/agtoosa-spec` so agents cannot skip Q&A when user prompts are detailed (DEV-125 regression) |
| Non-goals | Runtime enforcement engine; changing question budget caps (8/2) |
| Affected surfaces | `AgToosa_Spec.md`, `SPEC-FORMAT.md`, `AgToosa_Agent.md`, six platform adapters, bats |
| Test evidence | DEV-126 T-001–T-008 grep regressions |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Add interview hardening (floor, turn-stop, findings artifact, adapter parity) to canonical spec workflow? | User: "Yes, add them to next specs" (2026-07-26) |

#### Documented assumptions

- Maintainer implements in same session as spec approval — no separate build cycle required for doc-only generator changes.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Prevent `/agtoosa-spec` from skipping Plan-Mode Spec Interview when users provide detailed prompts |
| User outcome | Spec runs ask validation questions one at a time before writing spec files |
| Success condition | Canonical workflow + adapters + SPEC-FORMAT + bats DEV-126 T-001–T-008 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-126.md`; bats `DEV-126 T-*` |
| Non-goals | CI agent-behavior simulation; changing `/agtoosa-init` interview |
| Assumptions | Agent-instructed enforcement remains authoritative (DEV-028 model) |
| Risks | Agents may over-ask on trivial chores — mitigated by `/agtoosa-spec quick` |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN full `/agtoosa-spec` runs THE SYSTEM SHALL require minimum **2** validation questions before writing spec files unless user opts into documented assumptions |
| AC-002 | Must | WHEN `/agtoosa-spec quick` runs THE SYSTEM SHALL require minimum **1** validation question before writing the spec file |
| AC-003 | Must | WHEN research completes THE SYSTEM SHALL end the agent turn on the first interview question without writing spec artifacts in the same turn |
| AC-004 | Must | WHEN a spec file is generated THE SYSTEM SHALL include `### Plan-Mode Spec Interview (findings)` per `SPEC-FORMAT.md` |
| AC-005 | Must | WHEN canonical workflow is updated THE SYSTEM SHALL state that a detailed user prompt is input, not interview completion |
| AC-006 | Must | WHEN platform adapters install THE SYSTEM SHALL include Agent Mode Execution Contract forbidding interview skip and same-turn spec writes |
| AC-007 | Must | WHEN DEV-126 ships THE SYSTEM SHALL add bats DEV-126 T-001–T-008 for regression |

## 2. Design

### 2.1 Build Scope

- `template/Docs/AgToosa_Spec.md` + `docs/` mirror — interview hardening subsections
- `template/Docs/SPEC-FORMAT.md` + `docs/` mirror — findings section template
- `template/Docs/AgToosa_Agent.md` + `docs/` mirror — Smart Interview principles
- Platform adapters: Cursor, Claude, Windsurf, Gemini, Copilot, Codex prompt + skill
- `template/.cursor/rules/agtoosa-spec.mdc`, `template/.windsurf/rules/agtoosa-spec.md`
- Maintainer `.cursor/commands/agtoosa-spec.md`
- `tests/agtoosa.bats` DEV-126 section

## 3. Tasks

- [x] **1.** Canonical workflow hardening — _AC-001–AC-005_
- [x] **2.** SPEC-FORMAT findings section — _AC-004_
- [x] **3.** Adapter execution contracts — _AC-006_
- [x] **4.** Bats DEV-126 T-001–T-008 — _AC-007_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-126.md`.

---

## ✅ Spec Approved

Approved: 2026-07-26 for implementation (user-confirmed hardening scope).
