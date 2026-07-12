# Spec: DEV-109 — Lifecycle Next-Step Sync + Multi-Spec Clarity

> **Story ID:** DEV-109  
> **Epic:** DEV-002 — Workflow Templates (CLI parity also touches DEV-001)  
> **Status:** ⬜ Backlog  
> **Estimate:** L  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  
> **ADR:** `docs/adr/ADR-012-lifecycle-next-step-sync.md`

## Context

Users report two related product failures:

1. After phases complete, suggestions repeatedly push `/agtoosa-status`, so people miss Spec → Build → Review → Ship as the core path.
2. When asking AI to learn objectives and split into separate specs, Plan-Mode Spec Interview often does not run per child story.

**Smart interview decisions (recorded):**

| Decision | Choice |
|----------|--------|
| Scope | One story covering next-step sync + multi-spec clarity |
| Closure shape | Dual-line: lifecycle next + automatic executive SYNC pulse |
| SYNC implementation | Agent-instructed phase pulse **and** Bash `--status-line` + PowerShell `-StatusLine` (both Must) |
| Multi-spec | Hybrid: small → interview now (+ parallel when `sa-ready`); large → portfolio clarity + children `needs-interview` |
| Tag storage | Master-Plan optional `Clarity` column + spec header |
| Tag names | Canonical `ready` · `sa-ready` · `needs-interview` (aliases `Ready` · `SA-R` · `N-CI`); combinable |
| Interview budget | Soft cap 8, then +4; free-text new directions allow **repeating** +4 until clear |

**Specialist lanes:** none (no `docs/Context/specialists.md`).

