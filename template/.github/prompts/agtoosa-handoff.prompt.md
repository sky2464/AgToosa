---
name: agtoosa-handoff
mode: agent
description: "AgToosa: export a handoff pack for an async or external agent (wave or task)"
tools: [codebase]
---

Read Docs/AgToosa_Handoff.md and execute the handoff pack export workflow.

Use any sub-command or story reference provided (`wave`, `task`, or a story ID/title fragment) to pre-fill Step 1. Otherwise start from Step 1 (Resolve target).

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
