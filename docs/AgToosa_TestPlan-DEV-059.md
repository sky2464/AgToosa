# Test Plan: DEV-059 — Governance Policy-as-Code

> **Spec:** `docs/archived/spec-DEV-059.md`
> **Status:** 🟨 In Progress — build GREEN
> **Execution state:** GP-001–GP-009 green
> **Primary filter:** `bats tests/agtoosa.bats -f "DEV-059"`
> **Contract filter:** `bats tests/agtoosa.bats -f "GP-"`

## Coverage Target

Target: 8 of 8 acceptance criteria, including all 7 Must-priority criteria. GP-001–GP-008 are the contract IDs; GP-009 covers config registration.

| AC | Priority | Test ID | Type | Assertion | Automated |
|----|----------|---------|------|-----------|-----------|
| AC-001 | Must | GP-001 | Docs / integration | Canonical policy doc and inert example define all six categories, required rule fields, allowed enforcement classes, and allowed violation actions | `@smoke` |
| AC-002 | Must | GP-002 | Bats / integration | Resolver prefers `.agtoosa/policy.yaml`, falls back to Context policy, ignores the example, and succeeds with `policy_path=none` when policy is absent | `@smoke` |
| AC-003 | Must | GP-003 | Docs / integration | Handoff contract emits `Applicable Policy`, resolved source, and rule metadata or an explicit no-policy result without mutation | `@smoke` |
| AC-004 | Must | GP-004 | Docs / integration | Spec, Build, Review, Import, and Governance reference one violation contract and preserve Master-Plan lifecycle authority | `@smoke` |
| AC-005 | Must | GP-005 | Bats | Checker accepts the valid fixture and rejects missing keys, bad enums, duplicate IDs, unsupported categories, and oversized input without network access | `@smoke` |
| AC-006 | Must | GP-006 | Docs / integration | `block_generator` is limited to wired generator operations and host-level controls are not described as runtime-enforced | `@smoke` |
| AC-007 | Should | GP-007 | Bats / verifier | Invalid present policy emits WARN; absent policy emits no finding; strict-mode promotes warnings | yes |
| AC-008 | Must | GP-008 | Security / Bats | Secret-value fixture fails with rule/field diagnostics while the suspected value is absent from stdout and stderr | `@smoke` |

## Test Design

### Fixtures

| Fixture | Purpose | Expected result |
|---------|---------|-----------------|
| `tests/fixtures/policy/valid.yaml` | Complete policy containing each v1 category | Checker exit `0` |
| `tests/fixtures/policy/invalid-missing-class.yaml` | Rule without `enforcement_class` | Checker exit `1`; rule and field named |
| `tests/fixtures/policy/invalid-secret-value.yaml` | Forbidden literal credential field | Checker exit `1`; value redacted |
| Temporary fixture root with both active policy paths | Resolution precedence | `.agtoosa/policy.yaml` selected |
| Temporary fixture root with no active policy | Optional-policy behavior | Exit `0`; `policy_path=none` |

Temporary roots must be created outside the source fixture tree. Tests must not mutate the checked-in examples.

## TDD Evidence

### RED evidence — 2026-07-12T02:36Z

```
RED evidence — tasks 1.2 / 4.3 / 5.2
Command: bats tests/agtoosa.bats -f "DEV-059 GP-"
Exit code: 1 (nonzero; 8–9 failing before implementation)
Failure excerpt:
  not ok 1 DEV-059 GP-001: … `[ -f "$f" ]' failed
  not ok 2 DEV-059 GP-002: … `[ -f "$checker" ]' failed
  not ok 7 DEV-059 GP-007: … grep 'invalid optional policy' failed
Timestamp: 2026-07-12T02:36Z
```

### GREEN evidence — 2026-07-12T02:41Z

```
GREEN evidence — task 6.1 / GP-001–GP-009
Command: bats tests/agtoosa.bats -f "DEV-059 GP-"
Exit code: 0
Passing: 9/9
Excerpt: ok 1…ok 9 DEV-059 GP-001 … GP-009
Timestamp: 2026-07-12T02:41:38Z
```

```
GREEN evidence — policy checker
Command: bash docs/agtoosa-policy-check.sh --policy tests/fixtures/policy/valid.yaml
Exit code: 0
Excerpt: policy_path=tests/fixtures/policy/valid.yaml / policy: valid
Timestamp: 2026-07-12T02:41:38Z
```

```
GREEN evidence — verifier (missing policy not a finding)
Command: bash docs/agtoosa-verify.sh --root .
Exit code: 0
Excerpt: Gate 6 — Optional governance policy / PASS no extra policy configured / Result: ✅ PASS
Timestamp: 2026-07-12T02:41:38Z
```

## Evidence Status

RED evidence: recorded.
GREEN evidence: recorded.
Review evidence: recorded — `docs/archived/review-DEV-059.md` · `docs/archived/evidence-DEV-059.md` (2026-07-11 21:44; verdict PASS; bats DEV-059 exit 0).
Ship evidence: not recorded.
