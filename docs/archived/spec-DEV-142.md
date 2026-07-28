# Spec: DEV-142 — GitHub Surface Audit & Community Profile

> **Story ID:** DEV-142
> **Epic:** DEV-004 — Delivery, Quality & Operations
> **Status:** 🏁 Shipped — v5.3.56
> **Estimate:** M
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-139 — GitHub Issues PM Bridge · DEV-076 — Static Documentation Site Proof

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Authority | `docs/Master-Plan.md` remains SoT; Issues stay a public mirror (DEV-139) |
| About copy | README tagline: *"A lightweight, repo-native control plane for spec-driven AI development"* |
| Homepage | `https://sky2464.github.io/AgToosa/` once Pages enabled from `/docs` |
| Topics | `ai`, `developer-tools`, `spec-driven-development`, `cursor`, `claude`, `workflow`, `bash` |
| Wiki | `wiki-sync.yml` exists; gap is Home.md seed + audit verification |
| Labels | Live repo drift vs TRIAGE taxonomy; `labels.yml` is dispatch-only |
| Community profile | 85% health — missing description, topics, `ISSUE_TEMPLATE/config.yml` |
| Pages | DEV-076 proof workflow exists; Pages not deployed (API 404) |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Scope | **B** — Full surface audit of GitHub nav-visible surfaces |
| Q2 | Projects | **A** — Issues + milestones only; audit Projects tab, no Projects v2 board |
| Q3 | Pages | **A** — Enable GitHub Pages from `/docs` |
| Q4 | Verification | **A** — `scripts/github-surface-audit.sh` + CI gate on release checklist |
| Q5 | Non-goals | **A–F** — Exclude branch protection, secrets/env, Marketplace, Packages, Codespaces, Agents tab |

#### Documented assumptions

- Sponsors activation remains manual-deferred (DEV-084 M-1); audit checks `FUNDING.yml` presence only.
- One-time Pages enablement and About fields require maintainer `gh repo edit` / Settings steps documented in `.github/GITHUB-SURFACES.md`.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Bring all GitHub nav-visible community surfaces to a documented, machine-verified baseline so contributors see a complete public profile on first visit. |
| User outcome | A new visitor lands on a repo with filled About section, working Pages docs, populated Wiki home, aligned Issues labels, and Discussions categories — not an empty sidebar. |
| Success condition | `scripts/github-surface-audit.sh --mode live` exits 0 against `sky2464/AgToosa`; community profile health ≥95%; GSA-001–GSA-010 green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-142.md`; bats GSA-001–GSA-010; CI `github-surface-audit.yml`; pre-release hook. |
| Non-goals | Branch protection/rulesets; secrets/environments/deploy keys; Marketplace Action (DEV-062); GitHub Packages; Codespaces; Agents tab; Projects v2 kanban |
| Assumptions | `gh` available for live audit; manifest is single expected-state contract |
| Risks | Live audit fails until one-time maintainer setup; label sprawl from milestone history |
| Unresolved questions | None — interview complete |

### 1.2 User Stories

**As a** prospective contributor, **I want** a complete GitHub About section and docs site **so that** I understand what AgToosa is without cloning the repo.

**As a** maintainer, **I want** a scripted surface audit in CI **so that** community profile drift is caught before release.

**As a** triager, **I want** Issues labels aligned with TRIAGE.md **so that** automation and manual triage use the same taxonomy.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `github-surface-audit.sh --mode live` runs against the live repo THE SYSTEM SHALL exit 0 when all manifest assertions pass | Must |
| AC-002 | WHEN the About section is inspected THE SYSTEM SHALL have non-empty description, ≥5 topics, and homepage URL matching Pages | Must |
| AC-003 | WHEN GitHub Pages is enabled THE SYSTEM SHALL serve `/docs` Jekyll build at `https://sky2464.github.io/AgToosa/` | Must |
| AC-004 | WHEN labels are compared to manifest THE SYSTEM SHALL include full TRIAGE taxonomy labels | Must |
| AC-005 | WHEN `ISSUE_TEMPLATE/config.yml` exists THE SYSTEM SHALL disable blank issues and link security + discussions | Must |
| AC-006 | WHEN Wiki sync runs THE SYSTEM SHALL ensure `Home.md` exists in the wiki repo | Must |
| AC-007 | WHEN CI runs on `main` THE SYSTEM SHALL execute surface audit and fail on drift | Must |
| AC-008 | WHEN Projects tab is audited THE SYSTEM SHALL document Issues+milestones as canonical PM surface (no v2 board) | Should |
| AC-009 | WHEN Sponsors is checked THE SYSTEM SHALL confirm `FUNDING.yml` resolves (active sponsorship is manual/DEV-084) | Should |
| AC-010 | WHEN non-goals A–F are referenced THE SYSTEM SHALL NOT modify branch protection, secrets, Marketplace, Packages, Codespaces, or Agents config | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | Manifest schema invalid | Fail bats GSA-001; block merge |
| FM-002 | AC-002 | About empty after ship | Live audit fails; runbook remediation |
| FM-003 | AC-003 | Pages 404 | Document enablement step; audit reports URL |
| FM-004 | AC-004 | Missing TRIAGE labels | `labels.yml` dispatch + audit diff |
| FM-005 | AC-007 | CI runs live on PR before setup | Use `--mode local` on PR; live on release |

