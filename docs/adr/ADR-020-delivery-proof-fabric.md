# ADR-020: Delivery Proof Fabric (Evidence Provenance v2)

**Status**: Accepted  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review (DEV-120 spec)  
**Related**: ADR-017 (freshness vs authenticity) · DEV-087 (Delivery Evidence Contract) · DEV-089 (Gate 7) · DEV-049 (Evidence Ledger)

## Context

DEV-087 defines delivery-class artifact profiles (Guided / Evidenced / Enforced) and Gate 7 checks deterministic presence. DEV-049 indexes evidence pointers at review/ship but does not bind artifact content to execution context. ADR-017 states freshness metadata does not prove authenticity — execution-bound provenance is deferred to DEV-120.

The Competitive Proof Portfolio (DEV-120–124) needs a shared foundation: a derived proof graph with fingerprinted links and a pluggable provider interface, without replacing `Master-Plan.md`, evidence ledgers, or profiles.

## Decision

1. Introduce **Evidence Provenance v2** as a typed **node DAG** stored per story at `docs/archived/proof-graph-<story-id>.json` (generated path: `Docs/archived/…`).
2. Define six node types (`story`, `ac`, `artifact`, `command-run`, `content-hash`, `repo-snapshot`) and three edge types (`references`, `verified-by`, `content-of`).
3. Ship a **generic proof-provider interface** with one built-in pilot provider: **`local-hash`** (SHA-256 content fingerprints + repo HEAD snapshot).
4. Verify graphs via a **standalone** `agtoosa-proof-verify.sh` script (local, network-free). **Gate 8** verifier integration is deferred to a follow-up story.
5. Graph assembly at review/ship remains **agent-instructed** (extends `/agtoosa-evidence`); verification is **local machine check** when the script runs.

## Rationale

- Typed DAG extensibility supports DEV-121–124 without absorbing their scope in the spike.
- Standalone script proves the fabric before expanding `agtoosa-verify.sh` gate chain (Gate 7 already complex).
- `local-hash` validates link integrity without mandating Dafny, Nx, or hosted attestors (portfolio non-goals).
- Derived graph preserves `Master-Plan.md` as repo-local source of truth; graph is evidence, not authority.

## Consequences

### Positive

- Evidence rows gain machine-checkable content bindings.
- Portfolio children inherit a stable provenance vocabulary.
- Bats can tamper fixtures and assert deterministic verification failures.

### Negative

- Extra artifact per shipped story (proof graph JSON).
- Agents must assemble graphs correctly — mitigated by schema + workflow docs.
- Snapshot drift if repo moves after graph generation — document `--allow-stale-snapshot` vs strict mode.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Linear chain only (Q2-A) | Insufficient for multi-artifact / multi-AC stories; weak extensibility |
| Ledger column augmentation only (Q2-C) | No provider interface; does not validate "fabric" goal |
| Verifier Gate 8 in spike (Q3-B) | Expands scope; should follow proven schema + script |
| Agent-instructed only (Q3-C) | No executable verification pilot; fails spike proof bar |
