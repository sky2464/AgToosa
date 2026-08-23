# Test Plan: DEV-151 — Tracker Publish CI Automation

| AC | Test ID | Description | Type | Expected |
|----|---------|-------------|------|----------|
| AC-001 | GIA-001 | issues-sync.yml runs GIP bats before live sync | Contract | bats step precedes gh sync |
| AC-002 | GIA-002 | pull_request trigger on Master-Plan.md | Contract | PR job present |
| AC-002 | GIA-003 | PR job has no live gh upsert | Contract | dry-run + bats only |
| AC-003 | GIA-004 | checkout SHA pinned to maintainer standard | Contract | matches ci.yml pin |
| AC-004 | GIA-005 | release-advanced post-ship sync job | Contract | sync-issues-post-ship job |
| AC-005 | GIA-006 | post-ship continue-on-error | Contract | continue-on-error: true |
| AC-006 | GIA-007 | README commit uses [skip ci] | Contract | message pattern |
| AC-007 | GIA-008 | template workflow example parity | Contract | example mirrors maintainer |

Smoke: `bats tests/agtoosa.bats -f "DEV-151|GIA-"`
