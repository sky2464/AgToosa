#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${AGTOOSA_LAUNCH_MODE:-private}"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-launch-readiness.sh [--mode private|public]

Modes:
  private  Validate local launch docs and skip anonymous public URL checks.
  public   Validate local launch docs and require advertised public URLs to respond.

Examples:
  scripts/check-launch-readiness.sh --mode private
  scripts/check-launch-readiness.sh --mode public

Environment:
  AGTOOSA_LAUNCH_MODE=private|public
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -lt 2 ]] && { echo "Error: --mode requires private or public" >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$MODE" in
  private|public) ;;
  *)
    echo "Error: unsupported mode '$MODE' (expected private or public)" >&2
    exit 2
    ;;
esac

pass() {
  printf 'ok - %s\n' "$1"
}

FAILURES=0

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

record_fail() {
  printf 'not ok - %s\n' "$1" >&2
  FAILURES=$((FAILURES + 1))
}

require_file() {
  local path="$1"
  [[ -f "$ROOT_DIR/$path" ]] || fail "missing required file: $path"
  pass "found $path"
}

require_text() {
  local path="$1"
  local pattern="$2"
  local label="$3"
  grep -qE "$pattern" "$ROOT_DIR/$path" || fail "$label"
  pass "$label"
}

check_url() {
  local url="$1"
  local label="$2"
  local code
  code="$(curl -L -sS -o /dev/null -w '%{http_code}' --max-time 20 "$url" || true)"
  case "$code" in
    200|204|301|302|307|308)
      pass "$label ($code)"
      ;;
    *)
      record_fail "$label returned HTTP $code: $url"
      ;;
  esac
}

printf 'AgToosa launch readiness mode: %s\n' "$MODE"

require_file "README.md"
require_file ".github/SUPPORT.md"
require_file ".github/DISCUSSIONS.md"
require_file ".github/ISSUE_TEMPLATE/bug.yml"
require_file ".github/ISSUE_TEMPLATE/feature.yml"
require_file "bootstrap.sh"
require_file "bootstrap.ps1"

require_text "README.md" "Public launch status" "README states public launch status"
require_text "README.md" "Public launch: pinned release" "README labels pinned release public launch target"
require_text "README.md" "development-only main branch" "README labels main branch command as development-only"
require_text ".github/SUPPORT.md" "public support channel" "support doc explains public support channel"
require_text ".github/ISSUE_TEMPLATE/bug.yml" "Install command" "bug template asks for install command"
require_text ".github/ISSUE_TEMPLATE/bug.yml" "Target project context" "bug template asks for target project context"
require_text ".github/ISSUE_TEMPLATE/feature.yml" "Affected surface" "feature template asks for affected surface"

if [[ "$MODE" == "private" ]]; then
  echo "Skipping anonymous public URL checks in private mode."
  exit 0
fi

check_url "https://github.com/sky2464/AgToosa" "GitHub repository"
check_url "https://github.com/sky2464/AgToosa/releases" "GitHub releases"
check_url "https://github.com/sky2464/AgToosa/actions/workflows/ci.yml/badge.svg" "CI badge"
check_url "https://github.com/sky2464/AgToosa/actions/workflows/security-scan.yml/badge.svg" "security scan badge"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh" "raw bootstrap.sh on main"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/v5.3.4/bootstrap.sh" "raw bootstrap.sh on pinned release"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1" "raw bootstrap.ps1 on main"
check_url "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json" "registry index"
check_url "https://github.com/sky2464/AgToosa/issues" "GitHub issues"
check_url "https://github.com/sky2464/AgToosa/discussions" "GitHub discussions"
check_url "https://github.com/sky2464/AgToosa/security/policy" "SECURITY.md public policy"
check_url "https://github.com/sky2464/homebrew-agtoosa" "Homebrew tap"
check_url "https://github.com/sky2464/agtoosa-first-15-proof" "first-15-minute proof repo"

if [[ "$FAILURES" -gt 0 ]]; then
  printf 'Launch readiness failed: %s public surface(s) unavailable.\n' "$FAILURES" >&2
  exit 1
fi
