# Spec: DEV-146 — Docs: README First-Visit Simplification

> **Story ID:** DEV-146  
> **Epic:** DEV-002 — Workflow Templates  
> **Type:** Docs  
> **Status:** 🟦 Todo  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Depends on:** DEV-127 · DEV-134  
> **Spec created:** 2026-07-28  
> **Extends:** DEV-127 (README experience refresh)

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Parent | DEV-127 short README + readme-reference split; DEV-134 hero media shipped |
| Problem | Hero GIF and maintainer copy precede install; Windows buried in alternatives |
| Bats | PRF-001–009, RMH-001–006, R2, DEV-035/037/039/041/042 must remain green |
| Proof CTA | PRF-001 requires marker above first `---`; compact form in Essentials |
| Depth | Relocate `/agtoosa-next` essay and public-launch note to readme-reference |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Tagline under `# AgToosa`? | **A** — The repo-native AI project manager for spec-driven development |

#### Documented assumptions

- Auto-generated roadmap footer stays in README.
- REV4-M-3 proof video remains manual-deferred; first-15 link slot preserved.
- No Remotion re-render; existing hero assets reused.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | First-time visitors see tagline → Mac/Windows install → video/flowchart → compact essentials |
| User outcome | Understand what AgToosa is and install in under 2 minutes without scrolling past maintainer detail |
| Success condition | README ≤ 180 lines (excl. product-truth); PRF/RMH/R2/DEV bats green; RMF-001–003 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-146.md`; bats RMF-001–003 + regression |
| Non-goals | Hero Remotion re-render; REV4-M-3 video capture; template/ mirror |
| Risks | PRF above-fold contracts; line budget; duplicate install prose |

### 1.1 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN README is opened THE visitor SHALL see tagline, Mac/Linux + Windows install, then hero GIF + lifecycle flowchart before deep content | Must |
| AC-002 | WHEN README is read THE body SHALL remain ≤ 180 lines excluding product-truth block | Must |
| AC-003 | WHEN existing README contract bats run THE SYSTEM SHALL pass PRF-001–009, RMH-001–006, R2, DEV-035/037/039/041/042 greps | Must |
| AC-004 | WHEN depth is needed THE SYSTEM SHALL link to readme-reference without duplicating full install matrix in README | Must |
| AC-005 | WHEN verified THE SYSTEM SHALL pass RMF-001–003 bats for Windows block, tagline, and section order | Must |

### 1.2 Out of Scope

- `template/` README mirror
- Generator / bootstrap behavior changes
- REV4-M-3 terminal video recording

## 2. Design

### 2.1 Surfaces

| Surface | Action |
|---------|--------|
| `README.md` | Reorder: tagline → Quick install (Mac+Windows) → See it in action → Essentials → `---` → alternatives/footer |
| `docs/guides/readme-reference.md` | Absorb `/agtoosa-next` driver prose + public launch note |
| `tests/agtoosa.bats` | Add RMF-001–003 |
| `tests/fixtures/proof-journey/golden/readme-hero-snippet.md` | Sync if proof CTA prose changes |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Write spec + test plan + Master-Plan enrollment — _AC-001_
- [x] **2.** Rewrite README + relocate depth to readme-reference — _AC-001, AC-002, AC-004_
- [x] **3.** Add RMF bats + regression — _AC-003, AC-005_

## ✅ Spec Approved

Approved per user instruction to implement DEV-146 plan (2026-07-28).
