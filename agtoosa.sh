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

AGTOOSA_VERSION="5.3.28"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/template"
SHIP_DIR="${AGTOOSA_SHIP_DIR:-${SCRIPT_DIR}/ship}"
PACK_QUEUE_DIR="${AGTOOSA_PACK_QUEUE_DIR:-${SCRIPT_DIR}/.agtoosa/pack-queue}"

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
for _lib in config version copy apply state lock generate plan dryrun install update migrate provenance registry catalog tracker maintain reinstall cleanup; do
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

_print_self_target_guidance() {
  echo -e "${YELLOW}   --update is for downstream installed projects only.${NC}"
  echo -e "${YELLOW}   In the AgToosa generator repo, follow docs/agtoosa-maintainer.md.${NC}"
  echo -e "${YELLOW}   Do not create Docs/ or Docs/.agtoosa-version here.${NC}"
}

# ── Flags ─────────────────────────────────────────────────────
FORCE=false
DRY_RUN=false
UPDATE=false
UPDATE_PATH=""
REGISTRY=false
REGISTRY_COMMAND=""
REGISTRY_ARG=""
CATALOG=false
CATALOG_COMMAND=""
CATALOG_ARG=""
CATALOG_PATH=""
TRACKER=false
TRACKER_COMMAND=""
TRACKER_PATH=""
TRACKER_INPUT=""
TRACKER_OUTPUT=""
_PATH_ARG=""
ALLOW_UNVERIFIED=false
ASSUME_YES=false
CLI_PROJECT_PATH=""
CLI_PLATFORMS=""
VERIFY=false
VERIFY_PATH=""
DOCTOR=false
DOCTOR_PATH=""
UNINSTALL=false
UNINSTALL_PATH=""
REINSTALL=false
REINSTALL_PATH=""
CLEAN=false
CLEANUP=false
CLEANUP_PATH=""
CLEANUP_ONLY=""
OUTPUT_FORMAT=""
VERIFY_STRICT=false
STATUS_LINE=false
STATUS_LINE_PATH=""
ROUTE_HINT=false
PLAN_JSON_MODE=false
ACCEPT_BREAKING=false
while [[ $# -gt 0 ]]; do
  arg="$1"
  case "$arg" in
    --registry)            REGISTRY=true ;;
    --catalog)             CATALOG=true ;;
    --tracker)             TRACKER=true ;;
    --update)              UPDATE=true ;;
    --verify)              VERIFY=true ;;
    --doctor)              DOCTOR=true ;;
    --status-line)         STATUS_LINE=true ;;
    --route-hint)          ROUTE_HINT=true ;;
    --uninstall)           UNINSTALL=true ;;
    --cleanup)             CLEANUP=true ;;
    --only)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --only requires a category (backups).${NC}"; exit 1
      fi
      case "$2" in
        backups) CLEANUP_ONLY="backups" ;;
        *)
          echo -e "${RED}❌ Error: invalid --only '${2}' (expected backups).${NC}"; exit 2 ;;
      esac
      shift ;;
    --reinstall)           REINSTALL=true ;;
    --clean)               CLEAN=true ;;
    --force)               FORCE=true ;;
    --dry-run)             DRY_RUN=true ;;
    --allow-unverified)    ALLOW_UNVERIFIED=true ;;
    --yes|-y)              ASSUME_YES=true ;;
    --accept-breaking)     ACCEPT_BREAKING=true ;;
    # DEV-091 AC-007: --json is required on the migration path (alias of --format json).
    --json)                OUTPUT_FORMAT="json" ;;
    --strict)              VERIFY_STRICT=true ;;
    --format)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --format requires text|json.${NC}"; exit 1
      fi
      OUTPUT_FORMAT="$2"; shift
      case "$OUTPUT_FORMAT" in
        text|json) ;;
        *)
          echo -e "${RED}❌ Error: invalid --format '${OUTPUT_FORMAT}' (expected text|json).${NC}"
          exit 2 ;;
      esac ;;
    --path)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --path requires a directory argument.${NC}"; exit 1
      fi
      _PATH_ARG="$2"; shift ;;
    --input)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --input requires a file argument.${NC}"; exit 1
      fi
      TRACKER_INPUT="$2"; shift ;;
    --output)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --output requires a file argument.${NC}"; exit 1
      fi
      TRACKER_OUTPUT="$2"; shift ;;
    --platforms)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}❌ Error: --platforms requires a comma-separated list (e.g. cursor,claude).${NC}"; exit 1
      fi
      CLI_PLATFORMS="$2"; shift ;;
    --list-template-files) print_template_files; exit 0 ;;
    --version)             echo "AgToosa v${AGTOOSA_VERSION}"; exit 0 ;;
    --help|-h)             print_usage; exit 0 ;;
    *)
      if [[ "$REGISTRY" == true && -z "$REGISTRY_COMMAND" && "$arg" != --* ]]; then
        REGISTRY_COMMAND="$arg"
      elif [[ "$REGISTRY" == true && -n "$REGISTRY_COMMAND" && -z "$REGISTRY_ARG" && "$arg" != --* ]]; then
        REGISTRY_ARG="$arg"
      elif [[ "$CATALOG" == true && -z "$CATALOG_COMMAND" && "$arg" != --* ]]; then
        CATALOG_COMMAND="$arg"
      elif [[ "$CATALOG" == true && -n "$CATALOG_COMMAND" && -z "$CATALOG_ARG" && "$arg" != --* ]]; then
        CATALOG_ARG="$arg"
      elif [[ "$TRACKER" == true && -z "$TRACKER_COMMAND" && "$arg" != --* ]]; then
        TRACKER_COMMAND="$arg"
      elif [[ "$UPDATE" == true && -z "$UPDATE_PATH" && "$arg" != --* ]]; then
        UPDATE_PATH="$arg"
      elif [[ "$VERIFY" == true && -z "$VERIFY_PATH" && "$arg" != --* ]]; then
        VERIFY_PATH="$arg"
      elif [[ "$DOCTOR" == true && -z "$DOCTOR_PATH" && "$arg" != --* ]]; then
        DOCTOR_PATH="$arg"
      elif [[ "$STATUS_LINE" == true && -z "$STATUS_LINE_PATH" && "$arg" != --* ]]; then
        STATUS_LINE_PATH="$arg"
      elif [[ "$UNINSTALL" == true && -z "$UNINSTALL_PATH" && "$arg" != --* ]]; then
        UNINSTALL_PATH="$arg"
      elif [[ "$CLEANUP" == true && -z "$CLEANUP_PATH" && "$arg" != --* ]]; then
        CLEANUP_PATH="$arg"
      elif [[ "$REINSTALL" == true && -z "$REINSTALL_PATH" && "$arg" != --* ]]; then
        REINSTALL_PATH="$arg"
      else
        echo -e "${RED}❌ Error: Unknown option '${arg}'.${NC}"
        echo ""
        print_usage
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -n "$_PATH_ARG" ]]; then
  if [[ "$TRACKER" == true ]]; then
    TRACKER_PATH="$_PATH_ARG"
  elif [[ "$REINSTALL" == true && -z "$REINSTALL_PATH" ]]; then
    REINSTALL_PATH="$_PATH_ARG"
    CLI_PROJECT_PATH="$_PATH_ARG"
  elif [[ "$CLEANUP" == true && -z "$CLEANUP_PATH" ]]; then
    CLEANUP_PATH="$_PATH_ARG"
    CLI_PROJECT_PATH="$_PATH_ARG"
  else
    CLI_PROJECT_PATH="$_PATH_ARG"
  fi
