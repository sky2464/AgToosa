---
name: agtoosa-import
mode: agent
description: "AgToosa: import external agent results and map to tasks/ACs before closure"
tools: [codebase]
---

Read Docs/AgToosa_Import.md and execute the external agent result import workflow.

Use any sub-command provided (`check`) to pre-fill Step 1. If `check`, report gaps only and stop. Otherwise start from Step 1 (Collect returns).

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
