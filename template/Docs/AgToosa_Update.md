# AgToosa /agtoosa-update

Detect whether the installed AgToosa baseline is behind, plan the update, get explicit approval, run the real CLI update, and verify the result. A read-only `check` mode remains available for project briefings only.

## Sub-Commands

| Sub-command | Runs | stop condition |
|-------------|------|----------------|
| `/agtoosa-update` | Full flow: Detect → Plan → ask-then-apply → Apply → Verify | Stops after Verify summary, or after Plan when already current |
| `/agtoosa-update check` | Detect only + project briefing | **Read-only** — no shell commands, no mutation |
| `/agtoosa-update plan` | Detect + Plan | No mutation — stops after update plan and preflight |
| `/agtoosa-update apply` | Detect + Plan + approval + Apply + Verify | Stops after Verify, or when user declines Apply |
| `/agtoosa-update verify` | Verify only (post-update) | No Apply — stops after verification report |

## When to Run

- The project may be behind the latest AgToosa workflow baseline
- Resuming work after a break and need project context (`check`)
- Starting a new session before `/agtoosa-spec` or `/agtoosa-build`
- After upgrading the generator and need the installed project synced

## Default Contract

The default `/agtoosa-update` flow is **Detect → Plan → Apply → Verify** with **ask-then-apply** when drift is detected. The agent orchestrates preflight and approval; **file mutation is delegated to the CLI** — do not hand-edit workflow files in place of `agtoosa.sh --update`.

## Workflow

### Stage 1 — Detect

Stage 1 runs in two passes: **operating context first**, then **installed state** only for downstream (Generated Project) repos.

#### Stage 1a — Operating context (always first)

Classify the repo **before** version drift or Apply planning:

| Signal | Maintainer Dogfood | Generated Project |
|--------|-------------------|-------------------|
| Maintainer guide at repo root | `docs/agtoosa-maintainer.md` present (generator repo) | Absent |
| Generator surfaces | `agtoosa.sh`, `lib/`, `template/` at repo root | Absent |
| Install version marker | Do **not** treat `Docs/.agtoosa-version` here as a downstream install | `Docs/.agtoosa-version` expected when installed |

When **Maintainer Dogfood Mode** is detected:

- **Stop before Apply.** Do not ask for a downstream project path defaulting to `.` or the current repo.
- **Do not run** `bash agtoosa.sh --update` against this tree (the CLI blocks self-target; the workflow must not plan Apply anyway).
- Print the **Maintainer Dogfood report** (below) and **stop** for full flow, `plan`, and `apply`.
- For **`check`**, you may include dogfood context in the briefing, then **stop** (still read-only).

**Maintainer Dogfood report (required when 1a matches):**

```
## AgToosa Update — Maintainer Dogfood Mode

**Operating context:** Maintainer Dogfood Mode (AgToosa generator repo)
**CLI baseline update:** Not available for this source tree (`agtoosa.sh --update` targets downstream installs only).

Do not create `Docs/` or `Docs/.agtoosa-version` in the generator repo.

**Next actions:**
- `/agtoosa-status` — project health for AgToosa development
- `/agtoosa-spec` or `/agtoosa-build` — maintainer stories in `docs/Master-Plan.md`
- Re-run `/agtoosa-update` only against an explicit downstream project path (not the generator repo)
```

When **Generated Project Mode** is detected, continue to Stage 1b.

#### Stage 1b — Installed state (Generated Project only)

Gather installed project state without mutating files (read-only file reads and inspection only):

