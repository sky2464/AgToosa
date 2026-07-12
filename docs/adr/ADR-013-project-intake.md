# ADR-013: AgToosa Project Intake (Dual-Mode Freeform PM)

**Status:** Accepted  
**Date:** 2026-07-12  
**Deciders:** AI agent + human review (DEV-110)

## Context

AgToosa’s product promise is Spec → Build → Review → Ship with Master-Plan as source of truth. In practice, users often omit `/agtoosa-*` and send freeform prompts (“fix this error”, “browser shows X”, “update deps and never use memory”). Without an always-on intake contract, host agents may implement untracked changes, skip Spec for architecture-sized work, or repeat the same mistake minutes later because lessons were never written into project Context.

Existing pieces are insufficient alone: Discovery Triage only runs mid-`/agtoosa-build`; `/agtoosa-help next` is on-demand and never auto-runs; Cursor `agtoosa-core.mdc` ships with `alwaysApply: false`; Iron Law dependency checks are not promoted from freeform corrections into durable memory. DEV-109 improves post-phase next-step messaging and multi-spec clarity — it does not classify cold-start freeform asks.

## Decision

1. **Project Intake (dual-mode):** Soft path for Claim-Boundary-small asks (expedite with a quiet route line); hard path for Claim-Boundary-sized risk (no product code until user confirms; benefit-framed **AgToosa Project Intake** message).
2. **Always-on delivery:** Document the contract in `Docs/AgToosa_Agent.md` and set Cursor `agtoosa-core.mdc` to `alwaysApply: true`, with entry-point pointers on Claude/AGENTS (and peers). Explicit `/agtoosa-*` bypasses intake ceremony.
3. **Standing Corrections:** Persist always/never lessons as a dated, deduped table under `## Standing Corrections` in `Docs/Context/workflow.md`; read before classify/act.
4. **Destinations + expedite:** Map to task, review finding/sub-task, in-scope build, Spec, or factor-out; once soft-routed or hard-confirmed, execute the user’s ask immediately under that path.
5. **Tiered logging + Phase Stop:** Soft path avoids Update Log spam; hard path records after confirm. Never auto-chain Spec→Build→Review→Ship.
6. **Enrollment:** DEV-110 Backlog immediately after planned specs (after DEV-109); expedite build when capacity frees.

## Rationale

- Soft-only would still allow unintentional AI architecture drift.
- Hard-gate-only would interrupt typo/debug asks and harm install UX.
- A new `/agtoosa-intake` command would fail the “forgot slash” problem; always-on rules match install expectations.
- Retro (DEV-056) is proposal-only and too slow for “don’t do that again in five minutes.”

## Consequences

### Positive

- Freeform asks stay under AgToosa PM discipline without requiring perfect slash hygiene.
- Lessons stick in Context so agents re-read them.
- Soft path preserves speed for small work; hard path protects the Master Plan.

### Negative

- Always-on rules increase prompt surface on every Cursor turn.
- Standing Corrections need dedupe discipline or the table grows noisy.
- Claim Boundary remains agent-instructed — hosts that ignore rules can still drift (mitigated by bats + install expectation, not a runtime engine).

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Soft PM only (classify then always proceed) | Does not stop architecture-sized mistakes |
| Hard gate always | Interrupts small legitimate asks |
| New `/agtoosa-intake` command | Users who forgot slash will not invoke it |
| Docs-only (`alwaysApply: false`) | Weakest IDE enforcement; fails install expectation |
| Retro-only lesson store | Too slow; does not protect the next five minutes |
| Merge into DEV-109 | Different failure mode (post-phase sync vs cold-start intake) |
