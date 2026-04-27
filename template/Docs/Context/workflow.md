# Workflow Configuration

<!-- Fill in during /agtoosa-init. These values drive build and review behavior. -->

## TDD
tdd: false
# Set to true to enforce Red-Green-Refactor in /agtoosa-build

## Coverage
coverage_threshold: 80
# Minimum test coverage % required by /agtoosa-review QA Lead and /agtoosa-qa

## Branch Naming
branch_naming: "feat/<issue-id>-<short-desc>"
# Pattern for feature branches (e.g., feat/DEV-123-add-login)

## Commit Strategy
commit_strategy: "conventional"
# Options: conventional | free-form

## Linting
linter: ""
# Tool used (e.g., eslint, ruff, golangci-lint)
lint_config: ""
# Config file path (e.g., .eslintrc.json, pyproject.toml)

## Notes
<!-- Add team workflow rules, code review requirements, or release policies here. -->
