# Spec: DEV-136 — IDE Host Mode Bridge (Catch-up Formalization)

> **Story ID:** DEV-136  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.50  
> **Estimate:** M  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-028 (Plan-Mode Spec Interview) · DEV-116 (Lifecycle Compass — amend plan-mode prohibition)  
> **ADR:** `docs/adr/ADR-020-ide-host-mode-bridge.md`  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.50  
> **Note:** Catch-up formalization for IDE host mode bridge landed in `4882506` before lifecycle enrollment.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Bridge `/agtoosa-spec` and `/agtoosa-review` planning windows to native IDE plan mode; auto-switch to Agent/Auto for artifact writes |
| Platform scope | All declared platforms day one (Cursor, Codex, Copilot, Claude, Windsurf, Gemini) — not Cursor-first |
| Review depth | Full plan-mode power for review briefing — not read-only gating |
| Non-goals | No `agtoosa.sh` mode API; no auto-switch during build/ship; no mid-interview auto-switch |

#### Confirmed (prior session)

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Platform scope | All platforms day one |
| Q2 | Review depth | Full plan-mode power |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Map spec/review planning windows to native IDE plan mode with auditable HOST-MODE handoff to Agent/Auto for artifact writes |
| User outcome | Agents use host plan mode for interviews and review synthesis; AgToosa artifacts written only after auto-switch trigger |
| Success condition | IDE-001–012 bats green; product-truth `host_mode_policy`; Compass supersedes "Do not use Cursor native Plan mode" |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-136.md`; bats `IDE-001–012`; ADR-020 |
| Non-goals | Runtime mode switcher in `agtoosa.sh`; auto-switch on PROGRESS utterances; build/ship plan-mode bridge |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `/agtoosa-spec` runs THE SYSTEM SHALL require native IDE plan mode before Plan-Mode Spec Interview |
| AC-002 | Must | WHEN plan-mode interview is active THE SYSTEM SHALL NOT write spec artifacts or auto-switch mid-interview |
| AC-003 | Must | WHEN decision-complete and validation floor met THE SYSTEM SHALL print `HOST-MODE: plan complete → switching to agent for AgToosa artifacts` before first artifact write |
| AC-004 | Must | WHEN `/agtoosa-review` runs THE SYSTEM SHALL use plan mode for persona synthesis and Iron Law hypotheses |
| AC-005 | Must | WHEN review briefing is complete THE SYSTEM SHALL switch to Agent/Auto before writing `review-*.md` |
| AC-006 | Must | WHEN Compass or core rules reference plan mode THE SYSTEM SHALL prefer native IDE plan mode for spec/review (supersede DEV-116 block rule) |
| AC-007 | Must | WHEN any declared spec/review adapter renders THE SYSTEM SHALL include Host Mode Execution block |
| AC-008 | Must | WHEN DEV-136 ships THE SYSTEM SHALL pass bats IDE-001–012 and ship v5.3.50 |

### 2.3 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| Tampering (artifacts written in plan mode) | Contract forbids writes before HOST-MODE handoff; IDE-012 bats |
| Spoofing (false handoff line) | Auditable `HOST-MODE:` line required in contract; agent-instructed enforcement |

### 2.4 Build Scope

- `docs/adr/ADR-020-ide-host-mode-bridge.md`
- `docs/AgToosa_Agent.md`, `AgToosa_Spec.md`, `AgToosa_Review.md`, `AgToosa_AgentCapability.md` (+ template mirrors)
- `contracts/product-truth-v1.json` + schema + `scripts/product_truth_core.py`
- Platform adapters (spec/review): Cursor, Codex, Copilot, Claude, Windsurf, Gemini
- `template/.cursor/rules/agtoosa-core.mdc`, `.cursor/rules/agtoosa-maintainer-core.mdc`
- `tests/agtoosa.bats` (IDE-001–012); NLM-001 update
- `docs/AgToosa_TestPlan-DEV-136.md`

## 3. Tasks

- [x] **1.** ADR-020 + canonical IDE Host Mode Bridge sections — _AC-001, AC-004, AC-006_
- [x] **2.** Product-truth `host_mode_policy` + renderer — _AC-003, AC-007_
- [x] **3.** Platform adapter Host Mode Execution blocks — _AC-007_
- [x] **4.** Supersede Compass plan-mode block in core rules — _AC-006_
- [x] **5.** Bats IDE-001–012 + test plan — _AC-008_
- [x] **6.** Review + ship v5.3.50 — _AC-008_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-136.md`.

---

## ✅ Spec Approved

Approved 2026-07-28 — catch-up formalization; build complete in `4882506`; next `/agtoosa-review`.