1. **Installed version** — read `Docs/.agtoosa-version` if present; note `unknown` when missing.
2. **Lock metadata** — read `.agtoosa-lock.json` when present (generator version, platforms, template hash).
3. **Platform sentinels** — note which entry points exist (`CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `.github/copilot-instructions.md`, `OPENCODE.md`, etc.).
4. **Project context** — read all files in `Docs/Context/` (`product.md`, `tech-stack.md`, `workflow.md`, `product-guidelines.md`).
5. **Architecture memory** — read `Docs/Master-Architecture.md` as high-priority architecture memory: system boundaries, diagrams, data flow, deployment, security, and observability. Note whether it exists and is non-empty; preserve user-authored content on update.
6. **Master-Plan** — read `Docs/Master-Plan.md` (Project Charter, active cycle, In Progress stories, blocked items, recent ships).
7. **Changelog** — read `Docs/AgToosa_Changelog.md` (last 1–2 releases).
8. **Active specs** — list non-archived specs under `Docs/archived/`; note status and Goal Contract.
9. **Drift** — compare installed version to the target baseline the user intends (from generator checkout, lock file, or stated version). If already current, skip Apply.

For **`/agtoosa-update check`** in Generated Project Mode, continue to the briefing below and **stop**. Do not run shell commands or mutate files.

### Stage 2 — Plan

> **Maintainer Dogfood:** Skip Stage 2–4 unless the user provided an explicit downstream project path outside the generator repo. Default dogfood flow stops after Stage 1a.

When drift exists or the user invoked `plan` or `apply` in **Generated Project Mode**, produce an **update plan** that lists planned **overwrites**, **smart merge** targets, **native dir** refreshes, **preserved files**, and expected **backup** files:


| Planned action | Detail |
|----------------|--------|
| CLI command | `bash agtoosa.sh --update <project>` (or repo-appropriate path to the generator) |
| Workflow doc overwrites | `Docs/AgToosa_*.md` files the CLI will refresh |
| Platform entry points | Smart merge for `CLAUDE.md`, `.cursorrules`, `AGENTS.md`, `.github/copilot-instructions.md`, `OPENCODE.md` when installed |
| Native dir refreshes | `.claude/commands/`, `.cursor/rules/`, `.gemini/commands/`, etc. — AgToosa-owned files only |
| Version / lock metadata | `Docs/.agtoosa-version` and `.agtoosa-lock.json` when applicable |
| Preserved files | `Docs/Context/`, `Docs/Master-Plan.md`, `Docs/AgToosa_Changelog.md`, `Docs/archived/`, user files in platform dirs |
| Backups | `.bak` files the CLI may create on force merge paths |

**Preflight risks (report before Apply):** Surface any of the following and recommend `bash agtoosa.sh --update --dry-run <project>` or manual review when appropriate:

- **dirty git** state — uncommitted changes may be overwritten or conflict with merges
- **malformed** AgToosa markers — broken `<!-- AgToosa START -->` / `END` blocks in entry points
- **Existing backup files** — prior `.bak` files from forced merges
- **missing `Docs/`** — project not initialized for AgToosa
- **lock-file** issues — missing, stale, or mismatched `.agtoosa-lock.json`
- **platform drift** — sentinels present but native dirs missing or partial
- **major-version migration** risk — installed major version behind target; breaking workflow changes likely

**Migration guidance (before Apply):** When **major-version** drift or **breaking change** entries appear in the generator `CHANGELOG.md` or release notes relative to the installed version, summarize what the user should expect (new commands, renamed docs, merge behavior) and point to the relevant changelog section **before Apply**.

If the user invoked **`plan` only**, print the plan and preflight, then **stop** (no mutation).

### Stage 3 — Apply (approval gate)

> **Explicit approval required:** Ask for explicit approval **before running any mutating** shell command (e.g. "yes, apply the update", "approve apply").

When approved (or when running full `/agtoosa-update` and the user confirms at the gate):

1. Run the CLI update as the **source of truth**:
   ```bash
   bash agtoosa.sh --update <project-path>
   ```
   Use `--dry-run` first when preflight flagged high risk and the user has not yet seen the dry-run output.

2. **Forbidden:** Hand-copying individual template files, editing workflow docs manually, or syncing without the CLI when the goal is a baseline update.

If the user declines Apply, print the plan and **stop** without mutation.

### Stage 4 — Verify

After Apply (or when the user invoked **`verify` only** on an already-updated project), confirm:

| Check | What to verify |
|-------|----------------|
| Version marker | `Docs/.agtoosa-version` exists and matches expected target |
| Lock metadata | `.agtoosa-lock.json` present and consistent when lock was used at install |
| Platform surfaces | Installed entry points and native dirs contain expected AgToosa commands/rules |
| Preserved files | `Docs/Context/`, `Docs/Master-Plan.md`, `Docs/AgToosa_Changelog.md`, `Docs/archived/` unchanged |
| duplicate marker safety | Platform entry points contain a single `<!-- AgToosa START -->` … `END` block (no duplicate injection) |

Report filenames and pass/fail status only — do not dump secrets, tokens, or full config values.

If verification fails, list failures with **Fix with:** `bash agtoosa.sh --update <project>` or manual review; do not claim success.

### Stage 4b — Specialist materialization (optional, separate approval)

After Stage 4 Verify succeeds on the **full** or **`apply`** flow (Generated Project Mode only):

1. Run **Specialist Compatibility Check** (read-only) against `Docs/Context/specialists.md` and installed native specialist files — see below.
2. If gaps exist (roster entry without native file, stale platform target, missing `Docs/AgToosa_Specialists.md`), propose materialization or refresh in a **separate** approval gate.
3. **Forbidden:** Applying specialist writes during baseline `agtoosa.sh --update` or without explicit user approval after Verify.
4. Record Approve / Decline in `Docs/Master-Plan.md` **Update Log**.

Maintainer Dogfood Mode: skip specialist materialization; CLI update is unavailable for the generator repo anyway.

### Stage 4c — Optional Hook Automation Pack (preview + approval)

Separate from baseline CLI update. See `Docs/AgToosa_Hooks.md`.

1. Prepare a **HookInstallPreview** listing `affected_files`, merge intent, `existing_entries_preserved`, `entries_added`, `entries_deduplicated`, and `removal_steps`.
2. Require **explicit user approval** before any hook-related write. **No silent hook install.**
3. On **decline**: **does not write**; pack absence leaves `/agtoosa-status` and verifier health unchanged.
4. On **approval**: preserve unrelated settings; deduplicate AgToosa hook entries by command string via CLI `merge_settings_json` behavior when Claude settings are in scope.
5. Documented **removal** path lives in `Docs/AgToosa_Hooks.md` (remove listed AgToosa commands; leave unrelated settings intact).

## Specialist Compatibility Check (read-only)

Run during **`check`**, **`plan`**, and Stage 4 Verify summary. Follow `Docs/AgToosa_Specialists.md`.

| Check | Pass criteria |
|-------|----------------|
| Canonical doc | `Docs/AgToosa_Specialists.md` present at expected version |
| Roster | `Docs/Context/specialists.md` entries match approved ids (if file exists) |
| Native files | Each approved id has files on installed platforms per platform_targets |
| Stale support | No `agtoosa-*` specialist ids; no orphaned specialist files without roster entry |
| CLI safety | `agtoosa.sh --update` inventory does not list project specialist paths |

Report **missing**, **stale**, or **ok** per specialist id — do not mutate files in `check` or `plan`.

## `/agtoosa-update check` — Project Briefing (read-only)

After Detect, produce a concise briefing (no shell commands, no mutation):

```
## Project Update

**Product:** [one-line summary from product.md]
**Stack:** [key stack items from tech-stack.md]

**Installed AgToosa:** [version from Docs/.agtoosa-version or unknown]
**Drift:** [behind / current / unknown]

**Active cycle:** [cycle name/goal from Master-Plan]
**In Progress:** [active stories/tasks]
**Blocked:** [blocked items or "none"]
**Recently shipped:** [last release from Changelog]

**Open specs:** [non-archived specs and status]
**Goal summary:** [project/story goal and success condition, or "missing"]
**Architecture summary:** [key boundaries from Master-Architecture, or "missing"]

**Context gaps:** [missing Context files — suggest /agtoosa-init if significant]
**Goal clarity gaps:** [missing/vague Goal Contract fields — suggest /agtoosa-goal]
```

End with:

> Ready. Which command do you want to run — `/agtoosa-update` (apply baseline), `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-qa`, `/agtoosa-review`, or `/agtoosa-ship`?

**Stop here** for `check` — do not proceed to Plan, Apply, or Verify.

## What the CLI Updates vs Preserves

| Category | Action |
|----------|--------|
| `Docs/AgToosa_*.md` workflow files | Overwritten with latest version |
| Platform entry-points (`CLAUDE.md`, `.cursorrules`, etc.) | Smart merge — only if already installed |
| Platform native dirs (`.claude/commands/`, `.cursor/rules/`, etc.) | Overwritten — AgToosa-owned files only |
| `.claude/settings.json` hooks | Deep-merged, deduplicated |

| Category | Action |
|----------|--------|
| `Docs/Context/` | Never touched |
| `Docs/Master-Architecture.md` | Preserved — user-authored architecture memory |
| `Docs/Master-Plan.md` | Never touched |
| `Docs/AgToosa_Changelog.md` | Never touched |
| `Docs/archived/` | Never touched |
| `Docs/Context/specialists.md` | Never touched — project-approved roster |
| Project specialist native files | Never touched — `.codex/skills/<project-id>/`, `.claude/skills/<project-id>.md`, `.github/agents/<project-id>.agent.md`, platform specialist fallbacks |
| User files in platform dirs | Never touched |

## Output

On successful completion of the full flow or `apply`, print verbatim:

`✅ Done. Run /agtoosa-status to verify findings cleared.`
