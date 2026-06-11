# Spec: DEV-069 - Governance gate wiring

> **Story ID:** DEV-069
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
| Goal | Wire reference-only governance rules into the executing workflows. |
| User outcome | Out-of-order phase runs abort with the documented strings; debug state has a home; QA gates ship. |
| Success condition | Review/Ship prerequisites embed exact abort strings; Master-Plan template gains Active Diagnosis/Hypotheses; ship gains QA-cleared and verifier-green rows; QA reads the right AC heading. |
| Proof / evidence | Wave bats IDs: WC-007, WC-008; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN /agtoosa-review runs on a Todo story, THE SYSTEM SHALL print the exact governance abort string and stop. |
| AC-002 | WHEN /agtoosa-ship runs without a Review Approved entry, THE SYSTEM SHALL print the exact governance abort string and stop. |
| AC-003 | WHEN /agtoosa-debug records state, THE SYSTEM SHALL write to Master-Plan sections that exist in the shipped template. |

## 2. Design

### 2.4 Build Scope

template/Docs/AgToosa_Review.md, AgToosa_Ship.md, AgToosa_QA.md, Master-Plan.md template, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-069.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Phases skipped silently | Repudiation | Abort strings duplicated into prerequisites; verifier Gate 4 cross-checks review artifacts |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
