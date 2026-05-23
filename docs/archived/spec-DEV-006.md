# Spec: DEV-006 — AgToosa Status Guide sub-agent

> **Story ID:** DEV-006
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🟦 Todo
> **Estimate:** M
> **Spec created:** 2026-05-22

## Context

`/agtoosa-status` shipped in 4.1.0 with a deterministic Part 5.5 “Recommended Next Actions” algorithm, but users still must interpret the dashboard and decide which fix command to run. CHANGELOG `[Unreleased] → Planned` promises an **AgToosa Status Guide** sub-agent: read-only Auditor + Coach persona that runs `/agtoosa-status`, applies Part 5.5, surfaces the top three actions with rationale, and **asks the user to authorize** each suggested command before execution.

DEV-005 moved this item out of the released 4.1.0 “Coming next” section without implementing it. This story delivers the minimal shippable sub-agent on the existing GitHub Copilot agent surface (`.github/agents/`), with a canonical workflow doc installed via the generator. `/agtoosa-help next` remains a separate follow-up story.

**Smart Interview (skipped — answers inferred from codebase + CHANGELOG):**

| Question | Finding |
|----------|---------|
| Status quo | `agtoosa-status` variants delegate to `AgToosa_Status.md`; only `agtoosa.agent.md` exists; no Coach layer or authorization gate. |
| Narrowest scope | One new agent file + `AgToosa_StatusGuide.md` workflow + `lib/config.sh` registration + bats install/content parity + cross-links in Agent/Skills. No changes to Part 5.5 algorithm itself. |
| Urgency | Maintainer dogfood and Copilot users need guided next steps after status; repeated dream-report mentions since 05-14. |
| Failure modes | Agent runs fix commands without approval; improvises action order vs Part 5.5; modifies Master-Plan during “status”. |
| Security surface | Read-only status + user-authorized dispatch only; no new secrets or network APIs. |

## 1. Requirements

### 1.1 User Stories

**As a** developer using AgToosa on GitHub Copilot, **I want** a Status Guide agent that runs `/agtoosa-status` and coaches me through the top fix commands **so that** I get deterministic next steps without the main agent mutating project state.

**As a** AgToosa maintainer, **I want** the Status Guide workflow documented in `template/Docs/` and covered by bats **so that** generator installs stay in parity with other workflow commands.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the user invokes the Status Guide agent THE SYSTEM SHALL run `/agtoosa-status` (full dashboard) without modifying any file or git state | Must |
| AC-002 | WHEN the status dashboard is complete THE SYSTEM SHALL present up to three Recommended Next Actions derived strictly from `AgToosa_Status.md` Part 5.5 (no improvised ordering) | Must |
| AC-003 | WHEN presenting each recommended action THE SYSTEM SHALL include the fix-command, finding count/IDs, and the verbatim rationale line from Part 5.5 | Must |
| AC-004 | WHEN a recommended action would run `/agtoosa-init`, `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, or `/agtoosa-ship` THE SYSTEM SHALL ask the user for explicit authorization before invoking that command | Must |
| AC-005 | WHEN the user declines authorization THE SYSTEM SHALL not run the declined command and SHALL offer the next ranked action or stop | Must |
| AC-006 | WHEN `agtoosa.sh` installs platform GitHub (selection 5) THE SYSTEM SHALL copy `.github/agents/agtoosa-status-guide.agent.md` into the target project | Must |
| AC-007 | WHEN `bats tests/agtoosa.bats` runs the Status Guide parity tests THE SYSTEM SHALL pass install and canonical-doc assertions | Must |
| AC-008 | WHEN a reader opens `Docs/AgToosa_Agent.md` THE SYSTEM SHALL list the Status Guide sub-agent with a pointer to `Docs/AgToosa_StatusGuide.md` | Should |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Agent “fixes” findings during status → corrupts Master-Plan |
| AC-002 | Agent re-sorts actions by vibe → breaks cross-run determinism |
| AC-004 | Agent auto-runs `/agtoosa-build` after status without consent |
| AC-006 | Agent file missing after install → Copilot users never see Guide |
| AC-007 | Tests grep wrong path → false green while template drifts |

### 1.3 Out of Scope

- `/agtoosa-help next` context-aware help (separate story; remains in CHANGELOG Planned)
- Native Claude/Cursor/Windsurf sub-agent files (GitHub agent + doc reference only; other platforms invoke via “read AgToosa_StatusGuide.md” in core rules later)
- Changing Part 5.5 algorithm or health-score weights in `AgToosa_Status.md`
- Linear API integration for agent comments

## 2. Design

### 2.1 Architecture Blueprint

```
Files to create:
  - template/Docs/AgToosa_StatusGuide.md
  - template/.github/agents/agtoosa-status-guide.agent.md
  - docs/AgToosa_StatusGuide.md                    — maintainer mirror (dogfood)
  - docs/adr/ADR-005-status-guide-subagent.md      — orchestration extension
  - docs/Context/CONTEXT.md                        — domain terms (if missing)

