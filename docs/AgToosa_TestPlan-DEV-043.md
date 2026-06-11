# Test Plan: DEV-043 - Brownfield Spec Drift Baseline

> **Spec:** `docs/archived/spec-DEV-043.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-043"`
> **Status:** ✅ Done

## Coverage Target

This plan proves DEV-043 as an agent-instructed brownfield baseline workflow. It preserves the competitive execution wave claim boundary and does not claim full static analysis or hosted drift detection.

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | BDB-001 | Docs/Integration | Canonical and template spec workflows define a brownfield current-state baseline with proof | yes |
| AC-002 | BDB-002 | Docs/Integration | Enforcement language is classified as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap | yes |
| AC-003 | BDB-002 | Docs/Integration | `docs/Master-Plan.md` / `Docs/Master-Plan.md` remain the repo-local source of truth for external integrations | yes |
| AC-004 | BDB-001, BDB-002, BDB-003 | Bats | Focused failing regression coverage was added before workflow edits | yes |
| AC-005 | BDB-003 | Evidence | Test plan records implementation evidence without broader static-analysis claims | yes |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-043"
bats tests/agtoosa.bats -f "DEV-042-060"
git diff --check
```

## Evidence

Brownfield baseline workflow implemented in `docs/AgToosa_Spec.md` and `template/Docs/AgToosa_Spec.md`.

Validation evidence:

```bash
bats tests/agtoosa.bats -f "DEV-043"
```

The baseline remains agent-instructed until a later story wires generator-enforced or CI-enforced drift checks.
