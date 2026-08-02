#!/usr/bin/env bash

# ── AgToosa: GitHub Issues sync helpers (DEV-147) ─────────────
# Upsert loop extracted from scripts/agtoosa-issues-sync.sh for bats + doctor.

GH_ISSUES_SYNC_CMD="${GH_CMD:-gh}"

_github_issues_sync_gh() {
  "$GH_ISSUES_SYNC_CMD" "$@"
}

github_issues_sync_require_gh() {
  if ! command -v "$GH_ISSUES_SYNC_CMD" &>/dev/null; then
    echo "Error: gh CLI required for agtoosa-issues-sync." >&2
    return 1
  fi
}

github_issues_sync_write_manifest() {
  local root="$1" project="$2" manifest="$3" dry_run="$4"
  if [[ "$dry_run" == true ]]; then
    bash "$root/agtoosa.sh" --tracker publish --path "$project" --output "$manifest" >/dev/null
  elif [[ -f "$project/README.md" ]]; then
    bash "$root/agtoosa.sh" --tracker publish --path "$project" --output "$manifest" --readme "$project/README.md"
  else
    bash "$root/agtoosa.sh" --tracker publish --path "$project" --output "$manifest"
  fi
}

github_issues_sync_dry_run() {
  local manifest="$1"
  echo "Dry-run manifest ($(jq '.issues | length' "$manifest") issues):"
  jq -r '.issues[] | "\(.state)\t\(.upsert_key)\t\(.title)"' "$manifest"
}

github_issues_sync_apply() {
  local manifest="$1"
  local milestone_title milestone_number issue upsert_key story_id title body state labels existing new_num
  milestone_title=$(jq -r '.milestone // empty' "$manifest")
  milestone_number=""
  if [[ -n "$milestone_title" && "$milestone_title" != "null" ]]; then
    milestone_number=$(_github_issues_sync_gh api "repos/:owner/:repo/milestones" --jq ".[] | select(.title==\"$milestone_title\") | .number" 2>/dev/null | head -n1 || true)
    if [[ -z "$milestone_number" ]]; then
      milestone_number=$(_github_issues_sync_gh api repos/:owner/:repo/milestones -f title="$milestone_title" -f state=open --jq .number)
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

    existing=$(_github_issues_sync_gh issue list --label "$upsert_key" --state all --json number --jq '.[0].number' 2>/dev/null || true)

    if [[ -n "$existing" && "$existing" != "null" ]]; then
      _github_issues_sync_gh issue edit "$existing" --title "$title" --body "$body"
      if [[ -n "$milestone_title" && "$milestone_title" != "null" ]]; then
        _github_issues_sync_gh issue edit "$existing" --milestone "$milestone_title" 2>/dev/null || true
      fi
      _github_issues_sync_gh issue edit "$existing" --add-label "$labels" 2>/dev/null || true
      if [[ "$state" == "closed" ]]; then
        _github_issues_sync_gh issue close "$existing" --comment "AgToosa sync: story ${story_id} shipped."
      else
        _github_issues_sync_gh issue reopen "$existing" 2>/dev/null || true
      fi
      echo "Updated issue #${existing} (${story_id})"
    else
      local -a create_args=(--title "$title" --body "$body" --label "$labels")
      if [[ -n "$milestone_title" && "$milestone_title" != "null" ]]; then
        create_args+=(--milestone "$milestone_title")
      fi
      new_num=$(_github_issues_sync_gh issue create "${create_args[@]}" --json number --jq .number)
      if [[ "$state" == "closed" ]]; then
        _github_issues_sync_gh issue close "$new_num" --comment "AgToosa sync: story ${story_id} shipped."
      fi
      echo "Created issue #${new_num} (${story_id})"
    fi
  done < <(jq -c '.issues[]' "$manifest")

  echo "AgToosa Issues sync complete."
}

github_issues_sync_doctor_check() {
  local target="$1"
  local doc_pass="${2:-}"
  local doc_finding="${3:-}"
  [[ -n "$doc_pass" && -n "$doc_finding" ]] || return 0

  local workflow="${target}/.github/workflows/agtoosa-issues-sync.yml"
  [[ -f "$workflow" ]] || return 0

  local script="${target}/scripts/agtoosa-issues-sync.sh"
  if [[ ! -f "$script" ]]; then
    "$doc_finding" warn "GIP-003" \
      "agtoosa-issues-sync workflow present but scripts/agtoosa-issues-sync.sh is missing" \
      "CI issue sync will fail when Master-Plan changes are pushed." \
      "Copy scripts/agtoosa-issues-sync.sh from the AgToosa template pack." guided
    return 0
  fi

  local lib_root template_script
  lib_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  template_script="${lib_root}/template/scripts/agtoosa-issues-sync.sh"
  if [[ -f "$template_script" ]] && [[ "$(cd "$target" && pwd)" == "$(cd "$lib_root" && pwd)" ]]; then
    if ! cmp -s "$script" "$template_script"; then
      "$doc_finding" warn "GIP-003" \
        "Maintainer agtoosa-issues-sync.sh drift from template/scripts/ copy" \
        "Downstream template installs may ship a stale sync script." \
        "Sync template/scripts/agtoosa-issues-sync.sh from scripts/agtoosa-issues-sync.sh" guided
      return 0
    fi
  fi

  "$doc_pass" "GitHub Issues sync script present for opt-in workflow"
}
