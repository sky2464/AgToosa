# ── AgToosa: file copy/merge helpers (DEV-128, DEV-130, DEV-139, DEV-157) ───
# Sourced by agtoosa.sh.
# Globals read: FORCE, AGTOOSA_VERSION, colors (GREEN/YELLOW/CYAN/NC).
# Globals modified: COPIED, SKIPPED, BAK_FILES.

BAK_FILES=()

# Create a timestamped .bak and return its path.
backup_file() {
  local f="$1"
  local bak="${f}.bak.$(date +%Y%m%d-%H%M)"
  cp "$f" "$bak"
  printf '%s' "$bak"
}

# Copy a file to dst, respecting --force and version guards.
# Used for Context/ stubs and other skip-if-exists files.
copy_platform_file() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"

  if [[ ! -f "$dst" ]]; then
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label}"
    COPIED=$((COPIED + 1))
    return
  fi

  if [[ "$FORCE" == false ]]; then
    echo -e "  ${YELLOW}⏭${NC}  Skipping ${label} (exists, use --force to overwrite)"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  local old_ver
  old_ver="$(extract_version "$dst")"
  if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
    echo -e "  ${YELLOW}⏭${NC}  ${label} ${CYAN}(v${AGTOOSA_VERSION} — keeping your customizations)${NC}"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  local bak
  bak="$(backup_file "$dst")"
  BAK_FILES+=("$bak")
  cp "$src" "$dst"
  echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${old_ver:-unknown} → v${AGTOOSA_VERSION}, backup: $(basename "$bak"))${NC}"
  COPIED=$((COPIED + 1))
}

# Merge/append an AgToosa block into a platform entry-point file.
# Case A: new file → plain copy.
# Case B: existing AgToosa START/END block → update in-place (with .bak if older).
# Case C: old-format AgToosa file (no delimiters) → replace (with .bak if older).
# Case D: user's own file → backup + append block.
# --force: backup + full replace (same-or-newer version is always kept).
merge_platform_file() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"

  # Case A
  if [[ ! -f "$dst" ]]; then
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label}"
    COPIED=$((COPIED + 1))
    return
  fi

  local old_ver
  old_ver="$(extract_version "$dst")"

  # --force path
  if [[ "$FORCE" == true ]]; then
    if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
      echo -e "  ${YELLOW}⏭${NC}  ${label} ${CYAN}(v${AGTOOSA_VERSION} — keeping your customizations)${NC}"
      SKIPPED=$((SKIPPED + 1))
      return
    fi
    local bak
    bak="$(backup_file "$dst")"
    BAK_FILES+=("$bak")
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${old_ver:-unknown} → v${AGTOOSA_VERSION}, backup: $(basename "$bak"))${NC}"
    COPIED=$((COPIED + 1))
    return
  fi

  # Case B: existing START/END block
  if grep -qE 'AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START' "$dst" 2>/dev/null; then
    if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
      echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${AGTOOSA_VERSION}, up to date)${NC}"
      COPIED=$((COPIED + 1))
      return
    fi
    local bak tmp_out
    bak="$(backup_file "$dst")"
    BAK_FILES+=("$bak")
    tmp_out="$(mktemp)"
    awk '/AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START/{in_block=1;next} in_block && /AgToosa END/{in_block=0;next} !in_block{print}' "$dst" > "$tmp_out"
    printf '\n' >> "$tmp_out"
    cat "$src" >> "$tmp_out"
    mv "$tmp_out" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(merged: v${old_ver:-unknown} → v${AGTOOSA_VERSION}, backup: $(basename "$bak"))${NC}"
    COPIED=$((COPIED + 1))
    return
  fi

  # Case C: old-format AgToosa file
  if [[ -n "$old_ver" ]]; then
    if ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
      echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${AGTOOSA_VERSION}, up to date)${NC}"
      COPIED=$((COPIED + 1))
      return
    fi
    local bak
    bak="$(backup_file "$dst")"
    BAK_FILES+=("$bak")
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${old_ver} → v${AGTOOSA_VERSION}, backup: $(basename "$bak"))${NC}"
    COPIED=$((COPIED + 1))
    return
  fi

  # Case D: user-owned file — backup + append
  local bak tmp_out
  bak="$(backup_file "$dst")"
  BAK_FILES+=("$bak")
  tmp_out="$(mktemp)"
  cat "$dst" > "$tmp_out"
  printf '\n\n' >> "$tmp_out"
  cat "$src" >> "$tmp_out"
  mv "$tmp_out" "$dst"
  echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(appended to existing file, backup: $(basename "$bak"))${NC}"
  COPIED=$((COPIED + 1))
}
