# AgToosa Spec


## Windsurf workflow routing

This file is the native Windsurf project workflow for `/agtoosa-spec`. When the user invokes `/agtoosa-spec`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Spec.md` and execute the `/agtoosa-spec` workflow.

Dispatch based on any arguments after the command: `research`, `plan`, `quick`, `tasks`, or `to-issues`.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.
