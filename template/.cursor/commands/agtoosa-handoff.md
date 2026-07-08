---
description: AgToosa handoff pack export workflow
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-handoff`. When the user invokes `/agtoosa-handoff`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Handoff.md` and execute the `/agtoosa-handoff` workflow.

Dispatch based on any arguments after the command: `wave` or `task`.
