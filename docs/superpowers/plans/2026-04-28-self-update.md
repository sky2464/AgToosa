# AgToosa Self-Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `agtoosa.sh --update <path>` that refreshes workflow and platform files in an existing AgToosa install without touching user-owned content.

**Architecture:** A new `lib/update.sh` module handles platform detection, file updates, and the summary report. `agtoosa.sh` gets a new `--update` flag that routes to update mode before the interactive wizard. A new `template/Docs/AgToosa_Update.md` file wires `/agtoosa-update` into all AI assistants.

**Tech Stack:** Bash 3.2+, bats-core for tests. No new dependencies.

---

## File Map

| File | Change |
|------|--------|
| `lib/config.sh` | Add `"Docs/AgToosa_Update.md"` to `DOCS_FILES`; add `--update [path]` to `print_usage()` |
| `lib/update.sh` | **New.** `read_installed_version()`, `detect_installed_platforms()`, `update_native_dirs()`, `run_update()`, `print_update_summary()` |
| `agtoosa.sh` | Source `lib/update.sh`; add `UPDATE=false`/`UPDATE_PATH=""`; handle `--update` in flag loop; add update mode branch after source guard |
| `template/Docs/AgToosa_Update.md` | **New.** In-IDE `/agtoosa-update` workflow file |
| `template/CLAUDE.md` | Append `/agtoosa-update` to Optional utilities line |
| `template/.cursorrules` | Append `/agtoosa-update` to Optional utilities line |
| `template/AGENTS.md` | Append `/agtoosa-update` to Optional utilities line |
| `template/.windsurfrules` | Append `/agtoosa-update` to Optional utilities line |
| `template/.roorules` | Append `/agtoosa-update` to Optional utilities line |
| `template/OPENCODE.md` | Append `/agtoosa-update` to Optional utilities line |
| `template/.github/copilot-instructions.md` | Append `/agtoosa-update` to Optional utilities line |
| `template/Docs/AgToosa_Agent.md` | Add `/agtoosa-update` row to Utility Commands table |
| `tests/agtoosa.bats` | Add ~15 new tests |

---

## Task 1: Register `AgToosa_Update.md` in `lib/config.sh`

**Files:**
- Modify: `lib/config.sh`
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write the failing test**

Add to `tests/agtoosa.bats` after the existing `--list-template-files` or flag tests:

```bash
# ── Update wiring: AgToosa_Update.md in DOCS_FILES ───────────

@test "--list-template-files includes Docs/AgToosa_Update.md" {
  run bash "$SCRIPT" --list-template-files
  [ "$status" -eq 0 ]
  [[ "$output" == *"Docs/AgToosa_Update.md"* ]]
}
```

- [ ] **Step 2: Run to confirm it fails**

```bash
bats tests/agtoosa.bats --filter "list-template-files includes Docs/AgToosa_Update"
```

Expected: FAIL — `Docs/AgToosa_Update.md` not yet in the list.

- [ ] **Step 3: Add to `DOCS_FILES` in `lib/config.sh`**

In `lib/config.sh`, find the `DOCS_FILES` array and add the new entry (after `AgToosa_Skills.md`, before `Docs/Master-Plan.md`):

```bash
DOCS_FILES=(
  "Docs/AgToosa_Agent.md"
  "Docs/AgToosa_Init.md"
  "Docs/AgToosa_Spec.md"
  "Docs/AgToosa_Build.md"
  "Docs/AgToosa_Review.md"
  "Docs/AgToosa_Ship.md"
  "Docs/AgToosa_QA.md"
  "Docs/AgToosa_Revert.md"
  "Docs/AgToosa_Task.md"
  "Docs/AgToosa_Update.md"
  "Docs/AgToosa_Skills.md"
  "Docs/Master-Plan.md"
  "Docs/AgToosa_Changelog.md"
)
```

- [ ] **Step 4: Add `--update [path]` to `print_usage()` in `lib/config.sh`**

Find `print_usage()` and add the new option as the first entry:

```bash
print_usage() {
  echo "AgToosa Generator v${AGTOOSA_VERSION}"
  echo ""
  echo "Usage: bash agtoosa.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --update [path]        Update an existing AgToosa install (skips interactive wizard)"
  echo "  --force                Overwrite existing platform config files (creates .bak backups)"
  echo "  --dry-run              Show what would be copied without making changes"
  echo "  --list-template-files  Print every template file path and exit"
  echo "  --version              Print version and exit"
  echo "  --help                 Show this help message"
}
```

