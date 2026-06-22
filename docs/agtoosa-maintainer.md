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

## Operating Contexts

AgToosa has two operating contexts. Use the one that matches where you are working.

### Maintainer Dogfood Mode

| Topic | This repository |
|-------|-----------------|
| **Where** | The AgToosa generator repo (`AgToosa` on GitHub) |
| **What you build** | AgToosa itself — the generator, `template/` pack, and maintainer tooling |
| **Entry guide** | This file (`docs/agtoosa-maintainer.md`) |
| **PM source of truth** | `docs/Master-Plan.md` for AgToosa development |
| **In scope** | `agtoosa.sh`, `lib/`, `template/`, `tests/agtoosa.bats`, release/version wiring |

You are in **Maintainer Dogfood Mode** when editing this repository. AgToosa workflows here improve AgToosa; do not confuse the generator with a generic downstream app install.

#### Path conventions

Workflow paths differ by operating context. Use the prefix that matches the repository you are in:

| Context | PM / workflow prefix | Example |
|---------|----------------------|---------|
| **Maintainer Dogfood Mode** (this repo) | `docs/` (lowercase, on-disk) | `docs/Master-Plan.md`, `docs/archived/spec-DEV-025.md` |
| **Generated Project Mode** (downstream install) | `Docs/` (capital D, installed by generator) | `Docs/Master-Plan.md`, `Docs/archived/spec-DEV-42.md` |
| **Template pack** (source, not host layout) | `template/Docs/` | `template/Docs/AgToosa_Status.md` |

When syncing maintainer mirrors from `template/Docs/`, rewrite repo-local path references to `docs/`. Leave `template/Docs/` citations unchanged. Do not create a top-level `Docs/` directory in this repository.

### Generated Project Mode

| Topic | Downstream install |
|-------|-------------------|
| **Where** | Any other repository after `agtoosa.sh` install |
| **What you build** | **The project** or **the product** named in `Docs/Master-Plan.md` → `## Project Charter` |
| **Entry guide** | `Docs/AgToosa_Agent.md` in the host repo (not this maintainer guide) |
| **PM source of truth** | `Docs/Master-Plan.md` in the user's repository |
| **Out of scope here** | Generator shell changes, `lib/config.sh`, AgToosa release hygiene |

Generated projects must not inherit maintainer-only assumptions (treating every repo as "AgToosa the product", or editing generator surfaces). Template docs under `template/Docs/` are written for **Generated Project Mode** and ship into host repos.

## Story and Test ID Conventions

AgToosa uses two ID namespaces. Do not mix them when adding new work.

| Namespace | Where | Meaning |
|-----------|-------|---------|
| `DEV-0XX` | `docs/Master-Plan.md` | Product stories (spec → build → review → ship). Increment by one for each new story (currently through DEV-025). |
| `DEV-1XX` | Historical `CHANGELOG.md` / bats from v2.x–v3.x | Deprecated internal labels from the pre–Master-Plan era. **Do not allocate new DEV-1XX IDs.** |

When adding bats coverage:

- Tied to a Master-Plan story: use a story section header such as `# ── DEV-022: Registry publish PS1 + offline cache (RC1–RC3) ───`.
- Not tied to a story: use a descriptive section name (optionally with smoke codes like `RG1–RG8`). Never introduce new `# ── DEV-1XX:` section headers.

Inline comments in `lib/*.sh` and `agtoosa.sh` should describe behavior in plain English, not legacy DEV-1XX tags.

## Repository Facts

- AgToosa is a framework generator, not an SDK runtime.
- `agtoosa.sh` is the only supported entrypoint.
- `install.sh` is deprecated and should not be modified.
- `ship/` is temporary staging output and must never be treated as durable project state.
- `.agtoosa/pack-queue/` is the durable staging area for `--registry install` packs until the next project install merges them.
- The canonical version lives in `AGTOOSA_VERSION` at the top of `agtoosa.sh`.

## CLI Maintenance Surfaces

Beyond install/update, the generator exposes read-only and maintenance commands via `lib/maintain.sh`:

| Flag | Owner | Behavior |
|------|-------|----------|
| `--verify [path]` | `lib/maintain.sh` → target's `agtoosa-verify.sh` | Deterministic lifecycle gate (read-only, no AI). Prefers the target's installed copy over the template fallback. |
| `--doctor [path]` | `lib/maintain.sh` | Diagnose version skew, missing workflow docs, platform wiring gaps, context placeholders, pending pack queue, and stale backups. |
| `--uninstall [path]` | `lib/maintain.sh` | Remove AgToosa-owned files. Preserves `Master-Plan.md`, `Master-Architecture.md`, `AgToosa_Changelog.md`, `Context/`, `archived/`, and merged platform entry points. |

**Non-interactive install:** `--path <dir>`, `--platforms cursor,claude`, and `--yes` skip TTY prompts (CI, devcontainers, scripted rollouts). Bootstrap pass-through uses `--` before generator flags.

**When changing these surfaces:**

1. Update `lib/config.sh` help text and `lib/maintain.sh` behavior together.
2. Add or extend bats coverage in `tests/agtoosa.bats` (VF/DR/UN sections).
3. Keep `npm/package.json` version identical to `AGTOOSA_VERSION` — the npm wrapper pins downloads to that version.

**Shipped template artifacts** (keep `lib/config.sh` file lists aligned):

- `template/Docs/agtoosa-verify.sh` — deterministic verifier installed into every project
- `template/Docs/agtoosa-gate.yml.example` — CI gate template (users copy manually; AgToosa never writes `.github/workflows/` automatically)

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

**Bump decision tree (patch-first — see `docs/adr/ADR-005-release-cadence.md`):**

| Story profile | Bump | Example (from 5.2.0) |
|---------------|------|----------------------|
| Fix, Chore, docs-only, estimate **S** | **PATCH** (default) | 5.2.1 |
| Feature **S**, same MINOR train, non-breaking | **PATCH** | 5.2.1 |
| New MINOR train, multi-story batched release | **MINOR** (Z=0) | 5.3.0 |
| Breaking per ADR-004 | **MAJOR** | 6.0.0 |

Do **not** advance MINOR for every small story. Update Project Charter **Milestone** to the **next PATCH** on the active MINOR (e.g. `v5.2.1 (next)` while shipped is `5.2.0`).

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
