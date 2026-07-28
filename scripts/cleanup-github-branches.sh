#!/usr/bin/env bash
# Maintainer: clean stale Cursor agent remote branches (cursor/*).
# Default is dry-run — never mutates GitHub unless --apply is passed.
#
# Usage:
#   bash scripts/cleanup-github-branches.sh [--dry-run|--apply] [--close-prs] [--prefix cursor/]
#
# Eligibility: branches matching PREFIX that are not main/master and have no open PR
# (or only closed/merged PRs). With --close-prs, open PRs on matching branches are closed first.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="dry-run"
CLOSE_PRS=false
PREFIX="cursor/"

usage() {
  cat <<'EOF'
Usage: bash scripts/cleanup-github-branches.sh [--dry-run|--apply] [--close-prs] [--prefix PREFIX]

  --dry-run     List eligible remote branches without mutating (default)
  --apply       Delete eligible remote branches (and optionally close open PRs)
  --close-prs   With --apply: close open PRs on matching branches before delete
  --prefix      Branch name prefix to consider (default: cursor/)

Never deletes: main, master, or any tag.
Requires: gh CLI authenticated to the repo remote.
EOF
}

# Return 0 if branch name is protected and must never be deleted.
brh_is_denylisted() {
  local name="$1"
  case "$name" in
    main|master) return 0 ;;
    *) return 1 ;;
  esac
}

# Return 0 if branch is a candidate by name (prefix match, not denylisted).
brh_is_prefix_candidate() {
  local name="$1"
  local prefix="$2"
  brh_is_denylisted "$name" && return 1
  [[ "$name" == "${prefix}"* ]]
}

brh_repo_slug() {
  gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null
}

brh_list_remote_branches() {
  local slug="$1"
  gh api "repos/${slug}/branches" --paginate -q '.[].name'
}

# Return 0 if branch has at least one open PR.
brh_has_open_pr() {
  local branch="$1"
  local count
  count="$(gh pr list --state open --head "$branch" --json number -q 'length' 2>/dev/null || echo 0)"
  [[ "${count:-0}" -gt 0 ]]
}

brh_close_open_prs() {
  local branch="$1"
  local nums n
  nums="$(gh pr list --state open --head "$branch" --json number -q '.[].number' 2>/dev/null || true)"
  for n in $nums; do
    [[ -n "$n" ]] || continue
    gh pr close "$n" --comment "Closing stale Cursor agent PR during repository branch hygiene (DEV-133). Re-open from main if still needed."
  done
}

brh_delete_remote_branch() {
  local branch="$1"
  git push origin --delete "$branch"
}

# Collect eligible branch names into ELIGIBLE array (global).
brh_collect_eligible() {
  local slug="$1"
  local prefix="$2"
  local close_open="$3"
  local name
  ELIGIBLE=()
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    brh_is_prefix_candidate "$name" "$prefix" || continue
    if brh_has_open_pr "$name"; then
      if [[ "$close_open" == true ]]; then
        ELIGIBLE+=("$name")
      fi
      continue
    fi
    ELIGIBLE+=("$name")
  done < <(brh_list_remote_branches "$slug")
}

brh_main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) MODE="dry-run"; shift ;;
      --apply) MODE="apply"; shift ;;
      --close-prs) CLOSE_PRS=true; shift ;;
      --prefix)
        PREFIX="${2:-}"
        [[ -n "$PREFIX" ]] || { echo "Error: --prefix requires a value" >&2; exit 2; }
        shift 2
        ;;
      -h|--help) usage; exit 0 ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done

  if ! command -v gh >/dev/null 2>&1; then
    echo "Error: gh CLI is required." >&2
    exit 2
  fi

  local slug
  slug="$(brh_repo_slug)"
  if [[ -z "$slug" ]]; then
    echo "Error: could not resolve repo via gh repo view." >&2
    exit 2
  fi

  echo "Repo: $slug"
  echo "Mode: $MODE · prefix: ${PREFIX} · close-prs: ${CLOSE_PRS}"
  echo ""

  local close_for_collect=false
  if [[ "$MODE" == "apply" && "$CLOSE_PRS" == true ]]; then
    close_for_collect=true
  fi

  brh_collect_eligible "$slug" "$PREFIX" "$close_for_collect"

  if [[ ${#ELIGIBLE[@]} -eq 0 ]]; then
    echo "No eligible branches under prefix '${PREFIX}'."
    exit 0
  fi

  echo "Eligible (${#ELIGIBLE[@]}):"
  local b
  for b in "${ELIGIBLE[@]}"; do
    echo "  - $b"
  done
  echo ""

  if [[ "$MODE" != "apply" ]]; then
    echo "Dry-run only — no mutations. Re-run with --apply to delete."
    exit 0
  fi

  for b in "${ELIGIBLE[@]}"; do
    if brh_is_denylisted "$b"; then
      echo "Refusing denylisted branch: $b" >&2
      exit 1
    fi
    if [[ "$CLOSE_PRS" == true ]] && brh_has_open_pr "$b"; then
      echo "Closing open PRs for $b ..."
      brh_close_open_prs "$b"
    fi
    echo "Deleting origin/$b ..."
    brh_delete_remote_branch "$b"
  done

  echo "Done."
}

# Allow bats to source helpers without running main.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cd "$ROOT"
  brh_main "$@"
fi
