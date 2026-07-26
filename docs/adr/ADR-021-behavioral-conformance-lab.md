# ADR-021: Behavioral Conformance Lab v1

**Status**: Accepted  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review  
**Related**: ADR-020 (Delivery Proof Fabric) · DEV-094 (Compatibility Contract) · DEV-121

## Context

DEV-094 defines **Scenario-tested** compatibility but ships no reproducible scenario corpus. DEV-120 binds artifact integrity via proof graphs but does not certify assistant behavior. Maintainers need one honest path to record behavioral evidence across all adapter platforms without implying hosted labs or CI-driven assistant APIs.

## Decision

1. Ship a **versioned scenario corpus** with one universal pilot scenario (`lifecycle-compass-proof`) executed once per platform (six adapter targets).
2. Provide **two standalone CLIs** (mirroring DEV-120):
   - `agtoosa-scenario-run.sh` — maintainer runner (documents steps, collects artifact root, emits scenario-run JSON)
   - `agtoosa-scenario-verify.sh` — static artifact verifier (existence + markers)
3. Keep **live assistant execution out of default CI**; bats validate schemas, fixtures, and verifier behavior only.
4. **Scenario-tested** promotion remains manual per DEV-094 (`last_evidence` + pointer); static bats must not auto-upgrade rows.

## Consequences

### Positive

- Reproducible evidence format composes with DEV-120 `proof_graph_path` without absorbing proof-fabric scope.
- All platforms share one proof task — easier comparison and honest gap tracking.
- Pack behavioral certification can reference scenario ids in docs without new CI network requirements.

### Negative

- Maintainer must run six platform passes manually before claiming universal Scenario-tested coverage.
- Static fixtures cannot prove live assistant recognition — claim boundaries must stay explicit.

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Three unrelated pilot scenarios | Superseded by interview — one universal task × six platforms |
| CI executes assistants | Violates non-goals (hosted lab / remote probing) |
| Absorb DEV-060 benchmark | Explicit portfolio exclusion |
