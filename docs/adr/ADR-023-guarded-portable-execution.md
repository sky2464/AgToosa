# ADR-023: Guarded Portable Execution

**Status**: Accepted  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review (DEV-123 spec)  
**Related**: ADR-020 (Delivery Proof Fabric) · ADR-022 (Change-Aware Adaptive Delivery) · DEV-107 (Orchestration Brain) · DEV-047 (Async Agent Handoff Packs)

## Context

DEV-120 binds artifact integrity via proof graphs. DEV-122 supplies drift impact and provenance-aware context compilation. DEV-047 exports handoff packs for manual async agents but does not define portable execution capsules with scope, policy, ownership, budgets, or safe evidence return. Portfolio row DEV-123 requires guarded portable execution metadata and export — without secret values, default network, protected-workflow writes, native sandbox claims, agent launch, or a bounded autonomous runner.

## Decision

1. Introduce **Guarded Portable Execution v1** with two JSON contracts: execution capsule and capsule evidence return.
2. Ship one built-in capsule provider: **`local-guarded`** (allowlisted path scope, declarative policy block, ownership + budget hints, network-free).
3. Default `agtoosa-capsule-verify.sh` to **suggest-only** (exit 0 on policy warnings). **`--strict`** exits non-zero only when high-severity policy violations are detected — opt-in maintainer gate.
4. Ship `agtoosa-capsule-pack.sh` to assemble capsules from story context with optional proof-graph and drift-report pointers. Packing does **not** verify graphs or mutate Master-Plan.
5. Ship `agtoosa-capsule-export.sh` to emit handoff-compatible markdown extending DEV-047 return contract, with secret-shaped redaction and separate proof-verify requirement.
6. Record policy check results from **fixture-labeled** cases only — not live sandbox or network telemetry.

## Rationale

- Declarative capsules are the narrowest honest spike — metadata guardrails without claiming OS-level isolation.
- Suggest-first default avoids blocking handoffs before policy fixtures are calibrated.
- Handoff export reuses DEV-047 return contract — manual agent launch preserved.
- Fixture-labeled policy checks satisfy portfolio “verification” without false sandbox precision.
- Proof graph and drift bindings compose with DEV-120/DEV-122 without absorbing their scope.

## Consequences

### Positive

- Async handoffs gain machine-readable scope, policy, and budget metadata.
- Evidence return can cite proof-graph bindings with redaction rules.
- Bats tamper fixtures for deterministic strict/suggest behavior.

### Negative

- Capsules require maintainer curation — not automatic scope inference.
- Agents must not treat policy metadata as enforced runtime limits without human opt-in.
- Budget hints are advisory in v1 — not enforced execution timeouts.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Native sandbox/container wrapper in v1 | Violates portfolio non-goal; overclaims isolation |
| Default network allow in capsules | Violates portfolio non-goal; expands attack surface |
| Auto-launch async agents from export | Violates manual handoff boundary (DEV-047) |
| Capsule export writes Master-Plan | Violates SoT boundary |
| Live policy telemetry claims | No runtime probe infrastructure in spike |
| Bounded autonomous runner in v1 | Explicit portfolio non-goal; demand-gated separately |