fi
unset _PATH_ARG

# --reinstall and --clean are a paired Option C surface (ADR-004).
if [[ "$REINSTALL" == true && "$CLEAN" != true ]]; then
  echo -e "${RED}❌ Error: --reinstall requires --clean (ADR-004 Option C).${NC}" >&2
  echo -e "${YELLOW}Default safe upgrade remains: bash agtoosa.sh --update <project>${NC}" >&2
  exit 1
fi
if [[ "$CLEAN" == true && "$REINSTALL" != true ]]; then
  echo -e "${RED}❌ Error: --clean requires --reinstall.${NC}" >&2
  exit 1
fi
if [[ -n "${CLEANUP_ONLY:-}" && "$CLEANUP" != true ]]; then
  echo -e "${RED}❌ Error: --only requires --cleanup.${NC}" >&2
  exit 1
fi

if [[ "$DRY_RUN" == true && "$OUTPUT_FORMAT" == "json" ]]; then
  PLAN_JSON_MODE=true
fi

# --json / --format json require a consumer mode (install dry-run, update, verify, …).
if [[ "$OUTPUT_FORMAT" == "json" \
      && "$UPDATE" != true && "$DRY_RUN" != true && "$VERIFY" != true \
      && "$DOCTOR" != true && "$CLEANUP" != true && "$STATUS_LINE" != true \
      && "$CATALOG" != true && "$REGISTRY" != true && "$TRACKER" != true ]]; then
  echo -e "${RED}❌ Error: --json / --format json requires a command (--update, --dry-run, --verify, --doctor, --catalog, …).${NC}" >&2
  exit 1
