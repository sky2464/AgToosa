# ADR-010: Project-Specific Specialist Subagents

**Status:** Accepted  
**Date:** 2026-05-25  
**Deciders:** AgToosa maintainers

---

## Context

DEV-008 established approved **project skills** (Codex-first, `.codex/skills/<name>/SKILL.md`). `/agtoosa-review` already runs four **virtual** specialist personas in parallel on Claude Code, but those are framework-defined reviewers, not repo-specific specialists.

Downstream projects need **optional, approval-gated** specialists (domain QA, API contract, registry hygiene, etc.) that:

- Are discovered from repo context during `/agtoosa-init` and `/agtoosa-update`
- Materialize as native artifacts per installed platform (Codex skill, Claude skill, GitHub agent, Cursor/Windsurf/Gemini fallbacks)
- Participate in `/agtoosa-spec` when phase hooks and triggers match the active story
- Never ship as a default generic roster in the AgToosa template pack

---

## Decision

Introduce a canonical contract in `Docs/AgToosa_Specialists.md` and project state in `Docs/Context/specialists.md` (created only after user approval). Specialists are **project-specific only**; AgToosa reserves `agtoosa-*` ids and `/agtoosa-*` triggers for lifecycle adapters.

Orchestration: `/agtoosa-spec` reads the approved roster early in Part 1, runs matching `spec`-phase specialists in **parallel** when the host platform supports native delegation; otherwise **sequential** lanes with the same structured evidence block and an explicit fallback note in the spec output.

CLI `agtoosa.sh --update` does not overwrite project-specific specialist files; agentic `/agtoosa-update` may propose materialization after Verify with separate approval.

---

## Rationale

Separates **framework workflows** (fixed `agtoosa-*`) from **project expertise** (variable roster). Cross-platform v1 documents targets and fallbacks without requiring every platform to implement true subagents on day one. Approval gates prevent silent mutation of repo process knowledge or secret leakage.

---

## Consequences

### Positive

- Spec quality improves when domain specialists contribute evidence before Goal Contract and ACs finalize.
- Init/update stay aligned with installed platforms via lock metadata and sentinels.
- Bats can lock contract fields, reserved names, and “no default roster in template/”.

### Negative

- More workflow surface area (Init, Update, Spec, Agent, Skills, adapters).
- Maintainers must keep platform capability matrix current.
- Sequential fallback is slower than parallel on some hosts.

### Follow-ups

- Optional: specialist lanes for `/agtoosa-build` and `/agtoosa-review` phase hooks (out of DEV-031 v1 scope unless explicitly added).

---

## References

- ADR-003 — Multi-Agent Orchestration Patterns
- ADR-007 — Generated Project Skills as Approved Artifacts
- `docs/archived/spec-DEV-008.md` (shipped)
- `docs/archived/spec-DEV-031.md` (this story)
