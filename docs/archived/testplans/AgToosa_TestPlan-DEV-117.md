# Test Plan: DEV-117 — Cycle Continuity Guard

> **Spec:** `docs/archived/spec-DEV-117.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f 'DEV-117|CCG-'`
> **Status:** ✅ Build complete — focused suite green; accepted baseline documented
> **Coverage target:** 100% Must AC mapping; deterministic verifier checks and status-contract greps

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | CCG-001 | Integration | Explicit `Cycle state: Idle` empty cycle is recognized as intentional. | yes |
| AC-002 | CCG-004 | Integration | Template Master Plan exposes the bounded `Cycle state` vocabulary and default idle form. | yes |
| AC-003 | CCG-001 | CLI | Default verifier passes explicit idle without `G3-idle`. | yes |
| AC-003 | CCG-002 | CLI | Strict verifier also passes explicit idle without `G3-idle`. | yes |
| AC-004 | CCG-003 | CLI | Unmarked empty cycle retains guided `G3-idle` warning. | yes |
| AC-005 | CCG-005 | Integration | Status mirrors classify explicit idle as Info with no empty-cycle Plan Completeness deduction. | yes |
| AC-006 | CCG-005 | Integration | Status mirrors retain independent warning and scoring rules for stale/backlog/git risk. | yes |
| AC-007 | CCG-005 | Bats | Both verifier/status mirrors contain the shared Idle contract; the named CCG filter discovers the complete suite. | yes |
| AC-008 | CCG-001–CCG-005 | Bats | RED and GREEN evidence is captured truthfully. | yes |

## Negative / Edge Scenarios

| AC | Scenario | Test ID |
|----|----------|---------|
| AC-003 | A warning-free explicitly Idle fixture remains successful under `--strict` and does not emit `G3-idle`. | CCG-002 |
| AC-004 | Placeholder-only Active Cycle without `Cycle state: Idle` must not pass silently. | CCG-003 |
| AC-006 | The status contract retains high-priority backlog, stale Update Log, git, blocked, and orphan findings while Idle. | CCG-005 |

## Validation Commands

```bash
bats tests/agtoosa.bats -f 'DEV-117|CCG-'
bats tests/agtoosa.bats -f "CCG-"
bash docs/agtoosa-verify.sh --root <idle-fixture>
bash docs/agtoosa-verify.sh --strict --root <idle-fixture>
git diff --check
```

## Evidence

### RED evidence

RED evidence — DEV-117 / CCG-001–CCG-005
Command: `bats tests/agtoosa.bats -f "DEV-117"`
Exit code: 1
Failure excerpt:

```text
not ok 1 CCG-001: explicit Idle still emitted G3-idle
not ok 2 CCG-002: strict verifier exited nonzero for explicit Idle
not ok 4 CCG-004 / not ok 5 CCG-005: Cycle state and mirror contracts absent
```

Baseline: 1 passed, 4 failed. The unmarked-empty guard (`CCG-003`) already passed, proving the regression test preserves the existing warning boundary.

### GREEN evidence

GREEN evidence — 1.1
Command: `bats tests/agtoosa.bats -f "CCG-004"`
Exit code: 0
Result: 1 test passed; generated and maintainer Master Plans expose the bounded cycle-state contract.

GREEN evidence — 2.1
Command: `bats tests/agtoosa.bats -f "CCG-00[1-3]"`
Exit code: 0
Result: 3 tests passed; explicit Idle passes default and strict modes, while unmarked empty cycles retain `G3-idle`.

Lint: `shellcheck -e SC2034 template/Docs/agtoosa-verify.sh docs/agtoosa-verify.sh` passed. Plain shellcheck reports the pre-existing mirrored `SC2034` for `epv_out` outside the DEV-117 diff; accepted as existing debt, not suppressed in source.

GREEN evidence — 3.1
Command: `bats tests/agtoosa.bats -f "CCG-005"`
Exit code: 0
Result: 1 test passed; status and verifier mirrors share the neutral Idle contract, with independent findings retained.

GREEN evidence — 4.1
Command: `bats tests/agtoosa.bats -f "DEV-117"`
Exit code: 0
Result: 5 tests passed (`CCG-001`–`CCG-005`).

Regression command: `bats tests/agtoosa.bats -f "DEV-061|DEV-088|DEV-089|DEV-117|D1:|MD1:|MD4:|LNS-010"`
Exit code: 0
Result: 37 tests passed.

Build discovery: the first regression run exposed two stale DEV-088 assertions. `VFJ-004` expected state absence despite DEV-093 requiring install-time `.agtoosa/state.json`; `VFJ-009` expected doctor exit 0 despite documented warning exit 1 on uninitialized placeholders. Both test-only assertions were corrected and passed individually and in the 37-test sequence; runtime behavior was unchanged.

## Comprehensive Validation

| Check | Result |
|-------|--------|
| DEV-117 focused bats | PASS — 5/5 |
| Verifier/status regression set | PASS — 37/37 |
| Full bats suite | ACCEPTED BASELINE — 918/973 passed; 55 pre-existing, unrelated failures; all DEV-117 tests passed |
| Bash syntax | PASS — verifier mirrors |
| ShellCheck | PASS with pre-existing `SC2034` excluded; warning is outside DEV-117 diff |
| Verifier mirror parity | PASS — template and maintainer scripts byte-identical |
| Secret-pattern scan | PASS — no bounded credential patterns in DEV-117 diff |
| Self-verifier | PASS — 13 pass, 1 pre-existing `G2-log-bloat` warning, 0 fail |

Full-suite baseline classification: representative failures are present at pre-story commit `8c4c4ab`, including tests pinned to `5.3.26` while that commit already declares `5.3.28`, superseded Natural Language Intent Map assertions after DEV-116, and pack tests calling the pre-existing unsourced `apply_verbose_echo` helper. No full-suite failure references `CCG-*` or a DEV-117 acceptance criterion. These failures are accepted as pre-existing evidence, not repaired or counted as DEV-117 GREEN.

Security and supply-chain scope: no dependencies, service endpoint, IaC, or package lock changed. DAST, dependency audit, IaC scan, and SBOM generation are not applicable. Gitleaks, Semgrep, Checkov, Syft, and Trivy were unavailable; ShellCheck and the bounded diff secret scan were run locally.

## Ship-Gate Follow-Up Evidence

RED evidence — 5.1
Command: `count=$(rg -c '@test "DEV-117 @smoke CCG-' tests/agtoosa.bats); test "$count" -eq 5`
Exit code: 1
Failure excerpt: `smoke_count=4 expected=5`

GREEN evidence — 5.1
Command: `count=$(rg -c '@test "DEV-117 @smoke CCG-' tests/agtoosa.bats); test "$count" -eq 5`
Exit code: 0
Result: 5 DEV-117 CCG tests are tagged `@smoke`; AC-005 through AC-007 now have the tagged CCG-005 path required by ship readiness.

Focused command: `bats tests/agtoosa.bats -f 'DEV-117|CCG-'`
Exit code: 0 — 5/5 passed.

Smoke-only command: `bats tests/agtoosa.bats -f '@smoke CCG-'`
Exit code: 0 — 5/5 passed.

Adjacent regression command: `bats tests/agtoosa.bats -f 'DEV-061|DEV-088|DEV-089|DEV-117|D1:|MD1:|MD4:|LNS-010'`
Exit code: 0 — 37/37 passed.