### Spec Quality Analyzer (2026-07-12)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC → test-plan mapping | Pass — see test plan |
| Claim Boundary classified | Pass — §1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass — estimate L; backlog only (not Active Cycle) |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Keep users and agents synced on Spec → Build → Review → Ship after every phase, and force per-story clarity interviews when objectives split into multiple specs. |
| User outcome | After any lifecycle phase, the obvious next step is the next lifecycle command plus a one-line SYNC pulse; multi-spec work cannot finalize detailed specs while tagged `needs-interview`. |
| Success condition | Dual-line closure + SYNC format documented and wired in Spec/Build/Review/Ship (+ mirrors/adapters); Bash `--status-line` and PS1 `-StatusLine` emit the same pulse; multi-spec intake + soft interview budget + clarity tags in Spec/Agent/Master-Plan template; LNS bats + PS1 greps green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-109.md`; bats filter `DEV-109` / `LNS-`; review evidence at ship. |
| Non-goals | Replacing full `/agtoosa-status`; auto-chaining phases (Phase Stop preserved); runtime swarm (DEV-107); voluntary scorecard (roadmap DEV-108); changing Part 5.5 finding-ranking algorithm beyond empty/healthy lifecycle nudge; merging into DEV-110 (DEV-110 handles freeform cold-start Project Intake; DEV-109 handles post-phase lifecycle sync and multi-spec clarity). |
| Assumptions | Wave 3 may occupy Active Cycle; DEV-109 stays backlog until after last wave; build deferred until capacity frees (not enrolled in Active Cycle). |
| Risks | Closure-line bats break everywhere; Clarity column confuses old Master-Plans; agents ignore tags. Mitigate with optional column, alias acceptance, and contract bats. |
| Unresolved questions | None for Must scope. |

### 1.2 User Stories

**As an** AgToosa user finishing Spec/Build/Review/Ship, **I want** a primary lifecycle next command plus an automatic SYNC line **so that** I stay on Spec → Build → Review → Ship instead of chasing status as the default.

**As an** AgToosa user (or CI script), **I want** `agtoosa.sh --status-line` and `agtoosa.ps1 -StatusLine` **so that** the same executive pulse is available outside chat.

**As an** AgToosa user splitting a large agenda into multiple specs, **I want** intake tags and per-story interviews (now or deferred via `needs-interview`) **so that** clarity cannot be skipped when each spec is detailed later.

**As an** AgToosa agent running Plan-Mode Spec Interview, **I want** a soft 8/+4 budget that **repeats +4** when the user types new directions **so that** the spec stays crystal clear without treating 8 as a hard stop.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, or `/agtoosa-ship` completes successfully THE SYSTEM SHALL print a primary lifecycle next-step line (not `/agtoosa-status` as the headline) following Spec→Build→Review→Ship→next-story/`/agtoosa-spec` ordering | Must |
| AC-002 | WHEN a lifecycle phase completes successfully THE SYSTEM SHALL automatically emit one executive SYNC pulse line in the canonical format defined in §2.1 | Must |
| AC-003 | WHEN `agtoosa.sh --status-line [path]` runs THE SYSTEM SHALL print the same SYNC format read-only from Master-Plan (and exit 0 when parseable; nonzero on missing Master-Plan) | Must |
| AC-004 | WHEN `agtoosa.ps1 -StatusLine` runs THE SYSTEM SHALL provide PowerShell parity with the Bash SYNC semantics and format | Must |
| AC-005 | WHEN Master-Plan Active Cycle or Backlog tables document stories THE SYSTEM SHALL support an optional `Clarity` column whose values are combinable tags from {`ready`,`sa-ready`,`needs-interview`} accepting aliases {`Ready`,`SA-R`,`N-CI`} | Must |
| AC-006 | WHEN `/agtoosa-spec` detects a multi-objective / multi-story request THE SYSTEM SHALL run multi-spec intake (propose map → user confirm → size path) before writing detailed child specs | Must |
| AC-007 | WHILE a story row or spec header carries `needs-interview` (or `N-CI`) WHEN `/agtoosa-spec` targets that story THE SYSTEM SHALL run Plan-Mode Spec Interview (or `quick` only if user explicitly chooses quick) before writing or finalizing the detailed spec file | Must |
| AC-008 | WHEN Plan-Mode Spec Interview reaches the soft cap THE SYSTEM SHALL offer +4 continuation; IF the user answers with new free-text directions or requirements THEN THE SYSTEM SHALL allow the +4 extension to repeat until Decision-complete or the user explicitly accepts documented assumptions | Must |
| AC-009 | WHEN the universal status-only closure line is referenced in Spec/Build/Review/Ship Output sections THE SYSTEM SHALL replace or demote it so full `/agtoosa-status` is optional verify guidance, not the primary next step | Must |
| AC-010 | WHEN `/agtoosa-help next` and Status empty-state / healthy next-action copy are updated THE SYSTEM SHALL prefer lifecycle next-step language consistent with AC-001 (status only when state is unclear or findings dominate) | Should |
| AC-011 | WHEN `tests/agtoosa.bats` runs DEV-109 coverage THE SYSTEM SHALL assert dual-line/SYNC contract strings, multi-spec + soft-cap wording, clarity tag vocabulary, `--status-line` / `-StatusLine` wiring, and template↔docs mirrors where required | Must |
| AC-012 | WHEN shipping THE SYSTEM SHALL record RED/GREEN evidence in the test plan without claims beyond completed scope | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Users keep treating status as the core workflow |
| AC-002 | Agent and user disagree on current phase/state after a command |
| AC-003 | Scripts cannot sync without launching a full dashboard |
| AC-004 | Windows users get divergent next-step/sync behavior |
| AC-005 | Tags inventable per agent; Master-Plan/spec diverge |
| AC-006 | Multi-spec dumps skip intake confirmation |
| AC-007 | Deferred children get detailed specs without interview |
| AC-008 | Soft cap forces assumed specs while user is still steering |
| AC-009 | Old closure line remains the dominant prompt in adapters |
| AC-011 | Regressions ship without contract bats |
| AC-012 | Ship claims without evidence |

### 1.4 Out of Scope

- Replacing or rewriting Part 5.5 finding-priority algorithm (beyond lifecycle-friendly empty/healthy copy)
- Auto-invoking `/agtoosa-build` after Spec approval (Phase Stop unchanged)
- DEV-107 Orchestration Brain implementation
- Roadmap DEV-108 voluntary scorecard
- Hosted orchestration / remote telemetry
- Mandatory Clarity column on every historical backlog row (optional; empty = no clarity constraint)

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | Universal closure pushes `/agtoosa-status`; help-next has lifecycle order; Spec interview hard-ish 8/+4 once; no multi-spec intake tags |
| Intended change deltas | Dual-line + SYNC; CLI status-line; clarity tags; multi-spec intake; repeating soft-cap on free-text |
| Drift evidence | User report 2026-07-12; CHANGELOG closure-loop history; `AgToosa_Spec.md` budget exhaustion block |
| Claim Boundary | See §1.6 |
| Source of truth | `docs/Master-Plan.md` remains repo-local SoT |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Dual-line / SYNC / multi-spec / soft-cap instructions in workflow docs | agent-instructed |
| `--status-line` / `-StatusLine` flag wiring + help text | generator-enforced |
| Focused LNS bats / PS1 greps in CI when configured | CI-enforced |
| Choosing whether to enroll DEV-109 in Active Cycle | manual |
| Runtime auto-chaining of lifecycle phases | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

**Canonical SYNC format (exact):**

```text
SYNC: <story-id|none> · <status-pill-or-text> · tasks <N>/<M> · clarity <tags|—> · next </agtoosa-command>
```

Rules:

- Prefer Active Cycle In Progress / In Review story; else first Todo; else `none`.
- `clarity` lists canonical tags (normalize aliases); `—` if column absent/empty.
- `next` uses the same lifecycle ordering as `/agtoosa-help next` (empty cycle → `/agtoosa-spec`; unchecked tasks → `/agtoosa-build`; build done no review → `/agtoosa-review`; review ready → `/agtoosa-ship`; after ship / no active work → `/agtoosa-spec`).

**Dual-line close (exact shape):**

```text
✅ Done. Next: /agtoosa-<command> — <one-line rationale>
SYNC: ...
```

Optional tertiary (only when useful): `Optional: /agtoosa-status for full health findings.`

**CLI:**

| Surface | Behavior |
|---------|----------|
| `agtoosa.sh --status-line [path]` | `run_status_line` in `lib/maintain.sh`; read-only Master-Plan parse; stdout = one SYNC line |
| `agtoosa.ps1 -StatusLine` | Dispatch to bash helper (same pattern as `-Verify`/`-Doctor`) or native parse with identical format |

**Multi-spec intake (normative in Spec.md):**

1. Detect multi-objective / “break into specs” request.
2. Propose story map (IDs, titles, non-goals, suggested clarity tags, `intake:small` vs `intake:large` default).
3. User confirms map.
4. **Small:** interview now; set `sa-ready` when parallel child interviews allowed; write one story at a time (or parallel interviews when host + `sa-ready`).
5. **Large:** portfolio-level clarity only; enroll children with `needs-interview`; stop without detailed specs until each child is interviewed.
6. Never finalize a detailed spec file for a `needs-interview` story.

**Interview soft cap:** Document repeating +4 when free-text opens new directions; Decision-complete / assumption acceptance remains the write gate.

**Files to create/update:**

| Surface | Action |
|---------|--------|
| `docs/adr/ADR-012-lifecycle-next-step-sync.md` | Create (this ADR) |
| `template/Docs/AgToosa_Spec.md` + `docs/` mirror | Dual-line output; multi-spec intake; soft-cap repeat; clarity tags |
| `template/Docs/AgToosa_Build.md` / `Review.md` / `Ship.md` + mirrors | Dual-line + SYNC; demote status-only closure |
| `template/Docs/AgToosa_Agent.md` + mirror | Phase Stop + soft-cap + SYNC pointer; Smart Interview note |
| `template/Docs/AgToosa_Status.md` + mirror | Empty/healthy next-action prefers lifecycle (Should) |
| Help variants + core fallbacks | Align help-next / closure mentions (Should) |
| `template/Docs/Master-Plan.md` + maintainer notes | Optional `Clarity` column docs |
| `docs/SPEC-FORMAT.md` + template | Spec header Clarity field |
| `lib/maintain.sh` | `run_status_line` |
| `agtoosa.sh` / `agtoosa.ps1` | Flag wiring + help |
| `docs/agtoosa-maintainer.md` | Document `--status-line` / `-StatusLine` |
| Platform adapters / skills that hardcode old closure | Update verbatim lines |
| `tests/agtoosa.bats` (+ Pester greps as needed) | LNS-001… |

### 2.2 Data Flow

```text
Phase completes
    │
    ├─► Primary: Next: /agtoosa-* (lifecycle)
    └─► SYNC pulse (agent) ──┐
                             ├─► same format
