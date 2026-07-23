# ADR-015: Canonical Product Truth Contract

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** User + AI agent (DEV-118 interview and approval)
**Related:** ADR-008 (Operating Contexts) · DEV-094 (Assistant Compatibility Contract) · DEV-102 (Network Matrix)

## Context

AgToosa repeats cross-surface facts across generator configuration, workflow documents, native assistant adapters, Bash and PowerShell entry points, public tables, and compatibility guidance. Those copies have drifted in observable ways: generated `Docs/` references use maintainer-only lowercase `docs/`, adapter question budgets contradict the canonical workflow, public claims exceed their evidence, and Windows guidance obscures Bash-backed operations and dependencies.

Markdown remains appropriate for full workflow instructions, but it is not a reliable authority for facts that must agree across dozens of files. A canonical contract must remain local-first, inspectable, dependency-light, and unable to execute untrusted content.

## Decision

1. Create a maintainer-only, versioned JSON contract at `contracts/product-truth-v1.json` with a closed schema at `contracts/product-truth-v1.schema.json`.
2. The contract is canonical for modeled cross-surface facts: command inventory, portable command invariants, target and artifact identities, generated-path policy, operation dependencies, backend classifications, and public claim metadata.
3. Canonical workflow Markdown remains authoritative for detailed lifecycle prose and steps that are not represented in the contract. If a modeled field conflicts, contract validation fails and the contract-owned value wins.
4. `docs/Master-Plan.md` remains the repo-local lifecycle source of truth. The Product Truth Contract does not store story state, tasks, approvals, or derived lifecycle status.
5. Treat the JSON as inert data. The loader rejects unknown fields, executable expressions, interpolation, dynamic includes, absolute repository paths, `..` traversal, symlink escape, and over-size inputs. It performs no shell execution, environment expansion, network access, or writes.
6. Use UTF-8 without BOM, canonical POSIX repo-relative paths, deterministic ordering, stable identifiers, and explicit schema/contract versions. Evidence URLs may be stored as opaque references but are never fetched by validation.
7. Keep the contract out of `DOCS_FILES`; it governs AgToosa maintenance and is not installed into downstream projects.

## Rationale

- JSON matches AgToosa's existing machine-contract and schema patterns without adding a YAML parser.
- A closed, inert contract makes drift testable without becoming a runtime or remote control plane.
- The authority split keeps rich workflow prose readable while eliminating ambiguity for modeled facts.
- A maintainer-only contract avoids exposing AgToosa product metadata as downstream project state.

## Consequences

### Positive

- Cross-surface contradictions become deterministic failures.
- Contract changes produce reviewable diffs with stable identifiers.
- Windows, dependency, platform, and claim truth share one model.
- Validation stays local and cannot execute contract-provided behavior.

### Negative

- Maintainers must update the contract before changing governed facts.
- The authority boundary between modeled fields and detailed prose must remain explicit.
- A schema and checker add maintenance cost and require synchronization tests.
- Existing drift must be classified before it can be repaired safely.

## Alternatives Considered

| Option | Rejected because |
| -------- | ------------------ |
| Keep Markdown as the only authority | Existing drift proves cross-file prose checks are insufficient. |
| YAML authoring | Adds a parser dependency without a compensating product benefit. |
| Make the contract a downstream project artifact | Confuses AgToosa product truth with host-project lifecycle state. |
| Allow contract-supplied validation commands | Expands the trust boundary and turns inert metadata into executable input. |
| Fetch evidence during validation | Breaks local-first determinism and conflates freshness with authenticity. |
