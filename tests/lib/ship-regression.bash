# Ship regression version matrix for bats (DEV-152).
# Historical release versions live here — not in tests/agtoosa.bats — so version
# pins do not rot when AGTOOSA_VERSION bumps.

_ship_regression_tsv() {
  echo "${BATS_TEST_DIRNAME}/fixtures/ship-regression-versions.tsv"
}

ship_regression_ver() {
  local story_id="$1"
  local tsv line ver
  tsv="$(_ship_regression_tsv)"
  line="$(grep -E "^${story_id}[[:space:]]" "$tsv" | head -1)"
  ver="$(echo "$line" | awk -F'\t' '{print $2}')"
  [ -n "$ver" ] || return 1
  echo "$ver"
}

ship_regression_next_ver() {
  local story_id="$1"
  local tsv line nxt
  tsv="$(_ship_regression_tsv)"
  line="$(grep -E "^${story_id}[[:space:]]" "$tsv" | head -1)"
  nxt="$(echo "$line" | awk -F'\t' '{print $3}')"
  [ -n "$nxt" ] || return 1
  echo "$nxt"
}

# Current live version from agtoosa.sh (active pin — preferred over hardcoding).
agtoosa_live_version() {
  local root="${1:-$BATS_TEST_DIRNAME/..}"
  grep -m1 'AGTOOSA_VERSION=' "$root/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

ship_regression_changelog_has() {
  local root="$1"
  local ver="$2"
  grep -qF "## [${ver}]" "$root/CHANGELOG.md"
}

ship_regression_ship_complete_mp() {
  local mp="$1"
  local log="$2"
  local ver="$3"
  grep -q "Ship complete — v${ver}" "$mp" || grep -q "Ship complete — v${ver}" "$log"
}

ship_regression_release_shipped_mp() {
  local mp="$1"
  local log="$2"
  local ver="$3"
  grep -q "Release ${ver} shipped" "$mp" || grep -q "Release ${ver} shipped" "$log"
}

ship_regression_milestone_next_mp() {
  local mp="$1"
  local log="$2"
  local next_ver="$3"
  grep -q "Milestone v${next_ver} (next)" "$mp" || grep -q "Milestone v${next_ver} (next)" "$log" || \
    grep -q "v${next_ver} (next)" "$mp" || grep -q "v${next_ver} (next)" "$log"
}

ship_regression_assert_live_pins_aligned() {
  local root="$1"
  local bash_ver ps_ver npm_ver
  bash_ver="$(agtoosa_live_version "$root")"
  ps_ver="$(grep -m1 'AGTOOSA_VERSION' "$root/agtoosa.ps1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  npm_ver="$(grep -m1 '"version"' "$root/packaging/npm/package.json" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
  [ "$bash_ver" = "$ps_ver" ]
  [ "$bash_ver" = "$npm_ver" ]
}

ship_regression_readme_hero_release() {
  ship_regression_ver README-HERO
}

ship_regression_readme_install_ref() {
  ship_regression_ver README-REF
}