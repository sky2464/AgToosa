# Spec: DEV-134 — README Hero Media Pass (Catch-up Formalization)

> **Story ID:** DEV-134  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.48  
> **Estimate:** XS  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-127 (README experience refresh)  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.48  
> **Note:** Catch-up formalization for hero media landed in `7bac032` (WorkflowSummaryScene, captions, slower loop).

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Formalize README hero media catch-up with verifier evidence and bats |
| User outcome | README inline GIF reflects slower workflow loop, captions, and full-workflow summary scene |
| Success condition | `verify:checkpoint` green; MED-001–004 bats green; ship v5.3.48 |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-134.md`; bats `MED-001–004` |
| Non-goals | Licensed master render; replacing published GIF without review |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `npm run verify:checkpoint` runs THE SYSTEM SHALL pass source, timeline, and candidate contracts |
| AC-002 | Must | WHEN ReadmeLoop renders THE SYSTEM SHALL include WorkflowSummaryScene with captioned workflow rail |
| AC-003 | Must | WHEN README is viewed THE SYSTEM SHALL reference published `agtoosa-hero.gif` assets |
| AC-004 | Must | WHEN DEV-134 ships THE SYSTEM SHALL pass bats MED-001–004 and version v5.3.48 |

### 2.3 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| Tampering (stale published GIF) | `verify:checkpoint` + MED bats gate source and asset contracts |
| Spoofing (invented verifier output) | Verifier terminal uses authentic run summary only |

### 2.4 Build Scope

- `docs/media/agtoosa-hero/**`
- `tests/agtoosa.bats` (MED section)
- `docs/AgToosa_TestPlan-DEV-134.md`
- `docs/archived/spec-DEV-134.md`
- `docs/Master-Plan.md` (tracking only)

## 3. Tasks

- [x] **1.** Re-run `npm run verify:checkpoint` and record evidence — _AC-001_
- [x] **2.** Add bats MED-001–004 — _AC-002, AC-003, AC-004_
- [x] **3.** Ship v5.3.48 — changelog + version parity — _AC-004_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-134.md`.

---

## ✅ Spec Approved

Approved: 2026-07-28 — ready for `/agtoosa-build`.
