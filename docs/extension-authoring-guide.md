# Extension Authoring Guide: Adding a New AI Platform to AgToosa

This guide is the **canonical** maintainer handbook for wiring a new AI platform into AgToosa so users can select it during `bash agtoosa.sh` (or `agtoosa.ps1`) and receive the correct entry-point files.

**OpenCode / Codex** is used as the worked example for the single-file + `.codex/` skill/prompt path. **Claude Code** remains the richest multi-surface example (commands, skills, hooks). Follow an existing platform’s pattern to avoid edge-case bugs.

---

## Overview

Adding a new platform requires changes in these generator surfaces:

1. `template/` — entry-point file(s) and any platform adapter dirs that land in the user’s project
2. `lib/config.sh` — file lists that control staging, `--list-template-files`, and update inventory (`OPTIONAL_TEMPLATE_FILES` plus platform arrays)
3. `lib/generate.sh` — `stage_files()` logic that copies into `ship/`
4. `agtoosa.sh` — interactive menu, `--platforms` tokens, flags, and copy-to-project logic (`agtoosa.ps1` for Windows parity)

There is no plugin registry for platforms — they are hardcoded in these locations.

### Currently supported platforms (parity inventory)

| Platform | Menu / `--platforms` token | Entry-point / primary surface | Additional adapter dirs |
|----------|----------------------------|-------------------------------|-------------------------|
| Cursor | `cursor` (1) | `.cursorrules` | `.cursor/rules/`, `.cursor/commands/` |
| Windsurf | `windsurf` (2) | `.windsurfrules` | `.windsurf/rules/`, `.windsurf/workflows/` |
| Claude Code | `claude` (3) | `CLAUDE.md` | `.claude/commands/`, `.claude/skills/`, `.claude/hooks/`, `Docs/AgToosa_Claude.md` |
| Gemini CLI | `gemini` (4) | `AGENTS.md` | `.gemini/commands/`, `Docs/AgToosa_Gemini.md` |
| GitHub Copilot | `copilot` (5) | `.github/copilot-instructions.md` | `.github/prompts/`, `.github/agents/`, `.github/instructions/` |
| VS Code (generic) | `vscode` (6) | same Copilot instruction/prompt/agent set when Copilot is not also selected | `.github/prompts/`, `.github/agents/`, `.github/instructions/` |
| Codex / OpenCode / Other | `codex` / `opencode` / `other` (7) | `OPENCODE.md` | `.codex/skills/`, `.codex/prompts/` |

**Parity checks** (required before claiming a platform is complete):

- [ ] Template files exist under `template/` and are registered in `OPTIONAL_TEMPLATE_FILES` (and any platform-specific arrays in `lib/config.sh`)
- [ ] `lib/generate.sh` `stage_files()` stages the platform when its `USE_*` flag is true
- [ ] `agtoosa.sh` flag, menu digit, `--platforms` token, “all” shortcut, and install/copy path are wired; PowerShell mirrors non-interactive switches when applicable
- [ ] Focused smoke coverage exists in `tests/agtoosa.bats` (install generates expected paths)
- [ ] Entry-point instructs the AI to read `Docs/AgToosa_Agent.md` first and lists core slash commands

**Enforcement honesty:** repository bats and inventory checks are **CI-enforced** when CI runs them. Generator staging is **generator-enforced**. Following this guide while authoring is **agent-instructed / manual**. Marketplace or auto-discovered platform plugins remain **roadmap** (out of scope here).

---

## Step 1: Create the Template Entry-Point File

Create the file that will land in the user’s project root (or platform-specific directory).
At minimum, it must:

- Instruct the AI to read `Docs/AgToosa_Agent.md` first
- List the six core slash commands with their workflow files

**File:** `template/NEWPLATFORM.md`

