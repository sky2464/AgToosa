# Spec: DEV-076 — Spike: Static Documentation Site Proof

> **Story ID:** DEV-076
> **Type:** Spike
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Priority:** P2
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

AgToosa documentation is canonical markdown under `docs/`. A static site may improve discovery, but a site generator can easily create a second documentation source, checked-in build output, or an unnecessary runtime. This spike proves the smallest GitHub Pages-compatible build directly from canonical markdown and stops before a broader documentation-platform commitment.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Prove that GitHub Pages can build a no-backend static documentation artifact directly from canonical `docs/` markdown. |
| User outcome | Maintainers can evaluate a browsable documentation surface without rewriting docs or operating a service. |
| Success condition | A pinned CI workflow builds `docs/` into an ephemeral Pages artifact, representative canonical pages render under the repository base path, and no generated site content is committed. |
| Proof / evidence | SITE tests inspect source/config boundaries and execute the static build in an isolated output directory; CI artifact and logs identify the source commit. |
| Non-goals | Production information architecture, custom domain, search service, analytics, authentication, comments, or content migration. |
| Assumptions | GitHub Pages/Jekyll-compatible tooling is sufficient for the spike; repository owners control whether deployment is enabled. |
| Risks | Site-specific wrappers become a competing source of truth, project-page base paths break links, or unpinned actions expand supply-chain risk. |
| Unresolved questions | Whether to launch and maintain the site after the proof; that decision requires evidence from this spike. |

### 1.2 User Stories

**As a** prospective user, **I want** canonical AgToosa markdown rendered as a navigable static site **so that** I can evaluate the framework without cloning the repository.

**As a** maintainer, **I want** a build-only proof with no duplicated content **so that** documentation remains reviewable in one source location.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the documentation-site workflow runs THE SYSTEM SHALL build directly from the repository `docs/` directory into an ephemeral static artifact without copying canonical prose into a second source tree | Must |
| AC-002 | WHEN site navigation or landing content references a guide THE SYSTEM SHALL link to that guide's canonical markdown path and SHALL NOT embed a maintained duplicate of the guide body | Must |
| AC-003 | WHEN a pull request changes site configuration or canonical documentation THE SYSTEM SHALL run the static build and report a failing check when the build exits non-zero | Must |
| AC-004 | WHEN the site is built for GitHub project Pages THE SYSTEM SHALL apply the repository base path so navigation, assets, and representative internal links resolve below `/AgToosa/` | Must |
| AC-005 | WHEN the proof artifact is inspected THE SYSTEM SHALL contain rendered pages for README-equivalent entry content, `AgToosa_Agent.md`, and `examples/first-15-minutes.md`, and SHALL identify the source commit in build metadata or logs | Must |
| AC-006 | WHEN the proof configuration is inspected THE SYSTEM SHALL contain no application backend, database, account system, analytics beacon, or automatic production deployment requirement | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | A `site-content/` tree copies canonical markdown and drifts. |
| FM-002 | AC-002 | The landing page restates full guides instead of linking them. |
| FM-003 | AC-003 | Documentation changes merge while the Pages build is broken. |
| FM-004 | AC-004 | Root-relative links work locally but fail under `/AgToosa/`. |
| FM-005 | AC-005 | CI reports success without rendering representative content or recording its source revision. |
| FM-006 | AC-006 | The spike introduces a server, telemetry, credentials, or mandatory deploy step. |

### 1.5 Out of Scope

- Rewriting canonical markdown for a site theme.
- Full-text hosted search, user accounts, comments, analytics, or a content database.
- A custom domain, SEO program, screenshots, or a launch announcement.
- Committing `_site/`, generated HTML, or copied markdown.
- Automatically enabling GitHub Pages repository settings.
- Choosing a permanent documentation platform before reviewing spike evidence.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Canonical content under `docs/` | repository-enforced by review convention |
| Static build on matching pull requests | CI-enforced when the workflow is enabled |
| GitHub Pages hosting and availability | GitHub-managed; repository-owner enabled |
| Absence of a backend in scoped files | machine-checkable repository contract |
| Site usefulness or adoption | unproven spike outcome |
| Permanent docs platform selection | roadmap decision, not delivered here |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `docs/_config.yml` — minimal project-Pages configuration and exclusions.
- `docs/index.md` — link-only landing/navigation surface sourced from canonical paths.
- `.github/workflows/docs-pages-proof.yml` — pinned build-only workflow producing an ephemeral Pages artifact.

