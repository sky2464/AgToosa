#!/usr/bin/env bash

# ── AgToosa: transactional apply + hash-aware commit (DEV-092) ──
# Sourced by agtoosa.sh after copy.sh.
# Globals: APPLY_STAGING_ROOT, APPLY_WRITTEN, APPLY_MERGED, APPLY_UNCHANGED, APPLY_FAILED
# Inject: AGTOOSA_APPLY_FAIL_ON=<relpath> forces commit failure for tests.

APPLY_STAGING_ROOT=""
APPLY_WRITTEN=0
APPLY_MERGED=0
APPLY_UNCHANGED=0
APPLY_FAILED=0

apply_reset_summary() {
  APPLY_WRITTEN=0
  APPLY_MERGED=0
  APPLY_UNCHANGED=0
  APPLY_FAILED=0
}

apply_print_summary() {
  echo "apply summary: written=${APPLY_WRITTEN} merged=${APPLY_MERGED} unchanged=${APPLY_UNCHANGED} failed=${APPLY_FAILED}"
}

apply_content_sha256() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    sha256sum "$f" | awk '{print $1}'
  fi
}

# Create a staging root outside the project tree (never under PROJECT_PATH).
apply_begin_staging() {
  local project_path="$1"
  apply_abort_staging
  APPLY_STAGING_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agtoosa-apply.XXXXXX")"
  chmod 700 "$APPLY_STAGING_ROOT" 2>/dev/null || true
  # Record project for safety checks
  APPLY_PROJECT_PATH="$project_path"
}

apply_abort_staging() {
  if [[ -n "${APPLY_STAGING_ROOT:-}" && -d "${APPLY_STAGING_ROOT:-}" ]]; then
    rm -rf "$APPLY_STAGING_ROOT"
  fi
  APPLY_STAGING_ROOT=""
}

# Stage one file: copy src into staging at relative path.
apply_stage_file() {
  local src="$1" rel="$2"
  local dest
  [[ -n "$APPLY_STAGING_ROOT" ]] || { echo "apply: staging not begun" >&2; return 1; }
  [[ -f "$src" ]] || { echo "apply: missing source $src" >&2; return 1; }
  dest="${APPLY_STAGING_ROOT}/${rel}"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

# Commit all staged files into project. On any failure, leave project unchanged
# for files not yet committed by rolling back via not writing until validated.
# Strategy: validate all staged files first (hash + inject), then write.
# Optional 2nd arg: apply command label for .agtoosa/state.json (install|update|apply).
apply_commit_staging() {
  local project_path="$1"
  local apply_command="${2:-apply}"
  local rel staged target staged_hash target_hash mode
  local -a commit_list=()

  [[ -n "$APPLY_STAGING_ROOT" && -d "$APPLY_STAGING_ROOT" ]] || {
    echo "apply: no staging root" >&2
    return 1
  }

  # Fail-closed: refuse staging rooted inside the project
  case "$APPLY_STAGING_ROOT" in
    "${project_path}"/*)
      echo "apply: staging root must not be inside project" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
      ;;
  esac

  # Pack SHA revalidation before any project mutation or state write (DEV-093).
  if declare -F lock_revalidate_packs >/dev/null 2>&1; then
    if ! lock_revalidate_packs "$project_path"; then
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
  fi

  while IFS= read -r -d '' staged; do
    rel="${staged#"${APPLY_STAGING_ROOT}/"}"
    if [[ -n "${AGTOOSA_APPLY_FAIL_ON:-}" && "$rel" == "$AGTOOSA_APPLY_FAIL_ON" ]]; then
      echo "apply: injected failure on $rel" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if [[ -L "$staged" ]]; then
      echo "apply: refusing symlink in staging: $rel" >&2
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    commit_list+=("$rel")
  done < <(find "$APPLY_STAGING_ROOT" -type f -print0)

  for rel in "${commit_list[@]}"; do
    staged="${APPLY_STAGING_ROOT}/${rel}"
    target="${project_path}/${rel}"
    staged_hash="$(apply_content_sha256 "$staged")"
    if [[ -f "$target" ]]; then
      target_hash="$(apply_content_sha256 "$target")"
      if [[ "$staged_hash" == "$target_hash" ]]; then
        APPLY_UNCHANGED=$((APPLY_UNCHANGED + 1))
        continue
      fi
      mode="written"
    else
      mode="written"
    fi
    mkdir -p "$(dirname "$target")"
    # Atomic-ish: write via temp in same dir then rename
    local tmp
    tmp="${target}.agtoosa-tmp.$$"
    if ! cp "$staged" "$tmp"; then
      echo "apply: failed writing $rel" >&2
      rm -f "$tmp" 2>/dev/null || true
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if ! mv "$tmp" "$target"; then
      echo "apply: failed committing $rel" >&2
      rm -f "$tmp" 2>/dev/null || true
      APPLY_FAILED=$((APPLY_FAILED + 1))
      apply_abort_staging
      return 1
    fi
    if [[ "$mode" == "written" ]]; then
      APPLY_WRITTEN=$((APPLY_WRITTEN + 1))
    fi
  done

  apply_abort_staging

  # Post-apply operational state + lock reconcile (DEV-093).
  if declare -F lock_reconcile >/dev/null 2>&1; then
    lock_reconcile "$project_path"
  fi
  if declare -F state_write_after_apply >/dev/null 2>&1; then
    state_write_after_apply "$project_path" "$apply_command" "${commit_list[@]+"${commit_list[@]}"}"
  fi
  return 0
}

# Hash-aware copy used by install/update paths (idempotent second run).
# Sets APPLY_* counters. Returns 0 always for skip/write success; 1 on hard fail.
apply_copy_if_changed() {
  local src="$1" dst="$2" label="${3:-}"
  local src_hash dst_hash

  mkdir -p "$(dirname "$dst")"
  if [[ ! -f "$src" ]]; then
    APPLY_FAILED=$((APPLY_FAILED + 1))
    return 1
  fi

  if [[ -f "$dst" ]]; then
    src_hash="$(apply_content_sha256 "$src")"
    dst_hash="$(apply_content_sha256 "$dst")"
    if [[ "$src_hash" == "$dst_hash" ]]; then
      APPLY_UNCHANGED=$((APPLY_UNCHANGED + 1))
      if [[ -n "$label" && -n "${GREEN:-}" ]]; then
        echo -e "  ${GREEN}✅${NC} ${label} ${CYAN}(unchanged)${NC}"
      fi
      return 0
    fi
  fi

  local tmp
  tmp="${dst}.agtoosa-tmp.$$"
  if ! cp "$src" "$tmp" || ! mv "$tmp" "$dst"; then
    rm -f "$tmp" 2>/dev/null || true
    APPLY_FAILED=$((APPLY_FAILED + 1))
    return 1
  fi
  APPLY_WRITTEN=$((APPLY_WRITTEN + 1))
  if [[ -n "$label" && -n "${GREEN:-}" ]]; then
    echo -e "  ${GREEN}✅${NC} ${label}"
  fi
  return 0
}

# Mark a merge-style write in the summary (content already applied by caller).
apply_note_merged() {
  APPLY_MERGED=$((APPLY_MERGED + 1))
}
