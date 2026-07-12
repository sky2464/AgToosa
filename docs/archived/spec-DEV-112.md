# Spec: DEV-112 — `--cleanup` Executable

> **Story ID:** DEV-112  
> **Epic:** DEV-001 — Core Generator Engine  
> **Status:** 🏁 Shipped  
> **Estimate:** S  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  

## Context

After repeated upgrades, downstream projects accumulate AgToosa-owned clutter: merge backups (`*.bak.*`), workflow docs removed from the template, and files for deselected platforms. Users were warned about backups but had no safe removal path. `--reinstall --clean` is a different, heavier operation.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Offer opt-in removal of unnecessary AgToosa-owned files after upgrade or via standalone CLI. |
| User outcome | Users preview candidates, confirm once, and remove backups/orphans without touching user Context, Master-Plan, or changelog. |
| Success condition | `bash agtoosa.sh --cleanup` with dry-run/JSON/yes modes; post-apply offer; doctor hint; CLN-001–CLN-011 bats green. |

### 1.2 Acceptance Criteria

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | Scan merge backups `*.bak.*` (full tree) |
| AC-002 | Must | Scan orphan `Docs/AgToosa_*.md` not in template (preserve changelog) |
| AC-003 | Must | Scan deselected platform outputs from lock `platforms[]` |
| AC-004 | Must | Interactive confirm or `--yes`; non-TTY refuses without `--yes` |
| AC-005 | Must | `--dry-run` and `--format json` (`cleanup-result-v1`) |
| AC-006 | Should | Post install/upgrade offer when candidates exist |
| AC-007 | Should | `--doctor` `DR-stale-files` recommends `--cleanup` |
| AC-008 | Must | PS1 `-Cleanup` parity |
| AC-009 | Must | `vscode` platform modeled; CLN-011 no false orphan |
| AC-010 | Must | CLN-001–CLN-011 bats coverage |

## 2. Implementation

- `lib/cleanup.sh`: collect/plan/apply + `offer_cleanup_after_apply`
- `agtoosa.sh` / `agtoosa.ps1`: `--cleanup` / `-Cleanup` dispatch
- `lib/install.sh`, `lib/update.sh`: post-apply offer hook
- `lib/maintain.sh`: doctor stale-files finding
- `lib/lock.sh`, `lib/state.sh`: `vscode` in platform lists
- `Docs/schemas/cleanup-result-v1.json` in template + docs mirrors
- `template/Docs/AgToosa_Update.md`: Cleanup section

## 3. Test Plan

See `docs/AgToosa_TestPlan-DEV-112.md` — CLN-001–CLN-011.

## 4. Out of Scope (v1)

- Stale `agtoosa-*` in active platform dirs (category D)
- Old `.agtoosa/reinstall-archive/` (category E)
