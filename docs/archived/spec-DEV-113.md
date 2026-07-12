# Spec: DEV-113 — Cursor Intake Hardening + Fixture Parity

> **Story ID:** DEV-113  
> **Epic:** DEV-002 — Workflow Templates  
> **Status:** 🏁 Shipped — v5.3.26  
> **Estimate:** S  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  
> **Parent:** DEV-110 (Project Intake) · partial delivery in v5.3.24 without dedicated story

## Context

v5.3.24 shipped Cursor **Natural Language Intent Map**, maintainer dogfood rules (`.cursor/rules/agtoosa-maintainer-core.mdc`), `scripts/cursor-intake-fixture.sh`, and bats **FIX-001** / **NLM-001–NLM-006**. Post-ship review found parity gaps:

| Gap | Current state |
|-----|----------------|
| FIX-001 bypasses fixture script | Test calls `agtoosa.sh` directly; fixture assertions not exercised in CI |
| `template/CLAUDE.md` parity | Has Project Intake pointer but not NL Intent Map (`.cursorrules` has both) |
| Install bats flakiness | `AGTOOSA_SHIP_DIR` per-test isolation shipped; some install tests may still race on shared `ship/` teardown |
| Maintainer command mirror | Only `agtoosa-spec` + `agtoosa-build` in generator `.cursor/commands/` (19 in template) |

**Smart interview decisions (recorded — user chose Option A 2026-07-12):**

| Decision | Choice |
|----------|--------|
| Primary goal | Close fixture/test parity gaps from 5.3.24 cursor intake follow-up |
| FIX-001 | Must invoke `scripts/cursor-intake-fixture.sh` against `$TEST_PROJECT` |
| CLAUDE.md | Must add NL Intent Map pointer (match `.cursorrules`) |
| Bats stability | Must audit install tests for `AGTOOSA_SHIP_DIR`; fix residual `ship/` races if found |
| Full maintainer command mirror | **Out of scope v1** — defer unless trivial during build |
| Release | PATCH **v5.3.25** when shipped |
| Enrollment | Active Cycle now |

**Story Skill Opportunity Synthesis:**

| Skill name | Trigger | Purpose | Decision | Reason |
|------------|---------|---------|----------|--------|
| `cursor-intake-verify` | Maintainer wants manual dogfood | Run fixture + checklist | **Do not generate** | Covered by `scripts/cursor-intake-fixture.sh` + docs |
| `agtoosa-spec` duplicate | Spec intake | — | **Do not generate** | Reserved namespace |

