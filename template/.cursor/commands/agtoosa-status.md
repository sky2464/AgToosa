---
description: AgToosa status dashboard
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-status`. When the user invokes `/agtoosa-status`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

**CRITICAL:** This is a **read-only** command — do not modify any files, git state, or `Docs/Master-Plan.md`.

Read `Docs/AgToosa_Status.md` and execute the `/agtoosa-status` workflow. **Generated Project Mode** — see `Docs/AgToosa_Agent.md` → **Operating Contexts**.

Dispatch based on any arguments after the command: `plan`, `readiness`, `git`, or `orphans`.