fi

# ── Source guard (allows sourcing for unit tests) ─────────────
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0

# ── Verify mode (deterministic lifecycle gate) ────────────────
if [[ "$VERIFY" == true ]]; then
  if [[ "$VERIFY_STRICT" == true && -n "$OUTPUT_FORMAT" ]]; then
    run_verify "${VERIFY_PATH:-$PWD}" --format "$OUTPUT_FORMAT" --strict
  elif [[ "$VERIFY_STRICT" == true ]]; then
    run_verify "${VERIFY_PATH:-$PWD}" --strict
  elif [[ -n "$OUTPUT_FORMAT" ]]; then
    run_verify "${VERIFY_PATH:-$PWD}" --format "$OUTPUT_FORMAT"
  else
    run_verify "${VERIFY_PATH:-$PWD}"
  fi
  exit $?
fi

# ── Doctor mode (install diagnostics) ─────────────────────────
if [[ "$DOCTOR" == true ]]; then
  if [[ -n "$OUTPUT_FORMAT" ]]; then
    run_doctor "${DOCTOR_PATH:-$PWD}" --format "$OUTPUT_FORMAT"
  else
    run_doctor "${DOCTOR_PATH:-$PWD}"
  fi
  exit $?
fi

if [[ "$STATUS_LINE" == true ]]; then
  STATUS_LINE_FORMAT="$OUTPUT_FORMAT" run_status_line "${STATUS_LINE_PATH:-$PWD}"
  exit $?
fi

# ── Uninstall mode ─────────────────────────────────────────────
if [[ "$UNINSTALL" == true ]]; then
  run_uninstall "${UNINSTALL_PATH:-}"
  exit $?
fi

# ── Cleanup mode (backups, orphan docs, deselected platforms) ──
if [[ "$CLEANUP" == true ]]; then
  if [[ "$DRY_RUN" == true || "$OUTPUT_FORMAT" == "json" ]]; then
    run_cleanup_plan "${CLEANUP_PATH:-$PWD}" "${OUTPUT_FORMAT:-text}"
  else
    run_cleanup "${CLEANUP_PATH:-$PWD}"
  fi
  exit $?
fi

# ── Reinstall --clean mode (ADR-004 Option C) ─────────────────
if [[ "$REINSTALL" == true && "$CLEAN" == true ]]; then
  run_reinstall_clean "${REINSTALL_PATH:-${CLI_PROJECT_PATH:-}}"
  exit $?
fi

# ── Registry mode ──────────────────────────────────────────────
if [[ "$REGISTRY" == true ]]; then
  case "$REGISTRY_COMMAND" in
    list)   registry_list; exit $? ;;
    search) registry_search "$REGISTRY_ARG"; exit $? ;;
    info)   registry_info "$REGISTRY_ARG"; exit $? ;;
    install) registry_install "$REGISTRY_ARG"; exit $? ;;
    publish) registry_publish "$REGISTRY_ARG"; exit $? ;;
    *)
      echo -e "${RED}❌ Error: Unknown registry command '${REGISTRY_COMMAND}'.${NC}" >&2
      echo "Available commands: list, search, info, install, publish" >&2
      exit 1
      ;;
  esac
fi

# ── Catalog mode (read-only discovery + non-executing plans) ───
# OUTPUT_FORMAT (text|json) is honored by catalog_info / catalog_plan (DEV-100).
if [[ "$CATALOG" == true ]]; then
  case "$CATALOG_COMMAND" in
    list)
      if [[ -n "$CATALOG_ARG" ]]; then
        AGTOOSA_CATALOG_PATH="$CATALOG_ARG" catalog_list
      else
        catalog_list
      fi
      exit $? ;;
    search)
      if [[ -z "$CATALOG_ARG" ]]; then
        echo -e "${RED}❌ Error: --catalog search requires a keyword.${NC}" >&2
        exit 1
      fi
      catalog_search "$CATALOG_ARG"
      exit $? ;;
    info)
      if [[ -z "$CATALOG_ARG" ]]; then
        echo -e "${RED}❌ Error: --catalog info requires an entry id.${NC}" >&2
        exit 1
      fi
      catalog_info "$CATALOG_ARG"
      exit $? ;;
    validate)
      if [[ -z "$CATALOG_ARG" ]]; then
        echo -e "${RED}❌ Error: --catalog validate requires a catalog file path.${NC}" >&2
        exit 1
      fi
      catalog_validate "$CATALOG_ARG"
      exit $? ;;
    plan)
      if [[ -z "$CATALOG_ARG" ]]; then
        echo -e "${RED}❌ Error: --catalog plan requires a preset id.${NC}" >&2
        exit 1
      fi
      catalog_plan "$CATALOG_ARG"
      exit $? ;;
    *)
      echo -e "${RED}❌ Error: Unknown catalog command '${CATALOG_COMMAND}'.${NC}" >&2
      echo "Available commands: list, search, info, validate, plan" >&2
      exit 1
      ;;
  esac
