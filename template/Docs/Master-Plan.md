# Master-Plan

> **Source of truth for active work.** Completed work lives in `Docs/archived/` — see Completed This Cycle for links.
> **Last updated:** [YYYY-MM-DD HH:MM]

## Project Charter

| Field | Value |
|-------|-------|
| Product | `[name]` |
| Goal | `[project outcome]` |
| User outcome | `[who benefits and how]` |
| Success condition | `[measurable done state]` |
| Proof / evidence | `[tests, shipped behavior, metric, demo, or artifact]` |
| Non-goals | `[explicit exclusions]` |
| Assumptions | `[important assumptions]` |
| Risks | `[delivery, product, security, or quality risks]` |
| Unresolved questions | `[open points or None]` |
| GitHub repo | `[url]` |
| Milestone | `[e.g. v1.0, Sprint 3, Unreleased]` |
| Active cycle | `[cycle name]` |
| Cycle capacity | `[N] story points` |
| Current phase | ✏️ Spec · 🏗️ Build · 🔍 Review · 🚢 Ship ← _(update the active one)_ |

## Active Cycle

> Stories committed to the current sprint/cycle.
> **Progress:** `▰▰▰▰▱▱▱▱ 0/0 tasks` ← updated by `/agtoosa-build` after each task completes

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| [DEV-XX] | Feature: [story name] | Feature | M | 🟨 In Progress | 0/5 |

*(Empty until `/agtoosa-spec` enrolls a story in the active cycle.)*

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

- [ ] **1.** [Group name]: [top-level task]
  - [ ] 1.1 [sub-task description] — _Requirements: AC-001_
  - [ ] 1.2 [sub-task description] — _Requirements: AC-001, AC-003_
- [ ] **2.** [Group name]: [top-level task]
  - [ ] 2.1 [sub-task description] — _Requirements: AC-002_

*(Empty until `/agtoosa-spec` (Part 4) populates this section. Run `/agtoosa-spec tasks` to regenerate this tree if needed.)*

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.
> When you complete a step, run `/agtoosa-build` and choose (A) to mark it done.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|
| [DEV-XX] | 2.3 | [YYYY-MM-DD] | [task title] |

*(Empty — no manual tasks deferred.)*

## Blocked

> **Status:** 🟢 None blocked
> Update this section and change status pill if an issue is blocked during `/agtoosa-build`.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| [DEV-XX] | [title] | [DEV-YY / external reason] | [YYYY-MM-DD] |

*(Empty — good!)*

## Backlog

> Priority-ordered list of upcoming stories and issues. Updated by `/agtoosa-spec` and `/agtoosa-task`.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|
| [DEV-XX] | Feature: [name] | Feature | S | [DEV-YY] | High | ⬜ Backlog |

*(Empty until stories are created via `/agtoosa-spec` or `/agtoosa-task`.)*

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| [DEV-XX] | Epic: [product area name] | [N open / N total] | ⬜ Backlog |

*(Run `/agtoosa-init` to populate this table with your project's Epics.)*

## Active Diagnosis

> Written by `/agtoosa-debug` while a bug investigation is live. Cleared when the diagnosis closes.
> Holds the current reproduction command / feedback loop for the bug under investigation.

*(Empty — no active diagnosis.)*

## Hypotheses

> Written by `/agtoosa-debug`. Ranked candidate causes for the active diagnosis, marked confirmed/eliminated as evidence arrives.

*(Empty — no active diagnosis.)*

## Completed This Cycle

> Detail lives in `Docs/archived/`. This section shows pointer rows only — links to archived spec files.
> Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| [DEV-XX] | Feature: [name] | [YYYY-MM-DD] | [spec-[DEV-XX].md](archived/spec-[DEV-XX].md) |

*(Empty until `/agtoosa-ship` closes the first story.)*

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| [YYYY-MM-DD] | [phase] [Story ID] [started / completed / blocked / shipped] | AgToosa |

*(Run `/agtoosa-init` to add the first entry.)*
