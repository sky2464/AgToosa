# Extension Authoring Guide: Adding a New AI Platform to AgToosa

This guide explains how to wire a new AI platform into AgToosa so users can select it
during `bash agtoosa.sh` and receive the correct entry-point files for their project.

**OpenCode** is used as the worked example throughout — it is the most recently added
platform and represents the minimum-viable wiring path.

---

## Overview

Adding a new platform requires changes to four places:

1. `template/` — the entry-point file(s) that land in the user's project
2. `lib/config.sh` — file lists that control staging
3. `lib/generate.sh` — the staging logic that copies files into `ship/`
4. `agtoosa.sh` — the interactive menu + flag + copy-to-project logic

There is no "plugin registry" — all platforms are hardcoded in these four locations.
Follow the exact pattern of an existing platform to avoid edge-case bugs.

---

## Step 1: Create the Template Entry-Point File

Create the file that will land in the user's project root (or platform-specific directory).
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

**OpenCode example:** `template/OPENCODE.md` — a single file dropped at the project root.
No subdirectory config files were needed because OpenCode reads `OPENCODE.md` by convention.

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
  "OPENCODE.md"                        # OpenCode entry-point
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

For OpenCode (single-file platform), no additional array was needed.

---

## Step 3: Add Staging Logic to `lib/generate.sh`

`generate.sh`'s `stage_files()` function copies files from `template/` into `ship/`.
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

**OpenCode example** (verbatim from `generate.sh`):

```bash
if [[ "$USE_OPENCODE" == true ]]; then
  local opencode_count=0
  if [[ -f "${TEMPLATE_DIR}/OPENCODE.md" ]]; then
    inject_version "${TEMPLATE_DIR}/OPENCODE.md" "${SHIP_DIR}/OPENCODE.md"
    opencode_count=$((opencode_count + 1))
  fi
  if [[ $opencode_count -gt 0 ]]; then
    echo -e "  ${GREEN}✅${NC} OPENCODE.md ${CYAN}(OpenCode)${NC}"
    GENERATED=$((GENERATED + opencode_count))
  fi
fi
```

---

## Step 4: Wire the Flag and Menu in `agtoosa.sh`

Four locations in `agtoosa.sh` need updating:

### 4a. Initialize the flag

In the flags block (search for `USE_GEMINI=false`), add:

```bash
USE_NEWPLATFORM=false
```

### 4b. Set the flag in the "all platforms" shortcut

When the user selects all platforms (option `1`), enable yours:

```bash
USE_GEMINI=true; USE_COPILOT=true; USE_OPENCODE=true; USE_VSCODE=true; USE_NEWPLATFORM=true
```

### 4c. Add the numbered menu entry

In the `echo` block that prints the platform selection menu:

```bash
echo "  8) NewPlatform"
```

> **Note:** The next available number at time of writing is 8 (OpenCode is 7).
> Verify the current list before assigning a number.

### 4d. Parse the selection

In the selection-parsing block (search for `[[ "$SELECTION" == *"7"* ]]`), add:

```bash
[[ "$SELECTION" == *"8"* ]] && USE_NEWPLATFORM=true
```

### 4e. Add to the at-least-one-platform guard

In the validation block (search for `"$USE_OPENCODE" == true`), add your platform:

```bash
"$USE_OPENCODE" == true || "$USE_NEWPLATFORM" == true || \
```

### 4f. Add the copy-to-project block

In `_install_files()` or the equivalent per-platform copy section, add:

```bash
if [[ "$USE_NEWPLATFORM" == true ]]; then
  local np_src="${SHIP_DIR}/NEWPLATFORM.md"
  if [[ -f "$np_src" ]]; then
    copy_platform_file "$np_src" "${PROJECT_PATH}/NEWPLATFORM.md" "NEWPLATFORM.md"
  fi
fi
```

Use `copy_platform_file` for files that should be skipped if they already exist.
Use `merge_platform_file` for files that need safe appending into an existing user file.

---

## Step 5: Add to `agtoosa.sh --platform-names` (if implemented)

If the `--platform-names` or `--list-template-files` flags enumerate platforms, add
`"newplatform"` to those lists (search for `"opencode"` to find all relevant spots).

---

## Step 6: Write a Bats Test

Add at least one smoke test to `tests/agtoosa.bats`. Minimum coverage:

```bash
@test "generates NEWPLATFORM.md when platform 8 selected" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  printf '8\n%s\n' "$tmpdir" | run bash "$BATS_TEST_DIRNAME/../agtoosa.sh"
  [[ -f "${tmpdir}/NEWPLATFORM.md" ]]
  rm -rf "$tmpdir"
}
```

Run the suite to confirm no regressions:

```bash
bats tests/agtoosa.bats
```

---

## Checklist

- [ ] `template/NEWPLATFORM.md` — entry-point file created, functionally equivalent to existing platforms
- [ ] `lib/config.sh` — file added to `OPTIONAL_TEMPLATE_FILES`
- [ ] `lib/generate.sh` — `stage_files()` block added with `inject_version`
- [ ] `agtoosa.sh` — flag initialized, "all" shortcut updated, menu entry added, selection parsed, guard updated, copy block added
- [ ] `tests/agtoosa.bats` — smoke test added and passing
- [ ] `CHANGELOG.md` — entry added under `## [Unreleased]` or the active version section

---

## Reference: Platform File Locations

| Platform | Entry-point file | Platform-specific doc | Additional dirs |
|----------|-----------------|----------------------|----------------|
| Claude Code | `CLAUDE.md` | `Docs/AgToosa_Claude.md` | `.claude/commands/`, `.claude/skills/`, `.claude/hooks/` |
| Cursor | `.cursorrules` | _(none)_ | `.cursor/rules/` |
| Windsurf | `.windsurfrules` | _(none)_ | `.windsurf/rules/` |
| Gemini CLI | `AGENTS.md` | `Docs/AgToosa_Gemini.md` | `.gemini/commands/` |
| GitHub Copilot | `.github/copilot-instructions.md` | _(none)_ | `.github/instructions/`, `.github/prompts/` |
| OpenCode | `OPENCODE.md` | _(none)_ | _(none)_ |
