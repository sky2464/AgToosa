# ADR-020: IDE Host Mode Bridge (Spec and Review)

**Status:** Accepted  
**Date:** 2026-07-28  
**Deciders:** AI agent + human review (DEV-136)  
**Parent:** DEV-028 (Plan-Mode Spec Interview) · DEV-116 (Lifecycle Compass — amend plan-mode prohibition)

## Context

DEV-028 shipped a behavioral **Plan-Mode Spec Interview Contract** — research first, adaptive Q&A, turn-stop, findings artifact — but it runs inside whatever host mode the user happens to be in. DEV-116 Compass added **"Do not use Cursor native Plan mode"** for in-scope product work to prevent bypassing AgToosa workflow files.

Modern IDE hosts now ship native plan modes aligned with AgToosa's planning shape:

- **Cursor** — Plan mode (Shift+Tab): research, Q&A, reviewable plan, then build
- **GitHub Copilot / VS Code** — Plan agent (`/plan`): structured plan, **Start Implementation** handoff
- **Claude Code** — `plan` permission mode (Shift+Tab, `/plan`): read/analyze, approve plan → `auto` / `acceptEdits`
- **Codex, Windsurf, Gemini** — host-specific plan surfaces or behavioral fallbacks

AgToosa should **prefer** native plan mode during `/agtoosa-spec` and `/agtoosa-review` planning windows, then **auto-switch** to Agent/Auto for artifact writes — not fight the host.

## Decision

1. Add **IDE Host Mode Bridge** as a shared contract in `Docs/AgToosa_Agent.md`, referenced from `Docs/AgToosa_Spec.md` and `Docs/AgToosa_Review.md`.
2. **Supersede** the Compass rule "Do not use Cursor native Plan mode" with: prefer native IDE plan mode for spec/review planning windows; switch to Agent/Auto only at the auto-switch trigger.
3. **Plan-mode windows:**
   - `/agtoosa-spec` — research, Plan-Mode Spec Interview, Goal Contract / architecture / STRIDE as **plan artifact**
   - `/agtoosa-review` — persona synthesis, Iron Law hypotheses, cross-model gate planning, findings as **structured plan**
4. **Agent/Auto windows:** write `spec-*.md`, `review-*.md`, test plans, Master-Plan updates, simplification refactors, approval markers.
5. **Auto-switch trigger** (all must be true): decision-complete or assumptions accepted; minimum validation floor met; no pending interview question; print `HOST-MODE: plan complete → switching to agent for AgToosa artifacts` before first write.
6. **Never auto-switch** mid-interview, on PROGRESS utterances, or before user confirms assumptions.
7. **Per-platform enter/switch** instructions in native adapters + **IDE Host Mode Matrix** in `Docs/AgToosa_AgentCapability.md`.
8. **Product-truth** optional `host_mode_policy` on `command.spec` and `command.review` for bats-rendered adapter blocks.
9. **Review artifact:** `### Plan-Mode Review Briefing (findings)` in review reports (mirror spec findings pattern).

## Rationale

- Native plan modes are the host's planning surface — richer than behavioral turn-stop alone.
- Separating plan (brainstorm/Q&A) from agent (artifact writes) matches Spec → Build → Review → Ship discipline.
- Cross-platform parity via adapter instructions, not a shell runtime.

## Consequences

### Positive

- Spec and review leverage latest IDE plan-mode capabilities.
- Compass no longer blocks productive plan-mode usage.
- Clear handoff line (`HOST-MODE:`) auditable in chat logs.

### Negative

- Host plan→agent auto-switch can be flaky (Cursor queue desync, "Don't ask again" blocks) — mitigated by manual fallback instructions.
- Enforcement remains agent-instructed; no `agtoosa.sh` mode API in v1.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Keep blocking native plan mode | Fights host UX; duplicates plan-mode value DEV-028 mimicked behaviorally |
| Plan mode read-only only for review | User direction: use full plan-mode power, not read-only gating |
| Runtime mode switcher in `agtoosa.sh` | No stable cross-host API; out of scope v1 |
| Cursor-only v1 | User chose all-platform day one |

## Non-goals (v1)

- Auto-switch during `/agtoosa-build` or `/agtoosa-ship`
- Scenario-tested claims on every platform
- Replacing interview question budget or turn-stop semantics
