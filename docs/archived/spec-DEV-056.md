# Spec: DEV-056 — Retrospective Learning Loop

> **Story ID:** DEV-056
> **Epic:** DEV-002
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

`/agtoosa-ship retro` already asks Keep/Stop/Start questions and can append a changelog retrospective plus process action items. The missing capability is a durable, evidence-linked learning artifact with bounded proposals. Without that structure, retrospectives can become untraceable prose, repeat unsupported claims, or bypass normal lifecycle gates by directly changing specs, policy, workflow context, or backlog state.

DEV-056 turns completed repo-local evidence into proposals, not automatic decisions. A retro may recommend a task, spec, approved-spec amendment, policy rule, specialist, test, or workflow amendment, but the accepted change must still enter through `/agtoosa-task`, `/agtoosa-spec`, or `/agtoosa-spec amend`. The mode-appropriate `docs/Master-Plan.md` or `Docs/Master-Plan.md` remains the authority for lifecycle state.

This story depends on stable evidence sources such as DEV-049 and benefits from DEV-059 when it proposes policy rules. Dependency order is guidance only; the Master-Plan backlog remains authoritative. This story remains Backlog until explicitly enrolled.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Close the ship feedback loop with a structured, evidence-linked retrospective that records lessons and proposes bounded follow-up work without applying it automatically. |
| User outcome | Teams can identify repeated friction, preserve useful practices, reject unsupported overreach, and route accepted improvements through normal AgToosa gates. |
| Success condition | `/agtoosa-ship retro` creates one per-cycle retro artifact with required sections, evidence pointers, proposal records, repetition rules, and explicit next commands; future RL-001–RL-007 checks cover the contract. |
| Proof / evidence | Future RED/GREEN records in `docs/AgToosa_TestPlan-DEV-056.md`, RL-focused bats output, a fixture retro, review findings, and ship evidence ledger pointers. No proof exists while this story is Backlog. |
| Non-goals | Private or hosted memory; ML scoring; autonomous backlog enrollment; automatic policy/spec/context changes; organizational-learning claims; dashboard rendering. |
| Assumptions | Changelog, archived specs/reviews/evidence, test plans, Master-Plan cycle data, and `agtoosa-events.jsonl` are available repo-locally; missing optional evidence is reported honestly. |
| Risks | Proposals lack evidence; a retro silently mutates authority files; copied logs disclose secrets; repeated wording is mistaken for a validated pattern. |
| Unresolved questions | None for v1: one artifact is created per cycle as `archived/retro-[cycle-date].md` under the selected `docs/` or `Docs/` root, with story-specific evidence rows inside it. |

### 1.2 User Stories

**As a** maintainer closing a release cycle, **I want** planned-versus-shipped results linked to specs, tests, reviews, and evidence ledgers **so that** the retrospective is auditable.

**As a** team lead, **I want** repeated friction to produce a bounded proposal with a next command **so that** workflow improvements enter through the same gates as product work.