Files to change:

- `.gitignore` — ignore local static build output if not already covered.
- `tests/agtoosa.bats` — SITE source-boundary and build contract tests.

No content mirror, database, application server, or checked-in generated directory is introduced.

### 2.2 Data Flow

1. A maintainer edits canonical markdown under `docs/`.
2. Pull-request CI checks out the exact commit and invokes the pinned Pages-compatible builder with `docs/` as its source.
3. The builder renders into an isolated temporary output directory using the `/AgToosa/` base path.
4. SITE checks inspect representative output and internal links.
5. CI uploads the generated directory as an ephemeral artifact associated with the source commit.
6. A repository owner may later enable a deployment job; the proof itself requires no backend or automatic production deployment.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A preview is mistaken for content from another commit | Spoofing | Associate artifact and logs with the checked-out commit SHA. |
| Generated output is manually edited and committed | Tampering | Build into ignored temporary output; test that no generated site tree is tracked. |
| A maintainer cannot reconstruct the proof build | Repudiation | Pin workflow actions and record the build command and commit in CI logs. |
| Site config exposes credentials or private runtime data | Information Disclosure | No secrets, backend, analytics, or runtime configuration are required. |
| Broken links or theme dependencies prevent every page build | Denial of Service | Focused representative-page and base-path checks fail the PR build early. |
| A docs workflow gains unnecessary write/deploy authority | Elevation of Privilege | Build-only workflow uses read contents permission; deployment remains a separate owner decision. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)
Files in scope      : `docs/_config.yml`, `docs/index.md`, `.github/workflows/docs-pages-proof.yml`, `.gitignore`, `tests/agtoosa.bats`
Directories in scope: `docs/`, `.github/workflows/`
Out of scope        : canonical guide rewrites, generated HTML commits, backend code, analytics, custom domains, automatic Pages settings

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Define the proof contract
  - [ ] 1.1 Add RED SITE tests for direct source, no duplicate tree, base path, representative pages, and workflow permissions — _Requirements: AC-001, AC-002, AC-004, AC-005, AC-006_
  - [ ] 1.2 Record the exact build and artifact assertions in the test plan — _Requirements: AC-003, AC-005_
- [ ] **2.** Configure the static source
  - [ ] 2.1 Add minimal Pages configuration rooted at `docs/` — _Requirements: AC-001, AC-004, AC-006_
  - [ ] 2.2 Add a link-only landing page that points to canonical guides — _Requirements: AC-002, AC-005_
- [ ] **3.** Add the build-only workflow
  - [ ] 3.1 Add a pinned, least-privilege pull-request build and artifact upload — _Requirements: AC-003, AC-005, AC-006_
  - [ ] 3.2 Ensure local output is isolated and ignored — _Requirements: AC-001_
- [ ] **4.** Prove representative rendering
  - [ ] 4.1 Build and inspect the entry page, Agent guide, and first-15 walkthrough under the project base path — _Requirements: AC-004, AC-005_
  - [ ] 4.2 Confirm no copied markdown, backend, analytics, or deploy requirement entered scope — _Requirements: AC-001, AC-002, AC-006_
- [ ] **5.** Record spike evidence
  - [ ] 5.1 Capture RED/GREEN SITE results and a proceed/change/stop recommendation without launching a production site — _Requirements: AC-001, AC-003, AC-004, AC-005, AC-006_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2  
**Wave 2 (parallel after Wave 1):** 2.1, 2.2, 3.1, 3.2  
**Wave 3 (sequential after Wave 2):** 4.1, 4.2  
**Wave 4 (sequential after Wave 3):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-076.md`
AC coverage: 6 ACs mapped to 8 SITE test IDs
Smoke set: 3 tests tagged `@smoke`
