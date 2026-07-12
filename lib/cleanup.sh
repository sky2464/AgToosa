#!/usr/bin/env bash

# ── AgToosa: --cleanup (merge backups, orphan docs, deselected platforms) ──
# Sourced by agtoosa.sh.
# Globals read: SCRIPT_DIR, TEMPLATE_DIR, AGTOOSA_VERSION, ASSUME_YES, colors,
#               DOCS_FILES, platform file arrays from config.sh.

CLEANUP_CANDIDATES=()

_cleanup_safe_relpath() {
  local rel="$1"
  [[ -n "$rel" ]] || return 1
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *..* ]] && return 1
  return 0
}

_cleanup_seen_rel() {
  local rel="$1" entry erel
  for entry in "${CLEANUP_CANDIDATES[@]+"${CLEANUP_CANDIDATES[@]}"}"; do
    erel="${entry#*|}"; erel="${erel%%|*}"
    [[ "$erel" == "$rel" ]] && return 0
  done
  return 1
}

_cleanup_add_candidate() {
  local category="$1" rel="$2" reason="$3"
  _cleanup_safe_relpath "$rel" || return 0
  _cleanup_seen_rel "$rel" && return 0
  CLEANUP_CANDIDATES+=("${category}|${rel}|${reason}")
}

# Resolve selected platforms from lock file or installed sentinels.
cleanup_resolve_platforms() {
  local project_path="$1"
  local lock_file="${project_path}/Docs/agtoosa-lock.json"
  local -a platforms=()
  local p

  if [[ -f "$lock_file" ]] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r p; do
      [[ -n "$p" ]] && platforms+=("$p")
    done < <(jq -r '.platforms[]? // empty' "$lock_file" 2>/dev/null)
  fi

  if ((${#platforms[@]} == 0)); then
    local saved_path="${PROJECT_PATH:-}"
    PROJECT_PATH="$project_path"
    detect_installed_platforms
    while IFS= read -r p; do
      [[ -n "$p" ]] && platforms+=("$p")
    done < <(lock_selected_platforms)
    PROJECT_PATH="$saved_path"
  fi

  # VS Code generic (platform 6): shares .github/prompts; lock may omit an id when only
  # USE_VSCODE was selected (copilot-instructions.md is not installed).
  if ! _cleanup_platform_selected "copilot" "${platforms[@]+"${platforms[@]}"}" \
     && ! _cleanup_platform_selected "vscode" "${platforms[@]+"${platforms[@]}"}"; then
    if [[ ! -f "${project_path}/.github/copilot-instructions.md" ]] \
       && [[ -d "${project_path}/.github/prompts" ]] \
       && find "${project_path}/.github/prompts" -maxdepth 1 -name 'agtoosa-*' -print -quit 2>/dev/null | grep -q .; then
      platforms+=("vscode")
    fi
  fi

  if ((${#platforms[@]} > 0)); then
    printf '%s\n' "${platforms[@]}"
  fi
}

_cleanup_platform_selected() {
  local plat="$1"
  shift
  local p
  [[ $# -eq 0 ]] && return 1
  for p in "$@"; do
    [[ "$p" == "$plat" ]] && return 0
  done
  return 1
}

# Copilot and VS Code share .github/prompts and .github/agents (see lib/generate.sh).
_cleanup_github_prompts_owner_selected() {
  _cleanup_platform_selected "copilot" "$@" \
    || _cleanup_platform_selected "vscode" "$@"
}

# Known AgToosa-owned relative paths for one platform id.
_cleanup_paths_for_platform() {
  local plat="$1"
  case "$plat" in
    cursor)
      printf '%s\n' ".cursorrules"
      printf '%s\n' "${CURSOR_RULE_FILES[@]+"${CURSOR_RULE_FILES[@]}"}"
      printf '%s\n' "${CURSOR_COMMAND_FILES[@]+"${CURSOR_COMMAND_FILES[@]}"}"
      ;;
    windsurf)
      printf '%s\n' ".windsurfrules"
      printf '%s\n' "${WINDSURF_RULE_FILES[@]+"${WINDSURF_RULE_FILES[@]}"}"
      printf '%s\n' "${WINDSURF_WORKFLOW_FILES[@]+"${WINDSURF_WORKFLOW_FILES[@]}"}"
      ;;
    claude)
      printf '%s\n' "CLAUDE.md" "Docs/AgToosa_Claude.md"
      printf '%s\n' "${CLAUDE_COMMAND_FILES[@]+"${CLAUDE_COMMAND_FILES[@]}"}"
      printf '%s\n' "${CLAUDE_SKILL_FILES[@]+"${CLAUDE_SKILL_FILES[@]}"}"
      printf '%s\n' "${CLAUDE_HOOK_FILES[@]+"${CLAUDE_HOOK_FILES[@]}"}"
      printf '%s\n' ".claude/settings.json"
      ;;
    gemini)
      printf '%s\n' "AGENTS.md" "Docs/AgToosa_Gemini.md"
      printf '%s\n' "${GEMINI_COMMAND_FILES[@]+"${GEMINI_COMMAND_FILES[@]}"}"
      ;;
    copilot)
      printf '%s\n' ".github/copilot-instructions.md"
      printf '%s\n' "${COPILOT_PROMPT_FILES[@]+"${COPILOT_PROMPT_FILES[@]}"}"
      printf '%s\n' "${COPILOT_AGENT_FILES[@]+"${COPILOT_AGENT_FILES[@]}"}"
      printf '%s\n' "${COPILOT_INSTRUCTION_FILES[@]+"${COPILOT_INSTRUCTION_FILES[@]}"}"
      ;;
    vscode)
      # VS Code generic — prompts/agents only (no copilot-instructions.md sentinel).
      printf '%s\n' "${COPILOT_PROMPT_FILES[@]+"${COPILOT_PROMPT_FILES[@]}"}"
      printf '%s\n' "${COPILOT_AGENT_FILES[@]+"${COPILOT_AGENT_FILES[@]}"}"
      ;;
    opencode)
      printf '%s\n' "OPENCODE.md"
      printf '%s\n' "${CODEX_SKILL_FILES[@]+"${CODEX_SKILL_FILES[@]}"}"
      printf '%s\n' "${CODEX_PROMPT_FILES[@]+"${CODEX_PROMPT_FILES[@]}"}"
      ;;
  esac
}

# Scan platform tree for agtoosa-* files when platform is deselected.
_cleanup_scan_agtoosa_tree() {
  local project_path="$1" root_dir="$2" category="$3" reason="$4"
  local abs="${project_path}/${root_dir}"
  local f rel base

  [[ -d "$abs" ]] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#"${project_path}/"}"
    base="$(basename "$f")"
    [[ "$base" == agtoosa-* ]] || [[ "$rel" == *"/agtoosa-"* ]] || continue
    # Never touch user project specialists (non-agtoosa ids in agents/skills).
    case "$rel" in
      .github/agents/*)
        [[ "$base" == agtoosa*.agent.md || "$base" == agtoosa-*.agent.md ]] \
          || continue
        ;;
      .claude/skills/*)
        [[ "$base" == agtoosa-* ]] || continue
        ;;
      .codex/skills/*)
        [[ "$rel" == .codex/skills/agtoosa-* ]] || continue
        ;;
    esac
    _cleanup_add_candidate "$category" "$rel" "$reason"
  done < <(find "$abs" -type f -print0 2>/dev/null)
}

_cleanup_collect_backups() {
  local project_path="$1" f rel
  while IFS= read -r -d '' f; do
    rel="${f#"${project_path}/"}"
    _cleanup_add_candidate "backup" "$rel" "merge backup (*.bak.*)"
  done < <(find "$project_path" -type f -name '*.bak.*' -print0 2>/dev/null)
}

_cleanup_collect_orphan_docs() {
  local project_path="$1" f base rel
  for f in "${project_path}/Docs"/AgToosa_*.md; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    case "$base" in
      AgToosa_Changelog.md) continue ;;
      AgToosa_TestPlan-*) continue ;;
    esac
    rel="Docs/${base}"
    [[ -f "${TEMPLATE_DIR}/${rel}" ]] && continue
    _cleanup_add_candidate "orphan_doc" "$rel" "workflow doc removed from template"
  done
}

_cleanup_collect_orphan_platforms() {
  local project_path="$1"
  local -a selected=() all_plats=(cursor windsurf claude gemini copilot vscode opencode)
  local plat rel path

  while IFS= read -r plat; do
    [[ -n "$plat" ]] && selected+=("$plat")
  done < <(cleanup_resolve_platforms "$project_path")

  for plat in "${all_plats[@]}"; do
    _cleanup_platform_selected "$plat" "${selected[@]+"${selected[@]}"}" && continue
    # Copilot and VS Code share .github/prompts; skip both buckets when either is active.
    [[ "$plat" == "copilot" || "$plat" == "vscode" ]] \
      && _cleanup_github_prompts_owner_selected "${selected[@]+"${selected[@]}"}" \
      && continue
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      [[ -f "${project_path}/${rel}" ]] \
        && _cleanup_add_candidate "orphan_platform" "$rel" "deselected platform: ${plat}"
    done < <(_cleanup_paths_for_platform "$plat")

    case "$plat" in
      cursor)   _cleanup_scan_agtoosa_tree "$project_path" ".cursor" \
                  "orphan_platform" "deselected platform: cursor" ;;
      claude)   _cleanup_scan_agtoosa_tree "$project_path" ".claude" \
                  "orphan_platform" "deselected platform: claude" ;;
      gemini)   _cleanup_scan_agtoosa_tree "$project_path" ".gemini" \
                  "orphan_platform" "deselected platform: gemini" ;;
      copilot)  _cleanup_scan_agtoosa_tree "$project_path" ".github/prompts" \
                  "orphan_platform" "deselected platform: copilot"
                _cleanup_scan_agtoosa_tree "$project_path" ".github/agents" \
                  "orphan_platform" "deselected platform: copilot"
                _cleanup_scan_agtoosa_tree "$project_path" ".github/instructions" \
                  "orphan_platform" "deselected platform: copilot" ;;
      vscode)   _cleanup_scan_agtoosa_tree "$project_path" ".github/prompts" \
                  "orphan_platform" "deselected platform: vscode"
                _cleanup_scan_agtoosa_tree "$project_path" ".github/agents" \
                  "orphan_platform" "deselected platform: vscode" ;;
      opencode) _cleanup_scan_agtoosa_tree "$project_path" ".codex" \
                  "orphan_platform" "deselected platform: opencode" ;;
      windsurf) _cleanup_scan_agtoosa_tree "$project_path" ".windsurf" \
                  "orphan_platform" "deselected platform: windsurf" ;;
    esac
  done
}

# Populate CLEANUP_CANDIDATES for project_path.
cleanup_collect_candidates() {
  local project_path="$1"
  CLEANUP_CANDIDATES=()
  _cleanup_collect_backups "$project_path"
  _cleanup_collect_orphan_docs "$project_path"
  _cleanup_collect_orphan_platforms "$project_path"
}

_cleanup_validate_target() {
  local target="$1"
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi
  if [[ ! -d "${target}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory in '${target}' — AgToosa not installed.${NC}" >&2
    return 2
  fi
  local _rp_target _rp_script
  _rp_target="$(cd "$target" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_target" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}" >&2
    return 1
  fi
  return 0
}

_cleanup_count_category() {
  local cat="$1" entry c count=0
  for entry in "${CLEANUP_CANDIDATES[@]+"${CLEANUP_CANDIDATES[@]}"}"; do
    c="${entry%%|*}"
    [[ "$c" == "$cat" ]] && count=$((count + 1))
  done
  printf '%s' "$count"
}

_cleanup_emit_json() {
  local target="$1"
  local backup orphan_doc orphan_platform total entry cat rel reason
  local candidates_json="" item

  backup="$(_cleanup_count_category backup)"
  orphan_doc="$(_cleanup_count_category orphan_doc)"
  orphan_platform="$(_cleanup_count_category orphan_platform)"
  total=${#CLEANUP_CANDIDATES[@]}

  for entry in "${CLEANUP_CANDIDATES[@]+"${CLEANUP_CANDIDATES[@]}"}"; do
    IFS='|' read -r cat rel reason <<< "$entry"
    item="$(python3 -c 'import json,sys; print(json.dumps({"category":sys.argv[1],"path":sys.argv[2],"reason":sys.argv[3]}))' \
      "$cat" "$rel" "$reason")"
    [[ -n "$candidates_json" ]] && candidates_json+=","
    candidates_json+="$item"
  done

  export CLEANUP_JSON_TARGET="$target"
  export CLEANUP_JSON_VERSION="$AGTOOSA_VERSION"
  export CLEANUP_JSON_BACKUP="$backup"
  export CLEANUP_JSON_ORPHAN_DOC="$orphan_doc"
  export CLEANUP_JSON_ORPHAN_PLATFORM="$orphan_platform"
  export CLEANUP_JSON_TOTAL="$total"
  export CLEANUP_JSON_CANDIDATES="[$candidates_json]"

  python3 - <<'PY'
import json, os
doc = {
    "schema_version": "cleanup-result-v1",
    "project_path": os.environ["CLEANUP_JSON_TARGET"],
    "generator_version": os.environ["CLEANUP_JSON_VERSION"],
    "summary": {
        "backup": int(os.environ["CLEANUP_JSON_BACKUP"]),
        "orphan_doc": int(os.environ["CLEANUP_JSON_ORPHAN_DOC"]),
        "orphan_platform": int(os.environ["CLEANUP_JSON_ORPHAN_PLATFORM"]),
        "total": int(os.environ["CLEANUP_JSON_TOTAL"]),
    },
    "candidates": json.loads(os.environ["CLEANUP_JSON_CANDIDATES"]),
}
print(json.dumps(doc, ensure_ascii=False, separators=(",", ":")))
PY
}

_cleanup_emit_plan_human() {
  local target="$1"
  local entry cat rel reason
  local backup orphan_doc orphan_platform

  backup="$(_cleanup_count_category backup)"
  orphan_doc="$(_cleanup_count_category orphan_doc)"
  orphan_platform="$(_cleanup_count_category orphan_platform)"

  echo -e "${BOLD}AgToosa Cleanup Plan — ${target}${NC}"
  echo ""
  if ((${#CLEANUP_CANDIDATES[@]} == 0)); then
    echo -e "  ${GREEN}✅${NC} No unnecessary AgToosa-owned files found."
    echo ""
    return 0
  fi

  echo -e "  ${YELLOW}Found ${#CLEANUP_CANDIDATES[@]} candidate(s):${NC}"
  echo -e "    backups: ${backup}  ·  removed docs: ${orphan_doc}  ·  deselected platforms: ${orphan_platform}"
  echo ""

  for entry in "${CLEANUP_CANDIDATES[@]+"${CLEANUP_CANDIDATES[@]}"}"; do
    IFS='|' read -r cat rel reason <<< "$entry"
    case "$cat" in
      backup)          echo -e "  ${CYAN}backup${NC}           ${rel}  — ${reason}" ;;
      orphan_doc)      echo -e "  ${YELLOW}orphan_doc${NC}       ${rel}  — ${reason}" ;;
      orphan_platform) echo -e "  ${PURPLE}orphan_platform${NC}  ${rel}  — ${reason}" ;;
      *)               echo -e "  ${cat}  ${rel}  — ${reason}" ;;
    esac
  done
  echo ""
}

# Plan-only: --dry-run or --format json.
run_cleanup_plan() {
  local target="${1:-$PWD}"
  local format="${2:-text}"
  shift 2 2>/dev/null || true

  target="${target/#\~/$HOME}"
  target="${target%/}"

  _cleanup_validate_target "$target" || return $?

  cleanup_collect_candidates "$target"

  if [[ "$format" == "json" ]]; then
    _cleanup_emit_json "$target"
    return 0
  fi

  _cleanup_emit_plan_human "$target"
  echo -e "${YELLOW}[DRY RUN] No files removed. Re-run without --dry-run to apply.${NC}"
  echo ""
  return 0
}

_cleanup_prune_empty_dirs() {
  local target="$1" d
  for d in .claude/commands .claude/skills .claude/hooks .cursor/rules .cursor/commands \
           .gemini/commands .github/prompts .github/agents .github/instructions \
           .codex/skills .codex/prompts .windsurf/rules .windsurf/workflows \
           Docs/schemas; do
    [[ -d "${target}/${d}" ]] && find "${target}/${d}" -type d -empty -delete 2>/dev/null || true
  done
}

# Interactive apply: plan → confirm → delete.
# Optional second arg skip_confirm=true skips the final y/N when caller already confirmed.
run_cleanup() {
  local target="${1:-}" skip_confirm="${2:-false}"
  if [[ -z "$target" ]]; then
    if [[ -n "${CLI_PROJECT_PATH:-}" ]]; then
      target="$CLI_PROJECT_PATH"
    else
      echo -e "${BOLD}Project path to clean up:${NC}"
      read -rp "Project path: " target
      target="${target/#\~/$HOME}"
      target="${target%/}"
    fi
  fi
  target="${target/#\~/$HOME}"
  target="${target%/}"

  _cleanup_validate_target "$target" || return $?

  cleanup_collect_candidates "$target"

  if ((${#CLEANUP_CANDIDATES[@]} == 0)); then
    echo -e "${GREEN}${BOLD}✅ No unnecessary AgToosa-owned files to remove.${NC}"
    return 0
  fi

  _cleanup_emit_plan_human "$target"

  local reply
  if [[ "$skip_confirm" == true ]]; then
    reply="Y"
  elif [[ "${ASSUME_YES:-false}" == true ]]; then
    reply="Y"
  elif [[ -t 0 ]]; then
    read -rp "Remove these ${#CLEANUP_CANDIDATES[@]} file(s)? (y/N): " reply
    reply="${reply:-N}"
  else
    echo -e "${RED}❌ Error: --cleanup requires confirmation.${NC}" >&2
    echo -e "${YELLOW}Re-run with --yes for non-interactive use, or confirm on a TTY.${NC}" >&2
    return 1
  fi

  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    return 0
  fi

  local removed=0 entry rel cat
  for entry in "${CLEANUP_CANDIDATES[@]+"${CLEANUP_CANDIDATES[@]}"}"; do
    IFS='|' read -r cat rel _ <<< "$entry"
    _cleanup_safe_relpath "$rel" || continue
    if [[ -f "${target}/${rel}" ]]; then
      rm -f "${target}/${rel}"
      removed=$((removed + 1))
      echo -e "  ${GREEN}✅${NC} removed ${rel}"
    fi
  done

  _cleanup_prune_empty_dirs "$target"

  echo ""
  echo -e "${GREEN}${BOLD}✅ Cleanup complete — removed ${removed} file(s).${NC}"
  return 0
}

# Post install/upgrade: offer cleanup when candidates exist.
offer_cleanup_after_apply() {
  local project_path="$1"
  cleanup_collect_candidates "$project_path"
  local count=${#CLEANUP_CANDIDATES[@]}

  if [[ $count -eq 0 ]]; then
    return 0
  fi

  if [[ "${ASSUME_YES:-false}" == true ]]; then
    echo ""
    echo -e "${CYAN}ℹ️  Found ${count} unnecessary file(s). Run: bash agtoosa.sh --cleanup '${project_path}'${NC}"
    return 0
  fi

  if [[ -t 0 ]]; then
    echo ""
    echo -e "${YELLOW}Found ${count} unnecessary file(s) (backups, removed docs, deselected platforms).${NC}"
    local reply
    read -rp "Run cleanup now? (y/N): " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      run_cleanup "$project_path" true
    else
      echo -e "${CYAN}ℹ️  Run later: bash agtoosa.sh --cleanup '${project_path}'${NC}"
    fi
  else
    echo ""
    echo -e "${CYAN}ℹ️  Found ${count} unnecessary file(s). Run: bash agtoosa.sh --cleanup '${project_path}'${NC}"
  fi
}
