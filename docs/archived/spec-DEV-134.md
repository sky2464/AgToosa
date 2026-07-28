# Spec: DEV-134 — Natural-Language Continuation → `/agtoosa-next`

> **Story ID:** DEV-134  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🟨 In Progress — build complete  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-125 (`/agtoosa-next`) · DEV-131 (Sequential Approval) · DEV-116 (Lifecycle Compass)  
> **ADR:** `docs/adr/ADR-019-agtoosa-next-dispatcher.md` (amended)  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.48

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | DEV-116 Compass + DEV-125/131 Next partially cover sequential intent; only `"next"`, `"continue"`, `"what's next"` documented; agents still chain raw phase slashes or misread `"okay"` / `"do it"` |
| Status quo | `template/.cursor/rules/agtoosa-core.mdc` has one-line sequential freeform hint; `.cursor/rules/agtoosa-maintainer-core.mdc` lacks parity |
| Narrowest scope | Doc + adapter hardening: `PROGRESS` semantic class, Continuation Context Contract, blocked-state routing in `AgToosa_Next.md`, NLX bats — no shell NLP runtime |
| Non-goals | `/agtoosa-compass` slash command; auto-chaining phases; overriding 🔴 Critical review or Part 0 ship blockers |
| Failure modes | Misrouting interview answers as `/agtoosa-next`; treating `"continue"` as raw `/agtoosa-build` or `/agtoosa-ship` without SYNC pulse |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Where should DEV-134 land relative to DEV-133? | **DEV-134 after DEV-133 ships** — enroll backlog; activate on idle cycle |
| Q2 | When user says `"do it"` / `"okay"` during spec interview vs after closure? | **Context-aware** — pending interview Q → answer/momentum opt-in; post-closure or approval gate → `/agtoosa-next` |

#### Documented assumptions

- Semantic detection only (illustrative utterance list, not phrase-table lookup) per DEV-116 Compass principles.
- Standing Corrections append on fix tributary is **Should** (AC-007), not blocking ship.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Natural continuation utterances reliably dispatch `/agtoosa-next` with context-aware disambiguation |
| User outcome | User says "next", "continue", "okay", "do it", "go ahead", "sounds good", "yes", "proceed" and gets SYNC-driven smart routing — not raw phase slashes or blind phase-chaining |
| Success condition | NLX-001–008 bats green; template + maintainer mirrors aligned; ADR-019 amended |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-134.md`; bats `NLX-001–008` |
| Non-goals | Shell NLP runtime; `/agtoosa-compass` command; auto-chaining Spec→Build→Review→Ship; overriding review/ship blockers |
| Assumptions | DEV-125 dispatcher and DEV-131 Sequential Approval remain authoritative |
| Risks | Interview momentum opt-in conflated with lifecycle advance — mitigated by Continuation Context Contract priority table |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN user utters PROGRESS-class continuation without `/agtoosa-*` THE SYSTEM SHALL route to `/agtoosa-next` not a raw phase slash |
| AC-002 | Must | WHEN a Plan-Mode Spec Interview question is pending THE SYSTEM SHALL NOT dispatch `/agtoosa-next` for continuation utterances |
| AC-003 | Must | WHEN agent printed `Next: /agtoosa-next` or a phase approval gate THE SYSTEM SHALL treat continuation as `/agtoosa-next` dispatch (Sequential Approval when served) |
| AC-004 | Must | WHEN `/agtoosa-next` runs with review BLOCKED THE SYSTEM SHALL route fix/review tributary and update Master-Plan — not ship |
| AC-005 | Must | WHEN `agtoosa-core.mdc` and `agtoosa-maintainer-core.mdc` are compared THE SYSTEM SHALL both document Continuation Context Contract |
| AC-006 | Must | WHEN DEV-134 ships THE SYSTEM SHALL pass bats NLX-001–008 |
| AC-007 | Should | WHEN Standing Correction lesson confirmed during fix tributary THE SYSTEM SHALL append dated row to `docs/Context/workflow.md` |

### 1.3 Scope Boundary

**In scope:** `AgToosa_Agent.md`, `AgToosa_Next.md`, `agtoosa-core.mdc`, `agtoosa-maintainer-core.mdc`, `agtoosa-next` skill + platform adapters, ADR-019, `tests/agtoosa.bats` (NLX-001–008).

**Out of scope:** Generator CLI flags; runtime orchestrator; changing Sequential Approval or Phase Stop contracts.

## 2. Design

See §2.1–2.5 in archived draft; implemented per Continuation Context Contract and Step 1b blocked routing.

## 3. Tasks

- [x] **1.** Add PROGRESS + Continuation Context Contract to `AgToosa_Agent.md` (docs + template) — _AC-001, AC-002, AC-003_
- [x] **2.** Extend `AgToosa_Next.md` blocked routing + Relationship section (docs + template) — _AC-004_
- [x] **3.** Align `agtoosa-core.mdc` and `agtoosa-maintainer-core.mdc` — _AC-005_
- [x] **4.** Update `agtoosa-next` skill + platform adapters; amend ADR-019 — _AC-005, AC-006_
- [x] **5.** Add bats NLX-001–008 — _AC-006, AC-007_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-134.md`.

---

## ✅ Spec Approved

Approved: 2026-07-28 — ready for `/agtoosa-build`.
