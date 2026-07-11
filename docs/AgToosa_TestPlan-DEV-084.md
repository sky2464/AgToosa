# Test Plan: DEV-084 — Open-Source Sustainability and Support Boundary

> **Spec:** `docs/archived/spec-DEV-084.md`
> **Status:** ⬜ Backlog
> **Test prefix:** OSS
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Not run; this plan contains no support, sponsorship, or external-link evidence.

## Coverage Target

Check that future public repository guidance separates voluntary sponsorship, best-effort community support, private vulnerability reporting, sponsored educational content, and optional consulting while preserving equal open-source feature access and avoiding unsupported SLA language.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | OSS-001 | Voluntary Sponsorship No-Entitlement Boundary | Docs/claim boundary | Sponsor copy names the official destination and disclaims priority, timing, roadmap, private release, and feature entitlements | Planned — not run `@smoke` |
| AC-002 | Must | OSS-002 | Support Channel Routing Matrix | Docs/security | Questions, bugs, proposals, and private vulnerabilities have distinct channels and submission guidance | Planned — not run `@smoke` |
| AC-003 | Must | OSS-003 | Best-Effort No-SLA Language | Docs/contract | Public docs contain no unsupported acknowledgement, response, resolution, uptime, business-hour, or SLA promise | Planned — not run `@smoke` |
| AC-004 | Must | OSS-004 | Commercial and Sponsored-Content Independence Disclosure | Docs/governance | Consulting and sponsored educational content identify payment/editorial boundaries and grant no governance, favorable evidence, security-order, or feature privilege | Planned — not run |
| AC-005 | Must | OSS-005 | Open-Source Feature Parity | Scope/regression | No sponsor/client condition gates public features, releases, fixes, or workflow capabilities | Planned — not run `@smoke` |
| AC-006 | Must | OSS-006 | Public Sustainability Surface Consistency | Docs/integration | Support, funding, security, README, and contribution surfaces use consistent links and boundaries | Planned — not run |
| AC-001, AC-006 | Must | OSS-007 | Official Sponsor Destination Confirmation | Manual/external | Configured GitHub Sponsors destination is controlled by the maintainer and reachable at review time | Planned — not run |

## Planned Validation Commands

These commands are illustrative future commands only; they were not executed while creating this plan.

```bash
bats tests/agtoosa.bats -f "DEV-084"
bats tests/agtoosa.bats -f "OSS-"
git diff --check
```

`OSS-007` requires manual external confirmation. Static checks can validate repository metadata but cannot prove account control or availability.

## Smoke Set

- `OSS-001` — Voluntary Sponsorship No-Entitlement Boundary
- `OSS-002` — Support Channel Routing Matrix
- `OSS-003` — Best-Effort No-SLA Language
- `OSS-005` — Open-Source Feature Parity

Smoke status: **Planned — not run**.

## TDD Evidence Placeholders

| Future task group | RED evidence | GREEN evidence |
|-------------------|--------------|----------------|
| 1. Canonical boundary | Not run; no failing output recorded | Not run; no passing output recorded |
| 2. Public surface alignment | Not run; no failing output recorded | Not run; no passing output recorded |
| 3. Disclosure contract | Not run; no failing output recorded | Not run; no passing output recorded |

### RED evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Failure excerpt: Not recorded
- Required future action: add OSS wording and cross-surface assertions before changing the public documents.

### GREEN evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Passing excerpt: Not recorded
- Required future action: record exact checks and manual sponsor confirmation only after all public surfaces align.

No evidence may be inferred from the existence of this test plan.
