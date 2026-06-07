# Spec: DEV-039 - First 15 minutes proof and growth positioning

> **Story ID:** DEV-039
> **Epic:** DEV-002 - Workflow Templates
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-07)
> **Estimate:** S
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-014

## Context

AgToosa's strongest launch wedge is concrete first-run value. The launch review identified missing proof as a growth risk: without a real walkthrough or proof project, the product promise remains theoretical.

DEV-039 creates a short first-15-minutes proof that demonstrates what AgToosa installs and what artifacts a developer should expect.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Create a public walkthrough showing install, init, spec, test-plan, review, and ship artifacts in a tiny repo. |
| User outcome | A new developer can understand AgToosa's value before adopting the full workflow. |
| Success condition | README links to a first-15-minutes proof that starts from a clean repo and ends with visible AgToosa artifacts while distinguishing generator output from agent-instructed work. |
| Proof / evidence | Walkthrough commands are runnable in a temp repo or documented as a verified transcript; referenced artifacts exist. |
| Non-goals | Building a hosted demo, recording video, or adding a full sample app runtime. |
| Assumptions | Text-first walkthrough is enough for launch; screenshots can come later. |
| Risks | The walkthrough can become too long. Mitigate by limiting it to the smallest credible proof path. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the walkthrough is followed THE SYSTEM SHALL start from a clean repo and end with visible AgToosa artifacts. |
| AC-002 | WHEN artifacts are shown THE SYSTEM SHALL include at least one spec, one test-plan mapping, one review, and one ship-check artifact. |
| AC-003 | WHEN explaining artifacts THE SYSTEM SHALL name what the generator created versus what the AI agent was instructed to do. |
| AC-004 | WHEN developers try the walkthrough THE SYSTEM SHALL include cleanup/reset guidance. |
| AC-005 | WHEN README is read THE SYSTEM SHALL link the walkthrough near quickstart or first-run docs. |

## Design

Add `docs/examples/first-15-minutes.md` or equivalent. Keep the proof small and command-oriented. Use private-staging/public-launch language consistently with DEV-035.

## Build Scope

Files in scope: `docs/examples/first-15-minutes.md`, `README.md`, optional fixture docs under `docs/examples/`, focused docs tests, and `docs/AgToosa_TestPlan-DEV-039.md`.

## Task Tree

- [ ] **1.** Add failing walkthrough presence/link tests - _AC-001-AC-005_
- [ ] **2.** Create first-15-minutes walkthrough - _AC-001-AC-004_
- [ ] **3.** Link walkthrough from README quickstart - _AC-005_
- [ ] **4.** Verify referenced commands/artifacts or transcript - _AC-001-AC-004_
- [ ] **5.** Run focused docs tests and `git diff --check` - _AC-001-AC-005_

## Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-039.md`
