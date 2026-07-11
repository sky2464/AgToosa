# Test Plan: DEV-052 — Hook Automation Pack

> **Spec:** `docs/archived/spec-DEV-052.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "HK-001|HK-002|HK-003|HK-006|HK-007"`
> **Status:** ⬜ Backlog
> **Prerequisite gate:** DEV-059 must ship before DEV-052 enrollment
> **Execution state:** Planned only — no DEV-052 validation, preview, or hook command has been executed

## Coverage Target

The future build must prove a portable, optional, secret-safe hook contract without claiming universal native interception. Focused tests cover event and platform matrices, preview/approval/removal language, DEV-059 linkage, optional health, existing Claude script parity, and settings-merge deduplication. They do not prove that a third-party host executes a hook.

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | HK-001 | Docs contract | Both Hooks guide copies catalog all seven events with purpose, availability, command/script, failure behavior, and enforcement | planned `@smoke` |
| AC-002 | HK-002 | Docs/Integration | Init/Update show affected files and merge intent, require approval before write, preserve unrelated settings, support decline, and document removal | planned `@smoke` |
| AC-003 | HK-003 | Security/Negative | Guides, settings, and exemplar script prohibit or avoid raw tool input, environment dumps, tokens, private URLs, and secret values in diagnostics | planned `@smoke` |
| AC-004 | HK-004 | Docs/Integration | Hook policy consumption uses the shipped DEV-059 checker/result and preserves enforcement plus `on_violation` semantics | planned |
| AC-005 | HK-005 | Docs/Parity | Every event/platform cell distinguishes proven native support from checklist fallback; unknown support defaults to non-native | planned |
| AC-006 | HK-006 | Regression | Status and verifier produce no finding solely because the optional pack is absent | planned `@smoke` |
| AC-007 | HK-007 | Bats/Integration | Existing `merge_settings_json` preserves unrelated settings and deduplicates repeated AgToosa commands on update | planned `@smoke` |
| AC-008 | HK-001–HK-007 | Regression/Evidence | Full DEV-052 contract, dual-path parity, preview fixtures, and RED/GREEN evidence are complete | planned |

### Planned Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| HK-001 | Hooks guide copies | Seven events and six required fields per event are present with Claim Boundary classifications | Missing event/field or universal-runtime claim fails | planned — not authored or run |
| HK-002 | Init/Update copies + preview fixtures | Approved preview writes only listed entries; declined preview writes nothing; removal is documented | Write before approval, hidden affected file, or unrelated-setting replacement fails | planned — not authored or run |
| HK-003 | Hooks guide, Claude settings, exemplar script | Diagnostics use bounded metadata and redacted reasons | Raw tool payload, environment dump, token/private URL, or secret literal in output fails | planned — not authored or run |
| HK-004 | Hooks guide + DEV-059 interface references | Checker path/result and `warn`/`instruct_stop`/proven-block behavior match shipped policy | Local schema fork or upgraded enforcement fails | planned — not authored or run |
| HK-005 | Event/platform matrix + workflow pointers | Native events are evidence-backed; every unavailable event has a checklist fallback | Unverified native support or duplicated fallback matrix in adapters fails | planned — not authored or run |
| HK-006 | Status/verifier fixtures | Project without optional pack remains healthy and produces no hook-absence finding | Hook absence warning/failure or health deduction fails | planned — not authored or run |
| HK-007 | Update merge fixtures | Unrelated settings survive and repeated AgToosa command strings appear once | Duplicate commands, malformed JSON, or settings replacement fails | planned — not authored or run |

## Smoke Set

- `HK-001` — event catalog and honest enforcement
- `HK-002` — preview, approval, decline, preservation, and removal
- `HK-003` — secret-safe diagnostic boundary
- `HK-006` — optional pack does not affect health
- `HK-007` — update merge preservation and deduplication

Smoke is a future focused subset, not evidence that hook behavior exists today.

## Planned Preview Evidence

### Approved preview fixture

