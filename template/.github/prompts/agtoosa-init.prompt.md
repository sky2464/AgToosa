---
name: agtoosa-init
mode: agent
description: "AgToosa: one-time project init — scan codebase, validate AI configs, create Docs/Context/ files"
tools: [codebase]
---
name: agtoosa-init

Read Docs/AgToosa_Init.md and execute the initialization workflow.

Sub-command dispatch (include the sub-command after selecting this prompt):
- No argument → full one-time initialization: scan codebase, validate AI configs, establish Docs/Context/, configure AgToosa
- `zoom-out` → zoom-out: call graph, module boundaries, usage sites, and impact analysis for current focus area

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
