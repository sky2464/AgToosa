# Spec: DEV-155 — Cross-Platform Fallback Guidance for Unrecognized `/agtoosa-*` Commands

> **Story ID:** DEV-155
> **Epic:** DEV-004 — Testing & QA Harness
> **Type:** Fix
> **Status:** 🟦 Todo — Build Complete
> **Estimate:** S
> **Clarity:** `ready`
> **Priority:** P1
> **Parent / extends:** none
> **Spec created:** 2026-08-27
> **Ship target:** next patch after v0.3.63

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Native `/agtoosa-*` slash commands are discovered only by a platform's CLI/IDE session (`.claude/commands/`, `.cursor/commands/`, etc.); a different surface for the same assistant (web chat, non-interactive/cloud session) reads project files as plain context but does not register them as invokable commands |
| Status quo | User reported `/agtoosa-init` returning "isn't a recognized command here" in a non-CLI Claude surface, after a normal Claude Code platform install into a downstream project |
| Root cause confirmed | `template/.claude/commands/agtoosa-init.md` is a one-line dispatcher to `Docs/AgToosa_Init.md`, which is pure prose with no CLI dependency — a plain-language request is a fully viable fallback whenever the native picker isn't loaded |
| Existing principle, no implementation | `docs/agtoosa-maintainer.md` → Per-Platform Parity already states "if a platform truly lacks a per-command native format, document the fallback in its entry-point file," but a repo-wide search found zero entry-point files implementing it |
| Security | No new trust boundary — docs-only guidance plus one new CLI-printed string; no secrets, no network, no new write surface |
| Non-goals | Detecting which surface is active at runtime; changing how native command pickers are generated; fixing the two pre-existing unrelated bats failures found during validation |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Fix scope: CLI-output-only, targeted (CLI + central doc), or full per-platform parity? | **Full per-platform parity** — replicate identical fallback guidance across every platform entry point, matching this repo's existing cross-variant string convention |

#### Documented assumptions

- Confirmed via Plan Mode (AskUserQuestion) rather than a separate `/agtoosa-spec` interview turn; this file retroactively captures that approval in the standard spec format so the story satisfies the same lifecycle gate as any other Active Cycle entry.
- S estimate — six small, mechanical doc/string edits plus 2 bats tests; no generator logic branching changes.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Whenever a native `/agtoosa-*` command isn't recognized by the current assistant surface, the user (or the assistant on their behalf) has a documented, discoverable plain-language fallback |
| User outcome | A user who hits "not a recognized command" in any non-CLI/non-native surface can still complete the workflow by asking in plain language |
| Success condition | DEV-155 AC-001–AC-006 bats/parity checks green; no regressions vs. pre-change baseline |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-155.md`; bats: 2 new `@test` blocks in `tests/agtoosa.bats` |
| Non-goals | Runtime surface detection; auto-invoking workflows without user intent; fixing pre-existing unrelated bats failures |
| Assumptions | The underlying workflow docs (`Docs/AgToosa_*.md`) are already surface-agnostic prose; only discoverability of the fallback was missing |
| Risks | Drift if a future platform entry point is added without the same fallback section (mitigated by the new maintainer parity-table row) |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN the generator finishes an install or update THE SYSTEM SHALL print a "Next steps" tip explaining that an unrecognized `/agtoosa-init` can be run by asking the assistant to read `Docs/AgToosa_Init.md` directly |
| AC-002 | Must | WHEN `Docs/AgToosa_Agent.md` → Project Intake Protocol is read THE SYSTEM SHALL state that a plain-language request is equivalent to an unrecognized native `/agtoosa-*` command |
| AC-003 | Must | WHEN any of the 6 platform entry-point files (`CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `AGENTS.md`, `OPENCODE.md`, `.github/copilot-instructions.md`) is generated THE SYSTEM SHALL include an identical `## If a Command Isn't Recognized` section |
| AC-004 | Must | WHEN a maintainer consults `docs/agtoosa-maintainer.md` THE SYSTEM SHALL list the new fallback string in the User-Facing Strings parity table and note it as the first implemented Per-Platform Parity fallback example |
| AC-005 | Must | WHEN `bats tests/agtoosa.bats` runs THE SYSTEM SHALL verify the CLI tip (AC-001) and all 6 entry-point fallback sections (AC-003) via dedicated `@test` blocks |
| AC-006 | Must | WHEN DEV-155 ships THE SYSTEM SHALL show zero new bats regressions relative to the pre-change baseline (2 pre-existing, unrelated failures — `--update detects installed Claude platform and merges CLAUDE.md`, `SAU-003` — excluded, confirmed via git-stash baseline) |

