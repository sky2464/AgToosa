# Spec: DEV-110 — AgToosa Project Intake

> **Story ID:** DEV-110  
> **Epic:** DEV-002 — Workflow Templates  
> **Status:** ⬜ Backlog  
> **Estimate:** M  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  
> **ADR:** `docs/adr/ADR-013-project-intake.md`

## Context

Users often omit `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, or `/agtoosa-ship` and instead send freeform prompts (“fix this error”, “the browser shows…”, “update dependencies and never invent versions from memory”). Today AgToosa is slash-gated: without an explicit command, host agents may implement untracked changes and bypass Master-Plan discipline.

Closest existing patterns (extend, do not replace): Discovery Triage (mid-build only), `/agtoosa-help next` (suggest only), Task vs Spec boundary, Phase Stop, Standing Iron Law on dependency versions. DEV-109 covers post-phase next-step sync and multi-spec clarity — not cold-start freeform PM intake.

**Smart interview decisions (recorded):**

| Decision | Choice |
|----------|--------|
| Enforcement | Dual-mode: soft for small; hard gate for Claim-Boundary-sized risk |
| Hard-gate threshold | Claim-Boundary sized (new story/architecture, multi-primary-surface, security/trust, Active Cycle conflict, scope expand without Spec Approved) |
| Delivery | Always-on core rule + Agent contract; slash commands bypass intake ceremony |
| Logging | Tiered: soft = response one-liner; hard = record after confirm when task/spec/backlog changes |
| Destinations | task · review finding/sub-task · in-scope build · `/agtoosa-spec` · factor out; **expedite** once soft-routed or hard-confirmed |
| Lessons | Dated, deduped `## Standing Corrections` in `Docs/Context/workflow.md`; read before classify/act |
| Voice | **AgToosa Project Intake** — benefit framing (protect Master Plan; prevent untracked AI drift) |
| Enrollment | Backlog immediately after planned specs (after DEV-109); expedite build when capacity frees |

**Specialist lanes:** none (no `docs/Context/specialists.md`).

**Story Skill Opportunity Synthesis (2026-07-12):**

| Skill name | Trigger | Purpose | Decision | Reason |
|------------|---------|---------|----------|--------|
| `project-intake` | Freeform ask without `/agtoosa-*` | Classify and route intake | **Do not generate** | Reserved `agtoosa-*` namespace; behavior belongs in always-on Agent contract + `agtoosa-core.mdc` |
| `agtoosa-help` duplicate | Same as help-next | Suggest next command | **Do not generate** | help-next is suggest-only; intake is classify + expedite/hard-gate |

**Active Tasks policy:** Task tree lives in spec §3.1 until enrollment; mirror to `docs/Master-Plan.md` `## Active Tasks` when DEV-110 enters Active Cycle (backlog after DEV-109; expedite when capacity frees).

