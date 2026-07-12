# Spec: DEV-088 — Feature: Verifier and Doctor Machine Output

> **Story ID:** DEV-088
> **Type:** Feature
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟦 Todo
> **Estimate:** M
> **Priority:** P0
> **Spec created:** 2026-07-12
> **Extends:** DEV-061, DEV-062, DEV-073, DEV-079

## Context

DEV-061 shipped the deterministic lifecycle verifier; DEV-062 shipped the CI gate template; DEV-073 shipped `--doctor` diagnostics; DEV-079 shipped adoption docs. Rev4 requires machine-readable verifier output (`--format json`), human-friendly **Problem / Impact / Fix** messages, a published JSON schema, and a gate workflow step that consumes JSON. Provenance surface authority from `docs/updates/rev4-conflict-resolutions.md` §5 requires doctor output to summarize `Docs/.agtoosa-version`, `Docs/agtoosa-lock.json`, and `.agtoosa/state.json` with explicit labels.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Add stable JSON machine output and actionable human diagnostics to verifier and doctor, with schema documentation and CI gate consumption. |
| User outcome | Users and CI parse verifier results programmatically; humans see Problem/Impact/Fix guidance; doctor reports provenance surfaces with clear authority labels. |
| Success condition | `agtoosa-verify.sh --format json` and doctor JSON mode emit `verify-result-v1` schema documents; human text uses Problem/Impact/Fix; `docs/schemas/verify-result-v1.json` ships; gate example includes optional JSON parse step; bats VFJ green. |
| Proof / evidence | VFJ bats for JSON validity, schema conformance, human format, doctor provenance labels, gate template step; test-plan RED/GREEN. |
| Non-goals | New verifier gates; hosted dashboards; changing exit-code semantics; LLM-based diagnosis. |
| Assumptions | Text mode remains default; JSON is opt-in; exit codes `0/1/2` unchanged from DEV-061. |
| Risks | JSON schema drift from emitter; gate breaks on pretty-print variance; doctor over-claims missing optional files as errors. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** CI maintainer, **I want** verifier JSON output **so that** GitHub Actions can summarize findings without parsing free text.

**As a** developer, **I want** Problem/Impact/Fix messages **so that** I can remediate verifier failures without reading grep internals.

