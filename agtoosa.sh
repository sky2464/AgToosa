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

AGTOOSA_VERSION="3.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"
SHIP_DIR="${SCRIPT_DIR}/ship"

# ── Early preflight (no colors yet) ──────────────────────────
# Check template/ first — the bats preflight test copies only agtoosa.sh to /tmp
# and relies on "template/" appearing in the error output.
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "❌ Error: template/ directory not found. Run this script from the AgToosa root." >&2
  exit 1
fi
if [[ ! -d "${SCRIPT_DIR}/lib" ]]; then
  echo "❌ Error: lib/ directory not found. Run this script from the AgToosa root." >&2
  exit 1
fi

# ── Source modular libraries ──────────────────────────────────
for _lib in config version copy generate dryrun install update registry; do
  # shellcheck source=/dev/null
  source "${SCRIPT_DIR}/lib/${_lib}.sh"
done
unset _lib

# ── Cleanup trap ──────────────────────────────────────────────
KEEP_SHIP=false
_cleanup() {
  if [[ "$KEEP_SHIP" == false ]]; then
    rm -rf "$SHIP_DIR" 2>/dev/null || true
  fi
}
trap _cleanup EXIT

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Flags ─────────────────────────────────────────────────────
FORCE=false
DRY_RUN=false
UPDATE=false
UPDATE_PATH=""
REGISTRY=false
REGISTRY_COMMAND=""
REGISTRY_ARG=""
for arg in "$@"; do
  case "$arg" in
    --registry)            REGISTRY=true ;;
    --update)              UPDATE=true ;;
    --force)               FORCE=true ;;
    --dry-run)             DRY_RUN=true ;;
    --list-template-files) print_template_files; exit 0 ;;
    --version)             echo "AgToosa v${AGTOOSA_VERSION}"; exit 0 ;;
    --help)                print_usage; exit 0 ;;
    *)
      if [[ "$REGISTRY" == true && -z "$REGISTRY_COMMAND" && "$arg" != --* ]]; then
        REGISTRY_COMMAND="$arg"
      elif [[ "$REGISTRY" == true && -n "$REGISTRY_COMMAND" && -z "$REGISTRY_ARG" && "$arg" != --* ]]; then
        REGISTRY_ARG="$arg"
      elif [[ "$UPDATE" == true && -z "$UPDATE_PATH" && "$arg" != --* ]]; then
        UPDATE_PATH="$arg"
      else
        echo -e "${RED}❌ Error: Unknown option '${arg}'.${NC}"
        echo ""
        print_usage
        exit 1
      fi
      ;;
  esac
done

# ── Source guard (allows sourcing for unit tests) ─────────────
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0

# ── Registry mode ──────────────────────────────────────────────
if [[ "$REGISTRY" == true ]]; then
  case "$REGISTRY_COMMAND" in
    list)   registry_list; exit $? ;;
    search) registry_search "$REGISTRY_ARG"; exit $? ;;
    info)   registry_info "$REGISTRY_ARG"; exit $? ;;
    install) registry_install "$REGISTRY_ARG"; exit $? ;;
    publish) registry_publish; exit $? ;;
    *)
      echo -e "${RED}❌ Error: Unknown registry command '${REGISTRY_COMMAND}'.${NC}" >&2
      echo "Available commands: list, search, info, install, publish" >&2
      exit 1
      ;;
  esac
fi

