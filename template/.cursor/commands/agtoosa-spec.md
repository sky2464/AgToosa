---
description: AgToosa spec workflow
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-spec`. When the user invokes `/agtoosa-spec`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Spec.md` and execute the `/agtoosa-spec` workflow. **Generated Project Mode** — see `Docs/AgToosa_Agent.md` → **Operating Contexts**.

**Plan-Mode Spec Interview:** follow `Docs/AgToosa_Spec.md` → **Plan-Mode Spec Interview Contract** (canonical). Research the codebase and context before asking; interview before finalizing the spec; adaptive cap **8** (`quick` cap **2**).

Dispatch based on any arguments after the command: `research`, `plan`, `quick`, `tasks`, `amend`, or `to-issues`.

**Phase stop:** stop at the approval gate. Do **not** run `/agtoosa-build` automatically — the user must invoke it after approval.
