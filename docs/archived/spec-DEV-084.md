# Spec: DEV-084 — Open-Source Sustainability and Support Boundary

> **Story ID:** DEV-084
> **Epic:** DEV-004 — Testing & QA Harness
> **Type:** Chore
> **Priority:** P2
> **Status:** ⬜ Backlog
> **Estimate:** XS
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

AgToosa already exposes a GitHub Sponsors configuration, public support guidance, contribution guidance, and a security policy. These surfaces do not yet form one explicit boundary between voluntary sponsorship, best-effort open-source support, private security reporting, sponsored educational content, and optional consulting. Fixed response language can also be mistaken for a support SLA when no such service has been established.

DEV-084 aligns those public statements. It does not create paid feature tiers, promise response times, process payments, or establish a consulting engagement.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Define a consistent, transparent boundary for GitHub Sponsors, community support, security reporting, sponsored educational content, and optional consulting without feature gates or SLA overclaims. |
| User outcome | Users know where to ask for help, what response to expect, what sponsorship does and does not provide, and how optional consulting relates to the open-source project. |
| Success condition | Public funding/support/security/contribution surfaces use one consistent disclosure; sponsorship remains voluntary; sponsored content is disclosed; open-source features remain ungated; consulting is separate; unsupported response guarantees are removed or explicitly non-contractual. |
| Proof / evidence | Required before completion: static wording checks, public-link review, cross-surface consistency review, and manual confirmation of the configured sponsor destination. No evidence has been collected. |
| Non-goals | Paid support operations, an SLA, feature tiers, payment processing, legal/tax advice, or any parked roadmap item in §1.4. |
| Assumptions | GitHub remains the public project host; the MIT license and public contribution process remain unchanged; maintainers may offer consulting independently. |
| Risks | Sponsorship may be mistaken for purchased priority; consulting may appear to control roadmap decisions; security reporters may rely on an unsupported deadline; duplicated wording may drift. |
| Unresolved questions | The maintainer must confirm the configured GitHub Sponsors destination is active and correct before publication. |

### 1.2 User Stories

**As an** open-source user, **I want** clear support channels and best-effort expectations **so that** I do not infer a guaranteed response or resolution time.

**As a** potential sponsor, **I want** to understand that sponsorship is voluntary and does not buy product access or roadmap control **so that** the relationship is transparent.

**As a** potential consulting client or contributor, **I want** paid services disclosed as separate from project governance and feature access **so that** conflicts and expectations are visible.

**As a** reader of sponsored educational material, **I want** clear disclosure of the sponsor and editorial boundary **so that** promotion cannot be mistaken for independent product evidence.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN GitHub Sponsors is presented THE SYSTEM SHALL identify the official external destination, state that sponsorship is voluntary, and state that sponsorship does not guarantee support priority, response time, roadmap influence, private releases, or feature access | Must |
| AC-002 | WHEN a user seeks help THE SYSTEM SHALL route questions, reproducible bugs, feature proposals, and private vulnerability reports to distinct documented channels with the information expected for each | Must |
| AC-003 | WHEN support availability or timing is described THE SYSTEM SHALL characterize community maintenance as best effort and SHALL NOT promise acknowledgement, response, resolution, uptime, business hours, or an SLA unless a separately executed agreement provides it | Must |
| AC-004 | WHEN consulting or sponsored educational content is disclosed THE SYSTEM SHALL state that it is optional or sponsored, identify the commercial party and editorial/conflict boundary, and state that payment does not grant governance control, security-reporting preference, favorable benchmark treatment, or gated open-source functionality | Must |
| AC-005 | WHEN users obtain AgToosa under its open-source license THE SYSTEM SHALL expose the same public project features regardless of sponsorship or consulting status and SHALL NOT introduce sponsor-only gates, releases, fixes, or workflow capabilities | Must |
| AC-006 | WHEN funding, support, security, contribution, or README surfaces change THE SYSTEM SHALL keep the canonical boundary and links consistent, remove stale fixed-time guarantees, and distinguish project guidance from any separate written consulting agreement | Must |

**Failure modes:**

| AC | Failure mode | Required response |
|----|--------------|-------------------|
| AC-001 | Sponsor copy implies faster fixes or roadmap votes | Remove the implied benefit and restate the voluntary boundary. |
| AC-002 | Vulnerability reports are directed to a public issue | Restore the private security-reporting route. |
| AC-003 | A fixed acknowledgement or resolution time appears without an operated commitment | Remove it or explicitly scope it to a separate executed agreement. |
| AC-004 | Consulting or sponsored content obscures payment, editorial influence, or governance boundaries | Correct the sponsorship, independence, and conflict disclosure. |
| AC-005 | A feature, fix, release, or workflow is available only to sponsors | Reject the change as outside this story and the stated boundary. |
| AC-006 | `.github/SUPPORT.md`, `SECURITY.md`, funding metadata, and README contradict one another | Treat the disclosure as incomplete until all public surfaces align. |

### 1.4 Out of Scope

- Any SaaS or hosted control plane
- SSO or RBAC
- An MCP runtime
- An autonomous build runtime
- A federated registry
- A marketplace
- Silent telemetry or sponsor/user tracking
- A Go or Rust rewrite
- Paid feature tiers, sponsor-only functionality, private releases, or gated security fixes
- A guaranteed support plan, service desk, on-call rotation, uptime target, response target, resolution target, or SLA
- Payment processing, donor records, CRM, entitlement checks, or account management
- Consulting pricing, statements of work, contracts, delivery, invoicing, tax, or legal advice
- Undisclosed sponsored educational content or paid comparative claims
- Promising roadmap influence, governance votes, or preferential vulnerability handling

