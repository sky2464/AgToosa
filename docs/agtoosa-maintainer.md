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
- `lib/maintain.sh` owns `--verify`, `--doctor`, and `--uninstall` (sourced by `agtoosa.sh`).
- `template/Docs/agtoosa-verify.sh` ships to generated projects as `Docs/agtoosa-verify.sh`; the maintainer mirror is `docs/agtoosa-verify.sh`. Keep both copies aligned when changing gate logic.
- `docs/agtoosa-gate.yml.example` (and `template/Docs/agtoosa-gate.yml.example`) is the CI gate template — AgToosa never writes `.github/workflows/` automatically.

## Generator Maintenance CLI

`lib/maintain.sh` implements read-only and destructive maintenance paths. Wire new flags through `agtoosa.sh` argument parsing, not ad-hoc scripts.

| Flag | Behavior | Exit / notes |
|------|----------|--------------|
| `--verify [path]` | Runs `agtoosa-verify.sh` against the target. Prefers the target's installed copy (`Docs/` or `docs/`), then falls back to `template/Docs/agtoosa-verify.sh`. | Verifier exit code (0 pass, 1 findings, 2 usage). |
| `--doctor [path]` | Reports version skew (`Docs/.agtoosa-version` vs generator), missing core workflow docs, platform entry-point wiring gaps, context placeholder tokens, queued packs, and stale `*.bak.*` files. | 0 healthy, 1 issues found, 2 bad path. |
| `--uninstall [path]` | Removes AgToosa-owned workflow docs and platform command/rule files. **Preserves** `Master-Plan.md`, `Master-Architecture.md`, `AgToosa_Changelog.md`, `Context/`, `archived/`, and merged entry-point files (`.cursorrules`, `CLAUDE.md`, etc.). Prompts for confirmation unless `--yes`. | Blocks uninstall when target is the generator source tree. |
| `--path` + `--platforms` + `--yes` | Non-interactive install (CI, devcontainers). See `npm/README.md` for the `npx agtoosa` wrapper. | Requires valid path and platform list. |

**Verifier modes** (on either copy of `agtoosa-verify.sh`):

```bash
bash docs/agtoosa-verify.sh              # default gates
bash docs/agtoosa-verify.sh --strict     # WARN → FAIL
bash docs/agtoosa-verify.sh stats        # cycle analytics from Update Log + agtoosa-events.jsonl
bash agtoosa.sh --verify .               # generator dispatch (maintainer dogfood)
```

**Common pitfalls:**

- Maintainer repo uses lowercase `docs/`; generated projects use `Docs/`. The verifier auto-detects via `Master-Plan.md` location. `--doctor` only recognizes `Docs/` installs — it reports "not installed" on the generator source tree.
- `--doctor` on a pre-3.x or partial install reports a missing `Docs/.agtoosa-version` marker — run `--update`.
- `--uninstall` leaves AGTOOSA START/END blocks inside merged entry points; users delete those manually.

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
- After touching verifier or maintain helpers: `bash agtoosa.sh --verify .` and `bash docs/agtoosa-verify.sh --strict` on this repo. Use `--doctor` against a generated fixture (doctor checks `Docs/`, not maintainer `docs/`).
- After changing `lib/maintain.sh` uninstall paths: run focused bats (`-f "DEV-073"` or `-f "UN"`) before the full suite.
- For documentation-only or agent-config-only changes, verify that each native entry file points to this guide and that no frontmatter errors were introduced.

## Expected Output

- Brief findings or plan.
- Minimal set of changes.
- Exact validation performed.
- Open questions only if they block correctness.
