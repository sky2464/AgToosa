---
name: agtoosa-spec
description: Research, specify, and architect a story with STRIDE threat modeling, task planning, and optional story skill synthesis.
---

# agtoosa-spec

Use when the user asks for `/agtoosa-spec`, `$agtoosa-spec`, or wants a new or updated story specification.

## Execute

**Generated Project Mode:** See `Docs/AgToosa_Agent.md` → **Operating Contexts** — specs are for **the project/product**, not the AgToosa framework.

1. Read `Docs/AgToosa_Spec.md` in full and **run** its workflow precisely — preserve **Spec Specialist Orchestration** (`Docs/AgToosa_Specialists.md`), the **Plan-Mode Spec Interview Contract**, threat modeling, approval gates, and cycle enrollment steps unless `quick` applies.
2. **Dispatch** the first matching sub-command from user arguments: `research`, `plan`, `quick`, `tasks`, `amend`, or `to-issues`. With no argument, run Parts 1–4.
3. **Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically. Approval marks readiness only — the user must invoke `/agtoosa-build` explicitly.
4. Run Story Skill Opportunity Synthesis when applicable; require **explicit user approval** before writing project skill files. Do not propose project skills named `agtoosa-*` or triggered by `/agtoosa-*` — those names are reserved for AgToosa workflow adapters.
5. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)

## Agent Mode Execution Contract

`Docs/AgToosa_Spec.md` is the **canonical** workflow. This skill is an execution contract for Codex agent mode — **not a routing summary** and not a shallow dispatcher. Do **not** treat these instructions as permission to skip phases.

**Before any outputs:** read `Docs/AgToosa_Spec.md` in full.

**Full flow (no sub-command):** execute Parts 1–4 and produce visible evidence for each obligation below. Do **not** skip:

- **Spec Specialist Orchestration** — when `Docs/Context/specialists.md` exists, run matching `spec`-phase specialists per `Docs/AgToosa_Specialists.md`; parallel or sequential with evidence blocks merged before Goal Contract
- **Research** — context gathering and external research before user questions; verify dependencies and platform behavior from live sources when the workflow requires it
- **Goal Contract** — Story Goal Contract synthesis per the canonical spec workflow
- **Plan-Mode Spec Interview** — follow `Docs/AgToosa_Spec.md` → **Plan-Mode Spec Interview Contract**; adaptive cap **8** (`quick` cap **2**); minimum validation floor **2** / **1**; **interview turn-stop** after Q1; infer before asking; one question at a time with contextual options; satisfy Decision-complete checklist or document accepted assumptions; include `### Plan-Mode Spec Interview (findings)` in the spec
- **Executable spec** — requirements, user stories, EARS acceptance criteria, design, architecture, and STRIDE threat model
- **Task planning** — task tree in the spec and `Docs/Master-Plan.md` → `## Active Tasks`
- **Test plan skeleton** — `Docs/AgToosa_TestPlan-[story-id].md` per the workflow
- **Approval gate** — stop for `## ✅ Spec Approved`; never auto-approve or mark approved without the user

**Forbidden for the full flow:** skipping Plan-Mode Spec Interview or research; treating a detailed user prompt as interview-complete; writing spec/test-plan/Master-Plan rows in the **same turn** as the first interview question; omitting `### Plan-Mode Spec Interview (findings)`; implementing build artifacts before spec approval; skipping Goal Contract, task planning, or the test plan skeleton; copying divergent Part 1 / Part 2 workflow section bodies from `Docs/AgToosa_Spec.md` into this skill; auto-running `/agtoosa-build` after spec.

## Host Mode Execution (IDE Host Mode Bridge)

Follow `Docs/AgToosa_Spec.md` → **IDE Host Mode Bridge** and `Docs/AgToosa_AgentCapability.md` → **IDE Host Mode Matrix** (Codex / OpenCode row).

- **Enter plan:** host plan skill or behavioral plan-only turn-stop when native plan mode is unavailable
- **Plan window:** research, Plan-Mode Spec Interview, Goal Contract / architecture / STRIDE as plan artifact
- **Switch to agent:** when auto-switch trigger satisfied, print `HOST-MODE: plan complete → switching to agent for AgToosa artifacts`, then switch to agent execution mode (or print manual switch instruction)
- **Forbidden in plan mode:** writing spec files, test plans, or Master-Plan story rows before handoff

**Sub-commands:** when the user passes `research`, `plan`, `quick`, `tasks`, `amend`, or `to-issues`, dispatch that slice only while preserving the canonical phase obligations and stop conditions from `Docs/AgToosa_Spec.md`.
