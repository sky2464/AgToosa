## Codex prompt routing

This file is the Codex project prompt for `/agtoosa-spec`. When the user invokes `/agtoosa-spec`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Spec.md` and execute the `/agtoosa-spec` workflow. **Generated Project Mode** — see `Docs/AgToosa_Agent.md` → **Operating Contexts**.

Dispatch based on any arguments after the command: `research`, `plan`, `quick`, `tasks`, or `to-issues`.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
