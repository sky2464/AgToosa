---
name: agtoosa-update
mode: agent
description: "AgToosa: Detect → Plan → Apply → Verify baseline update (check is read-only)"
tools: [codebase]
---

Read Docs/AgToosa_Update.md and execute the `/agtoosa-update` workflow.

**Contract:** Detect → Plan → Apply → Verify (default: ask-then-apply). Sub-commands: `check` (read-only), `plan`, `apply`, `verify`. Do not describe the default flow as pure read-only sync.

Use optional user arguments as sub-commands or focus hints per the canonical doc.