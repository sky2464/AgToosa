# Spec: DEV-143 — Tracker Unlinked Status Finding

> **Story ID:** DEV-143
> **Epic:** DEV-003 — Community Template Registry / DEV-051 — Tracker Sync Bridge
> **Status:** 🏁 Shipped — v5.3.57
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-141 — Tracker Discovery & Bootstrap · DEV-117 — Cycle Continuity Guard

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Authority | `docs/Master-Plan.md` remains SoT; status finding is read-only coaching only |
| Parent | DEV-141 shipped `discover`/`bootstrap`; gap is surfacing `new_external` during `/agtoosa-status` |
| ID collision | Proposed label **DEV-142** was already shipped (GitHub Surface Audit v5.3.56); this story is **DEV-143** |
| Network | Core generator remains API-free; fetch caches are optional files under `.agtoosa/tracker/` |
| Classification | Reuse DEV-141 `_bootstrap_classify_item` semantics; only `new_external` triggers the finding |
| Greenfield | No finding when zero tracker signals and no cache files (silent skip) |
| Part 5.5 | Add fix-command row for tracker unlinked pattern; Info tier only (DEV-109 boundary preserved) |
| Parity | Bash CLI first; PowerShell help/delegation note; template doc mirrors |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | When should status report unlinked items? | **C** — Local discover each run + auto-merge standard fetch inputs when present on disk |
| Q2 | Implementation surface? | **A** — New generator CLI `agtoosa.sh --tracker status-check --format json`; `/agtoosa-status` doc calls it |
| Q3 | What counts as unlinked? | **A** — Only `new_external` (open external items without mirror label / title match) |
| Q4 | Cache paths for auto-merge? | **A** — `.agtoosa/tracker/gh-issues.json` and `.agtoosa/tracker/linear-fetch.json` |
| Q5 | Health score / Part 5.5? | **A** — ℹ️ Info only; zero Plan Completeness deduction; Part 5.5 maps to `/agtoosa-tracker discover` → `bootstrap` |

#### Documented assumptions

- **Silent skip** — No Info finding when `new_external` count is 0 or when the project has no tracker PM signals and no `.agtoosa/tracker/*` cache files (accepted; avoids greenfield noise).
- **Sample cap** — Status finding lists at most 5 `new_external` refs in the narrative; full list remains in JSON output (accepted; keeps dashboard readable).
- **Stale cache** — Status does not warn on cache age; user refreshes caches via documented fetch workflow (accepted; out of scope for v1).

### Spec Quality Analyzer (2026-07-28)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass — 8 Must ACs |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC → test-plan mapping | Pass — TUS-001–TUS-008 |
| Claim Boundary classified | Pass — §1.3 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Surface brownfield tracker drift during `/agtoosa-status` when external issues exist without Master-Plan linkage |
| User outcome | Run status and see an ℹ️ Info finding with count + sample refs when unmirrored GitHub/Linear items are detected; fix via discover → bootstrap |
| Success condition | `--tracker status-check` CLI; `AgToosa_Status.md` Part 1.x + Part 5.5 row; TUS-001–TUS-008 green; schema `agtoosa.tracker-status-check/v1` |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-143.md`; bats TUS-001–TUS-008 |
| Non-goals | Live API fetch in core; auto Master-Plan writes; Warning/Error severity; bidirectional “missing mirror” for Master-Plan rows; changing Part 5.5 ranking algorithm beyond one new row |
| Assumptions | DEV-141 discover/bootstrap shipped; optional fetch caches maintained outside core; status agent invokes CLI for deterministic counts |
| Risks | Stale `.agtoosa/tracker/` caches misreport; false positives if title-fuzzy match fails; over-nagging if skip heuristics wrong |
| Unresolved questions | None |

### 1.2 User Stories

**As a** brownfield adopter with existing GitHub/Linear issues, **I want** `/agtoosa-status` to flag unlinked external items **so that** I discover bootstrap work without running discover manually first.

**As a** maintainer, **I want** a bats-testable JSON status-check CLI **so that** the finding is deterministic and not agent-improvised.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa.sh --tracker status-check` runs THE SYSTEM SHALL perform local `tracker_discover` without network calls in lib | Must |
| AC-002 | WHEN `.agtoosa/tracker/gh-issues.json` and/or `.agtoosa/tracker/linear-fetch.json` exist THE SYSTEM SHALL auto-merge them before classification | Must |
| AC-003 | WHEN items classify as `new_external` THE SYSTEM SHALL include them in `unlinked_external` count and list in JSON output | Must |
| AC-004 | WHEN items classify as `mirror_skip`, `repo_plan`, `unchanged`, or `closed_external` THE SYSTEM SHALL NOT count them as unlinked | Must |
| AC-005 | WHEN `new_external` count is zero OR no tracker signals and no cache files exist THE SYSTEM SHALL set `finding.emit` to false | Must |
| AC-006 | WHEN `finding.emit` is true THE JSON output SHALL set `finding.severity` to `info` | Must |
| AC-007 | WHEN `/agtoosa-status` documents the check THE SYSTEM SHALL record an ℹ️ Info finding with Fix with `/agtoosa-tracker discover` (then `bootstrap`) and SHALL NOT deduct Plan Completeness | Must |
| AC-008 | WHEN verified THE SYSTEM SHALL pass TUS-001–TUS-008 including schema validation and silent-skip fixture | Must |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `--tracker status-check` | generator-enforced | Local files only; read-only |
| `.agtoosa/tracker/*.json` caches | manual / CI / agent fetch | Outside core; gitignored operational data |
| `/agtoosa-status` finding text | agent-instructed | Calls CLI; Info severity contract |
| Master-Plan | repo-local SoT | Wins every conflict |

