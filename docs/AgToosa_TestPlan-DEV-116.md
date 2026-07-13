# Test Plan: DEV-116 — AgToosa Lifecycle Compass

> **Spec:** `docs/archived/spec-DEV-116.md`  
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-116\\|CMP-"`  
> **Status:** 🟦 Awaiting spec approval — RED expected before build  
> **Coverage target:** Contract greps (docs + core rules + optional JSON CLI)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | CMP-001 | Integration | Agent.md defines Lifecycle Compass preamble with mandatory `--status-line` and ANCHOR | yes |
| AC-002 | CMP-002 | Integration | Semantic intent classes replace NL Intent Map phrase-only table | yes |
| AC-003 | CMP-003 | Integration | Branded `Compass: soft →` line documented | yes |
| AC-004 | CMP-004 | Integration | Hard gate `**AgToosa Lifecycle Compass**` + `ANCHOR:` documented | yes |
| AC-005 | CMP-005 | Integration | Tributary `serving <phase>` + `When done: return to` documented | no |
| AC-006 | CMP-001 | Integration | Intent × SYNC mismatch stop documented in reconciliation matrix | yes |
| AC-007 | CMP-001 | Integration | Single multiple-choice disambiguation rule documented | no |
| AC-008 | CMP-003 | Integration | Explicit `/agtoosa-*` bypasses Compass ceremony | no |
| AC-009 | CMP-006 | Integration | Phase Stop preserved — no auto-chain after Compass | yes |
| AC-010 | CMP-002 | Integration | `agtoosa-core.mdc` + maintainer core include Compass summary | yes |
| AC-011 | CMP-004 | Integration | Quickref / CLAUDE / AGENTS use Lifecycle Compass branding | no |
| AC-012 | CMP-007 | CLI | `--route-hint --format json` emits `anchor`, `sync`, task counts | no |
| AC-013 | CMP-001–CMP-007 | Bats | Full DEV-116 / CMP filter green | yes |
| AC-014 | CMP-001–CMP-007 | Bats | RED then GREEN evidence recorded below | yes |

## Negative / edge (Must ACs)

| AC | Negative scenario | Test ID |
|----|-------------------|---------|
| AC-002 | Phrase-only NL Intent Map remains without Compass section — forbidden | CMP-002 |
| AC-009 | Compass documents auto-run `/agtoosa-build` after hard confirm — forbidden | CMP-006 |
| AC-010 | Core rule missing `ANCHOR` or `--status-line` mandatory read — fail | CMP-002 |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-116"
bats tests/agtoosa.bats -f "CMP-"
bash agtoosa.sh --status-line . --route-hint --format json   # after AC-012 ships
git diff --check
```

## Evidence

### RED evidence

2026-07-12 — Before implementation: NL Intent Map phrase table present; no Lifecycle Compass section; no CMP bats. Expected failures on first `bats -f DEV-116` run.

### GREEN evidence

_(Record after build completes.)_
