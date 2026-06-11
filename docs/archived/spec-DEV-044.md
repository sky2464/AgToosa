# Spec: DEV-044 - EARS-to-Test TDD Gate

> **Story ID:** DEV-044
> **Epic:** DEV-004
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa has public launch proof and honest positioning as a lightweight, repo-native, multi-assistant SDLC workflow generator. The next competitive gap is making higher-assurance spec-to-test-to-agent execution explicit without claiming runtime enforcement before it exists.

DEV-044 captures one candidate capability from the competitive execution wave. It is a backlog spec until explicitly enrolled and built.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Map acceptance criteria to concrete test obligations and require RED/GREEN evidence before task closure. |
| User outcome | Builders can prove each AC has a test plan and TDD evidence instead of broad test claims. |
| Success condition | Build workflow requires AC-to-test mapping and recorded red/green evidence for story completion. |
| Proof / evidence | Workflow text, test-plan schema, focused bats checks, and validation evidence. |
| Claim Boundary | Capability is roadmap until this story ships with passing evidence; classify controls as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| Non-goals | This story remains agent-instructed unless CI enforcement is added in implementation. |
| Assumptions | AgToosa remains repo-native and markdown-first; external services and agents are integrations, not required runtime dependencies. |
| Risks | Overpromising current guarantees; adapter drift; workflow text that cannot be verified. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN DEV-044 is read THE SYSTEM SHALL state the specific user outcome and proof required before the capability is treated as shipped. |
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

- [ ] **1.** Add focused failing tests - _Requirements: AC-001-AC-005_
- [ ] **2.** Implement the narrow workflow or generator change - _Requirements: AC-001-AC-004_
- [ ] **3.** Update docs and platform references without duplicating canonical logic - _Requirements: AC-002, AC-003_
- [ ] **4.** Record validation evidence in the test plan - _Requirements: AC-005_
- [ ] **5.** Run focused tests, broader regression slice, full bats, and `git diff --check` - _Requirements: AC-004, AC-005_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-044.md`
