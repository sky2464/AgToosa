# Test Plan: DEV-089 — Evidence-Profile Verifier Gates

> **Spec:** `docs/archived/spec-DEV-089.md`
> **Status:** 🟦 Planned — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `EPV`

## Scope

Deterministic, fixture-based coverage for verifier Gate 7: gate ordering after Gate 6, opt-in profile health, valid/invalid profile handling, classification honesty, no-false-SAST-claims output, DEV-049 ledger WARN, and strict-mode promotion. No network or LLM calls.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | EPV-001 | Gate 6 precedes Gate 7 in verifier output | Integration | Gate 6 section appears before Gate 7; lifecycle gates follow Gate 7 | ⬜ Planned |
| AC-002 | EPV-002 | Absent evidence profile is healthy | Integration/fixture | Exit 0; `no evidence profile configured`; zero Gate 7 findings | ⬜ Planned `@smoke` |
| AC-003 | EPV-003 | Valid profile checks required entries deterministically | Fixture | Present artifacts pass; missing artifact WARNs with rule id and path | ⬜ Planned `@smoke` |
| AC-004 | EPV-004 | Guided rows are not upgraded to enforced | Contract/negative | Fixture with `guided` STRIDE row does not FAIL without wired command | ⬜ Planned |
| AC-005 | EPV-005 | SAST rows never claim vulnerability absence | Security/negative | Output contains presence/exit-code only; bans phrases like `no vulnerabilities` / `SAST clean` | ⬜ Planned `@smoke` |
| AC-006 | EPV-006 | Missing ledger emits WARN not FAIL | Integration/fixture | Profile requires ledger; absent `evidence-*.md` → WARN cites DEV-049 | ⬜ Planned |
| AC-007 | EPV-007 | Invalid evidence.yml emits bounded WARN | Negative fixture | Malformed YAML → WARN with rule/field; verifier continues | ⬜ Planned |
| AC-008 | EPV-008 | Strict mode promotes Gate 7 WARN to FAIL | Regression | `--strict` with profile WARN → exit 1 | ⬜ Planned |
| AC-009 | EPV-009 | DEV-089 filter documents RED/GREEN boundary | Meta | Bats filter exists; no hosted-audit claims in test names | ⬜ Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Profile names unknown profile key | EPV-007 | WARN names profile; no crash |
| Security-sensitive profile with scan log missing | EPV-003 | WARN on artifact; no semantic security claim |
| Ledger present but incomplete rows | EPV-006 | WARN or pass per contract row mapping — not FAIL |
| `command` field contains shell metacharacters | EPV-007 | Checker rejects or ignores; no execution |
| Gate 6 invalid policy + Gate 7 valid profile | EPV-001 | Both gates run; ordering preserved |

## Smoke Set

- `@smoke EPV-002` — absent profile is healthy.
- `@smoke EPV-003` — valid profile deterministic checks.
- `@smoke EPV-005` — no false SAST claims in output.
- `@smoke EPV-001` — gate order regression guard.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-089|EPV-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Fixture-based RED coverage | `bats tests/agtoosa.bats -f "DEV-089\|EPV-"` | 1 | `not ok EPV-001: Gate 7` missing; `not ok EPV-002: no evidence profile` grep failed |
| 2. Implement Gate 7 | `bats tests/agtoosa.bats -f "EPV-001\|EPV-003\|EPV-005\|EPV-006"` | 1 | Gate 7 block absent; SAST wording not bounded |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1–2. Full EPV suite | `bats tests/agtoosa.bats -f "DEV-089\|EPV-"` | 0 | `ok 1` through `ok 9` — all EPV tests pass |
| 3. Verifier self-dogfood | `bash docs/agtoosa-verify.sh --root .` | 0 | Gate 7 `no evidence profile configured` on maintainer repo |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-089\|EPV-"` | 0 | RED/GREEN rows recorded; no SAST overclaim strings in fixtures |
