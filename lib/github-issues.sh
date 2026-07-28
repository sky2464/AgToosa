#!/usr/bin/env bash

# ── AgToosa: GitHub Issues PM Bridge (DEV-139) ────────────────
# Renders publish manifests and intake proposals from tracker export.
# Master-Plan.md remains authoritative; no automatic apply.

GH_ISSUES_MANIFEST_VERSION="agtoosa.github-issues-manifest/v1"
GH_ISSUES_INTAKE_VERSION="agtoosa.github-issues-intake/v1"
GH_ISSUES_MAX_ISSUES=128
GH_ISSUES_ROADMAP_MAX_ROWS=12

_gh_issues_require_jq() {
  _tracker_require_jq
}

_gh_issues_story_shipped() {
  local status="$1"
  [[ "$status" =~ [Ss]hipped|[Dd]one|🏁 ]] && return 0
  return 1
}

_gh_issues_type_prefix() {
  local story_type="${1,,}"
  case "$story_type" in
    feature|feat*) printf 'feat' ;;
    bug|bugfix|fix*) printf 'fix' ;;
    docs|documentation*) printf 'docs' ;;
    spike|chore|security*) printf 'chore' ;;
    *) printf 'chore' ;;
  esac
}

_gh_issues_infer_type_from_title() {
  local title="$1"
  if [[ "$title" =~ ^[Ff]eature: ]]; then
    printf 'feat'
  elif [[ "$title" =~ ^[Bb]ug(fix)?: ]]; then
    printf 'fix'
  elif [[ "$title" =~ ^[Dd]ocs: ]]; then
    printf 'docs'
  else
    printf 'chore'
  fi
}

_gh_issues_render_title() {
  local story_type="$1" title="$2"
  local prefix clean
  prefix=$(_gh_issues_infer_type_from_title "$title")
  clean="$title"
  clean="${clean#Feature: }"
  clean="${clean#Bugfix: }"
  clean="${clean#Bug: }"
  clean="${clean#Chore: }"
  clean="${clean#Docs: }"
  clean="${clean#Spike: }"
  clean="${clean#Fix: }"
  clean="${clean#Security: }"
  clean="${clean%% }"
  printf '%s: %s' "$prefix" "$clean"
}

_gh_issues_status_label() {
  local status="$1"
  if [[ "$status" =~ [Ii]n[[:space:]]*[Rr]eview|🔍 ]]; then
    printf 'status-review'
  elif [[ "$status" =~ [Ii]n[[:space:]]*[Pp]rogress|🟨 ]]; then
    printf 'status-in-progress'
  elif [[ "$status" =~ [Bb]locked|🚫 ]]; then
    printf 'status-blocked'
  else
    printf 'status-backlog'
  fi
}

_gh_issues_area_label() {
  local title="$1" epic="$2"
  if [[ "$title" =~ [Cc][Ii]|[Ww]orkflow|[Tt]est ]]; then
    printf 'area-ci'
  elif [[ "$title" =~ [Dd]oc|[Rr]eadme|[Ww]iki ]]; then
    printf 'area-docs'
  elif [[ "$title" =~ [Ss]ecurity|[Ss]hell[Cc]heck ]]; then
    printf 'area-security'
  elif [[ "$title" =~ [Tt]emplate|[Pp]latform|[Aa]dapter ]]; then
    printf 'area-template'
  else
    printf 'area-generator'
  fi
}

_gh_issues_active_cycle_ids() {
  local mp="$1"
  _tracker_collect_story_rows "$mp" "Active Cycle" | cut -d'|' -f1
}