```markdown
# AgToosa — NewPlatform Instructions

You are acting as an autonomous Agentic AI PM and Senior Engineer utilizing the **AgToosa** framework.

## Critical First Step

Before beginning any task, read and follow `Docs/AgToosa_Agent.md` for core rules, principles,
and security requirements.

## Core Commands

| Command | Workflow File | Sub-commands |
|---------|--------------|--------------|
| `/agtoosa-init`   | `Docs/AgToosa_Init.md`   | `zoom-out` |
| `/agtoosa-spec`   | `Docs/AgToosa_Spec.md`   | `research` · `plan` · `quick` · `tasks` · `amend` |
| `/agtoosa-build`  | `Docs/AgToosa_Build.md`  | `tdd` · `test` |
| `/agtoosa-qa`     | `Docs/AgToosa_QA.md`     | `plan` · `run` · `report` · `triage` |
| `/agtoosa-review` | `Docs/AgToosa_Review.md` | `security` · `arch` · `debug` · `cross` |
| `/agtoosa-ship`   | `Docs/AgToosa_Ship.md`   | `check` · `docs` · `retro` |
```

Keep the entry-point file functionally equivalent to `CLAUDE.md`, `AGENTS.md`, and
`OPENCODE.md` — do not add platform-specific workflow variations here. Variations belong
in a separate `Docs/AgToosa_NewPlatform.md` file (see Claude and Gemini for examples).

**Maintained examples:**

- OpenCode / Codex: `template/OPENCODE.md` plus `.codex/skills/` and `.codex/prompts/`
- Claude Code: `template/CLAUDE.md` plus `.claude/commands/`, skills, and hooks
- Cursor: `template/.cursorrules` plus `.cursor/rules/` and `.cursor/commands/`

---

## Step 2: Add to `lib/config.sh`

`config.sh` declares the file lists that `generate.sh` uses to stage files.

**Two actions required:**

### 2a. Add to `OPTIONAL_TEMPLATE_FILES`

This array controls the `--list-template-files` flag and the update checker. Add your
entry-point file (and any platform-specific Docs file if applicable):

```bash
OPTIONAL_TEMPLATE_FILES=(
  ...
  "OPENCODE.md"                        # OpenCode / Codex entry-point
  "NEWPLATFORM.md"                     # ← add this line
  "Docs/AgToosa_NewPlatform.md"        # ← add if you have a platform-specific doc
  ...
)
```

### 2b. Add a platform-specific file array (only if needed)

If the platform requires additional files (commands, rules, hooks), declare a named array:

```bash
# example pattern from Claude Code:
CLAUDE_COMMAND_FILES=(
  ".claude/commands/agtoosa-init.md"
  ...
)
```

For a single-file platform with no extra adapters, no additional array is required.
OpenCode/Codex uses shared Codex skill/prompt arrays staged when `USE_OPENCODE` is true.

---

## Step 3: Add Staging Logic to `lib/generate.sh`

`generate.sh`’s `stage_files()` function copies files from `template/` into `ship/`.
Add a block for your platform following the existing pattern:

```bash
if [[ "$USE_NEWPLATFORM" == true ]]; then
  local np_count=0
  if [[ -f "${TEMPLATE_DIR}/NEWPLATFORM.md" ]]; then
    inject_version "${TEMPLATE_DIR}/NEWPLATFORM.md" "${SHIP_DIR}/NEWPLATFORM.md"
    np_count=$((np_count + 1))
  fi
  if [[ $np_count -gt 0 ]]; then
    echo -e "  ${GREEN}✅${NC} NEWPLATFORM.md ${CYAN}(NewPlatform)${NC}"
    GENERATED=$((GENERATED + np_count))
  fi
fi
```

Use `inject_version` (not `cp`) for the main entry-point file — this stamps the
`AGTOOSA_VERSION` string into the file for use by the update checker.

**OpenCode / Codex example** (see `generate.sh`): stages `OPENCODE.md`, then `.codex/skills/` and `.codex/prompts/`.

