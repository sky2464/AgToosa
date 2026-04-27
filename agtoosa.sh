#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# AgToosa — Local Interactive Generator
# Detects your AI assistant(s), generates the necessary files,
# and copies them directly to your project.
#
# Usage:
#   bash agtoosa.sh [--force] [--version] [--help]
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

print_usage() {
  echo "AgToosa Generator v${AGTOOSA_VERSION}"
  echo ""
  echo "Usage: bash agtoosa.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --force                Overwrite existing files in target project"
  echo "  --dry-run              Show what would be copied without making changes"
  echo "  --list-template-files  Print every template file path and exit"
  echo "  --version              Print version and exit"
  echo "  --help                 Show this help message"
}

print_template_files() {
  printf '%s\n' "${DOCS_FILES[@]}" "${OPTIONAL_TEMPLATE_FILES[@]}"
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
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --list-template-files) print_template_files; exit 0 ;;
    --version) echo "AgToosa v${AGTOOSA_VERSION}"; exit 0 ;;
    --help)
      print_usage
      exit 0
      ;;
    *)
      echo -e "${RED}❌ Error: Unknown option '${arg}'.${NC}"
      echo ""
      print_usage
      exit 1
      ;;
  esac
done

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

# Platform-specific configs
if [[ "$USE_CURSOR" == true ]]; then
  cp "${TEMPLATE_DIR}/.cursorrules" "${SHIP_DIR}/.cursorrules"
  echo -e "  ${GREEN}✅${NC} .cursorrules ${CYAN}(Cursor)${NC}"
  GENERATED=$((GENERATED + 1))
fi

if [[ "$USE_WINDSURF" == true ]]; then
  cp "${TEMPLATE_DIR}/.windsurfrules" "${SHIP_DIR}/.windsurfrules"
  echo -e "  ${GREEN}✅${NC} .windsurfrules ${CYAN}(Windsurf)${NC}"
  GENERATED=$((GENERATED + 1))
fi

if [[ "$USE_CLAUDE" == true ]]; then
  cp "${TEMPLATE_DIR}/CLAUDE.md" "${SHIP_DIR}/CLAUDE.md"
  cp "${TEMPLATE_DIR}/Docs/AgToosa_Claude.md" "${SHIP_DIR}/Docs/AgToosa_Claude.md"
  echo -e "  ${GREEN}✅${NC} CLAUDE.md + Docs/AgToosa_Claude.md ${CYAN}(Claude Code)${NC}"
  GENERATED=$((GENERATED + 2))
fi

if [[ "$USE_GEMINI" == true ]]; then
  cp "${TEMPLATE_DIR}/AGENTS.md" "${SHIP_DIR}/AGENTS.md"
  cp "${TEMPLATE_DIR}/Docs/AgToosa_Gemini.md" "${SHIP_DIR}/Docs/AgToosa_Gemini.md"
  echo -e "  ${GREEN}✅${NC} AGENTS.md + Docs/AgToosa_Gemini.md ${CYAN}(Gemini CLI / Jules)${NC}"
  GENERATED=$((GENERATED + 2))
fi

if [[ "$USE_COPILOT" == true ]]; then
  mkdir -p "${SHIP_DIR}/.github"
  cp "${TEMPLATE_DIR}/.github/copilot-instructions.md" "${SHIP_DIR}/.github/copilot-instructions.md"
  echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
  GENERATED=$((GENERATED + 1))
fi

if [[ "$USE_OPENCODE" == true ]]; then
  [[ -f "${TEMPLATE_DIR}/.roorules" ]] && cp "${TEMPLATE_DIR}/.roorules" "${SHIP_DIR}/.roorules"
  [[ -f "${TEMPLATE_DIR}/OPENCODE.md" ]] && cp "${TEMPLATE_DIR}/OPENCODE.md" "${SHIP_DIR}/OPENCODE.md"
  echo -e "  ${GREEN}✅${NC} .roorules + OPENCODE.md ${CYAN}(Roo / OpenCode)${NC}"
  GENERATED=$((GENERATED + 2))
fi

echo ""
echo -e "${GREEN}${BOLD}Generated ${GENERATED} files.${NC}"
echo ""

# ── Copy to project ─────────────────────────────────────────
echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Ready to copy AgToosa files to:${NC}"
echo -e "  ${CYAN}${PROJECT_PATH}${NC}"
echo ""

