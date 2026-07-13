# Spec: DEV-115 — `--cleanup` Safety Follow-Up

> **Story ID:** DEV-115  
> **Epic:** DEV-001 — Core Generator Engine  
> **Status:** Shipped  
> **Estimate:** S  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  

## Context

DEV-114 review follow-ups: safer incremental cleanup, preserve user Claude hooks, and negative-test coverage for deselected GitHub platforms.

## Requirements

| ID | Criterion |
|----|-----------|
| AC-001 | `--only backups` with `--cleanup` collects merge backups only |
| AC-002 | `.claude/settings.json` never whole-file deleted on deselected claude |
| AC-003 | CLN-015 proves shared prompts flagged when neither copilot nor vscode selected |
| AC-004 | CLN-016–CLN-017 bats green |
| AC-005 | `AgToosa_Update.md` documents `--only backups` and settings.json preservation |

## Implementation

- [`lib/cleanup.sh`](../lib/cleanup.sh): `CLEANUP_ONLY=backups` gate; remove `settings.json` from claude orphan paths
- [`agtoosa.sh`](../agtoosa.sh): `--only backups` parsing and validation
- [`template/Docs/AgToosa_Update.md`](../template/Docs/AgToosa_Update.md): cleanup guidance

## Test Plan

See [`docs/AgToosa_TestPlan-DEV-115.md`](../AgToosa_TestPlan-DEV-115.md) — CLN-015–CLN-017.
