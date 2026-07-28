# Spec: DEV-141 — Tracker Discovery & Bootstrap

> **Story ID:** DEV-141
> **Epic:** DEV-003 — Integrations
> **Status:** 🟦 Todo
> **Estimate:** L
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-051 · DEV-139

### Plan-Mode Spec Interview (findings)

| Area | Finding |
|------|---------|
| Authority | `docs/Master-Plan.md` remains SoT; bootstrap is proposal-only |
| Providers | GitHub bulk first; Linear via MCP envelope; repo-plans local |
| IDs | `DRAFT-NNN` in proposals; real IDs at `/agtoosa-task` accept |
| Init | Phase B.5 optional tributary — does not block init |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Inventory existing PM surfaces on brownfield adoption and render reviewable bootstrap proposals |
| Success condition | `discover` + `bootstrap` CLI; TBS-001–TBS-010 green; docs updated |
| Non-goals | Live bidirectional sync; OAuth in generator; auto Master-Plan writes |

### 1.2 Acceptance Criteria

| ID | Criterion | Priority |
|----|-----------|----------|
| AC-001 | `discover` emits `agtoosa.tracker-discovery/v1` without network | Must |
| AC-002 | `bootstrap` writes proposal only; no Master-Plan mutation | Must |
| AC-003 | `agtoosa:DEV-*` items classified `mirror_skip` | Must |
| AC-004 | GitHub bulk JSON merges and proposes `/agtoosa-task` hints | Must |
| AC-005 | Linear/repo-plan envelopes map with `unsupported` for gaps | Must |
| AC-006 | Init tributary preserves Master-Plan authority wording | Must |
| AC-007 | Claim boundary: no silent sync or core provider API | Must |
| AC-008 | TBS-001–TBS-010 pass including mutation guard | Must |

## 2. Design

`lib/tracker-discover.sh`, `lib/github-issues-discover.sh`, `Docs/AgToosa_TrackerSync.md` discover/bootstrap workflows.

## 3. Test Plan

`docs/AgToosa_TestPlan-DEV-141.md`
