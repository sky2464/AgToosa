#!/usr/bin/env bash

# ── AgToosa: install helpers ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, PACK_QUEUE_DIR, FORCE, USE_*, DOCS_FILES, CONTEXT_FILES,
#               AGTOOSA_VERSION, BAK_FILES, colors.
# Globals modified: COPIED, SKIPPED, EXISTING_FILES, KEEP_SHIP.

# Destinations a pack must never write to: executable-hook and CI surfaces.
# Canonical definition (lib/registry.sh defines a guarded copy for standalone use).
PACK_DENYLIST_PATTERNS=(
  ".claude/settings.json"
  ".claude/hooks/"
  ".github/workflows/"
)

# Return 0 when a pack-relative path is on the sensitive denylist.
pack_path_denied() {
  local rel="${1#/}"
  local pat
  for pat in "${PACK_DENYLIST_PATTERNS[@]}"; do
    if [[ "$pat" == */ ]]; then
      [[ "$rel" == "$pat"* ]] && return 0
    else
      [[ "$rel" == "$pat" ]] && return 0
    fi
  done
  return 1
}

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
  if [[ "$USE_COPILOT" == true || "$USE_VSCODE" == true ]]; then
    local cinstr
    for cinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${cinstr}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi

  if [[ "$USE_OPENCODE" == true ]]; then
    [[ -f "${PROJECT_PATH}/OPENCODE.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    local codex_skill
    for codex_skill in "${CODEX_SKILL_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${codex_skill}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    local codex_prompt
    for codex_prompt in "${CODEX_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${codex_prompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${PROJECT_PATH}/${cfile}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  done
  if [[ "$USE_CLAUDE" == true ]]; then
    local ccmd cskill chook
    for ccmd in "${CLAUDE_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${ccmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    [[ -f "${PROJECT_PATH}/.claude/settings.json" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    for cskill in "${CLAUDE_SKILL_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${cskill}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for chook in "${CLAUDE_HOOK_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${chook}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_CURSOR" == true ]]; then
    local crule ccmd
    for crule in "${CURSOR_RULE_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${crule}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for ccmd in "${CURSOR_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${ccmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_GEMINI" == true ]]; then
    local gcmd
    for gcmd in "${GEMINI_COMMAND_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${gcmd}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_COPILOT" == true ]]; then
    local pprompt pagent
    for pprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${pprompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for pagent in "${COPILOT_AGENT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${pagent}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_VSCODE" == true && "$USE_COPILOT" != true ]]; then
    [[ -f "${PROJECT_PATH}/.github/copilot-instructions.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    local vprompt vagent
    for vprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${vprompt}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for vagent in "${COPILOT_AGENT_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${vagent}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  if [[ "$USE_WINDSURF" == true ]]; then
    local wrule wflow
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${wrule}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
    for wflow in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      [[ -f "${PROJECT_PATH}/${wflow}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
    done
  fi
  return 0
}

# Copy pack files into PROJECT_PATH, skipping disallowed file types and
# sensitive destinations. Revalidates paths at merge time (the queue may have
# been modified between install and merge).
_merge_pack() {
  local pack_dir="$1" pack_name="$2"
  local allowed_exts="md json toml mdc"
  local count=0
  local canonical_dir
  canonical_dir=$(realpath "$pack_dir" 2>/dev/null || readlink -f "$pack_dir" 2>/dev/null || echo "$pack_dir")
  while IFS= read -r -d '' f; do
    [[ "$(basename "$f")" == ".pack-meta.json" ]] && continue

    # Merge-time containment check: symlinks or tampered queue content must
    # not let a pack read or write outside its own directory.
    local canonical_file
    canonical_file=$(realpath "$f" 2>/dev/null || readlink -f "$f" 2>/dev/null || echo "$f")
    if [[ "$canonical_file" != "$canonical_dir"/* ]]; then
      echo -e "  ${YELLOW}⏭${NC}  Skipping path-escaping file: ${f#"$pack_dir"}" >&2
      continue
    fi

    local ext="${f##*.}"
    local allowed=false
    for e in $allowed_exts; do
      [[ "$ext" == "$e" ]] && allowed=true && break
    done
    if [[ "$allowed" == false ]]; then
      echo -e "  ${YELLOW}⏭${NC}  Skipping disallowed file: ${f#"$pack_dir"}" >&2
      continue
    fi

    local rel="${f#"$pack_dir"}"
    rel="${rel#/}"
    if pack_path_denied "$rel"; then
      echo -e "  ${YELLOW}⛔${NC} Skipping sensitive destination: ${rel} (packs may not write hook or CI surfaces)" >&2
      continue
    fi

    local dst="${PROJECT_PATH}/${rel}"
    mkdir -p "$(dirname "$dst")"
    cp "$f" "$dst"
    count=$((count + 1))
  done < <(find -L "$pack_dir" -type f -print0)
  apply_verbose_echo "  ${GREEN}✅${NC} Pack '${pack_name}': ${count} files merged"
}

# Merge all pack subdirectories under packs_root. When clear_after is true, remove each
# pack dir after a successful merge (used for the durable pack queue).
# Sets _PACK_MERGE_COUNT and appends lock meta paths to _PACK_LOCK_ENTRIES.
_merge_packs_under_root() {
  local packs_root="$1"
  local clear_after="${2:-false}"
  _PACK_MERGE_COUNT=0
  _PACK_LOCK_ENTRIES=()

  [[ -d "$packs_root" ]] || return 0

  local pack_dir pname
  for pack_dir in "${packs_root}"/*/; do
    [[ -d "$pack_dir" ]] || continue
    pname=$(basename "$pack_dir")
    if _merge_pack "$pack_dir" "$pname"; then
      _PACK_MERGE_COUNT=$((_PACK_MERGE_COUNT + 1))
      if [[ -f "${pack_dir}/.pack-meta.json" ]]; then
        # Snapshot metadata before the queue dir is removed; lock write happens later.
        _PACK_LOCK_ENTRIES+=("$(cat "${pack_dir}/.pack-meta.json")")
      fi
      if [[ "$clear_after" == true ]]; then
        rm -rf "$pack_dir"
      fi
    fi
  done
}

_merge_pack_queue() {
  _merge_packs_under_root "$PACK_QUEUE_DIR" true
}

_merge_ship_staged_packs() {
  _merge_packs_under_root "${SHIP_DIR}/packs" false
}

# Write or update Docs/agtoosa-lock.json with installed pack entries.
_write_lock_file() {
  local meta_files=("$@")
  local lock_file="${PROJECT_PATH}/Docs/agtoosa-lock.json"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  local packs_json=""
  local sep=""
  for meta in "${meta_files[@]}"; do
    local entry
    if [[ -f "$meta" ]]; then
      entry=$(cat "$meta")
    else
      entry="$meta"
    fi
    [[ -n "$entry" ]] || continue
    packs_json+="${sep}    ${entry}"
    sep=$',\n'
  done

  if [[ -f "$lock_file" ]] && command -v jq &>/dev/null; then
    local existing_names=()
    while IFS= read -r n; do existing_names+=("$n"); done \
      < <(jq -r '.packs[]?.name' "$lock_file" 2>/dev/null)
    local new_names=()
    for meta in "${meta_files[@]}"; do
      local n
      if command -v jq &>/dev/null; then
        if [[ -f "$meta" ]]; then
          n=$(jq -r '.name' "$meta" 2>/dev/null)
        else
          n=$(echo "$meta" | jq -r '.name' 2>/dev/null)
        fi
      elif [[ -f "$meta" ]]; then
        n=$(grep -oP '"name":\s*"\K[^"]+' "$meta" | head -1)
      else
        n=$(echo "$meta" | grep -oP '"name":\s*"\K[^"]+' | head -1)
      fi
      [[ -n "$n" ]] || continue
      new_names+=("$n")
    done
    local kept_json=""
    local ksep=""
    while IFS= read -r existing_entry; do
      local ename
      ename=$(echo "$existing_entry" | jq -r '.name' 2>/dev/null)
      local skip=false
      for nn in "${new_names[@]}"; do [[ "$ename" == "$nn" ]] && skip=true && break; done
      if [[ "$skip" == false ]]; then
        kept_json+="${ksep}    $(echo "$existing_entry" | jq -c '.')"
        ksep=$',\n'
      fi
    done < <(jq -c '.packs[]?' "$lock_file" 2>/dev/null)
    if [[ -n "$kept_json" ]]; then
      packs_json="${kept_json}"$',\n'"    ${packs_json#    }"
    fi
  fi

  mkdir -p "${PROJECT_PATH}/Docs"
  printf '{\n  "agtoosa_version": "%s",\n  "generated_at": "%s",\n  "packs": [\n%s\n  ]\n}\n' \
    "$AGTOOSA_VERSION" "$timestamp" "$packs_json" > "$lock_file"
  echo -e "  ${GREEN}✅${NC} Docs/agtoosa-lock.json updated"
}

# Copy all staged files from ship/ into PROJECT_PATH, then print summary + next steps.
install_files() {
  mkdir -p "${PROJECT_PATH}/Docs/archived" "${PROJECT_PATH}/Docs/Context"
  if declare -F apply_reset_summary >/dev/null 2>&1; then
    apply_reset_summary
  fi

  # Docs/ workflow files overwrite on install except project-owned state
  # (Master-Plan, Changelog, Master-Architecture — same boundaries as --update).
  # DEV-092: hash-aware apply for Docs overwrites (shared with update via apply_*).
  local file
  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${file}" ]]; then
      if [[ "$file" == "Docs/Master-Plan.md" || "$file" == "Docs/AgToosa_Changelog.md" || \
            "$file" == "Docs/Master-Architecture.md" ]]; then
        if [[ -f "${PROJECT_PATH}/${file}" ]]; then
          if declare -F apply_note_preserved >/dev/null 2>&1; then
            apply_note_preserved
          fi
          local preserve_reason="your project plan"
          [[ "$file" == "Docs/AgToosa_Changelog.md" ]] && preserve_reason="your changelog"
          [[ "$file" == "Docs/Master-Architecture.md" ]] && preserve_reason="your architecture"
          echo -e "  ${BLUE}🔒${NC} Preserved ${file} ${CYAN}(${preserve_reason})${NC}"
          SKIPPED=$((SKIPPED + 1))
          continue
        fi
        if [[ "$file" == "Docs/Master-Architecture.md" ]]; then
          copy_platform_file "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}" "${file}"
          continue
        fi
      fi
      mkdir -p "$(dirname "${PROJECT_PATH}/${file}")"
      if declare -F apply_copy_if_changed >/dev/null 2>&1; then
        apply_copy_if_changed "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}" "${file}"
      else
        cp "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}"
        apply_verbose_echo "  ${GREEN}✅${NC} ${file}"
      fi
      COPIED=$((COPIED + 1))
    fi
  done

  # Platform entry-point dotfiles — smart merge/append
  local dotfile
  for dotfile in .cursorrules .windsurfrules; do
    [[ -f "${SHIP_DIR}/${dotfile}" ]] \
      && merge_platform_file "${SHIP_DIR}/${dotfile}" "${PROJECT_PATH}/${dotfile}" "${dotfile}"
  done

  # Platform entry-point markdown files — smart merge/append
  local mdfile
  for mdfile in CLAUDE.md AGENTS.md OPENCODE.md; do
    [[ -f "${SHIP_DIR}/${mdfile}" ]] \
      && merge_platform_file "${SHIP_DIR}/${mdfile}" "${PROJECT_PATH}/${mdfile}" "${mdfile}"
  done

  # Pure AgToosa Docs — hash-aware overwrite
  local pdoc
  for pdoc in Docs/AgToosa_Claude.md Docs/AgToosa_Gemini.md; do
    if [[ -f "${SHIP_DIR}/${pdoc}" ]]; then
      if declare -F apply_copy_if_changed >/dev/null 2>&1; then
        apply_copy_if_changed "${SHIP_DIR}/${pdoc}" "${PROJECT_PATH}/${pdoc}" "${pdoc}" || return 1
      else
        cp "${SHIP_DIR}/${pdoc}" "${PROJECT_PATH}/${pdoc}"
        apply_verbose_echo "  ${GREEN}✅${NC} ${pdoc}"
      fi
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

  if [[ "$USE_COPILOT" == true || "$USE_VSCODE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/instructions"
    local cinstr cinstr_count=0
    for cinstr in "${COPILOT_INSTRUCTION_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${cinstr}" ]]; then
        cp "${SHIP_DIR}/${cinstr}" "${PROJECT_PATH}/${cinstr}"
        cinstr_count=$((cinstr_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $cinstr_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .github/instructions/ (${cinstr_count} scoped instruction files)"
  fi

  # Context/ stubs — skip if exists (user may have filled them in)
  local cfile
  for cfile in "${CONTEXT_FILES[@]}"; do
    [[ -f "${SHIP_DIR}/${cfile}" ]] \
      && copy_platform_file "${SHIP_DIR}/${cfile}" "${PROJECT_PATH}/${cfile}" "${cfile}"
  done

  # .agtoosa/ config index + examples — overwrite AgToosa-owned examples only
  # (never write live evidence.yml / policy.yaml from the pack).
  local afile agtoosa_count=0
  mkdir -p "${PROJECT_PATH}/.agtoosa"
  for afile in "${AGTOOSA_DOTDIR_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${afile}" ]]; then
      cp "${SHIP_DIR}/${afile}" "${PROJECT_PATH}/${afile}"
      agtoosa_count=$((agtoosa_count + 1))
      COPIED=$((COPIED + 1))
    fi
  done
  [[ $agtoosa_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .agtoosa/ (${agtoosa_count} config index + evidence example)"

  # Claude Code commands, hooks, and skills — always overwrite (AgToosa-owned)
  if [[ "$USE_CLAUDE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.claude/commands" "${PROJECT_PATH}/.claude/skills" "${PROJECT_PATH}/.claude/hooks"
    local ccmd ccmd_count=0 cskill cskill_count=0 chook chook_count=0
    for ccmd in "${CLAUDE_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${ccmd}" ]]; then
        cp "${SHIP_DIR}/${ccmd}" "${PROJECT_PATH}/${ccmd}"
        ccmd_count=$((ccmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $ccmd_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .claude/commands/ (${ccmd_count} slash commands)"

    [[ -f "${SHIP_DIR}/.claude/settings.json" ]] \
      && merge_settings_json "${SHIP_DIR}/.claude/settings.json" \
                             "${PROJECT_PATH}/.claude/settings.json" \
                             ".claude/settings.json"

    for cskill in "${CLAUDE_SKILL_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${cskill}" ]]; then
        cp "${SHIP_DIR}/${cskill}" "${PROJECT_PATH}/${cskill}"
        cskill_count=$((cskill_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $cskill_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .claude/skills/ (${cskill_count} project skill)"

    for chook in "${CLAUDE_HOOK_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${chook}" ]]; then
        cp "${SHIP_DIR}/${chook}" "${PROJECT_PATH}/${chook}"
        chmod +x "${PROJECT_PATH}/${chook}" 2>/dev/null || true
        chook_count=$((chook_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $chook_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .claude/hooks/ (${chook_count} hook script)"
  fi

  # Cursor rules and commands — always overwrite (AgToosa-owned)
  if [[ "$USE_CURSOR" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.cursor/rules" "${PROJECT_PATH}/.cursor/commands"
    local crule crule_count=0 ccmd ccmd_count=0
    for crule in "${CURSOR_RULE_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${crule}" ]]; then
        cp "${SHIP_DIR}/${crule}" "${PROJECT_PATH}/${crule}"
        crule_count=$((crule_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $crule_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .cursor/rules/ (${crule_count} MDX rules)"

    for ccmd in "${CURSOR_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${ccmd}" ]]; then
        cp "${SHIP_DIR}/${ccmd}" "${PROJECT_PATH}/${ccmd}"
        ccmd_count=$((ccmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $ccmd_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .cursor/commands/ (${ccmd_count} slash commands)"
  fi

  # Gemini CLI native commands — always overwrite (AgToosa-owned)
  if [[ "$USE_GEMINI" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.gemini/commands"
    local gcmd gcmd_count=0
    for gcmd in "${GEMINI_COMMAND_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${gcmd}" ]]; then
        cp "${SHIP_DIR}/${gcmd}" "${PROJECT_PATH}/${gcmd}"
        gcmd_count=$((gcmd_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $gcmd_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .gemini/commands/ (${gcmd_count} TOML commands)"
  fi

  # GitHub Copilot reusable prompts + custom agent — always overwrite (AgToosa-owned)
  if [[ "$USE_COPILOT" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/prompts" "${PROJECT_PATH}/.github/agents"
    local pprompt pprompt_count=0
    for pprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${pprompt}" ]]; then
        cp "${SHIP_DIR}/${pprompt}" "${PROJECT_PATH}/${pprompt}"
        pprompt_count=$((pprompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $pprompt_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .github/prompts/ (${pprompt_count} reusable prompts)"
    local pagent pagent_count=0
    for pagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${pagent}" ]]; then
        cp "${SHIP_DIR}/${pagent}" "${PROJECT_PATH}/${pagent}"
        pagent_count=$((pagent_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $pagent_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .github/agents/ (${pagent_count} custom agents)"
  fi

  # VS Code generic prompts + custom agent — always overwrite (AgToosa-owned)
  if [[ "$USE_VSCODE" == true && "$USE_COPILOT" != true ]]; then
    mkdir -p "${PROJECT_PATH}/.github/prompts" "${PROJECT_PATH}/.github/agents"
    local vprompt vprompt_count=0
    for vprompt in "${COPILOT_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${vprompt}" ]]; then
        cp "${SHIP_DIR}/${vprompt}" "${PROJECT_PATH}/${vprompt}"
        vprompt_count=$((vprompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $vprompt_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .github/prompts/ (${vprompt_count} reusable prompts)"
    local vagent vagent_count=0
    for vagent in "${COPILOT_AGENT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${vagent}" ]]; then
        cp "${SHIP_DIR}/${vagent}" "${PROJECT_PATH}/${vagent}"
        vagent_count=$((vagent_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $vagent_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .github/agents/ (${vagent_count} custom agents)"
  fi

  # Codex skills — always overwrite (AgToosa-owned)
  if [[ "$USE_OPENCODE" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.codex/skills"
    local codex_skill codex_skill_count=0
    for codex_skill in "${CODEX_SKILL_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${codex_skill}" ]]; then
        mkdir -p "$(dirname "${PROJECT_PATH}/${codex_skill}")"
        cp "${SHIP_DIR}/${codex_skill}" "${PROJECT_PATH}/${codex_skill}"
        codex_skill_count=$((codex_skill_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $codex_skill_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .codex/skills/ (${codex_skill_count} Codex skills)"

    mkdir -p "${PROJECT_PATH}/.codex/prompts"
    local codex_prompt codex_prompt_count=0
    for codex_prompt in "${CODEX_PROMPT_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${codex_prompt}" ]]; then
        mkdir -p "$(dirname "${PROJECT_PATH}/${codex_prompt}")"
        cp "${SHIP_DIR}/${codex_prompt}" "${PROJECT_PATH}/${codex_prompt}"
        codex_prompt_count=$((codex_prompt_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $codex_prompt_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .codex/prompts/ (${codex_prompt_count} Codex slash prompts)"
  fi

  # Windsurf rules and workflows — always overwrite (AgToosa-owned)
  if [[ "$USE_WINDSURF" == true ]]; then
    mkdir -p "${PROJECT_PATH}/.windsurf/rules" "${PROJECT_PATH}/.windsurf/workflows"
    local wrule wrule_count=0 wflow wflow_count=0
    for wrule in "${WINDSURF_RULE_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${wrule}" ]]; then
        cp "${SHIP_DIR}/${wrule}" "${PROJECT_PATH}/${wrule}"
        wrule_count=$((wrule_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $wrule_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .windsurf/rules/ (${wrule_count} rules)"

    for wflow in "${WINDSURF_WORKFLOW_FILES[@]}"; do
      if [[ -f "${SHIP_DIR}/${wflow}" ]]; then
        cp "${SHIP_DIR}/${wflow}" "${PROJECT_PATH}/${wflow}"
        wflow_count=$((wflow_count + 1))
        COPIED=$((COPIED + 1))
      fi
    done
    [[ $wflow_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} .windsurf/workflows/ (${wflow_count} workflows)"
  fi


  # Merge durable pack queue, then any same-session ship/packs/ staging.
  local pack_count=0
  local new_lock_entries=()
  _merge_pack_queue
  pack_count=$((pack_count + _PACK_MERGE_COUNT))
  if [[ ${#_PACK_LOCK_ENTRIES[@]} -gt 0 ]]; then
    new_lock_entries+=("${_PACK_LOCK_ENTRIES[@]}")
  fi
  _merge_ship_staged_packs
  pack_count=$((pack_count + _PACK_MERGE_COUNT))
  if [[ ${#_PACK_LOCK_ENTRIES[@]} -gt 0 ]]; then
    new_lock_entries+=("${_PACK_LOCK_ENTRIES[@]}")
  fi
  [[ $pack_count -gt 0 ]] && apply_verbose_echo "  ${GREEN}✅${NC} Packs merged: ${pack_count}"
  # DEV-093: always reconcile lock (platforms + packs) on install; path Docs/agtoosa-lock.json.
  if declare -F lock_reconcile >/dev/null 2>&1; then
    if [[ ${#new_lock_entries[@]} -gt 0 ]]; then
      lock_reconcile "$PROJECT_PATH" "${new_lock_entries[@]}"
    else
      lock_reconcile "$PROJECT_PATH"
    fi
  elif [[ ${#new_lock_entries[@]} -gt 0 ]]; then
    _write_lock_file "${new_lock_entries[@]}"
  fi

  # Write version marker (enables --update to know installed version)
  echo "$AGTOOSA_VERSION" > "${PROJECT_PATH}/Docs/.agtoosa-version"

  # DEV-093: operational state after successful install apply
  if declare -F state_write_after_apply >/dev/null 2>&1; then
    state_write_after_apply "$PROJECT_PATH" "install"
  fi

  # Summary
  echo ""
  local summary_verb="installed"
  [[ "${SMART_UPGRADE_MODE:-false}" == true ]] && summary_verb="applied"
  if declare -F emit_apply_summary_human >/dev/null 2>&1; then
    emit_apply_summary_human "$summary_verb"
  else
    echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
    apply_verbose_echo "  ${GREEN}Copied:  ${COPIED} files${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} ${summary_verb} to ${PROJECT_PATH}${NC}"
  fi

  # Warn about .bak files when backups were created
  if [[ ${#BAK_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Backup files created — add ${BOLD}*.bak.*${NC}${YELLOW} to your .gitignore${NC}"
    if ((${#BAK_FILES[@]} <= 3)); then
      local bak
      for bak in "${BAK_FILES[@]}"; do
        echo -e "    ${CYAN}${bak#"${PROJECT_PATH}/"}${NC}"
      done
    else
      echo -e "    ${CYAN}${#BAK_FILES[@]} backup files in project root${NC}"
    fi
  fi

  if declare -F offer_cleanup_after_apply >/dev/null 2>&1; then
    offer_cleanup_after_apply "$PROJECT_PATH"
  fi

  echo ""
  echo -e "${BOLD}➡️  Next steps:${NC}"
  echo ""
  echo -e "  ${CYAN}1.${NC} Open your AI assistant in ${BOLD}${PROJECT_PATH}${NC}"
  echo ""
  if [[ "${SMART_UPGRADE_MODE:-false}" == true ]] \
     && declare -F project_context_initialized >/dev/null 2>&1 \
     && project_context_initialized; then
    echo -e "  ${CYAN}2.${NC} Continue with the 4-command workflow:"
    echo -e "     ${BOLD}/agtoosa-spec${NC}    → Research, specify, and plan"
    echo -e "     ${BOLD}/agtoosa-build${NC}   → TDD build and test"
    echo -e "     ${BOLD}/agtoosa-review${NC}  → Multi-persona code review"
    echo -e "     ${BOLD}/agtoosa-ship${NC}    → Deploy, archive, and suggest next"
  elif [[ "${SMART_UPGRADE_MODE:-false}" == true ]]; then
    echo -e "  ${CYAN}2.${NC} Run ${BOLD}/agtoosa-init${NC} to finish Context setup"
    echo ""
    echo -e "  ${CYAN}3.${NC} Then use the 4-command workflow:"
    echo -e "     ${BOLD}/agtoosa-spec${NC}    → Research, specify, and plan"
    echo -e "     ${BOLD}/agtoosa-build${NC}   → TDD build and test"
    echo -e "     ${BOLD}/agtoosa-review${NC}  → Multi-persona code review"
    echo -e "     ${BOLD}/agtoosa-ship${NC}    → Deploy, archive, and suggest next"
  else
    echo -e "  ${CYAN}2.${NC} Run ${BOLD}/agtoosa-init${NC} to set up your project (one-time)"
    echo ""
    echo -e "  ${CYAN}3.${NC} Then use the 4-command workflow:"
    echo -e "     ${BOLD}/agtoosa-spec${NC}    → Research, specify, and plan"
    echo -e "     ${BOLD}/agtoosa-build${NC}   → TDD build and test"
    echo -e "     ${BOLD}/agtoosa-review${NC}  → Multi-persona code review"
    echo -e "     ${BOLD}/agtoosa-ship${NC}    → Deploy, archive, and suggest next"
  fi
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
