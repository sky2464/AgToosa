# Spec: DEV-043 - Brownfield Spec Drift Baseline

> **Story ID:** DEV-043
> **Epic:** DEV-002
> **Status:** ✅ Done
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa has public launch proof and honest positioning as a lightweight, repo-native, multi-assistant SDLC workflow generator. The next competitive gap is making higher-assurance spec-to-test-to-agent execution explicit without claiming runtime enforcement before it exists.

DEV-043 captures one candidate capability from the competitive execution wave. It is enrolled in the active cycle and implemented as a canonical brownfield baseline workflow.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Create current-state baseline specs from code/docs and detect code/spec drift. |
| User outcome | Brownfield users can start from existing reality instead of writing future-state specs from scratch. |
| Success condition | Baseline workflow records current state, change deltas, and drift evidence. |
| Proof / evidence | Baseline doc template, drift checklist, focused bats docs checks, and test-plan evidence. |
| Claim Boundary | Capability is roadmap until this story ships with passing evidence; classify controls as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| Non-goals | This story does not guarantee full static analysis or replace architecture review. |
| Assumptions | AgToosa remains repo-native and markdown-first; external services and agents are integrations, not required runtime dependencies. |
| Risks | Overpromising current guarantees; adapter drift; workflow text that cannot be verified. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN DEV-043 is read THE SYSTEM SHALL state the specific user outcome and proof required before the capability is treated as shipped. |
| AC-002 | WHEN the capability mentions enforcement THE SYSTEM SHALL classify it as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| AC-003 | WHEN external agents, trackers, registries, or dashboards are mentioned THE SYSTEM SHALL preserve AgToosa as the repo-local source of truth unless implementation evidence proves otherwise. |
| AC-004 | WHEN implementation begins THE SYSTEM SHALL add focused regression coverage before changing generator or template behavior. |
| AC-005 | WHEN shipping THE SYSTEM SHALL record evidence in the matching test plan and avoid claims broader than the completed scope. |

## Design

Implement this story as a focused AgToosa lifecycle enhancement. Prefer docs/workflow contracts first, then narrow generator or template changes only where the acceptance criteria require an enforceable surface. Keep platform adapters delegated to canonical docs instead of duplicating long logic.

## Build Scope

Files in scope will be selected when the story is enrolled. Expected surfaces may include `docs/Master-Plan.md`, `docs/AgToosa_*.md`, `template/Docs/AgToosa_*.md`, platform adapters, `lib/config.sh`, and `tests/agtoosa.bats` depending on the final implementation.

Out of scope: broad version bumps, release publication, hosted services, and enterprise/compliance claims not backed by automated evidence.

## Task Tree

- [x] **1.** Add focused failing tests - _Requirements: AC-001-AC-005_
- [x] **2.** Implement the narrow workflow or generator change - _Requirements: AC-001-AC-004_
- [x] **3.** Update docs and platform references without duplicating canonical logic - _Requirements: AC-002, AC-003_
- [x] **4.** Record validation evidence in the test plan - _Requirements: AC-005_
- [x] **5.** Run focused tests, broader regression slice, full bats, and `git diff --check` - _Requirements: AC-004, AC-005_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 3, 4
**Wave 3 (sequential after Wave 2):** 5

## Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Baseline workflow overclaims static-analysis coverage | Repudiation | "Do not claim static analysis coverage" wording enforced by DEV-043 bats greps |
| Drift baseline text instructs agents to mutate source-of-truth files | Tampering | Source-of-truth boundary string required in both canonical docs (BDB-002) |
| Inventory steps surface sensitive paths/secrets in spec evidence | Information disclosure | Evidence redaction rules from ship workflow apply to baseline inventories |

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-043.md`

## ✅ Spec Approved

Approved for Active Cycle enrollment on 2026-06-08. Build preserves the claim boundary: DEV-043 adds an agent-instructed brownfield baseline workflow, not full static analysis or hosted drift detection.
