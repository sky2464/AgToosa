# Test Plan: DEV-059 — Governance Policy-as-Code

> **Spec:** `docs/archived/spec-DEV-059.md`
> **Status:** ⬜ Backlog
> **Execution state:** Not run
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-059"`
> **Contract filter:** `bats tests/agtoosa.bats -f "GP-"`

## Coverage Target

Target: 8 of 8 acceptance criteria, including all 7 Must-priority criteria. GP-001–GP-008 are future test IDs; no test result or implementation evidence is claimed in this backlog plan.

| AC | Priority | Test ID | Type | Future assertion | Automated |
|----|----------|---------|------|------------------|-----------|
| AC-001 | Must | GP-001 | Docs / integration | Canonical policy doc and inert example define all six categories, required rule fields, allowed enforcement classes, and allowed violation actions | planned `@smoke` |
| AC-002 | Must | GP-002 | Bats / integration | Resolver prefers `.agtoosa/policy.yaml`, falls back to the mode-appropriate `Docs/Context/agtoosa-policy.yaml` or `docs/Context/agtoosa-policy.yaml`, ignores the example, and succeeds with `policy_path=none` when policy is absent | planned `@smoke` |
| AC-003 | Must | GP-003 | Docs / integration | Handoff contract emits `Applicable Policy`, resolved source, and rule metadata or an explicit no-policy result without mutation | planned `@smoke` |
| AC-004 | Must | GP-004 | Docs / integration | Spec, Build, Review, Import, and Governance reference one violation contract and preserve Master-Plan lifecycle authority | planned `@smoke` |
| AC-005 | Must | GP-005 | Bats | Checker accepts the valid fixture and rejects missing keys, bad enums, duplicate IDs, unsupported categories, and oversized input without network access | planned `@smoke` |
| AC-006 | Must | GP-006 | Docs / integration | `block_generator` is limited to wired generator operations and host-level controls are not described as runtime-enforced | planned `@smoke` |
| AC-007 | Should | GP-007 | Bats / verifier | If implemented, invalid present policy emits WARN, absent policy emits no finding, and strict-mode behavior is documented | planned |
| AC-008 | Must | GP-008 | Security / Bats | Secret-value fixture fails with rule/field diagnostics while the suspected value is absent from stdout and stderr | planned `@smoke` |

## Test Design

### Fixtures

| Fixture | Purpose | Expected future result |
|---------|---------|------------------------|
| `tests/fixtures/policy/valid.yaml` | Complete policy containing each v1 category | Checker exit `0` |
| `tests/fixtures/policy/invalid-missing-class.yaml` | Rule without `enforcement_class` | Checker exit `1`; rule and field named |
| `tests/fixtures/policy/invalid-secret-value.yaml` | Forbidden literal credential field | Checker exit `1`; value redacted |
| Temporary fixture root with both active policy paths | Resolution precedence | `.agtoosa/policy.yaml` selected |
| Temporary fixture root with no active policy | Optional-policy behavior | Exit `0`; `policy_path=none` |

Temporary roots must be created outside the source fixture tree. Tests must not mutate the checked-in examples.

### Negative and Boundary Cases

- Unknown `enforcement_class` and `on_violation` values
- Duplicate rule IDs across categories
- Unknown top-level category
- Empty description or rule ID
- Policy at and immediately above the documented size limit
- Explicit `--policy` path outside the selected root
- Secret-like field whose value must never appear in diagnostics
- Missing policy under default verifier mode
- Workflow text that describes agent instructions as generator- or runtime-enforced

## Planned Smoke Set

The smoke set covers every Must AC. GP-007 remains outside smoke because verifier integration is Should-priority and conditional.

| Test ID | Must ACs covered | Why smoke |
|---------|------------------|-----------|
| GP-001 | AC-001 | Locks the schema and enforcement vocabulary. |
| GP-002 | AC-002 | Prevents optional policy from becoming an install blocker. |
| GP-003 | AC-003 | Prevents weaker boundaries in exported handoffs. |
| GP-004 | AC-004 | Locks shared violation behavior and Master-Plan authority. |
| GP-005 | AC-005 | Exercises deterministic validation behavior. |
| GP-006 | AC-006 | Prevents unsupported runtime-enforcement claims. |
| GP-008 | AC-008 | Protects secret values in diagnostics. |

## TDD Evidence Placeholders

No commands below have been executed. Replace each placeholder only during an enrolled build, preserving the exact command, exit code, and bounded output excerpt.

### RED evidence — unexecuted

| Task / tests | Future command | Expected failing condition before implementation | Status |
|--------------|----------------|--------------------------------------------------|--------|
| 1.2 / GP-001, GP-002, GP-005, GP-008 | `bats tests/agtoosa.bats -f "DEV-059"` | Policy docs, checker, fixtures, and secret-safe behavior do not yet exist | NOT RUN |
| 4.3 / GP-003, GP-004, GP-006 | `bats tests/agtoosa.bats -f "GP-00[346]"` | Workflow policy sections and honest enforcement wording are absent | NOT RUN |
| 5.2 / GP-007 | `bats tests/agtoosa.bats -f "GP-007"` | Optional verifier policy warning is absent if AC-007 is enrolled | NOT RUN |

Required RED record for each row: command, nonzero exit, failing test names, minimal failure excerpt, timestamp.

### GREEN evidence — unexecuted

| Task / tests | Future command | Expected passing condition after implementation | Status |
|--------------|----------------|-------------------------------------------------|--------|
| 6.1 / GP-001–GP-008 | `bats tests/agtoosa.bats -f "DEV-059"` | All enrolled GP contract and behavior checks pass | NOT RUN |
| 6.1 / GP-001–GP-008 | `bats tests/agtoosa.bats -f "GP-"` | GP namespace passes independently | NOT RUN |
| 6.1 / policy checker | `bash docs/agtoosa-policy-check.sh --policy tests/fixtures/policy/valid.yaml` | Valid fixture returns exit `0` | NOT RUN |
| 6.1 / regression | `bats tests/agtoosa.bats` | Full generator suite remains green | NOT RUN |

Required GREEN record for each row: command, exit `0`, passing test count, bounded output excerpt, timestamp.

## Future Validation Commands

Run only after DEV-059 is enrolled and the corresponding implementation wave is ready:

```bash
bats tests/agtoosa.bats -f "DEV-059"
bats tests/agtoosa.bats -f "GP-"
bash docs/agtoosa-policy-check.sh --policy tests/fixtures/policy/valid.yaml
bash docs/agtoosa-verify.sh
bash docs/agtoosa-verify.sh --strict
bats tests/agtoosa.bats
git diff --check
```

The strict verifier command is relevant only if AC-007 is implemented. A future report must distinguish repository CI checks, manual checker invocation, agent-instructed workflow behavior, and roadmap runtime controls.

## Evidence Status

RED evidence: not recorded.
GREEN evidence: not recorded.
Review evidence: not recorded.
Ship evidence: not recorded.
