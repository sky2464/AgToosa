# Spec: DEV-149 — Issues-Sync Dry-Run README Corruption

> **Story ID:** DEV-149
> **Epic:** DEV-139 — GitHub Issues PM Bridge / DEV-147 — Tracker CI Publish Hardening
> **Status:** 🏁 Shipped — v0.3.60; extended v0.3.62
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-08-27 (retroactive backfill — original fix shipped 2026-08-01 via PR #92; extension shipped 2026-08-02 as v0.3.62)

> **Backfill note:** Written after the fact to close a documentation gap flagged in the 2026-08-14/15 maintainer dream reports. DEV-149 shipped code, bats, and CHANGELOG entries across two releases but never received the `docs/archived/spec-*.md` / `review-*.md` / `evidence-*.md` quartet. Content reconstructed from `docs/archived/cycle-2026-08-01-release-5.3.60.md`, `CHANGELOG.md` v0.3.60/v0.3.62, and `tests/agtoosa.bats` GIS-011/012 + B33-001–006.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked, reconstructed from shipped artifacts)

| Checklist area | Finding |
|----------------|---------|
| Root cause (original) | `scripts/agtoosa-issues-sync.sh --dry-run` wrote to `README.md` as a side effect of manifest rendering, instead of only printing; repeat `--readme` publishes could leave a duplicate `AGTOOSA-ROADMAP:END` marker |
| Root cause (extension) | `agtoosa_prompt_read()` only handled the plain-TTY and always-`/dev/tty` cases; piped `curl \| bash` bootstrap left stdin on the script, so `read -p` exited immediately or read EOF instead of waiting on the user |
| Wave (original) | Bundled with DEV-147 and DEV-148 into PR #92, shipped as v0.3.60 |
| Wave (extension) | Shipped independently as v0.3.62, alongside `lib/cleanup.sh`/`lib/reinstall.sh` TTY-usable checks |

#### Documented assumptions

- Both the original README-guard fix and the later stdin-mode hardening are tracked under DEV-149 because Master-Plan and the CHANGELOG both describe the v0.3.62 change as "DEV-149 extended" rather than allocating a new DEV ID.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | `--dry-run` never mutates README; repeat publishes never duplicate the roadmap marker; piped bootstrap installs can still prompt the user via `/dev/tty` |
| User outcome | CI dry-runs are side-effect-free; `curl \| bash` installs don't silently fail on interactive prompts |
| Success condition | GIS-011/012 green (original); B33-001–006 green (extension) |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-149.md` |
| Non-goals | Redesigning the README roadmap block format; supporting stdin-less fully-silent installs (that's `--yes`/`--path`, a separate surface) |
| Assumptions | `/dev/tty` is available in the pipe-bootstrap case on the platforms AgToosa targets (Linux, macOS, WSL, Git Bash) |
| Risks | A future refactor of `agtoosa_prompt_read` could regress one of the three stdin modes without touching the others — B33-001–006 exist specifically to catch that |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer running CI, **I want** `--dry-run` to never touch README **so that** dry-run checks are safe to run repeatedly without polluting git diffs.

**As a** new user running the piped `curl \| bash` install, **I want** interactive prompts to still work **so that** the one-line install doesn't silently hang or fail when stdin is the script itself.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa-issues-sync.sh --dry-run` runs THE SYSTEM SHALL leave README byte-for-byte unchanged | Must |
| AC-002 | WHEN `--tracker publish --readme` runs twice in a row THE SYSTEM SHALL keep exactly one `AGTOOSA-ROADMAP:END` marker | Must |
| AC-003 | WHEN stdin is not a TTY (pipe bootstrap) THE SYSTEM SHALL route prompts through `/dev/tty` when available | Must |
| AC-004 | WHEN stdin is a TTY THE SYSTEM SHALL prompt interactively as before | Must |
| AC-005 | WHEN stdin is a script file being piped answers (not a bootstrap pipe) THE SYSTEM SHALL still read the piped answer | Must |
| AC-006 | WHEN neither a TTY nor `/dev/tty` is available THE SYSTEM SHALL exit non-zero with a `--path`/`--yes` non-interactive hint | Should |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `agtoosa-issues-sync.sh --dry-run` | generator-enforced | Local manifest render only, no README writes |
| `agtoosa_prompt_read` stdin mode detection | generator-enforced | Best-effort `/dev/tty` fallback; no guarantee on TTY-less CI containers |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `scripts/agtoosa-issues-sync.sh` | `--dry-run` short-circuits before any README write |
| README marker merge logic | De-dupe `AGTOOSA-ROADMAP:END` on repeat publish |
| `lib/config.sh` | `agtoosa_prompt_read` + `_agtoosa_tty_usable` — three-mode stdin handling |
| `lib/cleanup.sh`, `lib/reinstall.sh` | Route path prompts through `agtoosa_prompt_read` / `_agtoosa_tty_usable` |
| `agtoosa.ps1` | `Read-AgToosaPrompt` — PowerShell parity |

### 2.2 Build Scope

**Files in scope:** `scripts/agtoosa-issues-sync.sh`, `lib/config.sh`, `lib/cleanup.sh`, `lib/reinstall.sh`, `lib/maintain.sh`, `agtoosa.sh`, `agtoosa.ps1`

**Out of scope:** Non-interactive `--yes`/`--path` flag semantics (pre-existing, unchanged)

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** README dry-run guard (original, v0.3.60)
  - [x] 1.1 `--dry-run` no longer writes README — _AC-001_
  - [x] 1.2 De-dupe `AGTOOSA-ROADMAP:END` on repeat publish — _AC-002_
- [x] **2.** Piped bootstrap stdin hardening (extension, v0.3.62)
  - [x] 2.1 `agtoosa_prompt_read` three-mode stdin handling — _AC-003, AC-004, AC-005, AC-006_
  - [x] 2.2 Wire `_agtoosa_tty_usable` into `cleanup.sh`/`reinstall.sh`/`maintain.sh` — _AC-003_
  - [x] 2.3 PowerShell `Read-AgToosaPrompt` parity — _AC-003_

### 3.2 Test Plan

- `docs/archived/testplans/AgToosa_TestPlan-DEV-149.md`

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | Pass — AC-001/002 via GIS bats; AC-003–006 via B33 bats |
| Goal / Non-goals / AC / tasks aligned | Pass |
| Must AC → test plan mapping | Pass — GIS-011/012, B33-001–006 |
| Claim Boundary classified | Pass — §1.4 |
| Master-Plan authority preserved | Pass — row unchanged, this spec documents already-shipped state |
| No TBD placeholders | Pass |

## 🏁 Shipped

Shipped: 2026-08-01 — v0.3.60, PR #92 (original). Extended: 2026-08-02 — v0.3.62 (piped-bootstrap stdin hardening). Spec backfilled 2026-08-27 per dream-report Priority 1 finding.
