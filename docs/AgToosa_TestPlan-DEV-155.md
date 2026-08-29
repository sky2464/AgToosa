# Test Plan: DEV-155 — Cross-Platform Fallback Guidance for Unrecognized `/agtoosa-*` Commands

| AC | Test ID / Check | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | `install prints a fallback tip for unrecognized /agtoosa-init` (bats) | Integration | Fresh install output contains the CLI tip string and `Docs/AgToosa_Init.md` | yes |
| AC-002 | Manual grep: `docs/AgToosa_Agent.md` / `template/Docs/AgToosa_Agent.md` contain "Native command unavailable" | Doc parity | Bullet present directly after "Slash wins" in Project Intake Protocol | no |
| AC-003 | `all platform entry points document the 'command not recognized' fallback` (bats) | Integration | All 6 generated entry-point files contain `## If a Command Isn't Recognized` after a platform-8 (All) install | yes |
| AC-004 | Manual grep: `docs/agtoosa-maintainer.md` contains the new parity-table row | Doc parity | Row present under User-Facing Strings That Must Match Across Variants | no |
| AC-005 | Both new bats tests above | Regression | Filter `-f "fallback tip for unrecognized"` and `-f "command not recognized"` exit 0 | yes |
| AC-006 | Full `bats tests/agtoosa.bats` run | Regression | No new failures vs. pre-change baseline; 2 pre-existing unrelated failures (`--update detects installed Claude platform and merges CLAUDE.md`, `SAU-003`) confirmed present on baseline via `git stash` | no |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| N/A | Non-Claude platform install (e.g. platform 1, Cursor only) | `.claude/` fallback section not asserted; Cursor's own `.cursorrules` fallback section still asserted via the platform-8 parity test |
