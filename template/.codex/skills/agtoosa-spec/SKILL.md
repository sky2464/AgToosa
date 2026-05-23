---
name: agtoosa-spec
description: Research, specify, and architect a story with STRIDE threat modeling, task planning, and optional story skill synthesis.
---

# agtoosa-spec

Use when the user asks for `/agtoosa-spec`, `$agtoosa-spec`, or wants a new or updated story specification.

## Execute

1. Read `Docs/AgToosa_Spec.md` in full and **run** its workflow precisely — preserve forcing questions, threat modeling, approval gates, and cycle enrollment steps unless `quick` applies.
2. **Dispatch** the first matching sub-command from user arguments: `research`, `plan`, `quick`, `tasks`, or `to-issues`. With no argument, run Parts 1–4.
3. Run Story Skill Opportunity Synthesis when applicable; require **explicit user approval** before writing project skill files.
4. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
