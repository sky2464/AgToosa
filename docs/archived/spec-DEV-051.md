# Spec: DEV-051 — Tracker Sync Bridge

> **Story ID:** DEV-051
> **Epic:** DEV-003
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa deliberately keeps `docs/Master-Plan.md` as the repo-local project-management source of truth. Teams may still need GitHub Issues, Linear, Jira, or TaskMaster for organization-wide visibility, but direct bidirectional synchronization would introduce provider credentials, conflict semantics, and silent-overwrite risks that do not belong in a first release.

DEV-051 therefore defines a narrow v1 bridge:

1. **One-way export** from `Master-Plan.md` and its referenced specs into a provider-neutral JSON envelope.
2. **Proposal import** from a provider-neutral return envelope into a human-readable proposal artifact.
3. **No automatic apply.** Accepted changes re-enter AgToosa through `/agtoosa-task`, `/agtoosa-spec amend`, or an explicit human edit; `Master-Plan.md` wins every conflict.

The bridge does not call provider APIs in v1. Provider adapters, MCP tools, or humans may transport the envelopes, but they are integrations rather than authorities. This document remains a backlog contract until the story is explicitly enrolled; none of the described runtime surfaces exist merely because this spec exists.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Provide a deterministic, provider-neutral Tracker Sync Bridge that exports AgToosa story state and turns returned tracker changes into reviewable proposals without surrendering `Master-Plan.md` authority. |
| User outcome | Teams can mirror AgToosa work into GitHub Issues, Linear, Jira, or TaskMaster and bring suggested changes back for review without silent repo-state mutation. |
| Success condition | The v1 export and proposal schemas, local CLI paths, conflict rules, provider mappings, and approval route are implemented; TS-001–TS-008 pass; no import path writes `Master-Plan.md`. |
| Proof / evidence | Focused bats output for TS-001–TS-008, fixture export/proposal artifacts, mutation-guard assertions, schema validation, and RED/GREEN blocks recorded in `docs/AgToosa_TestPlan-DEV-051.md` after implementation. |
| Non-goals | Live provider API clients, OAuth/token storage, webhooks, polling, automatic two-way synchronization, or making any external tracker authoritative. |
| Assumptions | Story IDs are stable; `Master-Plan.md` and referenced spec files are readable; provider adapters can map the neutral envelope outside the core bridge; SHA-256 is available for source snapshots. |
| Risks | Field-loss across providers, stale proposals, accidental secret export, misleading “sync” claims, nondeterministic Markdown parsing, and adapters treating external status as canonical. |
| Unresolved questions | Which provider adapter should be validated first is deferred until enrollment; it does not change the provider-neutral v1 contract. |

### 1.2 User Stories

**As a** delivery lead, **I want** to export AgToosa stories into a neutral artifact **so that** existing tracker users can see current work without editing repo governance files.

**As an** AgToosa maintainer, **I want** returned tracker changes rendered as proposals **so that** I can accept, reject, or amend each suggestion before repo state changes.