### 1.5 Failure Modes

| AC | Failure mode |
|----|--------------|
| AC-001 | Status-check performs network I/O in lib |
| AC-002 | Cache files ignored or wrong path |
| AC-003 | `new_external` items omitted from output |
| AC-004 | `repo_plan` or mirrored items counted as unlinked |
| AC-005 | Greenfield repos nagged; or unlinked items hidden when caches present |
| AC-006 | Finding escalates to Warning and deducts health score |
| AC-007 | Status doc contradicts DEV-117 Info/no-deduction pattern |
| AC-008 | Non-deterministic or untested CLI behavior |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `lib/tracker-discover.sh` | Add `tracker_status_check()` — discover + cache merge + classify + JSON emit |
| `agtoosa.sh` | Wire `--tracker status-check [--format json] [--output file]` |
| `agtoosa.ps1` | Help text for `status-check` (delegates to Bash) |
| `docs/agtoosa-tracker-sync.schema.json` | Add `agtoosa.tracker-status-check/v1` |
| `template/Docs/agtoosa-tracker-sync.schema.json` | Mirror schema |
| `docs/AgToosa_TrackerSync.md` | Document status-check + cache paths |
| `template/Docs/AgToosa_TrackerSync.md` | Mirror |
| `template/.agtoosa/README.md` | Index `tracker/` cache files |
| `docs/AgToosa_Status.md` | Part 1.x tracker unlinked check + Part 5.5 fix-command row |
| `template/Docs/AgToosa_Status.md` | Mirror |
| `contracts/product-truth-v1.json` | Add `status-check` to `command.tracker` modes |
| Platform tracker adapters | Mention `status-check` in thin command stubs |
| `tests/fixtures/tracker-sync/status-check/` | Fixture project + cache JSON |
| `tests/agtoosa.bats` | TUS-001–TUS-008 |

### 2.2 Data Flow

1. Agent or user runs `agtoosa.sh --tracker status-check --path . --format json`.
2. `tracker_status_check` calls local discover (repo signals + repo-plans).
3. If `.agtoosa/tracker/gh-issues.json` exists, merge via existing GitHub fetch helper.
4. If `.agtoosa/tracker/linear-fetch.json` exists, merge via existing Linear envelope helper.
5. Classify each item with DEV-141 logic; collect `new_external` only.
6. Emit `agtoosa.tracker-status-check/v1` with counts, sample list, and `finding.emit`.
7. `/agtoosa-status` invokes CLI; when `finding.emit`, append ℹ️ Info finding and Part 5.5 action.

### 2.3 JSON Schema (summary)

`agtoosa.tracker-status-check/v1` fields: `schema_version`, `generated_at`, `project_path`, `has_tracker_signals`, `merged_inputs[]`, `counts{}`, `unlinked_external[]`, `finding{emit, severity, count, sample_refs[]}`.

### 2.4 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Malicious cache JSON exfiltrates paths | Information disclosure | Bounded JSON load (`_tracker_load_bounded_json`); status-check read-only |
| False “synced” claims from stale cache | Spoofing | Document cache refresh; no auto-apply |
| Status-check mutates Master-Plan | Tampering | Read-only CLI; no write paths |
| Network calls from “local” check | Elevation | No fetch in lib; caches only |
| Info finding treated as blocker | Denial of Service | Explicit Info + zero deduction in status contract |

### 2.5 Build Scope

Files in scope: `lib/tracker-discover.sh`, `agtoosa.sh`, `agtoosa.ps1`, tracker schema docs, `AgToosa_Status.md`, `AgToosa_TrackerSync.md`, `.agtoosa/README.md`, product-truth, platform adapters, bats fixtures/tests.

Out of scope: OAuth, live `gh`/Linear in core, auto-bootstrap, verifier new gate, PowerShell native implementation.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Status-check core
  - [x] 1.1 Add `agtoosa.tracker-status-check/v1` schema — _AC-008_
  - [x] 1.2 Implement `tracker_status_check()` with cache auto-merge — _AC-001, AC-002, AC-003, AC-004, AC-005, AC-006_
- [x] **2.** CLI wiring
  - [x] 2.1 `agtoosa.sh --tracker status-check` + PS1 help — _AC-001, AC-008_
- [x] **3.** Status workflow
  - [x] 3.1 `AgToosa_Status.md` Part 1.x + Part 5.5 row (maintainer + template) — _AC-007_
- [x] **4.** Docs and config index
  - [x] 4.1 TrackerSync cache paths + `.agtoosa/README.md` — _AC-002_
  - [x] 4.2 Product-truth `status-check` mode + platform stubs — _AC-008_
- [x] **5.** Bats TUS-001–TUS-008 — _AC-008_

### 3.2 Wave Plan

- **Wave 1:** 1.1, 1.2, 2.1
- **Wave 2:** 3.1, 4.1, 4.2
- **Wave 3:** 5

### 3.3 Test Plan

- `docs/AgToosa_TestPlan-DEV-143.md`

## ✅ Spec Approved

Approved: 2026-07-28 — served by `/agtoosa-next` (Sequential Approval; interview Q1–Q5 complete; renumbered DEV-143 after DEV-142 collision).
