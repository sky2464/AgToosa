# Tech Stack


## Language

language: "Bash, PowerShell"

## Frameworks

framework: "AI Generator Template & Engine"

## Database

database: "File-based (JSON local lockfiles)"

## Deployment

deployment: "Git tag push triggers GitHub Actions release"
deploy_command: "git tag v$VERSION && git push origin v$VERSION"
deploy_verify: "gh release view v$VERSION && gh run list --workflow=release-advanced.yml --limit 1"
release_policy: ".github/RELEASE.md"

## Test Framework

test_framework: "BATS-core (Bash Automated Testing System)"

## Browser / Device Matrix

<!-- Used by /agtoosa-review QA Lead for compatibility checks -->

browser_matrix:
- "N/A - Terminal/CLI environments"

## Infrastructure-as-Code

iac_tool: "N/A"

## CI/CD

ci_platform: "GitHub Actions"

## Notes
<!-- Add constraints, deprecated libraries to avoid, or vendor lock-in notes here. -->