**As a** platform integrator, **I want** documented mappings for GitHub Issues, Linear, Jira, and TaskMaster **so that** an adapter can translate fields without inventing source-of-truth semantics.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `--tracker export` reads a valid project THE SYSTEM SHALL emit an `agtoosa.tracker-bridge/v1` JSON envelope containing a stable export ID, source commit when available, `Master-Plan.md` SHA-256, and normalized story ID, title, epic, status, estimate, spec path, and acceptance-criteria references. | Must |
| AC-002 | WHEN identical repo state is exported more than once THE SYSTEM SHALL produce the same normalized story payload and export ID, excluding explicitly volatile metadata such as `generated_at`. | Must |
| AC-003 | WHEN `--tracker propose` receives a valid return envelope THE SYSTEM SHALL validate its schema and write a proposal artifact that shows each external value beside the current repo value, without modifying `docs/Master-Plan.md`, a spec, or task checkbox. | Must |
| AC-004 | WHEN a return envelope has an unknown story ID, unsupported field, missing base export ID, or a base digest that differs from current `Master-Plan.md` THE SYSTEM SHALL mark the item `rejected` or `stale`, explain why, and SHALL NOT apply it. | Must |
| AC-005 | WHEN repo and tracker values conflict THE SYSTEM SHALL label the repo value authoritative, preserve it unchanged, and route any accepted proposal through `/agtoosa-task`, `/agtoosa-spec amend`, or explicit human authorization before a new export. | Must |
| AC-006 | WHEN the bridge documents GitHub Issues, Linear, Jira, or TaskMaster THE SYSTEM SHALL define field mappings and unsupported-field behavior without claiming that AgToosa performs network transport or provider-side enforcement. | Must |
| AC-007 | WHEN export or proposal input contains credentials, private URLs with embedded credentials, absolute local paths, control characters, or unrecognized keys THE SYSTEM SHALL redact or reject the unsafe value and report the affected field without echoing secret material. | Must |
| AC-008 | WHEN the Tracker Sync workflow is installed THE SYSTEM SHALL expose the same `export` and `propose` contract through the canonical doc and thin platform adapters, while delegating all substantive rules to `Docs/AgToosa_TrackerSync.md`. | Must |
| AC-009 | WHEN enforcement is described THE SYSTEM SHALL classify local schema validation and mutation refusal as generator-enforced, workflow routing as agent-instructed, provider transport and proposal acceptance as manual or provider-enforced, and automatic bidirectional sync as roadmap. | Must |
| AC-010 | WHEN implementation begins THE SYSTEM SHALL add TS-001–TS-008 as failing contract tests before changing bridge behavior, including a byte-for-byte assertion that proposal import leaves `Master-Plan.md` unchanged. | Must |
| AC-011 | WHEN DEV-051 is reviewed or shipped THE SYSTEM SHALL record executed evidence in the matching test plan and SHALL NOT claim live provider synchronization, webhook delivery, or external-tracker authority. | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001, AC-002 | Export order or volatile timestamps change the export ID. | Sort normalized records and exclude volatile fields from the digest. |
| FM-002 | AC-003, AC-005 | Proposal import edits `Master-Plan.md` directly. | Fail the mutation-guard test; restore the file; emit proposal-only output. |
| FM-003 | AC-004 | A stale tracker return overwrites a newer repo status. | Mark the item stale and require a fresh export. |
| FM-004 | AC-006 | A provider adapter silently drops an unsupported status or estimate. | Preserve the original value in `unmapped`, warn, and leave repo state unchanged. |
| FM-005 | AC-007 | Export includes a token-bearing URL or workstation path. | Redact the value, identify only the field, and return a nonzero validation result for unsafe required data. |
| FM-006 | AC-008 | Platform adapters duplicate divergent conflict rules. | Keep adapters thin and test that each points to the canonical workflow. |
| FM-007 | AC-009, AC-011 | Documentation calls the bridge “two-way sync” or implies API delivery. | Block ship claims until wording is narrowed to export plus proposal import. |
| FM-008 | AC-010 | Tests verify artifact creation but not source immutability. | Require before/after hashes for `Master-Plan.md` and referenced specs. |

### 1.5 Out of Scope

- OAuth, API tokens, provider SDKs, MCP authentication, webhooks, polling, and hosted relay services
- Automatic create/update/delete operations in GitHub Issues, Linear, Jira, or TaskMaster
- Automatic application of returned status, estimate, title, owner, label, or comment changes
- Cross-repository synchronization; DEV-057 owns multi-repo coordination
- Provider-specific custom-field administration or workflow configuration
- Comment, attachment, sprint, cycle, board, or dependency round-trip
- CI enforcement that tracker state is fresh or identical to repo state
- Treating tracker IDs, tracker status, or adapter caches as project-management source of truth

### 1.6 Claim Boundary

