#!/usr/bin/env bash

# ── AgToosa: Tracker Discovery & Bootstrap (DEV-141) ──────────
# Local discovery heuristics and proposal-only bootstrap import.

TRACKER_DISCOVERY_VERSION="agtoosa.tracker-discovery/v1"
TRACKER_BOOTSTRAP_INPUT_VERSION="agtoosa.tracker-bootstrap-input/v1"
TRACKER_STATUS_CHECK_VERSION="agtoosa.tracker-status-check/v1"
TRACKER_CACHE_GH_REL=".agtoosa/tracker/gh-issues.json"
TRACKER_CACHE_LINEAR_REL=".agtoosa/tracker/linear-fetch.json"
TRACKER_MAX_DISCOVERY_ITEMS=256
_DISCOVER_SIGNALS_BUF=()

_discover_add_signal() {
  local provider="$1" confidence="$2" evidence="$3"
  _DISCOVER_SIGNALS_BUF+=("$(jq -nc \
    --arg provider "$provider" \
    --arg confidence "$confidence" \
    --arg evidence "$evidence" \
    '{provider: $provider, confidence: $confidence, evidence: $evidence}')")
}

_discover_normalize_title() {
  local t="$1"
  t=$(_gh_discover_lower "$t")
  t=$(printf '%s' "$t" | sed -E 's/^(feat|fix|chore|docs|spike|bug|feature|bugfix):[[:space:]]*//')
  t=$(printf '%s' "$t" | sed -E 's/[^a-z0-9]+/ /g' | sed 's/^ *//;s/ *$//')
  printf '%s' "$t"
}

