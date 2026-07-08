# Spec: DEV-049 — Evidence Ledger

> **Story ID:** DEV-049
> **Epic:** DEV-004
> **Status:** 🏁 Shipped (v5.3.4)
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa already records RED/GREEN and IMPORT evidence in story test plans, phase events in `agtoosa-events.jsonl`, and review reports under `docs/archived/`. There is no single per-story proof index that auditors can open after ship. DEV-049 adds that index as **agent-instructed** docs: a canonical markdown ledger plus an optional JSONL mirror.

### Brownfield Spec Drift Baseline

| Field | Value |
|-------|-------|
| User outcome / proof | Every shipped story has `docs/archived/evidence-[story-id].md`; Review/Ship require updates; bats prove dual-path docs + wiring |
| Repo evidence inventory | Test plans (RED/GREEN/IMPORT); `docs/agtoosa-events.jsonl`; `docs/AgToosa_Import.md`; review-*.md; stub spec-DEV-049 |
| Current-state baseline | No `AgToosa_Evidence.md`; no `evidence-*.md` schema; Roadmap lists DEV-049 backlog; Import defers ledger to DEV-049 |
| Intended change deltas | Evidence workflow doc; markdown schema; optional JSONL seed + schema; Review/Ship gate wiring; EL bats; config registration |
| Drift evidence | Stub meta-ACs → functional EARS; “machine-readable” clarified as markdown-canonical + optional JSONL (not hosted) |
| Claim Boundary | agent-instructed; no verifier WARN/FAIL in v1; hosted audit log = out of scope |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Maintain a machine-readable story evidence index for files, tests, logs, PRs, screenshots, and review notes. |
| User outcome | Every shipped story has a concise proof trail that can be audited later. |
| Success condition | Evidence ledger schema exists; `/agtoosa-review` and `/agtoosa-ship` require updates; optional JSONL mirror is documented. |
| Proof / evidence | `AgToosa_Evidence.md` (+ template mirror), Review/Ship wiring, seed JSONL, EL bats, test-plan evidence. |
| Claim Boundary | Ledger updates are **agent-instructed**. Not generator-enforced. Verifier WARN/FAIL for missing ledgers is **roadmap**. Controls classified as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| Non-goals | No hosted audit log; no live updates during `/agtoosa-build` or `/agtoosa-import` (those keep writing test-plan / IMPORT evidence; ledger consolidates at review/ship); no DEV-058 dashboard UI. |
| Assumptions | Markdown-first; IMPORT evidence and Terminal Evidence remain primary capture surfaces; Master-Plan is SoT. |
| Risks | Duplicate/conflicting evidence vs test plans; overclaiming machine enforcement; secret leakage into ledger files. |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** a per-story evidence index at review and ship **so that** I can audit proof without reconstructing it from chat.

