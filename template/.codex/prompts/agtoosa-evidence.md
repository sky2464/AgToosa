## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-evidence`. When the user invokes `/agtoosa-evidence`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Evidence.md` and execute the `/agtoosa-evidence` workflow.

Dispatch based on any arguments after the command: `review` or `ship`.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
