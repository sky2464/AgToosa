## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-ship`. When the user invokes `/agtoosa-ship`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Ship.md` and execute the `/agtoosa-ship` workflow.

Dispatch based on any arguments after the command: `check`, `docs`, or `retro`.

If the argument is `check`, run the read-only readiness audit (`Docs/AgToosa_Ship.md` Part 0 only). Do not deploy, archive specs, mutate changelog, or perform file mutation.

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
