# Spec: DEV-008 — Workflow skill synthesis for AgToosa projects

> **Story ID:** DEV-008
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (2026-05-23)
> **Estimate:** M
> **Spec created:** 2026-05-23

## Context

AgToosa now installs native Codex workflow skills under `.codex/skills/agtoosa-*/SKILL.md`, but those files are currently thin dispatchers that only tell Codex to read the matching workflow doc. That is enough for discoverability, but it does not fully use the skill model: concise trigger metadata, phase-specific operating instructions, progressive disclosure, and optional project-specific resources.

The generated workflow docs already know the project shape during `/agtoosa-init` and the story shape during `/agtoosa-spec`. Those are the two points where AgToosa can identify skills that would be absolutely useful for a target project, such as domain-language reviewers, API contract validators, QA artifact generators, migration checkers, or release evidence collectors. This story defines the smallest useful version: make AgToosa workflow skills run the workflow with real guidance, and add approved project-skill synthesis during init/spec.

**Smart Interview findings:**

| Question | Finding |
|----------|---------|
| Status quo | `template/.codex/skills/agtoosa-*/SKILL.md` files exist but are minimal workflow redirects; `template/Docs/AgToosa_Skills.md` maps personas but does not define project-skill generation. |
| Narrowest scope | Improve Codex workflow skill files and docs so init/spec can propose or generate valid `.codex/skills/<skill>/SKILL.md` project skills behind user approval. |
| Urgency | The user requested better AgToosa SKILLS that run workflows and understand which skills are useful during init/spec. |
| 10-star version | Cross-platform skill synthesis for Codex, Claude, Copilot agents, and installable marketplace packs with evaluation harnesses. |
| Failure modes | Skill files stay as shallow dispatchers; init/spec generate noisy low-value skills; generated skills leak secrets or duplicate existing workflow capabilities. |
| Security surface | Local repo file generation only, but generated skills may describe external APIs, auth, or project-specific process knowledge, so secret handling and user approval are required. |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Upgrade AgToosa's skill surfaces so generated projects receive workflow skills that execute the lifecycle with useful context, and init/spec can identify and generate high-value project-specific skills. |
| User outcome | Developers using Codex/OpenCode can invoke AgToosa skills directly, and projects gain approved skill artifacts that encode project-specific workflows instead of relying on repeated chat instructions. |
| Success condition | All generated Codex workflow skills contain valid skill metadata and phase-specific execution guidance; `/agtoosa-init` and `/agtoosa-spec` document project/story skill synthesis with approval gates; bats coverage locks the behavior. |
| Proof / evidence | Focused bats tests validate skill frontmatter, workflow execution wording, init/spec synthesis sections, dedupe/approval guardrails, and installed file inventory. |
| Non-goals | External skill marketplace installation, automatic internet skill downloads, new CLI flags, auto-running generated skills, or full native parity for non-Codex skill systems in this story. |
| Assumptions | Codex remains the first-class generated skill surface because AgToosa already installs `.codex/skills/`; other platforms continue using their existing command/prompt/workflow adapters. |
| Risks | Over-generating skills may create maintenance noise; weak skill metadata may cause bad triggering; generated project skills may accidentally capture secrets if guardrails are vague. |
| Unresolved questions | Whether a follow-up should add optional Claude project-skill parity once Codex skill synthesis proves useful. |

### 1.2 User Stories

**As a** developer installing AgToosa for Codex/OpenCode, **I want** generated AgToosa workflow skills to carry enough instructions to run the matching workflow **so that** skill invocation is useful without manually rediscovering the command docs.

**As an** AgToosa project maintainer, **I want** `/agtoosa-init` to identify project-specific skills worth generating **so that** recurring project workflows become durable artifacts instead of chat-only preferences.

