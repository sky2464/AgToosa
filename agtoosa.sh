#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# AgToosa — Local Interactive Generator
# Detects your AI assistant(s), generates the necessary files,
# and copies them directly to your project.
#
# Usage:
#   bash agtoosa.sh [--force] [--dry-run] [--version] [--help]
# ──────────────────────────────────────────────────────────────

AGTOOSA_VERSION="2.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"
SHIP_DIR="${SCRIPT_DIR}/ship"

DOCS_FILES=(
  "Docs/AgToosa_Agent.md"
  "Docs/AgToosa_Init.md"
  "Docs/AgToosa_Spec.md"
  "Docs/AgToosa_Build.md"
  "Docs/AgToosa_Review.md"
  "Docs/AgToosa_Ship.md"
  "Docs/AgToosa_QA.md"
  "Docs/AgToosa_Revert.md"
  "Docs/AgToosa_Skills.md"
  "Docs/Master-Plan.md"
  "Docs/AgToosa_Changelog.md"
)

OPTIONAL_TEMPLATE_FILES=(
  "Docs/AgToosa_Claude.md"
  "Docs/AgToosa_Gemini.md"
  ".cursorrules"
  ".windsurfrules"
  "CLAUDE.md"
  "AGENTS.md"
  ".github/copilot-instructions.md"
  ".roorules"
  "OPENCODE.md"
)

CONTEXT_FILES=(
  "Docs/Context/workflow.md"
  "Docs/Context/tech-stack.md"
  "Docs/Context/product.md"
  "Docs/Context/product-guidelines.md"
)

print_usage() {
  echo "AgToosa Generator v${AGTOOSA_VERSION}"
  echo ""
  echo "Usage: bash agtoosa.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --force                Overwrite existing platform config files (creates .bak backups)"
  echo "  --dry-run              Show what would be copied without making changes"
  echo "  --list-template-files  Print every template file path and exit"
  echo "  --version              Print version and exit"
  echo "  --help                 Show this help message"
}

print_template_files() {
  printf '%s\n' "${DOCS_FILES[@]}" "${OPTIONAL_TEMPLATE_FILES[@]}" "${CONTEXT_FILES[@]}"
}

# ── Version marker helpers (DEV-129) ─────────────────────────
# Inject AgToosa version header at top of a platform entry-point file
inject_version() {
  local src="$1" dst="$2"
  case "$src" in
    *.md) { printf '<!-- AgToosa v%s -->\n\n' "${AGTOOSA_VERSION}"; cat "$src"; } > "$dst" ;;
    *)    { printf '# AgToosa v%s\n\n' "${AGTOOSA_VERSION}"; cat "$src"; } > "$dst" ;;
  esac
}

# Extract AgToosa version string from an installed file
extract_version() {
  grep -m1 -oE 'AgToosa v[0-9]+\.[0-9]+\.[0-9]+' "$1" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo ""
}

