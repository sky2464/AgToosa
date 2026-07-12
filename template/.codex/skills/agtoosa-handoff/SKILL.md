---
name: agtoosa-handoff
description: Export an AgToosa-ready handoff pack for an async or external agent to execute a wave or task.
---

# agtoosa-handoff

Use when the user asks for `/agtoosa-handoff`, `$agtoosa-handoff`, or wants to export work context for Codex, Copilot, Jules, Devin, Cursor background agents, or Claude Code.

## Execute

1. Read `Docs/AgToosa_Handoff.md` in full and **run** its workflow precisely.
2. **Dispatch** `wave` or `task` when provided; otherwise run the full flow (Resolve target → Assemble pack → Write file).
3. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
