## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-import`. When the user invokes `/agtoosa-import`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Import.md` and execute the `/agtoosa-import` workflow.

Dispatch based on any arguments after the command: `check`.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
