# Spec: DEV-066 - Pinned install chain

> **Story ID:** DEV-066
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
| Goal | Make every advertised install path fail closed on pinning violations. |
| User outcome | Users who pin a version get exactly that version or a hard error — never silent branch content. |
| Success condition | Tag downloads never fall back to branches; brew formula pins tag tarball + sha256; releases publish SHA256SUMS; bootstrap supports --sha256; ps1 path quoting fixed. |
| Proof / evidence | Wave bats IDs: SC-005, SC-006, SC-007; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN a pinned tag archive is unavailable, THE SYSTEM SHALL abort instead of substituting a branch of the same name. |
| AC-002 | WHEN --sha256 is provided, THE SYSTEM SHALL verify the downloaded archive and abort on mismatch. |
| AC-003 | WHEN a release publishes, THE SYSTEM SHALL attach versioned bootstrap entrypoints and a SHA256SUMS asset in a protected environment. |

## 2. Design

### 2.4 Build Scope

bootstrap.sh, bootstrap.ps1, Formula/agtoosa.rb, .github/workflows/release-advanced.yml, .github/workflows/ci.yml

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

Test plan: `docs/AgToosa_TestPlan-DEV-066.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| main-branch compromise reaches pinned users | Spoofing/Tampering | Fail-closed tag pinning; release-asset checksums; pinned formula; protected release environment |
| Quoted path injects shell via Git Bash launcher | Elevation of privilege | Source dir passed via environment variable, not string interpolation |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