| Surface or control | Classification | Boundary |
|--------------------|----------------|----------|
| Neutral schema validation, normalized digest, and source-file mutation refusal | generator-enforced after implementation | Local files only; no provider API guarantee |
| `/agtoosa-tracker export` and `propose` workflow decisions | agent-instructed | Canonical doc controls behavior; adapters delegate |
| Provider field mapping examples | agent-instructed | Translation guidance, not proof of provider compatibility |
| Transporting an envelope to or from a tracker | manual / provider-enforced | Performed by a human, provider tool, or separately authorized integration |
| Accepting a proposal | manual authorization | Acceptance routes through existing AgToosa change workflows |
| Tracker freshness CI gate | roadmap | Not part of v1 |
| Automatic bidirectional synchronization | roadmap | Must not be claimed by DEV-051 |
| `docs/Master-Plan.md` authority | repo-local contract | It wins every tracker conflict |

## 2. Design

### 2.1 Architecture Blueprint

**Files to create:**

- `lib/tracker.sh` — provider-neutral export normalization, digesting, return-envelope validation, and proposal rendering
- `template/Docs/AgToosa_TrackerSync.md` — canonical `/agtoosa-tracker export|propose` workflow and provider mapping contract
- `docs/AgToosa_TrackerSync.md` — maintainer mirror
- `template/Docs/agtoosa-tracker-sync.schema.json` and `docs/agtoosa-tracker-sync.schema.json` — versioned export/return schema
- Thin `agtoosa-tracker` platform adapters under the existing Claude, Cursor, Gemini, Copilot, Windsurf, and Codex/OpenCode template surfaces
- `tests/fixtures/tracker-sync/` — deterministic project, provider return, stale digest, unmapped field, and secret-redaction fixtures

**Files to change:**

- `agtoosa.sh` — route `--tracker export|propose` and common `--path`, `--input`, and `--output` arguments
- `agtoosa.ps1` — native Windows parity for the same local-only contract
- `lib/config.sh` — register canonical docs, schema, and thin adapters
- `template/Docs/AgToosa_Agent.md`, `AgToosa_Quickref.md`, and maintainer mirrors — discoverability and claim boundary
- `tests/agtoosa.bats` — TS-001–TS-008
- `docs/AgToosa_TestPlan-DEV-051.md` — executed evidence only after build begins

**Key interfaces:**

- `tracker_export(project_path, output_path) -> export envelope`
- `tracker_propose(project_path, input_path, output_path) -> proposal artifact`
- `normalize_story(master_plan_row, spec_path) -> normalized story`
- `source_digest(normalized_payload) -> sha256`
- `validate_tracker_envelope(input) -> valid | rejected(reason)`

**Envelope contract:**

- Export: `schema_version`, `export_id`, `generated_at`, `repository`, `source`, `stories[]`
- Return: `schema_version`, `base_export_id`, `provider`, `changes[]`
- Change: `story_id`, `field`, `proposed_value`, `external_ref`, `observed_at`, `rationale`
- Proposal result per change: `proposed`, `unchanged`, `stale`, `unsupported`, or `rejected`

### 2.2 Data Flow

