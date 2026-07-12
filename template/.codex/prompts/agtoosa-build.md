## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-build`. When the user invokes `/agtoosa-build`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Build.md` and execute the `/agtoosa-build` workflow.

Dispatch based on any arguments after the command: `tdd` or `test`.

Respect all prerequisites. If a spec or task list is missing, stop and instruct the user to run `/agtoosa-spec` or `/agtoosa-spec tasks`; do **not** auto-run `/agtoosa-spec`.

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
