# Spec: DEV-061 - Deterministic lifecycle verifier

> **Story ID:** DEV-061
> **Epic:** DEV-004
> **Status:** ✅ Done
> **Estimate:** S/M
> **Spec created:** 2026-06-09
> **Wave:** Proof engine + supply chain (DEV-061–DEV-073), from the 2026-06-09 deep-review top-20

## Context

Implemented as part of the proof-engine and supply-chain wave. Consolidated validation evidence lives in `docs/AgToosa_TestPlan-DEV-061-073.md`; the story test plan below maps this story's ACs to wave test IDs.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ship a no-AI verifier that machine-checks AgToosa lifecycle state locally and in CI. |
| User outcome | Builders prove specs, ACs, threat models, mappings, and TDD evidence instead of claiming them. |
| Success condition | Docs/agtoosa-verify.sh installed with every project; agtoosa.sh --verify dispatches it; exit codes gate CI. |
| Proof / evidence | Wave bats IDs: VF-001, VF-002, VF-003, VF-004, VF-005; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the verifier runs on a repo with an active story lacking an approved spec, THE SYSTEM SHALL exit non-zero and name the story. |
| AC-002 | WHEN acceptance criteria rows lack EARS keywords, THE SYSTEM SHALL report them WHILE keeping the check deterministic (no LLM calls). |
| AC-003 | WHEN the generator installs or updates a project, THE SYSTEM SHALL register the verifier, quickref, and gate example in the template file lists. |

## 2. Design

### 2.4 Build Scope

template/Docs/agtoosa-verify.sh, lib/maintain.sh, lib/config.sh, agtoosa.sh, docs mirrors, tests/agtoosa.bats

Out of scope: version bumps, release publication, external-surface publishing (npm/tap/marketplace — Manual / Deferred).

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Add focused failing/contract tests — _Requirements: AC-001, AC-002, AC-003_
- [x] **2.** Implement the change on the owning surface — _Requirements: AC-001, AC-002_
- [x] **3.** Sync docs, mirrors, and platform adapters — _Requirements: AC-002, AC-003_
- [x] **4.** Record evidence in the story test plan — _Requirements: AC-003_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1
**Wave 2 (sequential after Wave 1):** 2, 3
**Wave 3 (sequential after Wave 2):** 4

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-061.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Verifier text tricked into false PASS by crafted markdown | Tampering | Greps anchored to structural markers; strict mode; CI re-runs on every PR |
| Verifier reads sensitive repo content into CI logs | Information disclosure | Read-only; prints findings summaries, not file bodies |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