# ── Update mode ───────────────────────────────────────────────
if [[ "$UPDATE" == true ]]; then
  if [[ -z "$UPDATE_PATH" ]]; then
    echo -e "${BOLD}Project path to update:${NC}"
    read -rp "Project path: " UPDATE_PATH
    UPDATE_PATH="${UPDATE_PATH/#\~/$HOME}"
    UPDATE_PATH="${UPDATE_PATH%/}"
  fi
  PROJECT_PATH="$UPDATE_PATH"

  if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ Error: Directory '${PROJECT_PATH}' does not exist.${NC}"
    exit 1
  fi

  _rp_project="$(cd "$PROJECT_PATH" && pwd)"
  _rp_script="$(cd "$SCRIPT_DIR" && pwd)"
  if [[ "$_rp_project" == "$_rp_script" ]]; then
    echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
    exit 1
  fi

  if [[ ! -d "${PROJECT_PATH}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory found in '${PROJECT_PATH}'.${NC}"
    echo -e "${YELLOW}Run the full install first: bash agtoosa.sh${NC}"
    exit 1
  fi

  if [[ "$DRY_RUN" == true ]]; then
    detect_installed_platforms
    _dnames=()
    [[ "$USE_CURSOR"   == true ]] && _dnames+=("cursor")
    [[ "$USE_WINDSURF" == true ]] && _dnames+=("windsurf")
    [[ "$USE_CLAUDE"   == true ]] && _dnames+=("claude")
    [[ "$USE_GEMINI"   == true ]] && _dnames+=("gemini")
    [[ "$USE_COPILOT"  == true ]] && _dnames+=("copilot")
    [[ "$USE_OPENCODE" == true ]] && _dnames+=("opencode")
    echo -e "${YELLOW}[DRY RUN] Would update AgToosa in '${PROJECT_PATH}'${NC}"
    echo -e "  Would overwrite: all Docs/AgToosa_*.md (except Master-Plan.md and AgToosa_Changelog.md)"
    echo -e "  Would merge platform entry-points: ${_dnames[*]:-none detected}"
    echo -e "  Would preserve: Docs/Context/, Docs/Master-Plan.md, Docs/AgToosa_Changelog.md"
    echo ""
    echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply.${NC}"
    exit 0
  fi

  OLD_VERSION="$(read_installed_version "$PROJECT_PATH")"
  echo ""
  echo -e "${PURPLE}${BOLD}Updating AgToosa v${OLD_VERSION} → v${AGTOOSA_VERSION}${NC}"
  echo -e "${PURPLE}${BOLD}Project: ${PROJECT_PATH}${NC}"
  echo ""

  COPIED=0; SKIPPED=0
  run_update "$OLD_VERSION"
  exit 0
fi

# ── Verify git is available ────────────────────────────────────
if ! command -v git &>/dev/null; then
  echo -e "${RED}❌ Error: git not found.${NC}" >&2
  echo "" >&2
  echo "AgToosa uses git to initialize and track projects." >&2
  echo "Please install git:" >&2
  echo "  macOS: brew install git" >&2
  echo "  Linux: sudo apt-get install -y git (Ubuntu/Debian)" >&2
  echo "         sudo dnf install -y git (Fedora/RHEL)" >&2
  echo "" >&2
  exit 1
fi

# ── Welcome ───────────────────────────────────────────────────
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
[[ "$DRY_RUN" == true ]] && { echo -e "${YELLOW}${BOLD}[DRY RUN] No files will be written.${NC}"; echo ""; }

# ── Project path ──────────────────────────────────────────────
echo -e "${BOLD}Where is your project?${NC}"
echo -e "${CYAN}Enter the full path to your project root:${NC}"
echo ""
read -rp "Project path: " PROJECT_PATH
PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
PROJECT_PATH="${PROJECT_PATH%/}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo -e "${RED}❌ Error: Directory '${PROJECT_PATH}' does not exist.${NC}"
  exit 1
fi

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

# ── Platform selection ────────────────────────────────────────
echo -e "${BOLD}Which AI coding assistant(s) do you use?${NC}"
echo -e "${CYAN}(Enter numbers separated by spaces, e.g., '1 3 5')${NC}"
echo ""
echo "  1) Cursor"
echo "  2) Windsurf"
echo "  3) Claude Code"
echo "  4) Gemini CLI / Jules"
echo "  5) GitHub Copilot"
echo "  6) VS Code (generic)"
echo "  7) OpenCode / Other"
echo "  8) All of the above"
echo ""
read -rp "Your selection: " SELECTION

USE_CURSOR=false; USE_WINDSURF=false; USE_CLAUDE=false
USE_GEMINI=false; USE_COPILOT=false; USE_OPENCODE=false; USE_VSCODE=false

if [[ "$SELECTION" == *"8"* ]]; then
  USE_CURSOR=true; USE_WINDSURF=true; USE_CLAUDE=true
  USE_GEMINI=true; USE_COPILOT=true; USE_OPENCODE=true; USE_VSCODE=true
else
  [[ "$SELECTION" == *"1"* ]] && USE_CURSOR=true
  [[ "$SELECTION" == *"2"* ]] && USE_WINDSURF=true
  [[ "$SELECTION" == *"3"* ]] && USE_CLAUDE=true
  [[ "$SELECTION" == *"4"* ]] && USE_GEMINI=true
  [[ "$SELECTION" == *"5"* ]] && USE_COPILOT=true
  [[ "$SELECTION" == *"6"* ]] && USE_VSCODE=true
  [[ "$SELECTION" == *"7"* ]] && USE_OPENCODE=true
fi

echo ""

# DEV-135: Warn on invalid selection tokens
if [[ "$SELECTION" != *"8"* ]]; then
  while IFS= read -r token; do
    token="${token//[[:space:]]/}"
    [[ -z "$token" ]] && continue
    if ! [[ "$token" =~ ^[1-7]$ ]]; then
      echo -e "${YELLOW}⚠️  Unknown selection: '${token}'. Valid options are 1–8.${NC}"
    fi
  done < <(tr ' ' '\n' <<< "$SELECTION")
fi

# DEV-136: Warn if no platform selected
SOME_PLATFORM_SELECTED=false
[[ "$USE_CURSOR" == true || "$USE_WINDSURF" == true || "$USE_CLAUDE" == true || \
   "$USE_GEMINI" == true || "$USE_COPILOT" == true || "$USE_OPENCODE" == true || \
   "$USE_VSCODE" == true ]] && SOME_PLATFORM_SELECTED=true

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

# ── Stage files into ship/ ────────────────────────────────────
[[ -d "$SHIP_DIR" ]] && rm -rf "$SHIP_DIR"
mkdir -p "$SHIP_DIR/Docs/archived" "$SHIP_DIR/Docs/Context" \
         "$SHIP_DIR/.claude/commands" "$SHIP_DIR/.claude/skills" \
           "$SHIP_DIR/.cursor/rules" \
           "$SHIP_DIR/.gemini/commands" \
           "$SHIP_DIR/.github/prompts" "$SHIP_DIR/.github/agents" \
           "$SHIP_DIR/.windsurf/rules"
echo ""
GENERATED=0
stage_files

echo ""
echo -e "${GREEN}${BOLD}Generated ${GENERATED} files.${NC}"
echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Ready to copy AgToosa files to:${NC}"
echo -e "  ${CYAN}${PROJECT_PATH}${NC}"
echo ""

# ── Existing file count + hint ────────────────────────────────
EXISTING_FILES=0
count_existing_files
if [[ $EXISTING_FILES -gt 0 ]]; then
  echo -e "${CYAN}ℹ️  ${EXISTING_FILES} file(s) already exist — platform configs will be merged, Context/ files preserved.${NC}"
  echo ""
fi

# ── Dry-run preview or confirm + install ─────────────────────
if [[ "$DRY_RUN" == true ]]; then
  print_dryrun_preview
  exit 0
fi

read -rp "Copy files now? (Y/n): " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  COPIED=0
  SKIPPED=0
  install_files
else
  manual_copy_instructions
fi
