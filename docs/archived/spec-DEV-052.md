# Spec: DEV-052 — Hook Automation Pack

> **Story ID:** DEV-052
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ⬜ Backlog
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Prerequisite gate:** DEV-059 must ship before DEV-052 enrollment

## Context

AgToosa currently ships Claude Code `Stop`, `PreToolUse`, and `PostToolUse` entries in `template/.claude/settings.json`, plus `block-dangerous-git.sh`. The installer/update path deep-merges those entries by command string. That is a Claude-specific baseline, not a portable lifecycle-hook contract: task start, test completion, secret checks, and ship gates have no shared event catalog, opt-in preview rule, logging boundary, policy linkage, or cross-platform fallback.

DEV-052 defines that optional contract and packages the existing safe guardrail as an exemplar. DEV-059 must ship first because it owns policy rule IDs, enforcement classes, and `on_violation`; hooks may consume that policy but must not invent stronger controls. The v1 pack documents native support and agent-instructed fallbacks honestly. It does not claim that all hosts expose hook APIs, and absence of the pack cannot make a project unhealthy.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a Hook Automation Pack contract with supported lifecycle events, safe command/script mappings, opt-in preview and approval, secret-safe output, DEV-059 policy linkage, and explicit platform fallbacks. |
| User outcome | Teams can reuse transparent workflow checks without silently overwriting user hooks or assuming every agent host provides native interception. |
| Success condition | `AgToosa_Hooks.md` catalogs events and enforcement; Init/Update define approval plus preview; Build/Ship reference relevant events; existing Claude merge behavior remains deduplicating; `HK-001`–`HK-007` pass; hook absence remains healthy. |
| Proof / evidence | Future RED/GREEN records in `docs/AgToosa_TestPlan-DEV-052.md`, approval/preview fixture output, safe-log assertions, merge-dedup fixtures, and focused bats output. |
| Non-goals | Silent hook installation, mandatory hooks, dynamic universal hook registration, new host APIs, hosted webhook ingestion, or changes to DEV-055. |
| Assumptions | DEV-059 ships the repo-local policy and checker first; Claude remains the only currently proven native hook host; other hosts can use the same checklist events without native interception. |
| Risks | Hook output leaks tool input; broad patterns block legitimate commands; update duplicates user settings; documentation implies host-level enforcement AgToosa does not provide. |
| Unresolved questions | None for v1. Cursor-native hooks remain roadmap unless a stable supported API is verified during a separately approved amendment. |

### 1.2 User Stories

**As a** security-conscious maintainer, **I want** a reviewed pre-tool-use guardrail tied to explicit policy rules **so that** dangerous actions are warned or blocked only at the enforcement level the host actually supports.

**As an** AgToosa user on a host without native hooks, **I want** the same lifecycle events represented as a checklist **so that** I can perform the checks without false automation claims.

**As a** repository owner with existing Claude settings, **I want** a file preview and explicit approval before hook changes **so that** my commands are preserved and AgToosa entries are not duplicated.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `Docs/AgToosa_Hooks.md` is read THE SYSTEM SHALL catalog `task-start`, `pre-tool-use`, `post-tool-use`, `pre-test`, `post-test`, `pre-ship`, and `secret-check` with purpose, native/checklist availability, example command or script path, failure behavior, and enforcement class | Must |
| AC-002 | WHEN the Hook Automation Pack is offered for installation THE SYSTEM SHALL show the affected files and merge intent, require explicit user approval before any write, preserve unrelated user settings, and provide a documented removal path | Must |
| AC-003 | WHEN a hook or fallback command emits diagnostics THE SYSTEM SHALL prohibit secret values, tokens, private URLs, environment dumps, and raw tool-input payloads in output, limiting diagnostics to event name, policy rule ID, command name, path, and redacted reason | Must |
| AC-004 | WHEN DEV-059 policy is configured THE SYSTEM SHALL resolve it through `agtoosa-policy-check.sh`, map applicable rule IDs and `on_violation` values to hook behavior, and refuse to upgrade `warn` or `instruct_stop` into an undocumented host-level block | Must |
| AC-005 | WHEN a selected platform lacks a proven native event THE SYSTEM SHALL label that event unavailable natively and provide the equivalent agent-instructed checklist step without claiming automatic execution | Must |
| AC-006 | WHEN no optional Hook Automation Pack is installed THE SYSTEM SHALL keep `/agtoosa-status` health unchanged and SHALL NOT make `agtoosa-verify.sh` fail or warn solely because hooks are absent | Must |
| AC-007 | WHEN `agtoosa.sh --update` merges existing Claude settings THE SYSTEM SHALL preserve unrelated settings and deduplicate AgToosa hook entries by command string, retaining the established `merge_settings_json` behavior | Must |
| AC-008 | WHEN `tests/agtoosa.bats` runs DEV-052 coverage THE SYSTEM SHALL assert dual-path Hooks documentation, event and platform matrices, preview/approval/removal language, secret-safe diagnostics, DEV-059 linkage, optional-health behavior, existing hook-script parity, and settings-merge deduplication | Must |

