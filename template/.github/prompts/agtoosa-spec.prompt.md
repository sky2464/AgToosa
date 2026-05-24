---
name: agtoosa-spec
mode: agent
description: "AgToosa: research → 6 forcing questions → Executable Specification → STRIDE threat model → atomic task planning"
tools: [codebase, githubSearch, fetch]
---
name: agtoosa-spec

Read Docs/AgToosa_Spec.md and execute the specification workflow. **Generated Project Mode** — see Docs/AgToosa_Agent.md → **Operating Contexts**.

Sub-command dispatch (include the sub-command after selecting this prompt):
- No argument → full workflow (Parts 1 + 2 + 3 + 4: research, spec, architecture/threat-model, task planning)
- `research <topic>` → Part 1 only: context, research, domain language alignment, 6 forcing questions
- `plan` → Part 2 only: architecture blueprint + threat model
- `quick <desc>` → abbreviated: 3 questions + spec, skip full threat model
- `tasks` → Part 4 only: scope boundary + atomic task breakdown + test plan skeleton against an already-approved spec
- `to-issues` → break active spec into vertical-slice GitHub issues

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
