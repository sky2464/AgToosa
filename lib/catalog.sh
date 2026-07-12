#!/usr/bin/env bash

# ── AgToosa: Extension and Preset Catalog ─────────────────────
# Sourced by agtoosa.sh for --catalog mode.
# Read-only discovery and non-executing preset plans; installs delegate to registry.

CATALOG_DEFAULT_PATH="${SCRIPT_DIR}/catalog/catalog.json"
CATALOG_MAX_BYTES=524288
CATALOG_MAX_ENTRIES=100
CATALOG_MAX_MEMBERS=20
CATALOG_MAX_TEXT=4096

CATALOG_ALLOWED_PLATFORMS=(
  cursor claude windsurf gemini copilot opencode codex vscode
)

_catalog_path() {
  printf '%s' "${AGTOOSA_CATALOG_PATH:-$CATALOG_DEFAULT_PATH}"
}

_catalog_require_jq() {
  if ! command -v jq &>/dev/null; then
    echo "Error: --catalog requires jq. Install jq and retry." >&2
    return 1
  fi
  return 0
}

_catalog_load_json() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "Error: Catalog file not found: $path" >&2
    return 1
  fi
  local size
  size=$(wc -c <"$path" | tr -d ' ')
  if [[ "$size" -gt $CATALOG_MAX_BYTES ]]; then
    echo "Error: Catalog file exceeds size bound (${CATALOG_MAX_BYTES} bytes)." >&2
    return 1
  fi
  local json
  json=$(cat "$path")
  if ! echo "$json" | jq -e . >/dev/null 2>&1; then
    echo "Error: Catalog file is not valid JSON: $path" >&2
    return 1
  fi
  printf '%s' "$json"
}

