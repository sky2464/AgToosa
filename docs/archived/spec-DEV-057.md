# Spec: DEV-057 — Multi-Repo Story Overlay

> **Story ID:** DEV-057
> **Epic:** DEV-002
> **Status:** ⬜ Backlog
> **Estimate:** L
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060
> **Prerequisite gate:** DEV-045 must ship and a Demand Evidence Record must be accepted before DEV-057 enrollment

## Context

AgToosa's lifecycle is intentionally repo-local. Each repository owns its own `docs/Master-Plan.md`, approved specs, handoff packs, import verification, and evidence. Existing `/agtoosa-handoff` and `/agtoosa-import` workflows can already coordinate work one repository at a time.

A multi-repo overlay is justified only when a real delivery story demonstrates that separate per-repo packs are insufficient—for example, because several independently governed repositories must expose dependency order, aggregate blockers, and a single evidence index for one release decision. DEV-057 must not invent that complexity speculatively.

### Demand Gate — Required Before Enrollment

DEV-057 remains Backlog and build work SHALL NOT begin until a human accepts a Demand Evidence Record containing:

| Required field | Gate condition |
|----------------|----------------|
| Real delivery story | Stable ID, outcome, and target date or release |
| Repository roster | At least two independently governed repositories with named owners |
| Existing-flow attempt | Paths or summaries for per-repo handoff/import packs already tried |
| Demonstrated insufficiency | Concrete coordination failure that separate packs cannot represent |
| Overlay benefit | Dependency, blocker, or aggregate-evidence outcome that resolves that failure |
| Data boundary | Which repo metadata may be read and which paths/URLs must remain private |
| Human sponsor | Named decision owner who accepts overlay complexity and partial-failure semantics |

No Demand Evidence Record is supplied by this backlog deepening. The gate is intentionally unmet.

The narrow future v1 is a **read-only coordination overlay** in a primary repository. It validates an explicit repo roster, renders per-repo handoff/import instructions, observes bounded status, and consolidates evidence pointers. It does not become a global source of truth, execute commands in member repos, or provide distributed transactions.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Coordinate one delivery outcome across independently governed AgToosa repositories through a read-only primary overlay, explicit per-repo handoff/import, and an aggregate evidence index. |
| User outcome | A release owner can see repo responsibilities, dependencies, blockers, and verified evidence in one place while each repository retains authority over its own story and completion state. |
| Success condition | The demand gate is satisfied before enrollment; overlay schema and local `validate`, `plan`, `status`, and `index` paths work without cross-repo mutation; every member uses its own handoff/import/evidence flow; MR-001–MR-010 pass. |
| Proof / evidence | Accepted Demand Evidence Record, multi-repo fixture results, read-only mutation guards, per-repo handoff/import pointers, aggregate evidence-index checks, partial-failure tests, and RED/GREEN blocks in `docs/AgToosa_TestPlan-DEV-057.md` after implementation. |
| Non-goals | A global Master-Plan, distributed transactions, automatic commits/merges/releases, remote command execution, repository discovery, hosted orchestration, or replacing per-repo verification. |
| Assumptions | Every member repo has an AgToosa `Master-Plan.md`, stable repo/story IDs, an owner, and a locally runnable verification flow; the primary repo can be granted read access to explicitly listed metadata. |
| Risks | Overlay state becomes stale or authoritative, private repo data leaks, paths escape the roster, partial success is misreported as global completion, dependency graphs overlap DEV-045, or users underestimate operational complexity. |
| Unresolved questions | Which real delivery story satisfies the Demand Gate; no implementation choice may resolve this by assumption. |

### 1.2 User Stories

**As a** cross-repo release owner, **I want** a primary overlay of member stories, dependencies, blockers, and evidence pointers **so that** I can assess aggregate readiness without editing child repositories.

**As a** member-repo owner, **I want** handoff and import to run inside my repository **so that** my Master-Plan, spec, tests, and evidence remain authoritative.

**As a** security-conscious maintainer, **I want** an explicit roster and read allowlist **so that** overlay status cannot crawl unrelated repositories or expose private paths and credentials.

