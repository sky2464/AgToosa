#!/usr/bin/env bash

# ── AgToosa: Docs/agtoosa-lock.json reconcile + pack SHA revalidation — DEV-093 ──
# Sourced by agtoosa.sh. Committed reproducibility surface (rev4 §5 / ADR-004).
# Operational file hashes belong in .agtoosa/state.json (lib/state.sh), not here.

lock_file_path() {
  local project_path="${1:-${PROJECT_PATH:-}}"
  printf '%s' "${project_path}/Docs/agtoosa-lock.json"
}

# Platform names from USE_* globals.
lock_selected_platforms() {
  if declare -F state_selected_platforms >/dev/null 2>&1; then
    state_selected_platforms
    return 0
  fi
  local -a names=()
  [[ "${USE_CURSOR:-false}" == true ]] && names+=("cursor")
  [[ "${USE_WINDSURF:-false}" == true ]] && names+=("windsurf")
  [[ "${USE_CLAUDE:-false}" == true ]] && names+=("claude")
  [[ "${USE_GEMINI:-false}" == true ]] && names+=("gemini")
  [[ "${USE_COPILOT:-false}" == true ]] && names+=("copilot")
  [[ "${USE_VSCODE:-false}" == true ]] && names+=("vscode")
  [[ "${USE_OPENCODE:-false}" == true ]] && names+=("opencode")
  if ((${#names[@]} > 0)); then
    printf '%s\n' "${names[@]}"
  fi
}

# Sanitize pack name for env override key (non-alnum → _).
lock_pack_env_key() {
  local name="$1"
  printf '%s' "$name" | tr -c 'A-Za-z0-9' '_'
}

# Revalidate pack SHAs from Docs/agtoosa-lock.json before state/lock write.
# Observed SHA sources (first match wins per pack):
#   1. AGTOOSA_PACK_OBSERVED_SHA_<sanitized_name> env override (tests / inject)
#   2. Skip pack when no observed source (cannot revalidate)
# On mismatch: print pack id + expected vs observed; return 1.
lock_revalidate_packs() {
  local project_path="${1:-${PROJECT_PATH:-}}"
  local lock_file
  lock_file="$(lock_file_path "$project_path")"
  [[ -f "$lock_file" ]] || return 0
  command -v jq >/dev/null 2>&1 || return 0

  local name expected observed env_key
  while IFS=$'\t' read -r name expected; do
    [[ -n "$name" && -n "$expected" && "$expected" != "null" && "$expected" != "" ]] || continue
    env_key="AGTOOSA_PACK_OBSERVED_SHA_$(lock_pack_env_key "$name")"
    observed="${!env_key:-}"
    [[ -n "$observed" ]] || continue
    if [[ "$observed" != "$expected" ]]; then
      echo "Error: pack SHA mismatch for '${name}'" >&2
      echo "  Expected: ${expected}" >&2
      echo "  Got:      ${observed}" >&2
      return 1
    fi
  done < <(jq -r '.packs[]? | select(.sha256 != null and .sha256 != "") | [.name, .sha256] | @tsv' "$lock_file")
  return 0
}

# Reconcile Docs/agtoosa-lock.json after successful apply.
# Updates agtoosa_version, generated_at, platforms from selection; preserves packs
# unless pack_json_args are provided (optional trailing JSON objects / meta files).
# Args: [project_path] [pack_meta_or_json ...]
lock_reconcile() {
  local project_path="${PROJECT_PATH:-}"
  local -a pack_args=()
  if [[ $# -gt 0 && -d "${1:-}" ]]; then
    project_path="$1"
    shift
  fi
  pack_args=("$@")

  local lock_file timestamp
  lock_file="$(lock_file_path "$project_path")"
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  mkdir -p "${project_path}/Docs"

  local -a platforms=()
  local p
  while IFS= read -r p; do
    [[ -n "$p" ]] && platforms+=("$p")
  done < <(lock_selected_platforms)

  # Prefer existing _write_lock_file when pack metas are supplied and no platforms needed
  # from older callers — here we always write ADR-004 fields including platforms[].
  local packs_json="[]"
  if command -v jq >/dev/null 2>&1; then
    if [[ -f "$lock_file" ]]; then
      packs_json="$(jq -c '.packs // []' "$lock_file" 2>/dev/null || echo '[]')"
    fi
    if [[ ${#pack_args[@]} -gt 0 ]]; then
      local entry new_packs='[]' n
      for entry in "${pack_args[@]}"; do
        if [[ -f "$entry" ]]; then
          new_packs="$(jq -c --argjson e "$(jq -c . "$entry")" '. + [$e]' <<<"$new_packs")"
        else
          new_packs="$(jq -c --argjson e "$entry" '. + [$e]' <<<"$new_packs")"
        fi
      done
      # Merge: keep existing packs whose names are not in new set; append/replace new.
      packs_json="$(jq -c --argjson existing "$packs_json" --argjson incoming "$new_packs" '
        ($incoming | map(.name)) as $names
        | ($existing | map(select(.name as $n | ($names | index($n) | not)))) + $incoming
      ')"
    fi

    local platforms_json
    platforms_json="$(printf '%s\n' "${platforms[@]+"${platforms[@]}"}" | jq -R . | jq -s -c .)"

    local tmp
    tmp="$(mktemp)"
    jq -n \
      --arg ver "${AGTOOSA_VERSION:-unknown}" \
      --arg gen "$timestamp" \
      --argjson platforms "$platforms_json" \
      --argjson packs "$packs_json" \
      '{
        agtoosa_version: $ver,
        generated_at: $gen,
        platforms: $platforms,
        packs: $packs
      }' > "$tmp"
    mv "$tmp" "$lock_file"
  else
    # Minimal non-jq fallback (platforms + empty/preserved packs not merged deeply).
    local plat_csv="" sep=""
    for p in "${platforms[@]+"${platforms[@]}"}"; do
      plat_csv+="${sep}\"${p}\""
      sep=', '
    done
    printf '{\n  "agtoosa_version": "%s",\n  "generated_at": "%s",\n  "platforms": [%s],\n  "packs": []\n}\n' \
      "${AGTOOSA_VERSION:-unknown}" "$timestamp" "$plat_csv" > "$lock_file"
  fi

  if [[ -n "${GREEN:-}" ]]; then
    echo -e "  ${GREEN}✅${NC} Docs/agtoosa-lock.json updated"
  fi
}
