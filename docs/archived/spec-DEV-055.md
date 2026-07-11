# Spec: DEV-055 — Agent Capability Matrix

> **Story ID:** DEV-055
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟦 Todo
> **Estimate:** S
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11

## Context

DEV-031 shipped project-specific specialists with a **platform native-target** matrix in `AgToosa_Specialists.md`. DEV-047 shipped async handoff packs; DEV-050 shipped cross-model review. The remaining gap is a **lifecycle capability matrix**: detect which agent surfaces are installed in a repo and recommend the best path for build, handoff, review (including cross-model), and specialist delegation — with honest fallbacks when a platform lacks native subagents.

**User-selected scope (recorded as findings):**

| Decision | Choice |
|----------|--------|
| Story ID | DEV-055 — Agent Capability Matrix (follow-on to DEV-050 subagent wave) |
| Not enrolled this cycle | DEV-045 (M, DAG schema remainder), DEV-059 (M, governance) — remain backlog |
| Distinction | `AgToosa_Specialists.md` § Platform Capability Matrix = specialist **native file targets**; this story = **lifecycle routing** matrix |
| Enforcement | Agent-instructed routing + generator file inventory for canonical doc; no runtime router |
| Estimate | **S** — canonical doc, workflow hooks, config registration, focused bats |

**Smart interview findings (gaps covered without additional questions):**

| Checklist area | Finding |
|----------------|---------|
| Status quo | Platform detection exists in Specialists + `--list-template-files`; no unified matrix for handoff/review/build routing |
| Narrowest v1 | `AgToosa_AgentCapability.md` + hooks in Handoff/Build/Review/Help + `lib/config.sh` + AM bats; no auto-dispatch service |
| Urgency | After DEV-050; user requested next enrollment post-v5.3.6 ship |
| Failure modes | Matrix claims native support where only fallback docs exist; drift from `lib/config.sh` sentinels; duplicates Specialists platform table |
| Security | Read-only detection; no secret collection; routing is advisory |
| Test evidence | Bats grep matrix rows, detection sentinels, workflow cross-links, config inventory |
| Rollout | Template + maintainer mirrors on `--update` |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a canonical **Agent Capability Matrix** that detects installed agent surfaces and recommends the best lifecycle path (build, handoff, review, cross-model, specialists) per platform with explicit fallbacks. |
| User outcome | Users and orchestrators route async work, reviews, and subagent lanes to **available** tools without assuming every platform supports parallel delegation or GitHub agents. |
| Success condition | `AgToosa_AgentCapability.md` defines detection rules, matrix columns, routing algorithm, and fallback chain; Handoff/Build/Review/Help reference it; `lib/config.sh` installs the doc; bats AM-001–AM-007 green. |
| Proof / evidence | Test plan `docs/AgToosa_TestPlan-DEV-055.md`; bats filter green; review evidence at ship. |
| Non-goals | Hosted agent router; mandatory platform installs; replacing Specialists native-target table; DEV-045 wave DAG scheduler. |
| Assumptions | Detection uses the same sentinels as DEV-031; recommendations are agent-instructed; user may override routing. |
| Risks | Terminology collision with Specialists "Platform Capability Matrix"; overclaiming native parallel support. Mitigate with glossary + cross-links. |
| Unresolved questions | None. |

### 1.2 User Stories

**As an** AgToosa user running `/agtoosa-build handoff`, **I want** the workflow to recommend the best async agent surface installed in my repo **so that** I export handoff packs to a platform that can actually execute them.

**As an** AgToosa user running `/agtoosa-review cross-model`, **I want** a matrix that shows which hosts support parallel subagent delegation **so that** I choose a reviewer path with documented fallbacks.

