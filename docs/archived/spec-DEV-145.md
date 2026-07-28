# Spec: DEV-145 — Tracker Bootstrap Apply

> **Story ID:** DEV-145
> **Epic:** DEV-051 — Tracker Sync Bridge / DEV-003 — Community Template Registry
> **Status:** 🏁 Shipped — v5.3.59
> **Estimate:** M
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-141 — Tracker Discovery & Bootstrap · DEV-143 — Tracker Unlinked Status Finding

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Parent | DEV-141 `bootstrap` is proposal-only; DEV-143 routes fix discover → bootstrap → manual `/agtoosa-task` |
| Authority | Master-Plan remains SoT; apply is explicit, auditable, reversible |
| Classification | Reuse `_bootstrap_classify_item`; only `new_external` (+ optional `repo_plan`) eligible for apply |
| GitHub naming | DEV-139: titles use `feat:`/`fix:`/`chore:`/`docs:` — **no `DEV-XXX:` in title**; ID lives in ID column + `agtoosa:DEV-*` label when mirrored |
| Type inference | Existing bootstrap heuristics map prefix → Feature/Bug/Chore |
| Safety | DEV-119 transaction journal available for pre-image before Master-Plan write |
| Parity | Bash CLI first; PowerShell help/delegation note |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Apply contract? | **Hybrid** — selective `accept: true` per row **plus** optional auto-accept all `new_external` |
| Q2 | Hybrid mechanics? | **A** — default `apply` requires `accept: true`; `--apply-all-new-external` auto-accepts every `new_external` row |
| Q3 | Backlog ID + title naming? | **A** — allocate next free `DEV-NNN` from Master-Plan; titles follow GitHub-standard prefixes (`feat:`/`fix:`/`chore:`/`docs:`), not `DEV-` in title |
| Q4 | Safety gate? | **A** — dry-run default; `--apply --yes` writes; optional DEV-119 journal pre-image |

#### Documented assumptions

