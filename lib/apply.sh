#!/usr/bin/env bash

# ── AgToosa: transactional apply + hash-aware commit (DEV-092) ──
# Sourced by agtoosa.sh after copy.sh.
# Globals: APPLY_STAGING_ROOT, APPLY_WRITTEN, APPLY_MERGED, APPLY_UNCHANGED, APPLY_FAILED
# Inject: AGTOOSA_APPLY_FAIL_ON=<relpath> forces commit failure for tests.

APPLY_STAGING_ROOT=""
APPLY_WRITTEN=0
APPLY_MERGED=0
APPLY_UNCHANGED=0
APPLY_FAILED=0
APPLY_PRESERVED=0
SMART_UPGRADE_MODE=false
OLD_INSTALLED_VERSION=""
SMART_APPLY_USE_UPDATE=false

apply_reset_summary() {
  APPLY_WRITTEN=0
  APPLY_MERGED=0
  APPLY_UNCHANGED=0
  APPLY_FAILED=0
  APPLY_PRESERVED=0
}

apply_print_summary() {
  echo "apply summary: written=${APPLY_WRITTEN} merged=${APPLY_MERGED} unchanged=${APPLY_UNCHANGED} preserved=${APPLY_PRESERVED} failed=${APPLY_FAILED}"
}

apply_note_preserved() {
  APPLY_PRESERVED=$((APPLY_PRESERVED + 1))
}

# Return 0 when project already has AgToosa installed.
detect_existing_agtoosa() {
  local project_path="$1"
  [[ -f "${project_path}/Docs/.agtoosa-version" ]] && return 0
  [[ -f "${project_path}/Docs/AgToosa_Agent.md" ]] && return 0
  return 1
}

# True when a Context/ file is still an unfilled template stub (safe to refresh).
context_is_placeholder_file() {
  local f="$1"
  local rel tpl src

  [[ -f "$f" ]] || return 1
  if grep -qE '\[name\]|\[url\]|\[e\.g\.' "$f" 2>/dev/null; then
    return 0
  fi
  rel="${f#"${PROJECT_PATH}/"}"
  for tpl in "${TEMPLATE_DIR}/${rel}" "${SHIP_DIR:-}/${rel}"; do
    [[ -f "$tpl" ]] || continue
    if [[ "$(apply_content_sha256 "$f")" == "$(apply_content_sha256 "$tpl")" ]]; then
      return 0
    fi
  done
  return 1
}

