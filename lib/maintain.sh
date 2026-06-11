#!/usr/bin/env bash

# ── AgToosa: verify / doctor / uninstall helpers ───────────────
# Sourced by agtoosa.sh.
# Globals read: SCRIPT_DIR, TEMPLATE_DIR, AGTOOSA_VERSION, FORCE, ASSUME_YES,
#               DOCS_FILES, OPTIONAL_TEMPLATE_FILES, CONTEXT_FILES, colors.

# Run the deterministic lifecycle verifier against a target repo.
# Prefers the target's installed copy (so downstream pins stay honest),
# falls back to the template copy shipped with the generator.
run_verify() {
  local target="$1"
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi
  local script=""
  for candidate in "${target}/Docs/agtoosa-verify.sh" "${target}/docs/agtoosa-verify.sh" \
                   "${TEMPLATE_DIR}/Docs/agtoosa-verify.sh"; do
    [[ -f "$candidate" ]] && script="$candidate" && break
  done
  if [[ -z "$script" ]]; then
    echo -e "${RED}❌ Error: agtoosa-verify.sh not found in target or template.${NC}" >&2
    return 2
  fi
  bash "$script" --root "$target"
}

# Diagnose an existing AgToosa install: version skew, platform wiring,
# context health, pending pack queue, and stale backups.
run_doctor() {
  local target="$1"
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 2
  fi

  echo -e "${BOLD}AgToosa Doctor — ${target}${NC}"
  echo ""
  local issues=0

  # Install presence + version skew.
  if [[ -f "${target}/Docs/.agtoosa-version" ]]; then
    local installed
    installed=$(cat "${target}/Docs/.agtoosa-version")
    if [[ "$installed" == "$AGTOOSA_VERSION" ]]; then
      echo -e "  ${GREEN}✅${NC} Installed version ${installed} matches generator v${AGTOOSA_VERSION}"
    else
      echo -e "  ${YELLOW}⚠️${NC}  Installed v${installed}, generator v${AGTOOSA_VERSION} — run: bash agtoosa.sh --update '${target}'"
      issues=$((issues + 1))
    fi
  elif [[ -d "${target}/Docs" ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  Docs/ exists but no Docs/.agtoosa-version marker (pre-3.x install or partial copy)"
    issues=$((issues + 1))
  else
    echo -e "  ${RED}❌${NC} No Docs/ directory — AgToosa is not installed here. Run: bash agtoosa.sh"
    return 1
  fi

  # Core workflow docs present.
  local missing=0 f
  for f in "${DOCS_FILES[@]}"; do
    [[ -f "${target}/${f}" ]] || missing=$((missing + 1))
  done
  if [[ $missing -eq 0 ]]; then
    echo -e "  ${GREEN}✅${NC} All ${#DOCS_FILES[@]} core workflow docs present"
  else
    echo -e "  ${YELLOW}⚠️${NC}  ${missing} core workflow doc(s) missing — run --update to restore"
    issues=$((issues + 1))
  fi

  # Platform entry-point wiring: config dirs without entry files and vice versa.
  if [[ -d "${target}/.cursor" && ! -f "${target}/.cursorrules" ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  .cursor/ exists but .cursorrules entry point is missing"
    issues=$((issues + 1))
  fi
  if [[ -d "${target}/.windsurf" && ! -f "${target}/.windsurfrules" ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  .windsurf/ exists but .windsurfrules entry point is missing"
    issues=$((issues + 1))
  fi
  if [[ -d "${target}/.claude" && ! -f "${target}/CLAUDE.md" ]]; then
    echo -e "  ${YELLOW}⚠️${NC}  .claude/ exists but CLAUDE.md entry point is missing"
    issues=$((issues + 1))
  fi

  # Context health.
  if [[ -d "${target}/Docs/Context" ]]; then
    if grep -lE '\[name\]|\[url\]|\[e\.g\.' "${target}/Docs/Context/"*.md >/dev/null 2>&1; then
      echo -e "  ${YELLOW}⚠️${NC}  Context files still contain template placeholders — run /agtoosa-init"
      issues=$((issues + 1))
    else
      echo -e "  ${GREEN}✅${NC} Context files populated"
    fi
  fi

  # Pending pack queue in the generator checkout.
  if [[ -d "$PACK_QUEUE_DIR" ]] && find "$PACK_QUEUE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | grep -q .; then
    echo -e "  ${CYAN}ℹ️${NC}  Queued pack(s) pending merge — run: bash agtoosa.sh (install) to merge them"
  fi

  # Stale backup files.
  local baks
  baks=$(find "$target" -maxdepth 2 -name '*.bak.*' 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$baks" -gt 0 ]]; then
    echo -e "  ${CYAN}ℹ️${NC}  ${baks} backup file(s) (*.bak.*) present — clean up and gitignore them"
  fi

  echo ""
  if [[ $issues -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}Doctor result: healthy.${NC}"
    return 0
  fi
  echo -e "${YELLOW}${BOLD}Doctor result: ${issues} issue(s) found.${NC}"
  return 1
}

# Remove AgToosa-owned files from a project. Preserves user data:
# Master-Plan, Master-Architecture, Changelog, Context/, archived/, and any
# platform entry-point files that may contain user content (those get a notice).
run_uninstall() {
  local target="$1"
  if [[ -z "$target" ]]; then
    read -rp "Project path to uninstall AgToosa from: " target
    target="${target/#\~/$HOME}"
    target="${target%/}"
  fi
  if [[ ! -d "$target" ]]; then
    echo -e "${RED}❌ Error: Directory '${target}' does not exist.${NC}" >&2
    return 1
  fi
  if [[ ! -d "${target}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory in '${target}' — nothing to uninstall.${NC}" >&2
    return 1
  fi

  local _rp_target _rp_script
  _rp_target="$(cd "$target" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_target" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}" >&2
    return 1
  fi

  echo -e "${BOLD}Uninstall AgToosa from: ${target}${NC}"
  echo "Removes AgToosa-owned workflow docs and platform command/rule files."
  echo "Preserves: Master-Plan.md, Master-Architecture.md, AgToosa_Changelog.md,"
  echo "           Docs/Context/, Docs/archived/, and merged platform entry-point files."
  echo ""
  local reply
  if [[ "$ASSUME_YES" == true ]]; then
    reply="Y"
  else
    read -rp "Proceed? (y/N): " reply
    reply="${reply:-N}"
  fi
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  local removed=0 f
  for f in "${DOCS_FILES[@]}"; do
    case "$f" in
      Docs/Master-Plan.md|Docs/Master-Architecture.md|Docs/AgToosa_Changelog.md) continue ;;
    esac
    if [[ -f "${target}/${f}" ]]; then
      rm -f "${target}/${f}"
      removed=$((removed + 1))
    fi
  done
  for f in "${OPTIONAL_TEMPLATE_FILES[@]}"; do
    # Entry-point files may carry user content from smart merges — leave them.
    case "$f" in
      .cursorrules|.windsurfrules|CLAUDE.md|AGENTS.md|OPENCODE.md|.github/copilot-instructions.md) continue ;;
    esac
    if [[ -f "${target}/${f}" ]]; then
      rm -f "${target}/${f}"
      removed=$((removed + 1))
    fi
  done
  if [[ -f "${target}/Docs/.agtoosa-version" ]]; then
    rm -f "${target}/Docs/.agtoosa-version"
    removed=$((removed + 1))
  fi

  # Remove now-empty AgToosa-owned directories (never user dirs like Docs/).
  local d
  for d in .claude/commands .claude/skills .claude/hooks .cursor/rules .cursor/commands \
           .gemini/commands .github/prompts .github/agents .github/instructions \
           .codex/skills .codex/prompts .windsurf/rules .windsurf/workflows; do
    [[ -d "${target}/${d}" ]] && find "${target}/${d}" -type d -empty -delete 2>/dev/null
  done

  echo ""
  echo -e "${GREEN}✅ Removed ${removed} AgToosa-owned file(s).${NC}"
  echo -e "${CYAN}ℹ️  Merged entry-point files (.cursorrules, CLAUDE.md, AGENTS.md, …) were kept;${NC}"
  echo -e "${CYAN}   delete the AGTOOSA START/END blocks inside them manually if desired.${NC}"
  return 0
}
