# AgToosa — Copilot Instructions

## What This Repo Is

AgToosa is a **framework generator** — a bash script plus a library of markdown workflow files. When a developer runs `bash agtoosa.sh`, it interactively collects their project path and AI platform preferences, then copies the appropriate markdown files into their project. There is no SDK or runtime in user projects; installation can be persistent (Homebrew) or one-time (bootstrap), but generated project output remains markdown/config only.

## Running the Generator

```bash
bash agtoosa.sh              # interactive mode
bash agtoosa.sh --force      # overwrite existing files in the target project
bash agtoosa.sh --version    # print version
bash agtoosa.sh --help       # show usage
```

`install.sh` is **deprecated** (v2.0) — it simply errors out and redirects to `agtoosa.sh`.

There is no automated test suite for this repo. To verify changes, run `bash agtoosa.sh` manually and confirm files are copied correctly to a test project directory.

## Architecture

```
agtoosa.sh          — Main interactive generator (the only entrypoint)
install.sh          — Deprecated stub; do not modify
template/           — The "product": all files that get copied to user projects
  Docs/             — Core workflow markdown files (AgToosa_Agent.md, AgToosa_Spec.md, etc.)
  .cursorrules      — Cursor platform entry point
  .windsurfrules    — Windsurf platform entry point
  CLAUDE.md         — Claude Code platform entry point
  AGENTS.md         — Gemini CLI / Jules platform entry point
  .github/
    copilot-instructions.md  — GitHub Copilot platform entry point
docs/               — Repo-level research/draft notes (not shipped to users)
```

`ship/` is a **temporary staging directory** created at the start of each `agtoosa.sh` run and deleted at the end. Never commit it.

## Repo Maintainer Mode

For changes to the AgToosa repository itself, use `.github/agents/agtoosa.agent.md` or read `docs/agtoosa-maintainer.md` directly.
That guide is the shared source of truth for the repo-maintainer persona across Copilot, Claude, Gemini, Cursor, and Windsurf.

## Key Conventions

### Version bumps
The canonical version lives in one place — the `AGTOOSA_VERSION` variable at the top of `agtoosa.sh`. Update it there and it propagates to `--version` output and the welcome banner.

### Adding a new AI platform
Three things are required:
1. Add a template file in `template/` (e.g., `template/NEWPLATFORM.md`)
2. Add a numbered selection option in the platform menu in `agtoosa.sh`
3. Add the corresponding `USE_NEWPLATFORM` flag, parse logic, copy-to-`ship/`, and copy-to-project blocks — following the exact same pattern as existing platforms

### Platform entry point pattern
All platform config files (`CLAUDE.md`, `.cursorrules`, `copilot-instructions.md`, etc.) follow the same minimal structure: tell the AI to read `Docs/AgToosa_Agent.md` first, then list the five slash commands mapping to their workflow files. Do not diverge from this pattern across platforms — they should stay functionally equivalent.

### Workflow files live in `template/Docs/`
`Docs/AgToosa_Agent.md` is the master rules file. The phase files (`AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`) define the 4-phase lifecycle. `AgToosa_Init.md` handles one-time setup. Changes to workflow behavior go in these files.

### `template/Docs/Context/` and `template/Docs/archived/`
These directories are created empty by `agtoosa.sh` (via `mkdir -p`) — they are not pre-populated in the template. `Context/` is populated by `/agtoosa-init` in the user's project. `archived/` is populated by `/agtoosa-ship`.

### Shell scripting style
`agtoosa.sh` uses `set -euo pipefail`. All user-facing messages use ANSI color variables (`RED`, `GREEN`, `YELLOW`, etc.) defined at the top of the script. The `NC` variable resets color. Follow this pattern for any new output lines.
