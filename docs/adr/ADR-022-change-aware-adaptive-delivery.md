# ADR-022: Change-Aware Adaptive Delivery

**Status**: Accepted  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review (DEV-122 spec)  
**Related**: ADR-020 (Delivery Proof Fabric) · DEV-107 (Orchestration Brain) · DEV-043 (brownfield baseline)

## Context

DEV-120 binds artifact integrity via proof graphs. DEV-121 adds behavioral scenario evidence. Neither answers: “Which allowlisted surfaces drifted since the last baseline, and how should rigor adapt?” Portfolio row DEV-122 requires drift/impact providers, measured error behavior, adaptive rigor selection, and provenance-aware context compilation — without default strict blocking or semantic ML claims.

## Decision

1. Introduce **Change-Aware Adaptive Delivery v1** with three JSON contracts: drift baseline, drift report, and context compilation.
2. Ship one built-in drift provider: **`git-inventory`** (allowlisted path SHA-256 compare, network-free).
3. Default `agtoosa-drift-assess.sh` to **suggest-only** (exit 0 on drift). **`--strict`** exits non-zero only when high-impact allowlisted paths drift — opt-in maintainer gate.
4. Map `overall_impact_level` → `suggested_rigor` (`light` · `standard` · `elevated`) via a documented matrix; never auto-block without `--strict`.
5. Ship `agtoosa-context-compile.sh` to emit derived context JSON with optional proof-graph and drift-report pointers. Compilation does **not** verify graphs or mutate Master-Plan.
6. Record measured error rates from **fixture-labeled** cases only in the `measurement` block — not live production metrics.

## Rationale

- Allowlist inventory is the narrowest honest spike — no mandatory language ecosystem (Nx, etc.).
- Suggest-first default avoids blocking workflows before measured accuracy exists.
- Context compilation extends DEV-107 orchestration with provenance pointers without PM authority creep.
- Fixture-labeled measurement satisfies portfolio “measured error behavior” without false precision.

## Consequences

### Positive

- Agents can adapt test depth with machine-readable drift + rigor hints.
- Proof graphs and drift reports compose in one context artifact.
- Bats tamper fixtures for deterministic strict/suggest behavior.

### Negative

- Baselines require maintainer curation — not full-repo semantic analysis.
- Agents must not treat `suggested_rigor` as enforced policy without human opt-in.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Default strict blocking on any drift | Violates portfolio non-goal; blocks before measured accuracy |
| Full-repo git diff provider in v1 | Scope creep; allowlist is sufficient for spike |
| Context compilation writes Master-Plan | Violates SoT boundary |
| Live FP/FN accuracy claims | No production telemetry in spike |
