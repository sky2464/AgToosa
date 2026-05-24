# AgToosa Ship

Read `Docs/AgToosa_Ship.md` and execute the `/agtoosa-ship` workflow.

Dispatch based on any arguments after the command:
- `check` → read-only readiness audit (`Docs/AgToosa_Ship.md` Part 0 only; no deploy, archive, or file mutation)
- `docs` or `retro` → run only the matching part from `Docs/AgToosa_Ship.md`
- No argument → full ship flow (Part 0, then deploy approval and release steps)
