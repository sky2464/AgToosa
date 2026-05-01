---
mode: agent
description: "AgToosa: one-time project init — scan codebase, validate AI configs, create Docs/Context/ files"
tools: [codebase]
---

Read Docs/AgToosa_Init.md and execute the initialization workflow.

Sub-command dispatch (include the sub-command after selecting this prompt):
- No argument → full one-time initialization: scan codebase, validate AI configs, establish Docs/Context/, configure AgToosa
- `zoom-out` → zoom-out: call graph, module boundaries, usage sites, and impact analysis for current focus area
