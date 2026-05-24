---
name: agtoosa-debug
mode: agent
description: "AgToosa: diagnose hard bugs — feedback-loop → reproduce → minimise → hypothesise → instrument → fix+regress"
tools: [codebase, terminal]
---

Read Docs/AgToosa_Debug.md and execute the diagnosis workflow.

Sub-command dispatch (include the sub-command after selecting this prompt):
- No argument → full 6-phase diagnosis loop
- `quick` → Phases 1-3 only (feedback loop, reproduce, minimise)
- `deep` → full loop with extended instrumentation
- `feedback-loop` → Phase 1 only: establish fast feedback loop