**As a** contributor, **I want** rejected overreach and deferred work recorded separately from shipped outcomes **so that** future planning does not repeat unsupported claims.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-ship retro` completes for a cycle THE SYSTEM SHALL create or update `archived/retro-[cycle-date].md` under the selected `docs/` or `Docs/` root with metadata and the sections `Planned vs Shipped`, `Evidence Index`, `Keep`, `Stop`, `Start`, `Rejected Overreach`, and `Proposals` | Must |
| AC-002 | WHEN the retro records a follow-up THE SYSTEM SHALL store its `proposal_id`, `type`, `summary`, `evidence_pointer`, `status`, and `next_command`; policy proposals SHALL also store an `enforcement_class` | Must |
| AC-003 | WHEN a proposal would change the mode-appropriate Master-Plan, an approved spec, policy, workflow context, tests, or specialist files THE SYSTEM SHALL leave those targets unchanged and SHALL require explicit user acceptance through `/agtoosa-task`, `/agtoosa-spec`, or `/agtoosa-spec amend` | Must |
| AC-004 | WHEN the retro gathers inputs THE SYSTEM SHALL read only repo-local Master-Plan, changelog, archived spec/review/evidence, test-plan, and event artifacts and SHALL represent missing or malformed optional sources as `unavailable` without requiring network access | Must |
| AC-005 | WHEN the retro describes capture, recommendations, or enforcement THE SYSTEM SHALL classify installed files as generator-enforced, repository checks as CI-enforced when run, proposal generation as agent-instructed, proposal acceptance as manual, and automatic application as roadmap | Must |
| AC-006 | WHEN at least two distinct evidence pointers identify the same normalized friction category THE SYSTEM SHALL mark a repeated-pattern candidate and MAY propose a specialist, policy rule, regression test, or workflow amendment; WHEN fewer than two pointers exist THE SYSTEM SHALL label the observation `single-cycle` | Must |
| AC-007 | WHEN the retro cites logs, review text, or external-agent output THE SYSTEM SHALL store concise pointers and redacted summaries rather than secret values, credentials, private URLs, or copied unbounded logs | Must |

Allowed proposal `type` values are: `task`, `spec`, `amend`, `policy`, `specialist`, `test`, and `workflow`. Allowed proposal `status` values are: `proposed`, `accepted`, `rejected`, and `deferred`. Recording `accepted` documents a human decision; it does not itself apply the change.

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | Retro exists only as a changelog paragraph and has no durable evidence index. | Stop completion and create the per-cycle artifact. |
| FM-002 | AC-002 | Proposal lacks an evidence pointer or next command. | Keep it out of the proposal table and report the missing field. |
| FM-003 | AC-003 | Retro edits an approved spec, policy, Context file, or Master-Plan item directly. | Revert the attempted target mutation and present the canonical command. |
| FM-004 | AC-004 | Retro requires a tracker, hosted service, or network fetch. | Continue from local sources and mark the remote source unavailable. |
| FM-005 | AC-005 | Wording claims automated learning or enforced recommendations. | Downgrade the claim to the proven enforcement class. |
| FM-006 | AC-006 | One anecdote is labeled a repeated pattern. | Mark it `single-cycle`; require a second independent pointer. |
| FM-007 | AC-007 | Retro copies a token, private URL, or full log. | Redact the value, replace the copy with a pointer, and report the safety correction. |
| FM-008 | AC-001, AC-004 | Two retro runs for the same cycle create competing files. | Resolve the same normalized cycle-date path and update idempotently. |

### 1.5 Out of Scope

- Hosted retrospective analytics, telemetry, or private memory stores
- Machine-learning ranking, sentiment analysis, or automatic organizational-learning claims
- Automatically creating or reprioritizing Master-Plan rows
- Automatically editing approved specs, governance policy, the selected `docs/Context/` or `Docs/Context/`, tests, or specialists
- Treating external trackers or agents as more authoritative than repo-local artifacts
- Rendering the local dashboard owned by DEV-058
- Requiring a retro artifact as a verifier FAIL in v1
- Release/version changes before normal story enrollment and ship

### 1.6 Claim Boundary

| Control | Classification | Honest boundary |
|---------|----------------|-----------------|
| Retro workflow doc installed with AgToosa | generator-enforced | Generator installs the contract; it does not force an agent to follow it. |
| Retro schema and fixture checked in repository tests | CI-enforced | Applies when project/release CI runs RL checks. |
| Evidence collection and proposal generation | agent-instructed | The executing agent follows workflow prose over local artifacts. |
| Keep/Stop/Start answers and proposal acceptance | manual | A human supplies judgment and accepts or rejects follow-up work. |
| Writing the retro artifact after explicit invocation | agent-instructed | The workflow authorizes only the retro file and phase event, not target changes. |
| Applying accepted follow-up through a lifecycle command | manual | The user invokes the command; that command owns subsequent mutations. |
| Automatic proposal application or private learning memory | roadmap | Explicitly absent from v1. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `template/Docs/AgToosa_Retro.md` — canonical input, artifact-schema, normalization, proposal-routing, and redaction contract
- `docs/AgToosa_Retro.md` — maintainer-dogfood mirror with lowercase `docs/` paths
- `tests/fixtures/retro/complete-cycle/` — local cycle sources and expected structured retro
- `tests/fixtures/retro/missing-optional/` — fixture proving graceful unavailable-source handling
- `tests/fixtures/retro/repeated-friction/` — two independent pointers for pattern classification

Files to change:

- `template/Docs/AgToosa_Ship.md` and `docs/AgToosa_Ship.md` — make Part 5 delegate to the Retro contract and stop direct proposal-target mutation
- `template/Docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Quickref.md`, and matching `docs/` mirrors — describe the structured `ship retro` output
- `lib/config.sh` — install `AgToosa_Retro.md`
- `tests/agtoosa.bats` — RL-001–RL-007 contract checks
- `docs/AgToosa_TestPlan-DEV-056.md` — future TDD and validation evidence

Retro artifact schema:

- Metadata: cycle identifier/date, generated timestamp, selected source paths, source availability
- Planned vs Shipped: story, planned AC count, supported shipped result, deferred result, reason, evidence pointer
- Evidence Index: story, artifact type, repo-relative pointer, verification summary
- Keep/Stop/Start: concise finding, evidence pointer, scope
- Rejected Overreach: unsupported claim, reason rejected, evidence gap
- Proposals: required AC-002 fields plus repetition classification

No new top-level command or platform adapter is required; all platforms already route `/agtoosa-ship retro` through the canonical Ship workflow.

### 2.2 Data Flow

1. The user invokes `/agtoosa-ship retro` and selects or confirms the closed cycle.
2. The workflow resolves `docs/` in maintainer mode or `Docs/` in a generated project and reads the cycle row, changelog, matching archived specs/reviews/evidence, test plans, and local phase events.
3. Missing optional sources are listed as unavailable; no remote source is fetched.
4. Planned acceptance criteria are compared with evidence-supported shipped, deferred, and rejected outcomes.
5. The existing Keep/Stop/Start interview contributes human observations, each linked to a source or labeled as user judgment.
6. Findings are normalized into friction categories. Two distinct evidence pointers permit `repeated-pattern`; otherwise the finding remains `single-cycle`.
7. The workflow writes or updates one `retro-[cycle-date].md` artifact and appends a bounded retro-complete phase event.
8. The workflow presents proposals and next commands. It does not edit proposal targets.
9. The user may later accept a proposal by invoking `/agtoosa-task`, `/agtoosa-spec`, or `/agtoosa-spec amend`; that separate workflow owns all authoritative changes.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A retro attributes a finding to the wrong cycle or story | Spoofing | Record normalized cycle ID, story IDs, and repo-relative evidence pointers. |
| Retro rewrites shipped evidence or approved policy | Tampering | Retro is additive; AC-003 forbids target mutation and routes changes through canonical commands. |
| A team cannot tell why a proposal was made | Repudiation | Every proposal requires an evidence pointer and repetition classification. |
| Logs or external-agent output leak credentials | Information Disclosure | Redact summaries, store pointers, and reject secret values or private URLs. |
| Huge logs or many event rows consume context | Denial of Service | Read bounded excerpts, deduplicate pointers, and link to full local artifacts. |
| A recommendation silently gains authority over lifecycle state | Elevation of Privilege | Master-Plan remains authoritative; proposals are agent-instructed and acceptance is manual. |

### 2.4 Build Scope

Proposed future scope; `/agtoosa-spec` must revalidate it against the enrolled cycle before implementation.

```text
✅ Ready to proceed — Scope Boundary
Files in scope      : template/Docs/AgToosa_Retro.md, docs/AgToosa_Retro.md, template and maintainer mirrors for Ship/Agent/Quickref, lib/config.sh, retro fixtures, tests/agtoosa.bats, docs/AgToosa_TestPlan-DEV-056.md
Directories in scope: template/Docs/, docs/, tests/fixtures/retro/, tests/, lib/
Out of scope        : hosted/private memory, dashboard rendering, automatic target mutation, new platform adapters, verifier FAIL gates, version/release work before ship
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Contract-first retro fixtures and tests:** make artifact behavior falsifiable
  - [ ] 1.1 Add complete, missing-optional, and repeated-friction fixture cycles — _Requirements: AC-001, AC-004, AC-006, AC-007_
  - [ ] 1.2 Add failing RL-001, RL-004, RL-006, and RL-007 checks and record RED evidence — _Requirements: AC-001, AC-004, AC-006, AC-007_
