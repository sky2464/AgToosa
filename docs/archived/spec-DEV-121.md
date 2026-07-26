# Spec: DEV-121 — Spike: Behavioral Conformance Lab

> **Story ID:** DEV-121  
> **Epic:** DEV-003 — Community Template Registry · DEV-004 — Testing & QA Harness  
> **Type:** Spike  
> **Status:** 🔍 In Review — Approved · next `/agtoosa-ship`  
> **Estimate:** L  
> **Clarity:** `ready`  
> **Priority:** P0  
> **Depends on:** DEV-118 (Product Truth) · DEV-120 (Delivery Proof Fabric)  
> **Extends:** DEV-094 (Compatibility Contract) · DEV-096 (Pack Validation) · DEV-101 (Verified vs Community labeling)  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-021-behavioral-conformance-lab.md`  
> **Portfolio:** Competitive Proof Portfolio child — follows DEV-120; DEV-122–124 remain separate

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Reproducible scenario corpus + evidence format for assistant compatibility (DEV-094 Scenario tier) and registry-pack behavioral certification |
| Foundation | DEV-094 defines Install/Render/Scenario tiers — no platform is Scenario-tested yet; DEV-120 proof fabric supports optional `proof_graph_path` linkage |
| Portfolio role | First behavioral child after DEV-120; must not absorb DEV-122 drift, DEV-123 execution capsules, or DEV-124 interchange |
| Non-goals | Hosted lab/runtime; automatic remote probing; live assistant API calls in CI; absorbing DEV-060 competitor benchmark runs |
| Security surface | Local file reads + marker checks; network-free; path traversal blocked |
| Test evidence | BCL bats on golden fixtures with tamper cases; no live agent execution in default CI |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Narrowest spike scope? | **B** — contract + in-repo fixture + maintainer runbook + bats regressions |
| Q2 | Which scenario kinds in corpus? | **A + B + C** — lifecycle, pack install, render sweep (see R1) |
| Q3 | v1 delivery boundary? | **B** — runnable pilots + stub (see R1) |
| Q4 | Proof fabric binding? | **B** — scenario evidence composes with proof graphs (see R1 — separate verify CLIs) |
| Q5 | Verification model? | **B** — golden fixtures; bats assert schema, parity, verifier behavior |

#### Documented assumptions

- Amendment R1 supersedes Q2–Q4 delivery detail: one **universal** pilot scenario (`lifecycle-compass-proof`) × six platforms replaces three separate scenario kinds for v1 ship.
- Runner/verifier CLIs mirror DEV-120 standalone-script pattern instead of a new proof-graph provider in this spike.
- Pack behavioral hooks are documentation cross-links (DEV-096/DEV-101), not new CI network probes.

## Spec Revision Log

| R | Date | Change | Why | Approved |
|---|------|--------|-----|----------|
| R1 | 2026-07-26 | Replaced three-scenario / `behavioral-scenario` provider design with universal `lifecycle-compass-proof` × six platforms + `agtoosa-scenario-run.sh` / `agtoosa-scenario-verify.sh` | Simpler comparison across adapters; honest static verification; aligns with ADR-021 | AgToosa 2026-07-26 |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship Behavioral Conformance Lab v1 — versioned scenario corpus, maintainer runner, static verifier, universal pilot scenario across six adapter platforms, and golden fixtures |
| User outcome | Maintainers can run one fixed proof task per platform, record comparable `scenario-run.json` evidence, and cross-link pack/compatibility docs without implying hosted labs or live CI assistant runs |
| Success condition | Contract + schemas + `lifecycle-compass-proof` + runner/verifier scripts + six platform fixture trees + BCL-001–BCL-013 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-121.md`; bats `BCL-*`; `tests/fixtures/scenario-corpus/`; ADR-021 Accepted |
| Non-goals | Hosted lab; live assistant probing in CI; auto Scenario-tested promotion; DEV-060 absorption; DEV-122–124 scope |
| Assumptions | Static verifier is authoritative for CI; maintainer records live runs manually; proof-graph verify remains separate (`agtoosa-proof-verify.sh`) |
| Risks | Golden fixture drift; over-claiming Scenario-tested; confusion with DEV-120 provenance |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN BCL contract is documented THE SYSTEM SHALL define runner vs verifier roles, claim boundaries, and forbidden live-assistant CI claims |
| AC-002 | Must | WHEN corpus index is authored THE SYSTEM SHALL conform to `contracts/scenario-corpus-v1.schema.json` and list at least `lifecycle-compass-proof` |
| AC-003 | Must | WHEN scenario-run evidence is recorded THE SYSTEM SHALL conform to `contracts/scenario-run-v1.schema.json` with `scenario_id`, `platform`, `run_at`, `artifact_results[]`, `verifier_exit_code` |
| AC-004 | Must | WHEN `agtoosa-scenario-run.sh` runs THE SYSTEM SHALL print maintainer steps, invoke verifier, and write `scenario-run.json` to the artifact root |
| AC-005 | Must | WHEN `agtoosa-scenario-verify.sh` runs on valid fixtures THE SYSTEM SHALL exit 0; WHEN markers mismatch or artifacts are missing THE SYSTEM SHALL exit non-zero without network I/O |
| AC-006 | Must | WHEN tamper fixtures are verified THE SYSTEM SHALL fail with bounded diagnostics naming the first failure |
| AC-007 | Must | WHEN universal scenario ships THE SYSTEM SHALL include six platform fixture trees under `tests/fixtures/scenario-corpus/lifecycle-compass-proof/` |
| AC-008 | Must | WHEN registry trust docs are updated THE SYSTEM SHALL document pack behavioral scenario binding referencing DEV-096/DEV-101 boundaries |
| AC-009 | Must | WHEN compatibility contract is updated THE SYSTEM SHALL cross-link BCL corpus and forbid false Scenario-tested claims |
| AC-010 | Must | WHEN Evidence Provenance docs are updated THE SYSTEM SHALL note scenario-run evidence is separate from `agtoosa-proof-verify.sh` |
| AC-011 | Must | WHEN `lib/config.sh` installs workflow files THE SYSTEM SHALL register BCL contract, runner, verifier, and corpus paths |
| AC-012 | Must | WHEN compatibility regression runs THE SYSTEM SHALL require scenario corpus pointer language (ACC via BCL-013) |
| AC-013 | Must | WHEN shipping DEV-121 THE SYSTEM SHALL include recorded `scenario-run.json` for at least two platforms (cursor + claude pilots) |

## 3. Tasks

- [x] **1.** Contract + ADR-021 — _AC-001_
- [x] **2.** Schemas + corpus index — _AC-002–AC-003_
- [x] **3.** Runner + verifier + `lib/scenario.sh` — _AC-004–AC-006_
- [x] **4.** Six platform fixtures + pilot evidence — _AC-007, AC-013_
- [x] **5.** Compatibility + registry cross-links — _AC-008–AC-009_
- [x] **6.** Provenance note + config registration — _AC-010–AC-011_
- [x] **7.** BCL bats BCL-001–BCL-013 — _AC-001–AC-013_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-121.md`.

---

## ✅ Spec Approved

Approved: 2026-07-26 for implementation.

## ✅ Amendment R1 Approved

Approved: 2026-07-26 — universal scenario × six platforms + standalone runner/verifier.
