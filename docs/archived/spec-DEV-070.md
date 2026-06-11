# Spec: DEV-070 - Token economy restructure

> **Story ID:** DEV-070
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
| Goal | Cut framework context tax without weakening the contract. |
| User outcome | Users stop paying for 21KB always-on prompts on unrelated chats. |
| Success condition | Quickref (≤90 lines) ships as the cheap entry; cursor core rule scoped (alwaysApply false); flake detection scoped to changed tests; tdd defaults true. |
| Proof / evidence | Wave bats IDs: WC-009; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN a session needs AgToosa context, THE SYSTEM SHALL offer a one-page quickref before any deep doc load. |
| AC-002 | WHEN Cursor loads rules for non-AgToosa edits, THE SYSTEM SHALL NOT apply the AgToosa core rule (scoped globs only). |
| AC-003 | WHEN flaky-test detection runs, THE SYSTEM SHALL scope re-runs to changed tests instead of 3x full suites. |

## 2. Design

### 2.4 Build Scope

template/Docs/AgToosa_Quickref.md, .cursor/rules/agtoosa-core.mdc, Context/workflow.md, AgToosa_Review.md, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-070.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Trimmed context drops a non-negotiable rule | Tampering | Quickref states rules verbatim and links canonical docs; bats checks size and key strings |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