# Human-readable platform list from USE_* globals.
platform_flags_to_names() {
  local -a names=()
  [[ "${USE_CURSOR:-false}" == true ]] && names+=("Cursor")
  [[ "${USE_WINDSURF:-false}" == true ]] && names+=("Windsurf")
  [[ "${USE_CLAUDE:-false}" == true ]] && names+=("Claude Code")
  [[ "${USE_GEMINI:-false}" == true ]] && names+=("Gemini")
  [[ "${USE_COPILOT:-false}" == true ]] && names+=("GitHub Copilot")
  [[ "${USE_VSCODE:-false}" == true ]] && names+=("VS Code")
  [[ "${USE_OPENCODE:-false}" == true ]] && names+=("Codex/OpenCode")
  if ((${#names[@]} == 0)); then
    echo "none"
  else
    local IFS=', '
    echo "${names[*]}"
  fi
}

# Set USE_* from a space-separated selection string (digits 1-8).
apply_platform_selection() {
  local selection="$1"
  USE_CURSOR=false; USE_WINDSURF=false; USE_CLAUDE=false
  USE_GEMINI=false; USE_COPILOT=false; USE_OPENCODE=false; USE_VSCODE=false
  if [[ "$selection" == *"8"* ]]; then
    USE_CURSOR=true; USE_WINDSURF=true; USE_CLAUDE=true
    USE_GEMINI=true; USE_COPILOT=true; USE_OPENCODE=true; USE_VSCODE=true
    return 0
  fi
  [[ "$selection" == *"1"* ]] && USE_CURSOR=true || true
  [[ "$selection" == *"2"* ]] && USE_WINDSURF=true || true
  [[ "$selection" == *"3"* ]] && USE_CLAUDE=true || true
  [[ "$selection" == *"4"* ]] && USE_GEMINI=true || true
  [[ "$selection" == *"5"* ]] && USE_COPILOT=true || true
  [[ "$selection" == *"6"* ]] && USE_VSCODE=true || true
  [[ "$selection" == *"7"* ]] && USE_OPENCODE=true || true
  return 0
}

# Union additional platform selection digits into current USE_* flags.
union_platform_selection() {
  local add_selection="$1"
  local uc uw ucl ug uco uv uop
  uc="$USE_CURSOR"; uw="$USE_WINDSURF"; ucl="$USE_CLAUDE"
  ug="$USE_GEMINI"; uco="$USE_COPILOT"; uv="$USE_VSCODE"; uop="$USE_OPENCODE"
  apply_platform_selection "$add_selection"
  [[ "$uc" == true ]] && USE_CURSOR=true || true
  [[ "$uw" == true ]] && USE_WINDSURF=true || true
  [[ "$ucl" == true ]] && USE_CLAUDE=true || true
  [[ "$ug" == true ]] && USE_GEMINI=true || true
  [[ "$uco" == true ]] && USE_COPILOT=true || true
  [[ "$uv" == true ]] && USE_VSCODE=true || true
  [[ "$uop" == true ]] && USE_OPENCODE=true || true
  return 0
}

emit_apply_summary_human() {
  local verb="${1:-installed}"
  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  [[ "${APPLY_WRITTEN:-0}" -gt 0 ]] \
    && echo -e "  ${GREEN}Updated:${NC}    ${APPLY_WRITTEN} framework files"
  [[ "${APPLY_PRESERVED:-0}" -gt 0 ]] \
    && echo -e "  ${BLUE}Preserved:${NC}  ${APPLY_PRESERVED} project files (your plan, context, changelog)"
  [[ "${APPLY_UNCHANGED:-0}" -gt 0 ]] \
    && echo -e "  ${CYAN}Unchanged:${NC}  ${APPLY_UNCHANGED} files already up to date"
  [[ "${APPLY_MERGED:-0}" -gt 0 ]] \
    && echo -e "  ${CYAN}Merged:${NC}     ${APPLY_MERGED} platform config(s)"
  [[ "${APPLY_FAILED:-0}" -gt 0 ]] \
    && echo -e "  ${RED}Failed:${NC}     ${APPLY_FAILED} files"
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  if [[ "$verb" == "applied" ]]; then
    echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} applied to ${PROJECT_PATH}${NC}"
  else
    echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} ${verb} to ${PROJECT_PATH}${NC}"
  fi
}

# Unified apply entry: ship-based install or template-based update.
smart_apply() {
  apply_reset_summary
  COPIED=0
  SKIPPED=0
  BAK_FILES=("${BAK_FILES[@]+"${BAK_FILES[@]}"}")

  if [[ "${SMART_APPLY_USE_UPDATE:-false}" == true ]]; then
    local old_ver="${OLD_INSTALLED_VERSION:-$(read_installed_version "$PROJECT_PATH")}"
    run_update "$old_ver"
    return $?
  fi

  install_files
}

apply_content_sha256() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    sha256sum "$f" | awk '{print $1}'
  fi
}

# Create a staging root outside the project tree (never under PROJECT_PATH).
apply_begin_staging() {
  local project_path="$1"
  apply_abort_staging
  APPLY_STAGING_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agtoosa-apply.XXXXXX")"
  chmod 700 "$APPLY_STAGING_ROOT" 2>/dev/null || true
  # Record project for safety checks
  APPLY_PROJECT_PATH="$project_path"
}

apply_abort_staging() {
  if [[ -n "${APPLY_STAGING_ROOT:-}" && -d "${APPLY_STAGING_ROOT:-}" ]]; then
    rm -rf "$APPLY_STAGING_ROOT"
  fi
  APPLY_STAGING_ROOT=""
}

