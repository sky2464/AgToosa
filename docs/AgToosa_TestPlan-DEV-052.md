# Test Plan: DEV-052 — Hook Automation Pack

> **Spec:** `docs/archived/spec-DEV-052.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "HK-001|HK-002|HK-003|HK-006|HK-007"`
> **Status:** ✅ Done (build evidence complete)
> **Prerequisite gate:** DEV-059 shipped (v5.3.10)
> **Execution state:** RED→GREEN executed 2026-07-11; preview fixtures recorded

## Coverage Target

Portable, optional, secret-safe hook contract without claiming universal native interception. Focused tests cover event and platform matrices, preview/approval/removal language, DEV-059 linkage, optional health, existing Claude script parity, and settings-merge deduplication. They do not prove that a third-party host executes a hook.

### AC Mapping

| AC | Test ID(s) | Type | Planned assertion | Automated |
|----|------------|------|-------------------|-----------|
| AC-001 | HK-001 | Docs contract | Both Hooks guide copies catalog all seven events with purpose, availability, command/script, failure behavior, and enforcement | `@smoke` pass |
| AC-002 | HK-002 | Docs/Integration | Init/Update show affected files and merge intent, require approval before write, preserve unrelated settings, support decline, and document removal | `@smoke` pass |
| AC-003 | HK-003 | Security/Negative | Guides, settings, and exemplar script prohibit or avoid raw tool input, environment dumps, tokens, private URLs, and secret values in diagnostics | `@smoke` pass |
| AC-004 | HK-004 | Docs/Integration | Hook policy consumption uses the shipped DEV-059 checker/result and preserves enforcement plus `on_violation` semantics | pass |
| AC-005 | HK-005 | Docs/Parity | Every event/platform cell distinguishes proven native support from checklist fallback; unknown support defaults to non-native | pass |
| AC-006 | HK-006 | Regression | Status and verifier produce no finding solely because the optional pack is absent | `@smoke` pass |
| AC-007 | HK-007 | Bats/Integration | Existing `merge_settings_json` preserves unrelated settings and deduplicates repeated AgToosa commands on update | `@smoke` pass |
| AC-008 | HK-001–HK-007 | Regression/Evidence | Full DEV-052 contract, dual-path parity, preview fixtures, and RED/GREEN evidence are complete | pass |

### Test Cases

| Test ID | Scope | Positive assertion | Negative / edge assertion | State |
|---------|-------|--------------------|---------------------------|-------|
| HK-001 | Hooks guide copies | Seven events and six required fields per event are present with Claim Boundary classifications | Missing event/field or universal-runtime claim fails | ✅ authored + GREEN |
| HK-002 | Init/Update copies + preview fixtures | Approved preview writes only listed entries; declined preview writes nothing; removal is documented | Write before approval, hidden affected file, or unrelated-setting replacement fails | ✅ authored + GREEN |
| HK-003 | Hooks guide, Claude settings, exemplar script | Diagnostics use bounded metadata and redacted reasons | Raw tool payload, environment dump, token/private URL, or secret literal in output fails | ✅ authored + GREEN |
| HK-004 | Hooks guide + DEV-059 interface references | Checker path/result and `warn`/`instruct_stop`/proven-block behavior match shipped policy | Local schema fork or upgraded enforcement fails | ✅ authored + GREEN |
| HK-005 | Event/platform matrix + workflow pointers | Native events are evidence-backed; every unavailable event has a checklist fallback | Unverified native support or duplicated fallback matrix in adapters fails | ✅ authored + GREEN |
| HK-006 | Status/verifier fixtures | Project without optional pack remains healthy and produces no hook-absence finding | Hook absence warning/failure or health deduction fails | ✅ authored + GREEN |
| HK-007 | Update merge fixtures | Unrelated settings survive and repeated AgToosa command strings appear once | Duplicate commands, malformed JSON, or settings replacement fails | ✅ authored + GREEN |

## Smoke Set

- `HK-001` — event catalog and honest enforcement
- `HK-002` — preview, approval, decline, preservation, and removal
- `HK-003` — secret-safe diagnostic boundary
- `HK-006` — optional pack does not affect health
- `HK-007` — update merge preservation and deduplication

Smoke command (2026-07-11): `bats tests/agtoosa.bats -f "HK-001|HK-002|HK-003|HK-006|HK-007"` → exit 0 (5/5).

## Preview Evidence

### Approved preview fixture

| Field | Evidence |
|-------|----------|
| Status | **EXECUTED** 2026-07-11 |
| Affected files shown | `docs/AgToosa_Hooks.md`, `.claude/settings.json`, `.claude/hooks/block-dangerous-git.sh` |
| Existing entries preserved | `permissions.allow` = `Bash(git status *)`; `echo 'user-custom-stop'` |
| Entries added | AgToosa Stop / PreToolUse / PostToolUse command strings from template settings |
| Entries deduplicated | `0` on first merge; second merge of same source adds `0` duplicates (HK-007) |
| User decision | explicit approval (simulated via `merge_settings_json`) |
| Result | hooks merged; unrelated settings intact; bounded output only |

### Declined preview fixture

| Field | Evidence |
|-------|----------|
| Status | **EXECUTED** 2026-07-11 |
| Affected files shown | `docs/AgToosa_Hooks.md`, `.claude/settings.json`, `.claude/hooks/block-dangerous-git.sh` |
| User decision | explicit decline |
| Result | no write — settings file bytes unchanged |
| Status/verifier effect | no hook-absence finding (HK-006 fixture project without pack: verifier exit 0, no hook mention) |

