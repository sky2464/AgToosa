# Spec: DEV-072 - Spec change control and living capability specs

> **Story ID:** DEV-072
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
| Goal | Make approved-spec changes auditable and let system documentation compound. |
| User outcome | Amendments carry revisions and re-approval; shipped deltas merge into living capability specs. |
| Success condition | /agtoosa-spec amend + Spec Revision Log in SPEC-FORMAT; Capability Delta (ADDED/MODIFIED/REMOVED) merged by ship Part 3. |
| Proof / evidence | Wave bats IDs: WC-006, WC-002; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN an approved spec changes, THE SYSTEM SHALL record a revision-log row instead of editing silently. |
| AC-002 | WHEN a Must-priority AC is added, modified, or removed, THE SYSTEM SHALL require explicit re-approval before build continues. |
| AC-003 | WHEN a story ships with a Capability Delta, THE SYSTEM SHALL merge it into Docs/specs/system/<capability>.md. |

## 2. Design

### 2.4 Build Scope

template/Docs/AgToosa_Spec.md, SPEC-FORMAT.md, AgToosa_Ship.md, spec adapters across six platforms, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-072.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Silent edits to approved contracts | Repudiation | Revision log + inline AC markers + verifier checks revision section presence |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
