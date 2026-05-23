---
mode: agent
description: "AgToosa: clarify project or story goals into a Goal Contract"
---

Read `Docs/AgToosa_Goal.md` and execute the goal clarification sub-workflow.

Dispatch based on the user's arguments:
- `/agtoosa-goal project <idea>`: clarify the project-level goal and update `Docs/Master-Plan.md`.
- `/agtoosa-goal story <idea>`: clarify a story or feature goal and update the active spec Goal Contract.
- `/agtoosa-goal check`: run a read-only goal clarity and satisfaction check.
- `/agtoosa-goal revise`: revise the current Goal Contract after an approval gate.
- `/agtoosa-goal`: infer project vs story; if unclear, ask one question.

This is an optional utility/sub-workflow, not a main lifecycle command.

