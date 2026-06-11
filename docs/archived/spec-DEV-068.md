# Spec: DEV-068 - Adapter drift remediation

> **Story ID:** DEV-068
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
| Goal | Restore canonical-to-adapter consistency across all six platforms. |
| User outcome | Every platform gets the same contract: Master-Plan-first, same sub-commands, same spec paths. |
| Success condition | Copilot instructions corrected; zoom-out/amend synced to all entry points; spec naming unified on Docs/archived/spec-[story-id].md; stale Linear-era mirrors regenerated. |
| Proof / evidence | Wave bats IDs: WC-004, WC-005, WC-008; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN Copilot instructions describe PM flow, THE SYSTEM SHALL state Master-Plan.md is the only source of truth (no tracker-first wording). |
| AC-002 | WHEN entry points list sub-commands, THE SYSTEM SHALL include init zoom-out and spec amend on all six platforms. |
| AC-003 | WHEN workflows reference the active spec, THE SYSTEM SHALL use the unified Docs/archived/spec-[story-id].md path. |

## 2. Design

### 2.4 Build Scope

template/.github/instructions, six entry-point files, AgToosa_Build/QA/Spec/Status references, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-068.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Platform adapters instruct contradictory behavior | Tampering | Parity bats greps per platform; mirrors regenerated from canonical templates |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
