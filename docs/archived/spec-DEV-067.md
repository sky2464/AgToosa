# Spec: DEV-067 - Executable workflows with TDD evidence

> **Story ID:** DEV-067
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
| Goal | Remove steps non-interactive agents cannot execute and make TDD provable. |
| User outcome | Builds and ships complete without interactive git, and RED runs are captured before GREEN. |
| Success condition | Build requires RED/GREEN evidence blocks; staging is path-explicit; ship squash is non-interactive with a backup ref; deploy needs documented targets or goes [manual]; revert mandates a safety net; waves execute in order. |
| Proof / evidence | Wave bats IDs: WC-001, WC-002, WC-003; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN a TDD task starts, THE SYSTEM SHALL capture a failing-run evidence block before implementation code is written. |
| AC-002 | WHEN squashing WIP commits, THE SYSTEM SHALL use a non-interactive procedure with a backup ref and restore path. |
| AC-003 | WHEN no documented deploy target exists, THE SYSTEM SHALL mark deployment [manual] rather than claiming success. |

## 2. Design

### 2.4 Build Scope

template/Docs/AgToosa_Build.md, AgToosa_Ship.md, AgToosa_Revert.md, .cursor rules, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-067.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Fabricated test/deploy claims | Repudiation | Mandatory evidence blocks checked by verifier; deploy requires documented target or manual marker |
| History loss during squash/revert | Tampering | backup/pre-squash and backup/revert refs are mandatory before rewriting |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
