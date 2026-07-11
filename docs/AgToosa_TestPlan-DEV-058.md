# Test Plan: DEV-058 — Local Dashboard

> **Spec:** `docs/archived/spec-DEV-058.md`
> **Status:** ⬜ Backlog
> **Execution state:** Not run
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-058"`
> **Contract filter:** `bats tests/agtoosa.bats -f "DB-"`

## Coverage Target

Target: 8 of 8 Must-priority acceptance criteria. DB-001–DB-008 are future test IDs; no dashboard run, read-only proof, or implementation evidence is claimed in this backlog plan.

| AC | Priority | Test ID | Type | Future assertion | Automated |
|----|----------|---------|------|------------------|-----------|
| AC-001 | Must | DB-001 | Bats / mutation boundary | Default invocation emits required Markdown to stdout while fixture content hashes, file inventory, and mtimes remain unchanged | planned `@smoke` |
| AC-002 | Must | DB-002 | Bats / output contract | HTML mode emits one self-contained document with all required sections and no remote asset references | planned `@smoke` |
| AC-003 | Must | DB-003 | Docs / output contract | Both formats identify the selected Master-Plan as repo-local source of truth and label all other inputs as projections | planned `@smoke` |
| AC-004 | Must | DB-004 | Docs / integration | Dashboard doc defines CLI, sources, stdout-only behavior, enforcement labels, and its non-duplicating relationship to Status | planned `@smoke` |
| AC-005 | Must | DB-005 | Bats / error handling | Missing or unreadable Master-Plan returns exit `2`, stderr diagnostic, empty stdout, and no created files | planned `@smoke` |
| AC-006 | Must | DB-006 | Bats / dependency contract | Renderer uses no Node, Python, package manager, account, telemetry, network command, or remote asset | planned `@smoke` |
| AC-007 | Must | DB-007 | Security / Bats | HTML output escapes all five required characters and does not activate injected tags or unsafe links | planned `@smoke` |
| AC-008 | Must | DB-008 | Bats / resilience | Missing optional files and malformed rows yield bounded warnings; `--log-lines` caps rows; repeated runs are byte-identical after normalizing the generation timestamp | planned `@smoke` |

## Test Design

### Fixture Repository

`tests/fixtures/dashboard-repo/` will contain only synthetic data:

| Input | Cases represented |
|-------|-------------------|
| `docs/Master-Plan.md` | Project Charter, Active Cycle, Blocked, completed work, bounded Update Log |
| `docs/archived/evidence-DEV-TEST.md` | Safe evidence pointers and phases |
| `docs/archived/retro-2099-01-01.md` | Latest-retro link and non-authoritative proposal |
| `docs/agtoosa-events.jsonl` | Valid rows plus one malformed optional row |
| Injection-valued story/evidence fields | `&`, `<`, `>`, `"`, `'`, script-like text, and unsafe URL-like text |

A test may copy this fixture to a temporary directory before execution. It must never run mutation assertions directly against a fixture another test could modify.

### Read-Only Proof Method

DB-001 snapshots all of the following before and after Markdown and HTML invocations:

1. Sorted relative file and directory inventory
2. Content digest for every regular file
3. Modification time for every regular file
4. Git-style status of the temporary fixture when initialized as a fixture repository

The script's stdout and stderr are captured outside the fixture root. Any created cache, lock, temp, output, or metadata file inside the fixture fails the test. This proves the tested implementation path, not an operating-system sandbox.

### Negative and Boundary Cases

- Explicit root with neither `docs/Master-Plan.md` nor `Docs/Master-Plan.md`
- Unreadable Master-Plan
- Invalid `--format`
- `--log-lines` equal to zero, negative, nonnumeric, and above the documented cap
- Both `docs/` and `Docs/` present
- Missing evidence, retro, or events file
- Malformed JSONL row between valid rows
- Duplicate evidence pointers and nondeterministic filesystem enumeration
- HTML control characters and script-like source text
- Absolute, remote, or traversal-like evidence link
- Script source containing `curl`, `wget`, package-manager, Node, or Python invocation

## Planned Smoke Set

All eight tests are planned smoke checks because each covers a Must AC and exercises a bounded local fixture.

| Test ID | Must AC covered | Why smoke |
|---------|-----------------|-----------|
| DB-001 | AC-001 | Protects the central stdout-only/read-only contract. |
| DB-002 | AC-002 | Locks the promised static HTML surface. |
| DB-003 | AC-003 | Preserves Master-Plan authority in every format. |
| DB-004 | AC-004 | Prevents CLI and Status relationship drift. |
| DB-005 | AC-005 | Prevents false-success output without required state. |
| DB-006 | AC-006 | Preserves dependency-light, local-first execution. |
| DB-007 | AC-007 | Prevents active markup injection in static output. |
| DB-008 | AC-008 | Protects resilience, bounded output, and determinism. |

## TDD Evidence Placeholders

No commands below have been executed. Replace each placeholder only during an enrolled build, preserving the exact command, exit code, and bounded output excerpt.

### RED evidence — unexecuted

| Task / tests | Future command | Expected failing condition before implementation | Status |
|--------------|----------------|--------------------------------------------------|--------|
| 1.2 / DB-001, DB-002, DB-005, DB-007, DB-008 | `bats tests/agtoosa.bats -f "DEV-058"` | Dashboard script and fixture behavior do not yet exist | NOT RUN |
| 5.2 / DB-003, DB-004, DB-006 | `bats tests/agtoosa.bats -f "DB-00[346]"` | Authority, documentation, registration, and dependency contracts are not wired | NOT RUN |

Required RED record for each row: command, nonzero exit, failing test names, minimal failure excerpt, timestamp.

### GREEN evidence — unexecuted

| Task / tests | Future command | Expected passing condition after implementation | Status |
|--------------|----------------|-------------------------------------------------|--------|
| 6.1 / DB-001–DB-008 | `bats tests/agtoosa.bats -f "DEV-058"` | All dashboard contract and behavior checks pass | NOT RUN |
| 6.1 / DB-001–DB-008 | `bats tests/agtoosa.bats -f "DB-"` | DB namespace passes independently | NOT RUN |
| 6.1 / Markdown smoke | `bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format markdown` | Required Markdown is emitted to stdout with exit `0` | NOT RUN |
| 6.1 / HTML smoke | `bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format html` | Self-contained escaped HTML is emitted to stdout with exit `0` | NOT RUN |
| 6.1 / regression | `bats tests/agtoosa.bats` | Full generator suite remains green | NOT RUN |

Required GREEN record for each row: command, exit `0`, passing test count or output assertions, bounded excerpt, timestamp.

## Future Validation Commands

Run only after DEV-058 is enrolled and the corresponding implementation wave is ready:

```bash
bats tests/agtoosa.bats -f "DEV-058"
bats tests/agtoosa.bats -f "DB-"
bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format markdown
bash docs/agtoosa-dashboard.sh --root tests/fixtures/dashboard-repo --format html
bash docs/agtoosa-verify.sh
bats tests/agtoosa.bats
git diff --check
```

A future report must distinguish the script's tested stdout-only path, CI checks when run, manual user invocation/redirection, agent-instructed Status analysis, and roadmap hosted/TUI behavior.

## Evidence Status

RED evidence: not recorded.
GREEN evidence: not recorded.
Review evidence: not recorded.
Ship evidence: not recorded.
