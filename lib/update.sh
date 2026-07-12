#!/usr/bin/env bash

# ── AgToosa: self-update helpers ─────────────────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, TEMPLATE_DIR, AGTOOSA_VERSION, FORCE,
#               DOCS_FILES, CLAUDE_COMMAND_FILES, CURSOR_RULE_FILES,
#               CURSOR_COMMAND_FILES, WINDSURF_WORKFLOW_FILES, CODEX_SKILL_FILES,
#               CODEX_PROMPT_FILES,
#               GEMINI_COMMAND_FILES, COPILOT_PROMPT_FILES, COPILOT_AGENT_FILES,
#               WINDSURF_RULE_FILES, CLAUDE_SKILL_FILES, CLAUDE_HOOK_FILES, CONTEXT_FILES,
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

  # Never propagate a non-zero status from probe checks under set -e.
  return 0
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
    for f in "${CLAUDE_HOOK_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        chmod +x "$dst" 2>/dev/null || true
        count=$((count + 1))
      fi
    done
  fi

  if [[ "$USE_CURSOR" == true && -d "${PROJECT_PATH}/.cursor/rules" ]]; then
    for f in "${CURSOR_RULE_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      [[ -f "$src" ]] && { cp "$src" "$dst"; count=$((count + 1)); }
    done
  fi
  if [[ "$USE_CURSOR" == true ]]; then
    for f in "${CURSOR_COMMAND_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        count=$((count + 1))
      fi
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
  if [[ "$USE_WINDSURF" == true ]]; then
    for f in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        count=$((count + 1))
      fi
    done
  fi
  if [[ "$USE_OPENCODE" == true ]]; then
    for f in "${CODEX_SKILL_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        count=$((count + 1))
      fi
    done
    for f in "${CODEX_PROMPT_FILES[@]}"; do
      src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
      if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        count=$((count + 1))
      fi
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

  COPIED=${COPIED:-0}
  SKIPPED=${SKIPPED:-0}
  BAK_FILES=("${BAK_FILES[@]+"${BAK_FILES[@]}"}")
  if declare -F apply_reset_summary >/dev/null 2>&1; then
    apply_reset_summary
  fi

  # DEV-093: pack SHA revalidation before mutate / state write
  if declare -F lock_revalidate_packs >/dev/null 2>&1; then
    lock_revalidate_packs "$PROJECT_PATH" || return 1
  fi

  echo -e "${YELLOW}Updating workflow files...${NC}"

  # Step 1: Workflow files — hash-aware overwrite (DEV-092 shared apply helper)
  for f in "${DOCS_FILES[@]}"; do
    [[ "$f" == "Docs/Master-Plan.md" || "$f" == "Docs/AgToosa_Changelog.md" || "$f" == "Docs/Master-Architecture.md" ]] && continue
    src="${TEMPLATE_DIR}/${f}"; dst="${PROJECT_PATH}/${f}"
    [[ ! -f "$src" ]] && continue
    mkdir -p "$(dirname "$dst")"
    if declare -F apply_copy_if_changed >/dev/null 2>&1; then
      local before_u="${APPLY_UNCHANGED:-0}"
      apply_copy_if_changed "$src" "$dst" "$f"
      if [[ "${APPLY_UNCHANGED:-0}" -eq "$before_u" ]]; then
        docs_updated=$((docs_updated + 1))
      fi
    else
      cp "$src" "$dst"
      echo -e "  ${GREEN}✅${NC} ${f}"
      docs_updated=$((docs_updated + 1))
    fi
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

  # Step 5: Reconcile lock (platforms + version) — DEV-093 / ADR-004.
  if declare -F lock_reconcile >/dev/null 2>&1; then
    lock_reconcile "$PROJECT_PATH"
  else
    local lock_file="${PROJECT_PATH}/Docs/agtoosa-lock.json"
    if [[ -f "$lock_file" ]] && command -v jq &>/dev/null; then
      local tmp_lock
      tmp_lock=$(mktemp)
      jq --arg v "$AGTOOSA_VERSION" --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '.agtoosa_version = $v | .generated_at = $t' "$lock_file" > "$tmp_lock" && mv "$tmp_lock" "$lock_file"
    fi
  fi

  # Write version marker
  echo "$AGTOOSA_VERSION" > "${PROJECT_PATH}/Docs/.agtoosa-version"

  # .agtoosa/ config index + examples (DEV-087) — overwrite AgToosa-owned files only
  local afile
  mkdir -p "${PROJECT_PATH}/.agtoosa"
  for afile in "${AGTOOSA_DOTDIR_FILES[@]}"; do
    src="${TEMPLATE_DIR}/${afile}"; dst="${PROJECT_PATH}/${afile}"
    [[ ! -f "$src" ]] && continue
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${afile}"
    docs_updated=$((docs_updated + 1))
  done

  # DEV-093: operational state after successful update apply
  if declare -F state_write_after_apply >/dev/null 2>&1; then
    state_write_after_apply "$PROJECT_PATH" "update"
  fi

  print_update_summary "$old_ver" "$docs_updated" "$platforms_merged" "$dirs_updated" \
    "${detected_names[@]+"${detected_names[@]}"}"
}

# Dry-run preview for --update via unified plan engine (read-only).
# MAJOR deltas are handled by run_major_migration / print_update_dryrun_preview.
run_update_dryrun() {
  local format="${1:-text}"
  compute_agtoosa_plan "$PROJECT_PATH" "update"
  if [[ "$format" == "json" ]]; then
    emit_plan_json
  else
    emit_plan_human
  fi
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
  if declare -F apply_print_summary >/dev/null 2>&1; then
    apply_print_summary
  fi

  if [[ ${#BAK_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Backup files created — add *.bak.* to your .gitignore${NC}"
    local bak
    for bak in "${BAK_FILES[@]}"; do
      echo -e "    ${CYAN}${bak#"${PROJECT_PATH}/"}${NC}"
    done
  fi

  echo ""
  echo -e "  Open ${BOLD}${PROJECT_PATH}${NC} in your AI assistant and run ${BOLD}/agtoosa-update${NC} to see the full changelog."
  echo ""
}