fi

# ── Tracker mode (local export + proposal-only import) ─────────
if [[ "$TRACKER" == true ]]; then
  _tracker_project="${TRACKER_PATH:-$PWD}"
  case "$TRACKER_COMMAND" in
    export)
      if [[ -z "$TRACKER_OUTPUT" ]]; then
        echo -e "${RED}❌ Error: --tracker export requires --output <file>.${NC}" >&2
        exit 1
      fi
      tracker_export "$_tracker_project" "$TRACKER_OUTPUT"
      exit $? ;;
    propose)
      if [[ -z "$TRACKER_INPUT" || -z "$TRACKER_OUTPUT" ]]; then
        echo -e "${RED}❌ Error: --tracker propose requires --input <file> and --output <file>.${NC}" >&2
        exit 1
      fi
      tracker_propose "$_tracker_project" "$TRACKER_INPUT" "$TRACKER_OUTPUT"
      exit $? ;;
    *)
      echo -e "${RED}❌ Error: Unknown tracker command '${TRACKER_COMMAND}'.${NC}" >&2
      echo "Available commands: export, propose" >&2
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
    _print_self_target_guidance
    exit 1
  fi

  if [[ ! -d "${PROJECT_PATH}/Docs" ]]; then
    echo -e "${RED}❌ Error: No Docs/ directory found in '${PROJECT_PATH}'.${NC}"
    echo -e "${YELLOW}Run the full install first: bash agtoosa.sh${NC}"
    exit 1
  fi

  OLD_VERSION="$(read_installed_version "$PROJECT_PATH")"

  # DEV-091: MAJOR migration wizard (plan / gate / rollback)
  if declare -F is_major_migration >/dev/null 2>&1 \
     && is_major_migration "$OLD_VERSION" "$AGTOOSA_VERSION"; then
    COPIED=0; SKIPPED=0
    run_major_migration "$PROJECT_PATH" "$OLD_VERSION"
    exit $?
  fi

  if [[ "$DRY_RUN" == true ]]; then
    run_update_dryrun "${OUTPUT_FORMAT:-text}"
    exit 0
  fi

  echo ""
  echo -e "${PURPLE}${BOLD}Updating AgToosa v${OLD_VERSION} → v${AGTOOSA_VERSION}${NC}"
  echo -e "${PURPLE}${BOLD}Project: ${PROJECT_PATH}${NC}"
  echo ""

  COPIED=0; SKIPPED=0
  SMART_APPLY_USE_UPDATE=true
  OLD_INSTALLED_VERSION="$OLD_VERSION"
  SMART_UPGRADE_MODE=true
  smart_apply
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
if [[ "$PLAN_JSON_MODE" != true ]]; then
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
  echo -e "${CYAN}Re-run on an existing project to upgrade — no --force needed.${NC}"
  echo ""
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  [[ "$DRY_RUN" == true ]] && { echo -e "${YELLOW}${BOLD}[DRY RUN] No files will be written.${NC}"; echo ""; }
fi

# ── Project path ──────────────────────────────────────────────
if [[ -n "$CLI_PROJECT_PATH" ]]; then
  PROJECT_PATH="$CLI_PROJECT_PATH"
else
  echo -e "${BOLD}Where is your project?${NC}"
  echo -e "${CYAN}Enter the full path to your project root:${NC}"
  echo ""
  read -rp "Project path: " PROJECT_PATH
fi
PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
PROJECT_PATH="${PROJECT_PATH%/}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo -e "${RED}❌ Error: Directory '${PROJECT_PATH}' does not exist.${NC}"
  exit 1
fi

# Prevent targeting the AgToosa source directory itself
_rp_project="$(cd "$PROJECT_PATH" && pwd)"
_rp_script="$(cd "$SCRIPT_DIR" && pwd)"
if [[ "$_rp_project" == "$_rp_script" ]]; then
  echo -e "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
  _print_self_target_guidance
  exit 1