- [ ] **Step 5: Run test to confirm it passes**

```bash
bats tests/agtoosa.bats --filter "list-template-files includes Docs/AgToosa_Update"
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/config.sh tests/agtoosa.bats
git commit -m "feat: register AgToosa_Update.md in DOCS_FILES, add --update to usage"
```

---

## Task 2: Create `lib/update.sh`

**Files:**
- Create: `lib/update.sh`

- [ ] **Step 1: Create `lib/update.sh` with all five functions**

```bash
# ── AgToosa: self-update helpers ─────────────────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, TEMPLATE_DIR, AGTOOSA_VERSION, FORCE,
#               DOCS_FILES, CLAUDE_COMMAND_FILES, CURSOR_RULE_FILES,
#               GEMINI_COMMAND_FILES, COPILOT_PROMPT_FILES, COPILOT_AGENT_FILES,
#               WINDSURF_RULE_FILES, CLAUDE_SKILL_FILES, CONTEXT_FILES,
#               colors (GREEN/YELLOW/CYAN/PURPLE/BOLD/NC).
# Globals modified: COPIED, SKIPPED, BAK_FILES, USE_*.

# Read installed AgToosa version from Docs/.agtoosa-version.
# Prints "unknown" if the file does not exist.
read_installed_version() {
  local project_path="$1"
  local ver_file="${project_path}/Docs/.agtoosa-version"
  if [[ -f "$ver_file" ]]; then
    cat "$ver_file"
  else
    echo "unknown"
  fi
}

# Set USE_* globals based on which platform sentinel files exist in PROJECT_PATH.
detect_installed_platforms() {
  USE_CURSOR=false; USE_WINDSURF=false; USE_CLAUDE=false
  USE_GEMINI=false; USE_COPILOT=false; USE_OPENCODE=false; USE_VSCODE=false

  [[ -f "${PROJECT_PATH}/.cursorrules" ]]                   && USE_CURSOR=true
  [[ -f "${PROJECT_PATH}/.windsurfrules" ]]                  && USE_WINDSURF=true
  [[ -f "${PROJECT_PATH}/CLAUDE.md" ]]                       && USE_CLAUDE=true
  [[ -f "${PROJECT_PATH}/AGENTS.md" ]]                       && USE_GEMINI=true
  [[ -f "${PROJECT_PATH}/.github/copilot-instructions.md" ]] && USE_COPILOT=true
  [[ -f "${PROJECT_PATH}/OPENCODE.md" ]]                     && USE_OPENCODE=true
}

# Copy AgToosa-owned files into existing platform native directories.
# Only touches files present in the known AgToosa arrays — never user files.
# Prints the count of files written to stdout.
update_native_dirs() {
  local count=0 f src dst

  if [[ "$USE_CLAUDE" == true ]]; then
    if [[ -d "${PROJECT_PATH}/.claude/commands" ]]; then
      for f in "${CLAUDE_COMMAND_FILES[@]}"; do
        src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
        [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
      done
    fi
    if [[ -d "${PROJECT_PATH}/.claude/skills" ]]; then
      for f in "${CLAUDE_SKILL_FILES[@]}"; do
        src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
        [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
      done
    fi
  fi

  if [[ "$USE_CURSOR" == true && -d "${PROJECT_PATH}/.cursor/rules" ]]; then
    for f in "${CURSOR_RULE_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
    done
  fi

  if [[ "$USE_GEMINI" == true && -d "${PROJECT_PATH}/.gemini/commands" ]]; then
    for f in "${GEMINI_COMMAND_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
    done
  fi

  if [[ "$USE_COPILOT" == true ]]; then
    if [[ -d "${PROJECT_PATH}/.github/prompts" ]]; then
      for f in "${COPILOT_PROMPT_FILES[@]}"; do
        src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
        [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
      done
    fi
    if [[ -d "${PROJECT_PATH}/.github/agents" ]]; then
      for f in "${COPILOT_AGENT_FILES[@]}"; do
        src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
        [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
      done
    fi
  fi

  if [[ "$USE_WINDSURF" == true && -d "${PROJECT_PATH}/.windsurf/rules" ]]; then
    for f in "${WINDSURF_RULE_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
    done
  fi

  echo "$count"
}

# Orchestrate full update: workflow files → platform entry-points → native dirs → settings.json.
run_update() {
  local old_ver="$1"
  local docs_updated=0 platforms_merged=0 dirs_updated=0
  local detected_names=()
  local f src dst

  echo -e "${YELLOW}Updating workflow files...${NC}"

  # Step 1: Workflow files — plain overwrite (never touch Master-Plan or Changelog)
  for f in "${DOCS_FILES[@]}"; do
    [[ "$f" == "Docs/Master-Plan.md" || "$f" == "Docs/AgToosa_Changelog.md" ]] && continue
    src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
    [[ ! -f "$src" ]] && continue
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${f}"
    docs_updated=$((docs_updated + 1))
  done

  echo ""
  echo -e "${YELLOW}Updating platform files...${NC}"

  # Step 2: Platform entry-points — smart merge (only if sentinel exists)
  detect_installed_platforms

  if [[ "$USE_CURSOR" == true ]]; then
    detected_names+=("cursor")
    merge_platform_file "${TEMPLATE_DIR}/.cursorrules" "${PROJECT_PATH}/.cursorrules" ".cursorrules"
    platforms_merged=$((platforms_merged + 1))
  fi
  if [[ "$USE_WINDSURF" == true ]]; then
    detected_names+=("windsurf")
    merge_platform_file "${TEMPLATE_DIR}/.windsurfrules" "${PROJECT_PATH}/.windsurfrules" ".windsurfrules"
    platforms_merged=$((platforms_merged + 1))
  fi
  if [[ "$USE_CLAUDE" == true ]]; then
    detected_names+=("claude")
    merge_platform_file "${TEMPLATE_DIR}/CLAUDE.md" "${PROJECT_PATH}/CLAUDE.md" "CLAUDE.md"
    src="${TEMPLATE_DIR}/Docs/AgToosa_Claude.md"; dst="${PROJECT_PATH}/Docs/AgToosa_Claude.md"
    [[ -f "$src" ]] && cp "$src" "$dst"
    platforms_merged=$((platforms_merged + 1))
  fi
  if [[ "$USE_GEMINI" == true ]]; then
    detected_names+=("gemini")
    merge_platform_file "${TEMPLATE_DIR}/AGENTS.md" "${PROJECT_PATH}/AGENTS.md" "AGENTS.md"
    src="${TEMPLATE_DIR}/Docs/AgToosa_Gemini.md"; dst="${PROJECT_PATH}/Docs/AgToosa_Gemini.md"
    [[ -f "$src" ]] && cp "$src" "$dst"
    platforms_merged=$((platforms_merged + 1))
  fi
  if [[ "$USE_COPILOT" == true ]]; then
    detected_names+=("copilot")
    merge_platform_file "${TEMPLATE_DIR}/.github/copilot-instructions.md" \
      "${PROJECT_PATH}/.github/copilot-instructions.md" ".github/copilot-instructions.md"
    platforms_merged=$((platforms_merged + 1))
  fi
  if [[ "$USE_OPENCODE" == true ]]; then
    detected_names+=("opencode")
    merge_platform_file "${TEMPLATE_DIR}/OPENCODE.md" "${PROJECT_PATH}/OPENCODE.md" "OPENCODE.md"
    platforms_merged=$((platforms_merged + 1))
  fi

  echo ""
  echo -e "${YELLOW}Updating platform native dirs...${NC}"

  # Step 3: Native dirs — overwrite known AgToosa files only
  dirs_updated="$(update_native_dirs)"

  # Step 4: .claude/settings.json — deep-merge hooks
  if [[ "$USE_CLAUDE" == true && -f "${PROJECT_PATH}/.claude/settings.json" ]]; then
    merge_settings_json "${TEMPLATE_DIR}/.claude/settings.json" \
      "${PROJECT_PATH}/.claude/settings.json" ".claude/settings.json"
  fi

  # Write version marker
  echo "$AGTOOSA_VERSION" > "${PROJECT_PATH}/Docs/.agtoosa-version"

  print_update_summary "$old_ver" "$docs_updated" "$platforms_merged" "$dirs_updated" \
    "${detected_names[@]+"${detected_names[@]}"}"
}

# Print the update summary report to stdout.
print_update_summary() {
  local old_ver="$1" docs_updated="$2" platforms_merged="$3" dirs_updated="$4"
  shift 4
  local detected_names=("$@")
  local platform_str
  platform_str="$(IFS=", "; echo "${detected_names[*]:-none}")"

  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}✅ AgToosa updated v${old_ver} → v${AGTOOSA_VERSION}${NC}"
  echo ""
  echo -e "  Workflow files updated : ${docs_updated}"
  echo -e "  Platform files merged  : ${platforms_merged}  (${platform_str})"
  echo -e "  Platform dirs updated  : ${dirs_updated}"
  echo -e "  Context/ preserved     : ${GREEN}✅${NC} (${#CONTEXT_FILES[@]} files untouched)"

  if [[ ${#BAK_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Backup files created — add *.bak.* to your .gitignore${NC}"
    local bak
    for bak in "${BAK_FILES[@]}"; do
      echo -e "    ${CYAN}${bak#"${PROJECT_PATH}/"}${NC}"
    done
  fi

  echo ""
  echo -e "  Run ${BOLD}/agtoosa-update${NC} in your AI assistant to see the full changelog."
  echo ""
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/update.sh
git commit -m "feat: add lib/update.sh with update helpers and run_update()"
```