### 1.4 Failure Modes

| AC | Failure mode |
|----|--------------|
| AC-001 | Event names or failure semantics differ between workflow docs, so users cannot predict which check runs. |
| AC-002 | An install/update path writes settings without a preview or duplicates/overwrites an existing user command. |
| AC-003 | Raw tool input or environment values appear in hook output and expose a credential. |
| AC-004 | A hook treats an advisory policy rule as a guaranteed runtime block or logs the policy's suspected secret value. |
| AC-005 | Cursor, Gemini, Windsurf, or another host is presented as natively hooked without a proven event API. |
| AC-006 | Optional-hook absence lowers health or creates verifier findings, making the pack effectively mandatory. |
| AC-007 | Repeated updates append identical commands, causing duplicate prompts or repeated side effects. |
| AC-008 | Existing Claude settings/scripts and the new portable catalog drift without a focused regression failure. |

### 1.5 Out of Scope

- Any edit to DEV-055 specs, evidence, AM tests, or either `AgToosa_AgentCapability.md` copy
- Defining or changing the DEV-059 policy schema/checker; DEV-052 consumes its shipped interface
- Installing executable hooks from registry packs; sensitive destinations remain denied
- CI workflow generation, hosted hook dispatch, telemetry ingestion, or remote event delivery
- Native event APIs not proven by the selected host
- Treating optional-hook absence as a status, verifier, or ship failure
- Version bumps and release publication before normal ship enrollment

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Installing the Hooks guide through generator inventory | generator-enforced |
| Existing Claude settings/script files copied for a user-selected Claude install | generator-enforced for file installation only; host execution is not an AgToosa guarantee |
| Hook contract and merge-dedup checks when run in CI | CI-enforced |
| Event selection, fallback checklists, policy consultation, and preview preparation | agent-instructed |
| Approval, settings changes, removals, and acceptance of blocking behavior | manual |
| Universal native hooks or host-independent runtime interception | roadmap |

Until DEV-052 ships with recorded GREEN evidence, the portable Hook Automation Pack remains roadmap. DEV-059 policy and `docs/Master-Plan.md` remain authoritative; hook output cannot mutate lifecycle state by itself.

## 2. Design

### 2.1 Architecture Blueprint

Files to create during the future build:

- `template/Docs/AgToosa_Hooks.md` — canonical event catalog, platform matrix, install/removal contract, policy linkage, and safe-output rules
- `docs/AgToosa_Hooks.md` — maintainer mirror with lowercase `docs/` paths

Files to change during the future build:

- `template/Docs/AgToosa_Init.md`, `docs/AgToosa_Init.md` — optional pack offer, preview, approval, and phase stop
- `template/Docs/AgToosa_Update.md`, `docs/AgToosa_Update.md` — merge preview, approval, preservation, deduplication, and removal guidance
- `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md` — task/pre-test/post-test event pointers
- `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md` — pre-ship and secret-check pointers
- `lib/config.sh` — register `Docs/AgToosa_Hooks.md`
- `template/.claude/settings.json` — remain the native-event mapping source; change only if needed to satisfy the approved safe-output contract
- `template/.claude/hooks/block-dangerous-git.sh` — remain the pre-tool-use exemplar; change only if a RED secret-safety assertion proves it necessary
- `tests/agtoosa.bats` — add `HK-001`–`HK-007`, including merge-dedup fixtures for existing `merge_settings_json`
- `docs/AgToosa_TestPlan-DEV-052.md` — capture future automated and preview evidence

Key interfaces:

- `HookEvent`: `{ event, purpose, availability, command_or_script, failure_behavior, enforcement_class }`
- `HookInstallPreview`: `{ affected_files, existing_entries_preserved, entries_added, entries_deduplicated, removal_steps }`
- DEV-059 checker: `bash Docs/agtoosa-policy-check.sh [--root PATH] [--policy PATH]`
- Policy result consumed by hooks: `{ policy_path, rule_id, enforcement_class, on_violation }`, with no secret values

