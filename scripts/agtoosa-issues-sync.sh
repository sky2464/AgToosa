#!/usr/bin/env bash
# AgToosa GitHub Issues sync — upsert Issues from publish manifest (DEV-139)
# Usage: scripts/agtoosa-issues-sync.sh [--dry-run] [--path DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI required for agtoosa-issues-sync." >&2
  exit 1
fi

MANIFEST="$(mktemp)"
trap 'rm -f "$MANIFEST"' EXIT

if [[ "$DRY_RUN" == true ]]; then
  bash "$ROOT/agtoosa.sh" --tracker publish --path "$PROJECT" --output "$MANIFEST"
else
  bash "$ROOT/agtoosa.sh" --tracker publish --path "$PROJECT" --output "$MANIFEST" --readme "$PROJECT/README.md"
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry-run manifest ($(jq '.issues | length' "$MANIFEST") issues):"
  jq -r '.issues[] | "\(.state)\t\(.upsert_key)\t\(.title)"' "$MANIFEST"
  exit 0
fi

MILESTONE_TITLE=$(jq -r '.milestone // empty' "$MANIFEST")
MILESTONE_NUMBER=""
if [[ -n "$MILESTONE_TITLE" && "$MILESTONE_TITLE" != "null" ]]; then
  MILESTONE_NUMBER=$(gh api "repos/:owner/:repo/milestones" --jq ".[] | select(.title==\"$MILESTONE_TITLE\") | .number" 2>/dev/null | head -n1 || true)
  if [[ -z "$MILESTONE_NUMBER" ]]; then
    MILESTONE_NUMBER=$(gh api repos/:owner/:repo/milestones -f title="$MILESTONE_TITLE" -f state=open --jq .number)
  fi
fi

while IFS= read -r issue; do
  [[ -z "$issue" ]] && continue
  upsert_key=$(echo "$issue" | jq -r '.upsert_key')
  story_id=$(echo "$issue" | jq -r '.story_id')
  title=$(echo "$issue" | jq -r '.title')
  body=$(echo "$issue" | jq -r '.body')
  state=$(echo "$issue" | jq -r '.state')
  labels=$(echo "$issue" | jq -r '.labels | join(",")')

  existing=$(gh issue list --label "$upsert_key" --state all --json number --jq '.[0].number' 2>/dev/null || true)

  if [[ -n "$existing" && "$existing" != "null" ]]; then
    gh issue edit "$existing" --title "$title" --body "$body"
    if [[ -n "$MILESTONE_TITLE" && "$MILESTONE_TITLE" != "null" ]]; then
      gh issue edit "$existing" --milestone "$MILESTONE_TITLE" 2>/dev/null || true
    fi
    gh issue edit "$existing" --add-label "$labels" 2>/dev/null || true
    if [[ "$state" == "closed" ]]; then
      gh issue close "$existing" --comment "AgToosa sync: story ${story_id} shipped."
    else
      gh issue reopen "$existing" 2>/dev/null || true
    fi
    echo "Updated issue #${existing} (${story_id})"
  else
    create_args=(--title "$title" --body "$body" --label "$labels")
    if [[ -n "$MILESTONE_TITLE" && "$MILESTONE_TITLE" != "null" ]]; then
      create_args+=(--milestone "$MILESTONE_TITLE")
    fi
    new_num=$(gh issue create "${create_args[@]}" --json number --jq .number)
    if [[ "$state" == "closed" ]]; then
      gh issue close "$new_num" --comment "AgToosa sync: story ${story_id} shipped."
    fi
    echo "Created issue #${new_num} (${story_id})"
  fi
done < <(jq -c '.issues[]' "$MANIFEST")

echo "AgToosa Issues sync complete."