---

## Task 3: Wire `--update` into `agtoosa.sh`

**Files:**
- Modify: `agtoosa.sh`
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write the failing test**

Add to `tests/agtoosa.bats`:

```bash
# ── --update: no Docs/ directory ─────────────────────────────

@test "--update on path with no Docs/ exits with error" {
  # TEST_PROJECT is empty (no Docs/ dir)
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"No Docs/"* ]]
}
```

- [ ] **Step 2: Run to confirm it fails**

```bash
bats tests/agtoosa.bats --filter "update on path with no Docs"
```

Expected: FAIL — `--update` is currently an unknown option, exits 1 with "Unknown option".

- [ ] **Step 3: Source `lib/update.sh` in `agtoosa.sh`**

Find the lib sourcing loop (around line 33):

```bash
for _lib in config version copy generate dryrun install; do
```

Change to:

```bash
for _lib in config version copy generate dryrun install update; do
```

- [ ] **Step 4: Add `UPDATE` flag variables in `agtoosa.sh`**

Find the `# ── Flags ──` section (around line 57) and add two new variables before the flag loop:

```bash
FORCE=false
DRY_RUN=false
UPDATE=false
UPDATE_PATH=""
```

- [ ] **Step 5: Handle `--update` in the flag loop**

The current flag loop is `for arg in "$@"`. Replace it with a version that handles `--update [path]` as a consecutive pair:

