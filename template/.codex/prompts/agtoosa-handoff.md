## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-handoff`. When the user invokes `/agtoosa-handoff`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Handoff.md` and execute the `/agtoosa-handoff` workflow.

Dispatch based on any arguments after the command: `wave` or `task`.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
