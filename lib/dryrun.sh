#!/usr/bin/env bash

# ── AgToosa: dry-run preview ──────────────────────────────────
# Sourced by agtoosa.sh.
# Globals read: PROJECT_PATH, SHIP_DIR, FORCE, AGTOOSA_VERSION, colors.

print_dryrun_preview() {
  compute_agtoosa_plan "$PROJECT_PATH" "install"
  emit_plan_human
}
