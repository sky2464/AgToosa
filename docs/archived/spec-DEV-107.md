# Spec: DEV-107 — Agent-Instructed Orchestration Brain

> **Story ID:** DEV-107
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ⬜ Backlog (Spec Approved; build after Wave 1a)
> **Estimate:** M
> **Spec created:** 2026-07-12

## Context

Parallelism in AgToosa is **scattered** across specialists (DEV-031), Work Package Wave DAGs (DEV-045), handoff/import (DEV-047/048), cross-model review (DEV-050), and the Agent Capability Matrix (DEV-055). Orchestrators lack a single algorithm: *inventory available surfaces → invent parallel lanes → merge evidence → sequential fallback* — with **skills, plugins, and MCP** as first-class inventory.

Rev4 and ADR-003 forbid a complex multi-agent **runtime**. This story ships an **agent-instructed Orchestration Brain**: the assistant remains the orchestrator; `docs/Master-Plan.md` remains shared state.

**User-selected scope (recorded as findings):**

| Decision | Choice |
|----------|--------|
| Shape | **A** — Agent-instructed brain only (no process supervisor / hosted swarm) |
| Timing | Backlog after Wave 1a (DEV-086 / 090 / 105); do not displace Active Cycle |
| Story ID | DEV-107 under Epic DEV-002 |
| Estimate | **M** — canonical doc + lifecycle hooks + ADR amendment + ORB bats |

**Smart interview findings (gaps covered without additional questions):**

| Checklist area | Finding |
|----------------|---------|
| Status quo | Spec specialists, Wave DAGs, handoff/import, review personas, AgentCapability exist; no unified fan-out brain |
| Narrowest v1 | `AgToosa_Orchestration.md` + thin hooks in Spec/Build/Review/Ship/Agent/Quickref/guide + `lib/config.sh` + ORB bats; extend ADR-003 |
| Urgency | Product ask for army/fan of subagents; Wave 1a capacity blocks build now |
| Failure modes | Overclaiming runtime scheduler; duplicating Specialists/AgentCapability tables; overlapping same-wave ownership; Master-Plan races from parallel mutators |
| Security | Inventory is path/name only; MCP listed by server name with user approval; no secrets in lane plans |
| Test evidence | ORB-001–ORB-008 bats; RED/GREEN in test plan at build |
| Rollout | Template + maintainer mirrors on `--update`; build deferred until after Wave 1a |

### Spec Quality Analyzer (2026-07-12)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass — 8 Must; each Must has failure mode |
| Goal / scope / AC / task / test-plan alignment | Pass — no contradictions |
| Must AC → test-plan mapping | Pass — AC-001–AC-008 mapped to ORB-001–ORB-008 |
| Claim Boundary classified | Pass — §1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass — none in Must ACs |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish one canonical **Orchestration Brain** that every lifecycle command consults before fan-out: inventory skills/plugins/MCP/platforms/specialists/wave packages → lane plan → parallel when capable → merge → sequential fallback. |
| User outcome | Faster, higher-quality Spec → Build → Review → Ship (and sync/task) work via safe parallel lanes without adopting a runtime swarm. |
| Success condition | `AgToosa_Orchestration.md` defines inventory, algorithm, phase lane catalogs, merge rules, and Claim Boundary; Spec/Build/Review/Ship/Agent/Quickref (+ subagent guide) reference it; `lib/config.sh` installs the doc; ADR-003 amended; ORB-001–ORB-008 green. |
| Proof / evidence | Test plan `docs/AgToosa_TestPlan-DEV-107.md`; bats filter green at build; review evidence at ship. |
| Non-goals | Runtime scheduler; auto-spawning agents without host Task/Agent tools; probing paid APIs; replacing Specialists, Wave DAG, Handoff, Import, or AgentCapability contracts; default specialist roster in `template/`; shipping an MCP server in AgToosa core. |
| Assumptions | Detection reuses AgentCapability sentinels; Wave DAG ownership rules remain authoritative for build fan-out; assistant is the orchestrator (ADR-003). |
| Risks | Doc sprawl / duplication; false parallel-safety claims; agents mutating Master-Plan in parallel. Mitigate with extend-don't-duplicate rule, Claim Boundary, and serial Master-Plan mutation rule. |
| Unresolved questions | None. |

### 1.2 User Stories

**As an** AgToosa orchestrator running `/agtoosa-spec`, **I want** a single brain that inventories skills, specialists, MCP needs, and host Task tools before research and specialist lanes **so that** I fan out safely and merge evidence before the Goal Contract finalizes.

**As an** AgToosa user on Claude Code or Cursor, **I want** Spec/Build/Review/Ship to default to parallel lanes when the host can and to print an honest sequential note when it cannot **so that** I get speed without false capability claims.

