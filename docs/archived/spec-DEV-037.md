# Spec: DEV-037 - Truthful launch documentation and positioning

> **Story ID:** DEV-037
> **Epic:** DEV-002 - Workflow Templates
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-004, LRS-005, LRS-007, LRS-009, LRS-015

## Context

The launch review found credibility risks in public docs: unqualified "No dependencies" language, stale comparison table, stale `SECURITY.md`, fragile macOS bootstrap guidance, and broad positioning that does not clearly name where AgToosa wins or loses.

DEV-037 makes the public-facing story accurate and decision-oriented.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Replace overclaims and stale comparison language with truthful dependency, security, platform, and competitor positioning. |
| User outcome | Developers can quickly decide whether AgToosa is right for them and can trust that docs do not overstate generator enforcement. |
| Success condition | README and security docs distinguish target-app runtime from generator prerequisites, current competitors are positioned honestly, macOS guidance is conservative, and security policy names current surfaces and supported versions. |
| Proof / evidence | Focused grep/Bats documentation checks and `git diff --check` pass. |
| Non-goals | PowerShell update parity, registry archive shape, Homebrew release automation, proof project walkthrough, or signed registry. |
| Assumptions | AgToosa's launch wedge is lightweight repo-native multi-assistant SDLC workflow installation for solo/indie developers and small teams. |
| Risks | Trying to sound "better than everyone" can reduce trust. Mitigate with a decision guide that also recommends competitors for their strengths. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN README describes dependencies THE SYSTEM SHALL avoid unqualified "No dependencies" and state generator prerequisites separately from target-app runtime. |
| AC-002 | WHEN README describes security/TDD/SBOM/DAST THE SYSTEM SHALL distinguish generator-enforced controls from agent-instructed workflow guidance. |
| AC-003 | WHEN README compares alternatives THE SYSTEM SHALL replace stale checkmark marketing with a dated decision guide. |
| AC-004 | WHEN alternatives are named THE SYSTEM SHALL concede competitor strengths for Spec Kit, OpenSpec, BMAD, Task Master, Spec Kitty, and metaswarm. |
| AC-005 | WHEN `SECURITY.md` is read THE SYSTEM SHALL name current supported versions, current security surfaces, and reporting channel. |
| AC-006 | WHEN bootstrap macOS guidance is read THE SYSTEM SHALL avoid fragile OS-version claims and give conservative install guidance. |
| AC-007 | WHEN positioning is read THE SYSTEM SHALL name right-fit and wrong-fit developer segments. |

## Design

Refactor README around a narrow promise: no target-app SDK/runtime, standard generator prerequisites, local workflow files, and honest guidance boundaries. Replace the stale comparison table with a "Use AgToosa when / Use another tool when" section.

Refresh `SECURITY.md` to current release line and actual attack surfaces. Replace macOS bootstrap wording with conservative prerequisite guidance.

## Build Scope

Files in scope: `README.md`, `SECURITY.md`, `bootstrap.sh`, `docs/AgToosa_Readiness.md`, `docs/AgToosa_TestPlan-DEV-037.md`, and focused Bats documentation checks.

## Task Tree

- [ ] **1.** Add failing doc truthfulness tests - _AC-001-AC-007_
- [ ] **2.** Rewrite dependency/runtime and enforcement-boundary claims - _AC-001, AC-002_
- [ ] **3.** Replace stale competitor table with dated decision guide - _AC-003, AC-004, AC-007_
- [ ] **4.** Refresh `SECURITY.md` supported versions, surfaces, and reporting channel - _AC-005_
- [ ] **5.** Fix macOS bootstrap guidance - _AC-006_
- [ ] **6.** Run focused docs tests, shellcheck for bootstrap, full Bats if touched tests require it, and `git diff --check` - _AC-001-AC-007_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-037.md`
