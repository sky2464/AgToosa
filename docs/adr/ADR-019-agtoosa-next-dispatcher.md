# ADR-019: /agtoosa-next Lifecycle Dispatcher (A+B Hybrid)

**Status:** Accepted (amended 2026-07-26)  
**Date:** 2026-07-26  
**Deciders:** AI agent + human review (DEV-125)

## Context

AgToosa's lifecycle is Spec → Build → Review → Ship. DEV-109 added dual-line phase close and `--status-line`. DEV-007 added `/agtoosa-help next` — read-only assistance. DEV-116 added Lifecycle Compass for freeform intent routing.

Most users (~90%) want sequential progress without memorizing phase slash commands. Advanced users still need explicit `/agtoosa-spec`, handoff, cross-model review, and parallel orchestration.

## Decision

1. Add **`/agtoosa-next`** as the **primary sequential driver** with canonical workflow `Docs/AgToosa_Next.md`.
2. **Dispatch, don't suggest:** read `--route-hint --format json` (including `spec_approved`), execute exactly **one** workflow per invocation.
3. **Help previews, Next executes:** `/agtoosa-help next` uses the same routing as `/agtoosa-next dry` and always hands off to `/agtoosa-next` for execution — help never mutates.
4. **Sub-commands:** `dry` (preview), `pick` (idle cold-start), optional tributary intents (`fix`, `test`, etc.).
5. **Idle behavior:** scan Backlog for highest-priority spec candidate; else cold-start with user idea or top-3 recommendations.
6. **Preserve Phase Stop:** never chain Spec → Build → Review → Ship inside one `/agtoosa-next` run.
7. **Compass feeds Next:** freeform sequential intent ("next", advance project) routes to `/agtoosa-next`, not raw phase slashes.
8. **Generator Must:** `spec_approved` in route-hint JSON; when false, SYNC `next` resolves to `/agtoosa-spec` not build.
9. **Sequential Approval (amended 2026-07-27):** when `/agtoosa-next` dispatches a phase, the user's Next invocation counts as approval at spec, review, and ship deploy gates when readiness checks pass — still one phase per invocation. Direct phase slashes keep standard gates. Post-ship idle routes to next backlog spec or cold-start recommendations.

## Consequences

- **Positive:** One command for sequential users; lower cognitive load; SYNC becomes trustworthy.
- **Positive:** Help remains safe (read-only) while Next handles execution.
- **Negative:** Doc repositioning across Quickref, Agent, help surfaces; product-truth inventory grows.
- **Advanced escape hatch:** explicit phase slashes and parallel orchestration unchanged.
