# AgToosa — OpenCode Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utility:** `/agtoosa-revert` → `Docs/AgToosa_Revert.md` (git-aware rollback)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- Linear project `AgToosa` — Source of truth for project state and backlog
- `Docs/Master-Plan.md` — Workspace mirror of Linear state
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep Linear updated first, then mirror the current state in `Docs/Master-Plan.md`.
