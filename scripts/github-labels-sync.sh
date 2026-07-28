#!/usr/bin/env bash
# DEV-142 — Apply TRIAGE labels from docs/github-surface-manifest.json via gh.
set -euo pipefail

ROOT_DIR="${AGTOOSA_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="${AGTOOSA_SURFACE_MANIFEST:-$ROOT_DIR/docs/github-surface-manifest.json}"
REPO="${GITHUB_REPOSITORY:-sky2464/AgToosa}"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  scripts/github-labels-sync.sh [--repo owner/name] [--dry-run]

Creates or skips labels declared in docs/github-surface-manifest.json.
Requires gh with issues:write permission.

Examples:
  scripts/github-labels-sync.sh --dry-run
  scripts/github-labels-sync.sh --repo sky2464/AgToosa
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
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

command -v gh >/dev/null 2>&1 || { echo "Error: gh required" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq required" >&2; exit 2; }
[[ -f "$MANIFEST" ]] || { echo "Error: manifest not found: $MANIFEST" >&2; exit 2; }

# Color map aligned with .github/workflows/labels.yml
label_color() {
  case "$1" in
    bug) echo d73a49 ;;
    enhancement) echo a2eeef ;;
    documentation) echo 0075ca ;;
    chore) echo bfdadc ;;
    question) echo cc317c ;;
    testing) echo 28a745 ;;
    priority-critical) echo ff0000 ;;
    priority-high) echo ff6600 ;;
    priority-medium) echo ffaa00 ;;
    priority-low) echo dddddd ;;
    status-backlog|status-needs-triage) echo 9e9e9e ;;
    status-in-progress) echo 0075ca ;;
    status-blocked) echo ff6666 ;;
    status-review) echo fbca04 ;;
    status-confirmed) echo 0e8a16 ;;
    status-wont-fix) echo ffffff ;;
    good-first-issue) echo 7057ff ;;
    help-wanted) echo 33aa3c ;;
    security) echo e74c3c ;;
    duplicate|invalid|stale) echo cfd3d7 ;;
    wontfix) echo ffffff ;;
    needs-repro) echo d4c5f9 ;;
    area-*) echo 1d76db ;;
    source:agtoosa-sync) echo 1d76db ;;
    source:community) echo 5319e7 ;;
    *) echo ededed ;;
  esac
}

label_description() {
  case "$1" in
    bug) echo "Something is broken" ;;
    enhancement) echo "New feature request" ;;
    documentation) echo "Docs improvements" ;;
    chore) echo "Maintenance and tooling" ;;
    question) echo "Questions and discussions" ;;
    testing) echo "Test suite improvements" ;;
    priority-critical) echo "Critical — blocks users" ;;
    priority-high) echo "High priority" ;;
    priority-medium) echo "Medium priority" ;;
    priority-low) echo "Low priority" ;;
    status-backlog) echo "Backlog" ;;
    status-needs-triage) echo "Awaiting triage" ;;
    status-confirmed) echo "Confirmed and accepted" ;;
    status-in-progress) echo "Currently being worked on" ;;
    status-blocked) echo "Blocked by something" ;;
    status-review) echo "Under review" ;;
    status-wont-fix) echo "Will not be fixed" ;;
    good-first-issue) echo "Good for newcomers" ;;
    help-wanted) echo "Extra attention needed" ;;
    security) echo "Security and vulnerabilities" ;;
    duplicate) echo "Duplicate issue" ;;
    invalid) echo "Invalid issue" ;;
    stale) echo "Inactive for 30 days" ;;
    wontfix) echo "Will not be fixed" ;;
    needs-repro) echo "Needs reproduction steps" ;;
    area-generator) echo "Generator / agtoosa.sh" ;;
    area-template) echo "Template pack" ;;
    area-ci) echo "CI and workflows" ;;
    area-docs) echo "Documentation" ;;
    area-security) echo "Security surfaces" ;;
    source:agtoosa-sync) echo "Mirrored from Master-Plan" ;;
    source:community) echo "Filed by a community contributor" ;;
    *) echo "" ;;
  esac
}

while IFS= read -r label; do
  [[ -n "$label" ]] || continue
  color="$(label_color "$label")"
  desc="$(label_description "$label")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run: would upsert label %s (#%s) %s\n' "$label" "$color" "$desc"
    continue
  fi
  if gh api "repos/$REPO/labels/$label" >/dev/null 2>&1; then
    printf 'skip: %s (exists)\n' "$label"
  else
    gh api -X POST "repos/$REPO/labels" \
      -f "name=$label" \
      -f "color=$color" \
      -f "description=$desc" >/dev/null
    printf 'created: %s\n' "$label"
  fi
done < <(jq -r '.labels[]?' "$MANIFEST")

printf 'Label sync complete for %s\n' "$REPO"
