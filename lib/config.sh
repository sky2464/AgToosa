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
  "Docs/AgToosa_Task.md"
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
  "OPENCODE.md"
  ".claude/commands/agtoosa-init.md"
  ".claude/commands/agtoosa-spec.md"
  ".claude/commands/agtoosa-build.md"
  ".claude/commands/agtoosa-qa.md"
  ".claude/commands/agtoosa-review.md"
  ".claude/commands/agtoosa-ship.md"
  ".claude/commands/agtoosa-revert.md"
  ".claude/commands/agtoosa-task.md"
  ".claude/commands/agtoosa-help.md"
  ".claude/settings.json"
  ".claude/skills/agtoosa-review.md"
  ".cursor/rules/agtoosa-core.mdc"
  ".cursor/rules/agtoosa-spec.mdc"
  ".cursor/rules/agtoosa-build.mdc"
  ".cursor/rules/agtoosa-qa.mdc"
  ".cursor/rules/agtoosa-review.mdc"
  ".cursor/rules/agtoosa-ship.mdc"
  ".cursor/rules/agtoosa-revert.mdc"
  ".cursor/rules/agtoosa-task.mdc"
  ".gemini/commands/agtoosa-init.toml"
  ".gemini/commands/agtoosa-spec.toml"
  ".gemini/commands/agtoosa-build.toml"
  ".gemini/commands/agtoosa-qa.toml"
  ".gemini/commands/agtoosa-review.toml"
  ".gemini/commands/agtoosa-ship.toml"
  ".gemini/commands/agtoosa-revert.toml"
  ".gemini/commands/agtoosa-task.toml"
  ".gemini/commands/agtoosa-help.toml"
  ".github/prompts/agtoosa-init.prompt.md"
  ".github/prompts/agtoosa-spec.prompt.md"
  ".github/prompts/agtoosa-build.prompt.md"
  ".github/prompts/agtoosa-qa.prompt.md"
  ".github/prompts/agtoosa-review.prompt.md"
  ".github/prompts/agtoosa-ship.prompt.md"
  ".github/prompts/agtoosa-revert.prompt.md"
  ".github/prompts/agtoosa-task.prompt.md"
  ".github/prompts/agtoosa-help.prompt.md"
  ".github/agents/agtoosa.agent.md"
  ".windsurf/rules/agtoosa-core.md"
  ".windsurf/rules/agtoosa-spec.md"
  ".windsurf/rules/agtoosa-build.md"
  ".windsurf/rules/agtoosa-qa.md"
  ".windsurf/rules/agtoosa-review.md"
  ".windsurf/rules/agtoosa-ship.md"
  ".windsurf/rules/agtoosa-revert.md"
  ".windsurf/rules/agtoosa-task.md"
)

CONTEXT_FILES=(
  "Docs/Context/workflow.md"
  "Docs/Context/tech-stack.md"
  "Docs/Context/product.md"
  "Docs/Context/product-guidelines.md"
)

CLAUDE_COMMAND_FILES=(
  ".claude/commands/agtoosa-init.md"
  ".claude/commands/agtoosa-spec.md"
  ".claude/commands/agtoosa-build.md"
  ".claude/commands/agtoosa-qa.md"
  ".claude/commands/agtoosa-review.md"
  ".claude/commands/agtoosa-ship.md"
  ".claude/commands/agtoosa-revert.md"
  ".claude/commands/agtoosa-task.md"
  ".claude/commands/agtoosa-help.md"
)

CLAUDE_SKILL_FILES=(
  ".claude/skills/agtoosa-review.md"
)

CURSOR_RULE_FILES=(
  ".cursor/rules/agtoosa-core.mdc"
  ".cursor/rules/agtoosa-spec.mdc"
  ".cursor/rules/agtoosa-build.mdc"
  ".cursor/rules/agtoosa-qa.mdc"
  ".cursor/rules/agtoosa-review.mdc"
  ".cursor/rules/agtoosa-ship.mdc"
  ".cursor/rules/agtoosa-revert.mdc"
  ".cursor/rules/agtoosa-task.mdc"
)

GEMINI_COMMAND_FILES=(
  ".gemini/commands/agtoosa-init.toml"
  ".gemini/commands/agtoosa-spec.toml"
  ".gemini/commands/agtoosa-build.toml"
  ".gemini/commands/agtoosa-qa.toml"
  ".gemini/commands/agtoosa-review.toml"
  ".gemini/commands/agtoosa-ship.toml"
  ".gemini/commands/agtoosa-revert.toml"
  ".gemini/commands/agtoosa-task.toml"
  ".gemini/commands/agtoosa-help.toml"
)

COPILOT_PROMPT_FILES=(
  ".github/prompts/agtoosa-init.prompt.md"
  ".github/prompts/agtoosa-spec.prompt.md"
  ".github/prompts/agtoosa-build.prompt.md"
  ".github/prompts/agtoosa-qa.prompt.md"
  ".github/prompts/agtoosa-review.prompt.md"
  ".github/prompts/agtoosa-ship.prompt.md"
  ".github/prompts/agtoosa-revert.prompt.md"
  ".github/prompts/agtoosa-task.prompt.md"
  ".github/prompts/agtoosa-help.prompt.md"
)

COPILOT_AGENT_FILES=(
  ".github/agents/agtoosa.agent.md"
)

WINDSURF_RULE_FILES=(
  ".windsurf/rules/agtoosa-core.md"
  ".windsurf/rules/agtoosa-spec.md"
  ".windsurf/rules/agtoosa-build.md"
  ".windsurf/rules/agtoosa-qa.md"
  ".windsurf/rules/agtoosa-review.md"
  ".windsurf/rules/agtoosa-ship.md"
  ".windsurf/rules/agtoosa-revert.md"
  ".windsurf/rules/agtoosa-task.md"
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