**As an** AgToosa maintainer, **I want** bats to lock the Orchestration doc, config inventory, non-runtime claims, and workflow pointers **so that** releases cannot drift into overclaiming a scheduler.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_Orchestration.md` is installed THE SYSTEM SHALL define Capability Inventory sources, a lane-plan algorithm (detect → invent lanes → parallel or sequential → merge), merge rules, and the exact sequential fallback note | Must |
| AC-002 | WHEN the Capability Inventory is built THE SYSTEM SHALL treat platforms (AgentCapability sentinels), project skills, specialists (`phase_hooks` + trigger), declared MCP needs (server names only), detectable host plugins/tools, and Work Package DAG rows (when present) as first-class inputs | Must |
| AC-003 | WHEN `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, or `/agtoosa-ship` prepares fan-out THE SYSTEM SHALL instruct the orchestrator to run Orchestration Brain step 0 before launching lanes (agent-instructed) | Must |
| AC-004 | WHEN orchestration enforcement is described THE SYSTEM SHALL classify inventory+routing as agent-instructed, doc install via `lib/config.sh` as generator-enforced, focused ORB bats in CI as CI-enforced when configured, agent selection as manual, and runtime auto-launch / hosted orchestrator as roadmap / out of scope | Must |
| AC-005 | WHEN same-wave build packages are considered for parallel fan-out THE SYSTEM SHALL preserve DEV-045 disjoint `owned_files` rules or convert overlaps to explicit sequential fallback | Must |
| AC-006 | WHEN parallel lanes complete THE SYSTEM SHALL require the orchestrator alone to mutate `docs/Master-Plan.md` status/checkboxes after Terminal Evidence merge, and SHALL require `/agtoosa-import` before external-agent claims close tasks | Must |
| AC-007 | WHEN `agtoosa.sh --update` installs workflow docs THE SYSTEM SHALL include `Docs/AgToosa_Orchestration.md` via `lib/config.sh` | Must |
| AC-008 | WHEN `tests/agtoosa.bats` runs DEV-107 coverage THE SYSTEM SHALL assert doc presence (template + docs), inventory fields, Claim Boundary / non-runtime wording, Spec/Build/Review/Ship/Agent/Quickref pointers, guide pointer, and `lib/config.sh` membership | Must |
| AC-009 | WHEN `/agtoosa-qa`, `/agtoosa-task`, or tracker-sync paths document fan-out THE SYSTEM SHOULD reference the brain for read-only parallel lanes while keeping Master-Plan mutations serial | Should |
| AC-010 | WHEN shipping THE SYSTEM SHALL record RED/GREEN evidence in the test plan without claims beyond completed scope | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Agents invent incompatible fan-out rituals because no canonical algorithm exists |
| AC-002 | Skills/MCP/plugins ignored; only specialists or platforms considered |
| AC-003 | Spec/Build/Review/Ship still fan out ad hoc without consulting the brain |
| AC-004 | Docs imply AgToosa auto-launches or hosts a swarm runtime |
| AC-005 | Same-wave packages with overlapping files presented as safe parallel |
| AC-006 | Subagents tick Master-Plan checkboxes or skip import gate |
| AC-007 | `--update` omits Orchestration doc → installs drift |
| AC-008 | Contract bats missing → regressions ship silently |
| AC-010 | Ship claims without RED/GREEN evidence |

### 1.4 Out of Scope

- Replacing or delaying Wave 1a (DEV-086 / DEV-090 / DEV-105)
- Generator-enforced agent spawning or a process supervisor
- Default specialist roster under `template/`
- New MCP server shipping inside AgToosa core
- Replacing `AgToosa_Specialists.md`, `AgToosa_AgentCapability.md`, Wave DAG schema, Handoff, or Import
- Hosted orchestration, paid API probing, or remote capability telemetry

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | Fan-out instructions live in Specialists (spec/review), Build Wave Plan + Work Package gate, Review personas, AgentCapability routing — no single entry algorithm |
| Intended change deltas | Add `AgToosa_Orchestration.md`; thin “step 0” hooks; ADR-003 amendment (default-parallel when capable); ORB bats; guide pointer |
| Drift evidence | User ask 2026-07-12 for army/fan of subagents across research/docs/plan/design/build; plan locked to agent-instructed shape A |
| Claim Boundary | See §1.6 |
| Source of truth | `docs/Master-Plan.md` remains repo-local SoT |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Orchestration Brain doc + workflow “step 0” references | agent-instructed |
| Doc installed via `lib/config.sh` / `--update` | generator-enforced |
| Focused ORB bats when run in CI | CI-enforced |
| Selecting which host Task/Agent tool to use | manual |
| Automatic agent launch / hosted orchestrator / runtime scheduler | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

