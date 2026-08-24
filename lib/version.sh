#!/usr/bin/env bash

# ── AgToosa: version marker helpers (inject/extract/compare) ──
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

# Exit when generator is older than installed (downgrade). --force allows with warning.
assert_not_downgrade() {
  local installed="$1" generator="$2"
  [[ -z "$installed" || "$installed" == "unknown" ]] && return 0
  [[ -z "$generator" ]] && return 0

  # One-time version-scheme exception: AgToosa's versioning was renumbered
  # from the historical 2.x-5.x line down to 0.x at the 5.3.62 -> 0.3.62
  # boundary (same minor/patch cadence, major reset to 0). An install still
  # recording a version from that historical line is not being downgraded
  # when it updates into the 0.x line -- treat the crossing as a normal
  # update, not a downgrade. Scoped to AgToosa's actual historical majors
  # (1-5) so unrelated/bogus installed markers still trigger the guard.
  local installed_major="${installed%%.*}" generator_major="${generator%%.*}"
  if (( 10#${generator_major:-99} == 0 )) \
    && (( 10#${installed_major:-99} >= 1 && 10#${installed_major:-99} <= 5 )); then
    return 0
  fi

  version_lt "$generator" "$installed" || return 0

  if [[ "${FORCE:-false}" == true ]]; then
    echo -e "${YELLOW}⚠️  Warning: generator v${generator} is older than installed v${installed} (--force override).${NC}" >&2
    return 0
  fi

  echo -e "${RED}❌ Error: generator v${generator} is older than installed v${installed}.${NC}" >&2
  echo "" >&2
  echo "Update your AgToosa generator before applying to this project:" >&2
  echo "  git pull && bash agtoosa.sh   # or: brew upgrade agtoosa / npm update -g agtoosa" >&2
  echo "" >&2
  echo "Advanced: pass --force only if you intentionally need a downgrade." >&2
  exit 1
}

# Print upgrade banner line for installed → generator versions.
print_upgrade_banner() {
  local installed="$1" generator="$2"
  if [[ "$installed" == "$generator" ]]; then
    echo -e "${PURPLE}${BOLD}Refreshing AgToosa v${installed}${NC}"
  else
    echo -e "${PURPLE}${BOLD}Upgrading AgToosa v${installed} → v${generator}${NC}"
  fi
}