fi

if [[ "$PLAN_JSON_MODE" != true ]]; then
  echo ""
  echo -e "${GREEN}✅ Project found: ${PROJECT_PATH}${NC}"
  echo ""
fi

# ── Detect existing install (smart upgrade mode) ─────────────
SMART_UPGRADE_MODE=false
OLD_INSTALLED_VERSION=""
if detect_existing_agtoosa "$PROJECT_PATH"; then
  SMART_UPGRADE_MODE=true
  APPLY_QUIET=true
  OLD_INSTALLED_VERSION="$(read_installed_version "$PROJECT_PATH")"
  if [[ "$PLAN_JSON_MODE" != true ]]; then
    echo -e "${PURPLE}${BOLD}Upgrading AgToosa v${OLD_INSTALLED_VERSION} → v${AGTOOSA_VERSION}${NC}"
    echo ""
  fi
else
  if [[ "$PLAN_JSON_MODE" != true ]]; then
    echo -e "${YELLOW}How it works:${NC}"
    echo -e "  1. We detect which AI assistant(s) you use"
    echo -e "  2. We generate ONLY the necessary config files"
    echo -e "  3. We copy them directly to your project"
    echo -e "  4. Run ${BOLD}/agtoosa-init${NC} in your AI assistant (one-time)"
    echo -e "  5. Then use: ${BOLD}/agtoosa-spec → /agtoosa-build → /agtoosa-review → /agtoosa-ship${NC}"
    echo ""
  fi
fi

# ── Platform selection ────────────────────────────────────────
if [[ "$SMART_UPGRADE_MODE" == true && -z "$CLI_PLATFORMS" ]]; then
  detect_installed_platforms
  if [[ "$PLAN_JSON_MODE" != true ]]; then
    print_platform_legend
    if [[ "$ASSUME_YES" != true ]] && ! all_platforms_installed; then
      echo -e "${CYAN}Add platforms? (Enter to keep, or enter numbers e.g. 2 6)${NC}"
      echo ""
      read -rp "Add platforms: " ADD_PLATFORM_SELECTION
      ADD_PLATFORM_SELECTION="${ADD_PLATFORM_SELECTION//[[:space:]]/}"
      if [[ -n "$ADD_PLATFORM_SELECTION" ]]; then
        union_platform_selection "$ADD_PLATFORM_SELECTION"
        echo ""
        echo -e "${GREEN}Platforms:${NC} $(platform_flags_to_names)"
        echo ""
      fi
    fi
  fi
elif [[ -n "$CLI_PLATFORMS" ]]; then
  # Non-interactive: map platform names (or numbers) to selection digits.
  SELECTION=""
  while IFS= read -r token; do
    token="${token//[[:space:]]/}"
    [[ -z "$token" ]] && continue
    case "$(tr '[:upper:]' '[:lower:]' <<< "$token")" in
      1|cursor)            SELECTION+=" 1" ;;
      2|windsurf)          SELECTION+=" 2" ;;
      3|claude|claude-code) SELECTION+=" 3" ;;
      4|gemini|jules)      SELECTION+=" 4" ;;
      5|copilot|github-copilot) SELECTION+=" 5" ;;
      6|vscode)            SELECTION+=" 6" ;;
      7|codex|opencode|other) SELECTION+=" 7" ;;
      8|all)               SELECTION+=" 8" ;;
      *)
        echo -e "${RED}❌ Error: Unknown platform '${token}' in --platforms.${NC}"
        echo "Valid: cursor, windsurf, claude, gemini, copilot, vscode, codex, all"
        exit 1
        ;;
    esac
  done < <(tr ',' '\n' <<< "$CLI_PLATFORMS")
  SELECTION="${SELECTION# }"
  apply_platform_selection "$SELECTION"
  if [[ "$SMART_UPGRADE_MODE" == true ]]; then
    detect_installed_platforms
    union_platform_selection "$SELECTION"
  fi
  [[ "$PLAN_JSON_MODE" != true ]] && echo -e "${BOLD}Platforms (from --platforms):${NC} ${CLI_PLATFORMS}"