### 1.3 Scope Boundary

**In scope:** `lib/install.sh`, `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md`, `template/CLAUDE.md`, `template/.cursorrules`, `template/.windsurfrules`, `template/AGENTS.md`, `template/OPENCODE.md`, `template/.github/copilot-instructions.md`, `docs/agtoosa-maintainer.md`, `tests/agtoosa.bats`, `docs/Master-Plan.md`, `CHANGELOG.md`.

**Out of scope:** Runtime detection of which assistant surface is active; changes to native command-picker generation logic (`.claude/commands/`, `.cursor/commands/`, etc.); the two pre-existing unrelated bats failures surfaced during validation; the user's own downstream `DreamToosa` project (out of Maintainer Dogfood Mode scope — advised as a manual workaround instead).

## 2. Design

### 2.1 CLI-side hint

`lib/install.sh`, next-steps print block: one additional `echo` line after the existing "Next steps" output, printed unconditionally (all `SMART_UPGRADE_MODE` branches converge before it).

### 2.2 Central doc

`template/Docs/AgToosa_Agent.md` → Project Intake Protocol: new **Native command unavailable** bullet directly after the existing **Slash wins** bullet. Mirrored into `docs/AgToosa_Agent.md` with `Docs/` → `docs/` path rewrite per the existing mirroring convention.

### 2.3 Platform entry points

Identical `## If a Command Isn't Recognized` section inserted between the existing `## Core Commands` and `## Key References` sections in all 6 entry-point files — verbatim heading and body, satisfying the "User-Facing Strings That Must Match Across Variants" convention.

### 2.4 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| N/A — docs/string-only change | No new trust boundary, no secrets, no network calls, no new write surface. The fallback text only tells the assistant to read files it could already read. |

### 2.5 Build Scope

| Surface | Change |
|---------|--------|
| `lib/install.sh` | New CLI tip line in next-steps output |
| `template/Docs/AgToosa_Agent.md` / `docs/AgToosa_Agent.md` | New Project Intake bullet |
| `template/CLAUDE.md`, `.cursorrules`, `.windsurfrules`, `AGENTS.md`, `OPENCODE.md`, `.github/copilot-instructions.md` | New `## If a Command Isn't Recognized` section |
| `docs/agtoosa-maintainer.md` | New parity-table row + Per-Platform Parity note |
| `tests/agtoosa.bats` | 2 new `@test` blocks |
| `docs/Master-Plan.md`, `CHANGELOG.md` | Story bookkeeping |

## 3. Tasks

- [x] **1.** CLI "Next steps" fallback tip — _AC-001_
- [x] **2.** Central Project Intake fallback bullet (+ template mirror) — _AC-002_
- [x] **3.** Identical fallback section in all 6 platform entry points — _AC-003_
- [x] **4.** Maintainer parity-table row + Per-Platform Parity note — _AC-004_
- [x] **5.** Bats coverage (2 new tests) — _AC-005_
- [x] **6.** Master-Plan / CHANGELOG bookkeeping — _AC-006_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-155.md`.

---

## ✅ Spec Approved

Approved via Plan Mode (AskUserQuestion scope confirmation) — 2026-08-27 — ready for build; build completed same session.
