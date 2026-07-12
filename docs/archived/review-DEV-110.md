# Review: DEV-110 — AgToosa Project Intake

> **Story:** DEV-110  
> **Date:** 2026-07-12  
> **Verdict:** ✅ PASS  
> **Suggested release:** PATCH **5.3.21 → 5.3.22** (ADR-005 patch-first)

## Summary

Dual-mode **AgToosa Project Intake** for freeform asks: always-on `agtoosa-core.mdc`, Project Intake Protocol in Agent.md (template + maintainer mirrors), Standing Corrections in `workflow.md`, entry pointers in CLAUDE/AGENTS/Quickref; ADR-013 Accepted; INT-001–INT-012 bats green. Goal Contract satisfied within agent-instructed Claim Boundary — no runtime orchestrator shipped.

| Persona | 🔴 Critical | 🟡 Warning | 🟢 Passed |
|---------|-------------|------------|-----------|
| Security Officer | 0 | 0 | 6 |
| Engineering Manager | 0 | 2 | 7 |
| CEO / Product Owner | 0 | 0 | 8 |
| QA Lead | 0 | 2 | 7 |
| **Unresolved Critical** | **0** | — | — |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Standard (docs + always-on rules; STRIDE mitigations documented; no auth/registry/secrets Must ACs) |
| Reviewer identity | — |
| Model/platform | — |
| Outcome | skipped |
| Skip rationale | Standard tier — virtual personas + INT contract bats + verifier PASS sufficient. Cross-model optional per `docs/AgToosa_CrossModelReview.md`. |

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟡 | EM | `alwaysApply: true` on core rule increases prompt surface on every Cursor turn | **Accepted** — intentional per ADR-013 and interview decision; Claim Boundary agent-instructed |
| 🟡 | EM | `agtoosa.sh` / `agtoosa.ps1` exceed 500-line guidance | **Accepted** — pre-existing; DEV-110 touched docs/rules only |
| 🟡 | QA | Verifier WARN `G3-ears-DEV-110`: failure-modes table rows lack EARS keywords | **Accepted** — Must AC table uses WHEN/SHALL; same pattern as DEV-109 |
| 🟡 | QA | Verifier WARN `G3-no-wave-DEV-110`: spec has `### 3.2 Wave Plan` not `### Wave Plan` heading | **Accepted** — wave plan present; verifier heading heuristic false positive |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Pass — freeform asks classified; soft expedite + hard gate; Standing Corrections persist lessons |
| User outcome | 🟢 Pass — mid-work prompts handled without untracked AI drift |
| Success condition | 🟢 Pass — always-on core + Agent contract + INT bats + Phase Stop preserved |
| Proof / evidence | 🟢 Pass — `docs/AgToosa_TestPlan-DEV-110.md` RED/GREEN; INT 12/12 |
| Non-goals | 🟢 Pass — no runtime engine; no new slash intake command; Discovery Triage unchanged |

## Terminal Evidence — QA

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-110"` |
| Exit code | 0 |
| Pass/fail | PASS — 12/12 (INT-001–INT-012) |
| Verifier | `bash docs/agtoosa-verify.sh` → PASS (10 pass · 3 warn · 0 fail) |
| Changed files | `docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Agent.md`, `template/.cursor/rules/agtoosa-core.mdc`, `template/Docs/Context/workflow.md`, `docs/Context/workflow.md`, `template/CLAUDE.md`, `template/AGENTS.md`, `docs/AgToosa_Quickref.md`, `template/Docs/AgToosa_Quickref.md`, `docs/adr/ADR-013-project-intake.md`, `tests/agtoosa.bats` |
| Next | `/agtoosa-ship` PATCH 5.3.22 |

## Security Officer — STRIDE / OWASP

| Check | Result |
|-------|--------|
| Spoofed soft classification skipping Spec | 🟢 Hard-gate trigger list + no product code until confirm |
| Tampering Standing Corrections | 🟢 Dated table; review-time check; bats INT-005 |
| Untracked freeform fixes (repudiation) | 🟢 Tiered logging documented; hard path records after confirm |
| Secrets in Standing Corrections | 🟢 Agent instructs intent-only; no credential storage |
| Hard-gate on every typo (DoS) | 🟢 Soft path for Claim-Boundary-small |
| Soft path privilege elevation | 🟢 Security/trust always hard-gates |

## Engineering Manager — Architecture

| Check | Result |
|-------|--------|
| 500-line limit | 🟡 Entrypoints pre-existing over limit; changed docs/rules under limit |
| ADR coverage | 🟢 ADR-013 Accepted at build |
| Domain language | 🟢 CONTEXT.md: Project Intake, Standing Corrections |
| Template parity | 🟢 `docs/` + `template/` mirrors aligned for Agent, workflow, core, Quickref |
| Discovery Triage boundary | 🟢 Mid-build triage unchanged; intake covers cold freeform only |

## CEO / Product Owner — Goal Contract

| AC band | Result |
|---------|--------|
| AC-001–AC-008 Must (intake behavior) | 🟢 Documented in Agent + core rule |
| AC-009 Claim Boundary | 🟢 agent-instructed / CI-enforced labels present |
| AC-010 enrollment | 🟢 Backlog after DEV-109; expedite note in Master-Plan |
| AC-011–AC-012 tests/evidence | 🟢 INT bats + test plan GREEN |
| AC-013 Should (dual-mode Spec-First) | 🟢 core.mdc Spec-First (dual-mode) |
| AC-014 Could (help pointer) | 🟢 Quickref bullet; help adapters optional |

## QA Lead — Coverage

| Check | Result |
|-------|--------|
| INT bats | 🟢 12/12 pass |
| Must AC → test mapping | 🟢 All Must ACs mapped in test plan |
| RED/GREEN evidence | 🟢 Recorded in test plan |
| Coverage threshold | 🟢 N/A — docs contract tests; workflow.md threshold 100% not applicable to grep bats |
| Regression | 🟢 N/A — feature story |