Neither fixture includes raw hook payloads, environment values, tokens, credentials, or private URLs.

## TDD Evidence

### Task 1.1 — RED contract tests

**RED evidence — Task 1.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected RED: newly authored `HK-001`–`HK-007` assertions fail against the pre-implementation tree
- Observed exit code: nonzero (7 failed, CW-015 ok)
- Failure excerpt: `HK-001: [ -f "$f" ] failed` (missing `AgToosa_Hooks.md`); `HK-007: AssertionError` duplicate `block-dangerous-git.sh` command strings after merge

**GREEN evidence — Task 1.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected GREEN: all focused Hook Automation tests pass after Tasks 1.2–3.2
- Observed exit code: 0
- Passing excerpt: `ok 2..8` HK-001–HK-007 (8/8 including CW-015)

### Task 1.2 — Hooks guide contract

**RED evidence — Task 1.2**

- Status: **EXECUTED** (same RED run as 1.1)
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-003|HK-005|HK-006"`
- Expected RED: event matrix, safety, fallback, or optional-health contracts are absent
- Observed exit code: nonzero
- Failure excerpt: `grep: .../AgToosa_Hooks.md: No such file or directory`

**GREEN evidence — Task 1.2**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-003|HK-005|HK-006"`
- Expected GREEN: both guide copies satisfy event, safety, platform, health, and Claim Boundary checks
- Observed exit code: 0
- Passing excerpt: `ok` HK-001, HK-003, HK-005, HK-006

### Task 2.1 — Preview, approval, and merge behavior

**RED evidence — Task 2.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-002|HK-007"`
- Expected RED: preview/approval/removal or settings preservation/deduplication behavior is incomplete
- Observed exit code: nonzero
- Failure excerpt: Init/Update missing Hook Automation Pack language; merge produced duplicate command strings

**GREEN evidence — Task 2.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-002|HK-007"`
- Expected GREEN: approved/declined fixtures and repeated-update merge fixture pass
- Observed exit code: 0
- Passing excerpt: `ok` HK-002, HK-007

### Task 2.2 — DEV-059 policy linkage

**RED evidence — Task 2.2**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-004"`
- Expected RED: Hooks does not yet consume the shipped checker and violation semantics exactly
- Observed exit code: nonzero
- Failure excerpt: missing `agtoosa-policy-check.sh` references in Hooks guide

**GREEN evidence — Task 2.2**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-004"`
- Expected GREEN: policy resolution, rule IDs, enforcement classes, and violation behavior match DEV-059
- Observed exit code: 0
- Passing excerpt: `ok 5 DEV-052 HK-004: Hooks consume DEV-059 checker and on_violation semantics`

### Task 2.3 — Build/Ship and platform fallbacks

**RED evidence — Task 2.3**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-005|HK-006"`
- Expected RED: workflow event pointers or checklist fallbacks are absent or overclaim native support
- Observed exit code: nonzero
- Failure excerpt: missing Hooks guide / Build-Ship pointers

**GREEN evidence — Task 2.3**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-001|HK-005|HK-006"`
- Expected GREEN: workflows delegate to one matrix and pack absence remains non-blocking
- Observed exit code: 0
- Passing excerpt: `ok` HK-001, HK-005, HK-006

### Task 3.1 — Registration and Claude parity

**RED evidence — Task 3.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-003|HK-007"`
- Expected RED: guide registration, safe-output parity, or merge deduplication is incomplete
- Observed exit code: nonzero
- Failure excerpt: exemplar echoed raw `$COMMAND`; merge duplicated AgToosa commands on partial overlap

**GREEN evidence — Task 3.1**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "HK-003|HK-007"`
- Expected GREEN: inventory, existing native mappings, safe exemplar behavior, and merge fixtures pass
- Observed exit code: 0
- Passing excerpt: `ok` HK-003, HK-007; `--list-template-files` includes `Docs/AgToosa_Hooks.md`

### Task 3.2 — GREEN closure and preview evidence

**RED evidence — Task 3.2**

- Status: **EXECUTED** (closure incomplete while placeholders remained)
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected RED: closure fails while a focused test or approved/declined preview record is incomplete
- Observed exit code: nonzero (pre-implementation)
- Failure excerpt: same as Task 1.1 RED

**GREEN evidence — Task 3.2**

- Status: **EXECUTED**
- Command: `bats tests/agtoosa.bats -f "DEV-052"`
- Expected GREEN: `HK-001`–`HK-007` pass and all evidence placeholders are replaced truthfully
- Observed exit code: 0
- Passing excerpt: `1..8` all `ok` (CW-015 + HK-001–HK-007)

## Exact Validation Commands (executed)

```bash
bats tests/agtoosa.bats -f "DEV-052"                                          # exit 0
bats tests/agtoosa.bats -f "HK-001|HK-002|HK-003|HK-006|HK-007"              # exit 0
bash agtoosa.sh --list-template-files | grep AgToosa_Hooks                    # Docs/AgToosa_Hooks.md
bash agtoosa.sh --verify .                                                    # exit 0 (PASS; pre-existing WARNs unrelated to hooks)
bash docs/agtoosa-verify.sh --strict                                          # exit 1 (pre-existing WARN→FAIL: Wave Plan heading form / other stories)
git diff --check                                                              # exit 0
```

Accepted/pre-existing: `--strict` FAIL from verifier expecting `### Wave Plan` while spec uses `### 3.2 Wave Plan` (and other active-story WARNs). No hook-absence findings introduced.
