#!/usr/bin/env bash

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
    mkdir -p "${SHIP_DIR}/.github" "${SHIP_DIR}/.github/instructions"
    inject_version "${TEMPLATE_DIR}/.github/copilot-instructions.md" "${SHIP_DIR}/.github/copilot-instructions.md"
    echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
    GENERATED=$((GENERATED + 1))

    local cinstr cinstr_count=0
    for cinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${cinstr}" ]]; then
        cp "${TEMPLATE_DIR}/${cinstr}" "${SHIP_DIR}/${cinstr}"
        cinstr_count=$((cinstr_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $cinstr_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/instructions/ ${CYAN}(${cinstr_count} scoped instruction files)${NC}"
  fi

  if [[ "$USE_OPENCODE" == true ]]; then
    local opencode_count=0 cskill cskill_count=0
    if [[ -f "${TEMPLATE_DIR}/OPENCODE.md" ]]; then
      inject_version "${TEMPLATE_DIR}/OPENCODE.md" "${SHIP_DIR}/OPENCODE.md"
      opencode_count=$((opencode_count + 1))
    fi
    if [[ $opencode_count -gt 0 ]]; then
      echo -e "  ${GREEN}\u2705${NC} OPENCODE.md ${CYAN}(Codex / OpenCode / Other)${NC}"
      GENERATED=$((GENERATED + opencode_count))
    fi

    mkdir -p "${SHIP_DIR}/.codex/skills"
    for cskill in "${CODEX_SKILL_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${cskill}" ]]; then
        mkdir -p "$(dirname "${SHIP_DIR}/${cskill}")"
        cp "${TEMPLATE_DIR}/${cskill}" "${SHIP_DIR}/${cskill}"
        cskill_count=$((cskill_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $cskill_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .codex/skills/ ${CYAN}(${cskill_count} Codex skills — discoverable AgToosa workflows)${NC}"

    mkdir -p "${SHIP_DIR}/.codex/prompts"
    local cprompt cprompt_count=0
    for cprompt in "${CODEX_PROMPT_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${cprompt}" ]]; then
        mkdir -p "$(dirname "${SHIP_DIR}/${cprompt}")"
        cp "${TEMPLATE_DIR}/${cprompt}" "${SHIP_DIR}/${cprompt}"
        cprompt_count=$((cprompt_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $cprompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .codex/prompts/ ${CYAN}(${cprompt_count} Codex slash prompts — native /agtoosa-* in Codex)${NC}"
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

  # Cursor rules and commands — staged when Cursor selected
  if [[ "$USE_CURSOR" == true ]]; then
    mkdir -p "${SHIP_DIR}/.cursor/rules" "${SHIP_DIR}/.cursor/commands"
    local rule rule_count=0 ccmd ccmd_count=0
    for rule in "${CURSOR_RULE_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${rule}" ]]; then
        cp "${TEMPLATE_DIR}/${rule}" "${SHIP_DIR}/${rule}"
        rule_count=$((rule_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $rule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .cursor/rules/ ${CYAN}(${rule_count} MDX rules — native Cursor rule injection)${NC}"

    for ccmd in "${CURSOR_COMMAND_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${ccmd}" ]]; then
        cp "${TEMPLATE_DIR}/${ccmd}" "${SHIP_DIR}/${ccmd}"
        ccmd_count=$((ccmd_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $ccmd_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .cursor/commands/ ${CYAN}(${ccmd_count} slash commands — native Cursor command picker)${NC}"
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

  # VS Code generic — staged when VS Code selected (skipped if Copilot already covers it)
  if [[ "$USE_VSCODE" == true && "$USE_COPILOT" != true ]]; then
    mkdir -p "${SHIP_DIR}/.github/prompts" "${SHIP_DIR}/.github/agents" "${SHIP_DIR}/.github/instructions"
    inject_version "${TEMPLATE_DIR}/.github/copilot-instructions.md" "${SHIP_DIR}/.github/copilot-instructions.md"
    echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(VS Code)${NC}"
    GENERATED=$((GENERATED + 1))

    local vinstr vinstr_count=0
    for vinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${vinstr}" ]]; then
        cp "${TEMPLATE_DIR}/${vinstr}" "${SHIP_DIR}/${vinstr}"
        vinstr_count=$((vinstr_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $vinstr_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/instructions/ ${CYAN}(${vinstr_count} scoped instruction files)${NC}"

    local vprompt vprompt_count=0
    for vprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${vprompt}" ]]; then
        cp "${TEMPLATE_DIR}/${vprompt}" "${SHIP_DIR}/${vprompt}"
        vprompt_count=$((vprompt_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $vprompt_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .github/prompts/ ${CYAN}(${vprompt_count} slash commands — /agtoosa-* in VS Code Copilot)${NC}"
    local vagent
    for vagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${vagent}" ]]; then
        cp "${TEMPLATE_DIR}/${vagent}" "${SHIP_DIR}/${vagent}"
        GENERATED=$((GENERATED + 1))
      fi
    done
    echo -e "  ${GREEN}✅${NC} .github/agents/agtoosa.agent.md ${CYAN}(custom Copilot agent)${NC}"
  fi

  # Windsurf rules and workflows — staged when Windsurf selected
  if [[ "$USE_WINDSURF" == true ]]; then
    mkdir -p "${SHIP_DIR}/.windsurf/rules" "${SHIP_DIR}/.windsurf/workflows"
    local wrule wrule_count=0 wflow wflow_count=0
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${wrule}" ]]; then
        cp "${TEMPLATE_DIR}/${wrule}" "${SHIP_DIR}/${wrule}"
        wrule_count=$((wrule_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $wrule_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .windsurf/rules/ ${CYAN}(${wrule_count} rules — native Windsurf rule injection)${NC}"

    for wflow in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      if [[ -f "${TEMPLATE_DIR}/${wflow}" ]]; then
        cp "${TEMPLATE_DIR}/${wflow}" "${SHIP_DIR}/${wflow}"
        wflow_count=$((wflow_count + 1))
        GENERATED=$((GENERATED + 1))
      fi
    done
    [[ $wflow_count -gt 0 ]] && echo -e "  ${GREEN}✅${NC} .windsurf/workflows/ ${CYAN}(${wflow_count} workflows — native Windsurf command picker)${NC}"
  fi
}
