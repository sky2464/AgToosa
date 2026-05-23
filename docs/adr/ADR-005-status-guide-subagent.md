# ADR-005: Status Guide Sub-Agent (Coach on Status)

**Status:** Accepted  
**Date:** 2026-05-22  
**Deciders:** AgToosa maintainers

---

## Context

`/agtoosa-status` provides a deterministic health dashboard and Part 5.5 Recommended Next Actions, but leaves execution planning to the user. Copilot projects already install `.github/agents/agtoosa.agent.md` as a phase dispatcher. We need a dedicated sub-agent that coaches without violating the status read-only guarantee.

---

## Decision

Add **`agtoosa-status-guide.agent.md`** plus canonical workflow **`Docs/AgToosa_StatusGuide.md`**. The Status Guide runs status read-only, presents the top three Part 5.5 actions, and requires explicit user authorization before each fix command. Register the agent in `lib/config.sh` for GitHub platform installs.

---

## Consequences

- **Positive:** Closes CHANGELOG Planned item; extends ADR-003 orchestration with a read-only → authorized-dispatch pattern.
- **Negative:** GitHub-only native agent file; other platforms reference the doc manually until a follow-up expands variants.
- **Follow-up:** `/agtoosa-help next` may call Status Guide internally (DEV-007+).