```
Lifecycle command (spec|build|qa|review|ship|task/sync)
        │
        ▼
AgToosa_Orchestration.md  ← step 0
        │
        ├── Capability Inventory
        │     ├── Platforms → AgToosa_AgentCapability.md
        │     ├── Specialists → AgToosa_Specialists.md
        │     ├── Skills → AgToosa_Skills.md
        │     ├── MCP needs (declared names)
        │     ├── Host plugins/tools (detectable markers only)
        │     └── Work Package DAG (when present)
        │
        ├── Lane Plan (phase catalog)
        ├── Parallel fan-out OR sequential fallback note
        └── Orchestrator merge → Master-Plan + phase artifacts
```

**Files to create:**

| Surface | Action |
|---------|--------|
| `template/Docs/AgToosa_Orchestration.md` | **Create** — canonical brain |
| `docs/AgToosa_Orchestration.md` | **Mirror** |
| `docs/adr/ADR-003-multi-agent-orchestration.md` | **Amend** — default-parallel when capable; still agent-instructed |

**Files to update (thin pointers only — do not duplicate matrices):**

| Surface | Action |
|---------|--------|
| `template/Docs/AgToosa_Spec.md` + `docs/` mirror | Step 0 before Part 1 specialist orchestration / research fan-out |
| `template/Docs/AgToosa_Build.md` + mirror | Step 0 before Wave / Work Package fan-out |
| `template/Docs/AgToosa_Review.md` + mirror | Step 0 before persona / specialist / cross-model lanes |
| `template/Docs/AgToosa_Ship.md` + mirror | Step 0 before independent check/docs/retro prep lanes |
| `template/Docs/AgToosa_Agent.md` + mirror | Orchestration Brain entry in key references |
| `template/Docs/AgToosa_Quickref.md` + mirror | One-line brain pointer |
| `docs/guides/subagent-heavy-workflows.md` | Brain as entry algorithm before handoff path |
| `lib/config.sh` | Register `Docs/AgToosa_Orchestration.md` |
| `tests/agtoosa.bats` | ORB-001–ORB-008 |

**Lane catalogs (normative in Orchestration doc):**

| Phase | Parallel lanes (examples) | Merge owner |
|-------|---------------------------|-------------|
| `/agtoosa-spec` | Context/code scan, web research, matching specialists, threat-model prep, domain-language, skill opportunity scan | Spec orchestrator |
| `/agtoosa-build` | Wave packages with disjoint `owned_files`; optional build-hook specialists | Orchestrator (+ import if async) |
| `/agtoosa-qa` | AC-cluster plan/run lanes when host allows | QA orchestrator |
| `/agtoosa-review` | Virtual personas + review specialists + optional cross-model | Review verdict gate |
| `/agtoosa-ship` | Independent check / docs / retro prep | Ship gate |
| Sync / task | Read-only status lanes only; Master-Plan mutations serial | Orchestrator |

**Sequential fallback note (exact):**

```
Capability lanes ran sequentially (platform does not support parallel subagents).
```

### 2.2 Data Flow

1. Orchestrator detects installed platforms via AgentCapability sentinels.
2. Loads specialists roster (if any), project skills, declared MCP needs, detectable host tools, and Work Package rows when present.
3. Filters lanes by current phase + trigger match; rejects reserved `agtoosa-*` project specialist/skill collisions.
4. If host supports native parallel delegation **and** same-wave ownership is disjoint → fan out; else sequential with fallback note.
5. Each lane returns Terminal Evidence (and specialist evidence blocks when applicable).
6. Orchestrator merges into phase artifacts; only then may Master-Plan checkboxes/status change.
7. Async external returns must pass `/agtoosa-import` before closure.

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Spoofed “runtime orchestrator” claim | Spoofing | Claim Boundary AC-004; bats forbid scheduler claims |
| Parallel lanes overwrite same files | Tampering | DEV-045 disjoint ownership / sequential fallback (AC-005) |
| Subagent marks tasks Done without proof | Repudiation | Terminal Evidence + import gate (AC-006) |
| MCP server names leak secrets | Information Disclosure | Names/paths only; user approves MCP scope |
| Fan-out storms block host | Denial of Service | Prefer bounded lane catalogs; sequential fallback |
| Lane elevates into Master-Plan edits | Elevation of Privilege | Serial Master-Plan mutation by orchestrator only |

### 2.4 Build Scope

**In scope:** Orchestration doc + mirrors; Spec/Build/Review/Ship/Agent/Quickref/guide hooks; ADR-003 amendment; `lib/config.sh`; ORB bats; test-plan evidence.