_discover_scan_signals() {
  local project="$1"
  _DISCOVER_SIGNALS_BUF=()

  if [[ -d "$project/.github/ISSUE_TEMPLATE" ]] \
    || [[ -f "$project/.github/workflows/agtoosa-issues-sync.yml" ]] \
    || [[ -f "$project/.github/workflows/agtoosa-issues-sync.yml.example" ]]; then
    _discover_add_signal "github-issues" "high" ".github issue templates or agtoosa-issues-sync workflow"
  fi
  if [[ -f "$project/ISSUES.md" ]]; then
    _discover_add_signal "github-issues" "medium" "ISSUES.md present"
  fi
  if grep -rq 'linear\.app' "$project/README.md" "$project/docs" "$project/Docs" 2>/dev/null \
    || [[ -d "$project/.linear" ]] \
    || grep -rq 'LINEAR_' "$project/README.md" 2>/dev/null; then
    _discover_add_signal "linear" "medium" "Linear URL or config reference"
  fi
  if [[ -f "$project/ROADMAP.md" ]] || [[ -f "$project/TODOS.md" ]] \
    || [[ -d "$project/docs/plans" ]] || [[ -d "$project/Docs/plans" ]] \
    || [[ -d "$project/.cursor/plans" ]]; then
    _discover_add_signal "repo-plans" "high" "ROADMAP/TODOS/plans directory"
  fi

  local mp
  if mp=$(_tracker_find_master_plan "$project" 2>/dev/null); then
    local backlog_body
    backlog_body=$(_tracker_section_body "$mp" "Backlog")
    if echo "$backlog_body" | grep -qE '^\|[[:space:]]*DEV-'; then
      _discover_add_signal "master-plan" "high" "Master-Plan Backlog has story rows"
    fi
  fi

  if [[ ${#_DISCOVER_SIGNALS_BUF[@]} -eq 0 ]]; then
    printf '[]'
    return 0
  fi
  printf '%s\n' "${_DISCOVER_SIGNALS_BUF[@]}" | jq -s .
}

_discover_repo_plan_items() {
  local project="$1"
  local -a items=()
  local f line title ref n=0

  _discover_parse_plan_file() {
    local path="$1" provider_label="$2"
    [[ -f "$path" ]] || return 0
    local basename_ref
    basename_ref=$(basename "$path")
    while IFS= read -r line; do
      if [[ "$line" =~ ^#[[:space:]]+(.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        title="${title%%#*}"
        title="${title#"${title%%[![:space:]]*}"}"
        [[ -z "$title" ]] && continue
        n=$((n + 1))
        ref="repo-plan:${basename_ref}#h${n}"
        items+=("$(jq -nc \
          --arg external_ref "$ref" \
          --arg title "$title" \
          --arg provider "$provider_label" \
          '{external_ref: $external_ref, provider: $provider, title: $title, status: "open", labels: ["source:repo-plan"], linked_story_id: null, body_excerpt: ""}')")
      elif [[ "$line" =~ ^-[[:space:]]*\[[[:space:]]*[xX][[:space:]]*\][[:space:]]+(.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        n=$((n + 1))
        ref="repo-plan:${basename_ref}#t${n}"
        items+=("$(jq -nc \
          --arg external_ref "$ref" \
          --arg title "$title" \
          '{external_ref: $external_ref, provider: "repo-plans", title: $title, status: "closed", labels: ["source:repo-plan"], linked_story_id: null, body_excerpt: ""}')")
      elif [[ "$line" =~ ^-[[:space:]]*\[[[:space:]]*\][[:space:]]+(.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        n=$((n + 1))
        ref="repo-plan:${basename_ref}#t${n}"
        items+=("$(jq -nc \
          --arg external_ref "$ref" \
          --arg title "$title" \
          '{external_ref: $external_ref, provider: "repo-plans", title: $title, status: "open", labels: ["source:repo-plan"], linked_story_id: null, body_excerpt: ""}')")
      fi
    done <"$path"
  }

  _discover_parse_plan_file "$project/ROADMAP.md" "repo-plans"
  _discover_parse_plan_file "$project/TODOS.md" "repo-plans"

  local plan_dir
  for plan_dir in "$project/docs/plans" "$project/Docs/plans" "$project/.cursor/plans"; do
    [[ -d "$plan_dir" ]] || continue
    while IFS= read -r f; do
      _discover_parse_plan_file "$f" "repo-plans"
    done < <(find "$plan_dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null | head -n 32)
  done

  if [[ ${#items[@]} -eq 0 ]]; then
    printf '[]'
    return 0
  fi
  printf '%s\n' "${items[@]}" | jq -s .
}

_resolve_discovery_input() {
  local input_json="$1"
  local schema discovery items='[]'
  schema=$(echo "$input_json" | jq -r '.schema_version // empty')
  case "$schema" in
    "$TRACKER_DISCOVERY_VERSION")
      printf '%s' "$input_json"
      return 0
      ;;
    "$TRACKER_BOOTSTRAP_INPUT_VERSION")
      discovery=$(echo "$input_json" | jq -c '.discovery')
      items=$(echo "$discovery" | jq -c '.items // []')
      if echo "$input_json" | jq -e '.github_issues_fetch' >/dev/null 2>&1; then
        local gh_items
        gh_items=$(github_issues_items_from_fetch "$(echo "$input_json" | jq -c '.github_issues_fetch')") || return 1
        items=$(discovery_merge_items "$items" "$gh_items")
      fi
      if echo "$input_json" | jq -e '.linear_fetch' >/dev/null 2>&1; then
        local lin_items
        lin_items=$(linear_items_from_fetch "$(echo "$input_json" | jq -c '.linear_fetch')") || return 1
        items=$(discovery_merge_items "$items" "$lin_items")
      fi
      echo "$discovery" | jq --argjson items "$items" '.items = $items'
      return 0
      ;;
    "$GH_ISSUES_FETCH_VERSION")
      items=$(github_issues_items_from_fetch "$input_json") || return 1
      jq -nc \
        --arg schema_version "$TRACKER_DISCOVERY_VERSION" \
        --arg discovered_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        --argjson items "$items" \
        '{schema_version: $schema_version, discovered_at: $discovered_at, signals: [], items: $items}'
      return 0
      ;;
    *)
      if echo "$input_json" | jq -e 'type == "array"' >/dev/null 2>&1; then
        items=$(github_issues_items_from_fetch "$input_json") || return 1
        jq -nc \
          --arg schema_version "$TRACKER_DISCOVERY_VERSION" \
          --arg discovered_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
          --argjson items "$items" \
          '{schema_version: $schema_version, discovered_at: $discovered_at, signals: [], items: $items}'
        return 0
      fi
      echo "Error: unsupported discovery input schema_version: ${schema:-<missing>}" >&2
      return 1
      ;;
  esac
}

tracker_discover() {
  local project_path="$1" output_path="$2" merge_input="${3:-}"
  _tracker_require_jq || return 1

  local signals items='[]' discovered_at repo_path
  signals=$(_discover_scan_signals "$project_path")
  items=$(_discover_repo_plan_items "$project_path")
  discovered_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
  repo_path="$project_path"

  if [[ -n "$merge_input" && -f "$merge_input" ]]; then
    local merge_json gh_items lin_items merge_schema repo=""
    merge_json=$(_tracker_load_bounded_json "$merge_input") || return 1
    merge_schema=$(echo "$merge_json" | jq -r '.schema_version // empty')
    if [[ "$merge_schema" == "$GH_ISSUES_FETCH_VERSION" ]] || echo "$merge_json" | jq -e 'type == "array"' >/dev/null 2>&1; then
      gh_items=$(github_issues_items_from_fetch "$merge_json") || return 1
      items=$(discovery_merge_items "$items" "$gh_items")
      repo=$(echo "$merge_json" | jq -r '.repository // empty')
      [[ -n "$repo" ]] && repo_path="$repo"
    elif [[ "$merge_schema" == "$LINEAR_FETCH_VERSION" ]]; then
      lin_items=$(linear_items_from_fetch "$merge_json") || return 1
      items=$(discovery_merge_items "$items" "$lin_items")
    else
      echo "Error: --input for discover must be github-issues-fetch or linear-fetch envelope." >&2
      return 1
    fi
  fi

  local count
  count=$(echo "$items" | jq 'length')
  if [[ "$count" -gt $TRACKER_MAX_DISCOVERY_ITEMS ]]; then
    echo "Error: discovery items exceed bound (${TRACKER_MAX_DISCOVERY_ITEMS})." >&2
    return 1
  fi

  local envelope
  envelope=$(jq -nc \
    --arg schema_version "$TRACKER_DISCOVERY_VERSION" \
    --arg discovered_at "$discovered_at" \
    --arg repository "$repo_path" \
    --argjson signals "$signals" \
    --argjson items "$items" \
    '{
      schema_version: $schema_version,
      discovered_at: $discovered_at,
      repository: $repository,
      signals: $signals,
      items: $items
    }')

  mkdir -p "$(dirname "$output_path")"
  printf '%s\n' "$envelope" >"$output_path"
  echo "Tracker discovery written: $output_path (${count} items, $(echo "$signals" | jq 'length') signals)"
  return 0
}

_bootstrap_collect_mp_index() {
  local mp="$1"
  _BOOTSTRAP_MP_IDS=()
  _BOOTSTRAP_MP_TITLES=()
  local row story_id title
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    IFS='|' read -r story_id title _ _ _ <<< "$row"
    _BOOTSTRAP_MP_IDS+=("$story_id")
    _BOOTSTRAP_MP_TITLES+=("$title")
  done < <(_tracker_deduped_story_rows "$mp")
}

_bootstrap_item_is_mirror() {
  local item_json="$1"
  local label
  while IFS= read -r label; do
    [[ -z "$label" ]] && continue
    if [[ "$label" =~ ^agtoosa:DEV- ]] || [[ "$label" == "source:agtoosa-sync" ]]; then
      return 0
    fi
  done < <(echo "$item_json" | jq -r '.labels[]? // empty')
  local body
  body=$(echo "$item_json" | jq -r '.body_excerpt // ""')
  [[ "$body" =~ agtoosa-story-id:[[:space:]]*DEV- ]]
}

_bootstrap_classify_item() {
  local item_json="$1" mp_has_backlog="${2:-0}"
  shift 2
  local -a mp_titles=("$@")

  if _bootstrap_item_is_mirror "$item_json"; then
    printf 'mirror_skip'
    return 0
  fi

  local status provider title mp_title norm norm_mp
  status=$(echo "$item_json" | jq -r '.status // "unknown"')
  provider=$(echo "$item_json" | jq -r '.provider // "other"')
  title=$(echo "$item_json" | jq -r '.title // ""')

  if [[ "$status" == "closed" ]]; then
    printf 'closed_external'
    return 0
  fi

  if [[ "$provider" == "repo-plans" ]]; then
    printf 'repo_plan'
    return 0
  fi

  if [[ "$mp_has_backlog" -eq 1 && ${#mp_titles[@]} -gt 0 ]]; then
    norm=$(_discover_normalize_title "$title")
    for mp_title in "${mp_titles[@]}"; do
      norm_mp=$(_discover_normalize_title "$mp_title")
      if [[ -n "$norm" && "$norm" == "$norm_mp" ]]; then
        printf 'unchanged'
        return 0
      fi
    done
  fi

  printf 'new_external'
}

_bootstrap_next_draft_id() {
  local n="${1:-1}"
  printf 'DRAFT-%03d' "$n"
}

_bootstrap_render_proposal() {
  local discovery_json="$1" classified_json="$2" generated_at="$3"
  local total mirror_skip new_ext repo_plan closed_ext unchanged
  total=$(echo "$classified_json" | jq 'length')
  mirror_skip=$(echo "$classified_json" | jq '[.[] | select(.disposition == "mirror_skip")] | length')
  new_ext=$(echo "$classified_json" | jq '[.[] | select(.disposition == "new_external")] | length')
  repo_plan=$(echo "$classified_json" | jq '[.[] | select(.disposition == "repo_plan")] | length')
  closed_ext=$(echo "$classified_json" | jq '[.[] | select(.disposition == "closed_external")] | length')
  unchanged=$(echo "$classified_json" | jq '[.[] | select(.disposition == "unchanged")] | length')

  {
    echo "# Tracker Bootstrap Proposal"
    echo ""
    echo "> Schema: \`${TRACKER_DISCOVERY_VERSION}\`"
    echo "> Generated: \`${generated_at}\`"
    echo ""
    echo "**Authority:** This proposal does **not** modify \`docs/Master-Plan.md\` or \`Docs/Master-Plan.md\`. Accept rows via \`/agtoosa-task\` or explicit human edit only."
    echo ""
    echo "## Summary"
    echo ""
    echo "| Disposition | Count |"
    echo "|-------------|-------|"
    echo "| mirror_skip | ${mirror_skip} |"
    echo "| new_external | ${new_ext} |"
    echo "| repo_plan | ${repo_plan} |"
    echo "| closed_external | ${closed_ext} |"
    echo "| unchanged | ${unchanged} |"
    echo "| **Total** | **${total}** |"
    echo ""
    echo "## Discovery signals"
    echo ""
    echo "$discovery_json" | jq -r '.signals[]? | "- **\(.provider)** (\(.confidence)): \(.evidence)"'
    echo ""
    echo "## Suggested tracker mirror config"
    echo ""
    echo '```yaml'
    echo '## Tracker mirror (add to Docs/Context/workflow.md after acceptance)'
    echo 'tracker_mirror:'
    local primary_provider
    primary_provider=$(echo "$discovery_json" | jq -r '[.signals[] | select(.provider != "master-plan" and .provider != "repo-plans") | .provider] | first // "none"')
    echo "  provider: ${primary_provider}"
    echo '  mode: outbound'
    echo '```'
    echo ""
    echo "## Items"
    echo ""
    echo "$classified_json" | jq -r '.[] |
      "### \(.draft_id // "—") — \(.disposition)\n\n" +
      "- **External ref:** \(.external_ref)\n" +
      "- **Provider:** \(.provider)\n" +
      "- **Title:** \(.title)\n" +
      (if .backlog_row != "" then "- **Suggested backlog row:**\n\n```\n" + .backlog_row + "\n```\n" else "" end) +
      (if .task_hint != "" then "- **Suggested command:** `\(.task_hint)`\n" else "" end)'
    echo ""
    echo "---"
    echo ""
    echo "*Master-Plan remains the repo-local source of truth. External trackers are optional mirrors after bootstrap.*"
  }
}

tracker_bootstrap() {
  local project_path="$1" input_path="$2" output_path="$3"
  _tracker_require_jq || return 1

  local mp mp_resolved out_resolved
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  mp_resolved=$(_tracker_resolve_path "$mp")
  out_resolved=$(_tracker_resolve_path "$output_path")
  if [[ "$out_resolved" == "$mp_resolved" ]]; then
    echo "Error: Bootstrap proposal output must not target Master-Plan.md." >&2
    return 1
  fi

  local raw_json discovery_json
  raw_json=$(_tracker_load_bounded_json "$input_path") || return 1
  discovery_json=$(_resolve_discovery_input "$raw_json") || return 1

  local schema
  schema=$(echo "$discovery_json" | jq -r '.schema_version // empty')
  if [[ "$schema" != "$TRACKER_DISCOVERY_VERSION" ]]; then
    echo "Error: expected schema_version ${TRACKER_DISCOVERY_VERSION} after input resolution." >&2
    return 1
  fi

  local -a mp_ids=() mp_titles=()
  _bootstrap_collect_mp_index "$mp"
  mp_ids=("${_BOOTSTRAP_MP_IDS[@]}")
  mp_titles=("${_BOOTSTRAP_MP_TITLES[@]}")
  local mp_has_backlog=0
  [[ ${#mp_ids[@]} -gt 0 ]] && mp_has_backlog=1

  local -a classified=()
  local item_json disposition draft_n=0 draft_id backlog_row task_hint title provider external_ref
  while IFS= read -r item_json; do
    [[ -z "$item_json" ]] && continue
    if unsafe=$(_tracker_unsafe_reason "$(echo "$item_json" | jq -r '.title + (.body_excerpt // "")')"); then
      disposition="unsupported"
      draft_id=""
      backlog_row=""
      task_hint=""
    else
      disposition=$(_bootstrap_classify_item "$item_json" "$mp_has_backlog" "${mp_titles[@]}")
      draft_id=""
      backlog_row=""
      task_hint=""
      if [[ "$disposition" == "new_external" || "$disposition" == "repo_plan" ]]; then
        draft_n=$((draft_n + 1))
        draft_id=$(_bootstrap_next_draft_id "$draft_n")
        title=$(echo "$item_json" | jq -r '.title // "Untitled"')
        provider=$(echo "$item_json" | jq -r '.provider // "other"')
        external_ref=$(echo "$item_json" | jq -r '.external_ref // ""')
        local item_type="Feature"
        [[ "$title" =~ ^[Ff]ix:|[Bb]ug ]] && item_type="Bug"
        [[ "$title" =~ ^[Cc]hore:|[Ss]pike ]] && item_type="Chore"
        backlog_row="| ${draft_id} | ${title} | ${item_type} | M | DEV-003 | P2 | ⬜ Backlog — from ${provider} ${external_ref} |"
        task_hint="/agtoosa-task feature \"${title}\" --id ${draft_id}"
      fi
    fi
    classified+=("$(jq -nc \
      --argjson item "$item_json" \
      --arg disposition "$disposition" \
      --arg draft_id "$draft_id" \
      --arg backlog_row "$backlog_row" \
      --arg task_hint "$task_hint" \
      --arg external_ref "$(echo "$item_json" | jq -r '.external_ref // ""')" \
      --arg provider "$(echo "$item_json" | jq -r '.provider // ""')" \
      --arg title "$(echo "$item_json" | jq -r '.title // ""')" \
      '$item + {
        disposition: $disposition,
        draft_id: (if $draft_id == "" then null else $draft_id end),
        backlog_row: $backlog_row,
        task_hint: $task_hint,
        external_ref: $external_ref,
        provider: $provider,
        title: $title
      }')")
  done < <(echo "$discovery_json" | jq -c '.items[]?')

  local classified_json='[]'
  if [[ ${#classified[@]} -gt 0 ]]; then
    classified_json=$(printf '%s\n' "${classified[@]}" | jq -s .)
  fi

  local generated_at
  generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
  mkdir -p "$(dirname "$output_path")"
  _bootstrap_render_proposal "$discovery_json" "$classified_json" "$generated_at" >"$output_path"
  echo "Tracker bootstrap proposal written: $output_path"
  return 0
}

tracker_status_check() {
  local project_path="$1" output_path="${2:-}"
  _tracker_require_jq || return 1

  local mp
  mp=$(_tracker_find_master_plan "$project_path") || return 1

  local signals items='[]' merged_inputs='["local"]'
  local gh_cache="${project_path}/${TRACKER_CACHE_GH_REL}"
  local lin_cache="${project_path}/${TRACKER_CACHE_LINEAR_REL}"
  local has_tracker_signals=0
  local generated_at project_resolved

  signals=$(_discover_scan_signals "$project_path")
  items=$(_discover_repo_plan_items "$project_path")
  generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
  project_resolved=$(_tracker_resolve_path "$project_path")

  if [[ "$(echo "$signals" | jq 'length')" -gt 0 ]]; then
    has_tracker_signals=1
  fi

  if [[ -f "$gh_cache" ]]; then
    local merge_json gh_items
    merge_json=$(_tracker_load_bounded_json "$gh_cache") || return 1
    gh_items=$(github_issues_items_from_fetch "$merge_json") || return 1
    items=$(discovery_merge_items "$items" "$gh_items")
    merged_inputs=$(echo "$merged_inputs" | jq -c --arg p "$TRACKER_CACHE_GH_REL" '. + [$p]')
    has_tracker_signals=1
  fi

  if [[ -f "$lin_cache" ]]; then
    local merge_json lin_items
    merge_json=$(_tracker_load_bounded_json "$lin_cache") || return 1
    lin_items=$(linear_items_from_fetch "$merge_json") || return 1
    items=$(discovery_merge_items "$items" "$lin_items")
    merged_inputs=$(echo "$merged_inputs" | jq -c --arg p "$TRACKER_CACHE_LINEAR_REL" '. + [$p]')
    has_tracker_signals=1
  fi

  local item_count
  item_count=$(echo "$items" | jq 'length')
  if [[ "$item_count" -gt $TRACKER_MAX_DISCOVERY_ITEMS ]]; then
    echo "Error: status-check items exceed bound (${TRACKER_MAX_DISCOVERY_ITEMS})." >&2
    return 1
  fi

  _bootstrap_collect_mp_index "$mp"
  local mp_has_backlog=0
  [[ ${#_BOOTSTRAP_MP_IDS[@]} -gt 0 ]] && mp_has_backlog=1

  local mirror_skip=0 new_ext=0 repo_plan=0 closed_ext=0 unchanged=0 unsupported=0
  local -a unlinked_items=()
  local item_json disposition

  while IFS= read -r item_json; do
    [[ -z "$item_json" ]] && continue
    if unsafe=$(_tracker_unsafe_reason "$(echo "$item_json" | jq -r '.title + (.body_excerpt // "")')"); then
      unsupported=$((unsupported + 1))
      continue
    fi
    disposition=$(_bootstrap_classify_item "$item_json" "$mp_has_backlog" "${_BOOTSTRAP_MP_TITLES[@]}")
    case "$disposition" in
      mirror_skip) mirror_skip=$((mirror_skip + 1)) ;;
      new_external)
        new_ext=$((new_ext + 1))
        unlinked_items+=("$item_json")
        ;;
      repo_plan) repo_plan=$((repo_plan + 1)) ;;
      closed_external) closed_ext=$((closed_ext + 1)) ;;
      unchanged) unchanged=$((unchanged + 1)) ;;
      *) unsupported=$((unsupported + 1)) ;;
    esac
  done < <(echo "$items" | jq -c '.[]?')

  local unlinked_json='[]' sample_refs='[]' emit=0 severity="info"
  if [[ ${#unlinked_items[@]} -gt 0 ]]; then
    unlinked_json=$(printf '%s\n' "${unlinked_items[@]}" | jq -s .)
    sample_refs=$(echo "$unlinked_json" | jq '[.[].external_ref] | .[0:5]')
  fi
  if [[ "$has_tracker_signals" -eq 1 && "$new_ext" -gt 0 ]]; then
    emit=1
  fi

  local counts_json finding_json envelope
  counts_json=$(jq -nc \
    --argjson mirror_skip "$mirror_skip" \
    --argjson new_external "$new_ext" \
    --argjson repo_plan "$repo_plan" \
    --argjson closed_external "$closed_ext" \
    --argjson unchanged "$unchanged" \
    --argjson unsupported "$unsupported" \
    '{mirror_skip: $mirror_skip, new_external: $new_external, repo_plan: $repo_plan, closed_external: $closed_external, unchanged: $unchanged, unsupported: $unsupported}')

  finding_json=$(jq -nc \
    --argjson emit "$emit" \
    --arg severity "$severity" \
    --argjson count "$new_ext" \
    --argjson sample_refs "$sample_refs" \
    '{emit: ($emit == 1), severity: $severity, count: $count, sample_refs: $sample_refs}')

  envelope=$(jq -nc \
    --arg schema_version "$TRACKER_STATUS_CHECK_VERSION" \
    --arg generated_at "$generated_at" \
    --arg project_path "$project_resolved" \
    --argjson has_tracker_signals "$([[ "$has_tracker_signals" -eq 1 ]] && echo true || echo false)" \
    --argjson merged_inputs "$merged_inputs" \
    --argjson counts "$counts_json" \
    --argjson unlinked_external "$unlinked_json" \
    --argjson finding "$finding_json" \
    '{
      schema_version: $schema_version,
      generated_at: $generated_at,
      project_path: $project_path,
      has_tracker_signals: $has_tracker_signals,
      merged_inputs: $merged_inputs,
      counts: $counts,
      unlinked_external: $unlinked_external,
      finding: $finding
    }')

  if [[ -n "$output_path" ]]; then
    mkdir -p "$(dirname "$output_path")"
    printf '%s\n' "$envelope" >"$output_path"
    echo "Tracker status-check written: $output_path (${new_ext} unlinked external)" >&2
  else
    printf '%s\n' "$envelope"
  fi
  return 0
}