### Spec Quality Analyzer (2026-07-12, re-run)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC → test-plan mapping | Pass — see test plan |
| Claim Boundary classified | Pass — §1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | When users omit `/agtoosa-*`, AgToosa still acts as PM: classify the ask, soft-handle small work, hard-gate large/risky work, persist Standing Corrections, and expedite the user’s ask once routed. |
| User outcome | Mid-work freeform prompts are addressed without wrecking Master-Plan discipline or repeating known mistakes (e.g. inventing package versions from memory). |
| Success condition | Always-on core + Agent contract implement dual-mode Project Intake; Standing Corrections template in `workflow.md`; INT bats prove docs/rule wiring; Phase Stop preserved (no auto Spec→Build→Ship). |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-110.md`; bats filter `DEV-110` / `INT-`; review evidence at ship. |
| Non-goals | Runtime workflow engine; auto-chaining phases; replacing Discovery Triage mid-build; merging into DEV-109; Update Log spam for every typo fix; new `/agtoosa-intake` slash command (always-on contract instead). |
| Assumptions | Wave 1a / Wave 2 may still occupy Active Cycle; DEV-110 stays Backlog after DEV-109 until capacity frees, then expedites. |
| Risks | Soft path over-applies and skips Spec for architecture; hard path over-interrupts; Standing Corrections grow without dedupe; agents ignore alwaysApply rules on some hosts. Mitigate with Claim-Boundary triggers, dedupe rules, and contract bats. |
| Unresolved questions | None for Must scope. |

### 1.2 User Stories

**As an** AgToosa user mid-development who forgets slash commands, **I want** AgToosa to classify my freeform ask **so that** small fixes proceed quickly and large changes go through Spec/Review without untracked AI drift.

**As an** AgToosa user correcting a repeated AI mistake (e.g. “always verify package versions on the internet”), **I want** that lesson stored as a Standing Correction **so that** the same failure cannot recur minutes later.

**As an** AgToosa agent, **I want** dual-mode Project Intake in always-on rules and the Agent contract **so that** I protect the Master Plan while still expediting in-scope user requests.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the user sends a freeform request without an explicit `/agtoosa-*` (or named `agtoosa-*`) command THE SYSTEM SHALL run Project Intake: read `Docs/Context/workflow.md` Standing Corrections (if present), then classify the ask | Must |
| AC-002 | WHILE the ask is Claim-Boundary-small (local bug/chore/debug cleanup, &lt;15 min, no architecture, no multi-primary-surface, no security/trust expand, no Active Cycle conflict) WHEN Project Intake classifies soft THE SYSTEM SHALL expedite under the chosen destination with a quiet one-line route note (no hard-gate ceremony) | Must |
| AC-003 | WHILE any Claim-Boundary hard trigger applies WHEN Project Intake classifies hard THE SYSTEM SHALL not modify product/implementation code until the user confirms; THE SYSTEM SHALL present a benefit-framed **AgToosa Project Intake** message naming the recommended next command | Must |
| AC-004 | WHEN Project Intake classifies THE SYSTEM SHALL map to exactly one primary destination from {`/agtoosa-task`, review finding or Active Tasks sub-task for next `/agtoosa-review`, continue in-scope `/agtoosa-build`, `/agtoosa-spec` or `quick`, factor-out/ignore} per the destination table in §2.1 | Must |
| AC-005 | WHEN the user states an always/never standing rule or confirms a hard-gate lesson that must not recur THE SYSTEM SHALL append a dated, deduped entry under `## Standing Corrections` in `Docs/Context/workflow.md` and require re-read on subsequent intake | Must |
| AC-006 | WHEN Project Intake completes THE SYSTEM SHALL use tiered logging: soft path writes Master-Plan/Update Log only if a Backlog/`/agtoosa-task` (or equivalent tracked) entry is created; hard path records the confirmed decision (task, scope note, Update Log, or deferred-to-spec) after user confirm | Must |
| AC-007 | WHEN AgToosa ships or updates Cursor core rules THE SYSTEM SHALL set `template/.cursor/rules/agtoosa-core.mdc` `alwaysApply: true` and document dual-mode Project Intake in `Docs/AgToosa_Agent.md` (and maintainer `docs/` mirror); WHEN the user invokes an explicit `/agtoosa-*` command THE SYSTEM SHALL bypass Project Intake ceremony and run that workflow | Must |
| AC-008 | WHEN Project Intake recommends Spec, Build, Review, or Ship THE SYSTEM SHALL preserve Phase Stop — never auto-chain Spec→Build→Review→Ship | Must |
| AC-009 | WHEN enforcement is described THE SYSTEM SHALL classify Project Intake as agent-instructed (docs + always-on rules); focused INT bats as CI-enforced when configured; Active Cycle enrollment as manual; runtime orchestrator as roadmap / out of scope | Must |
| AC-010 | WHEN DEV-110 is enrolled in Master-Plan / roadmap THE SYSTEM SHALL place it in Backlog immediately after already-planned specs (after DEV-109) and document expedite-when-capacity-free | Must |
| AC-011 | WHEN `tests/agtoosa.bats` runs DEV-110 coverage THE SYSTEM SHALL assert Project Intake contract strings, alwaysApply, Standing Corrections section, destination/hard-gate wording, Phase Stop preservation, and template↔docs mirrors where required | Must |
| AC-012 | WHEN shipping THE SYSTEM SHALL record RED/GREEN evidence in the test plan without claims beyond completed scope | Must |
| AC-013 | WHEN Spec-First language in core rules is updated THE SYSTEM SHALL allow soft-path local in-scope/chore fixes without a new Spec Approved file, while hard path still requires Spec (or explicit user override) before architecture/multi-surface/security work | Should |
| AC-014 | WHEN help or Quickref surfaces list governance aids THE SYSTEM SHALL include a one-line Project Intake pointer (Should) | Could |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Freeform asks skip PM classify; untracked AI edits |
| AC-002 | Tiny asks blocked by ceremony; user abandons AgToosa |
| AC-003 | Large asks silently coded; Master Plan drifts |
| AC-004 | Ambiguous routing; wrong lifecycle ownership |
| AC-005 | Same mistake repeats within the session or next day |
| AC-006 | No audit trail for hard decisions; or Update Log noise |
| AC-007 | Rules never load (`alwaysApply: false`); slash path double-gates |
| AC-008 | Intake auto-runs build after “confirm Spec” |
| AC-009 | Docs claim a hard runtime engine that does not exist |
| AC-010 | Story lost behind unrelated backlog; never expedited |
| AC-011 | Regressions ship without contract bats |
| AC-012 | Ship claims without evidence |

### 1.4 Out of Scope

