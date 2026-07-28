# Spec: DEV-138 — Main CI Health (Product Truth + PSScriptAnalyzer)

> **Story ID:** DEV-138  
> **Epic:** DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.53  
> **Estimate:** XS  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-118 (Product Truth) · DEV-033 (PSScriptAnalyzer) · DEV-135 (`/agtoosa-next` added 20th command)  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.52

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| PTC-002 failure | Inventory now `20 commands x 6 targets` after DEV-135 `/agtoosa-next`; bats still expect `19` |
| PSScriptAnalyzer failure | `Sanitize-PlatformMenuInput` at `agtoosa.ps1:630` — unapproved verb `Sanitize` |
| CI scope | `validate` + `Windows PowerShell Smoke Test` jobs red on `main` at `98b9f52` |
| Non-goals | No new commands; no security-scan changes (DEV-137 shipped) |

#### Confirmed (prior Next recommendation)

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Story pick | DEV-138 — main CI health (PTC-002 + PSScriptAnalyzer) |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Restore green `main` CI — Product Truth gate and Windows PSScriptAnalyzer smoke |
| User outcome | `ci.yml` validate + Windows jobs pass on current `main` |
| Success condition | PTC-002 green with `20 commands x 6 targets`; PSScriptAnalyzer PSUseApprovedVerbs exit 0 |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-138.md`; bats CIH-001–004; CI run URL |
| Non-goals | New lifecycle commands; security-scan workflow changes |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN product-truth inventory runs THE checker SHALL report `20 commands x 6 targets` and PTC-002 SHALL pass |
| AC-002 | Must | WHEN PSScriptAnalyzer runs on `agtoosa.ps1` THE PSUseApprovedVerbs rule SHALL exit 0 |
| AC-003 | Must | WHEN DEV-138 ships THE `ci.yml` validate job SHALL pass on `main` |
| AC-004 | Should | WHEN renaming PS1 helpers THE bats guard SHALL prevent unapproved-verb regression |

### 2.4 Build Scope

- `tests/product-truth.bats` — PTC-002 string update (`19` → `20`)
- `docs/AgToosa_TestPlan-DEV-118.md` — inventory baseline note (if referenced by bats/docs)
- `agtoosa.ps1` — rename `Sanitize-PlatformMenuInput` to approved verb (e.g. `ConvertTo-PlatformMenuInput`)
- `tests/agtoosa.bats` — CIH-001–004 regression guards

## 3. Tasks

- [x] **1.** Update PTC-002 and product-truth baseline docs for 20 commands — _AC-001_
- [x] **2.** Rename unapproved PS1 verb; update call site — _AC-002_
- [x] **3.** Add bats CIH-001–004 — _AC-004_
- [x] **4.** Verify CI green; review + ship v5.3.53 — _AC-003_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-138.md`.

---

## ✅ Spec Approved

Approved 2026-07-28 — served by `/agtoosa-next`; next `/agtoosa-build`.
