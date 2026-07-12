# Test Plan: DEV-109 — Lifecycle Next-Step Sync + Multi-Spec Clarity

> **Spec:** `docs/archived/spec-DEV-109.md`  
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-109\\|LNS-"`  
> **Status:** ⬜ Spec draft — awaiting approval  
> **Coverage target:** 80% focused contract tests (docs + CLI + PS1 greps)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | LNS-001 | Integration | Spec/Build/Review/Ship docs require primary lifecycle `Next:` line (not status as headline) | yes |
| AC-002 | LNS-002 | Integration | Dual-line close includes canonical `SYNC:` format string | yes |
| AC-003 | LNS-003 | Integration | `agtoosa.sh --status-line` wired; `run_status_line` exists; help mentions flag | yes |
| AC-004 | LNS-004 | Integration | `agtoosa.ps1` exposes `-StatusLine` and help text | yes |
| AC-005 | LNS-005 | Integration | SPEC-FORMAT / Master-Plan template document Clarity tags + aliases | yes |
| AC-006 | LNS-006 | Integration | Spec.md defines multi-spec intake (map → confirm → size path) | yes |
| AC-007 | LNS-007 | Integration | Spec.md blocks detailed spec finalize while `needs-interview` / `N-CI` | yes |
| AC-008 | LNS-008 | Integration | Spec/Agent docs define soft cap 8/+4 with repeating +4 on free-text directions | yes |
| AC-009 | LNS-009 | Integration | Old status-only closure demoted/replaced in canonical Output sections | yes |
| AC-010 | LNS-010 | Integration | help-next / Status empty-state prefer lifecycle language | no |
| AC-011 | LNS-001–LNS-010 | Bats | Full DEV-109 / LNS filter green | yes |
| AC-012 | LNS-001–LNS-010 | Bats | RED then GREEN evidence recorded below | yes |

## Negative / edge (Must ACs)

| AC | Negative scenario | Test ID |
|----|-------------------|---------|
| AC-003 | Missing Master-Plan → nonzero exit, no fake SYNC success | LNS-003n |
| AC-005 | Unknown tag rejected or normalized only from alias set | LNS-005n |
| AC-007 | Attempt to write detailed spec under `needs-interview` without interview — docs forbid | LNS-007 |
| AC-008 | Hard-stop-only budget wording absent; repeating +4 present | LNS-008 |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-109"
bats tests/agtoosa.bats -f "LNS-"
bash agtoosa.sh --status-line .
git diff --check
```

## Evidence

### RED evidence

_Pending `/agtoosa-build` — expect LNS tests to fail until dual-line docs, status-line CLI, and adapter updates land._

### GREEN evidence

_Pending `/agtoosa-build`._