**As an** AgToosa product owner, **I want** an evidence-backed demand gate **so that** multi-repo complexity is not built before the current per-repo workflows prove insufficient.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHILE no accepted Demand Evidence Record exists WHEN DEV-057 enrollment or build is requested THE SYSTEM SHALL keep the story Backlog, report each missing gate field, and SHALL NOT create runtime or template implementation changes. | Must |
| AC-002 | WHEN an overlay manifest is validated THE SYSTEM SHALL require a schema version, overlay ID, primary repo/story ID, sponsor, allowed metadata fields, and for every member a stable repo ID, explicit local root or sanitized remote reference, story ID, owner, role, dependencies, handoff pointer, import pointer, evidence pointer, and observed timestamp. | Must |
| AC-003 | WHEN overlay data conflicts with a member repository THE SYSTEM SHALL treat that member's `Master-Plan.md`, spec, test plan, import result, and evidence ledger as authoritative and mark the overlay observation stale or conflicted without writing to the member. | Must |
| AC-004 | WHEN `--overlay validate`, `plan`, or `status` runs THE SYSTEM SHALL read only explicitly rostered repos and allowlisted AgToosa metadata, SHALL NOT execute member-repo commands, and SHALL leave every member working tree and governance file byte-for-byte unchanged. | Must |
| AC-005 | WHEN work is delegated for a member THE SYSTEM SHALL require `/agtoosa-handoff` to run in that member repo against its local approved spec and SHALL record only the returned pack pointer and digest in the primary overlay. | Must |
| AC-006 | WHEN member work returns THE SYSTEM SHALL require `/agtoosa-import` and repo-local verification in that same member repo before its overlay row can become `verified`; a PR, branch, agent claim, or primary-repo test cannot substitute. | Must |
| AC-007 | WHEN `--overlay index` builds aggregate evidence THE SYSTEM SHALL create or update the primary story evidence index with one row per member containing repo ID, story ID, immutable artifact pointer or commit, mapped ACs, verification command, exit code, reviewer, observed timestamp, and source-ledger digest. | Must |
| AC-008 | WHEN the overlay reports dependencies, blockers, or status THE SYSTEM SHALL label them observed and non-authoritative, detect unknown/cyclic dependencies, and SHALL NOT auto-schedule work or duplicate the DEV-045 work-package executor. | Must |
| AC-009 | WHEN one member is missing, stale, blocked, or fails import THE SYSTEM SHALL preserve verified results from other members, mark aggregate readiness incomplete, list a deterministic resume/reconcile plan, and SHALL NOT claim rollback or distributed atomicity. | Must |
| AC-010 | WHEN a manifest or member path contains traversal, symlink escape, credential-bearing URL, unauthorized repo, command text, control characters, or unbounded content THE SYSTEM SHALL reject it before reading member metadata and SHALL NOT echo secret values. | Must |
| AC-011 | WHEN the Multi-Repo workflow is installed THE SYSTEM SHALL provide a canonical `Docs/AgToosa_MultiRepo.md`, versioned schema, thin platform adapters, and concise Handoff/Import/Evidence/Ship cross-links that preserve per-repo ownership. | Must |
| AC-012 | WHEN implementation begins after the Demand Gate is accepted THE SYSTEM SHALL add MR-001–MR-010 as failing contract tests before changing overlay, generator, template, adapter, or lifecycle behavior. | Must |
| AC-013 | WHEN DEV-057 is reviewed or shipped THE SYSTEM SHALL record executed per-repo and aggregate evidence in the matching test plan and SHALL NOT claim global source-of-truth status, remote execution, automatic scheduling, or distributed transaction guarantees. | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | The team builds an overlay for a hypothetical need. | Stop enrollment and report the missing Demand Evidence Record fields. |
| FM-002 | AC-002 | Two members use the same repo ID or omit ownership. | Schema validation fails; no plan/status/index is generated. |
| FM-003 | AC-003 | Primary overlay status overwrites a member's current status. | Mutation guard fails; member value remains authoritative and overlay is marked stale. |
| FM-004 | AC-004, AC-010 | A roster path traverses or follows a symlink into an unrelated repo. | Reject before metadata read and identify only the offending repo ID. |
| FM-005 | AC-005 | Primary repo generates a handoff from copied child spec content. | Refuse the pointer; require a handoff created inside the member repo. |
| FM-006 | AC-006 | PR merged is treated as verified without local import/test evidence. | Keep member unverified and print the exact member-local import requirement. |
| FM-007 | AC-007 | Aggregate index points at mutable branch names only. | Require commit/digest or immutable artifact pointer before counting the row. |
| FM-008 | AC-008 | Overlay becomes a second scheduler or work-package DAG engine. | Limit output to observed dependencies and manual plan; route executor work to DEV-045. |
| FM-009 | AC-009 | Two of three repos pass and aggregate status says complete. | Aggregate remains incomplete; retain passed evidence and list failed/missing members. |
| FM-010 | AC-013 | Documentation promises atomic rollback across repositories. | Block ship claim and state partial-failure/reconcile semantics explicitly. |