```bash
for arg in "$@"; do
  case "$arg" in
    --update)
      UPDATE=true ;;
    --force)               FORCE=true ;;
    --dry-run)             DRY_RUN=true ;;
    --list-template-files) print_template_files; exit 0 ;;
    --version)             echo "AgToosa v${AGTOOSA_VERSION}"; exit 0 ;;
    --help)                print_usage; exit 0 ;;
    *)
      if [[ "$UPDATE" == true && -z "$UPDATE_PATH" && "$arg" != --* ]]; then
        UPDATE_PATH="$arg"
      else
        echo -e "${RED}❌ Error: Unknown option '${arg}'.${NC}"
        echo ""
        print_usage
        exit 1
      fi
      ;;
  esac
done
```

- [ ] **Step 6: Add update mode branch in `agtoosa.sh` after the source guard**

Find the source guard line:

```bash
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0
```

Immediately after it, add the update mode block (before `# ── Welcome ──`):

```bash
# ── Update mode ───────────────────────────────────────────────
if [[ "$UPDATE" == true ]]; then
  if [[ -z "$UPDATE_PATH" ]]; then
    echo -e "${BOLD}Project path to update:${NC}"
    read -rp "Project path: " UPDATE_PATH
    UPDATE_PATH="${UPDATE_PATH/#\~/$HOME}"
    UPDATE_PATH="${UPDATE_PATH%/}"
  fi
  PROJECT_PATH="$UPDATE_PATH"

  if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ Error: Directory '${PROJECT_PATH}' does not exist.${NC}"
    exit 1
  fi

  _rp_project="$(cd "$PROJECT_PATH" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_project" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
    exit 1
  fi

  if [[ ! -d "${PROJECT_PATH}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory found in '${PROJECT_PATH}'.${NC}"
    echo -e "${YELLOW}Run the full install first: bash agtoosa.sh${NC}"
    exit 1
  fi

  if [[ "$DRY_RUN" == true ]]; then
    detect_installed_platforms
    local _dnames=()
    [[ "$USE_CURSOR"   == true ]] && _dnames+=("cursor")
    [[ "$USE_WINDSURF" == true ]] && _dnames+=("windsurf")
    [[ "$USE_CLAUDE"   == true ]] && _dnames+=("claude")
    [[ "$USE_GEMINI"   == true ]] && _dnames+=("gemini")
    [[ "$USE_COPILOT"  == true ]] && _dnames+=("copilot")
    [[ "$USE_OPENCODE" == true ]] && _dnames+=("opencode")
    echo -e "${YELLOW}[DRY RUN] Would update AgToosa in '${PROJECT_PATH}'${NC}"
    echo -e "  Would overwrite: all Docs/AgToosa_*.md (except Master-Plan.md and AgToosa_Changelog.md)"
    echo -e "  Would merge platform entry-points: ${_dnames[*]:-none detected}"
    echo -e "  Would preserve: Docs/Context/, Docs/Master-Plan.md, Docs/AgToosa_Changelog.md"
    echo ""
    echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply.${NC}"
    exit 0
  fi

  OLD_VERSION="$(read_installed_version "$PROJECT_PATH")"
  echo ""
  echo -e "${PURPLE}${BOLD}Updating AgToosa v${OLD_VERSION} → v${AGTOOSA_VERSION}${NC}"
  echo -e "${PURPLE}${BOLD}Project: ${PROJECT_PATH}${NC}"
  echo ""

  COPIED=0; SKIPPED=0; BAK_FILES=()
  run_update "$OLD_VERSION"
  exit 0
fi
```

