# Spec: DEV-141 — Tracker Discovery & Bootstrap

> **Story ID:** DEV-141
> **Epic:** DEV-003 — Integrations
> **Status:** 🏁 Shipped — v5.3.55
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
| As-built | `lib/tracker-discover.sh`, `lib/github-issues-discover.sh`, CLI discover/bootstrap shipped in 7f91f8a; TBS-001–010 green |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Inventory existing PM surfaces on brownfield adoption and render reviewable bootstrap proposals |
| User outcome | Run discover/bootstrap (or init tributary), accept rows via `/agtoosa-task`, then normal lifecycle |
| Success condition | `discover` + `bootstrap` CLI; TBS-001–TBS-010 green; init + TrackerSync docs updated |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-141.md`; bats TBS-001–TBS-010 |
| Non-goals | Live bidirectional sync; OAuth in generator; auto Master-Plan writes |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `discover` runs THE SYSTEM SHALL emit `agtoosa.tracker-discovery/v1` from local repo signals without network | Must |
| AC-002 | WHEN `bootstrap` runs THE SYSTEM SHALL write a proposal artifact and SHALL NOT mutate Master-Plan | Must |
| AC-003 | WHEN items carry `agtoosa:DEV-*` THE SYSTEM SHALL classify as `mirror_skip` or exclude at merge | Must |
| AC-004 | WHEN GitHub bulk JSON is supplied THE SYSTEM SHALL merge into discovery and propose backlog rows with `/agtoosa-task` hints | Must |
| AC-005 | WHEN Linear/repo-plan items are supplied via envelope THE SYSTEM SHALL map known fields and mark unmapped as `unsupported` | Must |
| AC-006 | WHEN init tributary is documented THE SYSTEM SHALL NOT contradict Master-Plan authority | Must |
| AC-007 | WHEN claim boundaries are documented THE SYSTEM SHALL NOT claim silent sync or provider API in core | Must |
| AC-008 | WHEN verified THE SYSTEM SHALL pass TBS-001–TBS-010 including mutation guard | Must |

### 1.3 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `discover` / `bootstrap` | generator-enforced | Local files only |
| GitHub/Linear fetch | manual / agent-instructed | MCP or `gh` outside core |
| Master-Plan | repo-local SoT | Wins every conflict |

## 2. Design

- `lib/tracker-discover.sh` — local heuristics, bootstrap reconcile, proposal render
- `lib/github-issues-discover.sh` — GitHub/Linear fetch → discovery items
- `agtoosa.sh --tracker discover|bootstrap`
- Schema: `agtoosa.tracker-discovery/v1`, fetch envelopes in `agtoosa-tracker-sync.schema.json`
- Docs: `AgToosa_TrackerSync.md`, `AgToosa_Init.md` Phase B.5

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Schema and discover core
  - [x] 1.1 Discovery + fetch envelope schemas — _AC-001_
  - [x] 1.2 `tracker_discover` local signals + repo-plans — _AC-001, AC-005_
- [x] **2.** Bootstrap proposal
  - [x] 2.1 `tracker_bootstrap` classify + render + mutation guard — _AC-002, AC-003_
- [x] **3.** GitHub bulk merge
  - [x] 3.1 `github_issues_items_from_fetch` + discover `--input` — _AC-004_
- [x] **4.** Docs and init
  - [x] 4.1 TrackerSync + Init tributary + Linear MCP recipe — _AC-006, AC-007_
  - [x] 4.2 Workflow example `agtoosa-issues-bootstrap.yml.example` — _AC-004_
- [x] **5.** Bats TBS-001–TBS-010 — _AC-008_

### 3.2 Wave Plan

- **Wave 1:** 1.1, 1.2, 2.1
- **Wave 2:** 3.1, 4.1
- **Wave 3:** 4.2, 5

### 3.3 Test Plan

- `docs/AgToosa_TestPlan-DEV-141.md`

## ✅ Spec Approved

Approved: 2026-07-28 23:25 — served by `/agtoosa-next` (Sequential Approval; TBS suite green).
