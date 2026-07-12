# Spec: DEV-106 — Docs: Built with AgToosa Showcase

> **Story ID:** DEV-106
> **Type:** Docs
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🟩 Built — SHOW-001–007 green
> **Estimate:** XS
> **Priority:** P2
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

Rev4 community flywheel work includes a "Built with AgToosa" showcase to surface credible adoption proof without turning the main repository into a marketing site. DEV-106 adds a showcase page with submission rules, eligibility criteria, and honest claim boundaries. Submissions are manual maintainer curation; the page links out to external repositories and evidence rather than hosting project code.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Publish a Built with AgToosa showcase page and submission rules for curated adoption examples. |
| User outcome | A visitor can see credible external examples and contributors know how to propose a listing without overstating AgToosa endorsement. |
| Success condition | Showcase doc exists with eligibility, submission steps, required evidence links, display fields, and rejection reasons; SHOW tests enforce rules and forbid implied official endorsement. |
| Proof / evidence | SHOW tests verify page presence, required rule sections, link-only external references, and non-duplication of case-study kit content. |
| Non-goals | Hosted gallery app, analytics, automatic repo scraping, or paid placement. |
| Assumptions | `docs/AgToosa_CaseStudy.template.md` (DEV-083) remains the canonical voluntary case-study kit; showcase is a curated index, not a second kit. |
| Risks | Showcase implies AgToosa certifies listed projects; stale or dead links accumulate without maintainer review. |
| Unresolved questions | Initial seed entries (if any) are chosen at enrollment; empty showcase is valid at launch. |

### 1.2 User Stories

**As a** prospective adopter, **I want** a showcase of real projects **so that** I can evaluate AgToosa in context beyond the first-15 proof.

**As a** contributor, **I want** clear submission rules **so that** I know what evidence to provide and what claims are allowed.

**As an** AgToosa maintainer, **I want** curated listing criteria **so that** the showcase does not become unvetted advertising.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a reader opens the showcase page THE SYSTEM SHALL explain that listings are curated examples, not paid placement or official certification | Must |
| AC-002 | WHEN submission rules are documented THE SYSTEM SHALL require a public repository link, a short description, AgToosa version or proof reference, and a contact/issue path for maintainer review | Must |
| AC-003 | WHEN eligibility is defined THE SYSTEM SHALL list inclusion criteria (e.g., verifiable AgToosa usage, public repo, no undisclosed malware/abuse) and exclusion criteria (e.g., misleading claims, scraped content farms) | Must |
| AC-004 | WHEN a listing is displayed THE SYSTEM SHALL use link-out fields only and SHALL NOT host third-party repository content inline | Must |
| AC-005 | WHEN showcase docs reference case studies THE SYSTEM SHALL link to `AgToosa_CaseStudy.template.md` for voluntary self-service write-ups without duplicating the template body | Must |
| AC-006 | WHEN discovery surfaces reference the showcase THE SYSTEM SHALL link from `docs/index.md` Maintain or Adapt section and SHALL NOT duplicate submission rules in README prose | Should |
| AC-007 | WHEN showcase rules are maintained THE SYSTEM SHALL fail focused checks if forbidden phrases imply AgToosa official endorsement or security certification of listed projects | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Showcase titled "AgToosa Certified Projects." |
| FM-002 | AC-002 | Submission accepted with only a logo and no repo link. |
| FM-003 | AC-003 | Abusive or misleading project listed without exclusion policy. |
| FM-004 | AC-004 | Showcase embeds third-party README bodies that drift. |
| FM-005 | AC-005 | Case-study template copied inline and diverges. |
| FM-006 | AC-006 | README carries a second submission checklist. |
| FM-007 | AC-007 | Listing language says "AgToosa security approved." |

### 1.5 Out of Scope

- Automatic GitHub star scraping or CI badge generation
- Payments, sponsorship tiers for placement, or marketplace listings
- Hosting screenshots or binaries in the AgToosa repo
- Verifying every claim in listed repositories (manual spot-check only)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Showcase page and submission rules | documentation |
| Listing acceptance | manual maintainer curation |
| Listed project quality/security | external / not guaranteed |
| Case study content | contributor-authored via DEV-083 kit |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `docs/built-with-agtoosa.md` — showcase page and submission rules (may launch with zero entries)
- `docs/index.md` — discovery link (coordinates with DEV-098 job navigation)
- `docs/AgToosa_CaseStudy.template.md` — cross-link only
- `tests/agtoosa.bats` — SHOW rule and honesty tests

Optional: add a `## Built with AgToosa` subsection in `README.md` with one link only.

### 2.2 Data Flow

1. Author showcase page with rules, eligibility, and empty or seed listing table.
2. Contributors open issues/PRs per submission rules with evidence links.
3. Maintainers manually curate entries; update listing table.
4. SHOW tests verify structure and forbidden claims regardless of entry count.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Showcase implies official certification | Spoofing | Disclaimer and forbidden-claim tests. |
| Malicious repo promoted | Elevation of Privilege | Eligibility exclusions; manual review path. |
| Stale embedded content | Tampering | Link-out only; no inline third-party bodies. |

### 2.4 Build Scope

🟩 Built — Wave 3

Files in scope      : `docs/built-with-agtoosa.md`, index discovery link, optional README link, SHOW bats
Directories in scope: `docs/`, `tests/`
Out of scope        : gallery app, analytics, paid placement, automatic scraping

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED showcase contract
  - [x] 1.1 Add SHOW page presence and submission-rule fixtures — _Requirements: AC-001, AC-002, AC-003_
  - [x] 1.2 Add link-only, case-study cross-link, and forbidden-claim fixtures — _Requirements: AC-004, AC-005, AC-007_
- [x] **2.** Author showcase
  - [x] 2.1 Write `built-with-agtoosa.md` with rules and listing table — _Requirements: AC-001–AC-005_
  - [x] 2.2 Add `docs/index.md` discovery link — _Requirements: AC-006_
- [x] **3.** Evidence
  - [x] 3.1 Record RED/GREEN SHOW evidence — _Requirements: AC-001–AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (sequential after Wave 1):** 2.1, 2.2  
**Wave 3 (sequential after Wave 2):** 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-106.md`
AC coverage: 7 ACs mapped to 7 SHOW test IDs
Smoke set: 2 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: seed entries optional at enrollment

## ✅ Spec Approved

Approved: 2026-07-12
Enrollment: Rev4 Wave 3 (DEV-106)
