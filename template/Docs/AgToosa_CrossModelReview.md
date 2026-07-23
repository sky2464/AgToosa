# AgToosa /agtoosa-review cross-model Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-review cross-model` | Cross-model review gate — independent reviewer subagent/model with structured evidence merge |

> **Distinction:** `/agtoosa-review cross` = cross-**platform** manual second opinion (switch Cursor ↔ Copilot). `/agtoosa-review cross-model` = cross-**model** writer/reviewer separation on the same or different hosts.

## Objective

Run an optional **cross-model review gate** that separates the **writer** (build agent) from an **independent reviewer** (different agent, model, or subagent) for higher-assurance stories — with structured evidence merge, confidence tiers, and honest fallbacks when a second model is unavailable.

> **Prerequisites:** `/agtoosa-build` complete for the active story; active spec approved; story status `In Progress` or `In Review`.
>
> **Claim Boundary:** This gate is **agent-instructed**. AgToosa documents orchestration and evidence; it does **not** route paid model APIs or enforce a second model at generator runtime.
>
> **Source of truth:** `Docs/Master-Plan.md` remains the repo-local source of truth. External reviewers are integrations, not authorities.

## Roles

| Role | Actor | Permissions |
|------|-------|-------------|
| **Writer** | Agent that ran `/agtoosa-build` | May fix findings after review with user authorization |
| **Independent reviewer** | Different subagent, model, or platform instance | **Read-only** during the gate — no file or git mutations without explicit user authorization |
| **Orchestrator** | Primary review session | Merges evidence, applies confidence tiers, writes review report section |

## Risk-Tier Triggers

| Tier | When | Gate expectation |
|------|------|------------------|
| **Standard** | Routine Docs/chore with no trust-boundary ACs | Cross-model optional |
| **Recommended** | Spec threat model touches auth, registry, secrets, supply chain, or user-controlled input | Strongly recommend `/agtoosa-review cross-model` |
| **Strongly recommended** | Must ACs explicitly tag security/registry/auth surfaces | Run cross-model or document explicit skip rationale in review report |

Compute tier from the active spec STRIDE table and Must AC keywords — do not require a second model for every story.

## Workflow

1. **Tier check** — Read active spec threat model and Must ACs; record tier in review notes.
2. **Delegate reviewer** — Launch independent reviewer subagent(s) with read-only scope: diff, spec, test logs, threat model, test plan. **Do not paste secrets** into reviewer prompts — redact sensitive values from diffs and logs (same rules as `Docs/AgToosa_Handoff.md`).
3. **Specialist lanes** — When `Docs/Context/specialists.md` exists, run only specialists whose `phase_hooks` includes `review` and whose `trigger` matches the active story (see `Docs/AgToosa_Specialists.md`).
4. **Parallel execution** — When the host supports native parallel subagent delegation (Task tool, Agent tool, GitHub agent), run reviewer persona(s) and matching specialists in parallel. Confirm parallel vs sequential support via `Docs/AgToosa_AgentCapability.md` before claiming parallel lanes.
5. **Sequential fallback** — When parallel delegation is unavailable, run the same lanes sequentially and record exactly:

    ```
    Cross-model lanes ran sequentially (platform does not support parallel subagents).
    ```

6. **Collect evidence** — Each lane returns the structured evidence block below.
7. **Merge findings** — Tag each finding with a confidence tier before the Part 3 verdict table.
8. **Fallback chain** — When no second model/subagent is available, in order:
    - `/agtoosa-review cross` (cross-platform manual review)
    - Sequential virtual personas (Security, EM, CEO, QA) with documented rationale
    - Explicit skip with rationale in `## Cross-Model Review` — never mark gate passed without one outcome recorded

## Structured Evidence Block

Every reviewer lane must return this shape (extends `Docs/AgToosa_Specialists.md`):

```markdown
### Cross-model evidence: <reviewer-id>
- **Reviewer identity:** <agent name or specialist id>
- **Model/platform:** <e.g. Claude Sonnet / Cursor / Copilot / Codex>
- **Findings:** …
- **Files read:** …
- **Commands:** …
- **Warnings/errors:** …
- **Recommendations:** …
- **Spec sections affected:** Goal Contract | ACs | Architecture | Threat model | Tasks | Test plan
- **Confidence tier:** both-models | reviewer-only | writer-only | virtual-persona-only
```

## Merge and Confidence Rules

| Tier | Meaning |
|------|---------|
| `both-models` | Same finding flagged by writer-context review and independent reviewer |
| `reviewer-only` | Independent reviewer found; writer did not surface |
| `writer-only` | Writer/orchestrator found; reviewer did not confirm |
| `virtual-persona-only` | Finding from virtual Security/EM/CEO/QA personas only |

Deduplicate before the verdict table; prefer `both-models` when descriptions match.

## Read-Only Guarantee

The independent reviewer **must not** modify `Docs/Master-Plan.md`, git state, or implementation files during the gate. If a fix is needed, the orchestrator asks the user to authorize `/agtoosa-build` or a scoped fix — same pattern as `Docs/AgToosa_StatusGuide.md`.

> **Claim boundary:** On GitHub Copilot and other hosts, read-only is **agent-instructed** — native agent tool manifests may still list `terminal` or write-capable tools. Enforcement is policy + orchestrator authorization, not tool-level sandboxing (v1).

## Review Report Section

Append to `Docs/archived/review-[story-id].md`:

```markdown
## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | standard / recommended / strongly recommended |
| Reviewer identity | … |
| Model/platform | … |
| Outcome | completed / cross-platform fallback / sequential personas / skipped |
| Skip rationale | (required when skipped) |

[Merged findings with confidence tiers]
```

Update `Docs/archived/evidence-[story-id].md` with a `cross-model` row per `Docs/AgToosa_Evidence.md`.

## Related Workflows

- **Virtual personas** — `Docs/AgToosa_Review.md` Part 1 (not replaced)
- **Cross-platform** — `Docs/AgToosa_Review.md` Part 4 (`/agtoosa-review cross`)
- **Project specialists** — `Docs/AgToosa_Specialists.md`
- **Handoff packs** — `Docs/AgToosa_Handoff.md` when reviewer runs async/external
- **Lifecycle routing** — `Docs/AgToosa_AgentCapability.md` (parallel vs sequential per installed host)

## Output

- Present merged cross-model findings before the review approval gate.
- On successful completion, print the dual-line phase close per Docs/AgToosa_Agent.md → Lifecycle Next-Step Contract
