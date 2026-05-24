# AgToosa — GitHub Copilot Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles, and security requirements.

Then load all scoped instruction files in `.github/instructions/`.

## GitHub slash-command routing

When the user types `/agtoosa-*` (for example `/agtoosa-spec` or `/agtoosa-init`), treat it as an AgToosa **workflow prompt** — execute the matching `.github/prompts/agtoosa-*.prompt.md` adapter and the corresponding `Docs/AgToosa_*.md` workflow. Do **not** route `/agtoosa-*` to `/create-skill` or invent a generic skill-creation flow for these names.

## Core Commands

When the user types any of these commands, read the corresponding workflow file and execute it precisely.
Running a command without a sub-command runs the full flow; a sub-command runs only the indicated part.

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | _(none)_ |
| `/agtoosa-spec` | `Docs/AgToosa_Spec.md` | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | `Docs/AgToosa_Build.md` | `tdd` · `test` |
| `/agtoosa-qa` | `Docs/AgToosa_QA.md` | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | `Docs/AgToosa_Ship.md` | `check` · `docs` · `retro` |

**Optional utilities:** `/agtoosa-goal` → Read `Docs/AgToosa_Goal.md` (clarify project/story outcomes) · `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast task capture to Master-Plan.md) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest) · `/agtoosa-status` → Read `Docs/AgToosa_Status.md` (read-only project health dashboard)

See `Docs/AgToosa_Agent.md` for the full sub-command reference.

## Key References

- `Docs/Master-Plan.md` — Source of truth for project state and backlog
- `Docs/AgToosa_Goal.md` — Goal clarification utility/sub-workflow
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/*.instructions.md` — scoped coding, testing, security, and changelog rules

Always keep `Docs/Master-Plan.md` up to date — it is the source of truth for project state and backlog.
