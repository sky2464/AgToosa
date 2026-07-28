---
name: agtoosa-review
description: Run multi-persona code review — security, architecture, product alignment, and QA coverage.
---

# agtoosa-review

Use when the user asks for `/agtoosa-review`, `$agtoosa-review`, or post-build review before ship.

## Execute

1. Read `Docs/AgToosa_Review.md` in full and **run** its workflow precisely.
2. **Dispatch** `security`, `arch`, `debug`, `cross`, or `cross-model` when provided; otherwise run all reviewer personas. For cross-model, read `Docs/Context/workflow.md` policy and follow consent + model ceiling in `Docs/AgToosa_CrossModelReview.md`.
3. Do not ship or merge — review outputs recommendations and findings only unless the user authorizes fixes.
4. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)

## Host Mode Execution (IDE Host Mode Bridge)

Follow `Docs/AgToosa_Review.md` → **IDE Host Mode Bridge** and `Docs/AgToosa_AgentCapability.md` → **IDE Host Mode Matrix** (Codex / OpenCode row).

- **Enter plan:** host plan skill or behavioral plan-only synthesis when native plan mode is unavailable
- **Plan window:** persona analysis, Iron Law hypotheses, cross-model gate, findings synthesis; include `### Plan-Mode Review Briefing (findings)` in the plan
- **Switch to agent:** when briefing complete, print `HOST-MODE: plan complete → switching to agent for AgToosa artifacts`, then agent execution mode for review artifacts and simplification
