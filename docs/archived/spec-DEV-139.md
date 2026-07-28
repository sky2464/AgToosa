# Spec: DEV-139 — GitHub Issues PM Bridge (Phased B)

> **Story ID:** DEV-139
> **Epic:** DEV-003 — Integrations · DEV-004 — Testing & QA Harness
> **Status:** 🏁 Shipped — v5.3.52
> **Estimate:** L
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-051 — Tracker Sync Bridge

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Status quo | GitHub Issues dormant (#7–#23 closed); Master-Plan runs DEV-138+ lifecycle; DEV-051 ships local export/propose only |
| Authority | `docs/Master-Plan.md` remains SoT; GitHub Issues are public mirror + contributor intake queue |
| Security | Reuse DEV-051 untrusted-input redaction; CI uses scoped `GITHUB_TOKEN`; no OAuth in generator |
| Naming | GitHub-standard title prefixes (`feat:`, `fix:`, `chore:`); `agtoosa:DEV-XXX` label for machine link — not title prefix |
| Stale docs | `.github/PROJECT.md` still claims Linear authority — must reconcile |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Primary outcome scope tier | **B phased** — outbound publish + inbound proposals v1; gh transport/webhooks roadmap |
| Q2 | Delivery shape | **B phased** — Phase 1 outbound + Phase 2 inbound; Phase 3 polish Should/roadmap |
| Q3 | First consumer | **Maintainer dogfood + template pack** |
| Q4 | Outbound sync trigger | **CI on `main` when Master-Plan.md changes** |
| Q5 | Rows mirrored | **Active cycle + all non-shipped backlog** |
| Q6 | Inbound community model | **Hybrid A+B** — proposal-only + backlog draft; GitHub-standard titles |
| Q7 | Public surface | **B+C combo** — Issues + labels/milestones + README roadmap block |

#### Documented assumptions

- Projects v2 kanban deferred to Phase 3 / roadmap; v1 uses Issues + milestones only.
- Classic `auto-project-assign.yml` retired in favor of `agtoosa-issues-sync.yml`.
- Template workflows ship as `.example` opt-in copies.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Evolve DEV-051 into a GitHub Issues PM bridge that publishes Master-Plan state to public Issues and renders community intake as reviewable proposals — without surrendering repo authority. |
| User outcome | Contributors see a live, professional Issues board and roadmap; maintainers govern changes through existing AgToosa workflows. |
| Success condition | `--tracker publish` emits deterministic manifest; CI upserts Issues on Master-Plan change; intake produces proposal + backlog draft; GIS-001–GIS-010 green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-139.md`; bats GIS-001–GIS-010; workflow files; template mirrors. |
| Non-goals | Projects v2 kanban v1; silent two-way sync; GitHub as PM authority; syncing all historical DEV rows |
| Assumptions | `gh` available in CI; `jq` for manifest rendering; DEV-051 export envelope stable |
| Risks | Issue sprawl from full backlog mirror; stale classic Projects workflow; title/label drift |
| Unresolved questions | None — interview complete |

### 1.2 User Stories

**As an** open-source contributor, **I want** GitHub Issues to reflect AgToosa's real backlog **so that** I can discover and claim work without reading internal-only docs.

**As a** maintainer, **I want** community Issues turned into backlog draft proposals **so that** intake stays governed without silent Master-Plan writes.

**As a** downstream AgToosa user, **I want** opt-in workflow examples **so that** I can mirror my own Master-Plan to GitHub Issues.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `--tracker publish` reads a valid project THE SYSTEM SHALL emit an `agtoosa.github-issues-manifest/v1` JSON manifest from the tracker export without network calls | Must |
| AC-002 | WHEN the manifest renders issue titles THE SYSTEM SHALL use GitHub-standard type prefixes and SHALL NOT prefix titles with `DEV-XXX:` | Must |
| AC-003 | WHEN `main` receives a Master-Plan change THE CI workflow SHALL upsert Issues for active cycle and non-shipped backlog stories and close Issues for shipped active-cycle stories | Must |
| AC-004 | WHEN publish runs with `--readme` THE SYSTEM SHALL update the bounded `AGTOOSA-ROADMAP` block in README.md from the export envelope | Must |
| AC-005 | WHEN `--tracker intake` receives a community issue envelope THE SYSTEM SHALL write a proposal artifact and SHALL NOT mutate Master-Plan.md | Must |
| AC-006 | WHEN intake processes a community issue THE proposal SHALL include a ready-to-paste Master-Plan backlog row and `/agtoosa-task` hint | Must |
| AC-007 | WHEN claim boundaries are documented THE SYSTEM SHALL state Master-Plan wins and SHALL NOT claim live bidirectional sync | Must |
| AC-008 | WHEN template pack ships THE SYSTEM SHALL include opt-in `agtoosa-issues-sync.yml.example` and TrackerSync publish/intake docs | Must |
| AC-009 | WHEN DEV-139 is verified THE SYSTEM SHALL pass GIS-001–GIS-010 including Master-Plan mutation guard | Must |
| AC-010 | WHEN `.github/PROJECT.md` is updated THE SYSTEM SHALL remove stale Linear authority language | Should |

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | Manifest non-deterministic across identical export | Stable sort by story_id; exclude volatile fields from digest |
| FM-002 | AC-005 | Intake mutates Master-Plan | Fail mutation guard; proposal-only output |
| FM-003 | AC-003 | Shipped story Issue stays open | Emit `state: closed` for shipped active-cycle rows |
| FM-004 | AC-002 | DEV prefix in title | Reject in GIS-002; use label `agtoosa:DEV-XXX` |
| FM-005 | AC-007 | False "live sync" marketing | Claim boundary table in TrackerSync doc |

### 1.5 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `--tracker publish` manifest render | generator-enforced | Local files only |
| `--tracker intake` proposal render | generator-enforced | Local files only |
| CI `agtoosa-issues-sync.yml` gh upsert | provider-enforced | GitHub Actions + `GITHUB_TOKEN` |
| CI `agtoosa-issues-intake.yml` comment | provider-enforced | GitHub Actions |
| Accepting intake proposals | manual authorization | `/agtoosa-task` or explicit edit |
| Live webhook bidirectional sync | **not in v1** | Roadmap Phase 3 |

### 1.6 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Forged issue body injects backlog row | Tampering | Intake treats body as untrusted; redact secrets/paths (DEV-051) |
| CI token exfiltration via issue body | Information disclosure | No echo of tokens; scoped `issues: write` only |
| Duplicate Issues on re-sync | Repudiation | Upsert key: `agtoosa:DEV-XXX` label + HTML comment `agtoosa-story-id` |
| Manifest DoS | Denial of service | Reuse `TRACKER_MAX_*` bounds |
| Spoofed community issue as sync issue | Spoofing | Skip intake when `agtoosa:DEV-*` label present |

## 2. Design

### 2.1 Publish pipeline

```
Master-Plan.md → tracker_export → github_issues_render_manifest → CI gh upsert
                                              ↓
                                    README AGTOOSA-ROADMAP block
```

### 2.2 Issue payload shape

| Field | Source |
|-------|--------|
| `title` | `{type_prefix}: {story title}` — no DEV prefix |
| `labels` | `agtoosa:{story_id}`, `source:agtoosa-sync`, status + type labels |
| `state` | `open` unless shipped active-cycle row → `closed` |
| `milestone` | Project Charter milestone for active-cycle stories |
| `body` | Spec link, AC checklist mirror, footer with `<!-- agtoosa-story-id: DEV-XXX -->` |

### 2.3 Intake pipeline

```
issues.opened (no agtoosa:DEV-* label) → issue JSON → --tracker intake → proposal.md + gh comment
```

### 2.4 Scope Boundary

**In scope:** `lib/github-issues.sh`, `agtoosa.sh`/`agtoosa.ps1` publish+intake, `scripts/agtoosa-issues-sync.sh`, `.github/workflows/agtoosa-issues-*.yml`, README roadmap, template mirrors, docs hygiene.

**Out of scope:** Projects v2, OAuth, webhook server, Linear/Jira adapters.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Contract and fixtures (GIS RED)
  - [x] 1.1 Add GIS-001–GIS-010 RED tests and intake/publish fixtures — _AC-009_
- [x] **2.** Publish core
  - [x] 2.1 Implement `lib/github-issues.sh` manifest + README renderer — _AC-001, AC-002, AC-004_
  - [x] 2.2 Wire `--tracker publish` and `--tracker intake` in agtoosa.sh/ps1 — _AC-001, AC-005_
- [x] **3.** CI outbound
  - [x] 3.1 Add `scripts/agtoosa-issues-sync.sh` + `agtoosa-issues-sync.yml` — _AC-003_
  - [x] 3.2 Retire classic `auto-project-assign.yml`; update PROJECT.md — _AC-010_
- [x] **4.** CI inbound
  - [x] 4.1 Add `agtoosa-issues-intake.yml` with proposal comment — _AC-005, AC-006_
- [x] **5.** Template + docs
  - [x] 5.1 Ship template workflow example + TrackerSync publish/intake sections — _AC-007, AC-008_
  - [x] 5.2 Update TRIAGE.md; extend schema; config inventory — _AC-007_

### 3.2 Wave Plan

- **Wave 1:** 1.1, 2.1
- **Wave 2:** 2.2, 3.1
- **Wave 3:** 3.2, 4.1, 5.1, 5.2

### 3.3 Test Plan

- Test plan: `docs/AgToosa_TestPlan-DEV-139.md`
- AC coverage: AC-001–AC-010 → GIS-001–GIS-010

## ✅ Spec Approved

Approved for build on 2026-07-28 per maintainer implementation request (phased B plan).
