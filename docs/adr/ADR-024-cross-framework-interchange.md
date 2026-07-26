# ADR-024: Cross-Framework Interchange

**Status**: Accepted  
**Date**: 2026-07-26  
**Deciders**: AI agent + human review (DEV-124 spec)  
**Related**: ADR-020 (Delivery Proof Fabric) · ADR-023 (Guarded Portable Execution) · DEV-048 (Agent Result Import Gate) · DEV-118 (Product Truth & Adapter Contract)

## Context

DEV-120 binds artifact integrity via proof graphs. DEV-123 adds guarded portable execution capsules. Portfolio row DEV-124 requires loss-aware import/export between AgToosa and Spec Kit, OpenSpec, BMAD, and Kiro-style (`SPEC-FORMAT.md`) specs — preserving source IDs and authority boundaries without claiming perfect round-trip fidelity or replacing source frameworks.

`docs/enforcement-comparison.md` documents honest framework control boundaries. `docs/SPEC-FORMAT.md` is the Kiro-style canonical for single-file AgToosa specs — not AWS Kiro IDE remote APIs.

## Decision

1. Introduce **Cross-Framework Interchange v1** with two JSON contracts: interchange manifest and interchange loss report.
2. Ship four **fixture-based** providers: `speckit`, `openspec`, `bmad`, `kiro` — export from archived AgToosa spec markdown; import from frozen JSON fixtures under `tests/fixtures/interchange/`.
3. Normalize requirements (EARS acceptance criteria) and tasks (§3.1 task tree) in the manifest; record unmappable fields in the loss report with `low` or `high` severity.
4. Preserve `source_ids` on export; mark imported manifests `authority.owner: imported-derived` with `preserved: false`.
5. Default loss assess to **suggest-only** (exit `0` on low severity). **`--strict`** exits non-zero when any high-severity loss is detected — opt-in maintainer gate only.
6. Interchange export may reference proof graphs optionally; packing does **not** verify graphs or mutate Master-Plan.
7. Record loss entries from **fixture-labeled** cases only — not live framework telemetry.

## Rationale

- Fixture-based providers are the narrowest honest spike — no `uvx`/`npx` installs or network I/O.
- Explicit loss reports prevent silent equivalence claims between frameworks.
- Authority boundaries keep `docs/Master-Plan.md` as repo-local SoT; imports emit derived manifests only.
- Source ID preservation enables traceability without framework replacement narratives.
- Kiro profile maps to `SPEC-FORMAT.md` single-file specs — distinct from remote IDE APIs.

## Consequences

### Positive

- Maintainers can compare Spec Kit, OpenSpec, BMAD, and Kiro-style shapes with machine-readable loss honesty.
- Export/import CLIs can compose with DEV-120 proof verify and DEV-048 import gate as optional steps.
- Bats tamper fixtures for deterministic strict/suggest behavior.

### Negative

- Fixtures require maintainer curation — may drift from live framework tools.
- Agents must not treat imported manifests as Master-Plan replacements.
- BMAD/OpenSpec imports may lack full EARS text until live tooling is integrated.

## Alternatives Considered

| Option | Rejected because |
|--------|------------------|
| Live `uvx`/`npx` framework installs in v1 | Violates portfolio non-goal; requires network |
| Perfect round-trip fidelity claims | Violates portfolio non-goal; frameworks are not equivalent |
| Import writes Master-Plan checkboxes | Violates SoT boundary |
| Mandatory interchange gate in default CI | Violates optional spike scope |
| AWS Kiro IDE API profile in v1 | Out of scope; SPEC-FORMAT.md is the honest Kiro-style mapping |
| Hosted interchange registries | Explicit portfolio non-goal |
