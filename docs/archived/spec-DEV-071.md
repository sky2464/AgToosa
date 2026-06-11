# Spec: DEV-071 - Non-interactive CLI and npm distribution

> **Story ID:** DEV-071
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
| Goal | Install AgToosa without a TTY and meet JS developers on npm. |
| User outcome | CI, devcontainers, and scripted rollouts install in one command; npx agtoosa works. |
| Success condition | --path/--platforms/--yes wired through bash; npm wrapper pins the package version and screens archives; version parity tested. |
| Proof / evidence | Wave bats IDs: NI-001, NI-002, SC-007; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN --path, --platforms, and --yes are provided, THE SYSTEM SHALL complete an install with no interactive prompt. |
| AC-002 | WHEN an unknown platform token is passed, THE SYSTEM SHALL fail with the valid token list. |
| AC-003 | WHEN the npm wrapper runs, THE SYSTEM SHALL download only the release matching its package version and screen archive members. |

## 2. Design

### 2.4 Build Scope

agtoosa.sh, lib/config.sh usage text, npm/, tests/agtoosa.bats

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

Test plan: `docs/AgToosa_TestPlan-DEV-071.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| npm wrapper drifts from generator version | Spoofing | SC-007 parity test pins npm version to AGTOOSA_VERSION |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