The parked roadmap, paid-service operations, and feature-gating items above are exclusions, not DEV-084 subtasks.

### 1.5 Claim Boundary

| Surface or claim | Classification | Boundary |
|------------------|----------------|----------|
| `.github/FUNDING.yml` | Repository metadata plus manual external account | Displays a link only; it does not prove availability, benefits, or payment status. |
| Community support guidance | Manual / best effort | Public channels invite participation but create no guaranteed response or resolution. |
| Security reporting route | Manual private intake | Defines where to report; it does not establish an acknowledgement or remediation SLA. |
| Consulting disclosure | Separate optional commercial relationship | Any obligations exist only in a separately executed agreement, not in project docs. |
| Open-source features and fixes | Public project boundary | No sponsorship or consulting entitlement gates. |
| Static consistency tests | CI-enforced-able after implementation | Can check required wording and links; cannot prove external sponsor availability or human responsiveness. |

## 2. Design

### 2.1 Architecture Blueprint

Proposed future surfaces:

| Surface | Responsibility |
|---------|----------------|
| `.github/SUPPORT.md` | Canonical support-channel, sponsorship, best-effort, and optional-consulting boundary |
| `.github/FUNDING.yml` | Official GitHub Sponsors destination only |
| `SECURITY.md` | Private vulnerability route and non-SLA response boundary |
| `README.md` | Concise links to canonical support and sponsorship disclosures |
| `CONTRIBUTING.md` | Contributor-facing pointer to support, issue, and security channels |
| `tests/agtoosa.bats` | OSS wording, no-feature-gate, stale-timeline, and cross-link contracts |

Key interfaces:

- Support matrix: request type, public/private channel, minimum information, expected handling, and explicit non-guarantees.
- Sponsorship disclosure: destination, voluntariness, permitted recognition, and prohibited entitlement implications.
- Consulting disclosure: separate agreement, independence/conflicts, no project entitlements, and no effect on security-reporting order.

### 2.2 Data Flow

1. A user follows README, funding, support, contribution, or security links.
2. The canonical support matrix classifies the request as a question, bug, proposal, vulnerability, or consulting inquiry.
3. Public requests go to the documented public channel; vulnerabilities go to the private route.
4. The user sees best-effort expectations before submitting and no unsupported timing promise.
5. A sponsor follows the verified external GitHub Sponsors destination and sees that sponsorship creates no feature or support entitlement.
6. A consulting inquiry is handled outside the open-source support flow under any separately agreed terms.
7. Static contracts detect contradictory links, entitlement language, feature-gate language, or stale fixed-time promises.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A fraudulent sponsor or consulting destination impersonates the maintainer | Spoofing | Keep one verified destination in repository-owned metadata and manually confirm it before publication. |
| Public support wording is changed to imply paid entitlement | Tampering | Add focused static contracts and require review of canonical boundary changes. |
| Parties dispute whether a response was guaranteed | Repudiation | State best-effort terms in the canonical public document and reserve contractual terms for separate agreements. |
| A vulnerability is disclosed publicly through the wrong channel | Information Disclosure | Keep private security routing prominent and distinct from issues/discussions. |
| Users flood an implied always-on support channel | Denial of Service | Avoid uptime/business-hour promises and document community best-effort triage. |
| Sponsors or clients gain implied governance or feature privilege | Elevation of Privilege | Explicitly prohibit roadmap, security-order, release, and feature entitlements. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `.github/SUPPORT.md`, `.github/FUNDING.yml`, `SECURITY.md`, `README.md`, `CONTRIBUTING.md`, and focused OSS tests
Directories in scope: repository public-governance documentation and `tests/`
External action     : manual confirmation of the configured GitHub Sponsors destination
Out of scope        : all §1.4 exclusions, generator/template behavior, payment/entitlement code, support operations, and consulting delivery

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Audit and define the canonical boundary
  - [ ] 1.1 Inventory sponsor, support, security, contribution, and timing claims across public surfaces — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006_
  - [ ] 1.2 Write the canonical channel matrix and sponsorship/consulting disclosure in `.github/SUPPORT.md` — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005_
- [ ] **2.** Align public repository surfaces
  - [ ] 2.1 Align `SECURITY.md` with the private route and non-SLA boundary — _Requirements: AC-002, AC-003, AC-006_
  - [ ] 2.2 Align README and contribution pointers without duplicating the full policy — _Requirements: AC-002, AC-006_
  - [ ] 2.3 Confirm the configured GitHub Sponsors destination is official and reachable — _Requirements: AC-001, AC-006_ `[manual]`
- [ ] **3.** Lock the disclosure contract
  - [ ] 3.1 Add OSS checks for required distinctions, no feature gates, and no unsupported fixed-time claims before changing documentation — _Requirements: AC-001, AC-003, AC-004, AC-005, AC-006_
  - [ ] 3.2 Review all public surfaces for consistent links and claim boundaries — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006_
  - [ ] 3.3 Record actual RED/GREEN and manual-link evidence only during future execution — _Requirements: AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 3.1  
**Wave 2 (sequential after Wave 1):** 1.2  
**Wave 3 (parallel after Wave 2):** 2.1, 2.2, 2.3  
**Wave 4 (sequential after Wave 3):** 3.2, 3.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-084.md`
AC coverage: 6 ACs mapped to 7 planned OSS test IDs
Smoke set: 4 planned tests tagged `@smoke`
Evidence state: RED and GREEN are unexecuted placeholders; no support or sponsorship evidence is claimed.
