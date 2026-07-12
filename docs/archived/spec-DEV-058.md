# Spec: DEV-058 — Local Dashboard

> **Story ID:** DEV-058
> **Epic:** DEV-004
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

`/agtoosa-status` already provides an agent-rendered, read-only health audit with git cross-reference, scoring, findings, and deterministic fix-command ranking. It is not a reusable static renderer, and users still open multiple files to inspect active stories, blockers, recent lifecycle events, evidence pointers, and retrospectives outside an agent session.

DEV-058 adds a deterministic local state projection, not another project-management authority. A standalone Bash script reads repo-local AgToosa artifacts and emits Markdown by default or self-contained HTML when requested. It writes only to stdout, has no accounts or network dependency, and does not reimplement the full `/agtoosa-status` health score. `docs/Master-Plan.md` remains authoritative; evidence, retro, tracker, and dashboard views are read-only projections.

The story should follow stable evidence and retro schemas, but dependency guidance does not enroll work. This story remains Backlog until Master-Plan enrollment and explicit spec approval.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Provide a dependency-light local script that renders Master-Plan state, blockers, evidence, recent events, retrospectives, and bounded next actions to stdout as Markdown or static HTML. |
| User outcome | Users can inspect important AgToosa state in one local view without opening several artifacts or creating hosted project state. |
| Success condition | The documented dashboard script supports a fixed CLI and deterministic sections, escapes HTML, degrades honestly when optional sources are absent, never writes repository files itself, and is covered by future DB-001–DB-008 checks. |
| Proof / evidence | Future RED/GREEN records in `docs/AgToosa_TestPlan-DEV-058.md`, DB-focused fixture output, before/after mutation checks, review findings, and ship evidence ledger pointers. No proof exists while this story is Backlog. |
| Non-goals | Hosted dashboard; accounts; collaboration; interactive TUI; tracker synchronization; Master-Plan mutation; full status health-score reimplementation. |
| Assumptions | Bash and standard POSIX-style text utilities are available where the existing verifier runs; source files follow documented AgToosa formats; missing optional artifacts are normal. |
| Risks | The renderer mutates or caches repo state; unsafe HTML renders source text; parsing drifts from Status; output implies that external evidence or trackers override Master-Plan. |
| Unresolved questions | None for v1: Markdown is default, `--format html` is optional, output is stdout-only, and a native interactive TUI remains roadmap. |

### 1.2 User Stories

**As a** developer, **I want** one local command to view active stories, blockers, evidence, and recent events **so that** I do not manually inspect several files.

**As a** maintainer, **I want** fixture tests to prove the renderer is stdout-only and deterministic **so that** the read-only claim stays bounded and verifiable.

**As a** security-conscious user, **I want** static HTML to escape repository-derived text and avoid remote assets **so that** opening the dashboard does not execute injected markup or contact third parties.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa-dashboard.sh` runs with no format option THE SYSTEM SHALL resolve the repo's `docs/` or `Docs/` root, read only documented source artifacts, emit a Markdown dashboard to stdout, and leave repository file content, inventory, and modification times unchanged | Must |
| AC-002 | WHEN `--format html` is selected THE SYSTEM SHALL emit one self-contained HTML document to stdout with Project Charter, Active Stories, Blocked, Evidence Index, Recent Events, Latest Retrospective, and Recommended Next Actions sections and no remote assets | Must |
| AC-003 | WHEN either format renders THE SYSTEM SHALL state that `Master-Plan.md` is the repo-local source of truth and SHALL present evidence, retrospectives, events, and external-integration references as non-authoritative projections | Must |
| AC-004 | WHEN `AgToosa_Dashboard.md` is installed THE SYSTEM SHALL document the CLI, source precedence, stdout-only contract, enforcement classes, and the distinction between dashboard state rendering and `/agtoosa-status` health analysis | Must |
| AC-005 | WHEN the selected root lacks a readable `Master-Plan.md` THE SYSTEM SHALL emit a concise stderr diagnostic, produce no partial dashboard, make no files, and exit `2` | Must |
| AC-006 | WHEN the dashboard renders either format THE SYSTEM SHALL require no Node, Python, package-manager install, account, telemetry, or network access | Must |
| AC-007 | WHEN repository-derived text is rendered as HTML THE SYSTEM SHALL escape `&`, `<`, `>`, `"`, and `'` and SHALL treat links as inert escaped text unless they are safe repo-relative pointers | Must |
| AC-008 | WHEN optional evidence, retro, or event sources are missing or contain malformed rows THE SYSTEM SHALL render an `Unavailable` or warning entry, continue with valid local data, cap rows using `--log-lines`, and order equivalent inputs deterministically | Must |

Supported v1 CLI:

```text
bash Docs/agtoosa-dashboard.sh [--root PATH] [--format markdown|html] [--log-lines N] [--help]
```

