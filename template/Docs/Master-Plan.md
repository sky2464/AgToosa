# Master-Plan

> **Source of truth:** `Docs/Master-Plan.md` is the project management source of truth for all tasks, stories, and epics. No external tracker required.
> **Last updated:** [YYYY-MM-DD HH:MM]

## Project Charter

- Product: [name]
- GitHub repo: <!-- Add your GitHub repo URL here -->
- Current milestone: <!-- e.g., v1.0, Sprint 3, Unreleased -->
- Active cycle: [cycle name] ([start date] → [end date])
- Cycle capacity: [N] story points / [N] days

## Epics

> Created at `/agtoosa-init`. One row per product area.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| [DEV-XX] | Epic: [product area name] | [N open / N total] | Backlog |

*(Run `/agtoosa-init` to populate this table with your project's Epics.)*

## Active Cycle

> Stories committed to the current sprint/cycle.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| [DEV-XX] | Feature: [story name] | Feature | M | In Progress | 2/5 |

*(Empty until `/agtoosa-spec` enrolls a story in the active cycle.)*

## Active Tasks

> Task sub-issues under the currently In Progress story. Created at `/agtoosa-spec` (Part 4) or regenerated with `/agtoosa-spec tasks`.

| ID | Title | Estimate | Status |
|----|-------|----------|--------|
| [DEV-XX] | Task: [short description] | 2h | In Progress |

*(Empty until `/agtoosa-spec` (Part 4) breaks down the active story.)*

## Backlog

> Priority-ordered list of upcoming stories and issues. Updated by `/agtoosa-spec` and `/agtoosa-task`.

| ID | Title | Type | Estimate | Epic | Priority |
|----|-------|------|----------|------|----------|
| [DEV-XX] | Feature: [name] | Feature | S | [DEV-YY] | High |

*(Empty until stories are created via `/agtoosa-spec` or `/agtoosa-task`.)*

## Blocked

> Issues that cannot progress due to a dependency or decision.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|
| [DEV-XX] | [title] | [DEV-YY / external reason] | [YYYY-MM-DD] |

*(Empty — good! Update here if an issue is blocked during `/agtoosa-build`.)*

## Completed This Cycle

> Stories shipped this sprint. Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| [DEV-XX] | Feature: [name] | [YYYY-MM-DD] | `Docs/archived/AgToosa_Spec-[name]-v[N].md` |

*(Empty until `/agtoosa-ship` closes the first story.)*

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| [YYYY-MM-DD] | [phase] [Story ID] [started / completed / blocked / shipped] | AgToosa |

*(Run `/agtoosa-init` to add the first entry.)*
