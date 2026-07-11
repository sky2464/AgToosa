# Test Plan: DEV-050 — Cross-Model Review Gate

> **Spec:** `docs/archived/spec-DEV-050.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-050"`
> **Status:** ✅ Done

## Coverage Target

80% — focused contract tests on docs, config inventory, and adapter routing (no live multi-model API calls).

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | CM-001 | Integration | `AgToosa_CrossModelReview.md` exists in template + docs mirrors; defines writer/reviewer roles, triggers, evidence schema, merge rules, fallbacks | yes @smoke |
| AC-002 | CM-002 | Integration | Review doc + cross-model agent state read-only reviewer guarantee (no silent write instructions) | yes @smoke |
| AC-003 | CM-003 | Integration | Evidence block fields include Specialist schema + cross-model extensions (`Reviewer identity`, `Model/platform`, `Confidence tier`) | yes |
| AC-004 | CM-004 | Integration | Review or Specialists doc includes parallel subagent path AND sequential fallback note verbatim | yes @smoke |
| AC-005 | CM-005 | Integration | Review doc strongly recommends cross-model for security/registry/auth-tier stories or documents skip rationale requirement | yes |
| AC-006 | CM-006 | Integration | Specialists doc documents `review` phase_hook orchestration with trigger matching | yes |
| AC-007 | CM-003 | Integration | Merge rules tag confidence tiers (`both-models`, `reviewer-only`, `writer-only`, `virtual-persona-only`) | yes |
| AC-008 | CM-001 | Integration | Fallback chain documented: cross-platform, sequential personas, explicit skip | yes |
| AC-009 | CM-001 | Bats | `lib/config.sh` registers `AgToosa_CrossModelReview.md` and `agtoosa-cross-model-reviewer.agent.md` | yes @smoke |
| AC-010 | CM-002 | Integration | `AgToosa_Review.md` lists `cross-model` sub-command and routes to canonical doc | yes @smoke |
| AC-011 | CM-005 | Docs | `AgToosa_Evidence.md` allows cross-model evidence row | yes |
| AC-012 | CM-001–CM-007 | Bats | Full DEV-050 filter green; adapter parity spot-check | yes @smoke |

## Negative / Edge Scenarios

| Scenario | Test ID | Expected |
|----------|---------|----------|
| Adapter duplicates full gate contract instead of routing | CM-002 | Adapter references `AgToosa_CrossModelReview.md`; no conflicting writer/reviewer rules |
| `agtoosa-*` shadowing for cross-model agent id | CM-001 | Agent file named `agtoosa-cross-model-reviewer` is lifecycle adapter, not project specialist |
| Missing maintainer mirror | CM-001 | `docs/AgToosa_CrossModelReview.md` exists when template copy exists |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-050"
bats tests/agtoosa.bats -f "CM-"
git diff --check
```

## Evidence

Record implementation evidence in this file and `docs/archived/evidence-DEV-050.md` at review/ship time.

### RED evidence — DEV-050

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-050"` (Wave 1, before implementation) |
| Exit code | 1 |
| Pass/fail | FAIL — 3 fail / 3 pass (CM-001–CM-003 failing; CM-004–CM-006 passing on partial wiring) |
| Failure excerpt | CM-001: missing `AgToosa_CrossModelReview.md`; CM-002: Review doc lacked `cross-model` routing; CM-003: evidence block fields absent |
| Recorded | 2026-07-11 |

### GREEN evidence — DEV-050

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-050"` |
| Exit code | 0 |
| Pass/fail | PASS — 8/8 (CW-013, CM-001–CM-007) |
| Verifier | `bash docs/agtoosa-verify.sh` → PASS |
| Recorded | 2026-07-11 |
