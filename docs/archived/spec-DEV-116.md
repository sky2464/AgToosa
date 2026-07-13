# Spec: DEV-116 — AgToosa Lifecycle Compass

> **Story ID:** DEV-116  
> **Epic:** DEV-002 — Workflow Templates  
> **Status:** 🟦 Todo — Spec Approved  
> **Estimate:** M  
> **Clarity:** ready  
> **Spec created:** 2026-07-12  
> **ADR:** `docs/adr/ADR-014-lifecycle-compass.md`  
> **Design:** `docs/superpowers/specs/2026-07-12-lifecycle-compass-design.md`  
> **Parent:** DEV-110 (Project Intake) · DEV-109 (`--status-line`) · DEV-112 (NL Intent Map — superseded by Compass)

## Context

DEV-110 shipped **AgToosa Project Intake** — dual-mode soft/hard classification for freeform asks. DEV-112 added a **Natural Language Intent Map** — a phrase table mapping "plan and code", "build it", "review it", "ship it" to lifecycle workflows.

Users still speak naturally: "add OAuth", "why is CI red?", "look at my changes", "can we ship this week?". The phrase table does not generalize. Agents may code without spec (under-route), block tiny fixes with ceremony (over-route), or fail to pick the correct lifecycle phase.

**AgToosa Lifecycle Compass** extends Project Intake with:

- Semantic intent understanding (not phrase matching)
- Deterministic project-state pulse via `--status-line` (and optional JSON route hint)
- Lifecycle-first **ANCHOR** branding on Spec → Build → Review → Ship
- **Tributary** paths (explore, fix, track) that serve a phase and return to the lifecycle

**Smart interview decisions (recorded — brainstorming 2026-07-12):**

| Decision | Choice |
|----------|--------|
| Approach | Hybrid B+ — agent semantics + deterministic state (`--status-line`; optional `--route-hint --format json`) |
| Branding | **AgToosa Lifecycle Compass**; lines: `Compass:`, `ANCHOR:`, tributary `serving <phase>`, `When done: return to` |
| Lifecycle north star | All resolutions anchor to `spec` · `build` · `review` · `ship`; tributaries allowed but must return |
| Supersedes | NL Intent Map phrase table in Agent.md + `agtoosa-core.mdc` (retain Project Intake soft/hard gate) |
| Delivery | Always-on core rule summary + full protocol in Agent.md; no `/agtoosa-compass` slash command |
| Phase Stop | Preserved — Compass picks workflow; never auto-chains phases |
| Release target | PATCH **v5.3.28** when shipped |

**Story Skill Opportunity Synthesis (2026-07-12):**

| Skill name | Trigger | Purpose | Decision | Reason |
|------------|---------|---------|----------|--------|
| `lifecycle-compass` | Freeform ask | Route to lifecycle phase | **Do not generate** | Reserved `agtoosa-*` namespace; belongs in always-on Agent + core rule |
| `agtoosa-help` duplicate | State read | Suggest next command | **Do not generate** | help-next is suggest-only; Compass reconciles + expedites |

### Spec Quality Analyzer (2026-07-12)

