# ADR-009: Master Architecture as First-Class Context

**Status:** Proposed  
**Date:** 2026-05-24  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa already gives projects a source of truth for product management, context, specs, ADRs, and workflow instructions. It does not currently create a single durable architecture map that agents must consult before making structural decisions.

---

## Decision

AgToosa will treat `Docs/Master-Architecture.md` as a first-class generated-project context artifact.

- Fresh installs include `Docs/Master-Architecture.md`.
- `/agtoosa-init` creates or updates it after smart interview and codebase scan.
- `/agtoosa-update` reads it as high-priority architecture memory and preserves user-authored content.
- Core agent instructions list it as required architecture context.
- The file remains Markdown-only with Mermaid examples and no external diagram dependency.

---

## Consequences

### Positive

- Agents have one stable architecture document to consult before spec, build, and review decisions.
- Teams get a visual architecture starting point without adding tools or runtime dependencies.
- Architecture drift becomes easier to detect during `/agtoosa-review arch`.

### Negative

- One more document must be maintained during meaningful architectural changes.

### Neutral

- ADRs remain the record of specific decisions; `Docs/Master-Architecture.md` is the current system map, not a replacement for ADR history.

---

## Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Store architecture only in `Docs/Context/` | Context files are key-value/product support files, not a visual system architecture. |
| Add architecture sections to `Docs/Master-Plan.md` | Master-Plan is PM state; mixing architecture diagrams into it would make status parsing noisier. |
| Require external C4/diagram tooling | Adds install friction and cross-platform drift; Markdown/Mermaid is enough for a portable baseline. |
