# AgToosa Self-Update — Design Spec

**Date:** 2026-04-28
**Status:** Approved

---

## Problem

Every AgToosa install is frozen at the version it was installed at. When workflow files improve, new commands ship, or platform configs are refined, existing users get none of it unless they manually re-run the full interactive installer. At the current iteration pace (3 major versions in a week), this compounds quickly. The merge infrastructure to fix it already exists — it just isn't wired to an update mode.

---

## Architecture

Three components, all building on existing infrastructure:

```
agtoosa.sh --update <path>          ← new CLI flag (skips interactive wizard)
      │
      └─► lib/update.sh             ← new lib module: run_update()
                │
                ├─ detect installed platforms (sentinel file existence)
                ├─ overwrite AgToosa-owned Docs/*.md
                ├─ merge_platform_file() on detected entry-points
                ├─ overwrite platform native dirs (.claude/commands/, etc.)
                └─ write Docs/.agtoosa-version

Docs/AgToosa_Update.md              ← in-IDE /agtoosa-update command
      │
      └─ reads Docs/.agtoosa-version → shows installed version
      └─ guides user to run CLI update → confirms success
      └─ surfaces changelog diff between versions
```

The full install wizard (`agtoosa.sh` with no flags) is unchanged.

---

## What Gets Updated vs. Preserved

| Category | Examples | Action |
|----------|----------|--------|
| AgToosa workflow files | `Docs/AgToosa_*.md` | Always overwrite |
| Platform entry-points | `CLAUDE.md`, `.cursorrules`, `AGENTS.md` | `merge_platform_file()` — only if already present in target |
| Platform native dirs | `.claude/commands/`, `.cursor/rules/`, `.gemini/commands/` | Overwrite all files — only if dir already present |
| `.claude/settings.json` | — | `merge_settings_json()` — deduplicates hooks |
| User-owned docs | `Docs/Context/`, `Docs/Master-Plan.md`, `Docs/AgToosa_Changelog.md`, `Docs/archived/` | Never touch |
| Version marker | `Docs/.agtoosa-version` | Write `AGTOOSA_VERSION` after successful update |

---

## Components

### `agtoosa.sh --update <path>`

New flag in the existing arg-loop. When set, skips the interactive wizard and calls `run_update()`. Path can be passed as the flag argument or prompted with the same single-line prompt used in install mode.

```
1. Validate path exists + not AgToosa source dir (reuse existing guards)
2. Read installed version from <path>/Docs/.agtoosa-version (or "unknown")
3. Print banner: "Updating AgToosa v{old} → v{new} in <path>"
4. Call run_update()
5. Write AGTOOSA_VERSION to <path>/Docs/.agtoosa-version
6. Print summary report
```

### `lib/update.sh` — `run_update()`

```
run_update()
  Step 1: Update workflow files
    For each file in DOCS_FILES:
      if file == Docs/Master-Plan.md or Docs/AgToosa_Changelog.md → skip
      else → cp template/<file> to <path>/<file> (plain overwrite)

  Step 2: Detect + update platform entry-points
    PLATFORM_SENTINELS:
      cursor    → .cursorrules
      windsurf  → .windsurfrules
      claude    → CLAUDE.md
      gemini    → AGENTS.md
      copilot   → .github/copilot-instructions.md
      roo       → .roorules
      opencode  → OPENCODE.md
    For each sentinel: if exists in <path> → merge_platform_file()

  Step 3: Update platform native dirs
    For each dir (.claude/commands/, .cursor/rules/, .gemini/commands/,
                  .windsurf/rules/, .roo/rules/, .github/prompts/, etc.):
      if dir exists in <path> → overwrite only files that exist in AgToosa's
      known file lists (CLAUDE_COMMAND_FILES, CURSOR_RULE_FILES, etc.)
      Never delete or touch files not in those lists (user's own commands)

  Step 4: Update .claude/settings.json (if present)
    → merge_settings_json()
```

### `Docs/AgToosa_Update.md`

One-page workflow file wired to `/agtoosa-update` in all 7 platform entry-point files and `Docs/AgToosa_Agent.md`. Reads `Docs/.agtoosa-version`, shows installed vs. current version, surfaces relevant changelog entries, guides user to run `bash agtoosa.sh --update .` from their project root, and confirms the update after the user reports it ran.

### Summary Report (stdout)