- New `/agtoosa-intake` slash command or skill (always-on + Agent contract instead)
- Replacing mid-build Discovery Triage Protocol
- Merging requirements into DEV-109
- Runtime / hosted orchestration (DEV-107 remains separate)
- Auto-enrolling DEV-110 into Active Cycle during this Spec phase
- Changing Part 5.5 finding-ranking algorithm
- Telemetry or remote lesson sync

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | Slash-only routing; `agtoosa-core.mdc` `alwaysApply: false`; no freeform classifier; Discovery Triage mid-build only; Iron Law “never assume dependency versions” exists but is not promoted from freeform corrections into `workflow.md` |
| Intended change deltas | Dual-mode Project Intake; alwaysApply true; Standing Corrections section; Spec-First soft/hard split; destination map; expedite after route |
| Drift evidence | User request 2026-07-12; explore of Agent/Build/core.mdc; DEV-109 non-goals exclude freeform dispatcher |
| Claim Boundary | See §1.6 |
| Source of truth | `docs/Master-Plan.md` remains repo-local SoT |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Project Intake dual-mode algorithm, destination map, Standing Corrections, hard-gate copy in Agent/core rules | agent-instructed |
| Template install of `agtoosa-core.mdc` with `alwaysApply: true` via generator copy | generator-enforced |
| Focused INT bats / doc greps in CI when configured | CI-enforced |
| Enrolling DEV-110 into Active Cycle / choosing build wave | manual |
| Runtime auto-dispatch or forced tool interception | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

**Brand voice (hard gate — normative shape):**

```text
**AgToosa Project Intake** — This change is bigger than a quick fix.
Routing it through /agtoosa-spec keeps it on the Master Plan, captures
Standing Corrections when needed, and prevents an untracked AI edit from
drifting the product. Confirm to open Spec, or say how you want to override.
```

(Soft path: one quiet line, e.g. `Intake: soft → /agtoosa-task — expediting.`.)

**Hard-gate triggers (Claim-Boundary sized):**

- New feature / architecture change
- Touches more than one primary surface (e.g. generator + template + tests as a coordinated product change beyond the immediate bug)
- Security / trust boundary
- Active Cycle conflict (ask conflicts with In Review / In Progress story ownership)
- Would enroll or expand scope without a Spec Approved path

**Soft path (expedite):**

- Single-file / local bug, debug output cleanup, obvious typo/chore
- In-scope incomplete Active Task
- Tiny regression clearly owned by current In Review story → attach as review finding/sub-task (soft if tiny; hard if expands review scope)

**Destination table:**

| Signal | Mode | Destination |
|--------|------|-------------|
| Local bug/chore/debug, &lt;15 min | Soft | Expedite now; `/agtoosa-task` if tracking needed |
| Regression from current cycle | Soft if tiny; Hard if expands review | Review finding or Active Tasks sub-task for next `/agtoosa-review` |
| In-scope Active Task | Soft | Continue under `/agtoosa-build` rules |
| New feature / architecture / multi-surface / security / cycle conflict | Hard | Stop; propose `/agtoosa-spec` (or `quick`); confirm before code |
| Out of charter / noise | Soft note | Factor out or Backlog spike — confirm if unsure |

**Standing Corrections format (under `## Standing Corrections` in workflow.md):**

```markdown
## Standing Corrections

| Date | Correction | Origin |
|------|------------|--------|
| YYYY-MM-DD | Never assume dependency versions from memory — verify via web/terminal first | Project Intake / user |
```

Dedupe: if an equivalent correction already exists (same intent), refresh the date instead of duplicating rows.

**Files to create/update (build phase):**

| Surface | Action |
|---------|--------|
| `docs/adr/ADR-013-project-intake.md` | Create (this ADR); mark Accepted on build start |
| `template/Docs/AgToosa_Agent.md` + `docs/` mirror | New **Project Intake** section; dual-mode; destinations; Standing Corrections; Phase Stop cross-link |
| `template/.cursor/rules/agtoosa-core.mdc` | `alwaysApply: true`; dual-mode Spec-First; Project Intake pointer |
| `template/CLAUDE.md`, `template/AGENTS.md` (+ other entry points that load AgToosa) | One-line Project Intake always-on pointer |
| `template/Docs/Context/workflow.md` + `docs/Context/workflow.md` | `## Standing Corrections` template section |
| `docs/Context/CONTEXT.md` | Term: Project Intake |
| Help / Quickref (Should/Could) | One-line pointer |
| `tests/agtoosa.bats` | INT-001… coverage |

### 2.2 Data Flow

