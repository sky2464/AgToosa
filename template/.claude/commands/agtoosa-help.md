Display the AgToosa command reference. Do not read any Docs file — output this table directly.

---

## AgToosa Command Reference

| Command | Purpose | Sub-commands |
|---------|---------|--------------|
| `/agtoosa-init` | One-time setup: scan codebase, validate AI configs, create Docs/Context/ files | _(none)_ |
| `/agtoosa-spec` | Research → 6 forcing questions → Executable Specification → STRIDE threat model → atomic task planning | `research` · `plan` · `quick` · `tasks` · `to-issues` |
| `/agtoosa-build` | TDD Red-Green-Refactor against the planned task list → full test suite + SAST/DAST | `tdd` · `test` |
| `/agtoosa-qa` | Plan → run → report → triage: unit, integration, E2E, browser, a11y, performance | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | 4-persona parallel review (Security · Arch · Product · QA) + Simplifier pass | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | Pre-flight → deploy → archive spec → update changelog → suggest next story | `check` · `docs` · `retro` |
| `/agtoosa-revert` | Git-aware logical rollback by phase or commit | _(phase or commit)_ |
| `/agtoosa-task` | Fast task capture to Master-Plan.md for bugs, chores, spikes, and fixes | _(type and description)_ |
| `/agtoosa-update` | Re-read context + changelog and sync workflow files to latest AgToosa baseline | _(none)_ |
| `/agtoosa-status` | Read-only health dashboard: Master-Plan parsing, git cross-ref, orphan detection | `plan` · `git` · `orphans` |

### Typical workflow
```
/agtoosa-init          (once per project)
/agtoosa-spec          → /agtoosa-build → /agtoosa-qa → /agtoosa-review → /agtoosa-ship
```

### Key files
- `Docs/Master-Plan.md` — project management source of truth
- `Docs/Context/` — product, tech-stack, and workflow configuration
- `Docs/archived/` — completed specs and plans
- `Docs/AgToosa_Changelog.md` — auto-maintained changelog
