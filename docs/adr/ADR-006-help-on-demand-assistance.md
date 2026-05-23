# ADR-006: Help as On-Demand Assistance

**Status:** Accepted  
**Date:** 2026-05-23  
**Deciders:** AgToosa maintainers

---

## Context

`/agtoosa-help` is currently a lightweight command reference, not one of the main lifecycle phases. After DEV-006, Status Guide can coach from `/agtoosa-status`, but the remaining planned item is `/agtoosa-help next`: context-aware help that suggests the next move when a user asks for assistance.

---

## Decision

Keep `/agtoosa-help` outside the main Spec -> Build -> QA -> Review -> Ship workflow. Treat it as an on-demand assistance helper that loads only when explicitly invoked. Add `/agtoosa-help next` as a contextual helper sub-command that performs a read-only status/context read and recommends the next command without mutating project state.

---

## Consequences

- **Positive:** Help stays lightweight and does not become another always-on phase.
- **Positive:** Users can ask for the next move without invoking Status Guide directly.
- **Negative:** Help behavior must remain mirrored across the three native help variants and Cursor/Windsurf core fallbacks.
- **Follow-up:** Build DEV-007 to wire `/agtoosa-help next` into platform help surfaces and bats parity.
