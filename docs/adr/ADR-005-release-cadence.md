# ADR-005: Maintainer release cadence (patch-first)

**Status:** Accepted  
**Date:** 2026-05-25  
**Deciders:** AgToosa maintainers  
**Related:** [ADR-004](ADR-004-versioning-backward-compatibility.md) (semver semantics and merge markers)

---

## Context

AgToosa ships frequently during maintainer dogfood. Agents running `/agtoosa-review` and `/agtoosa-ship` often suggested **MINOR** bumps (e.g. 5.1.0 → 5.2.0) for small **S** chores and doc-only fixes. That advanced the public version faster than maintainers wanted, while semver machinery (`AGTOOSA_VERSION`, CI tag checks, `version_lt`) already supports fine-grained **PATCH** releases.

ADR-004 defines what MAJOR, MINOR, and PATCH *mean*; it does not define *how often* each segment should advance during routine shipping.

---

## Decision

**Default to PATCH bumps on the active MINOR train** for routine maintainer releases unless a documented exception applies.

| Story profile | Bump | Example (from 5.2.0) |
|---------------|------|----------------------|
| Fix, Chore, docs-only, estimate **S** | **PATCH** | 5.2.1 |
| Feature **S**, same MINOR train, non-breaking | **PATCH** | 5.2.1 |
| New MINOR train, multi-story batched release, deliberate cycle boundary | **MINOR** (Z=0) | 5.3.0 |
| Breaking change per ADR-004 | **MAJOR** | 6.0.0 |

**Milestone rule:** `docs/Master-Plan.md` → Project Charter **Milestone** tracks the **next PATCH** on the current MINOR (e.g. `v5.2.1 (next)` while `AGTOOSA_VERSION` is `5.2.0`). Do not skip ahead to the next MINOR for routine backlog work.

**Batching:** Multiple stories may share one PATCH release when shipped together in a single `/agtoosa-ship`.

**Format:** Versions remain `X.Y.Z` (no zero-padded display variants such as `1.1.02`).

---

## Consequences

**Positive**

- Predictable, slow-moving version line for users and install pins
- Aligns agent behavior with existing CI and `version_lt` without code changes

**Negative**

- MINOR train advances less often; release notes may bundle more changes per MINOR when batched

**Out of scope**

- Renumbering historical releases
- Automating version selection in CI

---

## Enforcement

- `docs/agtoosa-maintainer.md` — Release Checklist bump tree
- `template/Docs/AgToosa_Ship.md` and `template/Docs/AgToosa_Review.md` — agent-facing defaults
- `tests/agtoosa.bats` — DEV-032 VP1–VP5 grep guards
