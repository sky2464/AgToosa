# Review: DEV-031 — Project-Specific Specialist Subagents

> **Story ID:** DEV-031
> **Spec:** `docs/archived/spec-DEV-031.md`
> **Reviewed:** 2026-05-25
> **Verdict:** PASS

## Summary

Documentation-and-bats story delivering cross-platform v1 **project specialist** contract (`AgToosa_Specialists.md`), init/update/spec orchestration, Codex skill routing, and 15 grep/integration tests. No generator runtime code beyond `lib/config.sh` inventory. All DEV-031 bats pass; DEV-008 K4 regression pass.

## Persona Findings

| ID | Persona | Severity | Finding | Action |
|----|---------|----------|---------|--------|
| R-001 | Security Officer | 🟢 Passed | STRIDE mitigations from spec reflected in docs: approval gates, `agtoosa-*` guard, secret redaction, CLI non-overwrite of roster/native files. No new executable attack surface. | — |
| R-002 | Engineering Manager | 🟢 Passed | ADR-010 documents decision. Canonical doc is 124 lines; workflow edits are modular. Template `docs/` mirrors present for Specialists, Init, Spec, Update, Agent, Skills. Phase E/F split preserves DEV-008 skill discovery (K4). | — |
| R-003 | Engineering Manager | 🟡 Warning | AC-014 parity enforced on **Codex skills** only (T-014). Claude/Cursor/Gemini command adapters still route via `AgToosa_Init.md` / `AgToosa_Spec.md` without explicit `AgToosa_Specialists.md` pointer. Acceptable per spec task 6.1 conditional; add thin pointers in a follow-up if dogfood shows adapter drift. | Optional follow-up |
| R-004 | CEO / Product Owner | 🟢 Passed | All 15 Must ACs have mapped bats (T-001–T-015). Goal contract met: no default roster, approval-gated materialization, spec orchestration with parallel/sequential fallback. Non-goals respected (no build/qa/review hooks, no CLI flags). | — |
| R-005 | QA Lead | 🟢 Passed | `bats -f "DEV-031"`: 15/15. `bats -f "K4"`: pass (Project Skill Discovery retained in Phase F). | — |
| R-006 | QA Lead | 🟡 Warning | Full suite: 343/344 — one **pre-existing** failure `self-targeting interactive install includes maintainer guidance` (DEV-030 `agtoosa.sh` install path). Not introduced by DEV-031; does not block DEV-031 ship. | Fix in DEV-030 |
| R-007 | QA Lead | 🟡 Warning | Key DEV-031 artifacts are **untracked** in git (`template/Docs/AgToosa_Specialists.md`, `docs/archived/spec-DEV-031.md`, `docs/AgToosa_TestPlan-DEV-031.md`, `docs/adr/ADR-010-project-specific-specialists.md`, `docs/archived/review-DEV-031.md`). Commit before `/agtoosa-ship`. | Ship hygiene |

## AC Coverage (QA)

| AC | Test ID | Status |
|----|---------|--------|
| AC-001 | T-001 | 🟢 |
| AC-002 | T-002 | 🟢 |
| AC-003 | T-003 | 🟢 |
| AC-004 | T-004 | 🟢 |
| AC-005 | T-005 | 🟢 |
| AC-006 | T-006 | 🟢 |
| AC-007 | T-007 | 🟢 |
| AC-008 | T-008 | 🟢 |
| AC-009 | T-009 | 🟢 |
| AC-010 | T-010 | 🟢 |
| AC-011 | T-011 | 🟢 |
| AC-012 | T-012 | 🟢 |
| AC-013 | T-013 | 🟢 |
| AC-014 | T-014 | 🟢 |
| AC-015 | T-015 | 🟢 |

## Simplification (Part 2)

No code refactors required. Specialist vs skill glossary in `AgToosa_Specialists.md` reduces future duplication — adequate for v1.

## Verdict

| Metric | Count |
|--------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 2 |
| 🟢 Passed | 5 |

**Ship version suggestion (maintainer dogfood):** PATCH+1 on current MINOR (e.g. `5.2.x` → `5.2.(n+1)`) — Feature story with workflow-doc-only blast radius; no breaking generator API.

## Review ✅ Passed

Review complete. No 🔴 Critical findings. Warnings R-003 (optional adapter pointers), R-006 (DEV-030 test), R-007 (untracked files at commit time) do not block DEV-031.

Shipped: **v5.2.3** (2026-05-25). `/agtoosa-ship` complete — version pins, CHANGELOG, Master-Plan Completed This Cycle.