**As a** tooling consumer, **I want** an optional JSONL mirror **so that** scripts can scan evidence rows without parsing every markdown file.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-review` completes for a story THE SYSTEM SHALL create or update `docs/archived/evidence-[story-id].md` (or `Docs/archived/` in generated projects) using the Evidence Ledger schema. | Must |
| AC-002 | WHEN `/agtoosa-ship` runs for a story THE SYSTEM SHALL finalize the same evidence file with ship-phase rows (tests, review path, smoke/verifier pointers) before marking the story Shipped. | Must |
| AC-003 | WHEN the ledger schema is documented THE SYSTEM SHALL require rows for artifact type, pointer, mapped ACs, verification command, exit code, reviewer, timestamp, and phase (`review` \| `ship`). | Must |
| AC-004 | WHEN enforcement is described THE SYSTEM SHALL classify the ledger as agent-instructed and state that Master-Plan remains the repo-local source of truth. | Must |
| AC-005 | WHEN the optional JSONL mirror is used THE SYSTEM SHALL append one JSON object per ledger row to `docs/agtoosa-evidence.jsonl` (seed file shipped) without treating JSONL as authoritative over the markdown index. | Should |
| AC-006 | WHEN the template pack ships THE SYSTEM SHALL register `Docs/AgToosa_Evidence.md` and the JSONL seed in `lib/config.sh` and wire Review/Ship (dual-path) plus Agent/Quickref pointers. | Must |
| AC-007 | WHEN shipping THE SYSTEM SHALL record EL bats evidence without claiming hosted audit or CI-enforced ledger checks. | Should |

### 1.4 Out of Scope

- Hosted / SaaS audit log
- Verifier WARN or FAIL on missing `evidence-*.md` (roadmap)
- Live ledger writes during build/import (consolidate at review/ship only)
- Local dashboard UI (DEV-058)

### Failure modes (Must ACs)

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Review ships without evidence file → no audit trail |
| FM-002 | AC-002 | Ship marks Shipped with empty/missing ledger → false completeness |
| FM-003 | AC-003 | Schema omits AC/verification fields → unusable index |
| FM-004 | AC-004 | Docs claim generator/CI enforcement → dishonest positioning |
| FM-005 | AC-006 | Doc not registered / Review unwired → installs miss the contract |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:
- `template/Docs/AgToosa_Evidence.md` — canonical schema + `/agtoosa-evidence` utility (or Review/Ship-embedded steps)
- `docs/AgToosa_Evidence.md` — maintainer mirror
- `template/Docs/agtoosa-evidence.jsonl` — seed (comment or empty + schema header in Evidence doc)
- `docs/agtoosa-evidence.jsonl` — maintainer seed

Files to change:
- `template/Docs/AgToosa_Review.md`, `docs/AgToosa_Review.md` — require evidence index before/with review report
- `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md` — Part 0 soft/required agent-instructed row + finalize on ship
- `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md` — Commands / Key References
- `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md`
- `docs/AgToosa_Readiness.md`, `template/Docs/AgToosa_Readiness.md` — enforcement row
- `docs/AgToosa_Team_Trust_Roadmap.md` — matrix + backlog text
- `template/Docs/AgToosa_Import.md`, `docs/AgToosa_Import.md` — point “Defer ledger” to shipped Evidence doc when done
- `lib/config.sh` — DOCS_FILES (+ seed if listed)
- `tests/agtoosa.bats` — EL-001–EL-005

Optional thin adapters: only if a top-level `/agtoosa-evidence` command is added; otherwise Review/Ship ownership is enough (prefer no new slash command unless Agent table needs it — **decision:** document as utility invoked from Review/Ship; add thin `/agtoosa-evidence` adapters for discoverability mirroring handoff/import).

### 2.2 Data Flow

```
Build/Import → test-plan RED/GREEN/IMPORT evidence
        │
        ▼
 /agtoosa-review → create/update evidence-[id].md  (+ optional JSONL append)
        │
        ▼
 /agtoosa-ship   → finalize evidence-[id].md       (+ optional JSONL append)
        │
        ▼
 Auditor opens archived evidence file (markdown canonical)
```

### 2.3 STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Spoofing | Fake verification rows | Require command + exit code; prefer pointers to existing test-plan evidence |
| Tampering | Silent ledger edits after ship | Append-only discipline in docs; ship finalizes; git history is audit |
| Repudiation | No record who reviewed | `reviewer` + `ts` fields required |
| Information Disclosure | Secrets in pointers/logs | Secret-safety rule: paths/commands only; redact tokens/URLs |
| Denial of Service | — | — |
| Elevation of Privilege | Ledger used to justify unsafe merges | Does not grant authority; Master-Plan + review Criticals still gate ship |

### 2.4 Build Scope

**In scope:** files in §2.1.
**Out of scope:** verifier FAIL implementation; hosted services; version bump (unless shipping this story).

### Markdown schema (canonical)

```markdown
# Evidence Ledger — [Story ID]

> **Story:** [ID] — [title]
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT
> **Updated:** [YYYY-MM-DD HH:MM] ([review|ship])

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| review | AC-001 | test-log | docs/AgToosa_TestPlan-….md#GREEN | bats … -f "…" | 0 | AgToosa | ISO-8601 |
```

### JSONL mirror row (optional, non-authoritative)

```json
{"ts":"ISO-8601","story":"DEV-049","phase":"review","ac":["AC-001"],"artifact":"test-log","pointer":"…","verification":"…","exit":0,"reviewer":"AgToosa"}
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED contract bats (EL-001–EL-005) — _Requirements: AC-001–AC-006_
- [x] **2.** Canonical Evidence doc + JSONL seed + maintainer mirrors — _Requirements: AC-003, AC-004, AC-005_
- [x] **3.** Wire Review, Ship, Agent, Quickref, Readiness, Roadmap, Import pointer — _Requirements: AC-001, AC-002, AC-004_
- [x] **4.** Register config + optional thin `/agtoosa-evidence` adapters — _Requirements: AC-006_
- [x] **5.** GREEN bats + test-plan evidence — _Requirements: AC-007_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 3, 4
**Wave 3 (sequential after Wave 2):** 5

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Every Must AC maps to EL test-plan rows: yes
- Claim Boundary honest: yes
- SoT preserved: yes
- No TBD placeholders: yes

## Story Skill Opportunity

| Skill | Decision |
|-------|----------|
| `evidence-ledger-writer` | **Do not generate** — overlaps `/agtoosa-review` / `/agtoosa-ship` / reserved `agtoosa-*` |
| Update existing Import skill | **N/A** — no project skill; Import already defers to DEV-049 |

## ✅ Spec Approved

Approved: 2026-07-08 18:05
