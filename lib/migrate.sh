#!/usr/bin/env bash

# ── AgToosa: MAJOR-version migration wizard + rollback manifest (DEV-091) ──
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, TEMPLATE_DIR, AGTOOSA_VERSION, FORCE, DRY_RUN,
#               ACCEPT_BREAKING, ASSUME_YES, OUTPUT_FORMAT, DOCS_FILES, colors.
# Depends on: lib/plan.sh (compute_agtoosa_plan, emit_plan_*), lib/version.sh,
#             lib/update.sh (run_update, read_installed_version).

MIGRATE_FROM_VERSION=""
MIGRATE_TO_VERSION=""
MIGRATE_ROLLBACK_TS=""
MIGRATE_ROLLBACK_DIR=""
MIGRATE_MANIFEST_ENTRIES=()

# Print major component of a semver (unknown → empty).
_migrate_major() {
  local v="$1"
  [[ "$v" == "unknown" || -z "$v" ]] && { echo ""; return; }
  printf '%s' "${v%%.*}"
}

# Return 0 when installed MAJOR is strictly less than target MAJOR.
is_major_migration() {
  local installed="$1" target="$2"
  local im tm
  im="$(_migrate_major "$installed")"
  tm="$(_migrate_major "$target")"
  [[ -n "$im" && -n "$tm" ]] || return 1
  (( 10#$im < 10#$tm ))
}

# True when path has non-whitespace content outside AgToosa START/END markers.
_migrate_has_outside_markers() {
  local file="$1"
  local outside
  [[ -f "$file" ]] || return 1
  outside="$(awk '
    /AgToosa v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* START/ { in_block=1; next }
    in_block && /AgToosa END/ { in_block=0; next }
    !in_block { print }
  ' "$file" 2>/dev/null | tr -d '[:space:]')"
  [[ -n "$outside" ]]
}

# Reject path traversal in relative paths used for rollback.
_migrate_safe_relpath() {
  local rel="$1"
  [[ -n "$rel" ]] || return 1
  [[ "$rel" == /* ]] && return 1
  [[ "$rel" == *..* ]] && return 1
  return 0
}

# Remap one DEV-090 plan row into migration categories: overwrite|merge|preserve|manual.
_migrate_remap_category() {
  local rel="$1" cat="$2"
  local target="${PROJECT_PATH}/${rel}"

  case "$rel" in
    CLAUDE.md|.cursorrules|.windsurfrules|AGENTS.md|OPENCODE.md|.github/copilot-instructions.md)
      if _migrate_has_outside_markers "$target"; then
        echo "preserve"
        return
      fi
      echo "merge"
      return
      ;;
  esac

  case "$cat" in
    overwrite|new|backup_replace) echo "overwrite" ;;
    merge) echo "merge" ;;
    skip|up_to_date) echo "preserve" ;;
    manual) echo "manual" ;;
    *) echo "overwrite" ;;
  esac
}

# Append manual rows for Docs/AgToosa_* present in project but not in template.
_migrate_append_manual_orphans() {
  local f base rel known
  [[ -d "${PROJECT_PATH}/Docs" ]] || return 0
  for f in "${PROJECT_PATH}/Docs"/AgToosa_*.md; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    rel="Docs/${base}"
    [[ -f "${TEMPLATE_DIR}/${rel}" ]] && continue
    known=false
    if ((${#PLAN_ACTIONS[@]} > 0)); then
      local entry
      for entry in "${PLAN_ACTIONS[@]}"; do
        [[ "${entry%%|*}" == "$rel" ]] && known=true && break
      done
    fi
    [[ "$known" == true ]] && continue
    PLAN_ACTIONS+=("${rel}|manual|Removed or non-template workflow — review manually before delete")
  done
}

# Build migration plan (plan-result-v1) with overwrite/merge/preserve/manual.
compute_migration_plan() {
  local project_path="$1"
  local from_ver="${2:-}"
  local to_ver="${3:-$AGTOOSA_VERSION}"
  local entry rel cat detail mapped
  local -a remapped=()

  MIGRATE_FROM_VERSION="${from_ver:-$(read_installed_version "$project_path")}"
  MIGRATE_TO_VERSION="$to_ver"

  compute_agtoosa_plan "$project_path" "update"
  PLAN_OPERATION="update"

  for entry in "${PLAN_ACTIONS[@]}"; do
    IFS='|' read -r rel cat detail <<< "$entry"
    mapped="$(_migrate_remap_category "$rel" "$cat")"
    case "$mapped" in
      preserve)
        detail="user content outside markers preserved (merge, not overwrite)"
        ;;
      manual)
        detail="${detail:-manual review required}"
        ;;
      merge)
        detail="${detail:-smart merge AgToosa block}"
        ;;
      overwrite)
        detail="${detail:-AgToosa-owned overwrite}"
        ;;
    esac
    remapped+=("${rel}|${mapped}|${detail}")
  done
  PLAN_ACTIONS=("${remapped[@]}")
  _migrate_append_manual_orphans
}

# Human-readable migration plan summary (ANSI ok on stderr/stdout for humans).
emit_migration_plan_human() {
  local entry rel cat detail
  echo -e "${YELLOW}${BOLD}MAJOR migration plan${NC}  v${MIGRATE_FROM_VERSION} → v${MIGRATE_TO_VERSION}"
  echo -e "${YELLOW}Categories: overwrite | merge | preserve | manual${NC}"
  echo ""
  for entry in "${PLAN_ACTIONS[@]}"; do
    IFS='|' read -r rel cat detail <<< "$entry"
    case "$cat" in
      overwrite) echo -e "  ${GREEN}overwrite${NC}  ${rel}  — ${detail}" ;;
      merge)     echo -e "  ${CYAN}merge${NC}      ${rel}  — ${detail}" ;;
      preserve)  echo -e "  ${BLUE}preserve${NC}   ${rel}  — ${detail}" ;;
      manual)    echo -e "  ${YELLOW}manual${NC}     ${rel}  — ${detail}" ;;
      *)         echo -e "  ${cat}  ${rel}  — ${detail}" ;;
    esac
  done
  echo ""
}

# Interactive confirm for MAJOR apply. Returns 0 when accepted.
confirm_major_migration() {
  local reply=""
  if [[ ! -t 0 ]]; then
    return 1
  fi
  echo -e "${YELLOW}${BOLD}MAJOR version change detected (v${MIGRATE_FROM_VERSION} → v${MIGRATE_TO_VERSION}).${NC}"
  echo -e "${YELLOW}Breaking template changes may apply. Review the plan above.${NC}"
  read -rp "Proceed with MAJOR migration? [y/N] " reply || true
  [[ "$reply" == "y" || "$reply" == "Y" || "$reply" == "yes" || "$reply" == "YES" ]]
}

# Create timestamped backup tree + manifest entries for mutable plan rows.
_migrate_backup_for_apply() {
  local entry rel cat detail src bak_rel bak_abs
  MIGRATE_ROLLBACK_TS="$(date -u +%Y%m%dT%H%M%SZ)"
  MIGRATE_ROLLBACK_DIR="${PROJECT_PATH}/.agtoosa/rollback/${MIGRATE_ROLLBACK_TS}"
  MIGRATE_MANIFEST_ENTRIES=()

  mkdir -p "$MIGRATE_ROLLBACK_DIR"

  for entry in "${PLAN_ACTIONS[@]}"; do
    IFS='|' read -r rel cat detail <<< "$entry"
    [[ "$cat" == "manual" ]] && continue
    _migrate_safe_relpath "$rel" || continue
    src="${PROJECT_PATH}/${rel}"
    [[ -f "$src" ]] || continue
    bak_rel=".agtoosa/rollback/${MIGRATE_ROLLBACK_TS}/${rel}.bak"
    bak_abs="${PROJECT_PATH}/${bak_rel}"
    mkdir -p "$(dirname "$bak_abs")"
    cp "$src" "$bak_abs"
    MIGRATE_MANIFEST_ENTRIES+=("$(python3 -c 'import json,sys; print(json.dumps({"path":sys.argv[1],"action":sys.argv[2],"backup":sys.argv[3]}))' "$rel" "$cat" "$bak_rel")")
  done
}

# Write .agtoosa/rollback/<ts>.json after backups are staged.
write_rollback_manifest() {
  local manifest="${PROJECT_PATH}/.agtoosa/rollback/${MIGRATE_ROLLBACK_TS}.json"
  local entries_joined="" e created
  mkdir -p "${PROJECT_PATH}/.agtoosa/rollback"
  for e in "${MIGRATE_MANIFEST_ENTRIES[@]+"${MIGRATE_MANIFEST_ENTRIES[@]}"}"; do
    [[ -n "$entries_joined" ]] && entries_joined+=","
    entries_joined+="$e"
  done
  created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  export MWZ_MANIFEST_ENTRIES="$entries_joined"
  export MWZ_FROM="$MIGRATE_FROM_VERSION"
  export MWZ_TO="$MIGRATE_TO_VERSION"
  export MWZ_CREATED="$created"
  python3 - <<'PY' > "$manifest"
import json, os
doc = {
    "schema_version": 1,
    "agtoosa_from": os.environ.get("MWZ_FROM", ""),
    "agtoosa_to": os.environ.get("MWZ_TO", ""),
    "created_at": os.environ.get("MWZ_CREATED", ""),
    "entries": json.loads("[" + os.environ.get("MWZ_MANIFEST_ENTRIES", "") + "]"),
}
print(json.dumps(doc, ensure_ascii=False, indent=2))
PY
  echo -e "  ${GREEN}✅${NC} Rollback manifest: .agtoosa/rollback/${MIGRATE_ROLLBACK_TS}.json"
}

# Gate + apply path for MAJOR updates. Exit codes: 0 ok, 1 blocked/declined.
run_major_migration() {
  local project_path="$1"
  local old_ver="$2"
  local format="${OUTPUT_FORMAT:-text}"
  local json_requested=false

  [[ "$format" == "json" ]] && json_requested=true

  compute_migration_plan "$project_path" "$old_ver" "$AGTOOSA_VERSION"

  # Dry-run / JSON plan: no filesystem mutations (AC-006, AC-007).
  if [[ "$DRY_RUN" == true || ( "$json_requested" == true && "${ACCEPT_BREAKING:-false}" != true ) ]]; then
    if [[ "$json_requested" == true ]]; then
      emit_plan_json
    else
      emit_migration_plan_human
      echo -e "${YELLOW}[DRY RUN] No changes made. Use --accept-breaking to apply MAJOR migration.${NC}"
    fi
    return 0
  fi

  # Always print categorized plan before apply (AC-005).
  emit_migration_plan_human

  if [[ "${ACCEPT_BREAKING:-false}" != true ]]; then
    if ! confirm_major_migration; then
      echo -e "${RED}❌ MAJOR migration blocked.${NC}" >&2
      echo -e "${YELLOW}Re-run with --accept-breaking after reviewing --update --dry-run (or --json).${NC}" >&2
      return 1
    fi
  fi

  _migrate_backup_for_apply
  write_rollback_manifest
  run_update "$old_ver"
  return 0
}
