#!/usr/bin/env bash

# ── AgToosa: unified install/update dry-run plan engine ───────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, TEMPLATE_DIR, FORCE, AGTOOSA_VERSION,
#               DOCS_FILES, CLAUDE_COMMAND_FILES, CLAUDE_SKILL_FILES,
#               CLAUDE_HOOK_FILES, CURSOR_RULE_FILES, CURSOR_COMMAND_FILES,
#               GEMINI_COMMAND_FILES, COPILOT_PROMPT_FILES, COPILOT_AGENT_FILES,
#               WINDSURF_RULE_FILES, WINDSURF_WORKFLOW_FILES, CODEX_SKILL_FILES,
#               CODEX_PROMPT_FILES, AGTOOSA_DOTDIR_FILES, colors.
#
# JSON contract (plan-result-v1):
#   operation, project_path, generator_version, actions[{path,category,detail}]
# Categories: new, overwrite, merge, backup_replace, skip, up_to_date, manual

PLAN_OPERATION=""
PLAN_PROJECT_PATH=""
PLAN_ACTIONS=()
PLAN_UPDATE_FILES=()

_plan_is_native_overwrite() {
  local f="$1"
  [[ "$f" == .claude/commands/* || "$f" == .claude/skills/* \
     || "$f" == .cursor/rules/* || "$f" == .cursor/commands/* \
     || "$f" == .gemini/commands/* \
     || "$f" == .github/prompts/* || "$f" == .github/agents/* || "$f" == .github/instructions/* \
     || "$f" == .codex/skills/* || "$f" == .codex/prompts/* \
     || "$f" == .windsurf/rules/* || "$f" == .windsurf/workflows/* ]]
}

_plan_is_dotdir_overwrite() {
  local f="$1" candidate
  for candidate in "${AGTOOSA_DOTDIR_FILES[@]}"; do
    [[ "$f" == "$candidate" ]] && return 0
  done
  return 1
}

# Categorize one relative path; sets PLAN_CAT and PLAN_DETAIL.
_plan_categorize_file() {
  local rel="$1"
  local target="${PROJECT_PATH}/${rel}"
  local old_ver

  PLAN_CAT=""
  PLAN_DETAIL=""

  if [[ "$PLAN_OPERATION" == "update" ]]; then
    if [[ "$rel" == "Docs/.agtoosa-version" ]]; then
      PLAN_CAT="overwrite"
      PLAN_DETAIL="AgToosa-owned, always updated"
      return
    fi
  fi

  if _plan_is_native_overwrite "$rel"; then
    PLAN_CAT="overwrite"
    PLAN_DETAIL="AgToosa-owned, always updated"
    return
  fi

  if [[ "$rel" == .claude/settings.json ]]; then
    if [[ -f "$target" ]]; then
      PLAN_CAT="merge"
      PLAN_DETAIL="merge AgToosa hooks into existing settings"
    else
      PLAN_CAT="new"
      PLAN_DETAIL="New file"
    fi
    return
  fi

  if _plan_is_dotdir_overwrite "$rel"; then
    if [[ ! -f "$target" ]]; then
      PLAN_CAT="new"
      PLAN_DETAIL="New file"
    else
      PLAN_CAT="overwrite"
      PLAN_DETAIL="AgToosa-owned, always updated"
    fi
    return
  fi

  if [[ ! -f "$target" ]]; then
    PLAN_CAT="new"
    PLAN_DETAIL="New file"
    return
  fi

  if [[ "$rel" == "Docs/Master-Plan.md" || "$rel" == "Docs/AgToosa_Changelog.md" || "$rel" == "Docs/Master-Architecture.md" ]]; then
    PLAN_CAT="preserve"
    PLAN_DETAIL="project-owned state preserved"
    return
  fi
  if [[ "$rel" == "Docs/agtoosa-evidence.jsonl" && -f "$target" ]]; then
    PLAN_CAT="preserve"
    PLAN_DETAIL="project-owned evidence ledger preserved"
    return
  fi

  case "$rel" in
    Docs/Context/*)
    if [[ "$FORCE" == true ]]; then
      old_ver="$(extract_version "$target")"
      PLAN_CAT="backup_replace"
      PLAN_DETAIL="backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
    elif declare -F context_is_placeholder_file >/dev/null 2>&1 \
         && context_is_placeholder_file "$target"; then
      local src="${SHIP_DIR}/${rel}"
      [[ "$PLAN_OPERATION" == "update" ]] && src="${TEMPLATE_DIR}/${rel}"
      if [[ -f "$src" ]] && declare -F apply_content_sha256 >/dev/null 2>&1 \
         && [[ "$(apply_content_sha256 "$target")" == "$(apply_content_sha256 "$src")" ]]; then
        PLAN_CAT="up_to_date"
        PLAN_DETAIL="template stub unchanged"
      else
        PLAN_CAT="overwrite"
        PLAN_DETAIL="refresh unfilled Context stub"
      fi
    else
      PLAN_CAT="preserve"
      PLAN_DETAIL="your project config preserved"
    fi
    return
    ;;
  esac

  case "$rel" in
    Docs/*)
    if declare -F apply_content_sha256 >/dev/null 2>&1; then
      local src="${SHIP_DIR}/${rel}"
      [[ "$PLAN_OPERATION" == "update" ]] && src="${TEMPLATE_DIR}/${rel}"
      if [[ -f "$src" ]] && [[ "$(apply_content_sha256 "$target")" == "$(apply_content_sha256 "$src")" ]]; then
        PLAN_CAT="up_to_date"
        PLAN_DETAIL="Already up to date"
      else
        PLAN_CAT="overwrite"
        PLAN_DETAIL="workflow file, always updated"
      fi
    else
      PLAN_CAT="overwrite"
      PLAN_DETAIL="workflow file, always updated"
    fi
    return
    ;;
  esac

  if [[ "$FORCE" == true ]]; then
    old_ver="$(extract_version "$target")"
    if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
      PLAN_CAT="skip"
      PLAN_DETAIL="same version, preserving customizations"
    else
      PLAN_CAT="backup_replace"
      PLAN_DETAIL="backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
    fi
    return
  fi

  old_ver="$(extract_version "$target")"
  if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
    PLAN_CAT="up_to_date"
    PLAN_DETAIL="Already up to date (v${AGTOOSA_VERSION})"
  elif grep -qE 'AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START' "$target" 2>/dev/null; then
    PLAN_CAT="merge"
    PLAN_DETAIL="backup + merge AgToosa block (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
  elif [[ -n "$old_ver" ]]; then
    PLAN_CAT="backup_replace"
    PLAN_DETAIL="backup + replace (v${old_ver} → v${AGTOOSA_VERSION}, old format)"
  else
    PLAN_CAT="merge"
    PLAN_DETAIL="backup + append AgToosa block to existing file"
  fi
}

# Build the relative-path list for update dry-run (mirrors run_update surfaces).
_plan_collect_update_files() {
  local -a files=() deduped=() seen=()
  local f src dup key

  files=()
  for f in "${DOCS_FILES[@]}"; do
    [[ "$f" == "Docs/Master-Plan.md" || "$f" == "Docs/AgToosa_Changelog.md" || "$f" == "Docs/Master-Architecture.md" ]] && continue
    [[ "$f" == "Docs/agtoosa-evidence.jsonl" && -f "${PROJECT_PATH}/${f}" ]] && continue
    src="${TEMPLATE_DIR}/${f}"
    [[ -f "$src" ]] && files+=("$f")
  done

  detect_installed_platforms

  [[ "$USE_CURSOR" == true ]] && files+=(".cursorrules")
  [[ "$USE_WINDSURF" == true ]] && files+=(".windsurfrules")
  [[ "$USE_CLAUDE" == true ]] && files+=("CLAUDE.md" "Docs/AgToosa_Claude.md")
  [[ "$USE_GEMINI" == true ]] && files+=("AGENTS.md" "Docs/AgToosa_Gemini.md")
  [[ "$USE_COPILOT" == true ]] && files+=(".github/copilot-instructions.md")
  [[ "$USE_OPENCODE" == true ]] && files+=("OPENCODE.md")

  if [[ "$USE_CLAUDE" == true ]]; then
    if [[ -d "${PROJECT_PATH}/.claude/commands" ]]; then
      for f in "${CLAUDE_COMMAND_FILES[@]}"; do
        [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
      done
    fi
    if [[ -d "${PROJECT_PATH}/.claude/skills" ]]; then
      for f in "${CLAUDE_SKILL_FILES[@]}"; do
        [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
      done
    fi
    for f in "${CLAUDE_HOOK_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi

  if [[ "$USE_CURSOR" == true && -d "${PROJECT_PATH}/.cursor/rules" ]]; then
    for f in "${CURSOR_RULE_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi
  if [[ "$USE_CURSOR" == true ]]; then
    for f in "${CURSOR_COMMAND_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi

  if [[ "$USE_GEMINI" == true && -d "${PROJECT_PATH}/.gemini/commands" ]]; then
    for f in "${GEMINI_COMMAND_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi

  if [[ "$USE_COPILOT" == true ]]; then
    if [[ -d "${PROJECT_PATH}/.github/prompts" ]]; then
      for f in "${COPILOT_PROMPT_FILES[@]}"; do
        [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
      done
    fi
    if [[ -d "${PROJECT_PATH}/.github/agents" ]]; then
      for f in "${COPILOT_AGENT_FILES[@]}"; do
        [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
      done
    fi
  fi

  if [[ "$USE_WINDSURF" == true && -d "${PROJECT_PATH}/.windsurf/rules" ]]; then
    for f in "${WINDSURF_RULE_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi
  if [[ "$USE_WINDSURF" == true ]]; then
    for f in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi

  if [[ "$USE_OPENCODE" == true ]]; then
    for f in "${CODEX_SKILL_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
    for f in "${CODEX_PROMPT_FILES[@]}"; do
      [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
    done
  fi

  if [[ "$USE_CLAUDE" == true && -f "${PROJECT_PATH}/.claude/settings.json" ]]; then
    files+=(".claude/settings.json")
  fi

  for f in "${AGTOOSA_DOTDIR_FILES[@]}"; do
    [[ -f "${TEMPLATE_DIR}/${f}" ]] && files+=("$f")
  done

  files+=("Docs/.agtoosa-version")

  for f in "${files[@]}"; do
    dup=false
    if ((${#seen[@]} > 0)); then
      for key in "${seen[@]}"; do
        [[ "$key" == "$f" ]] && dup=true && break
      done
    fi
    [[ "$dup" == true ]] && continue
    seen+=("$f")
    deduped+=("$f")
  done
  PLAN_UPDATE_FILES=("${deduped[@]}")
}

# Compute categorized actions for install (SHIP_DIR) or update (TEMPLATE_DIR).
compute_agtoosa_plan() {
  local project_path="$1"
  local operation="$2"
  local -a rel_files=() rel cat detail

  PLAN_OPERATION="$operation"
  PLAN_PROJECT_PATH="$project_path"
  PROJECT_PATH="$project_path"
  PLAN_ACTIONS=()

  case "$operation" in
    install)
      while IFS= read -r rel; do
        [[ -n "$rel" ]] && rel_files+=("$rel")
      done < <(find "$SHIP_DIR" -type f | sed "s|${SHIP_DIR}/||" | sort)
      ;;
    update)
      _plan_collect_update_files
      rel_files=("${PLAN_UPDATE_FILES[@]}")
      ;;
    *)
      echo "Error: invalid plan operation '${operation}' (expected install|update)" >&2
      return 1
      ;;
  esac

  for rel in "${rel_files[@]}"; do
    _plan_categorize_file "$rel"
    cat="$PLAN_CAT"
    detail="$PLAN_DETAIL"
    PLAN_ACTIONS+=("${rel}|${cat}|${detail}")
  done
  return 0
}

_emit_plan_human_line() {
  local rel="$1" cat="$2" detail="$3"

  case "$cat" in
    new)
      echo -e "  ${GREEN}✅${NC} ${rel}  → New file"
      ;;
    overwrite)
      if _plan_is_native_overwrite "$rel" || _plan_is_dotdir_overwrite "$rel" || [[ "$rel" == "Docs/.agtoosa-version" ]]; then
        echo -e "  ${GREEN}✅${NC} ${rel}  → Would overwrite (AgToosa-owned, always updated)"
      else
        echo -e "  ${GREEN}✅${NC} ${rel}  → Would overwrite (workflow file, always updated)"
      fi
      ;;
    merge)
      if [[ "$rel" == .claude/settings.json ]]; then
        echo -e "  ${CYAN}🔀${NC} ${rel}  → Would merge AgToosa hooks into existing settings"
      elif [[ "$detail" == *"append"* ]]; then
        echo -e "  ${CYAN}🔀${NC} ${rel}  → Would backup + append AgToosa block to existing file"
      else
        echo -e "  ${CYAN}🔀${NC} ${rel}  → Would backup + merge AgToosa block (${detail#backup + merge AgToosa block })"
      fi
      ;;
    backup_replace)
      echo -e "  ${CYAN}📦${NC} ${rel}  → Would backup + replace (${detail#backup + replace })"
      ;;
    preserve)
      echo -e "  ${BLUE}🔒${NC} ${rel}  → Would preserve (${detail})"
      ;;
    skip)
      if [[ "$detail" == *"preserving customizations"* || "$detail" == *"preserved"* ]]; then
        echo -e "  ${BLUE}🔒${NC} ${rel}  → Would preserve (${detail})"
      else
        echo -e "  ${YELLOW}⏭${NC}  ${rel}  → Would skip (${detail})"
      fi
      ;;
    up_to_date)
      echo -e "  ${GREEN}✅${NC} ${rel}  → ${detail}"
      ;;
    manual)
      echo -e "  ${YELLOW}✋${NC} ${rel}  → Manual action required (${detail})"
      ;;
    *)
      echo -e "  ${rel}  → ${cat}: ${detail}"
      ;;
  esac
}

emit_plan_human() {
  local entry rel cat detail

  if [[ "$PLAN_OPERATION" == "install" ]]; then
    echo -e "${YELLOW}[DRY RUN] Would copy the following files to ${PROJECT_PATH}:${NC}"
  else
    echo -e "${YELLOW}[DRY RUN] Would update AgToosa in '${PROJECT_PATH}'${NC}"
  fi
  echo ""

  for entry in "${PLAN_ACTIONS[@]}"; do
    IFS='|' read -r rel cat detail <<< "$entry"
    _emit_plan_human_line "$rel" "$cat" "$detail"
  done

  echo ""
  echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply.${NC}"
  echo ""
}

emit_plan_json() {
  local actions_json="" entry rel cat detail

  if ((${#PLAN_ACTIONS[@]} > 0)); then
    for entry in "${PLAN_ACTIONS[@]}"; do
      IFS='|' read -r rel cat detail <<< "$entry"
      if [[ -n "$actions_json" ]]; then
        actions_json+=","
      fi
      actions_json+="$(python3 -c 'import json,sys; print(json.dumps({"path":sys.argv[1],"category":sys.argv[2],"detail":sys.argv[3]}))' "$rel" "$cat" "$detail")"
    done
  fi

  export PLAN_JSON_ACTIONS="$actions_json"
  export PLAN_JSON_OPERATION="$PLAN_OPERATION"
  export PLAN_JSON_PROJECT="$PLAN_PROJECT_PATH"
  export PLAN_JSON_VERSION="$AGTOOSA_VERSION"

  python3 - <<'PY'
import json, os
doc = {
    "schema_version": "plan-result-v1",
    "operation": os.environ["PLAN_JSON_OPERATION"],
    "project_path": os.environ["PLAN_JSON_PROJECT"],
    "generator_version": os.environ["PLAN_JSON_VERSION"],
    "actions": json.loads("[" + os.environ.get("PLAN_JSON_ACTIONS", "") + "]"),
}
print(json.dumps(doc, ensure_ascii=False, separators=(",", ":")))
PY
}
