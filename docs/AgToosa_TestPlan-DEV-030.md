# Test Plan: DEV-030 — Fix `/agtoosa-update` self-target uncertainty

> **Spec:** `docs/archived/spec-DEV-030.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`, default 80% minimum)
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-030|source directory|Maintainer Dogfood"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | Canonical `AgToosa_Update.md` requires operating-context detection before drift-driven Apply planning | yes |
| AC-002 | T-002 | Integration | Canonical doc classifies Maintainer Dogfood via maintainer guide + generator surfaces (`agtoosa.sh`, `lib/`, `template/`) | yes |
| AC-003 | T-003 | Integration | Maintainer Dogfood branch stops before Apply and forbids downstream path prompt for current repo | yes |
| AC-004 | T-004 | Integration | Maintainer report states CLI update unavailable and lists maintainer-safe next actions | yes |
| AC-005 | T-005 | Integration | Generated Project Mode retains DEV-027 Detect → Plan → Apply → Verify and ask-then-apply | yes |
| AC-006 | T-006, T-010 | Integration | Bash blocks self-target with maintainer guidance (`agtoosa-maintainer.md`, no `Docs/`) | yes |
| AC-007 | T-008 | Integration | Update adapters route to canonical doc; no hand-edit override | yes |
| AC-008 | T-009, T-011 | Integration | Maintainer mirror + DEV-030 bats section registered | yes |
| AC-009 | T-010 (runtime) | Integration | Interactive install self-target output includes actionable maintainer guidance | no |
| AC-010 | T-007 | Integration | PowerShell self-target messages include guidance consistent with AC-006 (static grep) | no |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-001-N | Remove Stage 1a operating-context section from canonical update doc | T-001 fails |
| T-003-N | Remove stop-before-Apply or downstream-path prohibition in dogfood branch | T-003 fails |
| T-004-N | Remove CLI-unavailable or maintainer next-action wording | T-004 fails |
| T-005-N | Remove DEV-027 flow keywords from generated-project branch | T-005 fails; DEV-027 T-001 may fail |
| T-006-N | Revert Bash self-target to error-only without maintainer guidance | T-010/T-011 fail |
| T-007-N | Remove maintainer guidance strings from `agtoosa.ps1` | T-007 fails |
| T-008-N | Adapter instructs hand-sync or Apply against generator repo in dogfood | T-008 fails |

## Smoke Set

T-001, T-002, T-003, T-004, T-005, T-006, T-008, T-009

## Regression (DEV-027)

Run existing DEV-027 tests after DEV-030 changes:

```bash
bats tests/agtoosa.bats -f "T-00[1-9]:"
```

## Commands

```bash
# Narrow DEV-030 + self-target guidance
bats tests/agtoosa.bats -f "DEV-030|source directory|Maintainer Dogfood"

# Broader update regression (per spec proof)
bats tests/agtoosa.bats -f "agtoosa-update|source directory|Maintainer Dogfood|DEV-027|DEV-030"

# Full regression after targeted pass
bats tests/agtoosa.bats
```

## Evidence (build)

| Test ID | Bats test name | Result |
|---------|----------------|--------|
| T-001 | `DEV-030 T-001: canonical update requires operating context before drift Apply` | pass |
| T-002 | `DEV-030 T-002: canonical update classifies Maintainer Dogfood via maintainer guide and generator surfaces` | pass |
| T-003 | `DEV-030 T-003: Maintainer Dogfood stops before Apply and forbids downstream path prompt` | pass |
| T-004 | `DEV-030 T-004: Maintainer report states CLI update unavailable and lists next actions` | pass |
| T-005 | `DEV-030 T-005: Generated Project retains DEV-027 Detect Plan Apply Verify flow` | pass |
| T-006 | `DEV-030 T-006: maintainer mirror documents operating context with docs paths` | pass |
| T-007 | `DEV-030 T-007: PowerShell self-target messages include maintainer guidance` | pass |
| T-008 | `DEV-030 T-008: update adapters route to canonical AgToosa_Update without overriding dogfood stop` | pass |
| T-009 | `DEV-030 T-009: maintainer AgToosa_Update.md mirrors operating-context stop` | pass |
| T-010 | `DEV-030 T-010: bash self-target helper documents maintainer guidance strings` | pass |
| T-011 | `DEV-030 T-011: DEV-030 section registered in bats file` | pass |
| (runtime) | `self-targeting interactive install includes maintainer guidance` | pass (after review fix: `_print_self_target_guidance` on interactive install path) |
| (runtime) | `--update on AgToosa source directory includes maintainer guidance` | pass |

**Regression:** DEV-027 T-001–T-009 — 9/9 pass. **Full suite:** 324/324 pass.
