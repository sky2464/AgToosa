#!/usr/bin/env bash

# ── AgToosa: registry helpers ──────────────────────────────────
# Sourced by agtoosa.sh for --registry mode.
# Implements pack discovery, download, verification, and staging.
# Globals read: SCRIPT_DIR, SHIP_DIR, colors.
# Globals modified: none directly.

REGISTRY_URL="https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json"
# Allow tests and offline use to override the cache location.
REGISTRY_CACHE_DIR="${AGTOOSA_REGISTRY_CACHE_DIR:-${HOME}/.cache/agtoosa}"
REGISTRY_CACHE_FILE="${REGISTRY_CACHE_DIR}/registry.json"
REGISTRY_CACHE_TIMEOUT=3600

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
  local registry pack_entry pack_url pack_sha256 pack_version_resolved
  registry=$(fetch_registry) || return 1

  pack_entry=$(registry_resolve_pack_entry "$registry" "$pack_name" "$pack_version") || return 1

  # Extract URL, SHA-256, and version from pack entry.
  if command -v jq &>/dev/null; then
    pack_url=$(echo "$pack_entry" | jq -r '.url')
    pack_sha256=$(echo "$pack_entry" | jq -r '.sha256')
    pack_version_resolved=$(echo "$pack_entry" | jq -r '.version')
  else
    pack_url=$(echo "$pack_entry" | grep -oP '"url":\s*"\K[^"]+')
    pack_sha256=$(echo "$pack_entry" | grep -oP '"sha256":\s*"\K[^"]+')
    pack_version_resolved=$(echo "$pack_entry" | grep -oP '"version":\s*"\K[^"]+')
  fi

  if [[ -n "$pack_version" ]] && [[ "$pack_version" != "$pack_version_resolved" ]]; then
    echo "Error: Pack '$pack_name' version '$pack_version' not found in registry (available: ${pack_version_resolved})." >&2
    return 1
  fi

  # Show confirmation prompt.
  echo ""
  echo "Installing: $pack_name v${pack_version_resolved}"
  read -p "Continue? (Y/n) " -r
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  # Download pack tarball.
  local tmpfile pack_dir
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

  # Extract to staging area.
  echo "Staging pack..."
  pack_dir="${SHIP_DIR}/packs/${pack_name}"
  mkdir -p "$pack_dir"
  tar -xzf "$tmpfile" -C "$pack_dir" || {
    echo "Error: Failed to extract pack" >&2
    rm -rf "$(dirname "$tmpfile")" "$pack_dir"
    return 1
  }

  validate_pack_files "$pack_dir" || {
    rm -rf "$(dirname "$tmpfile")" "$pack_dir"
    return 1
  }

  local installed_at
  installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '{\n  "name": "%s",\n  "version": "%s",\n  "sha256": "%s",\n  "installed_at": "%s",\n  "source": "registry"\n}\n' \
    "$pack_name" "$pack_version_resolved" "$pack_sha256" "$installed_at" \
    > "${pack_dir}/.pack-meta.json"

  echo ""
  echo "✅ Pack staged at: $pack_dir"
  echo "Files are staged in ship/packs/ — run 'bash agtoosa.sh' in your project to merge them."
  rm -rf "$(dirname "$tmpfile")"
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

  echo ""
  echo "Installing local pack: $pack_name"
  read -p "Continue? (Y/n) " -r
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  # Copy pack contents to staging area (not the directory itself, so files
  # land at $pack_dir/<file> rather than $pack_dir/<pack_name>/<file>).
  local pack_dir
  pack_dir="${SHIP_DIR}/packs/${pack_name}"
  mkdir -p "$pack_dir"
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

  echo "✅ Local pack staged at: $pack_dir"
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
