# Test Plan: DEV-058 — Local Dashboard

> **Spec:** `docs/archived/spec-DEV-058.md`
> **Status:** 🟨 In Progress (build)
> **Execution state:** GREEN recorded
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-058"`
> **Contract filter:** `bats tests/agtoosa.bats -f "DB-"`

## Coverage Target

Target: 8 of 8 Must-priority acceptance criteria. DB-001–DB-008 map 1:1 to AC-001–AC-008.

| AC | Priority | Test ID | Type | Assertion | Automated |
|----|----------|---------|------|-----------|-----------|
| AC-001 | Must | DB-001 | Bats / mutation boundary | Default invocation emits required Markdown to stdout while fixture content hashes, file inventory, and mtimes remain unchanged | `@smoke` |
| AC-002 | Must | DB-002 | Bats / output contract | HTML mode emits one self-contained document with all required sections and no remote asset references | `@smoke` |
| AC-003 | Must | DB-003 | Docs / output contract | Both formats identify the selected Master-Plan as repo-local source of truth and label all other inputs as projections | `@smoke` |
| AC-004 | Must | DB-004 | Docs / integration | Dashboard doc defines CLI, sources, stdout-only behavior, enforcement labels, and its non-duplicating relationship to Status | `@smoke` |
| AC-005 | Must | DB-005 | Bats / error handling | Missing or unreadable Master-Plan returns exit `2`, stderr diagnostic, empty stdout, and no created files | `@smoke` |
| AC-006 | Must | DB-006 | Bats / dependency contract | Renderer uses no Node, Python, package manager, account, telemetry, network command, or remote asset | `@smoke` |
| AC-007 | Must | DB-007 | Security / Bats | HTML output escapes all five required characters and does not activate injected tags or unsafe links | `@smoke` |
| AC-008 | Must | DB-008 | Bats / resilience | Missing optional files and malformed rows yield bounded warnings; `--log-lines` caps rows; repeated runs are byte-identical after normalizing the generation timestamp | `@smoke` |

## Fixture Repository

`tests/fixtures/dashboard-repo/` contains synthetic data:

| Input | Cases represented |
|-------|-------------------|
| `docs/Master-Plan.md` | Project Charter, Active Cycle, Blocked, injection-valued titles |
| `docs/archived/evidence-DEV-TEST.md` / `evidence-DEV-ZZZ.md` | Sorted evidence pointers; unsafe remote/traversal pointers |
| `docs/archived/retro-2099-01-01.md` (+ older retro) | Latest-retro selection |
| `docs/agtoosa-events.jsonl` | Valid rows plus one malformed optional row |
| `tests/fixtures/dashboard-repo-missing-optional/` | Missing evidence/retro/events |
| `tests/fixtures/dashboard-repo-no-plan/` | Missing Master-Plan (exit 2) |

## TDD Evidence

### RED evidence — task 1.2

```
RED evidence — 1.2 / DB-001–DB-008
Command: bats tests/agtoosa.bats -f "DEV-058 DB-"
Exit code: 1 (nonzero)
Failure excerpt:
  not ok 1 DEV-058 DB-001: ... `[ -f "$dash" ]' failed
  not ok 2–8: same missing agtoosa-dashboard.sh / AgToosa_Dashboard.md
Timestamp: 2026-07-12T02:59:00Z
```

### GREEN evidence — task 6.1

```
GREEN evidence — 6.1 / DB-001–DB-008
Command: bats tests/agtoosa.bats -f "DEV-058 DB-"
Exit code: 0
Result: 8/8 pass
Timestamp: 2026-07-12T03:02:00Z
```

```
GREEN evidence — 6.1 / Markdown smoke
Command: bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format markdown
Exit code: 0
Excerpt: emits Project Charter / Active Stories / Blocked / Evidence Index / Recent Events / Latest Retrospective / Recommended Next Actions; stderr warns on 1 malformed event row
Timestamp: 2026-07-12T03:02:10Z
```

```
GREEN evidence — 6.1 / HTML smoke
Command: bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format html
Exit code: 0
Excerpt: self-contained HTML with 7 <h2> sections; injection characters escaped
Timestamp: 2026-07-12T03:02:15Z
```

```
GREEN evidence — 6.1 / missing Master-Plan
Command: bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo-no-plan --format markdown
Exit code: 2
Excerpt: empty stdout; stderr: Error: no Docs/Master-Plan.md or docs/Master-Plan.md ...
Timestamp: 2026-07-12T03:02:20Z
```

## Evidence Status

RED evidence: recorded (pre-implementation missing script/doc).
GREEN evidence: recorded (DB-001–DB-008 pass; markdown/html/missing-plan smokes).
Review evidence: not recorded.
Ship evidence: not recorded.
