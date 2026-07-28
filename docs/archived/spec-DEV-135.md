# Spec: DEV-135 — Natural-Language Continuation → `/agtoosa-next`

> **Story ID:** DEV-135  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.49  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-125 (`/agtoosa-next`) · DEV-131 (Sequential Approval) · DEV-116 (Lifecycle Compass)  
> **ADR:** `docs/adr/ADR-019-agtoosa-next-dispatcher.md` (amend)  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.49  
> **Note:** Renumbered from mistaken DEV-134 ID when user cold-start pick (3) enrolled README hero as DEV-134.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | DEV-116 Compass + DEV-125/131 Next partially cover sequential intent; agents still chain raw phase slashes or misread `"okay"` / `"do it"` |
| Narrowest scope | Doc + adapter hardening: `PROGRESS` semantic class, Continuation Context Contract, blocked-state routing — no shell NLP runtime |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Context for `"do it"` / `"okay"` | Context-aware — interview pending → answer; post-closure → `/agtoosa-next` |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Natural continuation utterances reliably dispatch `/agtoosa-next` with context-aware disambiguation |
| Success condition | NLX-001–008 bats green; template + maintainer mirrors aligned; ADR-019 amended |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-135.md`; bats `NLX-001–008` |
| Non-goals | Shell NLP runtime; auto-chaining phases; overriding 🔴 Critical blockers |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN user utters PROGRESS-class continuation without `/agtoosa-*` THE SYSTEM SHALL route to `/agtoosa-next` not a raw phase slash |
| AC-002 | Must | WHEN a Plan-Mode Spec Interview question is pending THE SYSTEM SHALL NOT dispatch `/agtoosa-next` |
| AC-003 | Must | WHEN agent printed `Next: /agtoosa-next` or a phase approval gate THE SYSTEM SHALL treat continuation as `/agtoosa-next` |
| AC-004 | Must | WHEN `/agtoosa-next` runs with review BLOCKED THE SYSTEM SHALL route fix/review tributary — not ship |
| AC-005 | Must | WHEN `agtoosa-core.mdc` and `agtoosa-maintainer-core.mdc` are compared THE SYSTEM SHALL both document Continuation Context Contract |
| AC-006 | Must | WHEN DEV-135 ships THE SYSTEM SHALL pass bats NLX-001–008 |
| AC-007 | Should | WHEN Standing Correction lesson confirmed during fix tributary THE SYSTEM SHALL append dated row to `docs/Context/workflow.md` |

## 3. Tasks

- [x] **1.** Add PROGRESS + Continuation Context Contract to `AgToosa_Agent.md` (docs + template) — _AC-001–003_
- [x] **2.** Extend `AgToosa_Next.md` blocked routing + Relationship section (docs + template) — _AC-004_
- [x] **3.** Align `agtoosa-core.mdc` and `agtoosa-maintainer-core.mdc` — _AC-005_
- [x] **4.** Update `agtoosa-next` skill + platform adapters; amend ADR-019 — _AC-005, AC-006_
- [x] **5.** Add bats NLX-001–008 — _AC-006_
- [x] **6.** Ship v5.3.49 — changelog + version parity — _AC-006_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-135.md`.

---

## ✅ Spec Approved

Approved 2026-07-28. Build complete (parked). When ready: enroll Active Cycle and `/agtoosa-review` as DEV-135.