### 1.5 Out of Scope

- Building DEV-057 before an accepted real-world Demand Evidence Record exists
- A global or shared `Master-Plan.md`, global story status, or overlay-owned child task checkboxes
- Git clone/fetch/pull/push, branch creation, commits, merges, PR creation, releases, or remote command execution
- Automatic traversal or discovery of sibling directories, submodules, organizations, or remote repositories
- Distributed locking, transactions, rollback, two-phase commit, or all-or-nothing deployment
- Replacing member-repo `/agtoosa-handoff`, `/agtoosa-import`, tests, review, ship, or evidence ledgers
- Automatic work-package scheduling or a second DEV-045 DAG executor
- Cross-repo code ownership, semantic API compatibility, deployment orchestration, or environment promotion
- Hosted dashboards, databases, queues, webhooks, accounts, or secret storage
- Copying private URLs, tokens, source content, or unrestricted logs into the primary evidence index

### 1.6 Claim Boundary

| Surface or control | Classification | Boundary |
|--------------------|----------------|----------|
| Demand Gate acceptance | manual governance | Human sponsor must accept real evidence before enrollment |
| Manifest/schema/path validation and read-only mutation guard | generator-enforced after implementation | Explicitly rostered local metadata only |
| Overlay plan/status/index workflow | agent-instructed plus local validator | Coordinates pointers; does not execute child work |
| Member handoff creation | agent-instructed in member repo | Existing `/agtoosa-handoff`; manual external launch |
| Member result import and verification | agent-instructed in member repo | Existing `/agtoosa-import`; member evidence remains authoritative |
| Aggregate evidence index | agent-instructed | Primary pointer index, not a replacement ledger |
| Dependency order and resume plan | agent-instructed | Advisory; no automatic scheduler |
| CI checks inside each member repo | CI-enforced where configured | Primary overlay cannot substitute |
| Cross-repo writes, rollback, and atomic completion | roadmap / out of scope | Must not be claimed by DEV-057 |
| Each member `Master-Plan.md` | repo-local contract | Wins conflicts for that member |

## 2. Design

### 2.1 Architecture Blueprint

**Files to create:**

- `lib/overlay.sh` — manifest validation plus read-only `validate`, `plan`, `status`, and `index` operations
- `template/Docs/AgToosa_MultiRepo.md` — canonical demand gate, roster, per-repo handoff/import, reconciliation, and evidence contract
- `docs/AgToosa_MultiRepo.md` — maintainer mirror
- `template/Docs/multi-repo-overlay.schema.json` and `docs/multi-repo-overlay.schema.json` — versioned project manifest schema
- Thin `agtoosa-overlay` adapters under existing platform command/prompt/workflow directories
- `tests/fixtures/multi-repo/` — isolated coordinator and member repos covering current, stale, blocked, missing, cyclic, traversal, symlink, and partial-failure cases

**Project-owned artifacts created by the future workflow:**

