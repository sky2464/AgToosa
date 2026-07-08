---
description: AgToosa external agent result import workflow
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-import`. When the user invokes `/agtoosa-import`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Import.md` and execute the `/agtoosa-import` workflow.

Dispatch based on any arguments after the command: `check`.
