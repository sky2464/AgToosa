# AgToosa — Gemini CLI / Jules Agent Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Also read `Docs/Master-Architecture.md` before architecture-affecting work; it is high-priority memory for system boundaries, diagrams, data flow, deployment, security, and observability.

## Gemini workflow command routing

Installed AgToosa workflow commands live in `.gemini/commands/agtoosa-*.toml`. When the user types `/agtoosa-*` or names a command `agtoosa-*`, treat it as an installed AgToosa workflow command — execute the matching TOML adapter and `Docs/AgToosa_*.md`. Do **not** route `/agtoosa-*` to `/create-skill` or invent generic skill-creation flows for these names. Reserved `/agtoosa-*` and `agtoosa-*` names belong to AgToosa adapters only, not generated project skills.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | `zoom-out` |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `amend` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-goal` → Read `Docs/AgToosa_Goal.md` (clarify project/story outcomes) · `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-handoff` → Read `Docs/AgToosa_Handoff.md` (export handoff pack for async/external agent) · `/agtoosa-import` → Read `Docs/AgToosa_Import.md` (import external agent results before task closure) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Goal.md` — Goal clarification utility/sub-workflow
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Master-Architecture.md` — Solution architecture and C4-style diagrams
- `Docs/Context/` — Product, tech-stack, and workflow configuration

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.
