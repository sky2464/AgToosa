# Test Plan: DEV-149 — Issues-Sync Dry-Run README Corruption (+ piped-bootstrap extension)

> **Spec:** `docs/archived/spec-DEV-149.md`
> **Status:** 🏁 Shipped — v0.3.60 (original); extended v0.3.62
> **Created:** 2026-08-27 (retroactive backfill; original fix shipped 2026-08-01 via PR #92, extension shipped 2026-08-02 as v0.3.62)
> **Test prefix:** `GIS` (README marker guard) · `B33` (piped bootstrap `/dev/tty` prompt hardening, DEV-149 extension)

## Scope

Two related but distinct fixes tracked under one DEV ID:

1. **Original (v0.3.60):** `agtoosa-issues-sync.sh --dry-run` was mutating `README.md`, and repeat `--tracker publish --readme` runs could duplicate the `AGTOOSA-ROADMAP:END` marker.
2. **Extension (v0.3.62):** `agtoosa_prompt_read()` hardened for three stdin modes (TTY, `curl | bash` pipe, non-TTY/non-pipe) so pipe-based bootstrap installs don't silently fail or read EOF instead of prompting.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | GIS-011 | `issues-sync --dry-run` does not mutate README | Regression | README md5 unchanged before/after dry-run | ✅ |
| AC-002 | GIS-012 | `publish --readme` repeat update keeps single END marker | Regression | Exactly one `AGTOOSA-ROADMAP:END` after two consecutive publishes | ✅ |
| AC-003 | B33-001 | `agtoosa_prompt_read` uses `/dev/tty` when stdin is not a TTY | Contract | `lib/config.sh` defines `_agtoosa_tty_usable`, checks `-t 0`, falls to `/dev/tty` | ✅ |
| AC-004 | B33-002 | Install wizard documents `.` and Enter for current folder | Contract | Prompt copy present in `agtoosa.sh` | ✅ |
| AC-005 | B33-003 | Install wizard routes interactive reads through `agtoosa_prompt_read` | Contract | No raw `read -rp "Project path:"` remaining | ✅ |
| AC-006 | B33-004 | Maintain flows (`reinstall.sh`, `cleanup.sh`, `maintain.sh`) route path prompts through `agtoosa_prompt_read` | Contract | No raw `read -rp` for project path in those files | ✅ |
| AC-007 | B33-005 | PowerShell install uses host-console `Read-AgToosaPrompt` | Contract | `agtoosa.ps1` defines and calls `Read-AgToosaPrompt` | ✅ |
| AC-008 | B33-006 | `agtoosa_prompt_read` accepts piped answers to a script file (non-bootstrap case) | Regression | `printf ... \| bash script.sh` still reads the piped answer, not `/dev/tty` | ✅ |

## Smoke Set

- `@smoke GIS-011`, `@smoke GIS-012` — README-mutation regressions.

Smoke command: `bats tests/agtoosa.bats -f "DEV-139 GIS-01[12]|DEV-149"`

## Spec Quality Analyzer Evidence

- Original-scope Must ACs (AC-001, AC-002) map to GIS-011/012.
- Extension-scope Must ACs (AC-003–AC-008) map to B33-001–006.
- `GIS-011`/`GIS-012` are tagged `DEV-139` in `tests/agtoosa.bats` (shared file with the broader GitHub Issues PM Bridge epic) rather than `DEV-149` — noted here rather than re-tagged, consistent with the DEV-148 backfill's treatment of similar pre-existing ID drift.
