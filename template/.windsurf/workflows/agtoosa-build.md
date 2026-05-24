# AgToosa Build


## Windsurf workflow routing

This file is the native Windsurf project workflow for `/agtoosa-build`. When the user invokes `/agtoosa-build`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Build.md` and execute the `/agtoosa-build` workflow.

Dispatch based on any arguments after the command: `tdd` or `test`.

If build prerequisites fail, **stop** and instruct the user — do **not** auto-run `/agtoosa-spec`. Report **Terminal Evidence Contract** fields for every command and parallel subagent.
