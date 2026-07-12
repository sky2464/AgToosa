#!/usr/bin/env bash

# ── AgToosa: dry-run preview ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, FORCE, AGTOOSA_VERSION, colors.
# MAJOR update dry-run uses lib/migrate.sh (plan-result-v1 with migration categories).

print_dryrun_preview() {
  compute_agtoosa_plan "$PROJECT_PATH" "install"
  emit_plan_human
}

# Update dry-run dispatcher: MAJOR → migration plan; else unified plan engine.
print_update_dryrun_preview() {
  local format="${1:-text}"
  local installed
  installed="$(read_installed_version "$PROJECT_PATH")"
  if declare -F is_major_migration >/dev/null 2>&1 \
     && is_major_migration "$installed" "$AGTOOSA_VERSION"; then
    compute_migration_plan "$PROJECT_PATH" "$installed" "$AGTOOSA_VERSION"
    if [[ "$format" == "json" ]]; then
      emit_plan_json
    else
      emit_migration_plan_human
      echo -e "${YELLOW}[DRY RUN] No changes made. Remove --dry-run to apply (MAJOR requires --accept-breaking).${NC}"
    fi
    return 0
  fi
  run_update_dryrun "$format"
}