### Spec Quality Analyzer (2026-07-12)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC → test-plan mapping | Pass |
| Claim Boundary classified | Pass — §1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Harden Cursor Project Intake verification so CI exercises the same path maintainers use for downstream dogfood, and close template entry-point parity gaps. |
| User outcome | Maintainers and CI trust that `cursor-intake-fixture.sh` + installed Cursor wiring match template contracts; fewer flaky install bats. |
| Success condition | FIX-001 runs fixture script; CLAUDE.md NL map parity; install bats stable under repeated `bats tests/agtoosa.bats`; FIX/NLM/CIT bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-113.md`; 3× full bats run without install-suite flakes |
| Non-goals | Full maintainer `.cursor/commands/` mirror (19 commands); runtime intake enforcer; new NL map phrases; changing DEV-110 intake algorithm |
| Assumptions | `AGTOOSA_SHIP_DIR` isolation is the right fix vector; remaining flakes are teardown/order issues not logic bugs |
| Risks | Over-scoping maintainer command mirror; bats changes mask real install bugs — mitigate with targeted flake repro + minimal diff |

### 1.2 User Stories

**As a** AgToosa maintainer, **I want** CI to run `cursor-intake-fixture.sh` **so that** fixture regressions cannot slip past direct `agtoosa.sh` installs.

**As a** downstream Cursor user, **I want** `CLAUDE.md` to mention the NL Intent Map **so that** Claude Code entry points match `.cursorrules` guidance.

**As a** maintainer running full bats, **I want** install tests isolated **so that** parallel or repeated runs do not fail on `ship/` races.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `tests/agtoosa.bats` runs FIX-001 THE SYSTEM SHALL invoke `scripts/cursor-intake-fixture.sh` with the test project path and assert exit 0 | Must |
| AC-002 | WHEN FIX-001 passes THE SYSTEM SHALL confirm post-install presence of `.cursor/rules/agtoosa-core.mdc`, `agtoosa-spec`/`agtoosa-build` commands, `Docs/AgToosa_Agent.md`, `alwaysApply: true`, Project Intake, and Natural language intent map in installed `agtoosa-core.mdc` | Must |
| AC-003 | WHEN `template/CLAUDE.md` is compared to `template/.cursorrules` THE SYSTEM SHALL include a Natural Language Intent Map pointer in the Project Intake line (template + `docs/` mirror if present) | Must |
| AC-004 | WHEN install-related bats run THE SYSTEM SHALL use per-test `AGTOOSA_SHIP_DIR` (or documented equivalent) so no test reads/writes the repo default `ship/` concurrently | Must |
| AC-005 | WHEN full `bats tests/agtoosa.bats` runs three consecutive times THE SYSTEM SHALL complete with zero failures attributable to install `ship/` teardown races | Must |
| AC-006 | WHEN `scripts/cursor-intake-fixture.sh` is invoked with the generator root path THE SYSTEM SHALL refuse with the same self-target error as `agtoosa.sh` | Must |
| AC-007 | WHEN shipping DEV-113 THE SYSTEM SHALL extend or add CIT-001–CIT-004 bats and keep NLM-001–NLM-006 green | Must |
| AC-008 | WHEN maintainer docs describe Cursor dogfood THE SYSTEM SHALL state that FIX-001 exercises the fixture script (Should) | Should |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Fixture script rots; CI green while manual dogfood breaks |
| AC-002 | Partial wiring ships (missing NL map or alwaysApply) |
| AC-003 | Claude Code users miss NL routing; Cursor-only parity |
| AC-004 | Flaky CI blocks releases; false negatives in install suite |
| AC-005 | Intermittent reds erode trust in bats |
| AC-006 | Maintainer accidentally installs into generator repo |
| AC-007 | Regression in NL map or fixture docs undetected |

### 1.4 Out of Scope (v1)

- Mirroring all 19 template `.cursor/commands/` into generator `.cursor/commands/`
- Runtime / hook enforcement of NL intent routing
- New natural-language phrases beyond DEV-110 map
- Changing Project Intake soft/hard algorithm (DEV-110)
- Windows PS1 fixture script (bash-only maintainer tool is acceptable)

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | v5.3.24: fixture script + NLM bats + maintainer core; FIX-001 calls `agtoosa.sh` directly; `template/CLAUDE.md` lacks NL map in intake line; `AGTOOSA_SHIP_DIR` in bats setup but not verified on all install paths |
| Intended change deltas | FIX-001 → fixture script; CLAUDE.md parity; install bats audit + race fixes; optional CIT self-target test |
| Drift evidence | Post-5.3.24 review; conversation Option A scope 2026-07-12 |
| Claim Boundary | See §1.6 |
| Source of truth | `docs/Master-Plan.md` remains repo-local SoT |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Fixture script post-install assertions | generator-enforced (script exit code) |
| FIX-001 / CIT-* bats | CI-enforced when bats run |
| NL map in CLAUDE.md | generator-enforced (template copy) + agent-instructed (host reads file) |
| Manual Cursor intake checklist | manual |
| Full maintainer command mirror | out of scope |

## 2. Design

### 2.1 Architecture Blueprint

No new modules. Changes are confined to:

| Surface | Action |
|---------|--------|
| `tests/agtoosa.bats` | Rewrite FIX-001 to call fixture script; add CIT-*; audit install tests for `AGTOOSA_SHIP_DIR` |
| `scripts/cursor-intake-fixture.sh` | Ensure assertions align with FIX-001/CIT expectations; self-target guard already present |
| `template/CLAUDE.md` + `docs/CLAUDE.md` if mirrored | Add NL Intent Map to Project Intake line |
| `docs/agtoosa-maintainer.md` | Note FIX-001 ↔ fixture relationship (Should) |

### 2.2 Data Flow

```text
1. bats setup → export AGTOOSA_SHIP_DIR=$(mktemp -d)
2. FIX-001 → bash scripts/cursor-intake-fixture.sh "$TEST_PROJECT"
3. Fixture → agtoosa.sh --platforms cursor --yes → assert files + greps
4. teardown → rm TEST_PROJECT + AGTOOSA_SHIP_DIR
```

### 2.3 STRIDE Threat Model

| Threat | Mitigation |
|--------|------------|
| Spoofing (fixture targets wrong dir) | Self-target guard on generator root |
| Tampering (ship dir shared) | Per-test `AGTOOSA_SHIP_DIR` |
| Repudiation | Bats evidence in test plan |
| Information disclosure | N/A — no secrets |
| Denial of service | N/A |
| Elevation | N/A — maintainer test harness only |

### 2.4 Build Scope

**Files in scope:**

- `tests/agtoosa.bats` (FIX-001, CIT-*, install test audit)
- `scripts/cursor-intake-fixture.sh` (assertion alignment only if needed)
- `template/CLAUDE.md`, `docs/CLAUDE.md` (if exists)
- `docs/agtoosa-maintainer.md` (Should — FIX-001 note)
- `docs/AgToosa_TestPlan-DEV-113.md`

**Directories in scope:** `tests/`, `scripts/`, `template/`, `docs/`

**Out of scope:** `lib/*.sh` install logic (unless race fix requires one-line env export), `.cursor/commands/` expansion, `agtoosa.ps1`

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Tests — fixture parity
  - [x] 1.1 Rewrite FIX-001 to invoke `scripts/cursor-intake-fixture.sh "$TEST_PROJECT"` — _Requirements: AC-001, AC-002_
  - [x] 1.2 Add CIT-002: fixture self-target rejects generator root — _Requirements: AC-006_
  - [x] 1.3 Add CIT-003: fixture asserts Project Intake in installed core — _Requirements: AC-002_
  - [x] 1.4 Verify NLM-001–NLM-006 still green after FIX-001 change — _Requirements: AC-007_

- [x] **2.** Template parity
  - [x] 2.1 Add NL Intent Map pointer to `template/CLAUDE.md` Project Intake line — _Requirements: AC-003_
  - [x] 2.2 Mirror to `docs/CLAUDE.md` if file exists — _N/A_

- [x] **3.** Install bats stability
  - [x] 3.1 Audit install-related tests for `AGTOOSA_SHIP_DIR` usage; patch any default `ship/` dependency — _Requirements: AC-004_
  - [x] 3.2 Run full bats 3× consecutively; fix flakes until AC-005 passes — _Requirements: AC-005_

- [x] **4.** Docs + evidence
  - [x] 4.1 Update `docs/agtoosa-maintainer.md` FIX-001 ↔ fixture note — _Requirements: AC-008_
  - [x] 4.2 Record GREEN evidence in test plan — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 3.1  
**Wave 2 (sequential after Wave 1):** 1.2, 1.3, 1.4, 2.2, 3.2, 4.1, 4.2

### 3.3 Test Plan

See `docs/AgToosa_TestPlan-DEV-113.md` — FIX-001 (updated), CIT-001–CIT-004, NLM regression.

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | verification |
|------------|------|------------|-------------|--------------|
| PKG-1.1 | 1 | — | `tests/agtoosa.bats` | `bats -f FIX-001` |
| PKG-2.1 | 1 | — | `template/CLAUDE.md` | `bats -f CIT-004` |
| PKG-3.1 | 1 | — | `tests/agtoosa.bats` | grep AGTOOSA_SHIP_DIR audit |
| PKG-1.2 | 2 | PKG-1.1 | `tests/agtoosa.bats` | `bats -f CIT-002` |
| PKG-1.3 | 2 | PKG-1.1 | `tests/agtoosa.bats` | `bats -f CIT-003` |
| PKG-1.4 | 2 | PKG-1.1, PKG-1.2, PKG-1.3 | — | `bats -f "NLM-|FIX-|CIT-"` |
| PKG-2.2 | 2 | PKG-2.1 | `docs/CLAUDE.md` | manual grep |
| PKG-3.2 | 2 | PKG-3.1 | `tests/agtoosa.bats` | 3× full bats |
| PKG-4.1 | 2 | PKG-1.1 | `docs/agtoosa-maintainer.md` | grep FIX-001 |
| PKG-4.2 | 2 | PKG-3.2 | `docs/AgToosa_TestPlan-DEV-113.md` | evidence block |

## ✅ Spec Approved

> **Approved:** 2026-07-12 — user: approve + build