**Out of scope:** Version bump; Wave 1a stories; verifier hard-fail for missing brain step; new MCP servers; default specialist roster.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED contract bats
  - [ ] 1.1 Add ORB-001–ORB-008 failing greps for doc, inventory, Claim Boundary, hooks, config — _Requirements: AC-008, AC-010_
- [ ] **2.** Canonical Orchestration Brain
  - [ ] 2.1 Author `template/Docs/AgToosa_Orchestration.md` + `docs/` mirror — _Requirements: AC-001, AC-002, AC-004_
  - [ ] 2.2 Amend ADR-003 follow-up (default-parallel when capable) — _Requirements: AC-004_
- [ ] **3.** Workflow + guide hooks
  - [ ] 3.1 Wire Spec, Build, Review, Ship step 0 pointers — _Requirements: AC-003, AC-005, AC-006_
  - [ ] 3.2 Wire Agent, Quickref, subagent-heavy guide; optional QA/task Should pointers — _Requirements: AC-003, AC-009_
  - [ ] 3.3 Register `lib/config.sh` inventory entry — _Requirements: AC-007_
- [ ] **4.** Evidence
  - [ ] 4.1 GREEN ORB bats + test-plan RED/GREEN blocks — _Requirements: AC-008, AC-010_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1  
**Wave 2 (sequential after Wave 1):** 2.2, 3.1, 3.2, 3.3  
**Wave 3 (sequential after Wave 2):** 4.1

> Wave 2 note: 3.1–3.3 touch different file sets and may run in parallel after 2.1 exists; 2.2 (ADR) is file-disjoint from workflow hooks and may run with them. Prefer sequential within Wave 2 only if merge conflicts appear on mirrors.

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-107.md`  
AC coverage: 10 ACs mapped to 8 ORB test IDs (AC-009 Should covered by ORB-007 pointer optional assert)  
Smoke set: ORB-001, ORB-002, ORB-003, ORB-008 tagged @smoke

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` | — | ORB bats RED | 1 | `bats tests/agtoosa.bats -f "ORB-"` |
| PKG-2.1 | 1 | — | `template/Docs/AgToosa_Orchestration.md`, `docs/AgToosa_Orchestration.md` | Plan + this spec | Canonical brain doc | 1 | `test -s template/Docs/AgToosa_Orchestration.md && test -s docs/AgToosa_Orchestration.md` |
| PKG-2.2 | 2 | PKG-2.1 | `docs/adr/ADR-003-multi-agent-orchestration.md` | PKG-2.1 | ADR amendment | 2 | `rg -n "DEV-107|Orchestration Brain" docs/adr/ADR-003-multi-agent-orchestration.md` |
| PKG-3.1 | 2 | PKG-2.1 | `template/Docs/AgToosa_Spec.md`, `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md`, `template/Docs/AgToosa_Review.md`, `docs/AgToosa_Review.md`, `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md` | PKG-2.1 | Step 0 hooks | 3 | `rg -n "AgToosa_Orchestration" docs/AgToosa_Spec.md docs/AgToosa_Build.md docs/AgToosa_Review.md docs/AgToosa_Ship.md` |
| PKG-3.2 | 2 | PKG-2.1 | `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md`, `docs/guides/subagent-heavy-workflows.md` | PKG-2.1 | Agent/Quickref/guide pointers | 3 | `rg -n "AgToosa_Orchestration" docs/AgToosa_Agent.md docs/AgToosa_Quickref.md docs/guides/subagent-heavy-workflows.md` |
| PKG-3.3 | 2 | PKG-2.1 | `lib/config.sh` | PKG-2.1 | Config inventory row | 4 | `rg -n "AgToosa_Orchestration.md" lib/config.sh` |
| PKG-4.1 | 3 | PKG-1.1, PKG-3.1, PKG-3.2, PKG-3.3 | `docs/AgToosa_TestPlan-DEV-107.md`, `tests/agtoosa.bats` | Wave 2 outputs | GREEN evidence | 5 | `bats tests/agtoosa.bats -f "DEV-107\\|ORB-"` |

> Ownership note: PKG-1.1 and PKG-4.1 both touch `tests/agtoosa.bats` across waves (allowed). Within Wave 2, PKG-3.1 / PKG-3.2 / PKG-3.3 / PKG-2.2 are file-disjoint and may parallelize.

## Capability Delta

Capability: orchestration-brain

| Change | Requirement | Notes |
|--------|-------------|-------|
| ADDED | WHEN a lifecycle command prepares fan-out, THE SYSTEM SHALL run Orchestration Brain step 0 (inventory → lane plan → parallel/sequential → merge) | new with DEV-107 |
| ADDED | WHEN describing orchestration, THE SYSTEM SHALL NOT claim a runtime scheduler or hosted auto-launch | Claim Boundary |

## ✅ Spec Approved

Approved: 2026-07-12 (plan lock A + implement request)
