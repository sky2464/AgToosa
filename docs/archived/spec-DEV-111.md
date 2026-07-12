# Spec: DEV-111 — Smart One-Command Install UX

> **Story ID:** DEV-111  
> **Epic:** DEV-001 — Core Generator Engine  
> **Status:** 🏁 Shipped  
> **Estimate:** M  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  

## Context

Re-running `agtoosa.sh` on an existing project confused users: install vs `--update` vs `--force`, noisy skip messages, and full platform re-selection every run. Goal: one command that "just works" — auto-detect upgrade, show detected platforms, optional add-more, smart per-file policy without exposing `--force` in interactive UX.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Plain `agtoosa.sh` on an existing install upgrades in place with clear human summary buckets and no `--force` ceremony. |
| User outcome | Users re-run one command; see Found platforms, optionally add more; filled project docs preserved; placeholder Context refreshed. |
| Success condition | `smart_apply()` unifies interactive + `--update`; SAU-001–SAU-010 bats green; PS1 parity for detect + summary UX. |

### 1.2 Acceptance Criteria

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | Existing install (`.agtoosa-version` or `AgToosa_Agent.md`) auto-enters upgrade mode |
| AC-002 | Must | Platform UX: show `Found:` detected platforms; Enter keeps; numbers union add |
| AC-003 | Must | `smart_apply()` handles interactive install and `--update` |
| AC-004 | Must | Master-Plan, Changelog, Architecture preserved without `--force` |
| AC-005 | Must | Populated Context preserved; placeholder Context refreshed |
| AC-006 | Must | Summary buckets: Updated / Preserved / Unchanged / Merged (no `--force` hint) |
| AC-007 | Must | `--force` still works non-interactively (`--yes --force`) for CI |
| AC-008 | Should | PS1 upgrade detect + platform prompt + Context smart guard |
| AC-009 | Must | SAU-001–SAU-010 bats coverage |

## 2. Implementation

- `lib/apply.sh`: `smart_apply()`, `detect_existing_agtoosa()`, `context_is_placeholder_file()`, `emit_apply_summary_human()`, platform union helpers
- `agtoosa.sh`: upgrade routing, platform prompt, welcome text
- `lib/copy.sh`, `lib/install.sh`, `lib/update.sh`, `lib/plan.sh`: preserve/refresh policy + messages
- `agtoosa.ps1`: PS1 parity
- `docs/AgToosa_Update.md`: one-command smart apply section

## 3. Test Plan

See `docs/AgToosa_TestPlan-DEV-111.md` — SAU-001–SAU-010.

## 4. Capability Delta

_None — UX/policy enhancement within existing install engine (DEV-090)._
