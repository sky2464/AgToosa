# Spec: DEV-127 — Docs: README Experience Refresh

> **Story ID:** DEV-127  
> **Epic:** DEV-002 — Workflow Templates  
> **Type:** Docs  
> **Status:** 🏁 Shipped (v5.3.33)  
> **Estimate:** M  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Depends on:** DEV-086 (proof journey) · DEV-073 (README consolidation)  
> **Spec created:** 2026-07-26  
> **Extends:** REV4-M-3 (proof video slot — manual capture deferred)

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal | Short, motion-first README; depth in `docs/guides/readme-reference.md` and wiki |
| Proof CTA | DEV-086 markers preserved above first `---` |
| Bats | 25+ README greps; competitor/wave sections migrate with test updates |
| Motion | Hybrid: Remotion source + rendered GIF/WebP + animated SVG accent + REV4-M-3 video slot |
| Version pins | README quick install uses `AGTOOSA_VERSION` (`v5.3.33`) |
| Template pack | Maintainer README only — no `template/` mirror required |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Hero motion delivery? | **Hybrid** — Remotion loop + SVG accent + poster + linked proof video |
| Q2 | Tone? | **Polished product-studio with playful energy** — confident, not meme-heavy |
| Q3 | Line budget? | **~180 lines** excluding product-truth block |
| Q4 | Block on REV4-M-3 video? | **No** — ship README with video placeholder link; manual capture deferred |

#### Documented assumptions

- GitHub README displays animated GIF reliably; WebP is secondary export.
- `docs/enforcement-comparison.md` link stays in short README (existing bats).
- Competitive comparison prose moves to readme-reference; bats grep targets updated.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | First-time visitors understand AgToosa and start the proof journey in under 5 minutes with a memorable visual hook |
| User outcome | Developer sees motion, reads a tight story, runs one install path, drills into depth only when needed |
| Success condition | README ≤ ~180 lines (excl. product-truth); PRF-* green; RMH-* green; hero assets from checked-in Remotion source |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-127.md`; bats `RMH-*`; `scripts/check-launch-readiness.sh --mode private` |
| Non-goals | Marketing site; generator behavior changes; wiki-sync automation rewrite |
| Assumptions | Existing proof-journey manifest unchanged; deep-dive is canonical relocation not duplication |
| Risks | Binary asset size; bats drift; motion mistaken for product runtime |
| Unresolved questions | None |

### 1.1 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN README is read THE SYSTEM SHALL present a motion hero asset, a ≤180-line body (excl. product-truth), and preserved DEV-086 above-fold proof CTA | Must |
| AC-002 | WHEN depth content is needed THE SYSTEM SHALL link to `docs/guides/readme-reference.md` and `docs/guides/architecture-overview.md` as canonical deep dives | Must |
| AC-003 | WHEN hero assets are maintained THE SYSTEM SHALL ship Remotion source under `docs/media/agtoosa-hero/` plus rendered GIF/PNG and animated SVG accent | Must |
| AC-004 | WHEN README contract bats run THE SYSTEM SHALL pass PRF-001–009 and updated RMH-* checks | Must |
| AC-005 | WHEN competitor and competitive-wave copy is relocated THE SYSTEM SHALL keep prose in readme-reference and update DEV-037/DEV-042 bats grep targets | Must |
| AC-006 | WHEN wiki home is read THE SYSTEM SHALL index new guides without stale Linear PM claims | Should |
| AC-007 | WHEN REV4-M-3 video is unavailable THE SYSTEM SHALL link to first-15 walkthrough and reserve a video URL slot in Read more | Should |

### 1.2 Out of Scope

- `template/` README mirror
- `AGTOOSA_VERSION` bump (ship phase)
- Recording REV4-M-3 terminal video (manual deferred)

## 2. Design

### 2.1 Surfaces

| Surface | Action |
|---------|--------|
| `README.md` | Rewrite — short story + read-more hub |
| `docs/guides/readme-reference.md` | New — relocated install, commands, security, comparison |
| `docs/guides/architecture-overview.md` | New — full lifecycle mermaid |
| `docs/media/agtoosa-hero/` | New — Remotion + exports |
| `.wiki/Home.md` | Refresh index |
| `tests/agtoosa.bats` | RMH-* + migrated greps |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Write spec + test plan + Master-Plan enrollment — _AC-001_
- [x] **2.** Create readme-reference + architecture-overview — _AC-002_
- [x] **3.** Rewrite README + motion assets — _AC-001, AC-003_
- [x] **4.** Bats migration + launch checker — _AC-004, AC-005_
- [x] **5.** Wiki refresh — _AC-006_

## ✅ Spec Approved

Approved for build per user instruction to implement DEV-127 plan (2026-07-26).
