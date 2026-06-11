# Spec: DEV-064 - Safe tar extraction

> **Story ID:** DEV-064
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
| Goal | Reject hostile archive members before extraction in registry installs and bootstraps. |
| User outcome | A malicious pack or archive cannot write outside its staging directory. |
| Success condition | Member-list pre-scan rejects absolute and dot-dot paths in lib/registry.sh, bootstrap.sh, bootstrap.ps1. |
| Proof / evidence | Wave bats IDs: SC-001, SC-005, PS-002; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN an archive member contains an absolute path or a .. segment, THE SYSTEM SHALL abort before any extraction. |
| AC-002 | WHEN a registry pack downloads, THE SYSTEM SHALL extract into an isolated staging directory before any durable queueing. |
| AC-003 | WHEN extraction is aborted, THE SYSTEM SHALL leave no partial files in the queue or project. |

## 2. Design

### 2.4 Build Scope

lib/registry.sh, bootstrap.sh, bootstrap.ps1, agtoosa.ps1, tests/agtoosa.bats

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

Test plan: `docs/AgToosa_TestPlan-DEV-064.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Tar slip writes ~/.ssh or project files during extract | Tampering | tar -tzf member scan pre-extraction (bash, PS1, bootstraps); staging isolation |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
