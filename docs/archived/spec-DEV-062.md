# Spec: DEV-062 - AgToosa Gate CI workflow template

> **Story ID:** DEV-062
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
| Goal | Provide a copy-in CI workflow that blocks PRs on verifier failures. |
| User outcome | Teams convert agent-instructed discipline into CI-enforced checks with one file copy. |
| Success condition | Docs/agtoosa-gate.yml.example ships in the pack and runs the repo-local verifier. |
| Proof / evidence | Wave bats IDs: VF-005, WC-011; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the gate workflow runs in CI, THE SYSTEM SHALL execute the repo-local verifier and fail the check on non-zero exit. |
| AC-002 | WHEN AgToosa installs files, THE SYSTEM SHALL NOT write into .github/workflows/ automatically (explicit user copy required). |
| AC-003 | WHEN the verifier script is missing, THE SYSTEM SHALL fail the gate with an actionable update instruction. |

## 2. Design

### 2.4 Build Scope

template/Docs/agtoosa-gate.yml.example, lib/config.sh, README.md, tests/agtoosa.bats

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

Test plan: `docs/AgToosa_TestPlan-DEV-062.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Auto-installed CI workflow as attack surface | Elevation of privilege | Shipped as .example only; user copies deliberately; packs denylisted from workflows dir |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
