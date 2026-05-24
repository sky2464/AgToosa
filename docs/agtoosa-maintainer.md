# AgToosa Maintainer Guide

Use this guide when working on the AgToosa repository itself.

## When To Use This Mode

Use AgToosa maintainer mode for work that changes any of these surfaces:

- `agtoosa.sh` or `lib/*.sh`
- `template/` workflow files, prompts, agents, commands, or platform entry points
- release/version wiring tied to `AGTOOSA_VERSION`
- generator copy/update behavior
- bats coverage in `tests/agtoosa.bats`

Do not use this mode for ordinary feature work inside a generated project that merely happens to use AgToosa.

## Repository Facts

- AgToosa is a framework generator, not an SDK runtime.
- `agtoosa.sh` is the only supported entrypoint.
- `install.sh` is deprecated and should not be modified.
- `ship/` is temporary staging output and must never be treated as durable project state.
- The canonical version lives in `AGTOOSA_VERSION` at the top of `agtoosa.sh`.

## Operating Rules

1. Start from the concrete owning surface: the shell file, template file, or test that directly controls the behavior.
2. Keep diffs small and preserve the existing shell style: defensive quoting, `set -euo pipefail`, and ANSI color variables with `NC` resets.
3. If you change generator behavior, update or add targeted bats coverage in `tests/agtoosa.bats`.
4. If you change template file inventory or native AI wiring, keep file lists in `lib/config.sh` aligned.
5. If you change platform entry points under `template/`, keep them functionally equivalent across platforms unless the platform truly requires a different native format.
6. Never silently rely on version drift. If release behavior changes, inspect `CHANGELOG.md` and version wiring together.

## Per-Platform Parity

Slash-command behavior has two layers: context rules and discoverable native entry points. Keep both aligned when changing workflow behavior:

- Claude Code: `.claude/commands/` plus `.claude/skills/` where applicable.
- Cursor: `.cursor/rules/` for context and `.cursor/commands/` for native command picker discoverability.
- Gemini CLI: `.gemini/commands/`.
- GitHub Copilot: `.github/prompts/` plus `.github/agents/` where applicable.
- Windsurf: `.windsurf/rules/` for context and `.windsurf/workflows/` for native workflow picker discoverability.
- Codex/OpenCode/Other: `OPENCODE.md` plus `.codex/skills/` for Codex skill discoverability.

If a platform truly lacks a per-command native format, document the fallback in its entry-point file rather than claiming native `/agtoosa-*` picker support.

## User-Facing Strings That Must Match Across Variants

These strings are part of the user-facing contract and must appear verbatim in every relevant canonical doc and platform variant. Bats parity tests grep for the canonical doc; verify variant copies on every release.

| String | Canonical source | Variants |
|---|---|---|
| `✅ Done. Run /agtoosa-status to verify findings cleared.` (closure line) | `template/Docs/AgToosa_{Build,Task,Spec,Ship,Init}.md` Output section | All relevant command, rule, prompt, workflow, and skill adapters |
| `Note: '<token>' is not a defined sub-command. Did you mean: plan, readiness, git, orphans? Falling back to full dashboard.` (status typo helper) | `template/Docs/AgToosa_Status.md` Part 5.6 | 5 status platform variants |
| `Recommended Next Actions generation` heading + the Part 5.5 algorithm | `template/Docs/AgToosa_Status.md` Part 5.5 | Referenced (not duplicated) from each status variant |

Adding a new fix-command? It must emit the closure line on successful completion and be added to the table above.

## Release Checklist

- Bump `AGTOOSA_VERSION` in `agtoosa.sh` AND `agtoosa.ps1` to identical values (bats checks parity).
- Update `README.md` version badge AND any pinned `--ref vX.Y.Z` install snippets — they drift silently across releases.
- Prepend a dated `## [X.Y.Z]` block to `CHANGELOG.md`. Move anything from `## [Unreleased]` into the new block.
- Re-grep every "user-facing string" from the parity table; ensure variants didn't drift.
- Run `bats tests/agtoosa.bats`. Confirm the version-parity test passes.

## Working Loop

1. Identify the smallest behavior-owning file.
2. Form one falsifiable hypothesis about the requested behavior.
3. Make the smallest change that tests or implements that hypothesis.
4. Run the narrowest validation available.
5. Report what changed, how it was verified, and any remaining risk.

## Validation

- Prefer `bats tests/agtoosa.bats` when generator behavior or template installation changes.
- Use narrow `bash agtoosa.sh --help`, `--version`, `--list-template-files`, or `--update` checks when they directly cover the touched surface.
- For documentation-only or agent-config-only changes, verify that each native entry file points to this guide and that no frontmatter errors were introduced.

## Expected Output

- Brief findings or plan.
- Minimal set of changes.
- Exact validation performed.
- Open questions only if they block correctness.
