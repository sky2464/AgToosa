# Spec: DEV-063 - Phase-event log and Update Log rotation

> **Story ID:** DEV-063
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
| Goal | Record machine-readable phase events and keep Master-Plan inside context budgets. |
| User outcome | Projects get auditable cycle data without unbounded markdown growth. |
| Success condition | Workflows append agtoosa-events.jsonl lines at transitions; ship rotates Update Log rows beyond 150 into archives. |
| Proof / evidence | Wave bats IDs: WC-010, VF-004; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN a phase starts or completes, THE SYSTEM SHALL append one JSON event line to Docs/agtoosa-events.jsonl. |
| AC-002 | WHEN the Update Log exceeds 150 rows, THE SYSTEM SHALL rotate older rows to Docs/archived/updatelog-<year>.md preserving every row. |
| AC-003 | WHEN stats mode runs, THE SYSTEM SHALL report event and ledger analytics deterministically. |

## 2. Design

### 2.4 Build Scope

template/Docs/AgToosa_Build.md, AgToosa_Ship.md, AgToosa_Agent.md, AgToosa_Quickref.md, docs mirrors

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

Test plan: `docs/AgToosa_TestPlan-DEV-063.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Event log forged to fake progress | Repudiation | Events cross-checked against Update Log and artifacts by verifier/stats; git history retains truth |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