Note: the `local` keyword is not valid at the top level of a script — replace `local _dnames=()` with just `_dnames=()` in the dry-run block above.

- [ ] **Step 7: Run failing test to confirm it now passes**

```bash
bats tests/agtoosa.bats --filter "update on path with no Docs"
```

Expected: PASS.

- [ ] **Step 8: Confirm no regressions**

```bash
bats tests/agtoosa.bats
```

Expected: all previously passing tests still PASS.

- [ ] **Step 9: Commit**

```bash
git add agtoosa.sh tests/agtoosa.bats
git commit -m "feat: wire --update flag and update mode into agtoosa.sh"
```

---

## Task 4: Error Handling Tests

**Files:**
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write two failing tests**

Add to `tests/agtoosa.bats`:

```bash
# ── --update: source dir guard ────────────────────────────────

@test "--update on AgToosa source directory is blocked" {
  local src_dir
  src_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  run bash "$SCRIPT" --update "$src_dir"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Target path cannot be the AgToosa source directory"* ]]
}

# ── --update: non-existent path ───────────────────────────────

@test "--update on non-existent path exits with error" {
  run bash "$SCRIPT" --update "/tmp/agtoosa-nonexistent-update-99999"
  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}
```

- [ ] **Step 2: Run both tests**

```bash
bats tests/agtoosa.bats --filter "source directory is blocked|non-existent path exits"
```

Expected: both PASS (guards implemented in Task 3).

- [ ] **Step 3: Commit**

```bash
git add tests/agtoosa.bats
git commit -m "test: add --update error-path tests (source dir, non-existent path)"
```

---

## Task 5: Core Update Behavior Tests

**Files:**
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write five tests**

Add to `tests/agtoosa.bats`:

