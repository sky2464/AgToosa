#!/usr/bin/env bash

# ── AgToosa: GitHub Issues discovery merge (DEV-141) ──────────
# Transforms gh issue list JSON into discovery items. No network.

GH_ISSUES_FETCH_VERSION="agtoosa.github-issues-fetch/v1"
LINEAR_FETCH_VERSION="agtoosa.linear-fetch-envelope/v1"

_gh_discover_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

_github_issues_label_names() {
  local issue_json="$1"
  echo "$issue_json" | jq -r '
    if (.labels | type) == "array" then
      .labels[] |
      if type == "object" then .name // empty
      elif type == "string" then .
      else empty end
    else empty end
  ' 2>/dev/null
}

_github_issues_is_mirror() {
  local issue_json="$1"
  local labels body label
  while IFS= read -r label; do
    [[ -z "$label" ]] && continue
    if [[ "$label" =~ ^agtoosa:DEV- ]]; then
      return 0
    fi
    if [[ "$label" == "source:agtoosa-sync" ]]; then
      return 0
    fi
  done < <(_github_issues_label_names "$issue_json")
  body=$(echo "$issue_json" | jq -r '.body // ""')
  if [[ "$body" =~ agtoosa-story-id:[[:space:]]*DEV- ]]; then
    return 0
  fi
  return 1
}

github_issues_item_from_issue() {
  local issue_json="$1" repo_slug="${2:-unknown}"
  local number title state labels_json body_excerpt external_ref item_status
  number=$(echo "$issue_json" | jq -r '.number // 0')
  title=$(echo "$issue_json" | jq -r '.title // "Untitled"')
  state=$(echo "$issue_json" | jq -r '.state // "OPEN"')
  state=$(_gh_discover_lower "$state")
  if [[ "$state" == "open" ]]; then
    item_status="open"
  elif [[ "$state" == "closed" ]]; then
    item_status="closed"
  else
    item_status="unknown"
  fi
  body_excerpt=$(echo "$issue_json" | jq -r '.body // ""' | head -c 512)
  labels_json=$(_github_issues_label_names "$issue_json" | jq -R . | jq -s .)
  external_ref="github:${repo_slug}#${number}"
  jq -nc \
    --arg external_ref "$external_ref" \
    --arg title "$title" \
    --arg status "$item_status" \
    --argjson labels "$labels_json" \
    --arg body_excerpt "$body_excerpt" \
    '{
      external_ref: $external_ref,
      provider: "github-issues",
      title: $title,
      status: $status,
      labels: $labels,
      linked_story_id: null,
      body_excerpt: $body_excerpt
    }'
}

github_issues_items_from_fetch() {
  local fetch_json="$1"
  local schema repo issues
  schema=$(echo "$fetch_json" | jq -r '.schema_version // empty')
  if [[ "$schema" != "$GH_ISSUES_FETCH_VERSION" ]]; then
    # Accept raw gh array (no wrapper) for convenience
    if echo "$fetch_json" | jq -e 'type == "array"' >/dev/null 2>&1; then
      issues="$fetch_json"
      repo="unknown"
    else
      echo "Error: expected schema_version ${GH_ISSUES_FETCH_VERSION} or a JSON array." >&2
      return 1
    fi
  else
    issues=$(echo "$fetch_json" | jq -c '.issues')
    repo=$(echo "$fetch_json" | jq -r '.repository // "unknown"')
  fi
  local count
  count=$(echo "$issues" | jq 'length')
  if [[ "$count" -gt $TRACKER_MAX_DISCOVERY_ITEMS ]]; then
    echo "Error: GitHub issues exceed discovery item bound (${TRACKER_MAX_DISCOVERY_ITEMS})." >&2
    return 1
  fi
  local -a items=()
  local issue
  while IFS= read -r issue; do
    [[ -z "$issue" ]] && continue
    if _github_issues_is_mirror "$issue"; then
      continue
    fi
    items+=("$(github_issues_item_from_issue "$issue" "$repo")")
  done < <(echo "$issues" | jq -c '.[]')
  if [[ ${#items[@]} -eq 0 ]]; then
    printf '[]'
    return 0
  fi
  printf '%s\n' "${items[@]}" | jq -s .
}

linear_items_from_fetch() {
  local fetch_json="$1"
  local schema
  schema=$(echo "$fetch_json" | jq -r '.schema_version // empty')
  if [[ "$schema" != "$LINEAR_FETCH_VERSION" ]]; then
    echo "Error: expected schema_version ${LINEAR_FETCH_VERSION}." >&2
    return 1
  fi
  local count
  count=$(echo "$fetch_json" | jq '.issues | length')
  if [[ "$count" -gt $TRACKER_MAX_DISCOVERY_ITEMS ]]; then
    echo "Error: Linear issues exceed discovery item bound (${TRACKER_MAX_DISCOVERY_ITEMS})." >&2
    return 1
  fi
  echo "$fetch_json" | jq -c '
    .issues[] |
    {
      external_ref: ("linear:" + (.identifier // "unknown")),
      provider: "linear",
      title: (.title // "Untitled"),
      status: (
        if (.state // "" | test("done|completed|cancelled|canceled"; "i")) then "closed"
        elif (.state // "" | test("started|progress|review"; "i")) then "open"
        else "unknown"
        end
      ),
      labels: [],
      linked_story_id: null,
      body_excerpt: (.url // "" | tostring | .[0:512])
    }
  ' | jq -s .
}

discovery_merge_items() {
  local base_items_json="$1" new_items_json="$2"
  jq -s '(.[0] // []) + (.[1] // []) | unique_by(.external_ref)' \
    <(echo "$base_items_json" | jq -c .) \
    <(echo "$new_items_json" | jq -c .)
}
