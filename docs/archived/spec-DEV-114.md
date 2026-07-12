# Spec: DEV-114 — `--cleanup` False-Positive Hotfix

> **Story ID:** DEV-114  
> **Epic:** DEV-001 — Core Generator Engine  
> **Status:** Shipped  
> **Estimate:** S  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  

## Context

miToosa `--cleanup --yes` (v5.3.24) removed 55 files. Twenty merge backups were correct; thirteen `Docs/AgToosa_TestPlan-*` story test plans and twenty-two Copilot `.github/prompts/agtoosa-*` files were false positives.

## Requirements

| ID | Criterion |
|----|-----------|
| AC-001 | When `copilot` is in `platforms[]`, shared `.github/prompts` / `.github/agents` are not flagged as `vscode` orphans |
| AC-002 | When `vscode` is in `platforms[]`, shared paths are not flagged as `copilot` orphans (existing behavior preserved) |
| AC-003 | `Docs/AgToosa_TestPlan-*` never classified as `orphan_doc` |
| AC-004 | True orphan framework docs (e.g. removed template workflows) still flagged |
| AC-005 | CLN-012–CLN-014 bats green |
| AC-006 | `AgToosa_Update.md` documents exclusions and `--dry-run` guidance |

## Implementation

- [`lib/cleanup.sh`](../lib/cleanup.sh): `_cleanup_github_prompts_owner_selected`; symmetric copilot/vscode skip; `AgToosa_TestPlan-*` exclude in `_cleanup_collect_orphan_docs`
- [`template/Docs/AgToosa_Update.md`](../template/Docs/AgToosa_Update.md): Cleanup section clarity

## Test Plan

See [`docs/AgToosa_TestPlan-DEV-114.md`](../AgToosa_TestPlan-DEV-114.md) — CLN-012–CLN-014.

## miToosa recovery (manual)

```bash
cd /path/to/miToosa
git checkout -- Docs/AgToosa_TestPlan-*.md   # if version-controlled
bash agtoosa.sh --path . --yes               # restore Copilot agtoosa prompts
```