1. The user runs the local export command against an explicit project path.
2. The bridge reads `docs/Master-Plan.md` and only the spec paths referenced by exported stories.
3. Story records are normalized and sorted by stable story ID.
4. The bridge computes `master_plan_sha256` and an export ID over the nonvolatile normalized payload.
5. The JSON envelope is written to the explicit output path; no network call occurs.
6. A human or separately authorized provider adapter translates and transports the envelope.
7. Returned suggestions arrive in the neutral return schema with the base export ID.
8. The proposal command validates schema, story IDs, allowed fields, secret safety, and current source digest.
9. The bridge writes a Markdown proposal showing current and proposed values plus `proposed`, `stale`, `unsupported`, or `rejected` disposition.
10. The user accepts desired changes through `/agtoosa-task`, `/agtoosa-spec amend`, or an explicitly authorized edit.
11. A fresh one-way export becomes the next tracker snapshot; external state never overwrites the repo implicitly.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A forged adapter claims a return came from a trusted provider. | Spoofing | Treat every return as untrusted input; provider identity is descriptive only in v1. |
| A stale return changes current story state. | Tampering | Compare base export ID and current `Master-Plan.md` digest; proposal only, never apply. |
| A user cannot determine who accepted a proposed change. | Repudiation | Proposal records external reference and rationale; actual change uses existing spec/task revision history. |
| Export leaks tokens, credential-bearing URLs, or local absolute paths. | Information Disclosure | Allowlist fields, redact unsafe values, reject unknown sensitive structures, and never serialize environment variables. |
| A huge or deeply nested return envelope exhausts parser resources. | Denial of Service | Bound file size, record count, key count, and nesting depth before parsing. |
| A malicious field injects workflow instructions or file paths. | Elevation of Privilege | Treat values as escaped data, restrict output to an explicit path, and prohibit proposal-time source mutation. |

### 2.4 Build Scope

**Future scope boundary — enrollment required before implementation**

```text
Files in scope      : `lib/tracker.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh`, canonical/mirror Tracker Sync docs and schemas, thin platform adapters, tracker fixtures, `tests/agtoosa.bats`, this spec, and its test plan
Directories in scope: `lib/`, `template/Docs/`, `docs/`, existing platform adapter directories under `template/`, `tests/fixtures/tracker-sync/`
Out of scope        : provider credentials or clients, hosted services, external registry repos, automatic proposal apply, DEV-057 multi-repo behavior, release/version publication
```

No build task may broaden this boundary to live provider writes without a spec amendment and new threat-model/test coverage.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and fixtures: lock v1 semantics before runtime changes
  - [ ] 1.1 Add TS-001–TS-008 as RED tests with deterministic project and provider fixtures — _Requirements: AC-001–AC-010_
  - [ ] 1.2 Add before/after source hashes and unsafe-input fixtures — _Requirements: AC-003, AC-004, AC-007, AC-010_
- [ ] **2.** Neutral bridge core: implement local export and proposal rendering
  - [ ] 2.1 Implement normalized export schema, ordering, and digest — _Requirements: AC-001, AC-002_
  - [ ] 2.2 Implement return validation, stale detection, and proposal-only output — _Requirements: AC-003–AC-005, AC-007_
  - [ ] 2.3 Wire Bash and PowerShell command parity without network access — _Requirements: AC-001, AC-003, AC-009_
- [ ] **3.** Canonical workflow and adapters: document transport and authority boundaries
  - [ ] 3.1 Create Tracker Sync canonical doc, schema, and four provider mappings — _Requirements: AC-006, AC-008, AC-009_
  - [ ] 3.2 Add thin platform adapters and config inventory entries — _Requirements: AC-008_
  - [ ] 3.3 Add Quickref/Agent discoverability and explicit proposal-acceptance route — _Requirements: AC-005, AC-009_
- [ ] **4.** Verification and evidence: prove only the implemented v1 claim
  - [ ] 4.1 Run focused and full regression commands after GREEN implementation — _Requirements: AC-010_
  - [ ] 4.2 Record RED/GREEN output and claim-boundary review in the test plan — _Requirements: AC-011_

### 3.2 Wave Plan

- **Wave 1 (parallel):** 1.1, 1.2, 3.1
- **Wave 2 (parallel after Wave 1):** 2.1, 2.2, 3.2
- **Wave 3 (parallel after Wave 2):** 2.3, 3.3
- **Wave 4 (sequential after Wave 3):** 4.1, 4.2

### 3.3 Test Plan

- Test plan: `docs/AgToosa_TestPlan-DEV-051.md`
- AC coverage: 11 ACs mapped to 8 planned test IDs (TS-001–TS-008)
- Smoke set: 6 planned tests
- Evidence state: unexecuted backlog placeholders only