**As an** operator, **I want** doctor JSON to label version, lock, and state surfaces **so that** I understand which provenance file is authoritative for what.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa-verify.sh` is invoked with `--format json` THE SYSTEM SHALL emit a single JSON document conforming to `docs/schemas/verify-result-v1.json` on stdout and SHALL preserve existing exit codes | Must |
| AC-002 | WHEN verifier or doctor reports a finding in human mode THE SYSTEM SHALL structure each finding with **Problem**, **Impact**, and **Fix** sections | Must |
| AC-003 | WHEN `docs/schemas/verify-result-v1.json` is published THE SYSTEM SHALL document required fields: `schema_version`, `tool`, `exit_code`, `summary`, `findings[]` with `id`, `severity`, `problem`, `impact`, `fix`, and optional `ac_refs` | Must |
| AC-004 | WHEN `agtoosa.sh --doctor` runs with JSON format THE SYSTEM SHALL emit doctor diagnostics including labeled summaries of `Docs/.agtoosa-version`, `Docs/agtoosa-lock.json`, and `.agtoosa/state.json` per rev4-conflict-resolutions §5 | Must |
| AC-005 | WHEN human and JSON modes run THE SYSTEM SHALL classify each check in output metadata as `guided`, `evidenced`, or `enforced` where applicable | Must |
| AC-006 | WHEN `Docs/agtoosa-gate.yml.example` is updated THE SYSTEM SHALL include a step that runs the verifier with `--format json`, validates non-empty JSON, and fails the job on non-zero verifier exit while preserving exit status | Must |
| AC-007 | WHEN JSON mode is not requested THE SYSTEM SHALL retain existing human verifier output shape aside from Problem/Impact/Fix enrichment | Must |
| AC-008 | WHEN `lib/maintain.sh` dispatches verify/doctor THE SYSTEM SHALL pass through `--format json` from `agtoosa.sh --verify --format json` and `agtoosa.sh --doctor --format json` | Must |
| AC-009 | WHEN `tests/agtoosa.bats` runs DEV-088 coverage THE SYSTEM SHALL validate JSON against schema, human finding format, doctor provenance labels, and gate template JSON step | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | JSON emitted on stderr or interleaved with human warnings; CI parsers break. |
| FM-002 | AC-002 | Human output reverts to opaque grep lines without remediation guidance. |
| FM-003 | AC-003 | Schema missing `schema_version`; consumers cannot version-pin. |
| FM-004 | AC-004 | Doctor conflates lock and state authority or omits explicit labels. |
| FM-005 | AC-005 | All checks labeled `enforced`; overclaims LLM-adjacent gates. |
| FM-006 | AC-006 | Gate swallows verifier exit code when JSON parse fails. |
| FM-007 | AC-007 | Default text mode breaks existing bats VF-* expectations. |

### 1.5 Out of Scope

- New lifecycle verifier gates or changing Must AC definitions.
- Verifier WARN/FAIL for missing evidence ledger (roadmap).
- Hosted result upload or telemetry.
- PowerShell verifier JSON parity (DEV-105 may dispatch to bash script).
- Automatic fix application.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| JSON schema document | generator-enforced + CI contract tests |
| Verifier exit codes | machine-enforced locally and in CI |
| Assurance level per check in JSON | documentation + emitter metadata |
| Semantic correctness of specs | guided — not JSON-gated |
| Branch protection | manual |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `docs/schemas/verify-result-v1.json` — JSON Schema for verifier/doctor machine output.
- `template/Docs/schemas/verify-result-v1.json` — generated-project copy.

Files to change:

- `template/Docs/agtoosa-verify.sh` and `docs/agtoosa-verify.sh` — `--format json`, Problem/Impact/Fix human findings, assurance metadata.
- `lib/maintain.sh` — doctor JSON emitter with provenance surface labels; CLI flag passthrough.
- `agtoosa.sh` — `--format json` for `--verify` and `--doctor`.
- `template/Docs/agtoosa-gate.yml.example` and `docs/agtoosa-gate.yml.example` — JSON verifier step.
- `docs/examples/verifier-ci-adoption.md` — document JSON mode and gate step.
- `tests/agtoosa.bats` — VFJ-001–VFJ-010 coverage.

Key interfaces:

- `emit_verify_json(findings[], exit_code)` — stdout only JSON in json mode.
- `format_finding_human(id, problem, impact, fix)` — human mode block.
- Doctor JSON `provenance` object — keys `version_marker`, `lock_file`, `state_file` with `path`, `present`, `authority` text.

### 2.2 Data Flow

1. User or CI invokes `bash Docs/agtoosa-verify.sh --format json --root .`.
2. Verifier runs deterministic checks; builds findings array with assurance classification.
3. JSON document printed to stdout; exit code set per DEV-061 semantics.
4. Human mode prints Problem/Impact/Fix blocks per finding.
5. Doctor gathers install health + reads three provenance surfaces; emits JSON or human summary with authority labels.
6. Gate workflow runs verifier with `--format json`, pipes to `jq` validation, fails on non-zero exit.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| JSON includes secret values from repo files | Information Disclosure | Emit finding summaries and paths only; never dump file bodies. |
| Crafted repo tricks verifier into JSON PASS | Tampering | Checks remain deterministic greps; schema tests lock required fields. |
| Gate step masks verifier failure | Repudiation | Preserve exit code; JSON parse failure fails job separately. |
| Schema injection via malicious finding text | Elevation of Privilege | JSON-encode all string fields; no eval of finding content. |
| Huge finding list breaks CI | Denial of Service | Cap findings array size; truncate with summary count. |
| Doctor mislabels state.json as committed truth | Spoofing | Explicit `authority` and `committed` flags per rev4-conflict-resolutions §5. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `template/Docs/agtoosa-verify.sh`, `lib/maintain.sh`, `agtoosa.sh`, `docs/schemas/verify-result-v1.json`, `agtoosa-gate.yml.example`, `docs/examples/verifier-ci-adoption.md`, `tests/agtoosa.bats`
Directories in scope: `template/Docs/`, `docs/schemas/`, `lib/`, `tests/`
Out of scope        : new verifier gates, PS1 JSON emitter, hosted dashboards

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Schema and contract RED coverage
  - [ ] 1.1 Add `verify-result-v1.json` and VFJ bats for JSON validity on pass/fail fixtures — _Requirements: AC-001, AC-003, AC-009_
  - [ ] 1.2 Add VFJ bats for Problem/Impact/Fix human format — _Requirements: AC-002, AC-007, AC-009_
- [ ] **2.** Verifier machine output
  - [ ] 2.1 Implement `--format json` emitter and assurance metadata in `agtoosa-verify.sh` — _Requirements: AC-001, AC-005, AC-007_
  - [ ] 2.2 Enrich human findings with Problem/Impact/Fix — _Requirements: AC-002, AC-007_
- [ ] **3.** Doctor machine output
  - [ ] 3.1 Add doctor JSON mode with provenance surface labels — _Requirements: AC-004, AC-005_
  - [ ] 3.2 Wire `agtoosa.sh` and `lib/maintain.sh` flag passthrough — _Requirements: AC-008_
- [ ] **4.** CI adoption
  - [ ] 4.1 Update gate example and adoption doc with JSON step — _Requirements: AC-006_
- [ ] **5.** Evidence
  - [ ] 5.1 Record VFJ RED/GREEN evidence — _Requirements: AC-001–AC-009_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2
**Wave 2 (sequential after Wave 1):** 2.1, 2.2
**Wave 3 (sequential after Wave 2):** 3.1, 3.2
**Wave 4 (sequential after Wave 3):** 4.1
**Wave 5 (sequential after Wave 4):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-088.md`
AC coverage: 9 ACs mapped to 10 VFJ test IDs
Smoke set: 3 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-07-12 09:00
Enrollment: Rev4 Wave 1 — verifier and doctor machine output
