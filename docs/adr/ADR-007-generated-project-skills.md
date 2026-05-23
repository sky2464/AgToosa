# ADR-007: Generated Project Skills as Approved Artifacts

**Status:** Accepted  
**Date:** 2026-05-23  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa installs Codex workflow skills for discoverability, but generated projects can also benefit from project-specific skills discovered during `/agtoosa-init` and `/agtoosa-spec`. Those skills may encode domain language, QA routines, API contracts, deployment evidence, or other repeated project workflows. Because skill generation mutates the repo and may reference sensitive project context, it needs a conservative artifact policy.

---

## Decision

Treat generated project skills as explicit project artifacts under `.codex/skills/<skill-name>/SKILL.md`. `/agtoosa-init` and `/agtoosa-spec` may propose skill candidates, but they must ask for user approval before creating or modifying files. Candidate generation must prefer reuse of existing workflow/platform skills, exclude secrets, and create only the files required by the Codex skill anatomy.

---

## Rationale

This keeps skills useful without turning every one-off instruction into repo noise. Codex skills are the first target because AgToosa already installs `.codex/skills/` and has bats inventory coverage for that surface. Other platforms can keep using existing command, prompt, rule, workflow, and agent adapters until a follow-up story proves native skill parity is needed.

---

## Consequences

### Positive

- AgToosa can preserve recurring project workflows as durable skill artifacts.
- Generated skills have a clear approval and audit trail.
- Skill quality can be tested with bats instead of relying on file-existence checks only.

### Negative

- Init/spec workflows become slightly longer when useful skill candidates exist.
- Maintainers must keep skill-generation rules aligned with Codex skill anatomy.
- Non-Codex native skill parity remains a follow-up unless proven necessary.

---

## Alternatives Considered

| Option | Rejected because |
|--------|-----------------|
| Keep workflow skills as thin dispatchers only | Does not satisfy the need for skills that actually run workflows with useful phase context |
| Generate skills automatically without approval | Risks repo noise, duplicate triggers, and accidental sensitive-content capture |
| Implement cross-platform generated skills in one story | Too broad for the current template surface and difficult to validate safely |