There is no `--output` or mutation flag. A user may explicitly redirect stdout outside the script; that manual shell action is not represented as a dashboard write guarantee.

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | Script creates a cache, temp file, lock, or generated artifact inside the repo. | DB-001 fails; remove the write path and retain stdout-only behavior. |
| FM-002 | AC-002, AC-006 | HTML mode depends on npm, a CDN, web font, or remote JavaScript. | Fail contract review; inline minimal CSS and use no remote assets. |
| FM-003 | AC-003 | Dashboard treats tracker, evidence, event, or retro state as authoritative. | Display the source-of-truth footer and derive lifecycle state only from Master-Plan. |
| FM-004 | AC-004 | Dashboard duplicates or contradicts the Status health-score algorithm. | Remove health scoring and cross-link `/agtoosa-status` for analysis. |
| FM-005 | AC-005 | Missing Master-Plan produces an empty but successful dashboard. | Exit `2`, stderr only, and create no output file. |
| FM-006 | AC-007 | Story title or evidence text injects HTML/script markup. | Escape all repository-derived fields before interpolation. |
| FM-007 | AC-008 | One malformed JSONL row aborts the entire renderer. | Emit a bounded warning, skip that row, and render valid sources. |
| FM-008 | AC-008 | Filesystem enumeration changes row order between runs. | Sort by documented stable keys before rendering. |

### 1.5 Out of Scope

- Hosted web application, server process, login, accounts, RBAC, or shared state
- Interactive TUI, live refresh, filesystem watcher, or background daemon
- Any write to Master-Plan, evidence, events, retro, cache, temp, or configuration files
- Full `/agtoosa-status` health score, git cross-reference, orphan detection, or fix-ranking duplication
- Tracker API calls or DEV-051 synchronization
- Telemetry, analytics, remote fonts, CDNs, or third-party JavaScript
- Native PowerShell renderer in v1; documentation must state the Bash requirement honestly
- Publishing dashboard output as a CI artifact unless a user separately configures CI
- Version/release work before normal story enrollment and ship

### 1.6 Claim Boundary

| Control | Classification | Honest boundary |
|---------|----------------|-----------------|
| Dashboard doc and Bash script installed by AgToosa | generator-enforced | Generator installs known files; it does not run or publish the dashboard. |
| Script's stdout-only implementation path | generator-enforced | The shipped script contains no repo write path; this is not an OS sandbox. |
| Read-only, escaping, and deterministic fixture checks | CI-enforced | Applies when project/release CI runs DB checks. |
| User invocation and optional shell redirection | manual | The user decides when and where to run or redirect output. |
| Dashboard-derived next-action subset | generator-enforced | Deterministic script logic, limited to the documented local-state subset. |
| `/agtoosa-status` health interpretation | agent-instructed | Status remains the richer agent workflow and is not replaced. |
| CI publication of static HTML | CI-enforced | Optional user-owned workflow, absent by default. |
| Hosted, collaborative, or interactive dashboard | roadmap | Not provided by this story. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `template/Docs/agtoosa-dashboard.sh` — installed stdout-only Markdown/HTML renderer
- `docs/agtoosa-dashboard.sh` — maintainer-dogfood mirror
- `template/Docs/AgToosa_Dashboard.md` — CLI, data sources, rendering rules, status relationship, and claim boundary
- `docs/AgToosa_Dashboard.md` — maintainer mirror
- `tests/fixtures/dashboard-repo/` — synthetic Master-Plan, evidence, retro, event, malformed-row, and injection cases

Files to change:

- `template/Docs/AgToosa_Status.md` and `docs/AgToosa_Status.md` — cross-link the renderer without moving health logic
- `template/Docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Quickref.md`, and matching `docs/` mirrors — document the local script invocation
- `lib/config.sh` — install the dashboard doc and script
- `tests/agtoosa.bats` — DB-001–DB-008 behavior and contract checks
- `docs/AgToosa_TestPlan-DEV-058.md` — future TDD and validation evidence

Key interfaces:

- `render_markdown(root, log_lines) -> stdout`
- `render_html(root, log_lines) -> stdout`
- `escape_html(value) -> escaped text`
- `read_master_plan(root) -> required structured rows or exit 2`
- `read_optional_sources(root, log_lines) -> rows plus bounded warnings`

The renderer parses only the fields listed in the contract. It does not expose a general Markdown-to-HTML engine and does not execute source content.

### 2.2 Data Flow