**As an** AgToosa maintainer, **I want** bats to lock the capability matrix against `lib/config.sh` platform inventory **so that** releases do not drift from install reality.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_AgentCapability.md` is installed THE SYSTEM SHALL define installed-surface detection, matrix columns (commands, handoff, review, cross-model, specialists, fallbacks), and a routing recommendation algorithm | Must |
| AC-002 | WHEN the matrix references enforcement THE SYSTEM SHALL classify each capability row as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap | Must |
| AC-003 | WHEN `agtoosa.sh --update` installs workflow docs THE SYSTEM SHALL include `Docs/AgToosa_AgentCapability.md` via `lib/config.sh` | Must |
| AC-004 | WHEN `/agtoosa-handoff` assembles a pack THE SYSTEM SHALL consult the matrix to recommend a target agent surface and document fallbacks when the preferred surface is absent | Must |
| AC-005 | WHEN `/agtoosa-review` or `/agtoosa-review cross-model` runs THE SYSTEM SHALL reference the matrix for parallel-delegation support and sequential fallback wording per platform | Must |
| AC-006 | WHEN `/agtoosa-help next` runs in assistance mode THE SYSTEM MAY include one matrix-based routing hint for the recommended next command (read-only; no mutation) | Should |
| AC-007 | WHEN `Docs/AgToosa_Specialists.md` is read THE SYSTEM SHALL cross-link to `AgToosa_AgentCapability.md` and SHALL NOT duplicate the full lifecycle routing table inline | Must |
| AC-008 | WHEN external agents or dashboards are mentioned THE SYSTEM SHALL preserve `docs/Master-Plan.md` as repo-local source of truth | Must |
| AC-009 | WHEN `tests/agtoosa.bats` runs DEV-055 coverage THE SYSTEM SHALL assert doc inventory, matrix rows for all installed platforms in `lib/config.sh`, workflow cross-links, and detection sentinel parity | Must |
| AC-010 | WHEN shipping THE SYSTEM SHALL record RED/GREEN evidence in the test plan without claims beyond completed scope | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Matrix omits Cursor sequential fallback → users expect parallel subagents |
| AC-004 | Handoff recommends Codex when `.codex/` absent |
| AC-005 | Review doc contradicts matrix on cross-model support |
| AC-007 | Two divergent routing tables (Specialists vs AgentCapability) |
| AC-009 | New platform added to `lib/config.sh` without matrix row |

### 1.4 Out of Scope

- Runtime capability probing or network calls to agent APIs
- DEV-045 owned-files / wave DAG schema (separate story)
- DEV-059 governance policy-as-code
- Auto-installing missing platforms

### 1.5 Claim Boundary

| Control | Classification |
|---------|----------------|
| Capability matrix doc + workflow references | agent-instructed |
| Doc installed via `lib/config.sh` | generator-enforced |
| Platform detection at install time | generator-enforced (sentinel files) |
| Routing recommendations during workflows | agent-instructed |
| Automatic agent launch | manual / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

```
Installed sentinels (.cursor/, .claude/, …)
        │
        ▼
AgToosa_AgentCapability.md (canonical matrix)
        │
        ├── /agtoosa-handoff → recommend target agent
        ├── /agtoosa-review + cross-model → parallel vs sequential
        ├── /agtoosa-build handoff → async dispatch hint
        └── /agtoosa-help next → optional routing hint (Should)
```

**Surfaces:**

| Surface | Action |
|---------|--------|
| `template/Docs/AgToosa_AgentCapability.md` | **Create** |
| `docs/AgToosa_AgentCapability.md` | **Mirror** |
| `template/Docs/AgToosa_Handoff.md`, `AgToosa_Review.md`, `AgToosa_Build.md`, `AgToosa_Help.md` | **Update** — matrix pointers |
| `template/Docs/AgToosa_Specialists.md` | **Update** — cross-link only |
| `lib/config.sh` | **Register** doc |
| `tests/agtoosa.bats` | **Add** AM-001–AM-007 |

### 2.2 Data Flow

1. Orchestrator reads `.agtoosa-lock.json` / sentinel directories (same rules as Specialists).
2. Intersect with matrix rows → list **available** surfaces.
3. For requested phase (handoff, review, build-async), pick recommended row + fallback chain.
4. Record recommendation in handoff pack or review notes (advisory).

### 2.3 STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Spoofing | Matrix claims platform installed when sentinel missing | Detection rules reference concrete paths only |
| Tampering | Stale matrix after new platform wiring | AM-009 parity bats vs `lib/config.sh` |
| Repudiation | No record of routing recommendation | Handoff/review artifacts cite matrix row used |
| Information Disclosure | Matrix embeds secrets | Paths and commands only |
| Denial of Service | Mandatory platform blocks workflow | Fallback chain always documented |
| Elevation | Matrix instructs destructive git on wrong host | Handoff Allowed Actions unchanged; matrix is advisory |

### 2.4 Build Scope

**In scope:** `AgToosa_AgentCapability.md`, Handoff/Review/Build/Help/Specialists mirrors, `lib/config.sh`, `tests/agtoosa.bats` AM section.

**Out of scope:** Version bump, verifier changes, DEV-045/DEV-059.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED contract bats (AM-001–AM-007) — _Requirements: AC-003, AC-009, AC-010_
- [ ] **2.** Canonical `AgToosa_AgentCapability.md` + maintainer mirror — _Requirements: AC-001, AC-002, AC-008_
- [ ] **3.** Wire Handoff, Review, Build, Help cross-links — _Requirements: AC-004, AC-005, AC-006, AC-007_
- [ ] **4.** Register `lib/config.sh` + Specialists cross-link — _Requirements: AC-003, AC-007_
- [ ] **5.** GREEN bats + test-plan evidence — _Requirements: AC-009, AC-010_

### Wave Plan

**Wave 1 (parallel):** 1, 2  
**Wave 2 (sequential after Wave 1):** 3, 4  
**Wave 3 (sequential after Wave 2):** 5

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- No contradiction with Non-goals / Claim Boundary: yes
- Every Must AC maps to test-plan row: yes (AM-001–AM-007)
- Enforcement classified: yes (§1.5)
- SoT preserved: yes
- No TBD/TODO placeholders: yes
