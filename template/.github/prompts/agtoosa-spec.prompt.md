---
mode: agent
description: "AgToosa: research → 6 forcing questions → Executable Specification → STRIDE threat model → atomic task planning"
tools: [codebase, githubSearch, fetch]
---

Read Docs/AgToosa_Spec.md and execute the specification workflow.

Sub-command dispatch (include the sub-command after selecting this prompt):
- No argument → full workflow (Parts 1 + 2 + 3 + 4: research, spec, architecture/threat-model, task planning)
- `research <topic>` → Part 1 only: context, research, domain language alignment, 6 forcing questions
- `plan` → Part 2 only: architecture blueprint + threat model
- `quick <desc>` → abbreviated: 3 questions + spec, skip full threat model
- `tasks` → Part 4 only: scope boundary + atomic task breakdown + test plan skeleton against an already-approved spec
- `to-issues` → break active spec into vertical-slice GitHub issues