- `docs/Context/multi-repo-overlay.json` in the primary repo — explicit roster and non-authoritative observations
- `docs/archived/evidence-[primary-story-id].md` — existing evidence-ledger format extended with one pointer row per member
- Handoff, import, test-plan, and evidence files remain inside each member repo

**Files to change:**

- `agtoosa.sh` — route `--overlay validate|plan|status|index` with an explicit primary path
- `agtoosa.ps1` — native Windows parity for read-only overlay operations
- `lib/config.sh` — register canonical doc, schema, and adapters
- `template/Docs/AgToosa_Handoff.md`, `AgToosa_Import.md`, `AgToosa_Evidence.md`, `AgToosa_Ship.md`, and maintainer mirrors — concise per-repo ownership and aggregate-index links
- `template/Docs/AgToosa_Agent.md`, `AgToosa_Quickref.md`, and maintainer mirrors — discoverability and demand warning
- `tests/agtoosa.bats` — MR-001–MR-010
- `docs/AgToosa_TestPlan-DEV-057.md` — executed evidence only after gate acceptance and build

**Key interfaces:**

- `overlay_validate(primary_path, manifest_path) -> diagnostics`
- `overlay_plan(manifest) -> ordered manual per-repo actions`
- `overlay_status(manifest) -> observed snapshot`
- `overlay_index(manifest, output_path) -> aggregate evidence pointers`
- `resolve_member_root(primary_root, configured_root) -> contained authorized root | reject`
- `verify_member_pointer(member, artifact, digest) -> current | stale | missing | invalid`

**Manifest model:**

- Overlay: `schema_version`, `overlay_id`, `primary`, `sponsor`, `allowed_metadata`, `members[]`
- Member: `repo_id`, `root` or sanitized `remote_ref`, `story_id`, `owner`, `role`, `depends_on[]`
- Artifact pointers: `handoff`, `import`, `evidence`, each with path/ref, digest/commit, and observed timestamp
- Observation: `status`, `blockers[]`, `observed_at`, `source_digest`; always non-authoritative

### 2.2 Data Flow

1. Before enrollment, the workflow checks the Demand Evidence Record. Missing or unaccepted evidence stops the build path.
2. After enrollment, the primary owner creates an explicit manifest in `docs/Context/multi-repo-overlay.json`.
3. The validator checks schema, duplicate IDs, authorized roots, containment, symlinks, URL safety, dependency references, cycles, and input bounds.
4. `--overlay plan` prints ordered manual actions per repo; it does not enter repos or execute commands.
5. A repo owner runs `/agtoosa-handoff` inside each member repo using that repo's local story, spec, scope, and tests.
6. The primary manifest records only the returned handoff pointer, digest, and observation time.
7. After external work returns, the member owner runs `/agtoosa-import` and local verification in that same repo.
8. The member evidence ledger records its authoritative AC/test result; the primary receives an immutable pointer or commit plus digest.
9. `--overlay status` reads only allowlisted metadata from explicit member roots and renders observed status, dependency gaps, blockers, and staleness without mutation.
10. `--overlay index` writes one aggregate pointer row per member into the primary story's evidence ledger.
11. If any member is missing, stale, blocked, or unverified, aggregate readiness remains incomplete while valid evidence from other members is preserved.
12. Re-running `plan` produces a deterministic reconcile sequence; no rollback or distributed atomicity is implied.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A malicious directory impersonates a rostered member repo. | Spoofing | Stable repo ID plus expected root/remote fingerprint and source digest; explicit sponsor-approved roster. |
| Primary overlay changes or fabricates child status/evidence. | Tampering | Member files remain authoritative; verify immutable pointer/commit and source-ledger digest. |
| Owners dispute who accepted a member result or demand gate. | Repudiation | Record sponsor, member owner, reviewer, timestamps, import pointer, and evidence digest. |
| Private paths, remote URLs, source, or logs leak into primary artifacts. | Information Disclosure | Metadata allowlist, sanitized references, secret redaction, and pointer-only evidence. |
| Missing or huge repos, cycles, or slow filesystems stall status. | Denial of Service | Bound members/file sizes, detect cycles up front, use per-member timeouts, and report partial status. |
| Manifest path or command text causes execution outside authorized repos. | Elevation of Privilege | Canonicalize roots, reject symlink/traversal escape, never execute manifest commands, and keep operations read-only except primary index output. |

