#!/usr/bin/env bash

# ── AgToosa: version marker helpers (DEV-129) ────────────────
# Sourced by agtoosa.sh. Globals: AGTOOSA_VERSION (read-only here).

# Wrap a platform entry-point file in AgToosa START/END delimiters.
inject_version() {
  local src="$1" dst="$2"
  case "$src" in
    *.md)
      {
        printf '<!-- AgToosa v%s START -->\n\n' "${AGTOOSA_VERSION}"
        cat "$src"
        printf '\n<!-- AgToosa END -->\n'
      } > "$dst"
      ;;
    *)
      {
        printf '# AgToosa v%s START\n\n' "${AGTOOSA_VERSION}"
        cat "$src"
        printf '\n# AgToosa END\n'
      } > "$dst"
      ;;
  esac
}

# Extract the AgToosa semver from an installed file (empty string if absent).
extract_version() {
  grep -m1 -oE 'AgToosa v[0-9]+\.[0-9]+\.[0-9]+' "$1" 2>/dev/null \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo ""
}

# Returns 0 (true) if semver $1 is strictly less than $2.
version_lt() {
  local a="$1" b="$2"
  [ "$a" = "$b" ] && return 1
  local a1 a2 a3 b1 b2 b3
  IFS='.' read -r a1 a2 a3 <<< "$a"
  IFS='.' read -r b1 b2 b3 <<< "$b"
  a1="${a1:-0}"; a2="${a2:-0}"; a3="${a3:-0}"
  b1="${b1:-0}"; b2="${b2:-0}"; b3="${b3:-0}"
  (( 10#$a1 < 10#$b1 )) && return 0
  (( 10#$a1 > 10#$b1 )) && return 1
  (( 10#$a2 < 10#$b2 )) && return 0
  (( 10#$a2 > 10#$b2 )) && return 1
  (( 10#$a3 < 10#$b3 )) && return 0
  return 1
}
