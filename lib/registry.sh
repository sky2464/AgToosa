#!/usr/bin/env bash

# ── AgToosa: registry helpers ──────────────────────────────────
# Sourced by agtoosa.sh for --registry mode.
# Implements pack discovery, download, verification, and staging.
# Globals read: SCRIPT_DIR, SHIP_DIR, PACK_QUEUE_DIR, colors.
# Globals modified: none directly.

_ensure_pack_queue_dir() {
  mkdir -p "$PACK_QUEUE_DIR"
}

# Move legacy ship/packs/* into the durable queue before ship/ is wiped.
_salvage_ship_packs_to_queue() {
  local legacy="${SHIP_DIR}/packs"
  [[ -d "$legacy" ]] || return 0
  _ensure_pack_queue_dir
  local pack_dir pname dest
  for pack_dir in "${legacy}"/*/; do
    [[ -d "$pack_dir" ]] || continue
    pname=$(basename "$pack_dir")
    dest="${PACK_QUEUE_DIR}/${pname}"
    rm -rf "$dest"
    mv "$pack_dir" "$dest"
  done
  rmdir "$legacy" 2>/dev/null || true
}

_pack_queue_dir_for() {
  local pack_name="$1"
  _ensure_pack_queue_dir
  local pack_dir="${PACK_QUEUE_DIR}/${pack_name}"
  rm -rf "$pack_dir"
  mkdir -p "$pack_dir"
  printf '%s' "$pack_dir"
}

_normalize_pack_dir() {
  local pack_dir="$1"
  local pack_name="$2"
  local nested="${pack_dir}/${pack_name}"
  [[ -d "$nested" ]] || return 0

  # Normalize tarballs produced with a single top-level pack directory.
  # Leave mixed layouts untouched so validation can reject or accept them as-is.
  if find "$pack_dir" -mindepth 1 -maxdepth 1 ! -name "$pack_name" ! -name ".pack-meta.json" | grep -q .; then
    return 0
  fi

  shopt -s dotglob nullglob
  local item
  for item in "$nested"/*; do
    mv "$item" "$pack_dir/"
  done
  shopt -u dotglob nullglob
  rmdir "$nested"
}

REGISTRY_URL="${AGTOOSA_REGISTRY_URL:-https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json}"
# Allow tests and offline use to override the cache location.
REGISTRY_CACHE_DIR="${AGTOOSA_REGISTRY_CACHE_DIR:-${HOME}/.cache/agtoosa}"
REGISTRY_CACHE_FILE="${REGISTRY_CACHE_DIR}/registry.json"
REGISTRY_CACHE_TIMEOUT=3600

# Destinations a pack must never write to: executable-hook and CI surfaces.
# Canonical definition lives in lib/install.sh; this guarded copy keeps
# registry.sh self-contained when sourced standalone (tests, tooling).
if ! declare -f pack_path_denied >/dev/null 2>&1; then
  PACK_DENYLIST_PATTERNS=(
    ".claude/settings.json"
    ".claude/hooks/"
    ".github/workflows/"
  )

  pack_path_denied() {
    local rel="${1#/}"
    local pat
    for pat in "${PACK_DENYLIST_PATTERNS[@]}"; do
      if [[ "$pat" == */ ]]; then
        [[ "$rel" == "$pat"* ]] && return 0
      else
        [[ "$rel" == "$pat" ]] && return 0
      fi
    done
    return 1
  }
fi