| Check | Result |
|-------|--------|
| Must ACs testable and unambiguous | Pass |
| Goal / scope / AC / task / test-plan alignment | Pass |
| Must AC → test-plan mapping | Pass — see test plan |
| Claim Boundary classified | Pass — §1.6 |
| Master-Plan source of truth preserved | Pass |
| TBD / placeholder requirements | Pass |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | When users omit `/agtoosa-*` and everyday language, AgToosa infers the right lifecycle phase (Spec → Build → Review → Ship), allows tributary side work, and prevents under-routing and over-routing. |
| User outcome | Freeform prompts like "add dark mode", "tests are failing", or "ready to release?" route intelligently without memorizing slash commands or magic phrases; small fixes still expedite; large work still hard-gates to Spec. |
| Success condition | NL Intent Map replaced by Lifecycle Compass in Agent + core rules + platform entry pointers; mandatory `--status-line` preamble documented; tributary return cues documented; CMP bats green; optional `--route-hint --format json` if CLI task ships. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-116.md`; bats filter `DEV-116` / `CMP-`; review evidence at ship. |
| Non-goals | Runtime workflow engine; `/agtoosa-compass` slash command; shell NLP on utterances; auto-chaining Spec→Build→Review→Ship; replacing Discovery Triage mid-build; removing Project Intake soft/hard gate. |
| Assumptions | DEV-110 intake and DEV-109 `--status-line` remain installed; Compass extends rather than replaces intake Claim Boundary. |
| Risks | Rule surface growth; agents skip `--status-line` read; JSON hint drifts from `run_status_line` logic. Mitigate with concise core summary, CMP bats, shared Python block in `maintain.sh`. |
| Unresolved questions | None for Must scope. |

### 1.2 User Stories

**As an** AgToosa user who speaks naturally, **I want** freeform asks anchored to Spec → Build → Review → Ship **so that** I do not need magic phrases or perfect slash hygiene.

**As an** AgToosa user doing quick exploration or fixes, **I want** tributary work allowed **so that** I can ask questions or fix small bugs without leaving the lifecycle.

**As an** AgToosa maintainer, **I want** deterministic state in `--status-line` (and optional JSON) **so that** the phase half of routing is testable in bats.

**As an** AgToosa agent, **I want** a reconciliation matrix for intent × project state **so that** I do not code when SYNC says `next /agtoosa-spec`.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the user sends a freeform request without `/agtoosa-*` THE SYSTEM SHALL run **AgToosa Lifecycle Compass** after reading Standing Corrections: run `agtoosa.sh --status-line [path]` (or equivalent Master-Plan read), infer semantic intent, apply Claim Boundary (soft/hard), reconcile intent with SYNC state, and name exactly one **ANCHOR** (`spec` · `build` · `review` · `ship` · `none`) | Must |
| AC-002 | WHEN Compass resolves a freeform ask THE SYSTEM SHALL replace the NL Intent Map phrase table with semantic intent classes (plan/build/review/ship/fix/explore/track) documented in `Docs/AgToosa_Agent.md` — examples are illustrative, not exhaustive phrase lists | Must |
| AC-003 | WHEN Compass routes on the soft path THE SYSTEM SHALL print a branded one-liner `Compass: soft → <phase> — <rationale>` before expediting | Must |
| AC-004 | WHILE Claim-Boundary hard triggers apply WHEN Compass routes THE SYSTEM SHALL not modify product/implementation code until user confirms; THE SYSTEM SHALL present benefit-framed `**AgToosa Lifecycle Compass**` copy with `ANCHOR: <phase>` naming `/agtoosa-<phase>` | Must |
| AC-005 | WHEN the ask is tributary work (explore, Claim-Boundary-small fix, or track) THE SYSTEM SHALL allow execution in the background, print `Compass: tributary (<type>) → serving <phase> · <story-id\|none>`, and end with `When done: return to /agtoosa-<phase> — <rationale>` citing SYNC when available | Must |
| AC-006 | WHEN user semantic intent conflicts with SYNC `next` (e.g. user implies build but SYNC says `next /agtoosa-spec`) THE SYSTEM SHALL explain the mismatch, anchor to the lifecycle-correct phase, and SHALL NOT silently implement product code on the wrong phase | Must |
| AC-007 | WHEN intent is ambiguous THE SYSTEM SHALL ask exactly one disambiguation question with multiple-choice options (plan / build / fix / review) — not a multi-question interview | Must |
| AC-008 | WHEN explicit `/agtoosa-*` is invoked THE SYSTEM SHALL bypass Compass ceremony and run the named workflow (Standing Corrections still apply) | Must |
| AC-009 | WHEN Compass recommends Spec, Build, Review, or Ship THE SYSTEM SHALL preserve Phase Stop — never auto-chain Spec→Build→Review→Ship | Must |
| AC-010 | WHEN `template/.cursor/rules/agtoosa-core.mdc` and maintainer `agtoosa-maintainer-core.mdc` ship THE SYSTEM SHALL include a concise Lifecycle Compass summary (ANCHOR, tributary, mandatory `--status-line`, return cue) pointing to Agent.md for full protocol | Must |
| AC-011 | WHEN platform entry points (CLAUDE.md, AGENTS.md, Quickref, `.cursorrules`) mention freeform routing THE SYSTEM SHALL use Lifecycle Compass branding and lifecycle-first language (not "NL Intent Map" alone) | Should |
| AC-012 | WHEN `agtoosa.sh --status-line [path] --route-hint --format json` is implemented THE SYSTEM SHALL emit JSON with at least `sync`, `anchor`, `story_id`, `tasks_done`, `tasks_total` derived from the same Master-Plan parse as plain `--status-line`; Bash and PS1 Must parity if PS1 flag ships | Should |
| AC-013 | WHEN `tests/agtoosa.bats` runs DEV-116 coverage THE SYSTEM SHALL assert Compass contract strings, ANCHOR/tributary wording, Phase Stop preservation, and template↔docs mirrors per CMP table | Must |
| AC-014 | WHEN shipping THE SYSTEM SHALL record RED/GREEN evidence in the test plan without claims beyond completed scope | Must |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Freeform asks skip state read; wrong lifecycle phase |
| AC-002 | Phrase-table regression; paraphrases miss routing |
| AC-003 | Soft path loses branded compass line; user cannot audit route |
| AC-004 | Large asks silently coded; Master Plan drifts |
| AC-005 | Tributaries become permanent off-ramp; lifecycle abandoned |
| AC-006 | Build runs without approved spec when SYNC says spec |
| AC-007 | Ambiguity causes questionnaire spam or silent guess |
| AC-008 | Double ceremony on explicit slash commands |
| AC-009 | Compass auto-chains phases after confirm |
| AC-010 | Core rule omits Compass; agents never load protocol |
| AC-013 | Regressions ship without contract bats |

### 1.4 Out of Scope

- Runtime orchestrator or forced tool interception
- `/agtoosa-compass` slash command or generated skill
- Shell-based natural-language classification of user utterances
- Replacing Project Intake Claim Boundary or Standing Corrections
- Replacing Discovery Triage mid-build
- Changing `--status-line` SYNC format (extend only with optional JSON)
- Full platform adapter rewrite beyond entry-point pointer updates

### 1.5 Brownfield Drift Baseline

| Field | Value |
|-------|-------|
| Current-state baseline | NL Intent Map phrase table in Agent.md + `agtoosa-core.mdc`; Project Intake soft/hard without semantic×state reconciliation; `--status-line` exists but is not mandatory on freeform preamble |
| Intended change deltas | Lifecycle Compass protocol; ANCHOR + tributary branding; mandatory state pulse; optional JSON route hint; CMP bats |
| Drift evidence | Brainstorming session 2026-07-12; user requirement D (under/over/phase ambiguity) |
| Claim Boundary | See §1.6 |
| Source of truth | `docs/Master-Plan.md` remains repo-local SoT |

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Compass semantic classes, reconciliation matrix, ANCHOR/tributary copy, disambiguation rules | agent-instructed |
| `--route-hint --format json` in `run_status_line` / PS1 parity | generator-enforced |
| CMP bats / doc greps in CI when configured | CI-enforced |
| Active Cycle enrollment for DEV-116 | manual |
| Runtime auto-dispatch on utterance | roadmap / out of scope |

## 2. Design

### 2.1 Architecture Blueprint

**Brand voice (normative shapes):**

Soft path:

```text
Compass: soft → build — in-scope fix under DEV-042; expediting.
```

Hard gate:

```text
**AgToosa Lifecycle Compass** — New capabilities belong in Spec before Build.
This keeps your Master Plan honest and prevents untracked AI drift.
ANCHOR: spec — confirm to open /agtoosa-spec, or say how you want to override.
```

Tributary:

```text
Compass: tributary (explore) → serving build · DEV-042
When done: return to /agtoosa-build — SYNC: next /agtoosa-build
```

**Mandatory freeform preamble (extends Project Intake step 1–3):**

1. Read `Docs/Context/workflow.md` → Standing Corrections
2. Run `bash agtoosa.sh --status-line [path]` (or `agtoosa.ps1 -StatusLine`; fallback: read Master-Plan Active Cycle)
3. Infer semantic intent class from utterance (not phrase table lookup)
4. Classify Claim Boundary soft/hard (existing intake triggers)
5. Reconcile intent × SYNC `next` × hard triggers → ANCHOR + destination workflow
6. Soft expedite or hard-gate confirm; tributaries print return cue

**Semantic intent classes → lifecycle ANCHOR:**

| Class | Typical meaning | ANCHOR | Primary workflow |
|-------|-----------------|--------|------------------|
| PLAN | New capability, architecture, scope expand | `spec` | `/agtoosa-spec` |
| BUILD | Implement approved work, finish tasks | `build` | `/agtoosa-build` |
| REVIEW | Audit, check quality, PR review | `review` | `/agtoosa-review` |
| SHIP | Release, deploy, publish | `ship` | `/agtoosa-ship` |
| FIX | Small bug/chore (Claim-Boundary-small) | active phase | tributary → expedite |
| EXPLORE | Read-only questions | active phase | tributary → answer |
| TRACK | Log backlog item | `spec` | tributary → `/agtoosa-task` |

**Reconciliation matrix (intent × SYNC — normative):**

| Condition | Route |
|-----------|-------|
| PLAN or hard-sized ask | Hard gate → ANCHOR `spec` |
| BUILD intent + SYNC `next /agtoosa-spec` | Explain mismatch → ANCHOR `spec` |
| BUILD intent + active tasks remain | ANCHOR `build` → `/agtoosa-build` |
| REVIEW intent + tasks incomplete | Explain → finish build or scope review |
| REVIEW intent + tasks complete | ANCHOR `review` |
| SHIP intent + review not done | ANCHOR `review` first |
| FIX + Claim-Boundary-small | tributary fix → serving active ANCHOR |
| EXPLORE | tributary explore → serving active ANCHOR |
| Low confidence | One A/B/C/D disambiguation question |

**Files to create/update (build phase):**

| Surface | Action |
|---------|--------|
| `docs/adr/ADR-014-lifecycle-compass.md` | Mark Accepted on build start |
| `template/Docs/AgToosa_Agent.md` + `docs/` mirror | Replace **Natural Language Intent Map** with **AgToosa Lifecycle Compass** |
| `template/.cursor/rules/agtoosa-core.mdc` + `.cursor/rules/agtoosa-maintainer-core.mdc` | Compass summary; mandatory `--status-line`; remove phrase-only table |
| `template/CLAUDE.md`, `template/AGENTS.md`, `template/.cursorrules` | Lifecycle Compass pointer |
| `template/Docs/AgToosa_Quickref.md` + `docs/` mirror | One-line Compass + lifecycle anchor |
| `template/Docs/Context/CONTEXT.md` + `docs/` mirror | Glossary: Lifecycle Compass, ANCHOR, tributary |
| `lib/maintain.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh` | Optional `--route-hint --format json` (Should) |
| `tests/agtoosa.bats` | CMP-001–CMP-006 |

### 2.2 Data Flow

1. User sends freeform message without `/agtoosa-*`.
2. Agent loads always-on core rule → Compass summary.
3. Agent reads Standing Corrections from `workflow.md`.
4. Agent runs `--status-line` → receives `SYNC: … · next /agtoosa-<phase>` (optional JSON `anchor`).
5. Agent classifies utterance into semantic intent class.
6. Agent applies Claim Boundary (soft/hard) from intake.
7. Agent reconciles intent × SYNC × hard triggers → single ANCHOR.
8. Soft: print `Compass: soft → …` and expedite under destination workflow rules.
9. Hard: print `**AgToosa Lifecycle Compass**` + `ANCHOR:` → await confirm → begin named workflow file (Phase Stop).
10. Tributary: execute side work → print return cue to lifecycle phase.
11. Explicit `/agtoosa-*` later bypasses steps 5–9 ceremony.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent codes architecture without spec | Elevation of privilege | Hard gate + AC-006 state mismatch stop |
| Wrong phase causes skipped review/ship | Tampering | ANCHOR + SYNC reconciliation matrix |
| Compass copy drift across platforms | Spoofing | CMP bats grep-lock branded strings |
| JSON route hint leaks paths | Information disclosure | Read-only Master-Plan parse; no secrets in output |
| Over-interview on ambiguous asks | Denial of Service | AC-007 single multiple-choice question cap |

### 2.4 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : docs/adr/ADR-014-lifecycle-compass.md, docs/archived/spec-DEV-116.md, docs/AgToosa_TestPlan-DEV-116.md, docs/superpowers/specs/2026-07-12-lifecycle-compass-design.md, template/Docs/AgToosa_Agent.md, docs/AgToosa_Agent.md, template/.cursor/rules/agtoosa-core.mdc, .cursor/rules/agtoosa-maintainer-core.mdc, template/CLAUDE.md, template/AGENTS.md, template/.cursorrules, template/Docs/AgToosa_Quickref.md, docs/AgToosa_Quickref.md, template/Docs/Context/CONTEXT.md, docs/Context/CONTEXT.md, lib/maintain.sh, agtoosa.sh, agtoosa.ps1, lib/config.sh, tests/agtoosa.bats
Directories in scope: template/Docs/, docs/, template/.cursor/rules/, .cursor/rules/, lib/
Out of scope        : Runtime orchestrator, /agtoosa-compass command, Discovery Triage rewrite, changing SYNC line format, full 19-command maintainer mirror
```

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** ADR + Agent protocol
  - [ ] 1.1 Mark ADR-014 Accepted; write full **AgToosa Lifecycle Compass** section in `template/Docs/AgToosa_Agent.md` (replace NL Intent Map) — _Requirements: AC-001, AC-002, AC-006, AC-007, AC-009_
  - [ ] 1.2 Mirror Agent Compass section to `docs/AgToosa_Agent.md` with `docs/` paths — _Requirements: AC-001, AC-002_
