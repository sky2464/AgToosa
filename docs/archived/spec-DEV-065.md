# Spec: DEV-065 - Registry pack containment

> **Story ID:** DEV-065
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
| Goal | Enforce the verified flag, preview pack contents, and deny sensitive destinations. |
| User outcome | Installing a community pack cannot silently inject executable hooks or CI workflows. |
| Success condition | Unverified packs blocked without --allow-unverified; preview shows AI-instruction surfaces; merge denylists .claude/settings.json, .claude/hooks/, .github/workflows/ with re-validation. |
| Proof / evidence | Wave bats IDs: SC-002, SC-003, SC-004, PS-001; verifier self-run PASS on this repo |
| Claim Boundary | Controls classified generator-enforced, CI-enforced(-able), agent-instructed, or manual in docs/AgToosa_Readiness.md and the Team Trust Roadmap matrix |
| Non-goals | Hosted services; cryptographic signing (tracked under DEV-054); enterprise SLA claims |
| Assumptions | AgToosa stays repo-native and markdown-first; bash/PS1 parity maintained |
| Risks | Overclaiming enforcement; adapter drift; regression in existing install/update flows |

## Requirements

### 1.2 Acceptance Criteria (EARS)

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN a registry entry has verified=false and no explicit opt-in, THE SYSTEM SHALL refuse the install with remediation guidance. |
| AC-002 | WHEN a pack is staged, THE SYSTEM SHALL display its full file tree flagging AI-instruction surfaces before asking for consent. |
| AC-003 | WHEN merging queued packs, THE SYSTEM SHALL skip denylisted destinations and re-validate path containment (find -L + realpath). |

## 2. Design

### 2.4 Build Scope

lib/registry.sh, lib/install.sh, agtoosa.sh (--allow-unverified), agtoosa.ps1, SECURITY.md, docs/AgToosa_Team_Trust_Roadmap.md

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

Test plan: `docs/AgToosa_TestPlan-DEV-065.md`

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Pack overwrites Claude settings/hooks (RCE on tool use) | Elevation of privilege | Hard denylist at merge + preview flag + PS1 parity |
| Durable prompt injection via platform rule files | Tampering | Preview consent labels every AI-instruction surface before install |

## ✅ Spec Approved

Approved: 2026-06-09 (wave enrollment from deep-review top-20; built and validated same session)
