---
name: agtoosa-init
description: Run one-time AgToosa project initialization — context, AI configs, epics, optional project specialist discovery, and optional project skill discovery.
---

# agtoosa-init

Use when the user asks for `/agtoosa-init`, `$agtoosa-init`, or first-time AgToosa setup.

## Execute

1. Read `Docs/AgToosa_Init.md` in full and **run** its workflow precisely.
2. **Dispatch** `zoom-out` when the user needs broader codebase context for a focused file or symbol.
3. Complete **Project Specialist Discovery** per `Docs/AgToosa_Specialists.md` when applicable; require approval before `Docs/Context/specialists.md` or native specialist files.
4. Complete **Project Skill Discovery** (Phase F) when applicable; require **explicit user approval** before writing any new `.codex/skills/<skill-name>/SKILL.md` file.
5. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