**As an** AgToosa story author, **I want** `/agtoosa-spec` to derive story-specific skill opportunities from the Goal Contract, acceptance criteria, and design **so that** specialist skills can be created only when they directly help implementation, review, or validation.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs a Codex workflow skill THE SYSTEM SHALL include valid `name` and `description` frontmatter plus concise workflow execution instructions in `SKILL.md` | Must |
| AC-002 | WHEN a generated AgToosa workflow skill is invoked THE SYSTEM SHALL direct the agent to read and execute the corresponding `Docs/AgToosa_*.md` workflow, including supported sub-command dispatch where applicable | Must |
| AC-003 | WHEN `/agtoosa-init` runs THE SYSTEM SHALL perform Project Skill Discovery and propose high-value project skills with name, trigger, purpose, inputs, optional resources, and validation approach | Must |
| AC-004 | WHEN `/agtoosa-spec` runs THE SYSTEM SHALL perform Story Skill Opportunity Synthesis from the Goal Contract, acceptance criteria, architecture, and test plan | Must |
| AC-005 | WHEN a project or story skill is generated THE SYSTEM SHALL create a valid `.codex/skills/<skill-name>/SKILL.md` using concise instructions, progressive disclosure, and only necessary `references/`, `scripts/`, or `assets/` folders | Must |
| AC-006 | WHEN skill generation or mutation would change files THE SYSTEM SHALL ask for explicit user approval and record the accepted/declined decision in the spec or Master-Plan update log | Must |
| AC-007 | WHEN a proposed skill duplicates an existing AgToosa workflow skill, platform adapter, or project skill THE SYSTEM SHALL update/reuse the existing artifact or recommend no new skill | Must |
| AC-008 | WHEN proposed skill content references secrets, credentials, private keys, tokens, or sensitive config THE SYSTEM SHALL exclude secret values and include a safety note instead | Must |
| AC-009 | WHEN this story is built THE SYSTEM SHALL add bats coverage for workflow skill frontmatter, workflow execution wording, init/spec synthesis sections, dedupe/approval guardrails, and generator install inventory | Must |
| AC-010 | IF optional skill UI metadata is requested THEN WHEN generation runs THE SYSTEM SHALL create only supported metadata files and SHALL NOT add README, quick-reference, or other auxiliary docs | Should |

**Failure modes (Must ACs):**

| AC | Failure mode |
|----|--------------|
| AC-001 | Skill files remain thin, metadata-free snippets that do not trigger reliably in Codex |
| AC-002 | Skill invocation tells the agent to read docs but not to execute workflow gates or sub-command dispatch |
| AC-003 | Init misses stable project workflows and forces the user to repeat project-specific instructions every session |
| AC-004 | Spec misses specialist skills needed for story validation, such as QA, API contract, or domain-language checks |
| AC-005 | Generated skills include noisy auxiliary docs or invalid folders that do not match Codex skill anatomy |
| AC-006 | Init/spec silently write new skill files without user consent |
| AC-007 | Duplicate skill generation creates conflicting trigger descriptions |
| AC-008 | Generated skills preserve secret material from context files or user prompts |
| AC-009 | Future template changes drift because tests only check file existence, not skill quality |

### 1.4 Out of Scope

- Installing skills from remote registries or marketplaces.
- Adding a new `agtoosa.sh` CLI flag for skill generation.
- Generating non-Codex native skill files beyond updating existing docs/adapters to describe the behavior.
- Auto-running any mutating workflow from a generated skill without the underlying workflow's existing approval gates.
- Creating project-specific skills when the candidate would not be reused or validated.

## 2. Design

### 2.1 Architecture Blueprint

```
Files to change during build:
  - template/.codex/skills/agtoosa-*/SKILL.md
  - template/Docs/AgToosa_Init.md
  - template/Docs/AgToosa_Spec.md
  - template/Docs/AgToosa_Skills.md
  - template/Docs/AgToosa_Agent.md
  - template/OPENCODE.md
  - docs/AgToosa_Skills.md
  - tests/agtoosa.bats

Files created during spec:
  - docs/adr/ADR-007-generated-project-skills.md
  - docs/AgToosa_TestPlan-workflow-skill-synthesis.md
```

Key behavior:

- AgToosa workflow skills become valid Codex skills with frontmatter and enough phase-specific instructions to execute the matching workflow.
- `/agtoosa-init` adds a Project Skill Discovery step after context gathering. It produces a short candidate table and asks before generating any project skill files.
- `/agtoosa-spec` adds Story Skill Opportunity Synthesis after architecture/test planning. It proposes only skills that clearly support repeated implementation, review, QA, or release evidence for that story.
- Generated project skills are created under `.codex/skills/<skill-name>/SKILL.md` and follow the same minimal anatomy: frontmatter, concise body, optional resources only when needed.
- Candidate generation is conservative: reuse existing AgToosa workflow skills first, prefer references over long inline bodies, and reject one-off skills.

### 2.2 Skill Candidate Format

`/agtoosa-init` and `/agtoosa-spec` should present candidates using this shape before any file write:

| Field | Description |
|-------|-------------|
| Skill name | Lowercase hyphen-case folder name under `.codex/skills/` |
| Trigger description | One sentence explaining exactly when the skill should activate |
| Purpose | The recurring project/story workflow this skill preserves |
| Inputs | Files or context the skill should read |
| Optional resources | `references/`, `scripts/`, or `assets/` only when justified |
| Validation | Command, checklist, or artifact review that proves the skill works |
| Decision | Generate / Update existing / Do not generate |

### 2.3 Data Flow

