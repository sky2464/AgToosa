# ADR-008: AgToosa Operating Contexts (Product vs Dogfood)

**Status:** Accepted  
**Date:** 2026-05-23  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa serves two distinct audiences with overlapping vocabulary:

1. **Generated Project Mode** — Teams install AgToosa into their own repositories. Workflow docs, status output, and agent instructions must refer to *the project* or *the product*, not to AgToosa as the application being built.
2. **Maintainer Dogfood Mode** — The AgToosa repository uses AgToosa workflows to improve the generator. Maintainer entry files (`docs/agtoosa-maintainer.md`, `CLAUDE.md`, `.github/agents/agtoosa.agent.md`) must explicitly scope work to generator surfaces.

Without explicit terminology, generated projects inherit maintainer assumptions (e.g., Linear project name `AgToosa`, "AgToosa" as product identity in status/spec copy). Audit UX-2 (v3.1.0) and dream reports document this drift.

ADR-003 still references Linear as authoritative; DEV-009 corrected workflow PM claims. This ADR addresses **identity and scope** boundaries, not PM tool choice.

---

## Decision

**Document two named operating contexts in canonical template docs and maintainer guides. Generated workflow docs SHALL use "the project" / "the product" language; maintainer docs MAY name AgToosa explicitly and SHALL state Maintainer Dogfood Mode.**

- No new CLI flags or generator runtime behavior.
- Canonical `template/Docs/` changes first; platform adapters mirror only necessary wording.
- Bats tests (B1–B5) lock the documentation contract.

---

## Consequences

### Positive

- Downstream projects stop inheriting AgToosa maintainer identity.
- Agents working in this repository understand they are improving the generator, not shipping a generic app template.

### Negative

- Dual vocabulary requires discipline when editing shared strings (maintainer parity table may grow).

### Neutral

- Repo mirrors under `docs/AgToosa_*.md` remain optional; DEV-011 targets `template/` + `docs/agtoosa-maintainer.md` only.

---

## Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Separate template pack for maintainer vs consumer | Doubles inventory and drift risk |
| Runtime `--mode maintainer` flag | Out of scope; docs-only contract per story |
| Single doc set with `{{PROJECT_NAME}}` placeholders | Heavy templating; init already customizes Master-Plan |
