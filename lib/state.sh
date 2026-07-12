#!/usr/bin/env bash

# ── AgToosa: operational install state (.agtoosa/state.json) — DEV-093 ──
# Sourced by agtoosa.sh. Gitignored operational surface (rev4 §5).
# Prefer Docs/agtoosa-lock.json for committed reproducibility pins.

STATE_SCHEMA_VERSION=1

state_file_path() {
  local project_path="$1"
  printf '%s' "${project_path}/.agtoosa/state.json"
}

# Collect selected platform names from USE_* globals (same flags as install/update).
state_selected_platforms() {
  local -a names=()
  [[ "${USE_CURSOR:-false}" == true ]] && names+=("cursor")
  [[ "${USE_WINDSURF:-false}" == true ]] && names+=("windsurf")
  [[ "${USE_CLAUDE:-false}" == true ]] && names+=("claude")
  [[ "${USE_GEMINI:-false}" == true ]] && names+=("gemini")
  [[ "${USE_COPILOT:-false}" == true ]] && names+=("copilot")
  [[ "${USE_OPENCODE:-false}" == true ]] && names+=("opencode")
  printf '%s\n' "${names[@]}"
}

# SHA-256 hex digest for a file (no sha256: prefix).
state_file_sha256() {
  local f="$1"
  if declare -F apply_content_sha256 >/dev/null 2>&1; then
    apply_content_sha256 "$f"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    sha256sum "$f" | awk '{print $1}'
  fi
}

# Build generated_file_hashes JSON object for relative paths under project.
# Args: project_path relpath [relpath...]
state_hash_inventory_json() {
  local project_path="$1"
  shift
  local rel path digest sep=""
  printf '{'
  for rel in "$@"; do
    [[ -n "$rel" ]] || continue
    path="${project_path}/${rel}"
    [[ -f "$path" ]] || continue
    digest="$(state_file_sha256 "$path")"
    printf '%s%s' "$sep" "$(printf '"%s":"sha256:%s"' "$rel" "$digest")"
    sep=','
  done
  printf '}'
}

# Read packs array JSON from lock file (or empty array).
state_packs_json_from_lock() {
  local project_path="$1"
  local lock_file="${project_path}/Docs/agtoosa-lock.json"
  if [[ -f "$lock_file" ]] && command -v jq >/dev/null 2>&1; then
    jq -c '.packs // []' "$lock_file" 2>/dev/null || echo '[]'
  else
    echo '[]'
  fi
}

# Write .agtoosa/state.json atomically after a successful apply.
# Args: project_path apply_command [relpath ...]
# If no relpaths given, hash common Docs markers that exist.
state_write_after_apply() {
  local project_path="$1"
  local apply_command="${2:-apply}"
  shift 2
  local -a hash_paths=("$@")
  local state_file platforms_json packs_json hashes_json timestamp tmp
  local -a platforms=()

  state_file="$(state_file_path "$project_path")"
  mkdir -p "$(dirname "$state_file")"

  # Corrupt existing state: warn and recreate (FM soft path).
  if [[ -f "$state_file" ]] && command -v jq >/dev/null 2>&1; then
    if ! jq -e . "$state_file" >/dev/null 2>&1; then
      echo -e "  ${YELLOW:-}⚠️${NC:-}  Corrupt .agtoosa/state.json — recreating" >&2
    fi
  fi

  while IFS= read -r p; do
    [[ -n "$p" ]] && platforms+=("$p")
  done < <(state_selected_platforms)

  if [[ ${#hash_paths[@]} -eq 0 ]]; then
    local candidate
    for candidate in Docs/AgToosa_Build.md Docs/AgToosa_Agent.md Docs/.agtoosa-version \
      Docs/AgToosa_Update.md Docs/AgToosa_Status.md; do
      [[ -f "${project_path}/${candidate}" ]] && hash_paths+=("$candidate")
    done
    # Also hash any Docs/AgToosa_*.md present (bounded).
    if [[ -d "${project_path}/Docs" ]]; then
      while IFS= read -r -d '' f; do
        candidate="${f#"${project_path}/"}"
        local seen=false
        local h
        for h in "${hash_paths[@]+"${hash_paths[@]}"}"; do
          [[ "$h" == "$candidate" ]] && seen=true && break
        done
        [[ "$seen" == false ]] && hash_paths+=("$candidate")
      done < <(find "${project_path}/Docs" -maxdepth 1 -type f -name 'AgToosa_*.md' -print0 2>/dev/null)
    fi
  fi

  if command -v jq >/dev/null 2>&1; then
    platforms_json="$(printf '%s\n' "${platforms[@]+"${platforms[@]}"}" | jq -R . | jq -s -c .)"
  else
    platforms_json='[]'
    if [[ ${#platforms[@]} -gt 0 ]]; then
      local sep="" pl
      platforms_json='['
      for pl in "${platforms[@]}"; do
        platforms_json+="${sep}\"${pl}\""
        sep=','
      done
      platforms_json+=']'
    fi
  fi

  packs_json="$(state_packs_json_from_lock "$project_path")"
  hashes_json="$(state_hash_inventory_json "$project_path" "${hash_paths[@]+"${hash_paths[@]}"}")"
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  tmp="${state_file}.tmp.$$"
  if command -v jq >/dev/null 2>&1; then
    jq -n \
      --argjson schema "$STATE_SCHEMA_VERSION" \
      --arg ver "${AGTOOSA_VERSION:-unknown}" \
      --argjson platforms "$platforms_json" \
      --argjson packs "$packs_json" \
      --argjson hashes "$hashes_json" \
      --arg at "$timestamp" \
      --arg cmd "$apply_command" \
      '{
        schema_version: $schema,
        agtoosa_version: $ver,
        platforms: $platforms,
        packs: $packs,
        generated_file_hashes: $hashes,
        last_apply_at: $at,
        last_apply_command: $cmd
      }' > "$tmp"
  else
    printf '{\n  "schema_version": %s,\n  "agtoosa_version": "%s",\n  "platforms": %s,\n  "packs": %s,\n  "generated_file_hashes": %s,\n  "last_apply_at": "%s",\n  "last_apply_command": "%s"\n}\n' \
      "$STATE_SCHEMA_VERSION" "${AGTOOSA_VERSION:-unknown}" "$platforms_json" "$packs_json" \
      "$hashes_json" "$timestamp" "$apply_command" > "$tmp"
  fi
  mv "$tmp" "$state_file"
}
