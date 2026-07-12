#!/usr/bin/env bash

# ── AgToosa: Tracker Sync Bridge (DEV-051) ────────────────────
# Provider-neutral export and proposal-only import. Sourced by agtoosa.sh.
# Master-Plan.md remains authoritative; no automatic apply.

TRACKER_SCHEMA_VERSION="agtoosa.tracker-bridge/v1"
TRACKER_MAX_BYTES=1048576
TRACKER_MAX_CHANGES=100
TRACKER_ALLOWED_FIELDS=(title epic status estimate)
TRACKER_RETURN_KEYS=(schema_version base_export_id provider changes)

_tracker_require_jq() {
  if ! command -v jq &>/dev/null; then
    echo "Error: tracker bridge requires jq. Install jq and retry." >&2
    return 1
  fi
  return 0
}

_tracker_sha256_string() {
  if command -v sha256sum &>/dev/null; then
    printf '%s' "$1" | sha256sum | awk '{print $1}'
  elif command -v shasum &>/dev/null; then
    printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
  else
    echo "Error: Neither sha256sum nor shasum found on this system." >&2
    return 1
  fi
}

_tracker_resolve_path() {
  local path="$1"
  realpath "$path" 2>/dev/null || readlink -f "$path" 2>/dev/null || printf '%s' "$path"
}

_tracker_find_master_plan() {
  local project="$1"
  if [[ -f "$project/docs/Master-Plan.md" ]]; then
    printf '%s/docs/Master-Plan.md' "$project"
    return 0
  fi
  if [[ -f "$project/Docs/Master-Plan.md" ]]; then
    printf '%s/Docs/Master-Plan.md' "$project"
    return 0
  fi
  echo "Error: Master-Plan.md not found under docs/ or Docs/ in $project" >&2
  return 1
}

_tracker_docs_prefix() {
  local mp="$1"
  if [[ "$mp" == */Docs/Master-Plan.md ]]; then
    printf 'Docs'
  else
    printf 'docs'
  fi
}

_tracker_section_body() {
  local mp="$1" heading="$2"
  awk -v h="$heading" '
    $0 ~ "^## " h { found=1; next }
    found && /^## / { exit }
    found { print }
  ' "$mp"
}

_tracker_find_spec_path() {
  local project="$1" prefix="$2" story_id="$3"
  local candidate
  for candidate in \
    "$project/$prefix/archived/spec-${story_id}.md" \
    "$project/$prefix/spec-${story_id}.md"; do
  if [[ -f "$candidate" ]]; then
    printf '%s' "${candidate#"$project/"}"
    return 0
  fi
  done
  printf ''
}

_tracker_ac_refs_from_spec() {
  local project="$1" spec_rel="$2"
  local spec_file="$project/$spec_rel"
  [[ -f "$spec_file" ]] || return 0
  grep -oE 'AC-[0-9]{3}' "$spec_file" 2>/dev/null | sort -u
}

_tracker_parse_table_row() {
  local line="$1" layout="$2"
  echo "$line" | awk -F'|' -v layout="$layout" '
    function trim(s) {
      sub(/^[ \t]+/, "", s)
      sub(/[ \t]+$/, "", s)
      return s
    }
    NF < 3 { exit 1 }
    {
      id = trim($2)
      if (id !~ /^DEV-/) exit 1
      title = trim($3)
      if (layout == "active") {
        estimate = trim($5)
        status = trim($6)
        epic = ""
      } else {
        estimate = trim($5)
        epic = trim($6)
        status = trim($8)
      }
      printf "%s|%s|%s|%s|%s\n", id, title, epic, status, estimate
    }'
}

_tracker_collect_story_rows() {
  local mp="$1" layout="$2"
  local body line kind
  if [[ "$layout" == "Active Cycle" ]]; then
    kind="active"
  else
    kind="backlog"
  fi
  body=$(_tracker_section_body "$mp" "$layout")
  while IFS= read -r line; do
    [[ "$line" =~ ^\|[[:space:]]*DEV- ]] || continue
    [[ "$line" =~ ^\|[[:space:]]*[-:]+ ]] && continue
    _tracker_parse_table_row "$line" "$kind" || continue
  done <<< "$body"
}