Files to change:
  - lib/config.sh                                  — add agent path to install lists
  - template/Docs/AgToosa_Agent.md                 — command / agent table row
  - template/Docs/AgToosa_Skills.md                — Status Guide persona + skills
  - template/.github/agents/agtoosa.agent.md       — dispatch hint for Status Guide
  - tests/agtoosa.bats                             — S1–S2 parity tests (names TBD in build)
  - docs/Master-Plan.md                            — enrollment (this workflow)

Key interfaces:
  - Status Guide agent → read AgToosa_StatusGuide.md → execute AgToosa_Status.md Parts 1–5 → Part 5.5 coach loop → authorization gate per action
```

### 2.2 Data Flow

1. User selects **Status Guide** agent in GitHub Copilot (or asks maintainer repo to follow `docs/AgToosa_StatusGuide.md`).
2. Agent reads `Docs/AgToosa_Status.md` and runs read-only status (plan + git + orphans + score + dashboard).
3. Agent extracts Part 5.5 **Recommended Next Actions** (max 5 listed; coach presents top 3).
4. For action #1: agent shows command + rationale, asks “Authorize running `<command>`? (yes/no)”.
5. On **yes**: agent runs only that command’s workflow doc; on **no**: proceed to action #2.
6. After authorized command completes, agent prints closure line if applicable and suggests `/agtoosa-status` to verify.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Coach agent writes Master-Plan during audit | Tampering | AC-001 + workflow “read-only guarantee” repeated in StatusGuide doc |
| Unauthorized destructive git ops | Elevation | AC-004/005; only read-only git commands during status phase |
| User tricked into approving wrong command | Spoofing | Show full command name + finding IDs before yes/no |
| False parity (agent not installed) | Repudiation | AC-006/007 bats install assertion |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : template/Docs/AgToosa_StatusGuide.md, template/.github/agents/agtoosa-status-guide.agent.md,
                      template/Docs/AgToosa_Agent.md, template/Docs/AgToosa_Skills.md,
                      template/.github/agents/agtoosa.agent.md, lib/config.sh, tests/agtoosa.bats,
                      docs/AgToosa_StatusGuide.md, docs/Master-Plan.md, docs/Context/CONTEXT.md,
                      docs/adr/ADR-005-status-guide-subagent.md
Directories in scope: template/Docs/, template/.github/agents/, lib/, tests/, docs/
Out of scope        : Part 5.5 edits in AgToosa_Status.md, /agtoosa-help next, agtoosa.sh generator logic beyond config lists,
                      CHANGELOG release entry (ship phase), README install snippets
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Canonical Status Guide workflow
  - [ ] 1.1 Author `template/Docs/AgToosa_StatusGuide.md` (personas, coach loop, authorization gate) — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005_
  - [ ] 1.2 Mirror to `docs/AgToosa_StatusGuide.md` for maintainer dogfood — _Requirements: AC-008_
- [ ] **2.** GitHub sub-agent surface
  - [ ] 2.1 Create `template/.github/agents/agtoosa-status-guide.agent.md` delegating to StatusGuide doc — _Requirements: AC-001, AC-004_
  - [ ] 2.2 Register agent in `lib/config.sh` install arrays — _Requirements: AC-006_
- [ ] **3.** Framework cross-links
  - [ ] 3.1 Update `template/Docs/AgToosa_Agent.md` and `AgToosa_Skills.md` — _Requirements: AC-008_
  - [ ] 3.2 Add Status Guide dispatch line to `template/.github/agents/agtoosa.agent.md` — _Requirements: AC-008_
- [ ] **4.** Bats parity
  - [ ] 4.1 Add install test: platform 5 copies `agtoosa-status-guide.agent.md` — _Requirements: AC-006, AC-007_
  - [ ] 4.2 Add content test: StatusGuide references Part 5.5, read-only, authorization — _Requirements: AC-002, AC-004, AC-007_
- [ ] **5.** Domain + ADR
  - [x] 5.1 Add `docs/Context/CONTEXT.md` terms (Status Guide, Coach loop, Authorization gate) — _Requirements: AC-008_
  - [x] 5.2 Add `docs/adr/ADR-005-status-guide-subagent.md` — _Requirements: AC-008_
- [ ] **6.** Validation
  - [ ] 6.1 Run new bats tests + agent install subset — all green — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 5.1, 5.2
**Wave 2 (sequential):** 1.2, 2.2, 3.1, 3.2
**Wave 3 (sequential):** 4.1, 4.2, 6.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-status-guide.md`
AC coverage: 8 ACs mapped to 8 test IDs
Smoke set: 5 tests tagged @smoke (T-001 through T-005)

## ✅ Spec Approved

Approved: 2026-05-22 16:45
