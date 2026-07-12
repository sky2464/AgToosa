#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${AGTOOSA_LAUNCH_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
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
  AGTOOSA_LAUNCH_ROOT=/path/to/repo   Override repository root for isolated fixtures.
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

normalize_proof_repo_url() {
  local url="$1"
  url="${url%/}"
  url="${url%.git}"
  printf '%s' "$url"
}

canonical_version="$(grep -m1 '^AGTOOSA_VERSION=' "$ROOT_DIR/agtoosa.sh" | sed -E 's/^AGTOOSA_VERSION="?([^"]+)"?/\1/')"
EXPECTED_TAG="v${canonical_version}"
PROOF_REPO_CANONICAL="https://github.com/sky2464/agtoosa-first-15-proof"

FIRST15_DOC="docs/examples/first-15-minutes.md"
PUBLIC_PROOF_DOC="docs/examples/public-launch-proof.md"

check_scoped_release_pin() {
  local file="$1"
  local label="$2"
  local pattern="$3"
  local path="$ROOT_DIR/$file"
  [[ -f "$path" ]] || {
    record_fail "$file missing for scoped release-pin check"
    return
  }
  local matches=()
  while IFS= read -r line; do
    matches+=("$line")
  done < <(grep -nEe "$pattern" "$path" || true)
  if [[ "${#matches[@]}" -eq 0 ]]; then
    record_fail "$file: no scoped release pin found (expected $EXPECTED_TAG)"
    return
  fi
  local entry line_no observed
  for entry in "${matches[@]}"; do
    line_no="${entry%%:*}"
    observed="$(printf '%s' "$entry" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
    if [[ "$observed" != "$EXPECTED_TAG" ]]; then
      record_fail "$file:$line_no release pin '$observed' does not match expected '$EXPECTED_TAG'"
    fi
  done
}

check_relative_proof_links() {
  local file="$1"
  local path="$ROOT_DIR/$file"
  [[ -f "$path" ]] || {
    record_fail "$file missing for relative proof-link check"
    return
  }
  local base_dir
  base_dir="$(cd "$(dirname "$path")" && pwd)"
  local link target
  while IFS= read -r link; do
    [[ "$link" =~ ^https?:// ]] && continue
    [[ "$link" =~ ^# ]] && continue
    target="$base_dir/$link"
    if [[ ! -e "$target" ]]; then
      record_fail "$file: relative proof link '$link' resolves to missing target '$target'"
    fi
  done < <(grep -oE '\]\([^)]+\)' "$path" | sed -E 's/^\]\((.*)\)$/\1/' || true)
}

check_proof_repo_url_consistency() {
  local file url normalized seen=()
  local -a sources=("README.md" "$FIRST15_DOC" "$PUBLIC_PROOF_DOC" "scripts/check-launch-readiness.sh")
  local canonical_norm
  canonical_norm="$(normalize_proof_repo_url "$PROOF_REPO_CANONICAL")"
  local mismatches=()
  for file in "${sources[@]}"; do
    local path="$ROOT_DIR/$file"
    [[ -f "$path" ]] || {
      record_fail "$file missing for first-15 proof repository URL check"
      continue
    }
    local found=0
    while IFS= read -r url; do
      [[ -n "$url" ]] || continue
      found=1
      url="$(printf '%s' "$url" | sed 's/`*$//')"
      normalized="$(normalize_proof_repo_url "$url")"
      if [[ "$normalized" != "$canonical_norm" ]]; then
        mismatches+=("$file observed '$normalized' expected '$canonical_norm'")
      fi
    done < <(grep -oE 'https://github\.com/sky2464/agtoosa-first-15-proof[^ )`"]*' "$path" | sed 's/[`]$//' || true)
    if [[ "$found" -eq 0 ]]; then
      record_fail "$file missing first-15 proof repository URL (expected '$PROOF_REPO_CANONICAL')"
    fi
  done
  if [[ "${#mismatches[@]}" -gt 0 ]]; then
    local mismatch
    for mismatch in "${mismatches[@]}"; do
      record_fail "$mismatch"
    done
  fi
}

README_PRIMARY_CTA_MARKER='**Primary: 15-minute proof journey**'
README_SECONDARY_SECTION_MARKER='### Alternative install paths'
FIRST15_VERIFY_HEADING='## 5. Verify (success condition)'
FIRST15_WALKTHROUGH_LINK='docs/examples/first-15-minutes.md'

readme_above_fold() {
  local path="$1"
  awk '/^---$/{exit} {print}' "$path"
}

check_readme_primary_proof_cta() {
  local path="$ROOT_DIR/README.md"
  [[ -f "$path" ]] || {
    record_fail "README.md missing for primary proof CTA check"
    return
  }
  local fold count
  fold="$(readme_above_fold "$path")"
  count="$(printf '%s' "$fold" | grep -cF -- "$README_PRIMARY_CTA_MARKER" || true)"
  if [[ "$count" -ne 1 ]]; then
    record_fail "README.md: expected exactly one primary proof CTA marker '$README_PRIMARY_CTA_MARKER' above the fold (observed count $count)"
    return
  fi
  if [[ "$fold" != *"$FIRST15_WALKTHROUGH_LINK"* ]]; then
    record_fail "README.md: primary proof CTA missing walkthrough link (observed above fold without '$FIRST15_WALKTHROUGH_LINK', expected link present)"
  fi
  if [[ "$fold" != *"$PROOF_REPO_CANONICAL"* ]]; then
    record_fail "README.md: primary proof CTA missing canonical proof repository URL (expected '$PROOF_REPO_CANONICAL')"
  fi
  local competing
  for competing in "**Public launch: pinned release**" "**Private collaborator path:"; do
    if [[ "$fold" == *"$competing"* ]]; then
      record_fail "README.md: competing primary marker '$competing' must not appear above the fold (observed above fold, expected secondary section only)"
    fi
  done
}

check_readme_secondary_install_paths() {
  local path="$ROOT_DIR/README.md"
  [[ -f "$path" ]] || {
    record_fail "README.md missing for secondary install path check"
    return
  }
  if ! grep -qF -- "$README_SECONDARY_SECTION_MARKER" "$path"; then
    record_fail "README.md missing secondary install section marker (expected '$README_SECONDARY_SECTION_MARKER')"
    return
  fi
  local section_line section_tail
  section_line="$(grep -nF -- "$README_SECONDARY_SECTION_MARKER" "$path" | head -n1 | cut -d: -f1)"
  section_tail="$(tail -n +"$section_line" "$path")"
  if [[ "$section_tail" != *"brew install"* ]]; then
    record_fail "README.md: secondary install section missing Homebrew alternative (expected 'brew install' after '$README_SECONDARY_SECTION_MARKER')"
  fi
  if [[ "$section_tail" != *"npx agtoosa"* ]]; then
    record_fail "README.md: secondary install section missing npm alternative (expected 'npx agtoosa' after '$README_SECONDARY_SECTION_MARKER')"
  fi
  if [[ "$section_tail" != *"git clone https://github.com/sky2464/AgToosa.git"* ]]; then
    record_fail "README.md: secondary install section missing clone alternative (expected git clone command after '$README_SECONDARY_SECTION_MARKER')"
  fi
}

check_first15_verify_success_step() {
  local path="$ROOT_DIR/$FIRST15_DOC"
  [[ -f "$path" ]] || {
    record_fail "$FIRST15_DOC missing for verify success step check"
    return
  }
  if ! grep -qF -- "$FIRST15_VERIFY_HEADING" "$path"; then
    record_fail "$FIRST15_DOC missing verify heading (expected '$FIRST15_VERIFY_HEADING')"
    return
  fi
  if ! grep -qF 'bash agtoosa.sh --verify .' "$path"; then
    record_fail "$FIRST15_DOC missing verifier command (expected 'bash agtoosa.sh --verify .')"
  fi
  if ! grep -qi 'exit code 0' "$path"; then
    record_fail "$FIRST15_DOC missing success condition (expected 'exit code 0')"
  fi
}

check_proof_journey_consistency() {
  local journey_failures_before="$FAILURES"
  printf 'proof-journey maintenance: validating README CTA, verify step, and canonical proof URL\n'

  check_readme_primary_proof_cta
  check_readme_secondary_install_paths
  check_first15_verify_success_step
  check_proof_repo_url_consistency

  if [[ "$FAILURES" -eq "$journey_failures_before" ]]; then
    pass "README primary proof CTA is present"
    pass "first-15 verify success step is present"
    pass "proof-journey surfaces are consistent"
    pass "first-15 proof repository URL is canonical"
  fi

  printf 'proof-journey maintenance complete\n'
}

run_first15_maintenance_gate() {
  printf 'first-15 maintenance gate: validating scoped pins, proof links, and proof repository URL\n'

  check_scoped_release_pin "$FIRST15_DOC" "first-15 walkthrough install command" '--ref v[0-9]+\.[0-9]+\.[0-9]+'
  check_scoped_release_pin "$PUBLIC_PROOF_DOC" "public launch proof release tag" 'releases/tag/v[0-9]+\.[0-9]+\.[0-9]+'
  check_scoped_release_pin "$PUBLIC_PROOF_DOC" "public launch proof pinned bootstrap" '/AgToosa/v[0-9]+\.[0-9]+\.[0-9]+/bootstrap\.sh'
  check_scoped_release_pin "$PUBLIC_PROOF_DOC" "public launch proof bootstrap artifact" 'agtoosa-bootstrap-v[0-9]+\.[0-9]+\.[0-9]+\.sh'
  if ! grep -qEe '/AgToosa/\$\{EXPECTED_TAG\}/bootstrap\.sh' "$ROOT_DIR/scripts/check-launch-readiness.sh"; then
    record_fail "scripts/check-launch-readiness.sh: pinned bootstrap URL must use \${EXPECTED_TAG} derived from AGTOOSA_VERSION"
  fi

  check_relative_proof_links "$FIRST15_DOC"
  check_relative_proof_links "$PUBLIC_PROOF_DOC"
  check_proof_journey_consistency

  if [[ "$FAILURES" -eq 0 ]]; then
    pass "scoped release pins match $EXPECTED_TAG"
    pass "relative proof links resolve"
  fi

  printf 'first-15 maintenance gate complete\n'
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

run_first15_maintenance_gate

if [[ "$FAILURES" -gt 0 ]]; then
  printf 'Launch readiness failed: %s first-15 maintenance finding(s).\n' "$FAILURES" >&2
  exit 1
fi

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
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/${EXPECTED_TAG}/bootstrap.sh" "raw bootstrap.sh on pinned release"
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