```text
1. User sends freeform ask (no /agtoosa-*).
2. Agent loads always-on core + Agent Project Intake contract.
3. Read Docs/Context/workflow.md Standing Corrections (if section exists).
4. Classify soft vs hard using Claim-Boundary triggers.
5a. Soft: emit quiet route line → expedite destination (task/build/review/factor-out).
5b. Hard: emit benefit-framed Project Intake message → wait for confirm → then expedite.
6. If always/never lesson: append/dedupe Standing Corrections.
7. Tiered Master-Plan logging per AC-006.
8. Never auto-chain to the next lifecycle phase (Phase Stop).
```

Slash path: user names `/agtoosa-*` → skip steps 3–5 ceremony → run named workflow (Standing Corrections still apply as project memory when relevant).

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Spoofed soft classification to skip Spec on architecture | Spoofing | Hard-gate trigger list; AC-003 no product code until confirm |
| Tampered Standing Corrections weaken security rules | Tampering | Dated table; review during `/agtoosa-review`; bats on section presence |
| Untracked freeform fixes with no audit | Repudiation | Tiered logging; hard path records after confirm |
| Standing Corrections leak secrets from user paste | Information Disclosure | Instruct agents to redact secrets; store intent not credentials |
| Hard-gate on every typo → user disables AgToosa | Denial of Service | Soft path for Claim-Boundary-small; quiet one-liner |
| Soft path elevates privileges via “quick fix” | Elevation of Privilege | Security/trust always hard-gates |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : AgToosa_Agent.md (+template), agtoosa-core.mdc, CLAUDE.md/AGENTS.md entry pointers, Context/workflow.md (+template), CONTEXT.md, ADR-013, help/quickref one-liners (Should), tests/agtoosa.bats, Master-Plan/roadmap enrollment docs
Directories in scope: docs/, template/, tests/
Out of scope        : New slash intake command, DEV-109 merge, DEV-107 runtime, Discovery Triage rewrite, version bump, auto-phase chaining, Part 5.5 ranking rewrite
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract docs + ADR
  - [ ] 1.1 Finalize ADR-013 Accepted on build start; add CONTEXT term Project Intake — _Requirements: AC-005, AC-009, AC-010_
  - [ ] 1.2 Add Project Intake section to Agent.md (+ template mirror): dual-mode, destinations, Standing Corrections, expedite, Phase Stop — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-008_
  - [ ] 1.3 Update Spec-First / dual-mode wording in core rule; set `alwaysApply: true` — _Requirements: AC-007, AC-013_
  - [ ] 1.4 Add Standing Corrections template to workflow.md (+ mirrors) — _Requirements: AC-005_
  - [ ] 1.5 Entry-point one-liners (CLAUDE.md, AGENTS.md, help/quickref as Should/Could) — _Requirements: AC-007, AC-014_
- [ ] **2.** Tests + evidence
  - [ ] 2.1 Add INT bats (alwaysApply, Standing Corrections, intake contract strings, Phase Stop, mirrors) — _Requirements: AC-011_
  - [ ] 2.2 Record RED/GREEN in test plan — _Requirements: AC-012_

### 3.2 Wave Plan

```
**Wave 1 (parallel):** 1.1, 1.4, 2.1 (RED stubs)
**Wave 2 (sequential after Wave 1):** 1.2, 1.3
**Wave 3 (parallel after Wave 2):** 1.5, 2.1 GREEN assertions, 2.2
```

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-DEV-110.md`.

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|----------|-------------|--------------|
| PKG-1.1 | 1 | — | `docs/adr/ADR-013-project-intake.md`, `docs/Context/CONTEXT.md` | interview decisions | ADR + term | 1 | file present; term listed |
| PKG-1.4 | 1 | — | `template/Docs/Context/workflow.md`, `docs/Context/workflow.md` | AC-005 | Standing Corrections section | 1 | bats grep section |
| PKG-2.1a | 1 | — | `tests/agtoosa.bats` (INT RED section) | ACs | failing INT tests | 2 | RED evidence |
| PKG-1.2 | 2 | PKG-1.1 | `docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Agent.md` | ADR-013 | Project Intake section | 1 | bats doc greps |
| PKG-1.3 | 2 | PKG-1.1 | `template/.cursor/rules/agtoosa-core.mdc` | AC-007 | alwaysApply + dual-mode | 2 | bats grep alwaysApply |
| PKG-1.5 | 3 | PKG-1.2 | `template/CLAUDE.md`, `template/AGENTS.md`, help/quickref | AC-007, AC-014 | pointers | 1 | greps |
| PKG-2.1b | 3 | PKG-1.2, PKG-1.3, PKG-1.4 | `tests/agtoosa.bats` | INT GREEN | passing INT | 2 | bats filter DEV-110 |
| PKG-2.2 | 3 | PKG-2.1b | `docs/AgToosa_TestPlan-DEV-110.md` | evidence | RED/GREEN filled | 3 | test plan updated |
