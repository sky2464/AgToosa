#!/usr/bin/env bash
# DEV-142 — GitHub surface audit (local file checks + optional live gh api checks).
set -euo pipefail

ROOT_DIR="${AGTOOSA_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="${AGTOOSA_SURFACE_MANIFEST:-$ROOT_DIR/docs/github-surface-manifest.json}"
MODE="local"
REPO="${GITHUB_REPOSITORY:-sky2464/AgToosa}"
FAILURES=0

usage() {
  cat <<'EOF'
Usage:
  scripts/github-surface-audit.sh [--mode local|live] [--repo owner/name] [--manifest path]

Modes:
  local  Validate manifest schema and required repository files (no network).
  live   local checks plus read-only GitHub API assertions via gh.

Examples:
  scripts/github-surface-audit.sh --mode local
  scripts/github-surface-audit.sh --mode live --repo sky2464/AgToosa

Environment:
  AGTOOSA_ROOT              Repository root override.
  AGTOOSA_SURFACE_MANIFEST  Manifest path override.
  GITHUB_REPOSITORY         Default repo for live mode.
EOF
}

pass() {
  printf 'ok - %s\n' "$1"
}

record_fail() {
  printf 'not ok - %s\n' "$1" >&2
  FAILURES=$((FAILURES + 1))
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Error: required command not found: $cmd" >&2
    exit 2
  }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -lt 2 ]] && { echo "Error: --mode requires local or live" >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    --repo)
      [[ $# -lt 2 ]] && { echo "Error: --repo requires owner/name" >&2; exit 2; }
      REPO="$2"
      shift 2
      ;;
    --manifest)
      [[ $# -lt 2 ]] && { echo "Error: --manifest requires a path" >&2; exit 2; }
      MANIFEST="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$MODE" in
  local|live) ;;
  *)
    echo "Error: unsupported mode '$MODE' (expected local or live)" >&2
    exit 2
    ;;
esac

require_cmd jq

[[ -f "$MANIFEST" ]] || {
  echo "Error: manifest not found: $MANIFEST" >&2
  exit 2
}

printf 'GitHub surface audit mode: %s\n' "$MODE"
printf 'Manifest: %s\n' "$MANIFEST"

run_local_checks() {
  local schema repo manifest_repo file label
  schema="$(jq -r '.schema_version // empty' "$MANIFEST")"
  [[ "$schema" == "agtoosa.github-surface-manifest/v1" ]] || {
    record_fail "manifest schema_version must be agtoosa.github-surface-manifest/v1 (observed '$schema')"
  }

  manifest_repo="$(jq -r '.repository // empty' "$MANIFEST")"
  [[ -n "$manifest_repo" ]] || record_fail "manifest missing repository field"
  if [[ "$manifest_repo" != "$REPO" ]]; then
    record_fail "manifest repository '$manifest_repo' does not match --repo '$REPO'"
  fi

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if [[ ! -f "$ROOT_DIR/$file" ]]; then
      record_fail "required file missing: $file"
    fi
  done < <(jq -r '.required_files[]?' "$MANIFEST")

  local config="$ROOT_DIR/.github/ISSUE_TEMPLATE/config.yml"
  if [[ -f "$config" ]]; then
    grep -q 'blank_issues_enabled: false' "$config" || \
      record_fail "ISSUE_TEMPLATE/config.yml must set blank_issues_enabled: false"
    grep -q 'security/advisories' "$config" || \
      record_fail "ISSUE_TEMPLATE/config.yml must link security advisories"
    grep -q 'discussions' "$config" || \
      record_fail "ISSUE_TEMPLATE/config.yml must link discussions"
  fi

  local funding="$ROOT_DIR/.github/FUNDING.yml"
  if [[ -f "$funding" ]]; then
    grep -q 'github:' "$funding" || record_fail "FUNDING.yml must declare github sponsors"
  fi

  local label_count
  label_count="$(jq '.labels | length' "$MANIFEST")"
  if [[ "$label_count" -lt 10 ]]; then
    record_fail "manifest labels array too small (expected TRIAGE taxonomy)"
  fi

  local projects_doc="$ROOT_DIR/.github/GITHUB-SURFACES.md"
  if [[ -f "$projects_doc" ]]; then
    grep -q 'Projects v2' "$projects_doc" || \
      record_fail "GITHUB-SURFACES.md must document Projects v2 non-goal"
    grep -q 'non-goal' "$projects_doc" || \
      record_fail "GITHUB-SURFACES.md must document explicit non-goals"
  fi

  if [[ "$FAILURES" -eq 0 ]]; then
    pass "manifest schema valid"
    pass "required repository files present"
    pass "issue template config and funding files valid"
  fi
}

run_live_checks() {
  require_cmd gh

  local owner="${REPO%%/*}"
  local name="${REPO##*/}"

  local repo_json
  repo_json="$(gh api "repos/$REPO" --jq '{
    description: .description,
    homepageUrl: .homepage_url,
    hasIssues: .has_issues,
    hasWiki: .has_wiki,
    hasDiscussions: .has_discussions,
    hasProjects: .has_projects
  }' 2>/dev/null || true)"

  local topics_json
  topics_json="$(gh api "repos/$REPO/topics" -H "Accept: application/vnd.github.mercy-preview+json" --jq '.names | sort' 2>/dev/null || echo '[]')"

  if [[ -z "$repo_json" || "$repo_json" == "null" ]]; then
    record_fail "gh api repos/$REPO failed — check auth and repo name"
    return
  fi

  local expected_desc expected_homepage
  expected_desc="$(jq -r '.about.description' "$MANIFEST")"
  expected_homepage="$(jq -r '.about.homepage_url' "$MANIFEST")"

  local observed_desc observed_homepage
  observed_desc="$(printf '%s' "$repo_json" | jq -r '.description // ""')"
  observed_homepage="$(printf '%s' "$repo_json" | jq -r '.homepageUrl // ""')"

  if [[ "$observed_desc" != "$expected_desc" ]]; then
    record_fail "About description mismatch (expected '$expected_desc', observed '$observed_desc')"
  fi
  if [[ "$observed_homepage" != "$expected_homepage" ]]; then
    record_fail "About homepage mismatch (expected '$expected_homepage', observed '$observed_homepage')"
  fi

  local topic topic_count=0
  while IFS= read -r topic; do
    [[ -n "$topic" ]] || continue
    if ! printf '%s' "$topics_json" | jq -e --arg t "$topic" 'index($t)' >/dev/null; then
      record_fail "missing repository topic: $topic"
    fi
    topic_count=$((topic_count + 1))
  done < <(jq -r '.about.topics[]?' "$MANIFEST")

  if [[ "$topic_count" -lt 5 ]]; then
    record_fail "manifest must declare at least 5 topics"
  fi

  local flag key expected observed
  while IFS=$'\t' read -r key expected; do
    [[ -n "$key" ]] || continue
    observed="$(printf '%s' "$repo_json" | jq -r --arg k "$key" '.[$k] // false')"
    if [[ "$observed" != "$expected" ]]; then
      record_fail "feature $key expected $expected (observed $observed)"
    fi
  done <<'EOF'
hasIssues	true
hasWiki	true
hasDiscussions	true
hasProjects	true
EOF

  local min_health
  min_health="$(jq -r '.community_profile.min_health_percentage // 95' "$MANIFEST")"
  local health
  health="$(gh api "repos/$REPO/community/profile" --jq '.health_percentage // 0' 2>/dev/null || echo 0)"
  if [[ "$health" -lt "$min_health" ]]; then
    record_fail "community profile health $health% below minimum $min_health%"
  fi

  local pages_enabled
  pages_enabled="$(jq -r '.pages.enabled // false' "$MANIFEST")"
  if [[ "$pages_enabled" == "true" ]]; then
    local pages_json source_path
    pages_json="$(gh api "repos/$REPO/pages" 2>/dev/null || true)"
    if [[ -z "$pages_json" ]]; then
      record_fail "GitHub Pages not enabled (expected source $(jq -r '.pages.source_path' "$MANIFEST"))"
    else
      source_path="$(printf '%s' "$pages_json" | jq -r '.source[0].path // ""')"
      local expected_path
      expected_path="$(jq -r '.pages.source_path' "$MANIFEST")"
      if [[ "$source_path" != "$expected_path" ]]; then
        record_fail "Pages source path mismatch (expected '$expected_path', observed '$source_path')"
      fi
    fi
  fi

  local label
  while IFS= read -r label; do
    [[ -n "$label" ]] || continue
    if ! gh api "repos/$REPO/labels/$label" >/dev/null 2>&1; then
      record_fail "missing GitHub label: $label"
    fi
  done < <(jq -r '.labels[]?' "$MANIFEST")

  local min_categories count
  min_categories="$(jq -r '.discussions.min_categories // 4' "$MANIFEST")"
  count="$(gh api graphql -f query="
    query { repository(owner: \"${REPO%%/*}\", name: \"${REPO##*/}\") {
      discussionCategories(first: 1) { totalCount }
    }}" --jq '.data.repository.discussionCategories.totalCount' 2>/dev/null || echo 0)"
  if [[ "$count" -lt "$min_categories" ]]; then
    record_fail "discussions categories $count below minimum $min_categories"
  fi

  local wiki_home
  wiki_home="$(jq -r '.wiki.home_page // "Home.md"' "$MANIFEST")"
  if gh api "repos/$owner/$name.wiki/contents/$wiki_home" >/dev/null 2>&1; then
    pass "wiki page $wiki_home exists"
  else
    record_fail "wiki page missing: $wiki_home (run wiki-sync workflow)"
  fi

  if [[ "$FAILURES" -eq 0 ]]; then
    pass "live About, topics, and homepage match manifest"
    pass "live feature flags match manifest"
    pass "community profile health >= $min_health%"
    pass "required labels present on GitHub"
    pass "discussions categories >= $min_categories"
  fi
}

run_local_checks

if [[ "$MODE" == "live" ]]; then
  run_live_checks
fi

if [[ "$FAILURES" -gt 0 ]]; then
  printf 'GitHub surface audit failed: %s finding(s).\n' "$FAILURES" >&2
  exit 1
fi

printf 'GitHub surface audit passed (%s mode).\n' "$MODE"
exit 0