normalize_story() {
  local project="$1" prefix="$2" row="$3"
  local story_id title epic status estimate spec_path ac_json='[]' ac_csv
  IFS='|' read -r story_id title epic status estimate <<< "$row"
  spec_path=$(_tracker_find_spec_path "$project" "$prefix" "$story_id")
  if ac_csv=$(_tracker_ac_refs_from_spec "$project" "$spec_path") && [[ -n "$ac_csv" ]]; then
    ac_json=$(printf '%s\n' "$ac_csv" | jq -R . | jq -s .)
  fi
  jq -nc \
    --arg story_id "$story_id" \
    --arg title "$title" \
    --arg epic "$epic" \
    --arg status "$status" \
    --arg estimate "$estimate" \
    --arg spec_path "$spec_path" \
    --argjson acceptance_criteria_refs "$ac_json" \
    '{
      story_id: $story_id,
      title: $title,
      epic: $epic,
      status: $status,
      estimate: $estimate,
      spec_path: $spec_path,
      acceptance_criteria_refs: $acceptance_criteria_refs
    }'
}

_tracker_deduped_story_rows() {
  local mp="$1"
  {
    while IFS= read -r row; do
      [[ -z "$row" ]] && continue
      printf '0|%s\n' "$row"
    done < <(_tracker_collect_story_rows "$mp" "Active Cycle")
    while IFS= read -r row; do
      [[ -z "$row" ]] && continue
      printf '1|%s\n' "$row"
    done < <(_tracker_collect_story_rows "$mp" "Backlog")
  } | awk -F'|' '!seen[$2]++ { sub(/^[^|]*\|/, ""); print }' | sort -t'|' -k1,1
}