```bash
# ── --update: core behavior ───────────────────────────────────

@test "--update overwrites workflow files" {
  # Full install first
  run bash -c "printf '$TEST_PROJECT\n8\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Corrupt a workflow file to simulate stale content
  echo "STALE CONTENT" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  # Run update
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  # Workflow file restored
  [[ "$(cat "$TEST_PROJECT/Docs/AgToosa_Agent.md")" != "STALE CONTENT" ]]
}

@test "--update preserves Docs/Context/ files" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "my custom stack" > "$TEST_PROJECT/Docs/Context/tech-stack.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "my custom stack" "$TEST_PROJECT/Docs/Context/tech-stack.md"
}

@test "--update preserves Docs/Master-Plan.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "# My Master Plan" > "$TEST_PROJECT/Docs/Master-Plan.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "My Master Plan" "$TEST_PROJECT/Docs/Master-Plan.md"
}

@test "--update preserves Docs/AgToosa_Changelog.md" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  echo "# My Changelog" > "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  grep -q "My Changelog" "$TEST_PROJECT/Docs/AgToosa_Changelog.md"
}

@test "--update writes Docs/.agtoosa-version" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  local ver
  ver="$(cat "$TEST_PROJECT/Docs/.agtoosa-version")"
  [[ "$ver" == AgToosa\ v* || "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
```

Note: `AGTOOSA_VERSION` in `agtoosa.sh` is a plain semver string like `"2.5.0"`. The last assertion accepts either `"2.5.0"` or `"AgToosa v2.5.0"` — check the actual `echo` in Task 3 Step 6 (it writes `$AGTOOSA_VERSION` directly, so the file contains `2.5.0`). Use this assertion instead:

```bash
  [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
```

- [ ] **Step 2: Run all five**

```bash
bats tests/agtoosa.bats --filter "update overwrites|update preserves|update writes Docs/.agtoosa-version"
```

Expected: all PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/agtoosa.bats
git commit -m "test: add --update core behavior tests (workflow files, Context, version file)"
```

---

## Task 6: Version Display Tests

**Files:**
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write two tests**

Add to `tests/agtoosa.bats`:

```bash
# ── --update: version display ─────────────────────────────────

@test "--update shows 'unknown ->' when no prior version file" {
  # Install without running update (so no .agtoosa-version exists)
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Confirm no version file from install
  rm -f "$TEST_PROJECT/Docs/.agtoosa-version"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"v unknown"* || "$output" == *"unknown →"* ]]
}

@test "--update shows 'v{old} ->' when prior version file exists" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Write a fake old version
  echo "2.0.0" > "$TEST_PROJECT/Docs/.agtoosa-version"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"2.0.0"* ]]
}
```

- [ ] **Step 2: Run both tests**

```bash
bats tests/agtoosa.bats --filter "shows 'unknown'|shows 'v{old}'"
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/agtoosa.bats
git commit -m "test: add --update version display tests"
```

---

## Task 7: Platform Detection Tests

**Files:**
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write two tests**

Add to `tests/agtoosa.bats`:

```bash
# ── --update: platform detection ─────────────────────────────

@test "--update detects installed Claude platform and merges CLAUDE.md" {
  # Install with Claude only
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/CLAUDE.md" ]
  # Simulate stale CLAUDE.md with old AgToosa block
  printf '<!-- AgToosa v1.0.0 START -->\nold content\n<!-- AgToosa END -->\n' \
    > "$TEST_PROJECT/CLAUDE.md"
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  # A .bak file was created (merge happened)
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name "CLAUDE.md.bak.*" | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  # Old version marker gone
  ! grep -q "v1.0.0 START" "$TEST_PROJECT/CLAUDE.md"
}

@test "--update does not create .cursorrules when not previously installed" {
  # Install with Claude only (no Cursor)
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
  run bash "$SCRIPT" --update "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  # Still absent after update
  [ ! -f "$TEST_PROJECT/.cursorrules" ]
}
```

- [ ] **Step 2: Run both tests**

```bash
bats tests/agtoosa.bats --filter "detects installed Claude|does not create .cursorrules"
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/agtoosa.bats
git commit -m "test: add --update platform detection tests (Claude merged, non-installed skipped)"
```

---

## Task 8: Flag Combination Tests

**Files:**
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write two tests**

Add to `tests/agtoosa.bats`:

```bash
# ── --update --dry-run ────────────────────────────────────────

@test "--update --dry-run writes no files and shows DRY RUN" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Corrupt a workflow file
  echo "STALE" > "$TEST_PROJECT/Docs/AgToosa_Agent.md"
  run bash "$SCRIPT" --update --dry-run "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]
  # Stale content untouched (no files written)
  grep -q "STALE" "$TEST_PROJECT/Docs/AgToosa_Agent.md"
}