- **Machine-readable proposal** — `bootstrap` emits companion `agtoosa.tracker-bootstrap-proposal/v1` JSON alongside markdown for `accept` flags (accepted; markdown remains human-readable).
- **Default accept** — `accept` defaults `false`; `--apply-all-new-external` sets accept=true for `new_external` at apply time without editing JSON.
- **repo_plan** — out of scope for auto-apply v1 unless user sets `accept: true` manually (accepted; avoids repo-plan file collisions).

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Close the discover → bootstrap → Master-Plan loop with an explicit, safe apply path |
| User outcome | Run `bootstrap --apply` (dry-run), review diff, then `--apply --yes` to append accepted rows with real DEV IDs and GitHub-standard titles |
| Success condition | `bootstrap --apply` CLI; JSON proposal schema; TBA-001–TBA-010 green; TrackerSync doc updated |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-145.md`; bats TBA-001–TBA-010 |
| Non-goals | Live bidirectional sync; OAuth; silent auto-apply without dry-run review; overwriting existing DEV rows |
| Risks | Duplicate titles; ID collision; partial apply failure; title prefix drift vs DEV-139 publish rules |
| Unresolved questions | None |

### 1.2 User Stories

**As a** brownfield adopter, **I want** `bootstrap --apply` to append accepted external items to Master-Plan **so that** I do not hand-copy proposal rows.

**As a** maintainer, **I want** dry-run by default and DEV ID allocation **so that** apply is safe and naming stays consistent with GitHub bridge rules.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `bootstrap` completes THE SYSTEM SHALL write `agtoosa.tracker-bootstrap-proposal/v1` JSON with per-item `accept` default false | Must |
| AC-002 | WHEN `bootstrap --apply` runs without `--yes` THE SYSTEM SHALL print a unified diff of Master-Plan backlog changes and SHALL NOT mutate files | Must |
| AC-003 | WHEN `bootstrap --apply --yes` runs THE SYSTEM SHALL append only rows with `accept: true` OR disposition `new_external` when `--apply-all-new-external` is set | Must |
| AC-004 | WHEN applying THE SYSTEM SHALL allocate the next free `DEV-NNN` ID by scanning Master-Plan and SHALL NOT reuse existing IDs | Must |
| AC-005 | WHEN applying THE SYSTEM SHALL normalize titles to GitHub-standard prefixes (`feat:`/`fix:`/`chore:`/`docs:`) and SHALL NOT embed `DEV-` in the title column | Must |
| AC-006 | WHEN apply writes THE SYSTEM SHALL record `external_ref` and provider in the Status column for traceability | Must |
| AC-007 | WHEN apply writes THE SYSTEM SHALL open a DEV-119 transaction journal pre-image of Master-Plan before mutation | Must |
| AC-008 | WHEN verified THE SYSTEM SHALL pass TBA-001–TBA-010 bats | Must |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `bootstrap --apply` | generator-enforced | Master-Plan backlog section only; dry-run default |
| GitHub/Linear fetch | manual / agent | Unchanged from DEV-141 |
| Publish manifest | DEV-139 | Outbound titles still `feat:`/`fix:`/`chore:`/`docs:` only |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `lib/tracker-discover.sh` | `tracker_bootstrap_apply()`, ID allocator, title normalizer, JSON proposal emit |
| `agtoosa.sh` | `--tracker bootstrap --apply [--yes] [--apply-all-new-external] --input <json>` |
| `docs/agtoosa-tracker-sync.schema.json` | Add `agtoosa.tracker-bootstrap-proposal/v1` |
| `docs/AgToosa_TrackerSync.md` | Apply workflow + naming table |
| `template/Docs/AgToosa_TrackerSync.md` | Mirror |
| `tests/fixtures/tracker-sync/bootstrap-apply/` | Fixture project + proposal JSON |
| `tests/agtoosa.bats` | TBA-001–TBA-010 |

### 2.2 Title normalization (GitHub app best practice)

| Source signal | Master-Plan `Title` | `Type` column |
|---------------|---------------------|---------------|
| `feat:` / feature label | `feat: <clean title>` | Feature |
| `fix:` / bug label | `fix: <clean title>` | Bug |
| `chore:` / maintenance | `chore: <clean title>` | Chore |
| `docs:` | `docs: <clean title>` | Docs |
| No prefix | `feat: <clean title>` (default) | Feature |

Rules: strip leading `DEV-\d+:` or `[Area]` duplicates; never write `DEV-NNN` into Title (ID column only).

### 2.3 Apply flow

1. Load proposal JSON (from prior `bootstrap` or `--input`).
2. Resolve accept set (`accept: true` ∪ optional `--apply-all-new-external` on `new_external`).
3. Dry-run: render diff of new backlog table rows.
4. `--yes`: journal pre-image → append rows under `## Backlog` → write JSON apply report.

### 2.4 Threat Model (STRIDE)

| Threat | Mitigation |
|--------|------------|
| Tampering — partial corrupt Master-Plan | DEV-119 journal + rollback path |
| Spoofing — wrong external ref | `external_ref` stored in Status; human review in dry-run |
| DoS — huge apply batch | Cap apply batch at 50 rows per invocation (documented) |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Proposal JSON + schema
  - [x] 1.1 `agtoosa.tracker-bootstrap-proposal/v1` — _AC-001_
  - [x] 1.2 Emit JSON from `tracker_bootstrap` — _AC-001_
- [x] **2.** Apply core
  - [x] 2.1 ID allocator + title normalizer — _AC-004, AC-005_
  - [x] 2.2 `tracker_bootstrap_apply` dry-run + `--yes` — _AC-002, AC-003, AC-006_
  - [x] 2.3 DEV-119 journal hook — _AC-007_
- [x] **3.** CLI + docs
  - [x] 3.1 `agtoosa.sh --tracker bootstrap --apply` flags — _AC-002, AC-003_
  - [x] 3.2 TrackerSync apply workflow (maintainer + template) — _AC-005_
- [x] **4.** Bats TBA-001–TBA-010 — _AC-008_

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-145.md`

## ✅ Spec Approved

Approved: 2026-07-28 — served by `/agtoosa-next` (interview Q1–Q4 complete; cold-start pick: tracker bootstrap apply).