# Reject tarballs whose member list contains absolute paths or '..' segments.
# Must run BEFORE extraction — post-extract validation cannot undo a tar slip.
assert_safe_tarball() {
  local tarball="$1"
  local entries
  if ! entries=$(tar -tzf "$tarball" 2>/dev/null); then
    echo "Error: Unable to read archive member list (corrupt archive?): $tarball" >&2
    return 1
  fi
  local entry
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if [[ "$entry" == /* ]]; then
      echo "Error: Archive contains absolute path member: $entry" >&2
      return 1
    fi
    case "/$entry/" in
      */../*)
        echo "Error: Archive contains path traversal member: $entry" >&2
        return 1
        ;;
    esac
  done <<< "$entries"
  return 0
}

# Print the file tree of a staged pack with warnings for AI-instruction and
# denied destinations, so the user confirms with full knowledge of contents.
_print_pack_preview() {
  local dir="$1"
  local rel ai_count=0 denied_count=0
  echo ""
  echo "Pack contents:"
  while IFS= read -r -d '' f; do
    rel="${f#"$dir"/}"
    [[ "$rel" == ".pack-meta.json" ]] && continue
    if pack_path_denied "$rel"; then
      echo "  ⛔ $rel  (blocked: sensitive destination, will NOT be merged)"
      denied_count=$((denied_count + 1))
    elif [[ "$rel" == .claude/* || "$rel" == .cursor/* || "$rel" == .windsurf/* || \
            "$rel" == .gemini/* || "$rel" == .github/* || "$rel" == .codex/* || \
            "$rel" == "CLAUDE.md" || "$rel" == "AGENTS.md" || "$rel" == "OPENCODE.md" || \
            "$rel" == ".cursorrules" || "$rel" == ".windsurfrules" ]]; then
      echo "  ⚠️  $rel  (AI instruction surface — your assistant will follow this content)"
      ai_count=$((ai_count + 1))
    else
      echo "  •  $rel"
    fi
  done < <(find "$dir" -type f -print0 | sort -z)
  if [[ $ai_count -gt 0 ]]; then
    echo ""
    echo "⚠️  ${ai_count} file(s) target AI instruction surfaces. Review them before confirming."
  fi
  if [[ $denied_count -gt 0 ]]; then
    echo "⛔ ${denied_count} file(s) target denied destinations and will be skipped at merge."
  fi
  echo ""
}

# Compute SHA256 hash in a cross-platform way (macOS uses shasum, Linux uses sha256sum).
compute_sha256() {
  local file="$1"
  if command -v sha256sum &>/dev/null; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "Error: Neither sha256sum nor shasum found on this system." >&2
    return 1
  fi
}

validate_pack_files() {
  local dir="$1"
  local canonical_dir
  canonical_dir=$(realpath "$dir" 2>/dev/null || readlink -f "$dir" 2>/dev/null || echo "$dir")
  local allowed_exts="md json toml mdc"
  local file ext base canonical_file
  while IFS= read -r -d '' file; do
    # Path traversal guard: resolve the canonical path and assert it stays inside the pack dir.
    canonical_file=$(realpath "$file" 2>/dev/null || readlink -f "$file" 2>/dev/null || echo "$file")
    if [[ "$canonical_file" != "$canonical_dir"/* ]]; then
      echo "Error: Pack contains path traversal: $file" >&2
      return 1
    fi
    base=$(basename "$file")
    ext="${base##*.}"
    if [[ "$base" == "$ext" ]]; then
      if [[ "$base" != ".pack-meta.json" ]]; then
        echo "Error: Pack contains disallowed file type: $file (allowed: .md .json .toml .mdc)" >&2
        return 1
      fi
    else
      local ok=0
      for a in $allowed_exts; do
        if [[ "$ext" == "$a" ]]; then
          ok=1
          break
        fi
      done
      if [[ $ok -eq 0 ]]; then
        echo "Error: Pack contains disallowed file type: $file (allowed: .md .json .toml .mdc)" >&2
        return 1
      fi
    fi
  done < <(find -L "$dir" -type f -print0)
  return 0
}

# Fetch registry.json from GitHub with 1-hour cache.
# SECURITY NOTE: registry.json is trusted via HTTPS only (no signed manifest in v1).
# Pack tarballs are still SHA-256 verified against each index entry on install.
# For high-assurance or air-gapped use, set AGTOOSA_REGISTRY_CACHE_DIR to a vetted
# copy and independently verify pack SHA-256 values before installing.
fetch_registry() {
  mkdir -p "$REGISTRY_CACHE_DIR"

  # Check cache validity.
  if [[ -f "$REGISTRY_CACHE_FILE" ]]; then
    local cache_age
    cache_age=$(($(date +%s) - $(stat -f%m "$REGISTRY_CACHE_FILE" 2>/dev/null || stat -c%Y "$REGISTRY_CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $cache_age -lt $REGISTRY_CACHE_TIMEOUT ]]; then
      cat "$REGISTRY_CACHE_FILE"
      return 0
    fi
  fi

  # Fetch from remote.
  if curl -fsSL "$REGISTRY_URL" -o "$REGISTRY_CACHE_FILE"; then
    cat "$REGISTRY_CACHE_FILE"
    return 0
  else
    echo "Error: Failed to fetch registry from $REGISTRY_URL" >&2
    return 1
  fi
}

# List all packs in the registry.
registry_list() {
  local registry
  registry=$(fetch_registry) || return 1

  # Parse JSON and display packs.
  echo ""
  echo "Available packs:"
  echo ""

  # Simple JSON parsing (works with jq if available, falls back to grep/awk).
  if command -v jq &>/dev/null; then
    echo "$registry" | jq -r '.[] | "\(.name) v\(.version) — \(.description) (by \(.author))"'
  else
    # Fallback: grep-based parsing for name, version, description.
    # This is a simplified approach assuming one pack per line or basic structure.
    echo "$registry" | grep -oP '"name":\s*"\K[^"]+' | while read -r name; do
      echo "  $name"
    done
  fi
}

# Search packs by keyword.
registry_search() {
  local query="$1"
  local registry
  registry=$(fetch_registry) || return 1

  if [[ -z "$query" ]]; then
    echo "Error: search requires a keyword" >&2
    return 1
  fi

  echo ""
  echo "Search results for '$query':"
  echo ""

  if command -v jq &>/dev/null; then
    local results jq_status=0
    results=$(echo "$registry" | jq -r --arg q "$query" \
      '.[] | select((.name | test($q; "i")) or (.description | test($q; "i"))) | "\(.name) v\(.version) — \(.description) (by \(.author))"' \
      2>/dev/null) || jq_status=$?
    if [[ $jq_status -ne 0 ]] || [[ -z "$results" ]]; then
      echo "No packs found matching '$query'"
    else
      echo "$results"
    fi
  else
    # Fallback: simple grep search.
    echo "$registry" | grep -i "$query" || echo "No packs found matching '$query'"
  fi
}

# Show details of a specific pack.
registry_info() {
  local pack_name="$1"
  local registry
  registry=$(fetch_registry) || return 1

  if [[ -z "$pack_name" ]]; then
    echo "Error: info requires a pack name" >&2
    return 1
  fi

  echo ""
  echo "Pack: $pack_name"
  echo ""

  if command -v jq &>/dev/null; then
    local info_out
    info_out=$(echo "$registry" | jq -r --arg n "$pack_name" \
      '.[] | select(.name == $n) | "Name: \(.name)\nDescription: \(.description)\nAuthor: \(.author)\nVersion: \(.version)\nURL: \(.url)\nVerified: \(.verified)"')
    if [[ -z "$info_out" ]]; then
      echo "Error: Pack '$pack_name' not found in registry." >&2
      return 1
    fi
    echo "$info_out"
  else
    # Fallback: simple display.
    echo "Name: $pack_name"
    echo "For full details, see the registry at: $REGISTRY_URL"
  fi
}

# Resolve a registry JSON entry by pack name and optional version pin.
# Prints one compact JSON object on success; writes an error to stderr and returns 1 on failure.
registry_resolve_pack_entry() {
  local registry="$1"
  local pack_name="$2"
  local pack_version="${3:-}"

  if [[ -z "$pack_name" ]]; then
    echo "Error: resolve requires a pack name" >&2
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    if [[ -n "$pack_version" ]]; then
      echo "Error: --registry install with @version requires jq. Install jq and retry." >&2
      return 1
    fi
    local pack_entry
    pack_entry=$(echo "$registry" | grep "\"name\": \"$pack_name\"" || true)
    if [[ -z "$pack_entry" ]]; then
      echo "Error: Pack '$pack_name' not found in registry" >&2
      return 1
    fi
    echo "$pack_entry"
    return 0
  fi

  local pack_entry
  if [[ -n "$pack_version" ]]; then
    pack_entry=$(echo "$registry" | jq -c --arg n "$pack_name" --arg v "$pack_version" \
      '.[] | select(.name == $n and .version == $v)' | head -n1)
    if [[ -z "$pack_entry" ]]; then
      local available
      available=$(echo "$registry" | jq -r --arg n "$pack_name" \
        '.[] | select(.name == $n) | .version' | paste -sd ', ' -)
      if [[ -z "$available" ]]; then
        echo "Error: Pack '$pack_name' not found in registry" >&2
      else
        echo "Error: Pack '$pack_name' version '$pack_version' not found in registry (available: ${available})." >&2
      fi
      return 1
    fi
  else
    pack_entry=$(echo "$registry" | jq -c --arg n "$pack_name" \
      '.[] | select(.name == $n)' | head -n1)
    if [[ -z "$pack_entry" ]]; then
      echo "Error: Pack '$pack_name' not found in registry" >&2
      return 1
    fi
  fi

  echo "$pack_entry"
}

# Download and install a pack.
registry_install() {
  # Preserve ship/ so staged pack files survive the EXIT trap.
  KEEP_SHIP=true

  local pack_spec="$1"  # Can be "pack-name" or "pack-name@1.2.3" or "./local-pack"
  local pack_name pack_version

  if [[ -z "$pack_spec" ]]; then
    echo "Error: install requires a pack name" >&2
    return 1
  fi

  # Parse version if specified.
  if [[ "$pack_spec" == *"@"* ]]; then
    pack_name="${pack_spec%@*}"
    pack_version="${pack_spec#*@}"
  else
    pack_name="$pack_spec"
    pack_version=""
  fi

  # Handle local pack (offline mode): explicit path prefix or any existing directory.
  if [[ "$pack_spec" == "./"* ]] || [[ "$pack_spec" == "/"* ]] || [[ -d "$pack_spec" ]]; then
    _install_local_pack "$pack_spec"
    return $?
  fi

  # Fetch registry and find pack entry.
  local registry pack_entry pack_url pack_sha256 pack_version_resolved pack_verified
  registry=$(fetch_registry) || return 1

  pack_entry=$(registry_resolve_pack_entry "$registry" "$pack_name" "$pack_version") || return 1

  # Extract URL, SHA-256, version, and verified flag from pack entry.
  if command -v jq &>/dev/null; then
    pack_url=$(echo "$pack_entry" | jq -r '.url')
    pack_sha256=$(echo "$pack_entry" | jq -r '.sha256')
    pack_version_resolved=$(echo "$pack_entry" | jq -r '.version')
    pack_verified=$(echo "$pack_entry" | jq -r '.verified // false')
  else
    pack_url=$(echo "$pack_entry" | grep -oP '"url":\s*"\K[^"]+')
    pack_sha256=$(echo "$pack_entry" | grep -oP '"sha256":\s*"\K[^"]+')
    pack_version_resolved=$(echo "$pack_entry" | grep -oP '"version":\s*"\K[^"]+')
    pack_verified=$(echo "$pack_entry" | grep -oP '"verified":\s*\K(true|false)' || echo "false")
  fi

  if [[ -n "$pack_version" ]] && [[ "$pack_version" != "$pack_version_resolved" ]]; then
    echo "Error: Pack '$pack_name' version '$pack_version' not found in registry (available: ${pack_version_resolved})." >&2
    return 1
  fi

  # Enforce the registry verified flag. Unverified packs require explicit opt-in.
  if [[ "$pack_verified" != "true" && "${ALLOW_UNVERIFIED:-false}" != true && "${AGTOOSA_ALLOW_UNVERIFIED:-0}" != "1" ]]; then
    echo "Error: Pack '$pack_name' is not verified in the registry." >&2
    echo "Unverified packs have not passed maintainer review." >&2
    echo "To install anyway, re-run with --allow-unverified (or AGTOOSA_ALLOW_UNVERIFIED=1)." >&2
    return 1
  fi

  echo ""
  echo "Installing: $pack_name v${pack_version_resolved}"
  [[ "$pack_verified" != "true" ]] && echo "⚠️  This pack is NOT verified (installing via --allow-unverified)."

  # Download pack tarball.
  local tmpfile stage_dir pack_dir
  tmpfile=$(mktemp -d)/agtoosa-pack-$$.tar.gz
  mkdir -p "$(dirname "$tmpfile")"

  echo "Downloading $pack_name..."
  if ! curl -fsSL "$pack_url" -o "$tmpfile"; then
    echo "Error: Failed to download pack from $pack_url" >&2
    rm -rf "$(dirname "$tmpfile")"
    return 1
  fi

  # Verify SHA-256.
  echo "Verifying integrity..."
  local computed_sha256
  computed_sha256=$(compute_sha256 "$tmpfile") || {
    rm -rf "$(dirname "$tmpfile")"
    return 1
  }

  if [[ "$computed_sha256" != "$pack_sha256" ]]; then
    echo "Error: SHA-256 mismatch!" >&2
    echo "  Expected: $pack_sha256" >&2
    echo "  Got:      $computed_sha256" >&2
    rm -rf "$(dirname "$tmpfile")"
    return 1
  fi

  # Reject hostile member paths BEFORE any extraction happens.
  assert_safe_tarball "$tmpfile" || {
    rm -rf "$(dirname "$tmpfile")"
    return 1
  }

  # Extract to an isolated staging dir first; only validated, user-confirmed
  # content ever reaches the durable pack queue.
  echo "Staging pack..."
  stage_dir=$(mktemp -d)/agtoosa-stage-$$
  mkdir -p "$stage_dir"
  tar -xzf "$tmpfile" -C "$stage_dir" || {
    echo "Error: Failed to extract pack" >&2
    rm -rf "$(dirname "$tmpfile")" "$(dirname "$stage_dir")"
    return 1
  }
  _normalize_pack_dir "$stage_dir" "$pack_name"

  validate_pack_files "$stage_dir" || {
    rm -rf "$(dirname "$tmpfile")" "$(dirname "$stage_dir")"
    return 1
  }

  # Informed-consent gate: show full file tree + AI-surface warnings.
  _print_pack_preview "$stage_dir"
  if [[ "${ASSUME_YES:-false}" == true ]]; then
    REPLY="Y"
  else
    read -p "Continue? (Y/n) " -r
  fi
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    rm -rf "$(dirname "$tmpfile")" "$(dirname "$stage_dir")"
    return 0
  fi

  pack_dir=$(_pack_queue_dir_for "$pack_name")
  cp -R "$stage_dir"/. "$pack_dir"/ || {
    echo "Error: Failed to queue pack" >&2
    rm -rf "$(dirname "$tmpfile")" "$(dirname "$stage_dir")" "$pack_dir"
    return 1
  }

  local installed_at
  installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '{\n  "name": "%s",\n  "version": "%s",\n  "sha256": "%s",\n  "installed_at": "%s",\n  "source": "registry",\n  "verified": %s\n}\n' \
    "$pack_name" "$pack_version_resolved" "$pack_sha256" "$installed_at" "$pack_verified" \
    > "${pack_dir}/.pack-meta.json"

  echo ""
  echo "✅ Pack queued at: $pack_dir"
  echo "Run 'bash agtoosa.sh' in your project to merge queued packs."
  rm -rf "$(dirname "$tmpfile")" "$(dirname "$stage_dir")"
}

# Install a local pack (offline mode).
_install_local_pack() {
  # Preserve ship/ so staged pack files survive the EXIT trap.
  KEEP_SHIP=true

  local pack_path="$1"

  if [[ ! -d "$pack_path" ]]; then
    echo "Error: Local pack directory not found: $pack_path" >&2
    return 1
  fi

  local pack_name
  pack_name=$(basename "$pack_path")

  # Validate the source and show contents before asking for consent.
  validate_pack_files "$pack_path" || return 1

  echo ""
  echo "Installing local pack: $pack_name"
  echo "⚠️  Local packs bypass registry review and SHA-256 pinning — trust the source."
  _print_pack_preview "$pack_path"
  if [[ "${ASSUME_YES:-false}" == true ]]; then
    REPLY="Y"
  else
    read -p "Continue? (Y/n) " -r
  fi
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  # Copy pack contents to queue (not the directory itself).
  local pack_dir
  pack_dir=$(_pack_queue_dir_for "$pack_name")
  cp -R "$pack_path"/. "$pack_dir"/ || {
    echo "Error: Failed to stage local pack" >&2
    return 1
  }

  validate_pack_files "$pack_dir" || {
    rm -rf "$pack_dir"
    return 1
  }

  local installed_at
  installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '{\n  "name": "%s",\n  "version": "local",\n  "sha256": "",\n  "installed_at": "%s",\n  "source": "local"\n}\n' \
    "$pack_name" "$installed_at" \
    > "${pack_dir}/.pack-meta.json"

  echo "✅ Local pack queued at: $pack_dir"
  echo "Run 'bash agtoosa.sh' in your project to merge queued packs."
}

registry_publish() {
  local pack_dir_input="${1:-}"

  echo "AgToosa Registry — Publish a Pack"
  echo ""

  # Accept directory as a positional arg; fall back to interactive prompt only
  # when stdin is a TTY. Without either, fail with usage so non-interactive
  # invocations (CI, tests) get a clear error rather than hanging on read.
  if [[ -z "$pack_dir_input" ]]; then
    if [[ -t 0 ]]; then
      read -p "Pack directory: " pack_dir_input
    else
      echo "Error: publish requires a pack directory argument." >&2
      echo "Usage: agtoosa --registry publish <pack-directory>" >&2
      return 1
    fi
  fi

  if [[ ! -d "$pack_dir_input" ]]; then
    echo "Error: Directory not found: $pack_dir_input" >&2
    return 1
  fi

  validate_pack_files "$pack_dir_input" || return 1

  local pub_name pub_desc pub_version
  read -p "Pack name: " pub_name
  read -p "Description: " pub_desc
  read -p "Version: " pub_version

  local tmptar
  tmptar=$(mktemp /tmp/agtoosa-publish-XXXXXX.tar.gz)
  tar -czf "$tmptar" -C "$(dirname "$pack_dir_input")" "$(basename "$pack_dir_input")"
  local pub_sha256
  pub_sha256=$(compute_sha256 "$tmptar")

  local pub_author
  pub_author=$(git config user.name 2>/dev/null || echo "unknown")

  echo ""
  echo "Add this entry to registry.json and open a PR at https://github.com/sky2464/agtoosa-registry:"
  echo ""

  if command -v jq &>/dev/null; then
    local pub_url
    pub_url="https://github.com/${pub_author}/${pub_name}/archive/refs/tags/v${pub_version}.tar.gz"
    jq -n \
      --arg name "$pub_name" \
      --arg description "$pub_desc" \
      --arg author "$pub_author" \
      --arg version "$pub_version" \
      --arg url "$pub_url" \
      --arg sha256 "$pub_sha256" \
      '{name: $name, description: $description, author: $author, version: $version, url: $url, sha256: $sha256, verified: false}'
  else
    printf '{\n  "name": "%s",\n  "description": "%s",\n  "author": "%s",\n  "version": "%s",\n  "url": "https://github.com/%s/%s/archive/refs/tags/v%s.tar.gz",\n  "sha256": "%s",\n  "verified": false\n}\n' \
      "$pub_name" "$pub_desc" "$pub_author" "$pub_version" \
      "$pub_author" "$pub_name" "$pub_version" \
      "$pub_sha256"
  fi

  rm -f "$tmptar"
}