# ── --update --force ──────────────────────────────────────────

@test "--update --force replaces user-owned platform entry-point with backup" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # Replace CLAUDE.md with plain user content (no AgToosa markers)
  echo "my own CLAUDE content, no agtoosa markers" > "$TEST_PROJECT/CLAUDE.md"
  run bash "$SCRIPT" --update --force "$TEST_PROJECT"
  [ "$status" -eq 0 ]
  # A .bak was created
  local bak_count
  bak_count="$(find "$TEST_PROJECT" -name "CLAUDE.md.bak.*" | wc -l | tr -d ' ')"
  [ "$bak_count" -ge 1 ]
  # Original user content gone from CLAUDE.md (replaced)
  ! grep -q "my own CLAUDE content" "$TEST_PROJECT/CLAUDE.md"
}
```

- [ ] **Step 2: Run both tests**

```bash
bats tests/agtoosa.bats --filter "dry-run writes no files|force replaces user-owned"
```

Expected: PASS.

- [ ] **Step 3: Run the full suite to confirm no regressions**

```bash
bats tests/agtoosa.bats
```

Expected: all tests PASS.

- [ ] **Step 4: Commit**

```bash
git add tests/agtoosa.bats
git commit -m "test: add --update --dry-run and --update --force tests"
```

---

## Task 9: Create `template/Docs/AgToosa_Update.md`

**Files:**
- Create: `template/Docs/AgToosa_Update.md`

- [ ] **Step 1: Create the workflow file**

```markdown
# AgToosa /agtoosa-update

Check your installed AgToosa version and update workflow files to the latest release.

## When to Run

- You want to check if a newer AgToosa version is available
- You pulled a new release of AgToosa and want workflow improvements to reach this project
- A workflow command feels outdated compared to the AgToosa docs

## Workflow

1. **Check installed version**

   Read `Docs/.agtoosa-version` in this project. If the file does not exist, the install predates v2.5.0 (version is unknown).

2. **Tell the user their installed version** and ask them to check the AgToosa repository for the latest release tag.

3. **Run the update**

   Ask the user to `git pull` in their AgToosa clone, then run from the AgToosa directory:

   ```bash
   bash agtoosa.sh --update /path/to/this/project
   ```

   Or from this project's root (if the AgToosa clone is a sibling or known path):

   ```bash
   bash /path/to/AgToosa/agtoosa.sh --update .
   ```

4. **Confirm**

   After the user reports the command ran, re-read `Docs/.agtoosa-version` and confirm the version updated.

5. **Surface what changed**

   Read `Docs/AgToosa_Changelog.md` and show the entries between the old and new version so the user knows what new commands or workflow improvements are now available.

## What Gets Updated

| Category | Action |
|----------|--------|
| `Docs/AgToosa_*.md` workflow files | Overwritten with latest version |
| Platform entry-points (`CLAUDE.md`, `.cursorrules`, etc.) | Smart merge — only if already installed |
| Platform native dirs (`.claude/commands/`, `.cursor/rules/`, etc.) | Overwritten — only AgToosa-owned files |
| `.claude/settings.json` hooks | Deep-merged, deduplicated |

## What Is Preserved

| Category | Action |
|----------|--------|
| `Docs/Context/` | Never touched (your product/tech/workflow config) |
| `Docs/Master-Plan.md` | Never touched (your Linear mirror) |
| `Docs/AgToosa_Changelog.md` | Never touched (your project changelog) |
| `Docs/archived/` | Never touched (completed specs) |
| User files in platform dirs | Never touched (only AgToosa-owned files overwritten) |
```

- [ ] **Step 2: Commit**

```bash
git add template/Docs/AgToosa_Update.md
git commit -m "feat: add template/Docs/AgToosa_Update.md in-IDE update workflow"
```

---

## Task 10: Wire `/agtoosa-update` into Platform Entry-Points

**Files:**
- Modify: `template/CLAUDE.md`, `template/.cursorrules`, `template/AGENTS.md`, `template/.windsurfrules`, `template/.roorules`, `template/OPENCODE.md`, `template/.github/copilot-instructions.md`, `template/Docs/AgToosa_Agent.md`
- Test: `tests/agtoosa.bats`

- [ ] **Step 1: Write the failing wiring tests**

Add to `tests/agtoosa.bats`:

```bash
# ── /agtoosa-update wiring ────────────────────────────────────

