# ADR-001: Plugin/Extension System Architecture

**Status:** Accepted  
**Date:** 2026-05-01  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa must run inside six different AI coding platforms (Cursor, Windsurf, Claude Code, Gemini CLI, GitHub Copilot, OpenCode) without requiring any runtime beyond `bash` and `curl`. Each platform has its own native config format for injecting instructions into the AI's context. Users also want to extend AgToosa with custom workflows, hooks, and community packs without forking the repo or modifying core files.

Forces at play:
- Zero runtime dependencies (no Node, Python, or package managers)
- Each platform has a distinct config API (MDX rules, TOML commands, JSON hooks, markdown prompts)
- Users have local edits in platform files that must survive an `--update` run
- Community packs (registry) must be composable with core workflows
- The Claude Code hooks system is the only platform that supports reactive/event-driven behavior

---

## Decision

**Use a platform-native entry-point registry with marker-based file merging, not a traditional plugin loader.**

AgToosa does not have a plugin runtime. Instead, it treats each platform's native config format as its extension surface. "Installing" a plugin means staging the correct markdown/TOML/JSON files for that platform and merging them into the project on disk. The framework itself is the generator; AI assistants are the runtime.

---

## Options Considered

### Option A: Platform-Native Entry-Point Registry (current)

Each platform gets its own generated file tree from `template/`. A platform selector in `lib/config.sh` maps platform IDs to file lists. Files are stamped with `<!-- AgToosa vX.Y.Z START/END -->` markers so future `--update` runs can replace only the AgToosa-owned block, leaving user edits outside markers intact.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low — pure file operations, no plugin loader |
| Cost | Free — no infra required |
| Scalability | Medium — new platforms require new template trees |
| Team familiarity | High — bash file I/O is universally understood |
| Zero-dependency | ✅ Fully maintained |
| Cross-platform skill sharing | ❌ Skills only work in Claude Code today |

**Pros:**
- No runtime dependency introduced
- Each platform gets idiomatic config (not a lowest-common-denominator shim)
- Marker-based merging is predictable and auditable
- Community packs extend the same file tree without a separate loader

**Cons:**
- Adding a new platform requires manual template authoring
- No dynamic hook registration — hooks are baked into `settings.json` at install time
- Skills (`.claude/skills/`) are Claude Code-only; no equivalent for Cursor or Gemini

### Option B: Central Plugin Manifest + Dynamic Loader

A `plugins.json` manifest declares plugin names, file lists, and platform targets. A loader script (`lib/plugin-loader.sh`) iterates the manifest at install/update time and stages files.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Medium — manifest schema + loader logic |
| Cost | Free |
| Scalability | High — new platforms registered in manifest, not code |
| Team familiarity | Medium — requires understanding manifest schema |
| Zero-dependency | ✅ Still bash-only |

**Pros:**
- Platforms and packs declared in data, not code
- Easier to add a 7th platform without touching `lib/`

**Cons:**
- Adds a new abstraction layer with no user-visible benefit yet
- Manifest schema must be versioned alongside framework
- Today's platform list is stable (6 platforms); premature generalization

### Option C: npm/pip Package with Plugin API

A traditional package manager plugin system with a `package.json` and runtime hooks.

| Dimension | Assessment |
|-----------|------------|
| Complexity | High |
| Cost | Infra for npm registry or equivalent |
| Scalability | High |
| Team familiarity | High for JS/Python devs |
| Zero-dependency | ❌ Breaks core constraint |

**Pros:**
- Industry-standard plugin ecosystem
- Dependency resolution built in

**Cons:**
- Violates the zero-dependency constraint — users without Node/Python cannot run AgToosa
- Overkill for a markdown-file distribution system

---

## Trade-off Analysis

Option A wins because the zero-dependency constraint is non-negotiable. Option B is a valid future migration path once the platform count exceeds 8–10 and the manifest overhead pays off. Option C is ruled out permanently unless the zero-dependency constraint is deliberately lifted.

The key tension in Option A is **cross-platform skill sharing**: the skills system (`.claude/skills/`) is Claude Code-only and provides the most powerful extension surface (rigid-skill workflows, parallel agent dispatch). Until other platforms expose an equivalent API, skills remain Claude-exclusive and community packs must be designed around the lowest-common-denominator (markdown instruction files).

---

## Consequences

**Easier:**
- Adding new community packs — they follow the same file-staging model as core
- Auditing what AgToosa owns in a project — markers make boundaries explicit
- Offline installs — everything is file copies, no network calls needed

**Harder:**
- Sharing a skill across Claude Code and Copilot — requires two separate implementations (`.claude/skills/` vs `.github/prompts/`)
- Dynamic hook registration for Claude Code — currently requires rewriting `settings.json`
- Testing platform files in CI — requires mocking each platform's file system expectations

**Will need to revisit:**
- When Gemini CLI or Cursor exposes a hooks/events API equivalent to Claude Code's `Stop`/`PreToolUse`/`PostToolUse` — migrate to a unified hook-registration model (ties to ADR-003)
- When platform count exceeds 8 — evaluate Option B manifest approach
- Cross-platform skill sharing (v4 roadmap item)

---

## Action Items

1. [x] Ship platform-native entry-point model (v3.0.0)
2. [ ] Define file-type allowlist enforcement in `lib/registry.sh` (reject non-markdown pack files)
3. [ ] Document extension authoring guide: how to add a new platform template tree
4. [ ] Evaluate manifest-driven approach (Option B) when platform count reaches 8
5. [ ] Track Gemini CLI and Cursor hook API announcements for cross-platform hook unification