- [ ] **2.** Always-on rules + entry points
  - [ ] 2.1 Update `agtoosa-core.mdc` + `agtoosa-maintainer-core.mdc` with Compass summary, ANCHOR, tributary return cue, mandatory `--status-line` — _Requirements: AC-003, AC-005, AC-010_
  - [ ] 2.2 Update CLAUDE.md, AGENTS.md, `.cursorrules`, Quickref, CONTEXT.md (template + docs mirrors) — _Requirements: AC-011_
- [ ] **3.** Optional CLI route hint (Should)
  - [ ] 3.1 Extend `run_status_line` + `agtoosa.sh`/`agtoosa.ps1`/`lib/config.sh` for `--route-hint --format json` — _Requirements: AC-012_
  - [ ] 3.2 CMP bats for JSON fields — _Requirements: AC-012, AC-013_
- [ ] **4.** Contract tests + evidence
  - [ ] 4.1 Add CMP-001–CMP-006 to `tests/agtoosa.bats`; capture RED then GREEN in test plan — _Requirements: AC-013, AC-014_

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1  
**Wave 2 (sequential after Wave 1):** 1.2, 2.2  
**Wave 3 (optional Should):** 3.1, 3.2  
**Wave 4 (after Wave 2):** 4.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-116.md`  
AC coverage: 14 ACs mapped to CMP-001–CMP-006  
Smoke set: CMP-001, CMP-002, CMP-003, CMP-004 @smoke

### 3.4 Work Package DAG

| package_id | wave | depends_on | owned_files | inputs | outputs | merge_order | verification |
|------------|------|------------|-------------|--------|---------|-------------|--------------|
| PKG-1.1 | 1 | — | `template/Docs/AgToosa_Agent.md`, `docs/adr/ADR-014-lifecycle-compass.md` | ADR-014 draft | Agent Compass section | 1 | `grep -q 'AgToosa Lifecycle Compass' template/Docs/AgToosa_Agent.md` |
| PKG-2.1 | 1 | — | `template/.cursor/rules/agtoosa-core.mdc`, `.cursor/rules/agtoosa-maintainer-core.mdc` | — | updated core rules | 1 | `grep -q 'ANCHOR' template/.cursor/rules/agtoosa-core.mdc` |
| PKG-1.2 | 2 | PKG-1.1 | `docs/AgToosa_Agent.md` | PKG-1.1 | docs mirror | 2 | `grep -q 'Lifecycle Compass' docs/AgToosa_Agent.md` |
| PKG-2.2 | 2 | PKG-2.1 | `template/CLAUDE.md`, `template/AGENTS.md`, Quickref, CONTEXT | PKG-2.1 | entry pointers | 2 | `bats -f CMP-004` |
| PKG-3.1 | 3 | PKG-1.1 | `lib/maintain.sh`, `agtoosa.sh`, `agtoosa.ps1`, `lib/config.sh` | — | JSON route hint | 3 | `bash agtoosa.sh --status-line . --route-hint --format json` |
| PKG-4.1 | 4 | PKG-1.2, PKG-2.2 | `tests/agtoosa.bats`, test plan | Waves 1–2 outputs | CMP bats green | 4 | `bats -f DEV-116` |

## ✅ Spec Approved

Approved: 2026-07-12 20:38

