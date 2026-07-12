# Spec: DEV-083 — Voluntary Workflow Metrics and Case Study Kit

> **Story ID:** DEV-083
> **Epic:** DEV-004 — Testing & QA Harness
> **Type:** Docs
> **Priority:** P2
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

AgToosa has repo-local artifacts that can support voluntary learning, but it does not need a telemetry service to define useful measures. Teams may want consistent ways to discuss installation, verifier use, handoffs, cross-model review, cycle time, and pack maintenance without sending repository activity anywhere.

DEV-083 defines copyable measurement and case-study templates. Collection, calculation, redaction, and sharing remain explicit user actions. This backlog spec does not claim any measurements have been taken or any case study exists.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a no-telemetry, voluntary kit for six workflow measures and evidence-bounded case studies. |
| User outcome | Teams can evaluate AgToosa adoption with shared definitions while retaining control over whether local data is collected, calculated, or shared. |
| Success condition | The kit defines consent and privacy boundaries, a common measurement schema, a case-study template, and usable templates for install success, verifier adoption, handoff/import, cross-model findings, cycle time, and pack maintenance. |
| Proof / evidence | Required before completion: documentation-contract tests, worked synthetic examples, privacy/claim-boundary review, and install/update inventory checks. No evidence has been collected. |
| Non-goals | Telemetry, hosted analytics, benchmark claims, automated reporting, individual performance scoring, or any parked roadmap item in §1.4. |
| Assumptions | Users may derive values manually from repo-local records; missing data is expected and must not be silently imputed. |
| Risks | Definitions may encourage false comparisons; small samples may expose identities; metrics may become targets; synthetic examples may be mistaken for real outcomes. |
| Unresolved questions | None; teams choose locally whether to use or share the optional templates. |

### 1.2 User Stories

**As a** project lead, **I want** voluntary, consistently defined workflow measures **so that** I can discuss adoption without installing analytics infrastructure.

**As a** contributor, **I want** explicit consent, redaction, and missing-data rules **so that** repo-local activity is not silently converted into surveillance.

**As an** AgToosa maintainer, **I want** an evidence-bounded case-study format **so that** anecdotes do not become unsupported product claims.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the metrics kit is used THE SYSTEM SHALL require explicit opt-in, keep source data local by default, define redaction and withdrawal steps, and SHALL NOT add collection hooks, network submission, background analytics, or automatic reporting | Must |
| AC-002 | WHEN a metric or case study is authored THE SYSTEM SHALL record purpose, definition, population, numerator/denominator or unit, time window, local source, exclusions, missing-data handling, calculation method, privacy review, evidence links, limitations, and publication consent | Must |
| AC-003 | WHEN install success is measured THE SYSTEM SHALL distinguish attempts, successful completion, standard post-install check, failure stage, platform, version, and retry without treating downloads or starts as success | Must |
| AC-004 | WHEN verifier adoption is measured THE SYSTEM SHALL distinguish eligible projects or cycles, verifier availability, actual runs, mode, result, follow-up, and observation window without equating availability with use | Must |
| AC-005 | WHEN handoff/import is measured THE SYSTEM SHALL distinguish packs exported, import attempts, successful imports, rejected or partial imports, target surface, and completion criteria without collecting pack content | Must |
| AC-006 | WHEN cross-model findings are measured THE SYSTEM SHALL distinguish proposed, confirmed, duplicate, rejected, and resolved findings by declared severity and SHALL NOT use counts as individual performance scores | Must |
| AC-007 | WHEN cycle time is measured THE SYSTEM SHALL define start and end events, pauses, manual/deferred intervals, incomplete cycles, timezone, aggregation, and sample size without inventing missing timestamps | Must |
| AC-008 | WHEN pack maintenance is measured THE SYSTEM SHALL define pack/version population, compatibility review age, open maintenance items, owner response state, deprecation state, and observation date without implying an SLA | Must |

**Failure modes:**

| AC | Failure mode | Required response |
|----|--------------|-------------------|
| AC-001 | A template sends data or enables collection by default | Reject the kit change; voluntary local entry is the boundary. |
| AC-002 | A percentage lacks its population, window, or missing-data rule | Mark it undefined and do not publish it. |
| AC-003 | Installation start is counted as successful installation | Recalculate using completion plus the declared post-install check. |
| AC-004 | Verifier presence is reported as verifier adoption | Separate availability from observed runs. |
| AC-005 | Handoff pack content is copied into a metric record | Remove content; retain only the minimal voluntary outcome fields. |
| AC-006 | Raw finding count is used to rank contributors | Remove the ranking and restate the non-performance boundary. |
| AC-007 | Missing start/end timestamps are estimated silently | Mark the cycle incomplete or document an explicit exclusion. |
| AC-008 | Maintenance age is presented as a promised response time | Correct the statement; the metric is descriptive, not an SLA. |

### 1.4 Out of Scope

- Any SaaS or hosted analytics/control plane
- SSO or RBAC
- An MCP runtime
- An autonomous build runtime
- A federated registry
- A marketplace or public ranking system
- Silent telemetry, hidden identifiers, background collection, or automatic reporting
- A Go or Rust rewrite
- A telemetry endpoint, analytics SDK, beacon, collector, dashboard backend, or data warehouse
- Automatic scraping of repositories, issues, agents, editors, CI providers, or external registries
- Individual productivity scoring, contributor ranking, comparative leaderboards, or employment evaluation
- Claims of causation, representative market benchmarks, guaranteed outcomes, or SLAs

The parked roadmap and telemetry items above are exclusions, not DEV-083 subtasks.

### 1.5 Claim Boundary

