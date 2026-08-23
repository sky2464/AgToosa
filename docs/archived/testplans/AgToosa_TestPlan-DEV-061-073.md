# Test Plan — DEV-061…DEV-073 (Proof engine, supply chain, correctness wave)

> Spec reference: wave scoped from the deep-review top-20 (2026-06-09); per-story rows in `docs/Master-Plan.md` Active Cycle.
> Run: `bats tests/agtoosa.bats -f "DEV-061|DEV-064|DEV-065|DEV-066|DEV-067|DEV-068|DEV-069|DEV-070|DEV-071|DEV-072|DEV-073|DEV-060 WC-011|DEV-054 PS"`

## AC coverage table

| Story | Test ID | Category | Covers |
|-------|---------|----------|--------|
| DEV-061 | VF-001 | Integration | Verifier passes on this repo (self-dogfood) |
| DEV-061 | VF-002 | Integration (negative) | Active story without spec → exit 1 with named finding |
| DEV-061 | VF-003 | Integration | `agtoosa.sh --verify <path>` dispatches the verifier |
| DEV-061 | VF-004 | Integration | `stats` mode reports Update Log analytics |
| DEV-061 | VF-005 | Unit | Verifier/Quickref/gate example registered in template lists |
| DEV-064 | SC-001 | Security (negative) | Tar-slip archive rejected before extraction; no file escapes |
| DEV-065 | SC-002 | Security (negative+positive) | Unverified pack blocked; `--allow-unverified` opt-in works |
| DEV-065 | SC-003 | Security/UX | Preview shows file tree + AI-instruction-surface warnings |
| DEV-065 | SC-004 | Security (negative) | Merge denylist blocks `.claude/settings.json`, `.github/workflows/` |
| DEV-066 | SC-005 | Security | Pinned tags fail closed; no branch fallback; safe-archive wired |
| DEV-066 | SC-006 | Security (negative) | `--sha256` mismatch aborts bootstrap |
| DEV-066 | SC-007 | Release hygiene | Formula pinned to tag tarball + sha256; npm version parity |
| DEV-071 | NI-001 | Integration | `--path/--platforms/--yes` full non-interactive install |
| DEV-071 | NI-002 | Unit (negative) | Unknown platform token rejected |
| DEV-073 | DR-001 | Integration | Doctor healthy on fresh install; fails on missing install |
| DEV-073 | UN-001 | Integration | Uninstall removes owned files, preserves user data |
| DEV-067 | WC-001 | Docs contract | RED/GREEN evidence gate; no `git add -p`; wave execution |
| DEV-067 | WC-002 | Docs contract | Non-interactive squash; evidence-based deploy; QA + verifier ship rows; log rotation; capability-delta merge |
| DEV-067 | WC-003 | Docs contract | Revert mandates backup branch, revert-first, confirmation for reset --hard |
| DEV-068 | WC-004 | Docs contract (negative) | Copilot instructions no longer invert PM source of truth |
| DEV-068 | WC-005 | Docs parity | All 6 entry points expose `zoom-out` + `amend` |
| DEV-072 | WC-006 | Docs contract | `/agtoosa-spec amend`, Spec Revision Log, Capability Delta in SPEC-FORMAT |
| DEV-069 | WC-007 | Docs contract | Governance abort strings wired into Review + Ship prerequisites |
| DEV-069 | WC-008 | Docs contract | Master-Plan template hosts Active Diagnosis/Hypotheses; unified spec links |
| DEV-070 | WC-009 | Docs contract | Quickref ≤90 lines; cursor core rule `alwaysApply: false`; `tdd: true` default |
| DEV-063 | WC-010 | Docs contract | `agtoosa-events.jsonl` contract in Build/Ship/Agent/Quickref |
| DEV-060 | WC-011 | Docs | Benchmark suite + enforcement comparison published and README-linked |
| DEV-065 | PS-001 | Security (PS1) | PowerShell install blocks unverified packs |
| DEV-065/064 | PS-002 | Security (PS1) | PS1 defines and wires Test-SafeTarArchive / Test-PackFiles / Test-PackPathDenied |

## TDD evidence

RED evidence — wave (representative; gate checks added before implementation fixes)
Command: `bats tests/agtoosa.bats -f "DEV-038 DH-001"` (after pinning the formula, before updating the assertion)
Exit code: 1
Failure excerpt: ``grep -q "branch: \"main\"" "$formula"` failed` — the legacy assertion encoded the unpinned (insecure) state; test updated to require tag+sha256 pinning.

GREEN evidence — wave
Command: `bats tests/agtoosa.bats -f "DEV-061|DEV-064|DEV-065|DEV-066|DEV-067|DEV-068|DEV-069|DEV-070|DEV-071|DEV-072|DEV-073|DEV-060 WC-011|DEV-054 PS"`
Exit code: 0 (29/29)

Verifier self-run: `bash docs/agtoosa-verify.sh --root .` → `Result: ✅ PASS` (15 pass · 5 warn · 0 fail).

## Validation evidence

- Focused new-wave bats: 29/29 green (2026-06-09).
- Registry slice: 28/28 green after containment changes.
- Pack/merge slice: green (PK1–PK5 + WP-002/003 unchanged behavior for legit packs).
- ShellCheck: clean with project exclusions on `agtoosa.sh`, `bootstrap.sh`, `lib/*.sh`.
- Full suite: run `bats tests/agtoosa.bats` (see Master-Plan Update Log for the final count of the wave session).

## Smoke set

@smoke VF-001 (verifier PASS on repo) · @smoke SC-002 (verified-flag gate) · @smoke NI-001 (non-interactive install) · @smoke SC-005 (fail-closed pinning)
