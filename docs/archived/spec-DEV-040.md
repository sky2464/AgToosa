# Spec: DEV-040 - Team trust roadmap

> **Story ID:** DEV-040
> **Epic:** DEV-003 - Community Template Registry / DEV-004 - Testing & QA Harness
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** S
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-016

## Context

AgToosa should launch for solo/indie developers first, but team and enterprise trust needs should be explicit before growth. The launch review identified future requirements: signed registry plan, high-assurance mode, docs versioning, adapter drift automation, support/security expectations, and enforcement boundaries.

DEV-040 creates the roadmap and boundary matrix without overbuilding enterprise controls before they are needed.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Define the team/enterprise trust roadmap while keeping day-one launch focused. |
| User outcome | Teams can see which controls exist, which are roadmap items, and what AgToosa does not enforce yet. |
| Success condition | A roadmap doc separates launch, growth, and team trust phases; a control matrix distinguishes generator-enforced, CI-enforced, agent-instructed, and manual controls. |
| Proof / evidence | Roadmap doc exists, README/docs link to it where appropriate, and docs tests prevent overpromising signed registry/SLA/enforcement. |
| Non-goals | Implementing signed registry, release signing, enterprise SLA, or adapter drift automation in this story. |
| Assumptions | High-assurance features are future work unless separately specified. |
| Risks | Roadmap language can sound like a current guarantee. Mitigate with explicit status labels. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the roadmap is read THE SYSTEM SHALL separate day-one launch, growth push, and team/enterprise trust requirements. |
| AC-002 | WHEN signed registry or signed releases are mentioned THE SYSTEM SHALL label them future high-assurance work unless implemented. |
| AC-003 | WHEN docs versioning and migration are mentioned THE SYSTEM SHALL define a policy direction for breaking workflow changes. |
| AC-004 | WHEN adapter drift automation is mentioned THE SYSTEM SHALL describe checks beyond grep-only parity as roadmap work. |
| AC-005 | WHEN controls are listed THE SYSTEM SHALL classify each as generator-enforced, CI-enforced, agent-instructed, or manual. |
| AC-006 | WHEN support/security expectations are listed THE SYSTEM SHALL avoid enterprise SLA promises before support capacity exists. |

## Design

Create a trust roadmap doc, likely `docs/AgToosa_Team_Trust_Roadmap.md`, with phase sections and an enforcement-boundary matrix. Link it from launch readiness docs or README without making it first-screen marketing.

## Build Scope

Files in scope: `docs/AgToosa_Team_Trust_Roadmap.md`, `README.md` or `docs/AgToosa_Readiness.md`, focused docs tests, and `docs/AgToosa_TestPlan-DEV-040.md`.

## Task Tree

- [ ] **1.** Add failing trust-roadmap docs tests - _AC-001-AC-006_
- [ ] **2.** Create team trust roadmap doc - _AC-001-AC-006_
- [ ] **3.** Link roadmap from appropriate docs - _AC-001_
- [ ] **4.** Verify no current docs overpromise signed registry, SLA, or enforcement - _AC-002, AC-006_
- [ ] **5.** Run focused docs tests and `git diff --check` - _AC-001-AC-006_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-040.md`
