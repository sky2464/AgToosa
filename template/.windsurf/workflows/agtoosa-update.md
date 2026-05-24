# AgToosa Update


## Windsurf workflow routing

This file is the native Windsurf project workflow for `/agtoosa-update`. When the user invokes `/agtoosa-update`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Update.md` and execute the `/agtoosa-update` workflow.

**Contract:** Detect → Plan → Apply → Verify (default: ask-then-apply). Sub-commands: `check` (read-only), `plan`, `apply`, `verify`. Do not treat the default flow as pure read-only sync.
