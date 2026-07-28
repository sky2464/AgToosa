# Spec: DEV-133 — GitHub Branch Hygiene for Cursor Agent Sprawl

> **Story ID:** DEV-133  
> **Epic:** DEV-004 — Testing & QA Harness · DEV-002 — Workflow Templates  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.47  
> **Estimate:** S  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** Maintainer dogfood hygiene (2026-07-27 incident: 21 stale `cursor/*` branches)  
> **Spec created:** 2026-07-27  
> **Ship target:** v5.3.47

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | Cursor Cloud agents pushed duplicate `cursor/critical-bug-investigation-*` branches with open PRs; manual `gh pr close` + `git push --delete` restored `main`-only remote |
| Status quo | `.github/workflows/stale.yml` closes inactive PRs after 30 days — too slow for same-day agent sprawl |
| Narrowest scope | Maintainer-only: dry-run cleanup script + scheduled workflow deleting `cursor/*` remote branches whose PRs are closed/merged; document safe usage in `docs/agtoosa-maintainer.md` |
| Non-goals | Blocking Cursor from pushing branches; changing downstream template; auto-deleting `main` or release tags |
| Failure modes | Accidental delete of active feature branch; deleting unmerged valuable work without review |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Cold-start pick from `/agtoosa-next` | **DEV-133** — prevent stale Cursor agent branch/PR sprawl |

#### Documented assumptions

- Applies to AgToosa maintainer repo (`sky2464/AgToosa`) only; script is opt-in via `workflow_dispatch` + schedule.
- Protected branch `main` is never deleted; only branches matching `cursor/*` prefix are candidates.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Keep GitHub remote branches to `main` plus short-lived intentional work — auto-retire stale `cursor/*` agent branches after PR close |
| User outcome | Maintainers spend minutes not hours cleaning duplicate agent PR/branch sprawl |
| Success condition | BRH-001–006 bats green; dry-run script lists candidates; scheduled workflow deletes only closed-PR `cursor/*` branches |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-133.md`; bats `BRH-001–006` |
| Non-goals | Cursor product changes; branch protection rule changes; deleting non-`cursor/*` branches |
| Assumptions | `gh` CLI available in CI; `GITHUB_TOKEN` has `contents: write` + `pull-requests: write` for workflow |
| Risks | Workflow misconfiguration could delete wrong prefix — mitigate with explicit `cursor/` filter + dry-run contract in script |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN maintainer runs `scripts/cleanup-github-branches.sh --dry-run` THE SYSTEM SHALL list `cursor/*` remote branches eligible for deletion (PR closed/merged or no open PR) without mutating GitHub |
| AC-002 | Must | WHEN maintainer runs `scripts/cleanup-github-branches.sh --apply` THE SYSTEM SHALL close duplicate open PRs on eligible `cursor/*` branches only when `--close-prs` is set, then delete listed remote branches |
| AC-003 | Must | WHEN the cleanup script runs THE SYSTEM SHALL never target `main`, `master`, or tags |
| AC-004 | Must | WHEN scheduled workflow `branch-hygiene.yml` runs THE SYSTEM SHALL invoke dry-run listing then delete `cursor/*` branches with no open PR (or closed PR) |
| AC-005 | Must | WHEN `docs/agtoosa-maintainer.md` documents branch hygiene THE SYSTEM SHALL include safe manual commands and link to the script/workflow |
| AC-006 | Must | WHEN DEV-133 ships THE SYSTEM SHALL pass bats BRH-001–006 |

### 1.3 Scope Boundary

**In scope:** `scripts/cleanup-github-branches.sh`, `.github/workflows/branch-hygiene.yml`, `docs/agtoosa-maintainer.md`, `tests/agtoosa.bats`.

**Out of scope:** Template pack changes, generator CLI flags, GitHub org-wide policies.

## 2. Design

### 2.1 Cleanup script contract

```bash
scripts/cleanup-github-branches.sh [--dry-run|--apply] [--close-prs] [--prefix cursor/]
```

- Default: `--dry-run`
- List branches via `gh api repos/{owner}/{repo}/branches`
- Filter: name starts with `cursor/`
- Eligible when: no open PR, or all PRs closed/merged
- `--apply`: delete via `git push origin --delete` or `gh api` DELETE ref
- `--close-prs`: close open PRs with explanatory comment before delete (manual recovery path)

### 2.2 Scheduled workflow

Weekly `workflow_dispatch` + cron; runs script in `--apply` mode without `--close-prs` (delete only branches with no open PR). Manual dispatch may pass `close_prs: true`.

### 2.3 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| Tampering (wrong branch deleted) | Hard-coded denylist `main`/`master`; prefix filter `cursor/` only |
| Denial of service | Dry-run default; workflow logs branch list |

### 2.4 Build Scope

| Surface | Change |
|---------|--------|
| `scripts/cleanup-github-branches.sh` | New maintainer cleanup tool |
| `.github/workflows/branch-hygiene.yml` | Scheduled + manual hygiene |
| `docs/agtoosa-maintainer.md` | Branch hygiene runbook section |
| `tests/agtoosa.bats` | BRH-001–006 contract tests |

## 3. Tasks

- [x] **1.** Add `scripts/cleanup-github-branches.sh` with dry-run/apply + denylist — _AC-001–AC-003_
- [x] **2.** Add `.github/workflows/branch-hygiene.yml` scheduled cleanup — _AC-004_
- [x] **3.** Document maintainer runbook in `docs/agtoosa-maintainer.md` — _AC-005_
- [x] **4.** Add bats BRH-001–006 — _AC-006_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-133.md`.

---

## ✅ Spec Approved

Approved via `/agtoosa-next` Sequential Approval — 2026-07-27 — ready for `/agtoosa-build`.