Existing platform adapters continue routing to canonical Init/Update/Build/Ship docs. The Hooks guide owns the fallback matrix; adapters do not duplicate it.

### 2.2 Data Flow

1. Init or Update detects the selected platform and reads the Hooks event matrix.
2. The workflow prepares a preview listing affected settings/doc/script paths, preserved entries, additions, and deduplicated entries.
3. The user approves or declines; declining makes no write and does not affect health.
4. On approval, the existing Claude merge path preserves unrelated settings and deduplicates by command; non-native platforms retain checklist mappings only.
5. At an applicable event, the hook/checklist resolves DEV-059 policy locally and records only event name, rule ID, command/path, and redacted reason.
6. The event follows the documented `warn`, `instruct_stop`, or specifically proven generator/host behavior without broadening the enforcement claim.
7. Status and verifier ignore pack absence; lifecycle changes still flow through ordinary AgToosa commands and `docs/Master-Plan.md`.
8. Removal follows the previewed command/entry list and preserves unrelated user settings.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A fallback is represented as a native hook | Spoofing | Per-event platform availability and enforcement columns; unknown support defaults to checklist-only. |
| Hook entries or policy mappings are changed without review | Tampering | Preview, explicit approval, Git-visible files, and dedup contract fixtures. |
| A user cannot determine which check ran | Repudiation | Emit event name and policy rule ID while retaining bounded Terminal Evidence. |
| Tool input, environment, or policy content leaks | Information Disclosure | Never echo raw payloads; allow only bounded metadata and redacted reasons. |
| A broad or duplicated hook blocks normal work | Denial of Service | Narrow event mapping, documented removal, preserved settings, and command-string deduplication. |
| Advisory policy is promoted to a host-level block | Elevation of Privilege | Consume DEV-059 enforcement/on-violation values exactly and reject stronger claims. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope      : `template/Docs/AgToosa_Hooks.md`, `docs/AgToosa_Hooks.md`, `template/Docs/AgToosa_Init.md`, `docs/AgToosa_Init.md`, `template/Docs/AgToosa_Update.md`, `docs/AgToosa_Update.md`, `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md`, `template/Docs/AgToosa_Ship.md`, `docs/AgToosa_Ship.md`, `lib/config.sh`, `template/.claude/settings.json`, `template/.claude/hooks/block-dangerous-git.sh`, `tests/agtoosa.bats`, `docs/archived/spec-DEV-052.md`, `docs/AgToosa_TestPlan-DEV-052.md`

Directories in scope: none beyond the listed files

Out of scope        : DEV-055 files and AM tests, DEV-059 schema/checker changes, registry destinations, CI workflow generation, platform adapter bodies, new native host APIs, release/version files

The future build may begin only after DEV-059 is shipped. Any hook-script or settings change requires a failing safety/behavior assertion first; documentation alone is not evidence that a host executes the event.

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Contract and RED coverage
  - [ ] 1.1 Add failing `HK-001`–`HK-007` assertions and safe merge fixtures before implementation — _Requirements: AC-008_
  - [ ] 1.2 Create both Hooks guide copies with the event matrix, Claim Boundary, secret-safe output, optional-health, and removal contracts — _Requirements: AC-001, AC-003, AC-005, AC-006_
- [ ] **2.** Lifecycle and policy wiring
  - [ ] 2.1 Add Init/Update preview, explicit approval, preservation, deduplication, decline, and removal behavior — _Requirements: AC-002, AC-007_
  - [ ] 2.2 Link the shipped DEV-059 resolver and exact enforcement/on-violation semantics without changing its schema — _Requirements: AC-004_
  - [ ] 2.3 Add Build/Ship event pointers and checklist fallbacks for every event without duplicating the matrix — _Requirements: AC-001, AC-005, AC-006_
- [ ] **3.** Installation and proof
  - [ ] 3.1 Register the guide and lock existing Claude settings/script parity plus secret-safe output — _Requirements: AC-003, AC-007, AC-008_
  - [ ] 3.2 Run future GREEN validation, capture an approved and declined preview fixture, and replace every evidence placeholder — _Requirements: AC-002, AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2

**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3

**Wave 3 (sequential after Wave 2):** 3.1

**Wave 4 (sequential after Wave 3):** 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-052.md`

AC coverage: 8 ACs mapped to 7 test IDs (`HK-001`–`HK-007`)

Smoke set: 5 tests tagged `@smoke` (`HK-001`, `HK-002`, `HK-003`, `HK-006`, `HK-007`)