_tracker_build_stories_json() {
  local project="$1" mp="$2"
  local prefix row story_json
  prefix=$(_tracker_docs_prefix "$mp")

  local -a rows=()
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    rows+=("$row")
  done < <(_tracker_deduped_story_rows "$mp")

  if [[ ${#rows[@]} -eq 0 ]]; then
    printf '[]'
    return 0
  fi

  local -a story_objs=()
  for row in "${rows[@]}"; do
    story_objs+=("$(normalize_story "$project" "$prefix" "$row")")
  done
  printf '%s\n' "${story_objs[@]}" | jq -s .
}

source_digest() {
  local master_plan_sha256="$1" stories_json="$2"
  local payload
  payload=$(jq -nc \
    --arg master_plan_sha256 "$master_plan_sha256" \
    --argjson stories "$stories_json" \
    '{master_plan_sha256: $master_plan_sha256, stories: $stories}')
  _tracker_sha256_string "$payload"
}

_tracker_load_bounded_json() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "Error: Input file not found: $path" >&2
    return 1
  fi
  local size
  size=$(wc -c <"$path" | tr -d ' ')
  if [[ "$size" -gt $TRACKER_MAX_BYTES ]]; then
    echo "Error: Tracker input exceeds size bound (${TRACKER_MAX_BYTES} bytes)." >&2
    return 1
  fi
  local json
  json=$(cat "$path")
  if ! echo "$json" | jq -e . >/dev/null 2>&1; then
    echo "Error: Tracker input is not valid JSON: $path" >&2
    return 1
  fi
  printf '%s' "$json"
}

_tracker_field_allowed() {
  local field="$1" allowed
  for allowed in "${TRACKER_ALLOWED_FIELDS[@]}"; do
    [[ "$field" == "$allowed" ]] && return 0
  done
  return 1
}

# Returns 0 when unsafe; prints reason to stdout (never echoes the secret value).
_tracker_unsafe_reason() {
  local value="$1"
  if printf '%s' "$value" | grep -q '[[:cntrl:]]' 2>/dev/null; then
    printf 'control characters'
    return 0
  fi
  if [[ "$value" == /* ]]; then
    printf 'absolute local path'
    return 0
  fi
  if [[ "$value" =~ https?://[^/]*@ ]]; then
    printf 'credential-bearing URL'
    return 0
  fi
  if [[ "$value" =~ (^|[^A-Za-z0-9_])(token|api[_-]?key|password|secret|bearer)[[:space:]:=] ]]; then
    printf 'credential-like token'
    return 0
  fi
  return 1
}

validate_tracker_envelope() {
  local json="$1"
  local schema_version base_export_id provider change_count
  schema_version=$(echo "$json" | jq -r '.schema_version // empty')
  if [[ "$schema_version" != "$TRACKER_SCHEMA_VERSION" ]]; then
    echo "rejected|invalid schema_version" >&2
    return 1
  fi

  local unknown
  unknown=$(echo "$json" | jq -r 'keys[]' | while read -r k; do
    local ok=0 key
    for key in "${TRACKER_RETURN_KEYS[@]}"; do
      [[ "$k" == "$key" ]] && ok=1
    done
    [[ $ok -eq 0 ]] && printf '%s\n' "$k"
  done)
  if [[ -n "$unknown" ]]; then
    echo "rejected|unsupported top-level keys" >&2
    return 1
  fi

  base_export_id=$(echo "$json" | jq -r '.base_export_id // empty')
  if [[ -z "$base_export_id" ]]; then
    echo "rejected|missing base_export_id" >&2
    return 1
  fi
  provider=$(echo "$json" | jq -r '.provider // empty')
  if [[ -z "$provider" ]]; then
    echo "rejected|missing provider" >&2
    return 1
  fi

  change_count=$(echo "$json" | jq '.changes | length')
  if [[ "$change_count" -gt $TRACKER_MAX_CHANGES ]]; then
    echo "rejected|changes exceed bound (${TRACKER_MAX_CHANGES})" >&2
    return 1
  fi

  local bad_change
  bad_change=$(echo "$json" | jq -r '.changes[]? | select(.story_id == null or .field == null or .proposed_value == null) | "incomplete"' | head -n1)
  if [[ "$bad_change" == "incomplete" ]]; then
    echo "rejected|incomplete change record" >&2
    return 1
  fi

  local extra_field
  extra_field=$(echo "$json" | jq -r '.changes[]? | keys[]' | while read -r f; do
    if [[ "$f" != "story_id" && "$f" != "field" && "$f" != "proposed_value" && "$f" != "external_ref" && "$f" != "observed_at" && "$f" != "rationale" ]]; then
      printf '%s\n' "$f"
    fi
  done | head -n1)
  if [[ -n "$extra_field" ]]; then
    echo "rejected|change contains unrecognized key (value withheld)" >&2
    return 1
  fi

  return 0
}

_tracker_story_field_value() {
  local stories_json="$1" story_id="$2" field="$3"
  echo "$stories_json" | jq -r --arg id "$story_id" --arg f "$field" \
    '.[] | select(.story_id == $id) | .[$f] // empty' | head -n1
}

_tracker_render_proposal() {
  local provider="$1" base_export_id="$2" current_export_id="$3" stale="$4" items_json="$5"
  local generated_at
  generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  {
    echo "# Tracker Sync Proposal"
    echo ""
    echo "> Schema: \`${TRACKER_SCHEMA_VERSION}\`"
    echo "> Provider: \`${provider}\`"
    echo "> Base export ID: \`${base_export_id}\`"
    echo "> Current export ID: \`${current_export_id}\`"
    echo "> Generated: \`${generated_at}\`"
    echo ""
    echo "**Authority:** Master-Plan values are authoritative. Accept external suggestions via \`/agtoosa-task\`, \`/agtoosa-spec amend\`, or explicit human edit only."
    echo ""
    if [[ "$stale" == "1" ]]; then
      echo "> **Stale envelope:** base export ID does not match the current repo snapshot. Run a fresh export before applying proposals."
      echo ""
    fi
    echo "## Summary"
    echo ""
    echo "| Story | Field | Disposition | Current (authoritative) | Proposed (external) |"
    echo "|-------|-------|-------------|-------------------------|---------------------|"
    echo "$items_json" | jq -r '.[] | "| \(.story_id) | \(.field) | \(.disposition) | \(.current_value) | \(.proposed_value) |"'
    echo ""
    echo "$items_json" | jq -r '.[] | "### \(.story_id) — \(.field)\n\n- **Disposition:** \(.disposition)\n\(if .reason != "" then "- **Reason:** \(.reason)\n" else "" end)- **Current (authoritative):** \(.current_value)\n- **Proposed (external):** \(.proposed_value)\n"'
  }
}

tracker_export() {
  local project_path="$1" output_path="$2"
  _tracker_require_jq || return 1

  local mp prefix stories_json master_sha export_id commit repo_path generated_at envelope
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  prefix=$(_tracker_docs_prefix "$mp")
  master_sha=$(compute_sha256 "$mp") || return 1
  stories_json=$(_tracker_build_stories_json "$project_path" "$mp")
  export_id=$(source_digest "$master_sha" "$stories_json") || return 1

  commit=""
  if command -v git &>/dev/null && git -C "$project_path" rev-parse HEAD &>/dev/null; then
    commit=$(git -C "$project_path" rev-parse HEAD 2>/dev/null || true)
  fi
  repo_path="${mp%/$prefix/Master-Plan.md}"
  generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

  envelope=$(jq -nc \
    --arg schema_version "$TRACKER_SCHEMA_VERSION" \
    --arg export_id "$export_id" \
    --arg generated_at "$generated_at" \
    --arg repository "$repo_path" \
    --arg master_plan_path "${mp#"$project_path"/}" \
    --arg master_plan_sha256 "$master_sha" \
    --arg commit "$commit" \
    --argjson stories "$stories_json" \
    '{
      schema_version: $schema_version,
      export_id: $export_id,
      generated_at: $generated_at,
      repository: $repository,
      source: {
        master_plan_path: $master_plan_path,
        master_plan_sha256: $master_plan_sha256,
        commit: (if $commit == "" then null else $commit end)
      },
      stories: $stories
    }')

  mkdir -p "$(dirname "$output_path")"
  printf '%s\n' "$envelope" >"$output_path"
  echo "Tracker export written: $output_path (${export_id})"
  return 0
}

tracker_propose() {
  local project_path="$1" input_path="$2" output_path="$3"
  _tracker_require_jq || return 1

  local mp master_sha stories_json current_export_id
  mp=$(_tracker_find_master_plan "$project_path") || return 1
  master_sha=$(compute_sha256 "$mp") || return 1
  stories_json=$(_tracker_build_stories_json "$project_path" "$mp")
  current_export_id=$(source_digest "$master_sha" "$stories_json") || return 1

  local mp_resolved out_resolved
  mp_resolved=$(_tracker_resolve_path "$mp")
  out_resolved=$(_tracker_resolve_path "$output_path")
  if [[ "$out_resolved" == "$mp_resolved" ]]; then
    echo "Error: Proposal output must not target Master-Plan.md." >&2
    return 1
  fi

  local json
  json=$(_tracker_load_bounded_json "$input_path") || return 1

  local envelope_status=0
  validate_tracker_envelope "$json" || envelope_status=$?

  local base_export_id provider stale=0
  base_export_id=$(echo "$json" | jq -r '.base_export_id // empty')
  provider=$(echo "$json" | jq -r '.provider // "unknown"')
  if [[ -n "$base_export_id" && "$base_export_id" != "$current_export_id" ]]; then
    stale=1
  fi

  local -a items=()
  local change story_id field proposed current disposition reason unsafe
  while IFS= read -r change; do
    [[ -z "$change" ]] && continue
    story_id=$(echo "$change" | jq -r '.story_id')
    field=$(echo "$change" | jq -r '.field')
    proposed=$(echo "$change" | jq -r '.proposed_value')

    disposition="proposed"
    reason=""
    current=""

    if [[ $envelope_status -ne 0 ]]; then
      disposition="rejected"
      reason="return envelope failed validation"
    elif [[ "$stale" -eq 1 ]]; then
      disposition="stale"
      reason="base export ID does not match current repo snapshot"
    elif ! _tracker_field_allowed "$field"; then
      disposition="unsupported"
      reason="field is not supported in v1 bridge"
    elif [[ -z "$(_tracker_story_field_value "$stories_json" "$story_id" "story_id")" ]]; then
      disposition="rejected"
      reason="unknown story ID"
    elif unsafe=$(_tracker_unsafe_reason "$proposed"); then
      disposition="rejected"
      reason="unsafe proposed value (${unsafe})"
      proposed="[redacted]"
    else
      current=$(_tracker_story_field_value "$stories_json" "$story_id" "$field")
      if [[ "$proposed" == "$current" ]]; then
        disposition="unchanged"
        reason="proposed value matches authoritative repo value"
      else
        disposition="proposed"
        reason="external tracker suggests a change; repo value remains authoritative until accepted"
      fi
    fi

    items+=("$(jq -nc \
      --arg story_id "$story_id" \
      --arg field "$field" \
      --arg disposition "$disposition" \
      --arg reason "$reason" \
      --arg current_value "$current" \
      --arg proposed_value "$proposed" \
      '{story_id: $story_id, field: $field, disposition: $disposition, reason: $reason, current_value: $current_value, proposed_value: $proposed_value}')")
  done < <(echo "$json" | jq -c '.changes[]?')

  local items_json='[]'
  if [[ ${#items[@]} -gt 0 ]]; then
    items_json=$(printf '%s\n' "${items[@]}" | jq -s .)
  fi

  mkdir -p "$(dirname "$output_path")"
  _tracker_render_proposal "$provider" "$base_export_id" "$current_export_id" "$stale" "$items_json" >"$output_path"

  echo "Tracker proposal written: $output_path"
  if [[ $envelope_status -ne 0 ]]; then
    return 1
  fi
  return 0
}