### 2.4 Build Scope

**Future scope boundary — blocked until the Demand Gate is accepted**

```text
Files in scope      : `lib/overlay.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh`, Multi-Repo canonical/mirror docs and schemas, concise Handoff/Import/Evidence/Ship links, thin platform adapters, isolated multi-repo fixtures, `tests/agtoosa.bats`, this spec, and its test plan
Directories in scope: `lib/`, `template/Docs/`, `docs/`, existing platform adapter directories under `template/`, `tests/fixtures/multi-repo/`
Out of scope        : arbitrary real member-repo mutation, network/git operations, hosted state, automatic scheduling, distributed transactions, deployment orchestration, release publication
```

The accepted Demand Evidence Record may narrow this boundary. Broadening it requires a spec amendment and new cross-repo security tests.

## 3. Tasks

### 3.1 Task Tree

- [ ] **0.** Demand Gate: establish that an overlay is warranted
  - [ ] 0.1 Capture the real delivery story, repo owners, existing pack attempt, insufficiency, benefit, data boundary, and sponsor acceptance — _Requirements: AC-001_
- [ ] **1.** Contract and fixtures: lock authority and read-only behavior before implementation
  - [ ] 1.1 Add MR-001–MR-010 as RED tests after Gate 0 passes — _Requirements: AC-001–AC-013_
  - [ ] 1.2 Create isolated coordinator/member fixtures and before/after hashes — _Requirements: AC-002–AC-004, AC-009, AC-010_
- [ ] **2.** Overlay core: implement bounded validation and observation
  - [ ] 2.1 Implement schema, root containment, symlink/URL safety, and dependency validation — _Requirements: AC-002, AC-008, AC-010_
  - [ ] 2.2 Implement read-only `validate`, `plan`, and `status` with Bash/PowerShell parity — _Requirements: AC-003, AC-004, AC-008, AC-009_
  - [ ] 2.3 Implement aggregate `index` with immutable member pointers and source digests — _Requirements: AC-006, AC-007_
- [ ] **3.** Per-repo lifecycle wiring: reuse handoff/import rather than centralizing authority
  - [ ] 3.1 Create canonical Multi-Repo doc, schema, adapters, and config inventory — _Requirements: AC-001, AC-011_
  - [ ] 3.2 Add member-local Handoff and Import contracts plus primary pointer rules — _Requirements: AC-003, AC-005, AC-006_
  - [ ] 3.3 Add Evidence/Ship reconciliation and partial-failure wording — _Requirements: AC-007–AC-009, AC-013_
- [ ] **4.** Verification and evidence: prove each repo independently and the overlay only as an index
  - [ ] 4.1 Run focused mutation, security, partial-failure, and full regression checks — _Requirements: AC-012_
  - [ ] 4.2 Record per-repo RED/GREEN/IMPORT pointers, aggregate results, and claim review — _Requirements: AC-006, AC-007, AC-013_

### 3.2 Wave Plan

- **Gate 0 (sequential prerequisite):** 0.1
- **Wave 1 (parallel after Gate 0):** 1.1, 1.2, 3.1
- **Wave 2 (parallel after Wave 1):** 2.1, 3.2
- **Wave 3 (parallel after Wave 2):** 2.2, 2.3, 3.3
- **Wave 4 (sequential after Wave 3):** 4.1, 4.2

No Wave 1 work is authorized while Gate 0 remains incomplete.

### 3.3 Test Plan

- Test plan: `docs/AgToosa_TestPlan-DEV-057.md`
- AC coverage: 13 ACs mapped to 10 planned test IDs (MR-001–MR-010)
- Smoke set: 8 planned tests
- Evidence state: unexecuted backlog placeholders only; Demand Gate unmet
