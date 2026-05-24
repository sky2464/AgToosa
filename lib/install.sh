#!/usr/bin/env bash

# ── AgToosa: install helpers ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, PACK_QUEUE_DIR, FORCE, USE_*, DOCS_FILES, CONTEXT_FILES,
#               AGTOOSA_VERSION, BAK_FILES, colors.
# Globals modified: COPIED, SKIPPED, EXISTING_FILES, KEEP_SHIP.

# Set EXISTING_FILES to the count of already-present files in PROJECT_PATH.
# Called before the copy confirmation prompt.
count_existing_files() {
  EXISTING_FILES=0
  [[ "$FORCE" == true ]] && return

  local file cfile
  for file in "${DOCS_FILES[@]}"; do
    [[ -f "${PROJECT_PATH}/${file}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  done
  [[ "$USE_CURSOR"   == true && -f "${PROJECT_PATH}/.cursorrules" ]]                   && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_WINDSURF" == true && -f "${PROJECT_PATH}/.windsurfrules" ]]                  && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_CLAUDE"   == true && -f "${PROJECT_PATH}/CLAUDE.md" ]]                       && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_CLAUDE"   == true && -f "${PROJECT_PATH}/Docs/AgToosa_Claude.md" ]]          && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_GEMINI"   == true && -f "${PROJECT_PATH}/AGENTS.md" ]]                       && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_GEMINI"   == true && -f "${PROJECT_PATH}/Docs/AgToosa_Gemini.md" ]]          && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_COPILOT"  == true && -f "${PROJECT_PATH}/.github/copilot-instructions.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  if [[ "$USE_COPILOT" == true || "$USE_VSCODE" == true ]]; then
    local cinstr
    for cinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${cinstr}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi

  if [[ "$USE_OPENCODE" == true ]]; then
    [[ -f "${PROJECT_PATH}/OPENCODE.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    local codex_skill
    for codex_skill in "${CODEX_SKILL_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${codex_skill}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    local codex_prompt
    for codex_prompt in "${CODEX_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${codex_prompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${PROJECT_PATH}/${cfile}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  done
  if [[ "$USE_CLAUDE" == true ]]; then
    local ccmd cskill
    for ccmd in "${CLAUDE_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${ccmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    [[ -f "${PROJECT_PATH}/.claude/settings.json" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    for cskill in "${CLAUDE_SKILL_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${cskill}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_CURSOR" == true ]]; then
    local crule ccmd
    for crule in "${CURSOR_RULE_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${crule}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for ccmd in "${CURSOR_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${ccmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_GEMINI" == true ]]; then
    local gcmd
    for gcmd in "${GEMINI_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${gcmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_COPILOT" == true ]]; then
    local pprompt pagent
    for pprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${pprompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for pagent in "${COPILOT_AGENT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${pagent}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_VSCODE" == true && "$USE_COPILOT" != true ]]; then
    [[ -f "${PROJECT_PATH}/.github/copilot-instructions.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    local vprompt vagent
    for vprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${vprompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for vagent in "${COPILOT_AGENT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${vagent}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_WINDSURF" == true ]]; then
    local wrule wflow
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${wrule}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for wflow in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${wflow}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  return 0
}

# Copy pack files into PROJECT_PATH, skipping disallowed file types.
_merge_pack() {
  local pack_dir="$1" pack_name="$2"
  local allowed_exts="md json toml mdc"
  local count=0
  while IFS= read -r -d '' f; do
    [[ "$(basename "$f")" == ".pack-meta.json" ]] && continue
    local ext="${f##*.}"
    local allowed=false
    for e in $allowed_exts; do
      [[ "$ext" == "$e" ]] && allowed=true && break
    done
    if [[ "$allowed" == false ]]; then
      echo -e "  ${YELLOW}⏭${NC}  Skipping disallowed file: ${f#"$pack_dir"}" >&2
      continue
    fi
    local rel="${f#"$pack_dir"}"
    local dst="${PROJECT_PATH}/${rel}"
    mkdir -p "$(dirname "$dst")"
    cp "$f" "$dst"
    count=$((count + 1))
  done < <(find "$pack_dir" -type f -print0)
  echo -e "  ${GREEN}✅${NC} Pack '${pack_name}': ${count} files merged"
}

# Merge all pack subdirectories under packs_root. When clear_after is true, remove each
# pack dir after a successful merge (used for the durable pack queue).
# Sets _PACK_MERGE_COUNT and appends lock meta paths to _PACK_LOCK_ENTRIES.
_merge_packs_under_root() {
  local packs_root="$1"
  local clear_after="${2:-false}"
  _PACK_MERGE_COUNT=0
  _PACK_LOCK_ENTRIES=()

  [[ -d "$packs_root" ]] || return 0

  local pack_dir pname
  for pack_dir in "${packs_root}"/*/; do
    [[ -d "$pack_dir" ]] || continue
    pname=$(basename "$pack_dir")
    if _merge_pack "$pack_dir" "$pname"; then
      _PACK_MERGE_COUNT=$((_PACK_MERGE_COUNT + 1))
      if [[ -f "${pack_dir}/.pack-meta.json" ]]; then
        _PACK_LOCK_ENTRIES+=("${pack_dir}/.pack-meta.json")
      fi
      if [[ "$clear_after" == true ]]; then
        rm -rf "$pack_dir"
      fi
    fi
  done
}

_merge_pack_queue() {
  _merge_packs_under_root "$PACK_QUEUE_DIR" true
}

_merge_ship_staged_packs() {
  _merge_packs_under_root "${SHIP_DIR}/packs" false
}

# Write or update Docs/agtoosa-lock.json with installed pack entries.
_write_lock_file() {
  local meta_files=("$@")
  local lock_file="${PROJECT_PATH}/Docs/agtoosa-lock.json"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  local packs_json=""
  local sep=""
  for meta in "${meta_files[@]}"; do
    [[ -f "$meta" ]] || continue
    local entry
    entry=$(cat "$meta")
    packs_json+="${sep}    ${entry}"
    sep=$',\n'
  done

  if [[ -f "$lock_file" ]] && command -v jq &>/dev/null; then
    local existing_names=()
    while IFS= read -r n; do existing_names+=("$n"); done \
      < <(jq -r '.packs[]?.name' "$lock_file" 2>/dev/null)
    local new_names=()
    for meta in "${meta_files[@]}"; do
      [[ -f "$meta" ]] || continue
      local n
      if command -v jq &>/dev/null; then
        n=$(jq -r '.name' "$meta" 2>/dev/null)
      else
        n=$(grep -oP '"name":\s*"\K[^"]+' "$meta" | head -1)
      fi
      new_names+=("$n")
    done
    local kept_json=""
    local ksep=""
    while IFS= read -r existing_entry; do
      local ename
      ename=$(echo "$existing_entry" | jq -r '.name' 2>/dev/null)
      local skip=false
      for nn in "${new_names[@]}"; do [[ "$ename" == "$nn" ]] && skip=true && break; done
      if [[ "$skip" == false ]]; then
        kept_json+="${ksep}    $(echo "$existing_entry" | jq -c '.')"
        ksep=$',\n'
      fi
    done < <(jq -c '.packs[]?' "$lock_file" 2>/dev/null)
    if [[ -n "$kept_json" ]]; then
      packs_json="${kept_json}"$',\n'"    ${packs_json#    }"
    fi
  fi

  mkdir -p "${PROJECT_PATH}/Docs"
  printf '{\n  "agtoosa_version": "%s",\n  "generated_at": "%s",\n  "packs": [\n%s\n  ]\n}\n' \
    "$AGTOOSA_VERSION" "$timestamp" "$packs_json" > "$lock_file"
  echo -e "  ${GREEN}✅${NC} Docs/agtoosa-lock.json updated"
}

# Copy all staged files from ship/ into PROJECT_PATH, then print summary + next steps.
install_files() {
  mkdir -p "${PROJECT_PATH}/Docs/archived" "${PROJECT_PATH}/Docs/Context"

  # DEV-134: Docs/ workflow files always overwrite
  local file
  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${file}" ]]; then
      if [[ "$file" == "Docs/Master-Architecture.md" ]]; then
        if [[ -f "${PROJECT_PATH}/${file}" ]]; then
          echo -e "  ${YELLOW}⏭${NC}  Skipping ${file} (architecture memory exists)"
          SKIPPED=$((SKIPPED + 1))
          continue
        fi
        copy_platform_file "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}" "${file}"
        continue
      fi
      cp "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}"
      echo -e "  ${GREEN}✅${NC} ${file}"
      COPIED=$((COPIED + 1))
    fi
  done

  # Platform entry-point dotfiles — smart merge/append
  local dotfile
  for dotfile in .cursorrules .windsurfrules; do
    [[ -f "${SHIP_DIR}/${dotfile}" ]] \
      && merge_platform_file "${SHIP_DIR}/${dotfile}" "${PROJECT_PATH}/${dotfile}" "${dotfile}"
  done

  # Platform entry-point markdown files — smart merge/append
  local mdfile
  for mdfile in CLAUDE.md AGENTS.md OPENCODE.md; do
    [[ -f "${SHIP_DIR}/${mdfile}" ]] \
      && merge_platform_file "${SHIP_DIR}/${mdfile}" "${PROJECT_PATH}/${mdfile}" "${mdfile}"
  done

  # Pure AgToosa Docs — always overwrite
  local pdoc
  for pdoc in Docs/AgToosa_Claude.md Docs/AgToosa_Gemini.md; do
    if [[ -f "${SHIP_DIR}/${pdoc}" ]]; then
      cp "${SHIP_DIR}/${pdoc}" "${PROJECT_PATH}/${pdoc}"
      echo -e "  ${GREEN}✅${NC} ${pdoc}"
      COPIED=$((COPIED + 1))
    fi
  done

  # GitHub Copilot entry-point
  if [[ -f "${SHIP_DIR}/.github/copilot-instructions.md" ]]; then
    mkdir -p "${PROJECT_PATH}/.github"
    merge_platform_file \
      "${SHIP_DIR}/.github/copilot-instructions.md" \
      "${PROJECT_PATH}/.github/copilot-instructions.md" \
      ".github/copilot-instructions.md"
  fi

  if [[ "$USE_COPILOT" == true || "$USE_VSCODE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/instructions"
    local cinstr cinstr_count=0
    for cinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${cinstr}" ]]; then
        cp "${SHIP_DIR}/${cinstr}" "${PROJECT_PATH}/${cinstr}"
        cinstr_count=$((cinstr_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $cinstr_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/instructions/ (${cinstr_count} scoped instruction files)"
  fi

  # Context/ stubs — skip if exists (user may have filled them in)
  local cfile
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${SHIP_DIR}/${cfile}" ]] \
      && copy_platform_file "${SHIP_DIR}/${cfile}" "${PROJECT_PATH}/${cfile}" "${cfile}"
  done

  # Claude Code commands, hooks, and skills — always overwrite (AgToosa-owned)
  if [[ "$USE_CLAUDE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.claude/commands" "${PROJECT_PATH}/.claude/skills"
    local ccmd ccmd_count=0 cskill cskill_count=0
    for ccmd in "${CLAUDE_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${ccmd}" ]]; then
        cp "${SHIP_DIR}/${ccmd}" "${PROJECT_PATH}/${ccmd}"
        ccmd_count=$((ccmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $ccmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .claude/commands/ (${ccmd_count} slash commands)"

    [[ -f "${SHIP_DIR}/.claude/settings.json" ]] \
      && merge_settings_json "${SHIP_DIR}/.claude/settings.json" \
                             "${PROJECT_PATH}/.claude/settings.json" \
                             ".claude/settings.json"

    for cskill in "${CLAUDE_SKILL_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${cskill}" ]]; then
        cp "${SHIP_DIR}/${cskill}" "${PROJECT_PATH}/${cskill}"
        cskill_count=$((cskill_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $cskill_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .claude/skills/ (${cskill_count} project skill)"
  fi

  # Cursor rules and commands — always overwrite (AgToosa-owned)
  if [[ "$USE_CURSOR" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.cursor/rules" "${PROJECT_PATH}/.cursor/commands"
    local crule crule_count=0 ccmd ccmd_count=0
    for crule in "${CURSOR_RULE_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${crule}" ]]; then
        cp "${SHIP_DIR}/${crule}" "${PROJECT_PATH}/${crule}"
        crule_count=$((crule_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $crule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .cursor/rules/ (${crule_count} MDX rules)"

    for ccmd in "${CURSOR_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${ccmd}" ]]; then
        cp "${SHIP_DIR}/${ccmd}" "${PROJECT_PATH}/${ccmd}"
        ccmd_count=$((ccmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $ccmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .cursor/commands/ (${ccmd_count} slash commands)"
  fi

  # Gemini CLI native commands — always overwrite (AgToosa-owned)
  if [[ "$USE_GEMINI" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.gemini/commands"
    local gcmd gcmd_count=0
    for gcmd in "${GEMINI_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${gcmd}" ]]; then
        cp "${SHIP_DIR}/${gcmd}" "${PROJECT_PATH}/${gcmd}"
        gcmd_count=$((gcmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $gcmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .gemini/commands/ (${gcmd_count} TOML commands)"
  fi

  # GitHub Copilot reusable prompts + custom agent — always overwrite (AgToosa-owned)
  if [[ "$USE_COPILOT" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/prompts" "${PROJECT_PATH}/.github/agents"
    local pprompt pprompt_count=0
    for pprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${pprompt}" ]]; then
        cp "${SHIP_DIR}/${pprompt}" "${PROJECT_PATH}/${pprompt}"
        pprompt_count=$((pprompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $pprompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/prompts/ (${pprompt_count} reusable prompts)"
    local pagent
    for pagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${pagent}" ]]; then
        cp "${SHIP_DIR}/${pagent}" "${PROJECT_PATH}/${pagent}"
        COPIED=$((COPIED + 1))
        echo -e "  ${GREEN}✅${NC} .github/agents/agtoosa.agent.md"
      fi
    done
  fi

  # VS Code generic prompts + custom agent — always overwrite (AgToosa-owned)
  if [[ "$USE_VSCODE" == true && "$USE_COPILOT" != true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/prompts" "${PROJECT_PATH}/.github/agents"
    local vprompt vprompt_count=0
    for vprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${vprompt}" ]]; then
        cp "${SHIP_DIR}/${vprompt}" "${PROJECT_PATH}/${vprompt}"
        vprompt_count=$((vprompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $vprompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/prompts/ (${vprompt_count} reusable prompts)"
    local vagent
    for vagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${vagent}" ]]; then
        cp "${SHIP_DIR}/${vagent}" "${PROJECT_PATH}/${vagent}"
        COPIED=$((COPIED + 1))
        echo -e "  ${GREEN}✅${NC} .github/agents/agtoosa.agent.md"
      fi
    done
  fi

  # Codex skills — always overwrite (AgToosa-owned)
  if [[ "$USE_OPENCODE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.codex/skills"
    local codex_skill codex_skill_count=0
    for codex_skill in "${CODEX_SKILL_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${codex_skill}" ]]; then
        mkdir -p "$(dirname "${PROJECT_PATH}/${codex_skill}")"
        cp "${SHIP_DIR}/${codex_skill}" "${PROJECT_PATH}/${codex_skill}"
        codex_skill_count=$((codex_skill_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $codex_skill_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .codex/skills/ (${codex_skill_count} Codex skills)"

    mkdir -p "${PROJECT_PATH}/.codex/prompts"
    local codex_prompt codex_prompt_count=0
    for codex_prompt in "${CODEX_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${codex_prompt}" ]]; then
        mkdir -p "$(dirname "${PROJECT_PATH}/${codex_prompt}")"
        cp "${SHIP_DIR}/${codex_prompt}" "${PROJECT_PATH}/${codex_prompt}"
        codex_prompt_count=$((codex_prompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $codex_prompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .codex/prompts/ (${codex_prompt_count} Codex slash prompts)"
  fi

  # Windsurf rules and workflows — always overwrite (AgToosa-owned)
  if [[ "$USE_WINDSURF" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.windsurf/rules" "${PROJECT_PATH}/.windsurf/workflows"
    local wrule wrule_count=0 wflow wflow_count=0
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${wrule}" ]]; then
        cp "${SHIP_DIR}/${wrule}" "${PROJECT_PATH}/${wrule}"
        wrule_count=$((wrule_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $wrule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .windsurf/rules/ (${wrule_count} rules)"

    for wflow in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${wflow}" ]]; then
        cp "${SHIP_DIR}/${wflow}" "${PROJECT_PATH}/${wflow}"
        wflow_count=$((wflow_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $wflow_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .windsurf/workflows/ (${wflow_count} workflows)"
  fi


  # Merge durable pack queue, then any same-session ship/packs/ staging.
  local pack_count=0
  local new_lock_entries=()
  _merge_pack_queue
  pack_count=$((pack_count + _PACK_MERGE_COUNT))
  new_lock_entries+=("${_PACK_LOCK_ENTRIES[@]}")
  _merge_ship_staged_packs
  pack_count=$((pack_count + _PACK_MERGE_COUNT))
  new_lock_entries+=("${_PACK_LOCK_ENTRIES[@]}")
  [[ $pack_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} Packs merged: ${pack_count}"
  if [[ ${#new_lock_entries[@]} -gt 0 ]]; then
    _write_lock_file "${new_lock_entries[@]}"
  fi

  # Write version marker (enables --update to know installed version)
  echo "$AGTOOSA_VERSION" > "${PROJECT_PATH}/Docs/.agtoosa-version"

  # Summary
  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo -e "  ${GREEN}Copied:  ${COPIED} files${NC}"
  [[ $SKIPPED -gt 0 ]] && echo -e "  ${YELLOW}Skipped: ${SKIPPED} files (use --force to overwrite)${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} installed to ${PROJECT_PATH}${NC}"

  # DEV-131: warn about .bak files
  if [[ ${#BAK_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Backup files created — add this to your .gitignore to avoid committing them:${NC}"
    echo -e "    ${BOLD}*.bak.*${NC}"
    local bak
    for bak in "${BAK_FILES[@]}"; do
      echo -e "    ${CYAN}${bak#"${PROJECT_PATH}/"}${NC}"
    done
  fi

  echo ""
  echo -e "${BOLD}➡️  Next steps:${NC}"
  echo ""
  echo -e "  ${CYAN}1.${NC} Open your AI assistant in ${BOLD}${PROJECT_PATH}${NC}"
  echo ""
  echo -e "  ${CYAN}2.${NC} Run ${BOLD}/agtoosa-init${NC} to set up your project (one-time)"
  echo ""
  echo -e "  ${CYAN}3.${NC} Then use the 4-command workflow:"
  echo -e "     ${BOLD}/agtoosa-spec${NC}    → Research, specify, and plan"
  echo -e "     ${BOLD}/agtoosa-build${NC}   → TDD build and test"
  echo -e "     ${BOLD}/agtoosa-review${NC}  → Multi-persona code review"
  echo -e "     ${BOLD}/agtoosa-ship${NC}    → Deploy, archive, and suggest next"
  echo ""
}

# Print manual copy instructions and keep ship/ for the user.
manual_copy_instructions() {
  KEEP_SHIP=true
  echo ""
  echo -e "${YELLOW}Files are staged in ${BOLD}ship/${NC}${YELLOW} — copy them manually:${NC}"
  echo -e "  ${BOLD}cp -r ship/* ${PROJECT_PATH}/${NC}"
  echo -e "  ${BOLD}find ship/ -maxdepth 1 -name '.*' -exec cp -r {} ${PROJECT_PATH}/ \\;${NC}  ${CYAN}(for dotfiles)${NC}"
  echo -e "${CYAN}(Run 'rm -rf ship/' when done.)${NC}"
  echo ""
}
