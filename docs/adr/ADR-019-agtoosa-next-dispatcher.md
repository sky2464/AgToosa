# ADR-019: /agtoosa-next Lifecycle Dispatcher

**Status:** Accepted  
**Date:** 2026-07-26  
**Deciders:** AI agent + human review (DEV-125)

## Context

AgToosa's lifecycle is Spec → Build → Review → Ship. DEV-109 added dual-line phase close and `--status-line`. DEV-007 added `/agtoosa-help next` — read-only assistance that recommends one command but never executes it. DEV-116 added Lifecycle Compass for freeform intent routing.

Users who want a single "do the right thing now" entry point must still remember which phase command to run. Saying "next" after completing a phase should advance the project without re-deriving state from scratch.

## Decision

1. Add **`/agtoosa-next`** as a utility command with canonical workflow `Docs/AgToosa_Next.md`.
2. **Dispatch, don't suggest:** read `--route-hint --format json`, apply approval override, execute exactly **one** lifecycle workflow per invocation.
3. **Sub-commands:** `dry` (preview), `pick` (idle cold-start with user choice).
4. **Idle behavior:** scan Backlog for highest-priority spec candidate; else cold-start with user idea or top-3 recommendations.
5. **Preserve Phase Stop:** never chain Spec → Build → Review → Ship inside one `/agtoosa-next` run.
6. **Distinct from help:** `/agtoosa-help next` stays read-only; `/agtoosa-next` mutates via dispatched workflow.

## Consequences

- **Positive:** One command advances lifecycle; pairs naturally with "say next again" UX.
- **Positive:** Reuses existing `--status-line` / route-hint infrastructure (DEV-109, DEV-116).
- **Negative:** Another command surface across six platform targets; product-truth inventory grows.
- **Follow-up:** Optional generator enhancement to include `spec_approved` in route-hint JSON (DEV-125 build task).
