#!/usr/bin/env bash

# ── AgToosa: registry helpers ──────────────────────────────────
# Sourced by agtoosa.sh for --registry mode.
# Implements pack discovery, download, verification, and staging.
# Globals read: SCRIPT_DIR, SHIP_DIR, colors.
# Globals modified: none directly.

REGISTRY_URL="https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json"
REGISTRY_CACHE_DIR="${HOME}/.cache/agtoosa"
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
    echo "$registry" | jq -r ".[] | select(.name | test(\"$query\"; \"i\") or .description | test(\"$query\"; \"i\")) | \"\(.name) v\(.version) — \(.description) (by \(.author))\""
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
    echo "$registry" | jq -r ".[] | select(.name == \"$pack_name\") | \"Name: \(.name)\nDescription: \(.description)\nAuthor: \(.author)\nVersion: \(.version)\nURL: \(.url)\nVerified: \(.verified)\""
  else
    # Fallback: simple display.
    echo "Name: $pack_name"
    echo "For full details, see the registry at: $REGISTRY_URL"
  fi
}

# Download and install a pack.
registry_install() {
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

  # Handle local pack (offline mode).
  if [[ "$pack_spec" == "./"* ]] || [[ "$pack_spec" == "/"* ]]; then
    _install_local_pack "$pack_spec"
    return $?
  fi

  # Fetch registry and find pack entry.
  local registry pack_entry pack_url pack_sha256
  registry=$(fetch_registry) || return 1

  if command -v jq &>/dev/null; then
    pack_entry=$(echo "$registry" | jq -r ".[] | select(.name == \"$pack_name\")")
  else
    pack_entry=$(echo "$registry" | grep "\"name\": \"$pack_name\"")
  fi

  if [[ -z "$pack_entry" ]]; then
    echo "Error: Pack '$pack_name' not found in registry" >&2
    return 1
  fi

  # Extract URL and SHA-256 from pack entry.
  if command -v jq &>/dev/null; then
    pack_url=$(echo "$pack_entry" | jq -r '.url')
    pack_sha256=$(echo "$pack_entry" | jq -r '.sha256')
  else
    pack_url=$(echo "$pack_entry" | grep -oP '"url":\s*"\K[^"]+')
    pack_sha256=$(echo "$pack_entry" | grep -oP '"sha256":\s*"\K[^"]+')
  fi

  # Show confirmation prompt.
  echo ""
  echo "Installing: $pack_name"
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

  echo ""
  echo "✅ Pack staged at: $pack_dir"
  echo "Run 'bash agtoosa.sh' in your project to merge the pack files."
  rm -rf "$(dirname "$tmpfile")"
}

# Install a local pack (offline mode).
_install_local_pack() {
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

  # Copy pack to staging area.
  local pack_dir
  pack_dir="${SHIP_DIR}/packs/${pack_name}"
  mkdir -p "$pack_dir"
  cp -r "$pack_path" "$pack_dir" || {
    echo "Error: Failed to stage local pack" >&2
    return 1
  }

  echo "✅ Local pack staged at: $pack_dir"
}
