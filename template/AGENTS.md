# AgToosa — Gemini CLI / Jules Agent Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

## Core Commands

| Command | Workflow File |
|---------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` |

**Optional utility:** `/agtoosa-revert` → `Docs/AgToosa_Revert.md` (git-aware rollback)

## Key References

- Linear project `AgToosa` — Source of truth for project state and backlog
- `Docs/Master-Plan.md` — Workspace mirror of Linear state
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep Linear updated first, then mirror the current state in `Docs/Master-Plan.md`.
