---
description: AgToosa command reference
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-help`. When the user invokes `/agtoosa-help`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Agent.md` and display the AgToosa command reference.

If the argument is `next`, perform a read-only status/context review and recommend the next AgToosa command. Do not run mutating commands automatically. Optionally include one routing hint from `Docs/AgToosa_AgentCapability.md` when the next command is handoff, review, or async build.
