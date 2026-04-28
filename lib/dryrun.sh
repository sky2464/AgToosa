# ── AgToosa: dry-run preview ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, FORCE, AGTOOSA_VERSION, colors.

print_dryrun_preview() {
  echo -e "${YELLOW}[DRY RUN] Would copy the following files to ${PROJECT_PATH}:${NC}"
  echo ""

  local f target old_ver
  while IFS= read -r f; do
    target="${PROJECT_PATH}/${f}"

    if [[ "$f" == .claude/commands/* || "$f" == .claude/skills/* || "$f" == .cursor/rules/* \
       || "$f" == .gemini/commands/* \
       || "$f" == .github/prompts/* || "$f" == .github/agents/* \
       || "$f" == .windsurf/rules/* ]]; then
      echo -e "  ${GREEN}✅${NC} ${f}  → Would overwrite (AgToosa-owned, always updated)"

    elif [[ "$f" == .claude/settings.json ]]; then
      if [[ -f "$target" ]]; then
        echo -e "  ${CYAN}🔀${NC} ${f}  → Would merge AgToosa hooks into existing settings"
      else
        echo -e "  ${GREEN}✅${NC} ${f}  → New file"
      fi

    elif [[ ! -f "$target" ]]; then
      echo -e "  ${GREEN}✅${NC} ${f}  → New file"

    elif [[ "$f" == Docs/Context/* ]]; then
      if [[ "$FORCE" == true ]]; then
        old_ver="$(extract_version "$target")"
        echo -e "  ${CYAN}📦${NC} ${f}  → Would backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
      else
        echo -e "  ${YELLOW}⏭${NC}  ${f}  → Would skip (exists, use --force to overwrite)"
      fi

    elif [[ "$f" == Docs/* ]]; then
      echo -e "  ${GREEN}✅${NC} ${f}  → Would overwrite (workflow file, always updated)"

    elif [[ "$FORCE" == true ]]; then
      old_ver="$(extract_version "$target")"
      if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
        echo -e "  ${YELLOW}⏭${NC}  ${f}  → Would keep (same version, preserving customizations)"
      else
        echo -e "  ${CYAN}📦${NC} ${f}  → Would backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
      fi

    else
      old_ver="$(extract_version "$target")"
      if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
        echo -e "  ${GREEN}✅${NC} ${f}  → Already up to date (v${AGTOOSA_VERSION})"
      elif grep -qE 'AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START' "$target" 2>/dev/null; then
        echo -e "  ${CYAN}🔀${NC} ${f}  → Would backup + merge AgToosa block (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
      elif [[ -n "$old_ver" ]]; then
        echo -e "  ${CYAN}📦${NC} ${f}  → Would backup + replace (v${old_ver} → v${AGTOOSA_VERSION}, old format)"
      else
        echo -e "  ${CYAN}🔀${NC} ${f}  → Would backup + append AgToosa block to existing file"
      fi
    fi

  done < <(find "$SHIP_DIR" -type f | sed "s|${SHIP_DIR}/||" | sort)

  echo ""
  echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply.${NC}"
  echo ""
}
