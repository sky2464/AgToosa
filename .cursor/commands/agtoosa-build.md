---
description: AgToosa build workflow (maintainer dogfood)
---

## Cursor command routing

This file is the native Cursor project command for `/agtoosa-build` in **Maintainer Dogfood Mode**. When the user invokes `/agtoosa-build`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `docs/AgToosa_Build.md` and execute the `/agtoosa-build` workflow. See `docs/agtoosa-maintainer.md` for operating context.

Dispatch based on any arguments after the command: `tdd` or `test`.

If build prerequisites fail, **stop** and instruct the user — do **not** auto-run `/agtoosa-spec`. Report **Terminal Evidence Contract** fields for every command and parallel subagent.