EXISTING_FILES=0
if [[ "$FORCE" == false ]]; then
  # Check for existing files
  for file in "${DOCS_FILES[@]}"; do
    [[ -f "${PROJECT_PATH}/${file}" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  done
  [[ "$USE_CURSOR" == true && -f "${PROJECT_PATH}/.cursorrules" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_WINDSURF" == true && -f "${PROJECT_PATH}/.windsurfrules" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_CLAUDE" == true && -f "${PROJECT_PATH}/CLAUDE.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_GEMINI" == true && -f "${PROJECT_PATH}/AGENTS.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))
  [[ "$USE_COPILOT" == true && -f "${PROJECT_PATH}/.github/copilot-instructions.md" ]] && EXISTING_FILES=$((EXISTING_FILES + 1))

  if [[ $EXISTING_FILES -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  ${EXISTING_FILES} file(s) already exist in your project.${NC}"
    echo ""
  fi
fi

if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}[DRY RUN] Would copy the following files to ${PROJECT_PATH}:${NC}"
  echo ""
  find "$SHIP_DIR" -type f | sed "s|${SHIP_DIR}/||" | sort | while IFS= read -r f; do
    echo -e "  ${CYAN}${f}${NC}"
  done
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

  # Copy all files from ship/ to project
  COPIED=0
  SKIPPED=0

  for file in "${DOCS_FILES[@]}"; do
    if [[ -f "${SHIP_DIR}/${file}" ]]; then
      if [[ -f "${PROJECT_PATH}/${file}" && "$FORCE" == false ]]; then
        echo -e "  ${YELLOW}⏭${NC}  Skipping ${file} (exists, use --force to overwrite)"
        SKIPPED=$((SKIPPED + 1))
      else
        cp "${SHIP_DIR}/${file}" "${PROJECT_PATH}/${file}"
        echo -e "  ${GREEN}✅${NC} ${file}"
        COPIED=$((COPIED + 1))
      fi
    fi
  done

  # Platform files — copy everything staged in ship/ that isn't in DOCS_FILES
  for dotfile in .cursorrules .windsurfrules .roorules; do
    if [[ -f "${SHIP_DIR}/${dotfile}" ]]; then
      if [[ -f "${PROJECT_PATH}/${dotfile}" && "$FORCE" == false ]]; then
        echo -e "  ${YELLOW}⏭${NC}  Skipping ${dotfile} (exists)"
        SKIPPED=$((SKIPPED + 1))
      else
        cp "${SHIP_DIR}/${dotfile}" "${PROJECT_PATH}/${dotfile}"
        echo -e "  ${GREEN}✅${NC} ${dotfile}"
        COPIED=$((COPIED + 1))
      fi
    fi
  done

  for mdfile in CLAUDE.md AGENTS.md OPENCODE.md; do
    if [[ -f "${SHIP_DIR}/${mdfile}" ]]; then
      if [[ -f "${PROJECT_PATH}/${mdfile}" && "$FORCE" == false ]]; then
        echo -e "  ${YELLOW}⏭${NC}  Skipping ${mdfile} (exists)"
        SKIPPED=$((SKIPPED + 1))
      else
        cp "${SHIP_DIR}/${mdfile}" "${PROJECT_PATH}/${mdfile}"
        echo -e "  ${GREEN}✅${NC} ${mdfile}"
        COPIED=$((COPIED + 1))
      fi
    fi
  done

  # Platform Docs
  for pdoc in Docs/AgToosa_Claude.md Docs/AgToosa_Gemini.md; do
    if [[ -f "${SHIP_DIR}/${pdoc}" ]]; then
      if [[ -f "${PROJECT_PATH}/${pdoc}" && "$FORCE" == false ]]; then
        echo -e "  ${YELLOW}⏭${NC}  Skipping ${pdoc} (exists)"
        SKIPPED=$((SKIPPED + 1))
      else
        cp "${SHIP_DIR}/${pdoc}" "${PROJECT_PATH}/${pdoc}"
        echo -e "  ${GREEN}✅${NC} ${pdoc}"
        COPIED=$((COPIED + 1))
      fi
    fi
  done

  if [[ -f "${SHIP_DIR}/.github/copilot-instructions.md" ]]; then
    mkdir -p "${PROJECT_PATH}/.github"
    if [[ -f "${PROJECT_PATH}/.github/copilot-instructions.md" && "$FORCE" == false ]]; then
      echo -e "  ${YELLOW}⏭${NC}  Skipping .github/copilot-instructions.md (exists)"
      SKIPPED=$((SKIPPED + 1))
    else
      cp "${SHIP_DIR}/.github/copilot-instructions.md" "${PROJECT_PATH}/.github/copilot-instructions.md"
      echo -e "  ${GREEN}✅${NC} .github/copilot-instructions.md"
      COPIED=$((COPIED + 1))
    fi
  fi

  # Summary
  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo -e "  ${GREEN}Copied:  ${COPIED} files${NC}"
  [[ $SKIPPED -gt 0 ]] && echo -e "  ${YELLOW}Skipped: ${SKIPPED} files (use --force to overwrite)${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} installed to ${PROJECT_PATH}${NC}"
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
  echo -e "  ${BOLD}cp -r ship/.* ${PROJECT_PATH}/${NC}  ${CYAN}(for dotfiles)${NC}"
  echo -e "${CYAN}(Run 'rm -rf ship/' when done.)${NC}"
  echo ""
fi

# ── Cleanup staging (handled by trap for errors; manual path keeps ship/) ────