else
  echo -e "${BOLD}Which AI coding assistant(s) do you use?${NC}"
  echo -e "${CYAN}(Enter numbers separated by spaces, e.g., '1 3 5')${NC}"
  echo ""
  echo "  1) Cursor"
  echo "  2) Windsurf"
  echo "  3) Claude Code"
  echo "  4) Gemini CLI / Jules"
  echo "  5) GitHub Copilot"
  echo "  6) VS Code (generic)"
  echo "  7) Codex / OpenCode / Other"
  echo "  8) All of the above"
  echo ""
  read -rp "Your selection: " SELECTION
  apply_platform_selection "$SELECTION"
fi

# Warn on invalid platform selection tokens (fresh install menu path only)
if [[ -z "$CLI_PLATFORMS" && "$SMART_UPGRADE_MODE" != true ]]; then
  while IFS= read -r token; do
    token="${token//[[:space:]]/}"
    [[ -z "$token" ]] && continue
    if ! [[ "$token" =~ ^[1-7]$ ]]; then
      echo -e "${YELLOW}⚠️  Unknown selection: '${token}'. Valid options are 1–8.${NC}"
    fi
  done < <(tr ' ' '\n' <<< "$SELECTION")
fi

echo ""
SOME_PLATFORM_SELECTED=false
[[ "$USE_CURSOR" == true || "$USE_WINDSURF" == true || "$USE_CLAUDE" == true || \
   "$USE_GEMINI" == true || "$USE_COPILOT" == true || "$USE_OPENCODE" == true || \
   "$USE_VSCODE" == true ]] && SOME_PLATFORM_SELECTED=true

if [[ "$SOME_PLATFORM_SELECTED" == false ]]; then
  echo -e "${YELLOW}⚠️  No AI platform selected. Only Docs/ workflow files will be copied.${NC}"
  echo -e "${YELLOW}    Your AI assistant won't have an entry-point config (CLAUDE.md, .cursorrules, etc.).${NC}"
  echo ""
  if [[ "$ASSUME_YES" == true ]]; then
    NO_PLATFORM_CONFIRM="Y"
  else
    read -rp "Continue anyway? (y/N): " NO_PLATFORM_CONFIRM
    NO_PLATFORM_CONFIRM="${NO_PLATFORM_CONFIRM:-N}"
  fi
  echo ""
  if [[ ! "$NO_PLATFORM_CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Re-run agtoosa.sh and select at least one platform.${NC}"
    echo ""
    exit 0
  fi
fi

# ── Stage files into ship/ ────────────────────────────────────
_salvage_ship_packs_to_queue
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
if [[ "$PLAN_JSON_MODE" == true ]] || [[ "$SMART_UPGRADE_MODE" == true ]]; then
  stage_files >/dev/null
else
  stage_files
fi

if [[ "$PLAN_JSON_MODE" != true ]]; then
  echo ""
  if [[ "$SMART_UPGRADE_MODE" == true ]]; then
    echo -e "${GREEN}${BOLD}Prepared ${GENERATED} files for upgrade.${NC}"
  else
    echo -e "${GREEN}${BOLD}Generated ${GENERATED} files.${NC}"
  fi
  echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
  echo ""
  if [[ "$SMART_UPGRADE_MODE" == true ]]; then
    echo -e "${BOLD}Ready to apply AgToosa v${AGTOOSA_VERSION} to:${NC}"
  else
    echo -e "${BOLD}Ready to copy AgToosa files to:${NC}"
  fi
  echo -e "  ${CYAN}${PROJECT_PATH}${NC}"
  echo ""
fi

# ── Existing file count + hint ────────────────────────────────
EXISTING_FILES=0
count_existing_files
if [[ "$PLAN_JSON_MODE" != true && $EXISTING_FILES -gt 0 && "$SMART_UPGRADE_MODE" != true ]]; then
  echo -e "${CYAN}ℹ️  ${EXISTING_FILES} file(s) already exist — platform configs will be merged, your project files preserved.${NC}"
  echo ""
fi

# ── Dry-run preview or confirm + install ─────────────────────
if [[ "$DRY_RUN" == true ]]; then
  compute_agtoosa_plan "$PROJECT_PATH" "install"
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    emit_plan_json
  else
    emit_plan_human
  fi
  exit 0
fi

if [[ "$ASSUME_YES" == true ]]; then
  CONFIRM="Y"
else
  if [[ "$SMART_UPGRADE_MODE" == true ]]; then
    read -rp "Apply upgrade now? (Y/n): " CONFIRM
  else
    read -rp "Copy files now? (Y/n): " CONFIRM
  fi
  CONFIRM="${CONFIRM:-Y}"
fi

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  SMART_APPLY_USE_UPDATE=false
  smart_apply
else
  manual_copy_instructions
fi
