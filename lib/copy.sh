#!/usr/bin/env bash

# ── AgToosa: file copy/merge helpers (copy, merge, backup) ───
# Sourced by agtoosa.sh.
# Globals read: FORCE, AGTOOSA_VERSION, colors (GREEN/YELLOW/CYAN/NC).
# Globals modified: COPIED, SKIPPED, BAK_FILES.

BAK_FILES=()

# Create a timestamped .bak and return its path.
backup_file() {
  local f="$1"
  local bak
  bak="${f}.bak.$(date +%Y%m%d-%H%M)"
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
    if grep -qE 'AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START' "$src" 2>/dev/null; then
      cat "$src" >> "$tmp_out"
    else
      local tmp_injected
      tmp_injected="$(mktemp)"
      inject_version "$src" "$tmp_injected"
      cat "$tmp_injected" >> "$tmp_out"
      rm -f "$tmp_injected"
    fi
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

# Deep-merge AgToosa hooks into an existing .claude/settings.json without touching user settings.
# New file → plain copy. Existing file → Python3 merges hooks arrays, deduplicating by command string.
merge_settings_json() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"

  if [[ ! -f "$dst" ]]; then
    cp "$src" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label}"
    COPIED=$((COPIED + 1))
    return
  fi

  local tmp
  tmp="$(mktemp)"
  if python3 - "$src" "$dst" "$tmp" <<'PYEOF'
import json, sys

src_path, dst_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]

with open(src_path) as f:
    new_cfg = json.load(f)
with open(dst_path) as f:
    existing = json.load(f)

for event, handlers in new_cfg.get('hooks', {}).items():
    existing.setdefault('hooks', {}).setdefault(event, [])
    existing_cmds = {
        h.get('command', '')
        for entry in existing['hooks'][event]
        for h in entry.get('hooks', [])
    }
    for handler in handlers:
        # Deduplicate by command string: append only novel commands
        novel = [h for h in handler.get('hooks', [])
                 if h.get('command', '') not in existing_cmds]
        if not novel:
            continue
        entry = {k: v for k, v in handler.items() if k != 'hooks'}
        entry['hooks'] = novel
        existing['hooks'][event].append(entry)
        for h in novel:
            existing_cmds.add(h.get('command', ''))

with open(out_path, 'w') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
PYEOF
  then
    mv "$tmp" "$dst"
    echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(hooks merged)${NC}"
    COPIED=$((COPIED + 1))
  else
    rm -f "$tmp"
    echo -e "  ${YELLOW}⚠️${NC}  ${label} — Python3 unavailable or JSON parse error, skipped"
    SKIPPED=$((SKIPPED + 1))
  fi
}
