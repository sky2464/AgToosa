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
| `DEV-0XX` | `docs/Master-Plan.md` | Product stories (spec → build → review → ship). Increment by one for each new story. |
| `DEV-1XX` | Historical `CHANGELOG.md` / bats from v2.x–v3.x | Deprecated internal labels from the pre–Master-Plan era. **Do not allocate new DEV-1XX IDs.** |

When adding bats coverage:

- Tied to a Master-Plan story: use a story section header such as `# ── DEV-022: Registry publish PS1 + offline cache (RC1–RC3) ───`.
- Not tied to a story: use a descriptive section name (optionally with smoke codes like `RG1–RG8`). Never introduce new `# ── DEV-1XX:` section headers.

Inline comments in `lib/*.sh` and `agtoosa.sh` should describe behavior in plain English, not legacy DEV-1XX tags.

## Repository Facts

- AgToosa is a framework generator, not an SDK runtime.
- `agtoosa.sh` is the primary Bash entrypoint; `agtoosa.ps1` is the native Windows port.
- `install.sh` is deprecated and should not be modified.
- `ship/` is temporary staging output and must never be treated as durable project state.
- `.agtoosa/pack-queue/` is the durable staging area for `--registry install` packs until the next project install merges them.
- The canonical version lives in `AGTOOSA_VERSION` at the top of `agtoosa.sh` and must match `agtoosa.ps1` and `npm/package.json`.
- Proof-engine artifacts ship from `template/Docs/` into every install: `agtoosa-verify.sh`, `agtoosa-gate.yml.example`, and `agtoosa-events.jsonl` (seed file).

## Generator CLI Surfaces

Beyond the interactive install wizard, `agtoosa.sh` exposes these maintainer-relevant flags (implemented in `lib/maintain.sh`, `lib/registry.sh`, and `agtoosa.sh`):

| Flag | Owning code | Purpose |
|------|-------------|---------|
| `--verify [path]` | `lib/maintain.sh:run_verify` | Run the deterministic lifecycle verifier (prefers the target's installed `Docs/agtoosa-verify.sh`, falls back to template copy) |
| `--doctor [path]` | `lib/maintain.sh:run_doctor` | Report version skew, missing workflow docs, platform wiring gaps, context placeholders, queued packs |
| `--uninstall [path]` | `lib/maintain.sh:run_uninstall` | Remove AgToosa-owned files; preserves Master-Plan, Context/, archived/, and user-edited entry points |
| `--path <dir>` | `agtoosa.sh` | Skip the interactive path prompt |
| `--platforms <list>` | `agtoosa.sh` | Comma-separated platform list (e.g. `cursor,claude`) |
| `--yes`, `-y` | `agtoosa.sh` | Non-interactive consent (CI, devcontainers, npm wrapper) |
| `--allow-unverified` | `lib/registry.sh` | Opt in to installing registry packs where `verified: false` |

**npm wrapper:** `npm/` publishes a thin `npx agtoosa` shim that downloads the release tarball pinned to `npm/package.json` version, screens archive members, and forwards args to `agtoosa.sh`. Bump `npm/package.json` version in lockstep with `AGTOOSA_VERSION` on every release.

## Proof Engine Artifacts

These files are part of the user-facing contract and must stay aligned across `template/Docs/`, maintainer mirrors under `docs/`, and `lib/config.sh` file lists:

| Artifact | Role | Maintainer notes |
|----------|------|------------------|
| `Docs/agtoosa-verify.sh` | Deterministic, no-AI lifecycle gate | Checks context, Master-Plan integrity, spec approval, EARS ACs, AC→test mapping, threat model, wave plan, TDD evidence. Exit `0` pass, `1` findings, `2` usage error. `--strict` promotes warnings. `stats` mode prints cycle analytics. |
| `Docs/agtoosa-gate.yml.example` | CI gate template | Users copy to `.github/workflows/` themselves — AgToosa never writes CI workflows. Supports both `Docs/` and `docs/` paths. |
| `Docs/agtoosa-events.jsonl` | Phase-event log | Workflows append one JSON line per phase transition; ship rotates Update Log rows beyond 150 into `Docs/archived/updatelog-<year>.md`. |
| `Docs/AgToosa_Quickref.md` | Token-diet entry point | One-page command contract; Cursor core rule scopes to Docs/ and `/agtoosa-*` runs. |

When changing verifier checks, update `template/Docs/agtoosa-verify.sh` first, mirror to `docs/agtoosa-verify.sh`, and add bats coverage under a `DEV-061` or descriptive section.

## Supply Chain and Registry Hardening

Registry and bootstrap behavior changed in the v5.3.0 supply-chain wave. Touch these surfaces together:

| Concern | Owning code | Behavior |
|---------|-------------|----------|
| Tar-slip pre-scan | `lib/registry.sh:assert_safe_tarball`, `bootstrap.sh`, `bootstrap.ps1` | Reject absolute paths and `..` members **before** extraction |
| Pack file allowlist | `lib/registry.sh:validate_pack_files` | Only `.md`, `.json`, `.toml`, `.mdc` allowed |
| Sensitive destination denylist | `lib/install.sh:PACK_DENYLIST_PATTERNS` | Packs cannot merge into `.claude/settings.json`, `.claude/hooks/`, or `.github/workflows/` |
| Verified flag | `lib/registry.sh` | `verified: false` packs require `--allow-unverified` or `AGTOOSA_ALLOW_UNVERIFIED=1` |
| Content preview | `lib/registry.sh:_print_pack_preview` | Lists staged files, flags AI-instruction surfaces, shows blocked destinations before consent |
| Pinned bootstrap | `bootstrap.sh`, `Formula/agtoosa.rb` | `--ref vX.Y.Z` fails closed (no branch fallback); optional `--sha256`; releases publish `SHA256SUMS` |

User-facing registry docs live in `template/Docs/AgToosa_Registry.md` (mirror: `docs/AgToosa_Registry.md`). Threat-model detail: `docs/security/template-injection-threat-model.md`.

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

- Bump `AGTOOSA_VERSION` in `agtoosa.sh`, `agtoosa.ps1`, and `npm/package.json` to identical values (bats checks parity).
- Update `README.md` version badge AND any pinned `--ref vX.Y.Z` install snippets — they drift silently across releases.
- Publish `SHA256SUMS` for bootstrap tarballs; pin `Formula/agtoosa.rb` to the tagged tarball + sha256.
- Run `bash agtoosa.sh --verify .` on this repo before shipping generator or template changes that touch lifecycle state.
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
- For proof-engine or lifecycle-doc changes: `bash agtoosa.sh --verify .`, `bash docs/agtoosa-verify.sh stats`, and `bash agtoosa.sh --doctor .`.
- For registry or bootstrap changes: exercise `--registry install` with a test pack and confirm tar-slip rejection, denylist blocking, and preview output.
- For documentation-only or agent-config-only changes, verify that each native entry file points to this guide and that no frontmatter errors were introduced.

## Expected Output

- Brief findings or plan.
- Minimal set of changes.
- Exact validation performed.
- Open questions only if they block correctness.
