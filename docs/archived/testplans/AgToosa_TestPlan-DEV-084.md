# Test Plan: DEV-084 — Open-Source Sustainability and Support Boundary

> **Spec:** `docs/archived/spec-DEV-084.md`
> **Status:** 🟨 Build evidence recorded
> **Test prefix:** OSS
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Static OSS suite executed (RED then GREEN). OSS-007 live account-control confirmation remains manual.

## Coverage Target

Check that public repository guidance separates voluntary sponsorship, best-effort community support, private vulnerability reporting, sponsored educational content, and optional consulting while preserving equal open-source feature access and avoiding unsupported SLA language.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | OSS-001 | Voluntary Sponsorship No-Entitlement Boundary | Docs/claim boundary | Sponsor copy names the official destination and disclaims priority, timing, roadmap, private release, and feature entitlements | Pass `@smoke` |
| AC-002 | Must | OSS-002 | Support Channel Routing Matrix | Docs/security | Questions, bugs, proposals, and private vulnerabilities have distinct channels and submission guidance | Pass `@smoke` |
| AC-003 | Must | OSS-003 | Best-Effort No-SLA Language | Docs/contract | Public docs contain no unsupported acknowledgement, response, resolution, uptime, business-hour, or SLA promise | Pass `@smoke` |
| AC-004 | Must | OSS-004 | Commercial and Sponsored-Content Independence Disclosure | Docs/governance | Consulting and sponsored educational content identify payment/editorial boundaries and grant no governance, favorable evidence, security-order, or feature privilege | Pass |
| AC-005 | Must | OSS-005 | Open-Source Feature Parity | Scope/regression | No sponsor/client condition gates public features, releases, fixes, or workflow capabilities | Pass `@smoke` |
| AC-006 | Must | OSS-006 | Public Sustainability Surface Consistency | Docs/integration | Support, funding, security, README, and contribution surfaces use consistent links and boundaries | Pass |
| AC-001, AC-006 | Must | OSS-007 | Official Sponsor Destination Confirmation | Manual/external | Configured GitHub Sponsors destination is controlled by the maintainer and reachable at review time | Static metadata pass; live account-control `[manual-deferred]` |

## Planned Validation Commands

```bash
bats tests/agtoosa.bats -f "^DEV-084"
bats tests/agtoosa.bats -f "OSS-"
git diff --check
```

`OSS-007` requires manual external confirmation. Static checks validate repository metadata but cannot prove account control or Sponsors enablement.

## Smoke Set

- `OSS-001` — Voluntary Sponsorship No-Entitlement Boundary — **Pass**
- `OSS-002` — Support Channel Routing Matrix — **Pass**
- `OSS-003` — Best-Effort No-SLA Language — **Pass**
- `OSS-005` — Open-Source Feature Parity — **Pass**

Smoke status: **Pass** (2026-07-11).

## TDD Evidence

| Task group | RED evidence | GREEN evidence |
|------------|--------------|----------------|
| 1. Canonical boundary | Fail before SUPPORT.md rewrite | Pass after SUPPORT.md rewrite |
| 2. Public surface alignment | Fail on README/CONTRIBUTING links + SECURITY.md 48h claim | Pass after alignment |
| 3. Disclosure contract | Fail on missing OSS assertions / entitlement language | Pass — 7/7 DEV-084 |

### RED evidence — Wave 1 / 3.1 (before doc changes)

```
Command: bats tests/agtoosa.bats -f '^DEV-084'
Exit code: 1
Failure excerpt:
  not ok 1 ... OSS-001 ... grep -qi 'github sponsors|...' "$oss_support" failed
  not ok 3 ... OSS-003 ... grep -qi 'best.?effort|best effort' "$oss_support" failed
  not ok 6 ... OSS-006 ... grep -qE '...SUPPORT.md' "$oss_readme" failed
  not ok 7 ... OSS-007 ... grep -qi 'github.com/sponsors/sky2464' "$oss_support" failed
```

### GREEN evidence — after surface alignment

```
Command: bats tests/agtoosa.bats -f '^DEV-084'
Exit code: 0
Passing excerpt:
  ok 1 DEV-084 @smoke OSS-001: voluntary sponsorship no-entitlement boundary
  ok 2 DEV-084 @smoke OSS-002: support channel routing matrix
  ok 3 DEV-084 @smoke OSS-003: best-effort no-SLA language
  ok 4 DEV-084 OSS-004: commercial and sponsored-content independence disclosure
  ok 5 DEV-084 @smoke OSS-005: open-source feature parity
  ok 6 DEV-084 OSS-006: public sustainability surface consistency
  ok 7 DEV-084 OSS-007: official sponsor destination metadata
```

Regression: `bats tests/agtoosa.bats -f 'LG-005'` → exit 0 (preserves `public support channel` marker).

### OSS-007 manual note

- `.github/FUNDING.yml` configures `github: [sky2464]`.
- `curl -sI https://github.com/sponsors/sky2464` returned **HTTP 302** → `https://github.com/sky2464` (profile redirect). Static metadata is consistent; maintainer must confirm Sponsors is enabled and controlled before treating the destination as live.
- Deferred as `[manual-deferred: 2026-07-11]`.