`agtoosa.sh --status-line` ──┘
         │
         ▼
   Parse Master-Plan (Active Cycle, Tasks, Clarity)
         │
         ▼
   stdout one line (read-only)
```

Multi-spec:

```text
User: split objectives
   → Intake map + tags
   → Confirm
   → small: interview → Ready → spec file
   → large: N-CI children → later /agtoosa-spec per ID → interview → Ready → spec file
```

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Spoofed “next” command that auto-runs build | Elevation | Phase Stop; suggestion-only; no auto-chain |
| Tampered Master-Plan tags skip interview | Tampering | AC-007 write gate; bats on wording |
| SYNC claims false task completion | Repudiation | Read-only parse; status remains deep audit |
| Status-line prints secrets from repo files | Information Disclosure | Parse Master-Plan tables only; no file contents dump |
| Rapid `--status-line` in loops | Denial of Service | Single-pass parse; no network |
| Alias confusion elevates unfinished specs | Spoofing | Normalize aliases to canonical tags |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : AgToosa_Spec/Build/Review/Ship/Agent/Status (+template mirrors), SPEC-FORMAT, Master-Plan template, ADR-012, lib/maintain.sh, agtoosa.sh, agtoosa.ps1, maintainer doc, help adapters/skills with old closure, tests/agtoosa.bats (+ Pester if needed), CONTEXT.md
Directories in scope: docs/, template/, lib/, tests/, root entrypoints
Out of scope        : Part 5.5 ranking rewrite, DEV-107/108, version bump, auto-phase chaining, verifier new gate (unless tiny optional later)
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract docs + ADR
  - [ ] 1.1 Finalize ADR-012 Accepted on build start; sync CONTEXT terms — _Requirements: AC-005, AC-008, AC-009_
  - [ ] 1.2 Update Spec.md: dual-line output, multi-spec intake, soft-cap repeat, clarity tags — _Requirements: AC-001, AC-002, AC-006, AC-007, AC-008, AC-009_
  - [ ] 1.3 Update Build/Review/Ship Output sections + Agent Smart Interview notes — _Requirements: AC-001, AC-002, AC-008, AC-009_
  - [ ] 1.4 SPEC-FORMAT + Master-Plan template Clarity column; Status/help Should copy — _Requirements: AC-005, AC-010_
- [ ] **2.** Status-line CLI
  - [ ] 2.1 Implement `run_status_line` in `lib/maintain.sh` — _Requirements: AC-002, AC-003_
  - [ ] 2.2 Wire `agtoosa.sh --status-line` + help/maintainer docs — _Requirements: AC-003_
  - [ ] 2.3 Wire `agtoosa.ps1 -StatusLine` parity + help — _Requirements: AC-004_
- [ ] **3.** Adapter parity
  - [ ] 3.1 Update platform commands/skills/prompts that hardcode old status-only closure — _Requirements: AC-001, AC-009_
- [ ] **4.** Tests + evidence
  - [ ] 4.1 Add LNS bats (docs + CLI + PS1 greps) — _Requirements: AC-011_
  - [ ] 4.2 Record RED/GREEN in test plan — _Requirements: AC-012_

### 3.2 Wave Plan

```
**Wave 1 (parallel):** 1.1, 1.4, 4.1 (RED stubs)
**Wave 2 (sequential after Wave 1):** 1.2, 1.3, 2.1
**Wave 3 (parallel after 2.1):** 2.2, 2.3, 3.1
**Wave 4 (sequential):** 4.1 GREEN assertions complete, 4.2
```

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-DEV-109.md`.

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|----------|-------------|--------------|
| PKG-1.1 | 1 | — | `docs/adr/ADR-012-lifecycle-next-step-sync.md`, `docs/Context/CONTEXT.md` | interview decisions | ADR + terms | 1 | file present; terms listed |
| PKG-1.4 | 1 | — | `docs/SPEC-FORMAT.md`, `template/Docs/SPEC-FORMAT.md`, `template/Docs/Master-Plan.md` | AC-005 | Clarity column docs | 1 | bats grep Clarity |
| PKG-4.1a | 1 | — | `tests/agtoosa.bats` (LNS RED section) | ACs | failing LNS tests | 2 | RED evidence |
| PKG-1.2 | 2 | PKG-1.1 | `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Spec.md` | ADR-012 | intake + soft-cap + dual-line | 1 | bats doc greps |
| PKG-1.3 | 2 | PKG-1.1 | `docs/AgToosa_Build.md`, `docs/AgToosa_Review.md`, `docs/AgToosa_Ship.md`, `docs/AgToosa_Agent.md` + template mirrors | ADR-012 | dual-line outputs | 2 | bats doc greps |
| PKG-2.1 | 2 | PKG-1.1 | `lib/maintain.sh` | SYNC format | `run_status_line` | 3 | CLI smoke |
| PKG-2.2 | 3 | PKG-2.1 | `agtoosa.sh`, `docs/agtoosa-maintainer.md` | run_status_line | flag wiring | 1 | `--status-line` smoke |
| PKG-2.3 | 3 | PKG-2.1 | `agtoosa.ps1`, `tests/pester/*` as needed | SYNC format | `-StatusLine` | 1 | bats/Pester greps |
| PKG-3.1 | 3 | PKG-1.2, PKG-1.3 | `template/.claude/**`, `template/.codex/**`, `template/.cursor/**`, `template/.gemini/**`, `template/.github/**`, `template/.windsurf/**` (closure lines only) | dual-line contract | adapter parity | 2 | bats adapter greps |
| PKG-4.1b | 4 | PKG-2.2, PKG-2.3, PKG-3.1 | `tests/agtoosa.bats` | LNS assertions | GREEN | 1 | bats filter green |
| PKG-4.2 | 4 | PKG-4.1b | `docs/AgToosa_TestPlan-DEV-109.md` | evidence | RED/GREEN recorded | 2 | test plan filled |

