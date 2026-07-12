#!/usr/bin/env bash

# ── AgToosa: --reinstall --clean (ADR-004 Option C) ─────────────────────────
# Sourced by agtoosa.sh.
# Archives generated files, regenerates from template (fresh-install equivalent
# for detected platforms), rewrites Docs/agtoosa-lock.json. Does not replace
# --update as the default upgrade path.

# Relative paths of AgToosa-generated files present in the project (for archive).
_reinstall_list_generated_paths() {
  local project_path="$1"
  local f
  local -a candidates=()

  for f in "${DOCS_FILES[@]}"; do
    case "$f" in
      Docs/Master-Plan.md|Docs/AgToosa_Changelog.md|Docs/Master-Architecture.md) continue ;;
    esac
    candidates+=("$f")
  done
  candidates+=("${OPTIONAL_TEMPLATE_FILES[@]+"${OPTIONAL_TEMPLATE_FILES[@]}"}")
  candidates+=("${AGTOOSA_DOTDIR_FILES[@]+"${AGTOOSA_DOTDIR_FILES[@]}"}")
  candidates+=("Docs/.agtoosa-version" "Docs/agtoosa-lock.json")

  if [[ "${USE_CLAUDE:-false}" == true ]]; then
    candidates+=("${CLAUDE_COMMAND_FILES[@]+"${CLAUDE_COMMAND_FILES[@]}"}")
    candidates+=("${CLAUDE_SKILL_FILES[@]+"${CLAUDE_SKILL_FILES[@]}"}")
    candidates+=("${CLAUDE_HOOK_FILES[@]+"${CLAUDE_HOOK_FILES[@]}"}")
    candidates+=(".claude/settings.json")
  fi
  if [[ "${USE_CURSOR:-false}" == true ]]; then
    candidates+=("${CURSOR_RULE_FILES[@]+"${CURSOR_RULE_FILES[@]}"}")
    candidates+=("${CURSOR_COMMAND_FILES[@]+"${CURSOR_COMMAND_FILES[@]}"}")
  fi
  if [[ "${USE_GEMINI:-false}" == true ]]; then
    candidates+=("${GEMINI_COMMAND_FILES[@]+"${GEMINI_COMMAND_FILES[@]}"}")
  fi
  if [[ "${USE_COPILOT:-false}" == true || "${USE_VSCODE:-false}" == true ]]; then
    candidates+=("${COPILOT_PROMPT_FILES[@]+"${COPILOT_PROMPT_FILES[@]}"}")
    candidates+=("${COPILOT_AGENT_FILES[@]+"${COPILOT_AGENT_FILES[@]}"}")
    candidates+=("${COPILOT_INSTRUCTION_FILES[@]+"${COPILOT_INSTRUCTION_FILES[@]}"}")
  fi
  if [[ "${USE_WINDSURF:-false}" == true ]]; then
    candidates+=("${WINDSURF_RULE_FILES[@]+"${WINDSURF_RULE_FILES[@]}"}")
    candidates+=("${WINDSURF_WORKFLOW_FILES[@]+"${WINDSURF_WORKFLOW_FILES[@]}"}")
  fi
  if [[ "${USE_OPENCODE:-false}" == true ]]; then
    candidates+=("${CODEX_SKILL_FILES[@]+"${CODEX_SKILL_FILES[@]}"}")
    candidates+=("${CODEX_PROMPT_FILES[@]+"${CODEX_PROMPT_FILES[@]}"}")
  fi

  printf '%s\n' "${candidates[@]}" \
    | awk 'NF && !seen[$0]++' \
    | while IFS= read -r f; do
        if [[ -f "${project_path}/${f}" ]]; then
          printf '%s\n' "$f"
        fi
      done
}

# True when a platform entry-point has content outside AgToosa START/END markers.
_reinstall_has_unmarked_edits() {
  local project_path="$1"
  local f content stripped
  for f in .cursorrules .windsurfrules CLAUDE.md AGENTS.md OPENCODE.md \
           .github/copilot-instructions.md; do
    [[ -f "${project_path}/${f}" ]] || continue
    if ! grep -qE 'AgToosa v[0-9]+\.[0-9]+\.[0-9]+ START' "${project_path}/${f}" 2>/dev/null; then
      # No markers but file exists — treat as unmarked / user-owned risk
      if grep -qiE 'AgToosa|agtoosa' "${project_path}/${f}" 2>/dev/null; then
        return 0
      fi
      continue
    fi
    stripped="$(awk '
      /AgToosa v[0-9]+\.[0-9]+\.[0-9]+ START/{in_block=1; next}
      in_block && /AgToosa END/{in_block=0; next}
      !in_block {print}
    ' "${project_path}/${f}")"
    content="$(printf '%s' "$stripped" | tr -d '[:space:]')"
    if [[ -n "$content" ]]; then
      return 0
    fi
  done
  return 1
}