1. User runs `/agtoosa-init` or `/agtoosa-spec`.
2. Workflow reads project context, tech stack, workflow settings, domain language, and story details.
3. Workflow identifies repeated or fragile tasks that would benefit from a skill.
4. Workflow filters candidates:
   - remove one-off tasks;
   - remove duplicates of existing AgToosa workflow skills;
   - remove candidates without clear validation;
   - remove or redact any secret-bearing material.
5. Workflow presents the candidate table and asks for approval before file writes.
6. On approval, workflow writes valid `.codex/skills/<skill-name>/SKILL.md` files and optional resources.
7. Workflow records generated/declined skills in the spec or `Docs/Master-Plan.md` update log.

### 2.4 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Generated skill includes private token or config content | Information Disclosure | AC-008 secret exclusion and safety note |
| Generated skill silently mutates repo files during init/spec | Tampering | AC-006 explicit approval gate and update-log/spec record |
| Duplicate trigger descriptions cause the wrong skill to activate | Spoofing | AC-007 dedupe/reuse rule and bats content checks |
| Skill claims to run a workflow but skips required approval gates | Elevation of Privilege | AC-002 requires executing the canonical workflow doc, preserving its gates |
| Noisy skill generation bloats projects and confuses users | Denial of Service | Candidate filter rejects one-off or unvalidated skills |
| Future maintainer cannot tell why a skill was generated | Repudiation | Candidate decision recorded in spec or Master-Plan update log |

### 2.5 Build Scope

```
✅ Ready to proceed — Scope Boundary
Files in scope      : template/.codex/skills/agtoosa-*/SKILL.md, template/Docs/AgToosa_Init.md, template/Docs/AgToosa_Spec.md, template/Docs/AgToosa_Skills.md, template/Docs/AgToosa_Agent.md, template/OPENCODE.md, docs/AgToosa_Skills.md, tests/agtoosa.bats
Directories in scope: template/.codex/skills/, template/Docs/, docs/, tests/
Out of scope        : remote skill installation, new CLI flags, non-Codex generated skill formats, automatic skill execution without workflow gates, marketplace publishing
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Workflow skill contract
  - [x] 1.1 Audit all `template/.codex/skills/agtoosa-*/SKILL.md` files and define the shared minimum contract — _Requirements: AC-001, AC-002_
  - [x] 1.2 Update each workflow skill with valid frontmatter and concise execution guidance — _Requirements: AC-001, AC-002_
  - [x] 1.3 Ensure sub-command skills (`spec`, `status`, `help`, `goal`, `debug`, `concise`) describe dispatch behavior without duplicating full docs — _Requirements: AC-002_
- [x] **2.** Init/spec skill synthesis
  - [x] 2.1 Add Project Skill Discovery to `AgToosa_Init.md` with candidate format and approval gate — _Requirements: AC-003, AC-006, AC-008_
  - [x] 2.2 Add Story Skill Opportunity Synthesis to `AgToosa_Spec.md` with dedupe and validation rules — _Requirements: AC-004, AC-006, AC-007_
  - [x] 2.3 Update `AgToosa_Skills.md`, `AgToosa_Agent.md`, and `OPENCODE.md` to describe workflow skills and generated project skills — _Requirements: AC-003–AC-007_
- [x] **3.** Generation guardrails
  - [x] 3.1 Document generated project skill anatomy, naming rules, and optional resource rules — _Requirements: AC-005, AC-010_
  - [x] 3.2 Add secret-redaction and sensitive-config wording to init/spec skill generation steps — _Requirements: AC-008_
  - [x] 3.3 Require candidate decisions to be recorded in the spec or Master-Plan update log — _Requirements: AC-006_
- [x] **4.** Bats coverage
  - [x] 4.1 Add tests that all Codex AgToosa skills have frontmatter `name` and `description` — _Requirements: AC-001, AC-009_
  - [x] 4.2 Add tests that workflow skills point to the canonical workflow docs and use execute/run wording — _Requirements: AC-002, AC-009_
  - [x] 4.3 Add tests for Project Skill Discovery and Story Skill Opportunity Synthesis headings and guardrails — _Requirements: AC-003, AC-004, AC-006–AC-008_
  - [x] 4.4 Add tests that generator install/list inventory still includes `.codex/skills` files — _Requirements: AC-009_
- [x] **5.** Validation
  - [x] 5.1 Run focused bats tests for Codex skills and skill synthesis wording — _Requirements: AC-009_
  - [x] 5.2 Run full `bats tests/agtoosa.bats` or record any pre-existing failures — _Requirements: AC-009_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2, 3.1  
**Wave 2 (parallel):** 1.2, 1.3, 2.3, 3.2, 3.3  
**Wave 3 (sequential):** 4.1, 4.2, 4.3, 4.4  
**Wave 4 (validation):** 5.1, 5.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-workflow-skill-synthesis.md`  
AC coverage: 10 ACs mapped to 10 test IDs  
Smoke set: 9 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-23 18:30