## Story Skill Opportunity Synthesis

| Skill name | Trigger | Purpose | Decision |
|------------|---------|---------|----------|
| _(none)_ | — | Dual-line/SYNC belongs in core AgToosa workflows; reserved `agtoosa-*` names must not be generated | **Do not generate** |

## Capability Delta

Capability: lifecycle-next-step-sync

| Change | Requirement | Notes |
|--------|-------------|-------|
| ADDED | WHEN Spec/Build/Review/Ship completes successfully, THE SYSTEM SHALL print a primary lifecycle next-step (not `/agtoosa-status` as headline) plus an executive SYNC pulse | dual-line close |
| ADDED | WHEN `agtoosa.sh --status-line` or `agtoosa.ps1 -StatusLine` runs, THE SYSTEM SHALL emit the same SYNC format read-only from Master-Plan | generator-enforced CLI |
| ADDED | WHEN multi-objective spec work is requested, THE SYSTEM SHALL run multi-spec intake with combinable clarity tags (`ready`, `sa-ready`, `needs-interview`) | per-story interview gate |
| ADDED | WHEN Plan-Mode Spec Interview hits soft cap, THE SYSTEM SHALL allow repeating +4 on free-text new directions until Decision-complete | not a hard stop at 8 |
| ADDED | WHEN describing phase close, THE SYSTEM SHALL demote universal status-only closure to optional verify guidance | preserves closure-loop without obscuring lifecycle |

## ✅ Spec Approved

Approved: 2026-07-12 14:30