@test "all 7 platform entry-point templates include /agtoosa-update" {
  local files=(
    "$TEMPLATE_DIR/CLAUDE.md"
    "$TEMPLATE_DIR/.cursorrules"
    "$TEMPLATE_DIR/AGENTS.md"
    "$TEMPLATE_DIR/.windsurfrules"
    "$TEMPLATE_DIR/.roorules"
    "$TEMPLATE_DIR/OPENCODE.md"
    "$TEMPLATE_DIR/.github/copilot-instructions.md"
  )
  local f
  for f in "${files[@]}"; do
    grep -q "agtoosa-update" "$f" || {
      echo "Missing /agtoosa-update in: $f"
      return 1
    }
  done
}

@test "AgToosa_Agent.md utility table includes /agtoosa-update" {
  grep -q "agtoosa-update" "$TEMPLATE_DIR/Docs/AgToosa_Agent.md"
}
```

- [ ] **Step 2: Run to confirm they fail**

```bash
bats tests/agtoosa.bats --filter "platform entry-point templates include|AgToosa_Agent.md utility"
```

Expected: FAIL — `/agtoosa-update` not yet in any file.

- [ ] **Step 3: Update `template/CLAUDE.md`**

Find the Optional utilities line:
```
**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast Linear issue capture)
```

Replace with:
```
**Optional utilities:** `/agtoosa-revert` → Read `Docs/AgToosa_Revert.md` (git-aware rollback) · `/agtoosa-task` → Read `Docs/AgToosa_Task.md` (fast Linear issue capture) · `/agtoosa-update` → Read `Docs/AgToosa_Update.md` (update workflow files to latest)
```

- [ ] **Step 4: Apply the same change to `template/.cursorrules`**

Same find-and-replace as Step 3 — the Optional utilities line is identical in all 7 files.

- [ ] **Step 5: Apply the same change to `template/AGENTS.md`**

- [ ] **Step 6: Apply the same change to `template/.windsurfrules`**

- [ ] **Step 7: Apply the same change to `template/.roorules`**

- [ ] **Step 8: Apply the same change to `template/OPENCODE.md`**

- [ ] **Step 9: Apply the same change to `template/.github/copilot-instructions.md`**

- [ ] **Step 10: Update `template/Docs/AgToosa_Agent.md`**

Find the Utility Commands table:

```markdown
| `/agtoosa-revert` | `Docs/AgToosa_Revert.md` | Git-aware logical revert |
| `/agtoosa-task` | `Docs/AgToosa_Task.md` | Fast Linear issue creation for bugs, chores, spikes, and fixes |
```

Add a new row after `/agtoosa-task`:

```markdown
| `/agtoosa-revert` | `Docs/AgToosa_Revert.md` | Git-aware logical revert |
| `/agtoosa-task` | `Docs/AgToosa_Task.md` | Fast Linear issue creation for bugs, chores, spikes, and fixes |
| `/agtoosa-update` | `Docs/AgToosa_Update.md` | Update workflow files to latest AgToosa release |
```

- [ ] **Step 11: Run wiring tests to confirm they pass**

```bash
bats tests/agtoosa.bats --filter "platform entry-point templates include|AgToosa_Agent.md utility"
```

Expected: both PASS.

- [ ] **Step 12: Run the full test suite**

```bash
bats tests/agtoosa.bats
```

Expected: all tests PASS.

- [ ] **Step 13: Commit**

```bash
git add template/CLAUDE.md template/.cursorrules template/AGENTS.md \
        template/.windsurfrules template/.roorules template/OPENCODE.md \
        template/.github/copilot-instructions.md \
        template/Docs/AgToosa_Agent.md tests/agtoosa.bats
git commit -m "feat: wire /agtoosa-update into all platform entry-points and AgToosa_Agent.md"
```

---

## Regression Test

After all tasks complete, run the full regression:

```bash
bats tests/agtoosa.bats
```

Every test must PASS. The new test count should be approximately 69 (existing) + 15 (new) = 84.
