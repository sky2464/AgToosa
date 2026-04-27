# ── AgToosa: install helpers ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, FORCE, USE_*, DOCS_FILES, CONTEXT_FILES,
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
  [[ "$USE_OPENCODE" == true && -f "${PROJECT_PATH}/.roorules" ]]                       && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_OPENCODE" == true && -f "${PROJECT_PATH}/OPENCODE.md" ]]                     && EXISTING_FILES=$((EXISTING_FILES + 1))
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${PROJECT_PATH}/${cfile}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  done
}

# Copy all staged files from ship/ into PROJECT_PATH, then print summary + next steps.
install_files() {
  mkdir -p "${PROJECT_PATH}/Docs/archived" "${PROJECT_PATH}/Docs/Context"

  # DEV-134: Docs/ workflow files always overwrite
  local file
  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${file}" ]]; then
      cp "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}"
      echo -e "  ${GREEN}✅${NC} ${file}"
      COPIED=$((COPIED + 1))
    fi
  done

  # Platform entry-point dotfiles — smart merge/append
  local dotfile
  for dotfile in .cursorrules .windsurfrules .roorules; do
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

  # Context/ stubs — skip if exists (user may have filled them in)
  local cfile
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${SHIP_DIR}/${cfile}" ]] \
      && copy_platform_file "${SHIP_DIR}/${cfile}" "${PROJECT_PATH}/${cfile}" "${cfile}"
  done

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