```
✅ AgToosa updated v2.3.0 → v2.5.0

  Workflow files updated : 10
  Platform files merged  : 3  (claude, cursor, gemini)
  Platform dirs updated  : 3
  Context/ preserved     : ✅ (4 files untouched)
  Backups created        : 2  (.bak.* in project root)

  Changes since v2.3.0:
    [2.5.0] ...
    [2.4.0] ...

Run /agtoosa-update inside your AI assistant to see the full changelog.
```

---

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Path does not exist | Exit 1: "Directory '...' does not exist" (reuse existing guard) |
| Path is AgToosa source dir | Exit 1: "Target path cannot be the AgToosa source directory" (reuse existing guard) |
| No `Docs/` directory in target | Exit 1: "No Docs/ directory found. Run full install first: bash agtoosa.sh <path>" |
| `Docs/AgToosa_Agent.md` missing | Warn "workflow files not found, running full update anyway" — proceed |
| `Docs/.agtoosa-version` missing | Treat installed version as "unknown" — proceed, write version at end |
| `merge_platform_file()` backup fails | Existing warning + skip behavior — unchanged |
| `merge_settings_json()` fails | Existing skip + warning behavior — unchanged |
| Changelog extraction fails | Skip changelog section in summary — non-blocking |
| `--update` + `--dry-run` | Run `print_dryrun_preview()` scoped to detected platforms + note workflow files would overwrite — no files written |
| `--update` + `--force` | `FORCE=true` flows through to `merge_platform_file()` — force-replaces user-owned entry-points |

---

## Testing

All tests in `tests/agtoosa.bats`.

### Core behavior

| Test | Assertion |
|------|-----------|
| `--update` on path with no `Docs/` exits with error | exit non-zero, "No Docs/ directory" in output |
| `--update` updates workflow files | `Docs/AgToosa_Agent.md` contains current version content |
| `--update` preserves `Docs/Context/` | custom content in `tech-stack.md` unchanged |
| `--update` preserves `Docs/Master-Plan.md` | user content unchanged |
| `--update` preserves `Docs/AgToosa_Changelog.md` | user content unchanged |
| `--update` detects installed Claude and merges | `CLAUDE.md` START/END block upgraded, `.bak.*` created |
| `--update` skips non-installed platform | no `.cursorrules` created if absent before update |
| `--update` writes `Docs/.agtoosa-version` | file contains `AGTOOSA_VERSION` after run |
| `--update` shows version transition in output | output contains "v{old} → v{new}" |
| Unknown prior version shows "unknown →" | output contains "unknown →" |
| `--update --dry-run` writes no files | no files modified, output contains "DRY RUN" |
| `--update --force` replaces user-owned entry-point | `.bak.*` created, file replaced |
| `--update` on AgToosa source dir blocked | exit 1, "cannot be the AgToosa source directory" |

### Wiring

| Test | Assertion |
|------|-----------|
| All 7 platform entry-points include `/agtoosa-update` | `grep -r "agtoosa-update"` hits all files |
| `AgToosa_Update.md` in `DOCS_FILES` array | present in `lib/config.sh` |

### Regression

Install a workflow file with an older AgToosa version marker, run `--update`, confirm the file now contains the new version marker. Must fail on old content, pass after update.

---

## Files Changed

| File | Change |
|------|--------|
| `agtoosa.sh` | Add `--update` flag parsing; call `run_update()` when set |
| `lib/update.sh` | New file: `run_update()`, `detect_installed_platforms()`, `read_installed_version()`, `print_update_summary()` |
| `lib/config.sh` | Add `AgToosa_Update.md` to `DOCS_FILES`; add `PLATFORM_SENTINELS` map |
| `template/Docs/AgToosa_Update.md` | New workflow file for `/agtoosa-update` in-IDE command |
| `template/CLAUDE.md` | Add `/agtoosa-update` row to command table |
| `template/.cursorrules` | Add `/agtoosa-update` row |
| `template/AGENTS.md` | Add `/agtoosa-update` row |
| `template/.windsurfrules` | Add `/agtoosa-update` row |
| `template/.roorules` | Add `/agtoosa-update` row |
| `template/OPENCODE.md` | Add `/agtoosa-update` row |
| `template/.github/copilot-instructions.md` | Add `/agtoosa-update` row |
| `template/Docs/AgToosa_Agent.md` | Add `/agtoosa-update` to utility commands table |
| `tests/agtoosa.bats` | Add ~15 new tests |