### 1.5 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `docs/github-surface-manifest.json` | repository-enforced | Committed expected state |
| `github-surface-audit.sh --mode local` | generator-enforced | File + manifest checks |
| `github-surface-audit.sh --mode live` | provider-enforced | `gh api` read-only |
| Pages enablement | manual authorization | Settings / `gh api` one-time |
| About description/topics | manual authorization | `gh repo edit` one-time |
| Sponsors activation | manual-deferred | DEV-084 M-1 |

### 1.6 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Manifest tampering lowers bar | Tampering | CI compares live API to committed manifest |
| Audit targets wrong repo | Spoofing | Requires explicit `--repo` or `GITHUB_REPOSITORY` |
| Audit logs secrets | Information disclosure | Read-only public API fields only |
| `gh api` rate limits | Denial of service | Batch calls; local mode for PR CI |
| Audit workflow writes settings | Elevation of privilege | Audit is read-only; remediation is separate |

## 2. Design

### 2.1 Audit pipeline

```
docs/github-surface-manifest.json
        ↓
github-surface-audit.sh --mode local|live
        ↓
.github/workflows/github-surface-audit.yml
        ↓
pre-release-checklist.yml (live mode)
```

### 2.2 Surface inventory

| Nav tab | Action |
|---------|--------|
| About | Manifest + live API check |
| Issues | Labels, config.yml, templates |
| Discussions | Enabled + min categories |
| Projects | Enabled; no v2 board required |
| Wiki | Home.md via wiki-sync |
| Pages | `/docs` source; optional deploy when `PAGES_ENABLED` |
| Security | `SECURITY.md` in repo |
| Sponsors | `FUNDING.yml` presence |

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Manifest and audit script
  - [x] 1.1 `docs/github-surface-manifest.json`
  - [x] 1.2 `scripts/github-surface-audit.sh` (local + live modes)
  - [x] 1.3 `scripts/github-labels-sync.sh`
- [x] **2.** CI and workflows
  - [x] 2.1 `.github/workflows/github-surface-audit.yml`
  - [x] 2.2 Pre-release checklist hook
  - [x] 2.3 `docs-pages-proof.yml` optional deploy guard
- [x] **3.** Issues hygiene
  - [x] 3.1 `.github/ISSUE_TEMPLATE/config.yml`
  - [x] 3.2 Reconcile `.github/workflows/labels.yml` with TRIAGE.md
- [x] **4.** Docs and wiki
  - [x] 4.1 `.github/GITHUB-SURFACES.md` runbook
  - [x] 4.2 Verify wiki-sync Home.md seed
- [x] **5.** Tests and enrollment
  - [x] 5.1 Bats GSA-001–GSA-010
  - [x] 5.2 Master-Plan + test plan

## ✅ Spec Approved

Approved for build per user implementation request (2026-07-28).
