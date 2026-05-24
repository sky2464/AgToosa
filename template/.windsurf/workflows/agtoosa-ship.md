# AgToosa Ship


## Windsurf workflow routing

This file is the native Windsurf project workflow for `/agtoosa-ship`. When the user invokes `/agtoosa-ship`, execute the AgToosa workflow below — do **not** route to `/create-skill` or generate a project skill for AgToosa workflow names.

Read `Docs/AgToosa_Ship.md` and execute the `/agtoosa-ship` workflow.

Dispatch based on any arguments after the command:
- `check` → read-only readiness audit (`Docs/AgToosa_Ship.md` Part 0 only; no deploy, archive, or file mutation)
- `docs` or `retro` → run only the matching part from `Docs/AgToosa_Ship.md`
- No argument → full ship flow (Part 0, then deploy approval and release steps)