# Stage one file: copy src into staging at relative path.
apply_stage_file() {
  local src="$1" rel="$2"
  local dest
  [[ -n "$APPLY_STAGING_ROOT" ]] || { echo "apply: staging not begun" >&2; return 1; }
  [[ -f "$src" ]] || { echo "apply: missing source $src" >&2; return 1; }
  dest="${APPLY_STAGING_ROOT}/${rel}"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

# Commit all staged files into project. On any failure, leave project unchanged
# for files not yet committed by rolling back via not writing until validated.
# Strategy: validate all staged files first (hash + inject), then write.
# Optional 2nd arg: apply command label for .agtoosa/state.json (install|update|apply).
apply_commit_staging() {
  local project_path="$1"
  local apply_command="${2:-apply}"
  local rel staged target staged_hash target_hash mode
  local -a commit_list=()

  [[ -n "$APPLY_STAGING_ROOT" && -d "$APPLY_STAGING_ROOT" ]] || {
    echo "apply: no staging root" >&2
    return 1
  }

  # Fail-closed: refuse staging rooted inside the project
  case "$APPLY_STAGING_ROOT" in
    "${project_path}"/*)
      echo "apply: staging root must not be inside project" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
      ;;
  esac

  # Pack SHA revalidation before any project mutation or state write (DEV-093).
  if declare -F lock_revalidate_packs >/dev/null 2>&1; then
    if ! lock_revalidate_packs "$project_path"; then
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
  fi

  while IFS= read -r -d '' staged; do
    rel="${staged#"${APPLY_STAGING_ROOT}/"}"
    if [[ -n "${AGTOOSA_APPLY_FAIL_ON:-}" && "$rel" == "$AGTOOSA_APPLY_FAIL_ON" ]]; then
      echo "apply: injected failure on $rel" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if [[ -L "$staged" ]]; then
      echo "apply: refusing symlink in staging: $rel" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    commit_list+=("$rel")
  done < <(find "$APPLY_STAGING_ROOT" -type f -print0)

  for rel in "${commit_list[@]}"; do
    staged="${APPLY_STAGING_ROOT}/${rel}"
    target="${project_path}/${rel}"
    staged_hash="$(apply_content_sha256 "$staged")"
    if [[ -f "$target" ]]; then
      target_hash="$(apply_content_sha256 "$target")"
      if [[ "$staged_hash" == "$target_hash" ]]; then
        APPLY_UNCHANGED=$((APPLY_UNCHANGED + 1))
        continue
      fi
      mode="written"
    else
      mode="written"
    fi
    mkdir -p "$(dirname "$target")"
    # Atomic-ish: write via temp in same dir then rename
    local tmp
    tmp="${target}.agtoosa-tmp.$$"
    if ! cp "$staged" "$tmp"; then
      echo "apply: failed writing $rel" >&2
      rm -f "$tmp" 2>/dev/null || true
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if ! mv "$tmp" "$target"; then
      echo "apply: failed committing $rel" >&2
      rm -f "$tmp" 2>/dev/null || true
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if [[ "$mode" == "written" ]]; then
      APPLY_WRITTEN=$((APPLY_WRITTEN + 1))
    fi
  done

  apply_abort_staging

  # Post-apply operational state + lock reconcile (DEV-093).
  if declare -F lock_reconcile >/dev/null 2>&1; then
    lock_reconcile "$project_path"
  fi
  if declare -F state_write_after_apply >/dev/null 2>&1; then
    state_write_after_apply "$project_path" "$apply_command" "${commit_list[@]+"${commit_list[@]}"}"
  fi
  return 0
}

# Hash-aware copy used by install/update paths (idempotent second run).
# Sets APPLY_* counters. Returns 0 always for skip/write success; 1 on hard fail.
apply_copy_if_changed() {
  local src="$1" dst="$2" label="${3:-}"
  local src_hash dst_hash

  mkdir -p "$(dirname "$dst")"
  if [[ ! -f "$src" ]]; then
    APPLY_FAILED=$((APPLY_FAILED + 1))
    return 1
  fi

  if [[ -f "$dst" ]]; then
    src_hash="$(apply_content_sha256 "$src")"
    dst_hash="$(apply_content_sha256 "$dst")"
    if [[ "$src_hash" == "$dst_hash" ]]; then
      APPLY_UNCHANGED=$((APPLY_UNCHANGED + 1))
      if [[ -n "$label" && -n "${GREEN:-}" ]]; then
        echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(unchanged)${NC}"
      fi
      return 0
    fi
  fi

  local tmp
  tmp="${dst}.agtoosa-tmp.$$"
  if ! cp "$src" "$tmp" || ! mv "$tmp" "$dst"; then
    rm -f "$tmp" 2>/dev/null || true
    APPLY_FAILED=$((APPLY_FAILED + 1))
    return 1
  fi
  APPLY_WRITTEN=$((APPLY_WRITTEN + 1))
  if [[ -n "$label" && -n "${GREEN:-}" ]]; then
    echo -e "  ${GREEN}✅${NC} ${label}"
  fi
  return 0
}

# Mark a merge-style write in the summary (content already applied by caller).
apply_note_merged() {
  APPLY_MERGED=$((APPLY_MERGED + 1))
}
