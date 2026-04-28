Display the AgToosa command reference. Do not read any Docs file — output this table directly.

---

## AgToosa Command Reference

| Command | Purpose | Sub-commands |
|---------|---------|--------------|
| `/agtoosa-init` | One-time setup: scan codebase, validate AI configs, create Docs/Context/ files | _(none)_ |
| `/agtoosa-spec` | Research → 6 forcing questions → Executable Specification → STRIDE threat model | `research` · `plan` · `quick` |
| `/agtoosa-build` | Break spec into atomic tasks → TDD Red-Green-Refactor → full test suite + SAST/DAST | `scope` · `tdd` · `test` |
| `/agtoosa-qa` | Plan → run → report → triage: unit, integration, E2E, browser, a11y, performance | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | 4-persona parallel review (Security · Arch · Product · QA) + Simplifier pass | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship` | Pre-flight → deploy → archive spec → update changelog → suggest next story | `check` · `docs` · `retro` |
| `/agtoosa-revert` | Git-aware logical rollback by phase or commit | _(phase or commit)_ |

### Typical workflow
```
/agtoosa-init          (once per project)
/agtoosa-spec          → /agtoosa-build → /agtoosa-qa → /agtoosa-review → /agtoosa-ship
```

### Key files
- `Docs/Master-Plan.md` — workspace mirror of Linear project state
- `Docs/Context/` — product, tech-stack, and workflow configuration
- `Docs/archived/` — completed specs and plans
- `Docs/AgToosa_Changelog.md` — auto-maintained changelog
