#!/usr/bin/env bash
# AgToosa GitHub Issues sync — upsert Issues from publish manifest (DEV-139 / DEV-147)
# Usage: scripts/agtoosa-issues-sync.sh [--dry-run] [--path DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT}/lib/github-issues-sync.sh"

PROJECT="$ROOT"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --path)
      PROJECT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

github_issues_sync_require_gh || exit 1

MANIFEST="$(mktemp)"
trap 'rm -f "$MANIFEST"' EXIT

github_issues_sync_write_manifest "$ROOT" "$PROJECT" "$MANIFEST" "$DRY_RUN"

if [[ "$DRY_RUN" == true ]]; then
  github_issues_sync_dry_run "$MANIFEST"
  exit 0
fi

github_issues_sync_apply "$MANIFEST"
