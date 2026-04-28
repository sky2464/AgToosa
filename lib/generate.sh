# ── AgToosa: stage files into ship/ ──────────────────────────
# Sourced by agtoosa.sh.
# Globals read: TEMPLATE_DIR, SHIP_DIR, USE_*, DOCS_FILES, CONTEXT_FILES, colors.
# Globals modified: GENERATED.

stage_files() {
  local file

  # Core workflow docs — always included
  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${TEMPLATE_DIR}/${file}" ]]; then
      cp "${TEMPLATE_DIR}/${file}" "${SHIP_DIR}/${file}"
      echo -e "  ${GREEN}✅${NC} ${file}"
      GENERATED=$((GENERATED + 1))
    fi
  done

  # Platform entry-point files — inject version marker
  if [[ "$USE_CURSOR" == true ]]; then
    inject_version "${TEMPLATE_DIR}/.cursorrules" "${SHIP_DIR}/.cursorrules"
    echo -e "  ${GREEN}✅${NC} .cursorrules ${CYAN}(Cursor)${NC}"
    GENERATED=$((GENERATED + 1))
  fi

  if [[ "$USE_WINDSURF" == true ]]; then
    inject_version "${TEMPLATE_DIR}/.windsurfrules" "${SHIP_DIR}/.windsurfrules"
    echo -e "  ${GREEN}✅${NC} .windsurfrules ${CYAN}(Windsurf)${NC}"
    GENERATED=$((GENERATED + 1))
  fi

  if [[ "$USE_CLAUDE" == true ]]; then
    inject_version "${TEMPLATE_DIR}/CLAUDE.md" "${SHIP_DIR}/CLAUDE.md"
    cp "${TEMPLATE_DIR}/Docs/AgToosa_Claude.md" "${SHIP_DIR}/Docs/AgToosa_Claude.md"
    echo -e "  ${GREEN}✅${NC} CLAUDE.md + Docs/AgToosa_Claude.md ${CYAN}(Claude Code)${NC}"
    GENERATED=$((GENERATED + 2))
  fi

  if [[ "$USE_GEMINI" == true ]]; then
    inject_version "${TEMPLATE_DIR}/AGENTS.md" "${SHIP_DIR}/AGENTS.md"
    cp "${TEMPLATE_DIR}/Docs/AgToosa_Gemini.md" "${SHIP_DIR}/Docs/AgToosa_Gemini.md"
    echo -e "  ${GREEN}✅${NC} AGENTS.md + Docs/AgToosa_Gemini.md ${CYAN}(Gemini CLI / Jules)${NC}"
    GENERATED=$((GENERATED + 2))
  fi

  if [[ "$USE_COPILOT" == true ]]; then
    mkdir -p "${SHIP_DIR}/.github"
    inject_version "${TEMPLATE_DIR}/.github/copilot-instructions.md" "${SHIP_DIR}/.github/copilot-instructions.md"
    echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
    GENERATED=$((GENERATED + 1))
  fi

  if [[ "$USE_OPENCODE" == true ]]; then
    local opencode_count=0
    if [[ -f "${TEMPLATE_DIR}/.roorules" ]]; then
      inject_version "${TEMPLATE_DIR}/.roorules" "${SHIP_DIR}/.roorules"
      opencode_count=$((opencode_count + 1))
    fi
    if [[ -f "${TEMPLATE_DIR}/OPENCODE.md" ]]; then
      inject_version "${TEMPLATE_DIR}/OPENCODE.md" "${SHIP_DIR}/OPENCODE.md"
      opencode_count=$((opencode_count + 1))
    fi
    if [[ $opencode_count -gt 0 ]]; then
      echo -e "  ${GREEN}✅${NC} .roorules + OPENCODE.md ${CYAN}(Roo / OpenCode)${NC}"
      GENERATED=$((GENERATED + opencode_count))
    fi
  fi

  # Context/ stubs — staged for skip-if-exists copy
  local cfile context_staged=0
  for cfile in "${CONTEXT_FILES[@]}"; do
    if [[ -f "${TEMPLATE_DIR}/${cfile}" ]]; then
      cp "${TEMPLATE_DIR}/${cfile}" "${SHIP_DIR}/${cfile}"
      context_staged=$((context_staged + 1))
      GENERATED=$((GENERATED + 1))
    fi
  done
  if [[ $context_staged -gt 0 ]]; then
    echo -e "  ${GREEN}✅${NC} Docs/Context/ ${CYAN}(${context_staged} config stubs — fill in during /agtoosa-init)${NC}"
  fi

  # Claude Code native commands, hooks, and skills — staged when Claude selected
  if [[ "$USE_CLAUDE" == true ]]; then
    mkdir -p "${SHIP_DIR}/.claude/commands" "${SHIP_DIR}/.claude/skills"
    local cmd cmd_count=0 skill skill_count=0
    for cmd in "${CLAUDE_COMMAND_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${cmd}" ]]; then
        cp "${TEMPLATE_DIR}/${cmd}" "${SHIP_DIR}/${cmd}"
        cmd_count=$((cmd_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $cmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .claude/commands/ ${CYAN}(${cmd_count} slash commands — native /agtoosa-* in Claude Code)${NC}"

    if [[ -f "${TEMPLATE_DIR}/.claude/settings.json" ]]; then
      cp "${TEMPLATE_DIR}/.claude/settings.json" "${SHIP_DIR}/.claude/settings.json"
      echo -e "  ${GREEN}✅${NC} .claude/settings.json ${CYAN}(hooks: Stop, PreToolUse, PostToolUse)${NC}"
      GENERATED=$((GENERATED + 1))
    fi

    for skill in "${CLAUDE_SKILL_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${skill}" ]]; then
        cp "${TEMPLATE_DIR}/${skill}" "${SHIP_DIR}/${skill}"
        skill_count=$((skill_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $skill_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .claude/skills/ ${CYAN}(${skill_count} project skill — agtoosa-review)${NC}"
  fi

  # Cursor rules — staged when Cursor selected
  if [[ "$USE_CURSOR" == true ]]; then
    mkdir -p "${SHIP_DIR}/.cursor/rules"
    local rule rule_count=0
    for rule in "${CURSOR_RULE_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${rule}" ]]; then
        cp "${TEMPLATE_DIR}/${rule}" "${SHIP_DIR}/${rule}"
        rule_count=$((rule_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $rule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .cursor/rules/ ${CYAN}(${rule_count} MDX rules — native Cursor rule injection)${NC}"
  fi

  # Gemini CLI native commands — staged when Gemini selected
  if [[ "$USE_GEMINI" == true ]]; then
    mkdir -p "${SHIP_DIR}/.gemini/commands"
    local gcmd gcmd_count=0
    for gcmd in "${GEMINI_COMMAND_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${gcmd}" ]]; then
        cp "${TEMPLATE_DIR}/${gcmd}" "${SHIP_DIR}/${gcmd}"
        gcmd_count=$((gcmd_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $gcmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .gemini/commands/ ${CYAN}(${gcmd_count} TOML commands — native /agtoosa-* in Gemini CLI)${NC}"
  fi

  # GitHub Copilot reusable prompts + custom agent — staged when Copilot selected
  if [[ "$USE_COPILOT" == true ]]; then
    mkdir -p "${SHIP_DIR}/.github/prompts" "${SHIP_DIR}/.github/agents"
    local pprompt pprompt_count=0
    for pprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${pprompt}" ]]; then
        cp "${TEMPLATE_DIR}/${pprompt}" "${SHIP_DIR}/${pprompt}"
        pprompt_count=$((pprompt_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $pprompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/prompts/ ${CYAN}(${pprompt_count} reusable prompts — native Copilot prompt files)${NC}"
    local pagent
    for pagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${pagent}" ]]; then
        cp "${TEMPLATE_DIR}/${pagent}" "${SHIP_DIR}/${pagent}"
        GENERATED=$((GENERATED + 1))
      fi
    done
    echo -e "  ${GREEN}✅${NC} .github/agents/agtoosa.agent.md ${CYAN}(custom Copilot agent)${NC}"
  fi

  # Windsurf rules — staged when Windsurf selected
  if [[ "$USE_WINDSURF" == true ]]; then
    mkdir -p "${SHIP_DIR}/.windsurf/rules"
    local wrule wrule_count=0
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${wrule}" ]]; then
        cp "${TEMPLATE_DIR}/${wrule}" "${SHIP_DIR}/${wrule}"
        wrule_count=$((wrule_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $wrule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .windsurf/rules/ ${CYAN}(${wrule_count} rules — native Windsurf rule injection)${NC}"
  fi

  # Roo / OpenCode rules — staged when OpenCode selected
  if [[ "$USE_OPENCODE" == true ]]; then
    mkdir -p "${SHIP_DIR}/.roo/rules"
    local rrule rrule_count=0
    for rrule in "${ROO_RULE_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${rrule}" ]]; then
        cp "${TEMPLATE_DIR}/${rrule}" "${SHIP_DIR}/${rrule}"
        rrule_count=$((rrule_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $rrule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .roo/rules/ ${CYAN}(${rrule_count} rules — native Roo/OpenCode rule injection)${NC}"
  fi
}