# Reject credential-bearing URLs and shell metacharacters in catalog strings.
_catalog_string_safe() {
  local value="$1" field="$2"
  if [[ ${#value} -gt $CATALOG_MAX_TEXT ]]; then
    echo "Error: Field '$field' exceeds text bound (${CATALOG_MAX_TEXT} chars)." >&2
    return 1
  fi
  if [[ "$value" == *$'\n'* ]]; then
    echo "Error: Field '$field' must not contain newlines." >&2
    return 1
  fi
  if [[ "$value" == *'..'* ]] || [[ "$value" == /* ]]; then
    echo "Error: Field '$field' contains a traversal path." >&2
    return 1
  fi
  if [[ "$value" =~ [\|\&\;\`\$\(\)] ]]; then
    echo "Error: Field '$field' contains shell metacharacters." >&2
    return 1
  fi
  if [[ "$value" =~ https?://[^/]*@ ]]; then
    echo "Error: Field '$field' contains credential-bearing URL." >&2
    return 1
  fi
  return 0
}

# Returns 0 when semver $1 satisfies a simple range like ">=5.0.0 <6.0.0".
_catalog_semver_satisfies() {
  local version="$1" range="$2"
  local op ver rest satisfied=1 normalized
  local -a parts=()
  normalized=$(_catalog_normalize_range "$range")
  read -r -a parts <<< "$normalized"
  local i=0
  while [[ $i -lt ${#parts[@]} ]]; do
    op="${parts[$i]}"
    [[ -z "$op" ]] && { i=$((i + 1)); continue; }
    ver="${parts[$((i + 1))]}"
  if [[ -z "$ver" ]]; then
    echo "Error: Invalid semantic-version range: $range" >&2
    return 1
  fi
  case "$op" in
    ">=")
      if version_lt "$version" "$ver"; then satisfied=0; fi
      ;;
    ">")
      if ! version_lt "$ver" "$version"; then satisfied=0; fi
      ;;
    "<=")
      if version_lt "$ver" "$version"; then satisfied=0; fi
      ;;
    "<")
      if ! version_lt "$version" "$ver"; then satisfied=0; fi
      ;;
    "="|"==")
      [[ "$version" != "$ver" ]] && satisfied=0
      ;;
    *)
      echo "Error: Invalid semantic-version range operator: $op" >&2
      return 1
      ;;
  esac
  i=$((i + 2))
  done
  [[ $satisfied -eq 1 ]]
}

_catalog_validate_semver_triplet() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

_catalog_normalize_range() {
  # Insert spaces around operators so ">=5.0.0 <6.0.0" tokenizes reliably.
  echo "$1" | sed -E 's/(>=|<=|>|<|==|=)/ \1 /g'
}

_catalog_validate_range_syntax() {
  local range="$1" field="$2"
  if [[ -z "$range" ]]; then
    echo "Error: Field '$field' requires a semantic-version range." >&2
    return 1
  fi
  local token normalized
  normalized=$(_catalog_normalize_range "$range")
  local -a parts=()
  read -r -a parts <<< "$normalized"
  for token in "${parts[@]}"; do
    [[ -z "$token" ]] && continue
    case "$token" in
      ">="|">"|"<="|"<"|"="|"==") continue ;;
    esac
    if ! _catalog_validate_semver_triplet "$token"; then
      echo "Error: Field '$field' has invalid semantic-version range: $range" >&2
      return 1
    fi
  done
  return 0
}

_catalog_registry_index() {
  if [[ -n "${AGTOOSA_CATALOG_REGISTRY_JSON:-}" ]]; then
    printf '%s' "$AGTOOSA_CATALOG_REGISTRY_JSON"
    return 0
  fi
  if [[ -f "$REGISTRY_CACHE_FILE" ]]; then
    cat "$REGISTRY_CACHE_FILE"
    return 0
  fi
  fetch_registry 2>/dev/null || return 1
}

_catalog_entry_by_id() {
  local catalog="$1" entry_id="$2"
  echo "$catalog" | jq -c --arg id "$entry_id" '.entries[] | select(.id == $id)' | head -n1
}

_catalog_project_dir() {
  printf '%s' "${AGTOOSA_CATALOG_PROJECT:-$PWD}"
}

_catalog_detect_platforms() {
  local project
  project="$(_catalog_project_dir)"
  local -a found=()
  [[ -d "$project/.cursor" ]] && found+=("cursor")
  [[ -d "$project/.claude" ]] && found+=("claude")
  [[ -d "$project/.windsurf" ]] && found+=("windsurf")
  [[ -d "$project/.gemini" ]] && found+=("gemini")
  [[ -d "$project/.github" ]] && found+=("copilot")
  [[ -d "$project/.codex" ]] && found+=("opencode")
  if [[ ${#found[@]} -eq 0 && -n "${AGTOOSA_CATALOG_PLATFORMS:-}" ]]; then
    IFS=',' read -r -a found <<< "$AGTOOSA_CATALOG_PLATFORMS"
  fi
  printf '%s\n' "${found[@]}"
}

_catalog_project_version() {
  local project
  project="$(_catalog_project_dir)"
  if [[ -n "${AGTOOSA_CATALOG_VERSION:-}" ]]; then
    printf '%s' "$AGTOOSA_CATALOG_VERSION"
    return 0
  fi
  if [[ -f "$project/Docs/.agtoosa-version" ]]; then
    cat "$project/Docs/.agtoosa-version"
    return 0
  fi
  printf '%s' "$AGTOOSA_VERSION"
}

_catalog_project_capabilities() {
  local project
  project="$(_catalog_project_dir)"
  if [[ -n "${AGTOOSA_CATALOG_CAPABILITIES:-}" ]]; then
    printf '%s' "$AGTOOSA_CATALOG_CAPABILITIES"
    return 0
  fi
  if [[ -d "$project/.agtoosa/pack-queue" ]]; then
    find "$project/.agtoosa/pack-queue" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; \
      | paste -sd ',' -
    return 0
  fi
  printf ''
}

_catalog_compare_registry_snapshot() {
  local extension="$1" registry="$2"
  local name version source sha sig verified
  name=$(echo "$extension" | jq -r '.provenance.registry_name')
  version=$(echo "$extension" | jq -r '.provenance.version')
  source=$(echo "$extension" | jq -r '.provenance.source')
  sha=$(echo "$extension" | jq -r '.provenance.sha256')
  sig=$(echo "$extension" | jq -r '.provenance.signature // "not-present"')
  verified=$(echo "$extension" | jq -r '.trust.registry_verified_snapshot')

  local row
  row=$(echo "$registry" | jq -c --arg n "$name" --arg v "$version" \
    '.[] | select(.name == $n and .version == $v)' | head -n1)
  if [[ -z "$row" ]]; then
    echo "stale|registry row missing for ${name}@${version}"
    return 1
  fi

  local r_url r_sha r_verified r_sig
  r_url=$(echo "$row" | jq -r '.url')
  r_sha=$(echo "$row" | jq -r '.sha256')
  r_verified=$(echo "$row" | jq -r '.verified')
  r_sig=$(echo "$row" | jq -r '.signature // "not-present"')

  if [[ "$source" != "$r_url" || "$sha" != "$r_sha" || "$verified" != "$r_verified" || "$sig" != "$r_sig" ]]; then
    echo "stale|catalog provenance differs from registry (registry is authoritative)"
    return 1
  fi
  echo "current|matches registry index"
  return 0
}

_catalog_evaluate_compatibility() {
  local entry="$1"
  local reasons=() status="compatible"
  local lifecycle agtoosa_range
  local project
  project="$(_catalog_project_dir)"
  lifecycle=$(echo "$entry" | jq -r '.lifecycle')
  if [[ "$lifecycle" == "deprecated" ]]; then
    reasons+=("lifecycle is deprecated")
    status="incompatible"
  fi

  agtoosa_range=$(echo "$entry" | jq -r '.compatibility.agtoosa')
  local proj_ver
  proj_ver=$(_catalog_project_version "$project")
  if ! _catalog_validate_semver_triplet "$proj_ver"; then
    echo "unknown|project AgToosa version unparseable: $proj_ver"
    return 0
  fi
  if ! _catalog_semver_satisfies "$proj_ver" "$agtoosa_range"; then
    reasons+=("AgToosa $proj_ver outside range $agtoosa_range")
    status="incompatible"
  fi

  local req_platform missing=0 p
  while IFS= read -r req_platform; do
    [[ -z "$req_platform" ]] && continue
    local found=0
    while IFS= read -r installed; do
      [[ "$installed" == "$req_platform" ]] && found=1
    done < <(_catalog_detect_platforms "$project")
    if [[ $found -eq 0 ]]; then
      reasons+=("missing platform: $req_platform")
      status="incompatible"
      missing=1
    fi
  done < <(echo "$entry" | jq -r '.compatibility.platforms[]?')

  local cap required_caps
  required_caps=$(_catalog_project_capabilities "$project")
  while IFS= read -r cap; do
    [[ -z "$cap" ]] && continue
    if [[ ",$required_caps," != *",$cap,"* ]]; then
      reasons+=("missing capability: $cap")
      status="incompatible"
    fi
  done < <(echo "$entry" | jq -r '.compatibility.requires[]?')

  while IFS= read -r cap; do
    [[ -z "$cap" ]] && continue
    if [[ ",$required_caps," == *",$cap,"* ]]; then
      reasons+=("conflicts with capability: $cap")
      status="incompatible"
    fi
  done < <(echo "$entry" | jq -r '.compatibility.conflicts[]?')

  if [[ ${#reasons[@]} -eq 0 ]]; then
    echo "compatible|meets declared compatibility"
    return 0
  fi
  local joined
  joined=$(IFS='; '; echo "${reasons[*]}")
  echo "${status}|${joined}"
}

_catalog_validate_entry_shape() {
  local entry="$1" catalog="$2"
  local kind id
  kind=$(echo "$entry" | jq -r '.kind')
  id=$(echo "$entry" | jq -r '.id')

  local forbidden
  forbidden=$(echo "$entry" | jq -r 'paths | select(.[-1] == "command" or .[-1] == "shell" or .[-1] == "exec") | join(".")' 2>/dev/null || true)
  if [[ -n "$forbidden" ]]; then
    echo "Error: Entry '$id' contains forbidden executable field." >&2
    return 1
  fi

  local required ext_fields preset_fields
  ext_fields='.id,.kind,.name,.summary,.tags,.examples,.maintainers,.support,.lifecycle,.reviewed_at,.compatibility,.trust,.provenance'
  preset_fields='.id,.kind,.name,.summary,.tags,.examples,.maintainers,.support,.lifecycle,.reviewed_at,.compatibility,.trust,.members'

  local check
  if [[ "$kind" == "extension" ]]; then
    check=$(echo "$entry" | jq -e "$ext_fields" >/dev/null 2>&1; echo $?)
  elif [[ "$kind" == "preset" ]]; then
    check=$(echo "$entry" | jq -e "$preset_fields" >/dev/null 2>&1; echo $?)
  else
    echo "Error: Entry '$id' has invalid kind (expected extension or preset)." >&2
    return 1
  fi
  if [[ "$check" -ne 0 ]]; then
    echo "Error: Entry '$id' is missing required fields." >&2
    return 1
  fi

  if [[ $(echo "$entry" | jq '.maintainers | length') -lt 1 ]]; then
    echo "Error: Entry '$id' requires at least one maintainer." >&2
    return 1
  fi
  if [[ $(echo "$entry" | jq '.examples | length') -lt 1 ]]; then
    echo "Error: Entry '$id' requires at least one example." >&2
    return 1
  fi

  local field value
  for field in id name summary support lifecycle reviewed_at; do
    value=$(echo "$entry" | jq -r --arg f "$field" '.[$f]')
    _catalog_string_safe "$value" "$field" || return 1
  done

  _catalog_validate_range_syntax "$(echo "$entry" | jq -r '.compatibility.agtoosa')" "compatibility.agtoosa" || return 1

  if [[ "$kind" == "extension" ]]; then
    for field in registry_name version source sha256 signature; do
      value=$(echo "$entry" | jq -r --arg f "$field" '.provenance[$f]')
      [[ "$field" == "signature" && "$value" == "null" ]] && value="not-present"
      _catalog_string_safe "$value" "provenance.$field" || return 1
    done
    if [[ -z "$(echo "$entry" | jq -r '.provenance.registry_name')" ]]; then
      echo "Error: Extension '$id' requires provenance.registry_name." >&2
      return 1
    fi
  fi

  if [[ "$kind" == "preset" ]]; then
    local member_count
    member_count=$(echo "$entry" | jq '.members | length')
    if [[ "$member_count" -lt 1 || "$member_count" -gt $CATALOG_MAX_MEMBERS ]]; then
      echo "Error: Preset '$id' member count out of bounds (1-${CATALOG_MAX_MEMBERS})." >&2
      return 1
    fi
  fi

  return 0
}

catalog_validate() {
  local catalog_path="${1:-$(_catalog_path)}"
  _catalog_require_jq || return 1
  local catalog
  catalog=$(_catalog_load_json "$catalog_path") || return 1

  local unknown
  unknown=$(echo "$catalog" | jq -r 'keys[]' | grep -vxE 'schema_version|entries' || true)
  if [[ -n "$unknown" ]]; then
    echo "Error: Catalog contains unknown top-level keys: $unknown" >&2
    return 1
  fi

  local schema_version
  schema_version=$(echo "$catalog" | jq -r '.schema_version // empty')
  if [[ -z "$schema_version" ]]; then
    echo "Error: Catalog missing schema_version." >&2
    return 1
  fi

  local entry_count
  entry_count=$(echo "$catalog" | jq '.entries | length')
  if [[ "$entry_count" -gt $CATALOG_MAX_ENTRIES ]]; then
    echo "Error: Catalog exceeds entry bound (${CATALOG_MAX_ENTRIES})." >&2
    return 1
  fi

  local dup
  dup=$(echo "$catalog" | jq -r '[.entries[].id] | group_by(.) | map(select(length>1)) | .[0][0] // empty')
  if [[ -n "$dup" ]]; then
    echo "Error: Duplicate catalog entry id: $dup" >&2
    return 1
  fi

  local entry
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    _catalog_validate_entry_shape "$entry" "$catalog" || return 1
  done < <(echo "$catalog" | jq -c '.entries[]')

  echo "Catalog valid: $catalog_path (${entry_count} entries, schema ${schema_version})"
  return 0
}

catalog_list() {
  local catalog_path="${1:-$(_catalog_path)}"
  _catalog_require_jq || return 1
  local catalog
  catalog=$(_catalog_load_json "$catalog_path") || return 1
  catalog_validate "$catalog_path" >/dev/null || return 1

  echo ""
  echo "Catalog entries:"
  echo ""
  echo "$catalog" | jq -r '.entries | sort_by(.id)[] | "\(.id) [\(.kind)] — \(.summary) (lifecycle: \(.lifecycle))"'
}

catalog_search() {
  local query="$1" catalog_path="${2:-$(_catalog_path)}"
  if [[ -z "$query" ]]; then
    echo "Error: search requires a keyword" >&2
    return 1
  fi
  _catalog_require_jq || return 1
  local catalog
  catalog=$(_catalog_load_json "$catalog_path") || return 1
  catalog_validate "$catalog_path" >/dev/null || return 1

  echo ""
  echo "Catalog search results for '$query':"
  echo ""
  local results
  results=$(echo "$catalog" | jq -r --arg q "$query" \
    '.entries | sort_by(.id)[] | select((.id|test($q;"i")) or (.name|test($q;"i")) or (.summary|test($q;"i")) or ([.tags[]?]|tostring|test($q;"i"))) | "\(.id) [\(.kind)] — \(.summary)"')
  if [[ -z "$results" ]]; then
    echo "No catalog entries found matching '$query'"
  else
    echo "$results"
  fi
}

_catalog_print_trust() {
  local entry="$1"
  echo "Trust (separate fields — not a security guarantee):"
  echo "  Curation tier: $(echo "$entry" | jq -r '.trust.curation_tier')"
  echo "  Registry verified (catalog snapshot): $(echo "$entry" | jq -r '.trust.registry_verified_snapshot')"
  echo "  Review status: $(echo "$entry" | jq -r '.trust.review_status')"
  if [[ "$(echo "$entry" | jq -r '.kind')" == "extension" ]]; then
    echo "  Checksum (catalog snapshot): $(echo "$entry" | jq -r '.provenance.sha256')"
    echo "  Signature state (catalog snapshot): $(echo "$entry" | jq -r '.provenance.signature // "not-present"')"
  fi
}

_catalog_want_json() {
  [[ "${OUTPUT_FORMAT:-}" == "json" ]]
}

# Emit registry-info JSON for --catalog info --format json (AC-003).
_catalog_emit_info_json() {
  local entry="$1" compat_status="$2" compat_reason="$3"
  echo "$entry" | jq -c \
    --arg status "$compat_status" \
    --arg reason "$compat_reason" \
    '
    {
      id: .id,
      name: .name,
      platforms: (.compatibility.platforms // []),
      compatibility: {
        status: $status,
        reason: $reason,
        agtoosa: .compatibility.agtoosa,
        platforms: (.compatibility.platforms // []),
        requires: (.compatibility.requires // []),
        conflicts: (.compatibility.conflicts // [])
      }
    }
    + (if .kind == "extension" then {
        version: .provenance.version,
        sha256: .provenance.sha256,
        signature: (.provenance.signature // "not-present")
      } else {} end)
    '
}

catalog_info() {
  local entry_id="$1" project="${2:-$PWD}" catalog_path="${3:-$(_catalog_path)}"
  if [[ -z "$entry_id" ]]; then
    echo "Error: info requires an entry id" >&2
    return 1
  fi
  _catalog_require_jq || return 1
  local catalog entry
  catalog=$(_catalog_load_json "$catalog_path") || return 1
  catalog_validate "$catalog_path" >/dev/null || return 1
  entry=$(_catalog_entry_by_id "$catalog" "$entry_id")
  if [[ -z "$entry" ]]; then
    echo "Error: Catalog entry '$entry_id' not found." >&2
    return 1
  fi

  local compat_line compat_status compat_reason
  compat_line=$(_catalog_evaluate_compatibility "$entry")
  compat_status="${compat_line%%|*}"
  compat_reason="${compat_line#*|}"

  if _catalog_want_json; then
    _catalog_emit_info_json "$entry" "$compat_status" "$compat_reason"
    return 0
  fi

  echo ""
  echo "Catalog entry: $entry_id"
  echo "Kind: $(echo "$entry" | jq -r '.kind')"
  echo "Name: $(echo "$entry" | jq -r '.name')"
  echo "Summary: $(echo "$entry" | jq -r '.summary')"
  echo "Lifecycle: $(echo "$entry" | jq -r '.lifecycle')"
  echo "Compatibility: $compat_status ($compat_reason)"
  _catalog_print_trust "$entry"

  if [[ "$(echo "$entry" | jq -r '.kind')" == "extension" ]]; then
    local registry reconcile
    if registry=$(_catalog_registry_index 2>/dev/null); then
      reconcile=$(_catalog_compare_registry_snapshot "$entry" "$registry" || true)
      echo "Registry reconciliation: ${reconcile%%|*} (${reconcile#*|})"
    else
      echo "Registry reconciliation: unknown (registry cache unavailable)"
    fi
  fi
}

CATALOG_CYCLE_PATH=()

_catalog_cycle_dfs() {
  local node="$1" catalog_json="$2"
  local p member
  if [[ ${#CATALOG_CYCLE_PATH[@]} -gt 0 ]]; then
    for p in "${CATALOG_CYCLE_PATH[@]}"; do
      [[ "$p" == "$node" ]] && return 0
    done
  fi
  CATALOG_CYCLE_PATH+=("$node")
  while IFS= read -r member; do
    [[ -z "$member" ]] && continue
    _catalog_cycle_dfs "$member" "$catalog_json" && return 0
  done < <(echo "$catalog_json" | jq -r --arg id "$node" \
    '.entries[] | select(.id == $id and .kind == "preset") | .members[].extension_id')
  if [[ ${#CATALOG_CYCLE_PATH[@]} -gt 0 ]]; then
    unset "CATALOG_CYCLE_PATH[$((${#CATALOG_CYCLE_PATH[@]} - 1))]"
  fi
  return 1
}

_catalog_preset_has_cycle() {
  local catalog="$1" start="$2"
  CATALOG_CYCLE_PATH=()
  _catalog_cycle_dfs "$start" "$catalog"
}

catalog_plan() {
  local preset_id="$1" project="${2:-$PWD}" catalog_path="${3:-$(_catalog_path)}"
  if [[ -z "$preset_id" ]]; then
    echo "Error: plan requires a preset id" >&2
    return 1
  fi
  _catalog_require_jq || return 1
  local catalog preset
  catalog=$(_catalog_load_json "$catalog_path") || return 1
  catalog_validate "$catalog_path" >/dev/null || return 1
  preset=$(_catalog_entry_by_id "$catalog" "$preset_id")
  if [[ -z "$preset" ]]; then
    echo "Error: Catalog entry '$preset_id' not found." >&2
    return 1
  fi
  if [[ "$(echo "$preset" | jq -r '.kind')" != "preset" ]]; then
    echo "Error: plan requires a preset entry (got kind $(echo "$preset" | jq -r '.kind'))." >&2
    return 1
  fi

  if _catalog_preset_has_cycle "$catalog" "$preset_id"; then
    echo "Error: Preset '$preset_id' contains a dependency cycle." >&2
    return 1
  fi

  local registry=""
  if ! registry=$(_catalog_registry_index 2>/dev/null); then
    registry=""
  fi

  local ready=1 reasons=() commands=()
  local member_id member_entry rationale
  local -a member_ids=() conflict_tags=()
  while IFS= read -r member_id; do
    [[ -z "$member_id" ]] && continue
    member_ids+=("$member_id")
    member_entry=$(_catalog_entry_by_id "$catalog" "$member_id")
    if [[ -z "$member_entry" ]]; then
      ready=0
      reasons+=("missing member extension: $member_id")
      continue
    fi
    if [[ "$(echo "$member_entry" | jq -r '.kind')" != "extension" ]]; then
      ready=0
      reasons+=("member $member_id is not an extension")
      continue
    fi

    local compat_line compat_status
    compat_line=$(_catalog_evaluate_compatibility "$member_entry")
    compat_status="${compat_line%%|*}"
    if [[ "$compat_status" != "compatible" ]]; then
      ready=0
      reasons+=("member $member_id: ${compat_line#*|}")
    fi

    if [[ -n "$registry" ]]; then
      local reconcile
      reconcile=$(_catalog_compare_registry_snapshot "$member_entry" "$registry" || true)
      if [[ "${reconcile%%|*}" == "stale" ]]; then
        ready=0
        reasons+=("member $member_id stale: ${reconcile#*|}")
      fi
    else
      ready=0
      reasons+=("registry cache unavailable — cannot confirm install metadata")
    fi

    local pack_name pack_version
    pack_name=$(echo "$member_entry" | jq -r '.provenance.registry_name')
    pack_version=$(echo "$member_entry" | jq -r '.provenance.version')
    if [[ "$pack_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ && "$pack_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      commands+=("bash agtoosa.sh --registry install ${pack_name}@${pack_version}")
    else
      ready=0
      reasons+=("member $member_id has invalid registry pin tokens")
    fi

    local c
    while IFS= read -r c; do
      [[ -z "$c" ]] && continue
      conflict_tags+=("$c")
    done < <(echo "$member_entry" | jq -r '.compatibility.conflicts[]?')
  done < <(echo "$preset" | jq -r '.members[].extension_id')

  if [[ ${#conflict_tags[@]} -gt 0 ]]; then
    local overlap
    overlap=$(printf '%s\n' "${conflict_tags[@]}" | sort | uniq -d | head -n1)
    if [[ -n "$overlap" ]]; then
      ready=0
      reasons+=("members declare overlapping conflict: $overlap")
    fi
  fi

  # JSON mode reuses DEV-090 emit_plan_json / plan-result-v1 (AC-001, AC-006).
  if _catalog_want_json; then
    PLAN_OPERATION="install"
    PLAN_PROJECT_PATH="$(_catalog_project_dir)"
    PLAN_ACTIONS=()
    if [[ $ready -eq 1 ]]; then
      local cmd pin
      for cmd in "${commands[@]}"; do
        pin="${cmd##*install }"
        PLAN_ACTIONS+=("${pin}|manual|${cmd}")
      done
    fi
    emit_plan_json
    return 0
  fi

  echo ""
  echo "Preset plan: $preset_id"
  echo "Name: $(echo "$preset" | jq -r '.name')"
  if [[ $ready -eq 1 ]]; then
    echo "Status: ready (commands only — run each registry install separately with preview/consent)"
  else
    echo "Status: not-ready"
    local r
    for r in "${reasons[@]}"; do
      echo "  - $r"
    done
  fi
  _catalog_print_trust "$preset"
  echo ""
  echo "Install commands (non-executing plan):"
  if [[ $ready -eq 1 ]]; then
    local cmd
    for cmd in "${commands[@]}"; do
      echo "  $cmd"
    done
  else
    echo "  (withheld until plan is ready)"
  fi
  return 0
}
