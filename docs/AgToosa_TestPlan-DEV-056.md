# Test Plan: DEV-056 — Retrospective Learning Loop

> **Spec:** `docs/archived/spec-DEV-056.md`
> **Status:** ⬜ Backlog
> **Execution state:** Not run
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-056"`
> **Contract filter:** `bats tests/agtoosa.bats -f "RL-"`

## Coverage Target

Target: 7 of 7 Must-priority acceptance criteria. RL-001–RL-007 are future test IDs; no test result, retro output, or implementation evidence is claimed in this backlog plan.

| AC | Priority | Test ID | Type | Future assertion | Automated |
|----|----------|---------|------|------------------|-----------|
| AC-001 | Must | RL-001 | Docs / fixture integration | Retro contract and complete-cycle fixture contain metadata plus Planned vs Shipped, Evidence Index, Keep, Stop, Start, Rejected Overreach, and Proposals; repeated runs resolve one cycle path | planned `@smoke` |
| AC-002 | Must | RL-002 | Docs / fixture integration | Every proposal has required fields and allowed enums; policy proposals carry an allowed enforcement class | planned `@smoke` |
| AC-003 | Must | RL-003 | Mutation-boundary integration | Retro workflow leaves Master-Plan, approved specs, policy, Context, tests, and specialist targets unchanged and emits only canonical next commands | planned `@smoke` |
| AC-004 | Must | RL-004 | Bats / integration | Inputs are limited to documented repo-local sources; missing optional sources become `unavailable`; no network command is required | planned `@smoke` |
| AC-005 | Must | RL-005 | Docs / claim contract | Retro controls use generator-enforced, CI-enforced, agent-instructed, manual, and roadmap labels without claiming automated learning | planned `@smoke` |
| AC-006 | Must | RL-006 | Fixture integration | Two distinct evidence pointers produce `repeated-pattern`; one pointer produces `single-cycle`; proposals stay within allowed types | planned `@smoke` |
| AC-007 | Must | RL-007 | Security / fixture integration | Retro summaries redact credential/private-URL fixtures, omit unbounded logs, and retain safe repo-relative pointers | planned `@smoke` |

## Test Design

### Fixtures

| Fixture | Purpose | Expected future result |
|---------|---------|------------------------|
| `tests/fixtures/retro/complete-cycle/` | Full Master-Plan, spec, review, evidence, test-plan, changelog, and events inputs | Expected retro contains every required section and supported result |
| `tests/fixtures/retro/missing-optional/` | No review/evidence/event optional artifacts | Retro completes with explicit `unavailable` entries |
| `tests/fixtures/retro/repeated-friction/` | Two independent artifacts cite the same normalized friction | One `repeated-pattern` candidate with two pointers |
| Secret-bearing review/log fixture inside the test tree | Redaction behavior | Secret and private URL absent; safe pointer retained |

Fixtures must use synthetic values. They must not copy real tokens, private URLs, or production logs.

### Mutation Boundary

RL-003 must snapshot content hashes and file inventory for all authoritative fixture inputs before the simulated retro run, then compare them afterward. Only the expected `archived/retro-[cycle-date].md` and bounded retro phase-event output may differ. The test must fail if proposal acceptance is represented as target mutation.

### Negative and Boundary Cases

- Missing required proposal field
- Unknown proposal type or status
- Policy proposal without `enforcement_class`
- Duplicate proposal ID
- Two observations that cite the same artifact row rather than two distinct pointers
- Missing optional evidence files
- Malformed optional JSONL event row
- Existing retro file for the same normalized cycle date
- Credential, private URL, or oversized log excerpt in source text
- Workflow wording that treats external agents, trackers, or retro output as lifecycle authority

## Planned Smoke Set

All seven tests are planned smoke checks because each covers a Must AC and the contract is documentation/fixture focused.

| Test ID | Must AC covered | Why smoke |
|---------|-----------------|-----------|
| RL-001 | AC-001 | Locks the durable artifact schema and one-file-per-cycle behavior. |
| RL-002 | AC-002 | Keeps every follow-up actionable and traceable. |
| RL-003 | AC-003 | Prevents the retro from bypassing lifecycle approval. |
| RL-004 | AC-004 | Preserves local-first operation and graceful missing-source behavior. |
| RL-005 | AC-005 | Prevents automated-learning and enforcement overclaims. |
| RL-006 | AC-006 | Makes repeated-pattern classification falsifiable. |
| RL-007 | AC-007 | Protects secrets and bounds copied evidence. |

## TDD Evidence Placeholders

No commands below have been executed. Replace each placeholder only during an enrolled build, preserving the exact command, exit code, and bounded output excerpt.

### RED evidence — unexecuted

| Task / tests | Future command | Expected failing condition before implementation | Status |
|--------------|----------------|--------------------------------------------------|--------|
| 1.2 / RL-001, RL-004, RL-006, RL-007 | `bats tests/agtoosa.bats -f "DEV-056"` | Retro contract and fixture behavior do not yet exist | NOT RUN |
| 4.2 / RL-002, RL-003, RL-005 | `bats tests/agtoosa.bats -f "RL-00[235]"` | Proposal boundary and enforcement wording are not wired | NOT RUN |

Required RED record for each row: command, nonzero exit, failing test names, minimal failure excerpt, timestamp.

### GREEN evidence — unexecuted

| Task / tests | Future command | Expected passing condition after implementation | Status |
|--------------|----------------|-------------------------------------------------|--------|
| 5.1 / RL-001–RL-007 | `bats tests/agtoosa.bats -f "DEV-056"` | All RL contract and fixture checks pass | NOT RUN |
| 5.1 / RL-001–RL-007 | `bats tests/agtoosa.bats -f "RL-"` | RL namespace passes independently | NOT RUN |
| 5.1 / regression | `bats tests/agtoosa.bats` | Full generator suite remains green | NOT RUN |

Required GREEN record for each row: command, exit `0`, passing test count, bounded output excerpt, timestamp.

## Future Validation Commands

Run only after DEV-056 is enrolled and the corresponding implementation wave is ready:

```bash
bats tests/agtoosa.bats -f "DEV-056"
bats tests/agtoosa.bats -f "RL-"
bash docs/agtoosa-verify.sh
bats tests/agtoosa.bats
git diff --check
```

A future report must distinguish the generated workflow contract, CI checks when run, agent-instructed proposal generation, manual proposal acceptance, and roadmap automatic application.

## Evidence Status

RED evidence: not recorded.
GREEN evidence: not recorded.
Review evidence: not recorded.
Ship evidence: not recorded.
