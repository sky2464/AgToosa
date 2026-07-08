---
description: AgToosa evidence ledger workflow — create or finalize per-story evidence at review and ship
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-evidence`. When the user invokes `/agtoosa-evidence`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Evidence.md` and execute the `/agtoosa-evidence` workflow.

Dispatch based on any arguments after the command: `review` or `ship`.
