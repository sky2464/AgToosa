## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-task`. When the user invokes `/agtoosa-task`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Task.md` and execute the `/agtoosa-task` workflow.

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
