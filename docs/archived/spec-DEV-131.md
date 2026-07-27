# Spec: DEV-131 — Sequential Approval + Release Publication Gate

> **Story ID:** DEV-131  
> **Epic:** DEV-002 — Workflow Templates · DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.45  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P0  
> **Parent / extends:** DEV-125 (`/agtoosa-next`) · DEV-130 ship hygiene correction  
> **ADR:** `docs/adr/ADR-019-agtoosa-next-dispatcher.md` (amended)  
> **Spec created:** 2026-07-27  
> **Ship target:** v5.3.45

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Close two gaps: (1) `/agtoosa-next` should complete each phase through approval gates when user repeats `next`; (2) ship must not claim `Release X shipped` until git tag + GitHub release exist |
| Sequential Approval | Docs + ADR-019 amendment + NXT-013–NXT-015 bats; served-by-next exceptions in Spec, Review, Ship, Agent |
| Release publication | `docs/Context/tech-stack.md` `deploy_command`; `AgToosa_Ship.md` release rule; `check-launch-readiness.sh`; `release-advanced.yml`; RL-001–RL-004 bats |
| Non-goals | Auto-chaining phases in one Next run; overriding 🔴 Critical blockers; mandatory network in local ship without user approval |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Cold-start pick from `/agtoosa-next dry` | **(1)** DEV-131 — Sequential Approval + release publication gate |

#### Documented assumptions

- Implementation largely landed on `main` before formal enrollment; build verifies parity and ships v5.3.45.
- Catch-up GitHub release for v5.3.44 may already exist; this story formalizes the gate for future ships.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | `/agtoosa-next` completes each lifecycle phase through approval gates (Sequential Approval); ship records release only after tag + GitHub release verification |
| User outcome | User types `next` repeatedly to spec→build→review→ship without separate approval turns; maintainers never log false `Release X shipped` rows |
| Success condition | NXT-013–015 + RL-001–004 green; template/docs mirrors aligned; v5.3.45 shipped |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-131.md`; bats `NXT-013–015`, `RL-001–004` |
| Non-goals | Phase auto-chaining; removing direct-phase approval gates; silent git push without user consent on direct `/agtoosa-ship` |
| Assumptions | DEV-125 dispatcher shipped; maintainer `docs/Context/tech-stack.md` documents git-tag deploy |
| Risks | Users confuse implicit Next approval with yolo override of critical findings |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `/agtoosa-next` dispatches a lifecycle phase THE SYSTEM SHALL document Sequential Approval — user's Next invocation counts as approval at spec, review, and ship deploy gates when readiness checks pass |
| AC-002 | Must | WHEN `/agtoosa-next` completes one phase THE SYSTEM SHALL NOT chain into the next lifecycle phase in the same invocation |
| AC-003 | Must | WHEN idle after ship THE SYSTEM SHALL scan backlog or print `No spec is planned` with up to 3 recommendations |
| AC-004 | Must | WHEN `deploy_command` is documented THE SYSTEM SHALL forbid `Release X shipped` Update Log rows until tag push and `deploy_verify` succeed |
| AC-005 | Must | WHEN maintainer tech-stack documents git-tag deploy THE SYSTEM SHALL list `deploy_command`, `deploy_verify`, and `release-advanced.yml` reference |
| AC-006 | Must | WHEN launch readiness runs THE SYSTEM SHALL verify remote release tag via `check_release_tag_published` |
| AC-007 | Must | WHEN DEV-131 ships THE SYSTEM SHALL pass bats NXT-013–NXT-015 and RL-001–RL-004 |

### 1.3 Scope Boundary

**In scope:** `AgToosa_Next.md`, `AgToosa_Agent.md`, `AgToosa_Spec.md`, `AgToosa_Review.md`, `AgToosa_Ship.md`, ADR-019, platform adapters, `check-launch-readiness.sh`, release workflows, bats.

**Out of scope:** New generator CLI flags; runtime orchestrator; auto git push without approval on direct ship.

## 2. Design

### 2.1 Sequential Approval flow

```
User: next (or /agtoosa-next)
  → SYNC pulse + dispatch ONE phase
  → Complete phase INCLUDING approval when checks pass
  → Next: /agtoosa-next — <next phase or backlog spec>
User: next again → next phase (separate invocation)
```

### 2.2 Release publication flow

```
/agtoosa-ship Part 0 pass
  → deploy_command documented?
  → push tag (with approval) → deploy_verify (gh release + CI)
  → only then: Release X shipped log + 🏁 Shipped
```

### 2.3 Threat Model (STRIDE summary)

| Threat | Mitigation |
|--------|------------|
| False release claims | Release publication rule + readiness checker |
| Build before spec approval | `spec_approved` route-hint (DEV-125) |
| Silent override of critical findings | Next does not bypass 🔴 Critical review or Part 0 ship failures |
| Approval bypass on direct slashes | Sequential Approval applies only when served by Next |

## 3. Tasks

- [x] **1.** Verify doc parity (template + `docs/` mirrors) — _AC-001, AC-003, AC-004_
- [x] **2.** Run bats NXT-013–015 + RL-001–004 — _AC-007_
- [x] **3.** Ship v5.3.45 — version parity, changelog, cycle archive — _AC-004–AC-006_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-131.md`.

---

## ✅ Spec Approved

Approved: 2026-07-27 17:15