# Returns 0 (true) if semver $1 is strictly less than $2
version_lt() {
  local a="$1" b="$2"
  [ "$a" = "$b" ] && return 1
  local a1 a2 a3 b1 b2 b3
  IFS='.' read -r a1 a2 a3 <<< "$a"
  IFS='.' read -r b1 b2 b3 <<< "$b"
  a1="${a1:-0}"; a2="${a2:-0}"; a3="${a3:-0}"
  b1="${b1:-0}"; b2="${b2:-0}"; b3="${b3:-0}"
  (( 10#$a1 < 10#$b1 )) && return 0
  (( 10#$a1 > 10#$b1 )) && return 1
  (( 10#$a2 < 10#$b2 )) && return 0
  (( 10#$a2 > 10#$b2 )) && return 1
  (( 10#$a3 < 10#$b3 )) && return 0
  return 1
}

# Create a timestamped .bak file and record it (DEV-130)
BAK_FILES=()
backup_file() {
  local f="$1"
  local bak="${f}.bak.$(date +%Y%m%d-%H%M)"
  cp "$f" "$bak"
  printf '%s' "$bak"
}

# Copy a platform entry-point file with version-aware --force logic (DEV-128, DEV-130, DEV-139)
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

  # --force: check version before overwriting (DEV-129)
  local old_ver
  old_ver="$(extract_version "$dst")"

  if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
    # Same or newer version — keep user's customizations, no backup needed
    echo -e "  ${YELLOW}⏭${NC}  ${label} ${CYAN}(v${AGTOOSA_VERSION} — keeping your customizations)${NC}"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  # Older or unknown version — backup and replace
  local bak
  bak="$(backup_file "$dst")"
  BAK_FILES+=("$bak")
  cp "$src" "$dst"
  echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(v${old_ver:-unknown} → v${AGTOOSA_VERSION}, backup: $(basename "$bak"))${NC}"
  COPIED=$((COPIED + 1))
}

# ── Cleanup trap (DEV-86) ─────────────────────────────────────
# Keeps ship/ only when user chose manual copy (KEEP_SHIP=true)
KEEP_SHIP=false
_cleanup() {
  if [[ "$KEEP_SHIP" == false ]]; then
    rm -rf "$SHIP_DIR" 2>/dev/null || true
  fi
}
trap _cleanup EXIT

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Flags ────────────────────────────────────────────────────
FORCE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --force)               FORCE=true ;;
    --dry-run)             DRY_RUN=true ;;
    --list-template-files) print_template_files; exit 0 ;;
    --version)             echo "AgToosa v${AGTOOSA_VERSION}"; exit 0 ;;
    --help)                print_usage; exit 0 ;;
    *)
      echo -e "${RED}❌ Error: Unknown option '${arg}'.${NC}"
      echo ""
      print_usage
      exit 1
      ;;
  esac
done

# ── Source guard (allows sourcing for unit tests) ─────────────
# When sourced (e.g., via bats), all functions/variables are available but interactive
# code below is skipped. Direct execution (bash agtoosa.sh) proceeds normally.
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0

# ── Preflight ────────────────────────────────────────────────
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo -e "${RED}❌ Error: template/ directory not found. Run this script from the AgToosa root.${NC}"
  exit 1
fi

# ── Welcome ──────────────────────────────────────────────────
clear 2>/dev/null || true
echo ""
echo -e "${PURPLE}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}${BOLD}║          🤖 AgToosa v${AGTOOSA_VERSION} — Local Generator         ║${NC}"
echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}AgToosa is a spec-driven agentic AI framework that${NC}"
echo -e "${CYAN}understands your codebase and helps you develop with${NC}"
echo -e "${CYAN}a clean folder structure and structured workflow.${NC}"
echo ""
echo -e "${YELLOW}How it works:${NC}"
echo -e "  1. We detect which AI assistant(s) you use"
echo -e "  2. We generate ONLY the necessary config files"
echo -e "  3. We copy them directly to your project"
echo -e "  4. Run ${BOLD}/agtoosa-init${NC} in your AI assistant (one-time)"
echo -e "  5. Then use: ${BOLD}/agtoosa-spec → /agtoosa-build → /agtoosa-review → /agtoosa-ship${NC}"
echo ""
echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}${BOLD}[DRY RUN] No files will be written.${NC}"
  echo ""
fi

# ── Project Path ─────────────────────────────────────────────
echo -e "${BOLD}Where is your project?${NC}"
echo -e "${CYAN}Enter the full path to your project root:${NC}"
echo ""

read -rp "Project path: " PROJECT_PATH

# Expand ~ to home directory
PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

# Validate path
if [[ ! -d "$PROJECT_PATH" ]]; then
  echo -e "${RED}❌ Error: Directory '${PROJECT_PATH}' does not exist.${NC}"
  exit 1
fi

# Normalize path (remove trailing slash)
PROJECT_PATH="${PROJECT_PATH%/}"

# DEV-137: Prevent targeting the AgToosa source directory itself
_rp_project="$(cd "$PROJECT_PATH" && pwd)"
_rp_script="$(cd "$SCRIPT_DIR" && pwd)"
if [[ "$_rp_project" == "$_rp_script" ]]; then
  echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Project found: ${PROJECT_PATH}${NC}"
echo ""

# ── AI Platform Selection ────────────────────────────────────
echo -e "${BOLD}Which AI coding assistant(s) do you use?${NC}"
echo -e "${CYAN}(Enter numbers separated by spaces, e.g., '1 3 5')${NC}"
echo ""
echo "  1) Cursor"
echo "  2) Windsurf"
echo "  3) Claude Code"
echo "  4) Gemini CLI / Jules"
echo "  5) GitHub Copilot"
echo "  6) VS Code (generic)"
echo "  7) OpenCode / Roo / Other"
echo "  8) All of the above"
echo ""

read -rp "Your selection: " SELECTION

# Parse selection
USE_CURSOR=false
USE_WINDSURF=false
USE_CLAUDE=false
USE_GEMINI=false
USE_COPILOT=false
USE_OPENCODE=false

if [[ "$SELECTION" == *"8"* ]]; then
  USE_CURSOR=true
  USE_WINDSURF=true
  USE_CLAUDE=true
  USE_GEMINI=true
  USE_COPILOT=true
  USE_OPENCODE=true
else
  [[ "$SELECTION" == *"1"* ]] && USE_CURSOR=true
  [[ "$SELECTION" == *"2"* ]] && USE_WINDSURF=true
  [[ "$SELECTION" == *"3"* ]] && USE_CLAUDE=true
  [[ "$SELECTION" == *"4"* ]] && USE_GEMINI=true
  [[ "$SELECTION" == *"5"* ]] && USE_COPILOT=true
  [[ "$SELECTION" == *"7"* ]] && USE_OPENCODE=true
  # Option 6 (VS Code generic) uses only Docs/AgToosa_Agent.md (always included)
fi

echo ""

# DEV-135: Warn on invalid selection numbers
if [[ "$SELECTION" != *"8"* ]]; then
  while IFS= read -r token; do
    token="${token//[[:space:]]/}"
    [[ -z "$token" ]] && continue
    if ! [[ "$token" =~ ^[1-7]$ ]]; then
      echo -e "${YELLOW}⚠️  Unknown selection: '${token}'. Valid options are 1–8.${NC}"
    fi
  done < <(tr ' ' '\n' <<< "$SELECTION")
fi

# DEV-136: Warn on empty platform selection (option 6 is intentionally Docs/-only)
SOME_PLATFORM_SELECTED=false
[[ "$USE_CURSOR" == true || "$USE_WINDSURF" == true || "$USE_CLAUDE" == true || \
   "$USE_GEMINI" == true || "$USE_COPILOT" == true || "$USE_OPENCODE" == true ]] && SOME_PLATFORM_SELECTED=true
[[ "$SELECTION" == *"6"* ]] && SOME_PLATFORM_SELECTED=true

if [[ "$SOME_PLATFORM_SELECTED" == false ]]; then
  echo -e "${YELLOW}⚠️  No AI platform selected. Only Docs/ workflow files will be copied.${NC}"
  echo -e "${YELLOW}    Your AI assistant won't have an entry-point config (CLAUDE.md, .cursorrules, etc.).${NC}"
  echo ""
  read -rp "Continue anyway? (y/N): " NO_PLATFORM_CONFIRM
  NO_PLATFORM_CONFIRM="${NO_PLATFORM_CONFIRM:-N}"
  echo ""
  if [[ ! "$NO_PLATFORM_CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Re-run agtoosa.sh and select at least one platform.${NC}"
    echo ""
    exit 0
  fi
fi

# ── Prepare ship/ staging directory ─────────────────────────
if [[ -d "$SHIP_DIR" ]]; then
  rm -rf "$SHIP_DIR"
fi

mkdir -p "$SHIP_DIR/Docs/archived"
mkdir -p "$SHIP_DIR/Docs/Context"

# ── Generate files into ship/ ────────────────────────────────
GENERATED=0

echo -e "${BOLD}Generating files...${NC}"
echo ""

for file in "${DOCS_FILES[@]}"; do
  if [[ -f "${TEMPLATE_DIR}/${file}" ]]; then
    cp "${TEMPLATE_DIR}/${file}" "${SHIP_DIR}/${file}"
    echo -e "  ${GREEN}✅${NC} ${file}"
    GENERATED=$((GENERATED + 1))
  fi
done

# Platform-specific configs — inject version marker (DEV-129)
if [[ "$USE_CURSOR" == true ]]; then
  inject_version "${TEMPLATE_DIR}/.cursorrules" "${SHIP_DIR}/.cursorrules"
  echo -e "  ${GREEN}✅${NC} .cursorrules ${CYAN}(Cursor)${NC}"
  GENERATED=$((GENERATED + 1))
fi

if [[ "$USE_WINDSURF" == true ]]; then
  inject_version "${TEMPLATE_DIR}/.windsurfrules" "${SHIP_DIR}/.windsurfrules"
  echo -e "  ${GREEN}✅${NC} .windsurfrules ${CYAN}(Windsurf)${NC}"
  GENERATED=$((GENERATED + 1))
fi

if [[ "$USE_CLAUDE" == true ]]; then
  inject_version "${TEMPLATE_DIR}/CLAUDE.md" "${SHIP_DIR}/CLAUDE.md"
  cp "${TEMPLATE_DIR}/Docs/AgToosa_Claude.md" "${SHIP_DIR}/Docs/AgToosa_Claude.md"
  echo -e "  ${GREEN}✅${NC} CLAUDE.md + Docs/AgToosa_Claude.md ${CYAN}(Claude Code)${NC}"
  GENERATED=$((GENERATED + 2))
fi

if [[ "$USE_GEMINI" == true ]]; then
  inject_version "${TEMPLATE_DIR}/AGENTS.md" "${SHIP_DIR}/AGENTS.md"
  cp "${TEMPLATE_DIR}/Docs/AgToosa_Gemini.md" "${SHIP_DIR}/Docs/AgToosa_Gemini.md"
  echo -e "  ${GREEN}✅${NC} AGENTS.md + Docs/AgToosa_Gemini.md ${CYAN}(Gemini CLI / Jules)${NC}"
  GENERATED=$((GENERATED + 2))
fi

if [[ "$USE_COPILOT" == true ]]; then
  mkdir -p "${SHIP_DIR}/.github"
  inject_version "${TEMPLATE_DIR}/.github/copilot-instructions.md" "${SHIP_DIR}/.github/copilot-instructions.md"
  echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
  GENERATED=$((GENERATED + 1))
fi

# DEV-138: count OpenCode files individually
if [[ "$USE_OPENCODE" == true ]]; then
  OPENCODE_COUNT=0
  if [[ -f "${TEMPLATE_DIR}/.roorules" ]]; then
    inject_version "${TEMPLATE_DIR}/.roorules" "${SHIP_DIR}/.roorules"
    OPENCODE_COUNT=$((OPENCODE_COUNT + 1))
  fi
  if [[ -f "${TEMPLATE_DIR}/OPENCODE.md" ]]; then
    inject_version "${TEMPLATE_DIR}/OPENCODE.md" "${SHIP_DIR}/OPENCODE.md"
    OPENCODE_COUNT=$((OPENCODE_COUNT + 1))
  fi
  if [[ $OPENCODE_COUNT -gt 0 ]]; then
    echo -e "  ${GREEN}✅${NC} .roorules + OPENCODE.md ${CYAN}(Roo / OpenCode)${NC}"
    GENERATED=$((GENERATED + OPENCODE_COUNT))
  fi
fi

# Context/ template files — stage in ship/ (copy to project is skip-if-exists)
CONTEXT_STAGED=0
for cfile in "${CONTEXT_FILES[@]}"; do
  if [[ -f "${TEMPLATE_DIR}/${cfile}" ]]; then
    cp "${TEMPLATE_DIR}/${cfile}" "${SHIP_DIR}/${cfile}"
    CONTEXT_STAGED=$((CONTEXT_STAGED + 1))
    GENERATED=$((GENERATED + 1))
  fi
done
if [[ $CONTEXT_STAGED -gt 0 ]]; then
  echo -e "  ${GREEN}✅${NC} Docs/Context/ ${CYAN}(${CONTEXT_STAGED} config stubs — fill in during /agtoosa-init)${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}Generated ${GENERATED} files.${NC}"
echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Ready to copy AgToosa files to:${NC}"
echo -e "  ${CYAN}${PROJECT_PATH}${NC}"
echo ""

# DEV-133: count ALL existing files including previously missing ones
EXISTING_FILES=0
if [[ "$FORCE" == false ]]; then
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

  if [[ $EXISTING_FILES -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  ${EXISTING_FILES} file(s) already exist in your project.${NC}"
    echo ""
  fi
fi

# DEV-132: --dry-run with --force awareness
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}[DRY RUN] Would copy the following files to ${PROJECT_PATH}:${NC}"
  echo ""
  while IFS= read -r f; do
    target="${PROJECT_PATH}/${f}"
    if [[ ! -f "$target" ]]; then
      echo -e "  ${GREEN}✅${NC} ${f}  → New file"
    elif [[ "$f" == Docs/Context/* ]]; then
      # Context/ files respect --force (user may have customized them)
      if [[ "$FORCE" == true ]]; then
        old_ver="$(extract_version "$target")"
        echo -e "  ${CYAN}📦${NC} ${f}  → Would backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
      else
        echo -e "  ${YELLOW}⏭${NC}  ${f}  → Would skip (exists, use --force to overwrite)"
      fi
    elif [[ "$f" == Docs/* ]]; then
      # DEV-134: Docs/ always overwrite
      echo -e "  ${GREEN}✅${NC} ${f}  → Would overwrite (workflow file, always updated)"
    elif [[ "$FORCE" == true ]]; then
      old_ver="$(extract_version "$target")"
      if [[ -n "$old_ver" ]] && ! version_lt "$old_ver" "$AGTOOSA_VERSION"; then
        echo -e "  ${YELLOW}⏭${NC}  ${f}  → Would keep (same version, preserving customizations)"
      else
        echo -e "  ${CYAN}📦${NC} ${f}  → Would backup + replace (v${old_ver:-unknown} → v${AGTOOSA_VERSION})"
      fi
    else
      echo -e "  ${YELLOW}⏭${NC}  ${f}  → Would skip (exists, use --force to overwrite)"
    fi
  done < <(find "$SHIP_DIR" -type f | sed "s|${SHIP_DIR}/||" | sort)
  echo ""
  echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply.${NC}"
  echo ""
  exit 0
fi

read -rp "Copy files now? (Y/n): " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  # Create directories in target
  mkdir -p "${PROJECT_PATH}/Docs/archived"
  mkdir -p "${PROJECT_PATH}/Docs/Context"

  COPIED=0
  SKIPPED=0

  # DEV-134: Docs/ workflow files always overwrite — no --force check needed
  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${file}" ]]; then
      cp "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}"
      echo -e "  ${GREEN}✅${NC} ${file}"
      COPIED=$((COPIED + 1))
    fi
  done

  # Platform files — version-aware copy with .bak backup (DEV-128, DEV-129, DEV-130, DEV-139)
  for dotfile in .cursorrules .windsurfrules .roorules; do
    if [[ -f "${SHIP_DIR}/${dotfile}" ]]; then
      copy_platform_file "${SHIP_DIR}/${dotfile}" "${PROJECT_PATH}/${dotfile}" "${dotfile}"
    fi
  done

  for mdfile in CLAUDE.md AGENTS.md OPENCODE.md; do
    if [[ -f "${SHIP_DIR}/${mdfile}" ]]; then
      copy_platform_file "${SHIP_DIR}/${mdfile}" "${PROJECT_PATH}/${mdfile}" "${mdfile}"
    fi
  done

  for pdoc in Docs/AgToosa_Claude.md Docs/AgToosa_Gemini.md; do
    if [[ -f "${SHIP_DIR}/${pdoc}" ]]; then
      copy_platform_file "${SHIP_DIR}/${pdoc}" "${PROJECT_PATH}/${pdoc}" "${pdoc}"
    fi
  done

  if [[ -f "${SHIP_DIR}/.github/copilot-instructions.md" ]]; then
    mkdir -p "${PROJECT_PATH}/.github"
    copy_platform_file "${SHIP_DIR}/.github/copilot-instructions.md" \
      "${PROJECT_PATH}/.github/copilot-instructions.md" \
      ".github/copilot-instructions.md"
  fi

  # Context/ config stubs — skip if already exists (user may have filled them in)
  for cfile in "${CONTEXT_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${cfile}" ]]; then
      copy_platform_file "${SHIP_DIR}/${cfile}" "${PROJECT_PATH}/${cfile}" "${cfile}"
    fi
  done

  # Summary
  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo -e "  ${GREEN}Copied:  ${COPIED} files${NC}"
  [[ $SKIPPED -gt 0 ]] && echo -e "  ${YELLOW}Skipped: ${SKIPPED} files (use --force to overwrite)${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} installed to ${PROJECT_PATH}${NC}"

  # DEV-131: Warn about .bak files not being gitignored
  if [[ ${#BAK_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Backup files created — add this to your .gitignore to avoid committing them:${NC}"
    echo -e "    ${BOLD}*.bak.*${NC}"
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

else
  # DEV-83: User chose manual copy — keep ship/ intact for them to use
  KEEP_SHIP=true
  echo ""
  echo -e "${YELLOW}Files are staged in ${BOLD}ship/${NC}${YELLOW} — copy them manually:${NC}"
  echo -e "  ${BOLD}cp -r ship/* ${PROJECT_PATH}/${NC}"
  echo -e "  ${BOLD}find ship/ -maxdepth 1 -name '.*' -exec cp -r {} ${PROJECT_PATH}/ \\;${NC}  ${CYAN}(for dotfiles)${NC}"
  echo -e "${CYAN}(Run 'rm -rf ship/' when done.)${NC}"
  echo ""
fi

# ── Cleanup staging (handled by trap for errors; manual path keeps ship/) ────