_reinstall_archive_generated() {
  local project_path="$1"
  local archive_dir="$2"
  local manifest="${archive_dir}/manifest.txt"
  local f count=0

  mkdir -p "$archive_dir"
  : > "$manifest"

  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    mkdir -p "$(dirname "${archive_dir}/${f}")"
    cp "${project_path}/${f}" "${archive_dir}/${f}"
    printf '%s\n' "$f" >> "$manifest"
    count=$((count + 1))
  done < <(_reinstall_list_generated_paths "$project_path")

  printf '%s\n' "$count"
}

# Hard overwrite from ship staging (no marker merge — Option C fresh state).
_reinstall_apply_clean() {
  local project_path="$1"
  local changed=0
  local unchanged=0
  local f src dst src_hash dst_hash

  # Workflow docs — overwrite AgToosa-owned; preserve project-owned state files
  local -a doc_targets=("${DOCS_FILES[@]}")
  doc_targets+=("Docs/AgToosa_Claude.md" "Docs/AgToosa_Gemini.md")
  for f in "${doc_targets[@]}"; do
    case "$f" in
      Docs/Master-Plan.md|Docs/AgToosa_Changelog.md|Docs/Master-Architecture.md) continue ;;
    esac
    src="${SHIP_DIR}/${f}"
    dst="${project_path}/${f}"
    [[ -f "$src" ]] || continue
    mkdir -p "$(dirname "$dst")"
    if [[ -f "$dst" ]] && declare -F apply_content_sha256 >/dev/null 2>&1; then
      src_hash="$(apply_content_sha256 "$src")"
      dst_hash="$(apply_content_sha256 "$dst")"
      if [[ "$src_hash" == "$dst_hash" ]]; then
        unchanged=$((unchanged + 1))
        continue
      fi
    fi
    cp "$src" "$dst"
    changed=$((changed + 1))
    echo -e "  ${GREEN}✅${NC} ${f}"
  done

  # Platform entry-points — replace entirely from staged template
  local entry
  for entry in .cursorrules .windsurfrules CLAUDE.md AGENTS.md OPENCODE.md; do
    src="${SHIP_DIR}/${entry}"
    dst="${project_path}/${entry}"
    [[ -f "$src" ]] || continue
    if [[ -f "$dst" ]] && declare -F apply_content_sha256 >/dev/null 2>&1; then
      src_hash="$(apply_content_sha256 "$src")"
      dst_hash="$(apply_content_sha256 "$dst")"
      if [[ "$src_hash" == "$dst_hash" ]]; then
        unchanged=$((unchanged + 1))
        continue
      fi
    fi
    cp "$src" "$dst"
    changed=$((changed + 1))
    echo -e "  ${GREEN}✅${NC} ${entry} ${CYAN}(clean replace)${NC}"
  done
  if [[ -f "${SHIP_DIR}/.github/copilot-instructions.md" ]]; then
    src="${SHIP_DIR}/.github/copilot-instructions.md"
    dst="${project_path}/.github/copilot-instructions.md"
    mkdir -p "$(dirname "$dst")"
    if [[ -f "$dst" ]] && declare -F apply_content_sha256 >/dev/null 2>&1; then
      src_hash="$(apply_content_sha256 "$src")"
      dst_hash="$(apply_content_sha256 "$dst")"
      if [[ "$src_hash" != "$dst_hash" ]]; then
        cp "$src" "$dst"
        changed=$((changed + 1))
        echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(clean replace)${NC}"
      else
        unchanged=$((unchanged + 1))
      fi
    else
      cp "$src" "$dst"
      changed=$((changed + 1))
      echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(clean replace)${NC}"
    fi
  fi

  # Native dirs + remaining staged files (skip docs/entry-points already handled)
  while IFS= read -r -d '' src; do
    f="${src#"${SHIP_DIR}/"}"
    case "$f" in
      Docs/*|.cursorrules|.windsurfrules|CLAUDE.md|AGENTS.md|OPENCODE.md|.github/copilot-instructions.md)
        continue ;;
    esac
    dst="${project_path}/${f}"
    mkdir -p "$(dirname "$dst")"
    if [[ -f "$dst" ]] && declare -F apply_content_sha256 >/dev/null 2>&1; then
      src_hash="$(apply_content_sha256 "$src")"
      dst_hash="$(apply_content_sha256 "$dst")"
      if [[ "$src_hash" == "$dst_hash" ]]; then
        unchanged=$((unchanged + 1))
        continue
      fi
    fi
    cp "$src" "$dst"
    if [[ "$f" == *.sh ]]; then
      chmod +x "$dst" 2>/dev/null || true
    fi
    changed=$((changed + 1))
  done < <(find "$SHIP_DIR" -type f -print0)

  # Version marker
  mkdir -p "${project_path}/Docs"
  if [[ -f "${project_path}/Docs/.agtoosa-version" ]] \
     && [[ "$(cat "${project_path}/Docs/.agtoosa-version")" == "$AGTOOSA_VERSION" ]]; then
    unchanged=$((unchanged + 1))
  else
    echo "$AGTOOSA_VERSION" > "${project_path}/Docs/.agtoosa-version"
    changed=$((changed + 1))
  fi

  REINSTALL_CHANGED=$changed
  REINSTALL_UNCHANGED=$unchanged
}

# Orchestrate clean reinstall for PROJECT_PATH (or explicit target).
# Returns 0 on success; 1 on cancel / validation failure.
run_reinstall_clean() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    if [[ -n "${CLI_PROJECT_PATH:-}" ]]; then
      target="$CLI_PROJECT_PATH"
    else
      echo -e "${BOLD}Project path to reinstall (clean):${NC}"
      read -rp "Project path: " target
      target="${target/#\~/$HOME}"
      target="${target%/}"
    fi
  fi
  target="${target/#\~/$HOME}"
  target="${target%/}"

  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 1
  fi
  if [[ ! -d "${target}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory found in '${target}'.${NC}" >&2
    echo -e "${YELLOW}Run a full install first: bash agtoosa.sh --path <dir> --platforms … --yes${NC}" >&2
    return 1
  fi

  local _rp_project _rp_script
  _rp_project="$(cd "$target" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_project" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}" >&2
    if declare -F _print_self_target_guidance >/dev/null 2>&1; then
      _print_self_target_guidance
    fi
    return 1
  fi

  PROJECT_PATH="$target"

  # Platform selection: CLI list or detect installed sentinels
  if [[ -n "${CLI_PLATFORMS:-}" ]]; then
    if declare -F apply_cli_platforms >/dev/null 2>&1; then
      apply_cli_platforms "$CLI_PLATFORMS"
    else
      USE_CURSOR=false; USE_WINDSURF=false; USE_CLAUDE=false
      USE_GEMINI=false; USE_COPILOT=false; USE_OPENCODE=false; USE_VSCODE=false
      local tok
      IFS=',' read -ra _plats <<< "$CLI_PLATFORMS"
      for tok in "${_plats[@]}"; do
        tok="$(echo "$tok" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
        case "$tok" in
          cursor) USE_CURSOR=true ;;
          windsurf) USE_WINDSURF=true ;;
          claude|claude-code) USE_CLAUDE=true ;;
          gemini|jules) USE_GEMINI=true ;;
          copilot|github-copilot) USE_COPILOT=true ;;
          vscode) USE_COPILOT=true; USE_VSCODE=true ;;
          codex|opencode|other) USE_OPENCODE=true ;;
          all)
            USE_CURSOR=true; USE_WINDSURF=true; USE_CLAUDE=true
            USE_GEMINI=true; USE_COPILOT=true; USE_OPENCODE=true ;;
        esac
      done
    fi
  else
    detect_installed_platforms
  fi

  echo ""
  echo -e "${PURPLE}${BOLD}AgToosa --reinstall --clean (ADR-004 Option C)${NC}"
  echo -e "${PURPLE}${BOLD}Project: ${PROJECT_PATH}${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  Clean reinstall regenerates AgToosa files from the current generator.${NC}"
  echo -e "${YELLOW}   Custom edits outside AgToosa markers may not be preserved.${NC}"
  echo -e "${YELLOW}   This is NOT marker-merge preservation (use --update for the default safe path).${NC}"
  echo ""

  if _reinstall_has_unmarked_edits "$PROJECT_PATH"; then
    echo -e "${YELLOW}⚠️  Detected content outside AgToosa markers in platform entry-point(s).${NC}"
    echo -e "${YELLOW}   Clean reinstall will not preserve those unmarked edits.${NC}"
    echo ""
  fi

  local reply
  if [[ "${ASSUME_YES:-false}" == true ]]; then
    reply="Y"
  elif [[ -t 0 ]]; then
    read -rp "Proceed with destructive clean reinstall? (y/N): " reply
    reply="${reply:-N}"
  else
    echo -e "${RED}❌ Error: --reinstall --clean requires confirmation.${NC}" >&2
    echo -e "${YELLOW}Re-run with --yes for non-interactive use, or confirm on a TTY.${NC}" >&2
    return 1
  fi
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    return 1
  fi

  local ts archive_dir archived_count
  ts="$(date +%Y%m%d-%H%M%S)"
  archive_dir="${PROJECT_PATH}/.agtoosa/reinstall-archive/${ts}"
  echo -e "${CYAN}Archiving generated files → ${archive_dir}${NC}"
  archived_count="$(_reinstall_archive_generated "$PROJECT_PATH" "$archive_dir")"
  echo -e "  ${GREEN}✅${NC} Archived ${archived_count} file(s); manifest: ${archive_dir}/manifest.txt"
  echo ""

  # Stage fresh template set for selected platforms
  [[ -d "$SHIP_DIR" ]] && rm -rf "$SHIP_DIR"
  mkdir -p "$SHIP_DIR/Docs/archived" "$SHIP_DIR/Docs/Context" \
           "$SHIP_DIR/.agtoosa" \
           "$SHIP_DIR/.claude/commands" "$SHIP_DIR/.claude/skills" \
           "$SHIP_DIR/.cursor/rules" "$SHIP_DIR/.cursor/commands" \
           "$SHIP_DIR/.gemini/commands" \
           "$SHIP_DIR/.github/prompts" "$SHIP_DIR/.github/agents" \
           "$SHIP_DIR/.codex/skills" \
           "$SHIP_DIR/.windsurf/rules" "$SHIP_DIR/.windsurf/workflows"
  GENERATED=0
  stage_files >/dev/null

  echo -e "${YELLOW}Regenerating AgToosa outputs (clean)…${NC}"
  REINSTALL_CHANGED=0
  REINSTALL_UNCHANGED=0
  _reinstall_apply_clean "$PROJECT_PATH"

  # Rewrite lock when content changed or lock is missing/stale (skip pure no-ops for idempotency).
  local lock_file="${PROJECT_PATH}/Docs/agtoosa-lock.json"
  local need_lock=false
  if [[ ! -f "$lock_file" ]]; then
    need_lock=true
  elif command -v jq >/dev/null 2>&1; then
    local lock_ver
    lock_ver="$(jq -r '.agtoosa_version // empty' "$lock_file" 2>/dev/null || true)"
    [[ "$lock_ver" != "$AGTOOSA_VERSION" ]] && need_lock=true
  else
    need_lock=true
  fi

  if [[ "${REINSTALL_CHANGED:-0}" -gt 0 || "$need_lock" == true ]]; then
    if declare -F lock_reconcile >/dev/null 2>&1; then
      lock_reconcile "$PROJECT_PATH"
      REINSTALL_CHANGED=$((REINSTALL_CHANGED + 1))
    fi
    if declare -F state_write_after_apply >/dev/null 2>&1; then
      state_write_after_apply "$PROJECT_PATH" "reinstall-clean"
    fi
  fi

  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  if [[ "${REINSTALL_CHANGED:-0}" -eq 0 ]]; then
    echo -e "  ${GREEN}No effective change${NC} — install already matched generator v${AGTOOSA_VERSION}"
  else
    echo -e "  ${GREEN}Changed: ${REINSTALL_CHANGED}${NC}  ${CYAN}Unchanged: ${REINSTALL_UNCHANGED:-0}${NC}"
  fi
  echo -e "  Archive: ${CYAN}${archive_dir}${NC}"
  echo -e "  Lock:    ${CYAN}${PROJECT_PATH}/Docs/agtoosa-lock.json${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} reinstall --clean complete${NC}"
  return 0
}
