# ── AgToosa: file lists and usage text ───────────────────────
# Sourced by agtoosa.sh. Globals: AGTOOSA_VERSION (read-only here).

DOCS_FILES=(
  "Docs/AgToosa_Agent.md"
  "Docs/AgToosa_Init.md"
  "Docs/AgToosa_Spec.md"
  "Docs/AgToosa_Build.md"
  "Docs/AgToosa_Review.md"
  "Docs/AgToosa_Ship.md"
  "Docs/AgToosa_QA.md"
  "Docs/AgToosa_Revert.md"
  "Docs/AgToosa_Skills.md"
  "Docs/Master-Plan.md"
  "Docs/AgToosa_Changelog.md"
)

OPTIONAL_TEMPLATE_FILES=(
  "Docs/AgToosa_Claude.md"
  "Docs/AgToosa_Gemini.md"
  ".cursorrules"
  ".windsurfrules"
  "CLAUDE.md"
  "AGENTS.md"
  ".github/copilot-instructions.md"
  ".roorules"
  "OPENCODE.md"
)

CONTEXT_FILES=(
  "Docs/Context/workflow.md"
  "Docs/Context/tech-stack.md"
  "Docs/Context/product.md"
  "Docs/Context/product-guidelines.md"
)

print_usage() {
  echo "AgToosa Generator v${AGTOOSA_VERSION}"
  echo ""
  echo "Usage: bash agtoosa.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --force                Overwrite existing platform config files (creates .bak backups)"
  echo "  --dry-run              Show what would be copied without making changes"
  echo "  --list-template-files  Print every template file path and exit"
  echo "  --version              Print version and exit"
  echo "  --help                 Show this help message"
}

print_template_files() {
  printf '%s\n' "${DOCS_FILES[@]}" "${OPTIONAL_TEMPLATE_FILES[@]}" "${CONTEXT_FILES[@]}"
}
