# ADR-012: Lifecycle Next-Step Sync + Clarity Tags

**Status:** Accepted  
**Date:** 2026-07-12  
**Deciders:** AI agent + human review (DEV-109)

## Context

AgToosa’s core product promise is Spec → Build → Review → Ship. After earlier closure-loop work, phase commands print a universal line that pushes `/agtoosa-status`. That verifies health, but it often becomes the *default next step* users and agents chase — obscuring the lifecycle. Separately, when users ask agents to learn objectives and split work into multiple specs, nothing forces Plan-Mode Spec Interview per child story, so clarity interviews are skipped.

`/agtoosa-help next` already encodes lifecycle ordering, but it is on-demand assistance and easy to miss. Status Part 5.5 ranks findings, not phase progression.

## Decision

1. **Dual-line phase close:** After Spec / Build / Review / Ship success, print a **primary lifecycle next command**, then an automatic **executive SYNC pulse** (not “go run full status” as the headline).
2. **Generator `--status-line` / `-StatusLine`:** Bash and PowerShell Must parity for the same one-line pulse format, reading Master-Plan first.
3. **Clarity tags** on Master-Plan story rows (optional `Clarity` column) and spec headers: canonical `ready` · `sa-ready` · `needs-interview` (aliases `Ready` · `SA-R` · `N-CI`), combinable.
4. **Multi-spec intake:** Propose a story map; choose small (interview now, parallel when `sa-ready`) vs large (portfolio clarity now, children tagged `needs-interview` until interviewed).
5. **Soft interview budget:** Default 8, then +4; when the user types new directions (not a menu pick), +4 **may repeat** until Decision-complete or explicit assumption acceptance. Never auto-write a final detailed spec while Must clarity gaps or `needs-interview` remain.

## Consequences

- **Positive:** Users and agents stay oriented on Spec → Build → Review → Ship; multi-spec work cannot silently skip interviews.
- **Positive:** Scripts/CI can stay in sync via `--status-line` without loading the full dashboard.
- **Negative:** Master-Plan template gains an optional Clarity column; bats and PS1 maintain surfaces grow.
- **Follow-up:** DEV-109 implements docs, CLI, adapters, and contract bats. Full `/agtoosa-status` remains the deep health tool.
