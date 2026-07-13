# ADR-014: AgToosa Lifecycle Compass (Semantic Freeform Routing)

**Status:** Accepted  
**Date:** 2026-07-12  
**Deciders:** AI agent + human review (DEV-116)  
**Parent:** ADR-013 (Project Intake) · DEV-109 (`--status-line`) · DEV-007 (`/agtoosa-help next`)

## Context

DEV-110 shipped **AgToosa Project Intake** — dual-mode soft/hard classification and destination mapping for freeform asks. DEV-112 added a **Natural Language Intent Map** — a small phrase table ("plan and code", "build it", "ship it") mapping informal wording to lifecycle workflows.

Users still omit magic phrases. Typical asks ("add OAuth", "CI is red", "look at my PR") do not match the table. Agents may under-route (code without spec), over-route (full ceremony on typos), or miss the lifecycle phase entirely. The phrase table does not scale to paraphrase diversity.

Existing deterministic pieces are underused at intake time:

- `agtoosa.sh --status-line` (DEV-109) emits `SYNC: … · next /agtoosa-<phase>`
- `/agtoosa-help next` encodes lifecycle ordering (DEV-007) but is on-demand only

ADR-013 rejected a runtime orchestrator and a `/agtoosa-intake` slash command. Enforcement remains agent-instructed.

## Decision

1. **Replace** the NL Intent Map phrase table with **AgToosa Lifecycle Compass** — a hybrid protocol extending Project Intake.
2. **Lifecycle-first anchoring:** every freeform resolution names an **ANCHOR** on Spec → Build → Review → Ship (`spec` · `build` · `review` · `ship` · `none`).
3. **Tributary work** (explore, small fix, track) is allowed but must declare which lifecycle phase it **serves** and print a **return cue** to the anchored phase when done.
4. **Mandatory preamble** on freeform asks (before product code): read Standing Corrections → run `--status-line` (or read Master-Plan) → infer semantic intent → classify Claim Boundary → reconcile intent × SYNC state → route.
5. **Optional generator JSON hint:** extend `run_status_line` with `--route-hint --format json` emitting deterministic phase facts (`anchor`, `story_id`, `tasks_done/total`, `sync` line). Agent owns utterance semantics; CLI owns project state.
6. **Branded user-facing lines:** `Compass: soft → …`, `**AgToosa Lifecycle Compass** — …`, `ANCHOR: <phase>`, tributary `serving <phase>` + `When done: return to /agtoosa-<phase>`.
7. **No new slash command** (`/agtoosa-compass`). Always-on rules + Agent contract, like intake.
8. **Phase Stop preserved** — Compass selects a workflow; never auto-chains Spec → Build → Review → Ship.

## Rationale

- Phrase tables are brittle; semantic classes + state reconciliation scale to natural language.
- Deterministic `--status-line` prevents build-without-spec when Master-Plan says `next /agtoosa-spec`.
- Tributaries (explore/fix/track) preserve intake speed while keeping Spec → Build → Review → Ship as the north star.
- JSON route hint makes the state half bats-testable without building an NLP engine in shell.

## Consequences

### Positive

- Freeform asks route intelligently without memorizing slash commands or magic phrases.
- Under-routing and over-routing both improve via intent × state matrix.
- Branding reinforces AgToosa lifecycle discipline.

### Negative

- Always-on rule surface grows (mitigate: concise core summary + full protocol in Agent.md).
- JSON hint must stay aligned with `run_status_line` lifecycle logic.
- Semantic half remains agent-instructed — hosts that ignore rules can still drift.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Expand phrase table only | Does not solve paraphrase diversity |
| Docs-only (no `--route-hint`) | State half harder to test; agents may skip Master-Plan read |
| Full `agtoosa-route.sh` NLP pre-router | Runtime orchestrator creep; brittle keywords; duplicates agent |
| Merge into DEV-110 retroactively | DEV-110 shipped; Compass is additive evolution |
| `/agtoosa-compass` slash command | Fails the "forgot slash" problem (ADR-013 pattern) |