**VS Code example:** when `USE_VSCODE` is true and Copilot is not selected, stages the shared `.github/copilot-instructions.md`, prompts, agents, and instructions (same family as Copilot).

---

## Step 4: Wire the Flag and Menu in `agtoosa.sh`

Locations in `agtoosa.sh` that need updating (verify current digits before assigning a new one):

### 4a. Initialize the flag

In the flags block (search for `USE_GEMINI=false`), add:

```bash
USE_NEWPLATFORM=false
```

### 4b. Set the flag in the "all platforms" shortcut

When the user selects all platforms (option `1` / `all`), enable yours alongside Cursor, Windsurf, Claude, Gemini, Copilot, OpenCode, and VS Code.

### 4c. Add the numbered menu entry

In the `echo` block that prints the platform selection menu, add the next free digit.
Current menu at time of writing: 1 Cursor · 2 Windsurf · 3 Claude · 4 Gemini · 5 Copilot · 6 VS Code · 7 Codex/OpenCode/Other.

### 4d. Parse the selection and `--platforms` tokens

Add a selection digit parse and a token in the non-interactive `--platforms` mapper (search for `opencode`).

### 4e. Add to the at-least-one-platform guard

Include `"$USE_NEWPLATFORM" == true` in the platform-selected validation.

### 4f. Add the copy-to-project block

In `_install_files()` / per-platform copy section, use `copy_platform_file` or `merge_platform_file` as appropriate for your surface.

---

## Step 5: Enumerate Platform Names

If `--platform-names` or `--list-template-files` enumerate platforms, add `"newplatform"` wherever `"opencode"` / `"vscode"` appear today.

---

## Step 6: Write a Bats Test

Add at least one smoke test to `tests/agtoosa.bats`. Minimum coverage:

```bash
@test "generates NEWPLATFORM.md when platform N selected" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  printf 'N\n%s\n' "$tmpdir" | run bash "$BATS_TEST_DIRNAME/../agtoosa.sh"
  [[ -f "${tmpdir}/NEWPLATFORM.md" ]]
  rm -rf "$tmpdir"
}
```

Run focused coverage first, then the suite when changing shared staging:

```bash
bats tests/agtoosa.bats -f "NEWPLATFORM|newplatform"
```

---

## Checklist

- [ ] `template/NEWPLATFORM.md` — entry-point created, functionally equivalent to existing platforms
- [ ] Platform adapter dirs (if any) registered in `lib/config.sh` arrays and `OPTIONAL_TEMPLATE_FILES`
- [ ] `lib/generate.sh` — `stage_files()` block added with `inject_version` where needed
- [ ] `agtoosa.sh` — flag, “all” shortcut, menu, selection, `--platforms` token, guard, copy block
- [ ] `tests/agtoosa.bats` — smoke test added and passing (parity)
- [ ] `CHANGELOG.md` — entry under `## [Unreleased]` or the active version section

---

## Reference: Platform File Locations

| Platform | Entry-point file | Platform-specific doc | Additional dirs |
|----------|-----------------|----------------------|----------------|
| Claude Code | `CLAUDE.md` | `Docs/AgToosa_Claude.md` | `.claude/commands/`, `.claude/skills/`, `.claude/hooks/` |
| Cursor | `.cursorrules` | _(none)_ | `.cursor/rules/`, `.cursor/commands/` |
| Windsurf | `.windsurfrules` | _(none)_ | `.windsurf/rules/`, `.windsurf/workflows/` |
| Gemini CLI | `AGENTS.md` | `Docs/AgToosa_Gemini.md` | `.gemini/commands/` |
| GitHub Copilot | `.github/copilot-instructions.md` | _(none)_ | `.github/instructions/`, `.github/prompts/`, `.github/agents/` |
| VS Code (generic) | `.github/copilot-instructions.md` | _(none)_ | same `.github/` family when Copilot is not selected |
| Codex / OpenCode / Other | `OPENCODE.md` | _(none)_ | `.codex/skills/`, `.codex/prompts/` |
