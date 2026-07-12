Display the AgToosa command reference.

## Sub-commands

| Sub-command | Behavior |
|-------------|----------|
| _(none)_ | Print the static command table below **without** reading `Docs/Master-Plan.md`, git state, or other project files |
| `next` | **Assistance-only:** read-only context read → recommend exactly one next AgToosa command |

### Default — `/agtoosa-help` (static, fast)

Output the table below directly. Do not read any Docs file for the default path.

---

## AgToosa Command Reference

| Command | Purpose | Sub-commands |
|---------|---------|--------------|
| `/agtoosa-init` | One-time setup: scan codebase, validate AI configs, create Docs/Context/ files | _(none)_ |
| `/agtoosa-spec` | Research → 6 forcing questions → Executable Specification → STRIDE threat model → atomic task planning | `research` · `plan` · `quick` · `tasks` · `amend` · `to-issues` |
| `/agtoosa-build` | TDD Red-Green-Refactor against the planned task list → full test suite + SAST/DAST | `tdd` · `test` |
| `/agtoosa-qa` | Plan → run → report → triage: unit, integration, E2E, browser, a11y, performance | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | 4-persona parallel review (Security · Arch · Product · QA) + Simplifier pass | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | Pre-flight → deploy → archive spec → update changelog → suggest next story | `check` · `docs` · `retro` |
| `/agtoosa-goal` | Clarify project/story outcomes into a Goal Contract | `project` · `story` · `check` · `revise` |
| `/agtoosa-revert` | Git-aware logical rollback by phase or commit | _(phase or commit)_ |
| `/agtoosa-task` | Fast task capture to Master-Plan.md for bugs, chores, spikes, and fixes | _(type and description)_ |
| `/agtoosa-update` | Re-read context + changelog and sync workflow files to latest AgToosa baseline | _(none)_ |
| `/agtoosa-status` | Read-only health dashboard: Master-Plan parsing, git cross-ref, orphan detection | `plan` · `git` · `orphans` |

### Typical workflow
```
/agtoosa-init          (once per project)
/agtoosa-spec          → /agtoosa-build → /agtoosa-qa → /agtoosa-review → /agtoosa-ship
```

`/agtoosa-help` and `/agtoosa-help next` are **on-demand assistance** — not part of this lifecycle.

### Key files
- `Docs/Master-Plan.md` — project management source of truth
- `Docs/AgToosa_Goal.md` — goal clarification utility/sub-workflow
- `Docs/AgToosa_AgentCapability.md` — lifecycle routing matrix (installed surfaces → handoff/review paths)
- `Docs/Context/` — product, tech-stack, and workflow configuration
- `Docs/archived/` — completed specs and plans
- `Docs/AgToosa_Changelog.md` — auto-maintained changelog

### Authoring resources
Static maintainer-guide links (print as-is; do not fetch or treat as local Docs paths):
- Platform extensions: https://github.com/sky2464/AgToosa/blob/main/docs/extension-authoring-guide.md
- Registry packs: https://github.com/sky2464/AgToosa/blob/main/docs/registry-pack-authoring.md

### `/agtoosa-help next` (read-only)

1. Read `Docs/Master-Plan.md` and run read-only git commands (`git status`, `git log --oneline -5`). **Never modify** files, git state, or Master-Plan.
2. Recommend **exactly one** next command:
   - Empty Active Cycle → `/agtoosa-spec`
   - Active story with unchecked automated tasks → `/agtoosa-build`
   - All automated tasks done, no archived review → `/agtoosa-review`
   - Review passed, ready to close → `/agtoosa-ship`
   - Multiple blockers or unclear state → `/agtoosa-status`
3. Optionally include **one** matrix-based routing hint from `Docs/AgToosa_AgentCapability.md` when the recommended command is handoff, review, or async build (read-only; no mutation).
4. Output:

```
Next command: `/agtoosa-<command>`
Rationale: <one sentence>
Note: This is a **suggestion only** — no command has been run. The agent **does not auto-run** mutating commands (`/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, `/agtoosa-ship`).
```

For deeper coaching with authorization gates, mention the Status Guide — do not invoke it automatically.