| Field | Future evidence |
|-------|-----------------|
| Status | **PLANNED — NOT EXECUTED** |
| Affected files shown | `[capture exact repo-relative list]` |
| Existing entries preserved | `[capture fixture keys/commands; no values that contain secrets]` |
| Entries added | `[capture AgToosa command strings]` |
| Entries deduplicated | `[capture duplicate command count]` |
| User decision | `[capture explicit approval]` |
| Result | `[capture changed-file list and bounded output]` |

### Declined preview fixture

| Field | Future evidence |
|-------|-----------------|
| Status | **PLANNED — NOT EXECUTED** |
| Affected files shown | `[capture exact repo-relative list]` |
| User decision | `[capture explicit decline]` |
| Result | `[capture proof of no write]` |
| Status/verifier effect | `[capture proof of no hook-absence finding]` |

Neither fixture may include raw hook payloads, environment values, tokens, credentials, or private URLs.

## TDD Evidence Placeholders

Every block below is deliberately unexecuted. Replace bracketed fields only with observed future output after DEV-059 has shipped and DEV-052 has been enrolled and approved.

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected RED: newly authored `HK-001`–`HK-007` assertions fail against the pre-implementation tree
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 1.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected GREEN: all focused Hook Automation tests pass after Tasks 1.2–3.2
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 1.2 — Hooks guide contract

**RED evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-003|HK-005|HK-006"`
- Expected RED: event matrix, safety, fallback, or optional-health contracts are absent
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 1.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-003|HK-005|HK-006"`
- Expected GREEN: both guide copies satisfy event, safety, platform, health, and Claim Boundary checks
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.1 — Preview, approval, and merge behavior

**RED evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-002|HK-007"`
- Expected RED: preview/approval/removal or settings preservation/deduplication behavior is incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 2.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-002|HK-007"`
- Expected GREEN: approved/declined fixtures and repeated-update merge fixture pass
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.2 — DEV-059 policy linkage

**RED evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-004"`
- Expected RED: Hooks does not yet consume the shipped checker and violation semantics exactly
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 2.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-004"`
- Expected GREEN: policy resolution, rule IDs, enforcement classes, and violation behavior match DEV-059
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 2.3 — Build/Ship and platform fallbacks

**RED evidence — Task 2.3**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-005|HK-006"`
- Expected RED: workflow event pointers or checklist fallbacks are absent or overclaim native support
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 2.3**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-005|HK-006"`
- Expected GREEN: workflows delegate to one matrix and pack absence remains non-blocking
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 3.1 — Registration and Claude parity

**RED evidence — Task 3.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-003|HK-007"`
- Expected RED: guide registration, safe-output parity, or merge deduplication is incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 3.1**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-003|HK-007"`
- Expected GREEN: inventory, existing native mappings, safe exemplar behavior, and merge fixtures pass
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

### Task 3.2 — GREEN closure and preview evidence

**RED evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected RED: closure fails while a focused test or approved/declined preview record is incomplete
- Observed exit code: `[not captured]`
- Failure excerpt: `[capture from future run with secrets redacted]`

**GREEN evidence — Task 3.2**

- Status: **PLANNED — NOT EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected GREEN: `HK-001`–`HK-007` pass and all evidence placeholders are replaced truthfully
- Observed exit code: `[not captured]`
- Passing excerpt: `[capture from future run]`

## Exact Future Validation Commands

Do not run these while DEV-052 is Backlog or before DEV-059 ships. Run them after DEV-052 is enrolled, approved, implemented, and both preview fixtures are recorded.

```bash
bats tests/agtoosa.bats -f "DEV-052"
bats tests/agtoosa.bats -f "HK-"
bats tests/agtoosa.bats -f "HK-001|HK-002|HK-003|HK-006|HK-007"
bash agtoosa.sh --list-template-files
bash agtoosa.sh --verify .
bash docs/agtoosa-verify.sh --strict
bats tests/agtoosa.bats
git diff --check
```
