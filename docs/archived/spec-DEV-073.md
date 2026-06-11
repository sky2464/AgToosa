# Spec: DEV-073 - Onboarding: doctor, uninstall, README consolidation

> **Story ID:** DEV-073
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
| Goal | Make AgToosa easy to try, easy to trust, and easy to remove. |
| User outcome | New users reach value in minutes; skeptics can audit and cleanly uninstall. |
| Success condition | --doctor diagnoses installs; --uninstall removes owned files preserving user data; README has one Installation section, a Day-1 card, and a Verification section. |
| Proof / evidence | Wave bats IDs: DR-001, UN-001, WC-011; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN --doctor runs on an installed project, THE SYSTEM SHALL report version skew, missing docs, wiring gaps, and context health. |
| AC-002 | WHEN --uninstall runs, THE SYSTEM SHALL remove AgToosa-owned files WHILE preserving Master-Plan, Context, archived, and merged entry points. |
| AC-003 | WHEN the README is read, THE SYSTEM SHALL present exactly one Installation section with pinned, fail-closed paths. |

## 2. Design

### 2.4 Build Scope

lib/maintain.sh, agtoosa.sh, README.md, tests/agtoosa.bats

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

Test plan: `docs/AgToosa_TestPlan-DEV-073.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Uninstall deletes user project data | Tampering | Explicit preserve-list; confirmation prompt; self-target guard |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
