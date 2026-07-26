# ADR-018: Recoverable Project Transaction Journal

**Status**: Proposed  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review (DEV-119 spec)

## Context

DEV-092 stages generator apply outside the project tree and commits file-by-file. A failure during the commit loop can leave some targets updated while others remain stale — violating the all-or-nothing operator expectation. DEV-093 records operational state only after a successful apply. Operators need a deterministic, local recovery path without databases, git automation, or agent-runtime sandboxing.

## Decision

Introduce a **gitignored transaction journal** under `.agtoosa/transactions/<transaction-id>/` that records pre-image snapshots (or `absent` markers) for every generator-orchestrated path before mutation, rolls back on late-commit failure, and exposes `agtoosa.sh --transaction-recover` for manual recovery of incomplete transactions.

## Rationale

- Journals are filesystem-local, auditable, and align with existing `.agtoosa/` operational surfaces.
- Pre-image capture closes the gap between staging success and partial commit failure.
- Recovery stays explicit CLI — not automatic git revert (non-goal).
- Agent-driven workflow edits remain out of scope (DEV-123).

## Consequences

### Positive

- Failed installs/updates can be restored without manual diff archaeology.
- Bats can inject late failures and assert deterministic tree hash recovery.
- Composes with DEV-092 idempotency and DEV-093 state writes.

### Negative

- Extra disk use for backups during apply.
- Journal retention policy must be documented to avoid unbounded growth.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Two-phase rename entire tree | Cross-filesystem and Windows parity cost; does not cover per-file merge modes |
| Git stash / auto-revert | Violates non-goal; surprises users with git mutations |
| SQLite journal | Violates DEV-119 non-goals (no database) |
| Agent-instructed recovery only | Not generator-enforced; fails CI evidence bar |

## Related

- DEV-092 transactional apply
- DEV-093 state.json
- DEV-091 rollback manifest (MAJOR migration — separate artifact)