_gh_issues_charter_milestone() {
  local mp="$1"
  awk -F'|' '/^\| Milestone \|/ {
    gsub(/^[ \t]+|[ \t]+$/, "", $3)
    gsub(/`/, "", $3)
    gsub(/[[:space:]]*\(next\).*/, "", $3)
    print $3
    exit
  }' "$mp"
}

_gh_issues_should_publish_story() {
  local story_id="$1" status="$2" active_ids="$3"
  if _gh_issues_story_shipped "$status"; then
    grep -qx "$story_id" <<< "$active_ids" && return 0
    return 1
  fi
  return 0
}

_gh_issues_render_body() {
  local story_id="$1" title="$2" status="$3" estimate="$4" spec_path="$5" ac_json="$6" export_id="$7" sync_at="${8:-}"
  if [[ -z "$sync_at" ]]; then
    sync_at="export:${export_id:0:12}"
  fi
  local ac_lines=""
  if [[ -n "$ac_json" && "$ac_json" != "[]" && "$ac_json" != "null" ]]; then
    ac_lines=$(echo "$ac_json" | jq -r '.[] | "- [ ] \(.)"' 2>/dev/null || true)
  fi
  cat <<EOF
## Summary

${title}

| Field | Value |
|-------|-------|
| Story ID | \`${story_id}\` |
| Status | ${status} |
| Estimate | ${estimate} |

$(if [[ -n "$spec_path" ]]; then echo "**Spec:** [\`${spec_path}\`](${spec_path})"; echo ""; fi)
$(if [[ -n "$ac_lines" ]]; then echo "### Acceptance criteria (mirror)"; echo ""; echo "$ac_lines"; echo ""; fi)
---

_AgToosa sync mirror — \`docs/Master-Plan.md\` is authoritative. Accept changes via \`/agtoosa-task\` or \`/agtoosa-spec amend\` only._

- **last-sync:** ${sync_at}
- **export-id:** \`${export_id}\`

<!-- agtoosa-story-id: ${story_id} -->
EOF
}

github_issues_render_issue_payload() {
  local story_json="$1" export_id="$2" milestone="${3:-}" sync_at="${4:-}"
  local story_id title epic status estimate spec_path state labels_json body
  story_id=$(echo "$story_json" | jq -r '.story_id')
  title=$(echo "$story_json" | jq -r '.title')
  epic=$(echo "$story_json" | jq -r '.epic // ""')
  status=$(echo "$story_json" | jq -r '.status')
  estimate=$(echo "$story_json" | jq -r '.estimate // ""')
  spec_path=$(echo "$story_json" | jq -r '.spec_path // ""')
  local ac_json
  ac_json=$(echo "$story_json" | jq -c '.acceptance_criteria_refs // []')

  if _gh_issues_story_shipped "$status"; then
    state="closed"
  else
    state="open"
  fi

  local rendered_title type_label status_label area_label
  rendered_title=$(_gh_issues_render_title "" "$title")
  type_label="chore"
  [[ "$rendered_title" == feat:* ]] && type_label="enhancement"
  [[ "$rendered_title" == fix:* ]] && type_label="bug"
  [[ "$rendered_title" == docs:* ]] && type_label="documentation"
  status_label=$(_gh_issues_status_label "$status")
  area_label=$(_gh_issues_area_label "$title" "$epic")

  body=$(_gh_issues_render_body "$story_id" "$title" "$status" "$estimate" "$spec_path" "$ac_json" "$export_id" "$sync_at")

  jq -nc \
    --arg story_id "$story_id" \
    --arg title "$rendered_title" \
    --arg body "$body" \
    --arg state "$state" \
    --arg milestone "$milestone" \
    --arg type_label "$type_label" \
    --arg status_label "$status_label" \
    --arg area_label "$area_label" \
  '{
    story_id: $story_id,
    upsert_key: ("agtoosa:" + $story_id),
    title: $title,
    body: $body,
    state: $state,
    milestone: (if $milestone == "" then null else $milestone end),
    labels: [
      ("agtoosa:" + $story_id),
      "source:agtoosa-sync",
      $type_label,
      $status_label,
      $area_label
    ]
  }'
}

github_issues_render_manifest_from_export() {
  local export_json="$1" active_ids="$2" milestone="$3"
  local export_id stories filtered count=0 sync_at
  export_id=$(echo "$export_json" | jq -r '.export_id')
  sync_at=$(echo "$export_json" | jq -r '.export_id' | cut -c1-16)
  stories=$(echo "$export_json" | jq -c '.stories[]?')

  local -a payloads=()
  while IFS= read -r story; do
    [[ -z "$story" ]] && continue
    local story_id status ms=""
    story_id=$(echo "$story" | jq -r '.story_id')
    status=$(echo "$story" | jq -r '.status')
    if ! _gh_issues_should_publish_story "$story_id" "$status" "$active_ids"; then
      continue
    fi
    if grep -qx "$story_id" <<< "$active_ids"; then
      ms="$milestone"
    fi
    payloads+=("$(github_issues_render_issue_payload "$story" "$export_id" "$ms" "$sync_at")")
    count=$((count + 1))
    if [[ $count -ge $GH_ISSUES_MAX_ISSUES ]]; then
      break
    fi
  done <<< "$stories"

  local issues_json='[]'
  if [[ ${#payloads[@]} -gt 0 ]]; then
    issues_json=$(printf '%s\n' "${payloads[@]}" | jq -s 'sort_by(.story_id)')
  fi

  jq -nc \
    --arg schema_version "$GH_ISSUES_MANIFEST_VERSION" \
    --arg export_id "$export_id" \
    --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg milestone "$milestone" \
    --argjson issues "$issues_json" \
    '{
      schema_version: $schema_version,
      export_id: $export_id,
      generated_at: $generated_at,
      milestone: (if $milestone == "" then null else $milestone end),
      issues: $issues
    }'
}

github_issues_render_readme_block() {
  local export_json="$1"
  local charter_ms active_lines
  charter_ms=$(echo "$export_json" | jq -r '.milestone // empty')
  active_lines=$(echo "$export_json" | jq -r '
    .stories[]?
    | select(.status | test("Shipped|Done|🏁") | not)
    | "| " + .story_id + " | " + .title + " | " + .status + " |"
  ' 2>/dev/null | head -n "$GH_ISSUES_ROADMAP_MAX_ROWS")

  {
    echo "<!-- AGTOOSA-ROADMAP:START -->"
    echo ""
    echo "## Public roadmap (synced from Master-Plan)"
    echo ""
    echo "> Auto-generated by \`agtoosa-issues-sync\` — [\`docs/Master-Plan.md\`](docs/Master-Plan.md) is authoritative."
    echo ""
    if [[ -n "$charter_ms" ]]; then
      echo "**Milestone:** ${charter_ms}"
      echo ""
    fi
    echo "| Story | Title | Status |"
    echo "|-------|-------|--------|"
    if [[ -n "$active_lines" ]]; then
      echo "$active_lines"
    else
      echo "| — | (no active stories in export) | — |"
    fi
    echo ""
    echo "[View all issues →](https://github.com/sky2464/AgToosa/issues)"
    echo ""
    echo "<!-- AGTOOSA-ROADMAP:END -->"
  }
}

github_issues_update_readme_block() {
  local readme_path="$1" block_path="$2"
  [[ -f "$readme_path" ]] || {
    echo "Error: README not found: $readme_path" >&2
    return 1
  }
  local tmp start end
  tmp=$(mktemp)
  start=$(grep -n 'AGTOOSA-ROADMAP:START' "$readme_path" | head -n1 | cut -d: -f1 || true)
  end=$(grep -n 'AGTOOSA-ROADMAP:END' "$readme_path" | head -n1 | cut -d: -f1 || true)
  if [[ -n "$start" && -n "$end" && "$start" -lt "$end" ]]; then
    {
      head -n $((start - 1)) "$readme_path"
      cat "$block_path"
      tail -n +"$end" "$readme_path"
    } >"$tmp"
  else
    {
      cat "$readme_path"
      echo ""
      cat "$block_path"
    } >"$tmp"
  fi
  mv "$tmp" "$readme_path"
}

tracker_publish() {
  local project_path="$1" output_path="$2" readme_path="${3:-}"
  _gh_issues_require_jq || return 1

  local mp active_ids milestone export_tmp export_json manifest
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  active_ids=$(_gh_issues_active_cycle_ids "$mp")
  milestone=$(_gh_issues_charter_milestone "$mp")
  milestone="${milestone#v}"

  export_tmp=$(mktemp)
  tracker_export "$project_path" "$export_tmp" || return 1
  export_json=$(cat "$export_tmp")
  rm -f "$export_tmp"

  manifest=$(github_issues_render_manifest_from_export "$export_json" "$active_ids" "$milestone")
  manifest=$(echo "$manifest" | jq --arg at "$(echo "$export_json" | jq -r '.generated_at')" '.generated_at = $at')
  mkdir -p "$(dirname "$output_path")"
  printf '%s\n' "$manifest" >"$output_path"

  if [[ -n "$readme_path" ]]; then
    local block_tmp
    block_tmp=$(mktemp)
    # enrich export with milestone for readme
    local enriched
    enriched=$(echo "$export_json" | jq --arg ms "$milestone" '. + {milestone: $ms}')
    github_issues_render_readme_block "$enriched" >"$block_tmp"
    github_issues_update_readme_block "$readme_path" "$block_tmp" || return 1
    rm -f "$block_tmp"
  fi

  echo "GitHub Issues manifest written: $output_path"
  return 0
}

_github_issues_next_dev_id() {
  local mp="$1"
  local max=0 n
  while IFS= read -r n; do
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    [[ "$n" -gt "$max" ]] && max="$n"
  done < <(grep -oE 'DEV-[0-9]{3}' "$mp" | sed 's/DEV-//' | sort -u)
  printf 'DEV-%03d' $((max + 1))
}

github_issues_render_intake_proposal() {
  local project_path="$1" intake_json="$2"
  local mp draft_id title body labels issue_number url generated_at
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  draft_id=$(_github_issues_next_dev_id "$mp")

  title=$(echo "$intake_json" | jq -r '.title // "Untitled"')
  body=$(echo "$intake_json" | jq -r '.body // ""')
  labels=$(echo "$intake_json" | jq -c '.labels // []')
  issue_number=$(echo "$intake_json" | jq -r '.issue_number // "?"')
  url=$(echo "$intake_json" | jq -r '.url // ""')
  generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  local safe_title safe_body
  safe_title="$title"
  safe_body="$body"
  if unsafe=$(_tracker_unsafe_reason "$body"); then
    safe_body="[redacted — ${unsafe}]"
  fi

  local backlog_row
  backlog_row="| ${draft_id} | ${safe_title} | Feature | M | DEV-003 | P2 | ⬜ Backlog — from issue #${issue_number} |"

  cat <<EOF
# GitHub Issues Intake Proposal

> Provider: \`github-issues\`
> Issue: #${issue_number}
> Generated: \`${generated_at}\`
> Proposed story ID: \`${draft_id}\` (suggested — assign at acceptance)

**Authority:** This proposal does **not** modify \`docs/Master-Plan.md\`. Accept via \`/agtoosa-task\` or explicit human edit only.

## Community issue

- **Title:** ${safe_title}
- **URL:** ${url}
- **Labels:** $(echo "$labels" | jq -r 'join(", ")')

## Suggested Master-Plan backlog row

\`\`\`
${backlog_row}
\`\`\`

## Suggested command

\`\`\`
/agtoosa-task feature "${safe_title}" --id ${draft_id}
\`\`\`

## Issue body (sanitized)

${safe_body}
EOF
}

tracker_propose_intake() {
  local project_path="$1" input_path="$2" output_path="$3"
  _gh_issues_require_jq || return 1

  local mp_resolved out_resolved mp
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  mp_resolved=$(_tracker_resolve_path "$mp")
  out_resolved=$(_tracker_resolve_path "$output_path")
  if [[ "$out_resolved" == "$mp_resolved" ]]; then
    echo "Error: Intake proposal output must not target Master-Plan.md." >&2
    return 1
  fi

  local json
  json=$(_tracker_load_bounded_json "$input_path") || return 1
  local schema_version
  schema_version=$(echo "$json" | jq -r '.schema_version // empty')
  if [[ "$schema_version" != "$GH_ISSUES_INTAKE_VERSION" ]]; then
    echo "Error: Invalid intake schema_version (expected ${GH_ISSUES_INTAKE_VERSION})." >&2
    return 1
  fi

  mkdir -p "$(dirname "$output_path")"
  github_issues_render_intake_proposal "$project_path" "$json" >"$output_path"
  echo "GitHub Issues intake proposal written: $output_path"
  return 0
}