1. The script parses arguments, validates `--log-lines` as a bounded positive integer, and resolves an explicit root or the current repository root.
2. It selects lowercase `docs/` in maintainer mode or uppercase `Docs/` in generated-project mode and requires a readable `Master-Plan.md`.
3. It parses Project Charter, Active Cycle, Blocked, and the bounded Update Log fields needed for rendering.
4. It inventories repo-relative `archived/evidence-*.md` and the latest `archived/retro-*.md`, then reads up to the requested count of valid local event rows.
5. It derives a documented minimal next-action subset from Master-Plan state only; it does not compute the Status health score.
6. It normalizes and sorts rows by stable keys. Missing optional sources and malformed rows become bounded warnings.
7. Markdown mode formats normalized fields directly; HTML mode escapes every repository-derived field and uses inline static CSS.
8. The selected renderer writes the complete document to stdout. Diagnostics go to stderr. No repository file is opened for writing.
9. The output footer identifies the selected Master-Plan as source of truth and links users to `/agtoosa-status` for health analysis.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A nested directory impersonates the repository root | Spoofing | Resolve one explicit/canonical root and report the selected Master-Plan path. |
| Dashboard or source text changes repository state | Tampering | Read-only file descriptors, stdout-only output, and before/after content/inventory/mtime checks. |
| A dashboard snapshot is presented as current authoritative state | Repudiation | Include generation timestamp, selected source path, and non-authoritative projection footer. |
| HTML or errors expose secret-like source content | Information Disclosure | Render allowlisted fields, escape HTML, omit environment variables and raw logs, use bounded warnings. |
| Large plans, evidence sets, or JSONL files exhaust resources | Denial of Service | Bound recent rows, avoid recursive content rendering, and cap `--log-lines`. |
| External tracker or evidence state overrides lifecycle status | Elevation of Privilege | Derive status only from Master-Plan and label all other sources as projections. |

### 2.4 Build Scope

Proposed future scope; `/agtoosa-spec` must revalidate it against the enrolled cycle before implementation.

```text
✅ Ready to proceed — Scope Boundary
Files in scope      : template/Docs/agtoosa-dashboard.sh, docs/agtoosa-dashboard.sh, template/Docs/AgToosa_Dashboard.md, docs/AgToosa_Dashboard.md, template and maintainer mirrors for Status/Agent/Quickref, lib/config.sh, dashboard fixtures, tests/agtoosa.bats, docs/AgToosa_TestPlan-DEV-058.md
Directories in scope: template/Docs/, docs/, tests/fixtures/dashboard-repo/, tests/, lib/
Out of scope        : hosted/TUI surfaces, PowerShell renderer, status health-score changes, tracker APIs, repository writes, CI publication, version/release work before ship
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1. Contract-first dashboard fixture and tests:** establish read-only and output behavior
  - [ ] 1.1 Add complete, missing-optional, malformed-row, and injection fixture inputs — _Requirements: AC-001, AC-005, AC-007, AC-008_
  - [ ] 1.2 Add failing DB-001, DB-002, DB-005, DB-007, and DB-008 checks and record RED evidence — _Requirements: AC-001, AC-002, AC-005, AC-007, AC-008_
- [ ] **2. Dashboard contract documentation:** define sources, CLI, and honest boundaries
  - [ ] 2.1 Create Dashboard canonical doc and maintainer mirror — _Requirements: AC-003, AC-004, AC-006_
  - [ ] 2.2 Define the minimal next-action subset and Status non-duplication rule — _Requirements: AC-003, AC-004_
- [ ] **3. Markdown renderer:** implement required local state projection first
  - [ ] 3.1 Implement root resolution, required Master-Plan parsing, deterministic sorting, and error exits — _Requirements: AC-001, AC-005, AC-006_
  - [ ] 3.2 Implement optional evidence, retro, and event parsing with row caps and warnings — _Requirements: AC-001, AC-008_
  - [ ] 3.3 Implement Markdown sections, authority footer, and next-action subset — _Requirements: AC-001, AC-003_
- [ ] **4. Static HTML renderer:** add safe alternate output over the same normalized data
  - [ ] 4.1 Implement HTML escaping and self-contained sections with inline CSS — _Requirements: AC-002, AC-007_
  - [ ] 4.2 Prove no remote assets, network calls, or runtime package dependencies — _Requirements: AC-002, AC-006_
- [ ] **5. Installation and discovery wiring:** ship the renderer without a new adapter family
  - [ ] 5.1 Register doc/script in `lib/config.sh` and cross-link Status, Agent, and Quickref — _Requirements: AC-004, AC-006_
  - [ ] 5.2 Add DB-003, DB-004, and DB-006 contract checks — _Requirements: AC-003, AC-004, AC-006_
- [ ] **6. Complete future verification:** close the TDD loop and preserve the read-only claim
  - [ ] 6.1 Run DB-001–DB-008 and focused regression commands, then record GREEN evidence — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008_
  - [ ] 6.2 Review before/after fixture state, HTML escaping, deterministic output, and authority labels — _Requirements: AC-001, AC-003, AC-007, AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2
**Wave 2 (sequential after Wave 1):** 1.2, 3.1
**Wave 3 (parallel after Wave 2):** 3.2, 3.3
**Wave 4 (parallel after Wave 3):** 4.1, 4.2, 5.1
**Wave 5 (parallel after Wave 4):** 5.2, 6.2
**Wave 6 (sequential after Wave 5):** 6.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-058.md`
AC coverage: 8 of 8 ACs mapped to DB-001–DB-008
Must coverage: 8 of 8 Must ACs mapped
Smoke set: 8 planned tests tagged `@smoke`
Execution state: not run; this story is Backlog

## ✅ Spec Approved

Approved: 2026-07-11 22:00
Enrollment: remaining-specs fan-out wave 4 (post v5.3.11)