- [ ] **2. Canonical retrospective contract:** define durable output and proposal boundaries
  - [ ] 2.1 Create `AgToosa_Retro.md` and maintainer mirror — _Requirements: AC-001, AC-002, AC-004, AC-005_
  - [ ] 2.2 Define proposal enums, repetition classification, and redaction rules — _Requirements: AC-002, AC-006, AC-007_
- [ ] **3. Ship workflow integration:** replace prose-only retro output with the structured loop
  - [ ] 3.1 Delegate Ship Part 5 to the Retro contract and preserve Keep/Stop/Start — _Requirements: AC-001, AC-004_
  - [ ] 3.2 Replace direct proposal-target edits with explicit command routing — _Requirements: AC-002, AC-003_
  - [ ] 3.3 Add bounded retro-complete event and idempotent artifact path behavior — _Requirements: AC-001, AC-004_
- [ ] **4. Discovery and installation wiring:** expose one canonical contract without platform duplication
  - [ ] 4.1 Update Agent and Quickref descriptions and register the doc in `lib/config.sh` — _Requirements: AC-001, AC-005_
  - [ ] 4.2 Add RL-002, RL-003, and RL-005 contract checks — _Requirements: AC-002, AC-003, AC-005_
- [ ] **5. Complete future verification:** close the TDD loop and preserve honest claims
  - [ ] 5.1 Run RL-001–RL-007 and focused regression commands, then record GREEN evidence — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_
  - [ ] 5.2 Review fixture output for source authority, bounded content, and secret redaction — _Requirements: AC-003, AC-004, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1
**Wave 2 (parallel after Wave 1):** 1.2, 2.2
**Wave 3 (sequential after Wave 2):** 3.1, 3.2, 3.3
**Wave 4 (parallel after Wave 3):** 4.1, 4.2
**Wave 5 (sequential after Wave 4):** 5.1, 5.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-056.md`
AC coverage: 7 of 7 ACs mapped to RL-001–RL-007
Must coverage: 7 of 7 Must ACs mapped
Smoke set: 7 planned tests tagged `@smoke`
Execution state: not run; this story is Backlog

## ✅ Spec Approved

Approved: 2026-07-11 21:50
Enrollment: remaining-specs fan-out wave 3 (post v5.3.10)
