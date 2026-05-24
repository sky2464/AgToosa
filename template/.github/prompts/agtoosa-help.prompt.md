---
name: agtoosa-help
mode: ask
description: "AgToosa: static command reference or read-only /agtoosa-help next assistance"
tools: []
---
name: agtoosa-help

Display the AgToosa command reference.

## Sub-commands

| Sub-command | Behavior |
|-------------|----------|
| _(none)_ | Print the static command table below **without** reading `Docs/Master-Plan.md`, git state, or other project files |
| `next` | **Assistance-only:** read-only context read → recommend exactly one next AgToosa command |

### Default — `/agtoosa-help` (static, fast)

Output this table directly without reading any Docs file.

## AgToosa Command Reference

| Command | Purpose | Sub-commands |
|---------|---------|--------------|
| `/agtoosa-init` | One-time setup: scan codebase, validate configs, create Docs/Context/ | _(none)_ |
| `/agtoosa-spec` | Research → 6 questions → Spec → STRIDE threat model → atomic task planning | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | TDD Red-Green-Refactor against the planned task list → tests + SAST/DAST | `tdd` · `test` |
| `/agtoosa-qa` | Plan → run → report → triage all test types | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | 4-persona parallel review + Simplifier pass | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | Pre-flight → deploy → archive → changelog → next story | `check` · `docs` · `retro` |
| `/agtoosa-goal` | Clarify project/story outcomes into a Goal Contract | `project` · `story` · `check` · `revise` |
| `/agtoosa-revert` | Git-aware logical rollback by phase or commit | _(phase or commit)_ |
| `/agtoosa-task` | Fast task capture to Master-Plan.md for bugs, chores, spikes, and fixes | _(type and description)_ |
| `/agtoosa-update` | Re-read context + changelog and sync workflow files to latest AgToosa baseline | _(none)_ |
| `/agtoosa-status` | Read-only health dashboard: Master-Plan parsing, git cross-ref, orphan detection | `plan` · `git` · `orphans` |

Typical workflow: `/agtoosa-spec` → `/agtoosa-build` → `/agtoosa-qa` → `/agtoosa-review` → `/agtoosa-ship`

`/agtoosa-help` and `/agtoosa-help next` are **on-demand assistance** — not part of this lifecycle.

### `/agtoosa-help next` (read-only)

1. Read `Docs/Master-Plan.md` and run read-only git commands (`git status`, `git log --oneline -5`). **Never modify** files, git state, or Master-Plan.
2. Recommend **exactly one** next command:
   - Empty Active Cycle → `/agtoosa-spec`
   - Active story with unchecked automated tasks → `/agtoosa-build`
   - All automated tasks done, no archived review → `/agtoosa-review`
   - Review passed, ready to close → `/agtoosa-ship`
   - Multiple blockers or unclear state → `/agtoosa-status`
3. Present mutating commands as **suggestions only** — **do not auto-run** `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, or `/agtoosa-ship`.
