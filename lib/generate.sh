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
}