| Surface or claim | Classification | Boundary |
|------------------|----------------|----------|
| Metric definitions and blank templates | Documentation / agent-instructed | They define optional methods; they collect nothing. |
| Synthetic worked examples | Documentation test fixtures | Illustrative only and clearly labeled as non-customer data. |
| User-entered local measurements | Manual / user-controlled | AgToosa does not receive, verify, or retain them. |
| Case-study publication | Manual consent | Sharing requires deliberate redaction, evidence review, and approval by the data owner. |
| Derived trends or comparisons | Analytical claim | Limited to the declared sample, method, and observation window; no causation implied. |
| Install inventory and contract checks | Generator/CI-enforced-able after implementation | They can prove files and required language, not real-world outcomes. |

## 2. Design

### 2.1 Architecture Blueprint

Proposed future surfaces:

| Surface | Responsibility |
|---------|----------------|
| `template/Docs/AgToosa_MetricsKit.md` | Canonical consent boundary, common schema, six measurement templates, interpretation guidance, and synthetic examples |
| `docs/AgToosa_MetricsKit.md` | Maintainer mirror with repo-local paths |
| `template/Docs/AgToosa_CaseStudy.template.md` | Copyable context, method, metric, evidence, limitation, consent, and publication checklist |
| `docs/AgToosa_CaseStudy.template.md` | Maintainer mirror for dogfood and contract review |
| `lib/config.sh` | Install/update inventory for the two documentation artifacts |
| `tests/agtoosa.bats` | MET documentation, no-telemetry, mirror, and inventory contracts |

Key interfaces:

- Common metric record: metadata fields in AC-002 plus one of the six metric-specific sections.
- Case study: context → question → method → voluntary data → result → limitations → consent → claim review.
- Source boundary: user-selected repo-local records or manual observations; no automatic reader or sender.

### 2.2 Data Flow

1. A user explicitly chooses whether to use a blank metric or case-study template.
2. The user defines the purpose, population, window, source, exclusions, and privacy boundary before entering values.
3. The user manually copies the minimum necessary local observations into the chosen template.
4. The user calculates the measure using the documented formula and preserves missing or incomplete states.
5. The user reviews interpretation limits, sample size, redaction, and potential misuse.
6. For a case study, evidence links and synthetic-versus-observed labels are checked.
7. The data owner explicitly approves, narrows, or declines publication.
8. Nothing is transmitted by AgToosa; any sharing is an intentional action outside the kit.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A case study falsely claims to represent another team | Spoofing | Require source ownership and publication-consent fields. |
| Values or definitions are changed after calculation | Tampering | Record method, source snapshot/reference, date, and revision notes. |
| A publisher denies exclusions or limitations | Repudiation | Keep an explicit review and consent checklist with dated approval. |
| Small samples reveal people, repositories, or pack content | Information Disclosure | Minimize fields, redact identifiers, aggregate where safe, and permit withdrawal. |
| Metric completion becomes a required workflow gate | Denial of Service | State that every template is optional and blank/missing is valid. |
| Managers use finding counts to rank individuals | Elevation of Privilege | Prohibit individual scoring and include misuse warnings in the cross-model template. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : future metrics-kit and case-study template sources/mirrors, documentation inventory wiring, and focused MET contract tests
Directories in scope: `template/Docs/`, `docs/`, `lib/config.sh`, and `tests/`
Data collection     : none
Out of scope        : all §1.4 exclusions, network code, analytics infrastructure, automatic repository parsing, and publication of a real case study

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Define the voluntary measurement contract
  - [ ] 1.1 Write opt-in, local-only, minimization, redaction, withdrawal, and consent rules — _Requirements: AC-001, AC-002_
  - [ ] 1.2 Define the common metric schema, interpretation rules, and synthetic-example labels — _Requirements: AC-002_
- [ ] **2.** Author the six metric templates
  - [ ] 2.1 Define install-success fields and formula — _Requirements: AC-003_
  - [ ] 2.2 Define verifier-adoption fields and formula — _Requirements: AC-004_
  - [ ] 2.3 Define handoff/import fields and formula — _Requirements: AC-005_
  - [ ] 2.4 Define cross-model-finding fields and interpretation boundary — _Requirements: AC-006_
  - [ ] 2.5 Define cycle-time fields, pauses, and incomplete-state handling — _Requirements: AC-007_
  - [ ] 2.6 Define pack-maintenance fields and no-SLA boundary — _Requirements: AC-008_
- [ ] **3.** Complete the documentation kit
  - [ ] 3.1 Author the case-study template with evidence, limitations, consent, and claim review — _Requirements: AC-001, AC-002_
  - [ ] 3.2 Add clearly labeled synthetic worked examples and maintainer mirrors — _Requirements: AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008_
  - [ ] 3.3 Register the two kit files for install/update without collection hooks — _Requirements: AC-001_
- [ ] **4.** Prove the documentation contract
  - [ ] 4.1 Add MET tests for required fields, six metric sections, mirror parity, and no-telemetry language before implementation — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008_
  - [ ] 4.2 Record actual RED/GREEN and privacy-review evidence only during future execution — _Requirements: AC-001, AC-002_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 4.1  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 2.3, 2.4, 2.5, 2.6  
**Wave 3 (parallel after Wave 2):** 3.1, 3.2  
**Wave 4 (sequential after Wave 3):** 3.3, 4.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-083.md`
AC coverage: 8 ACs mapped to 10 planned MET test IDs
Smoke set: 4 planned tests tagged `@smoke`
Evidence state: RED and GREEN are unexecuted placeholders; no metric or case-study evidence is claimed.

## ✅ Spec Approved

Approved: 2026-07-11 21:25
Enrollment: remaining-specs fan-out wave 1 (build/review/ship)
