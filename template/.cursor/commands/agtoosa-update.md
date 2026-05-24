---
description: AgToosa update workflow
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-update`. When the user invokes `/agtoosa-update`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Update.md` and execute the `/agtoosa-update` workflow.

**Contract:** Detect → Plan → Apply → Verify (default: ask-then-apply). Sub-commands: `check` (read-only), `plan`, `apply`, `verify`. Do not describe the default flow as a pure read-only sync.
