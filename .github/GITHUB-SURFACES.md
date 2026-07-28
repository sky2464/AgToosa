# GitHub Community Surfaces — Maintainer Runbook

> **Story:** DEV-142 — GitHub Surface Audit & Community Profile  
> **Authority:** `docs/Master-Plan.md` remains the sole PM source of truth. GitHub Issues are a public mirror (DEV-139).

This guide inventories every **nav-visible** GitHub community surface, how to configure it, and how to verify it stays healthy.

## Surface inventory

| Nav tab | Purpose | Automation |
|---------|---------|------------|
| **About** | Description, topics, homepage URL | `docs/github-surface-manifest.json` + one-time `gh repo edit` |
| **Issues** | Bug/feature intake + synced backlog | `agtoosa-issues-sync.yml`, templates, labels |
| **Discussions** | Q&A, Ideas, Show & Tell, Announcements | `.github/DISCUSSIONS.md` |
| **Projects** | **Intentionally unused** — Issues + milestones are canonical | Audit only; no Projects v2 board |
| **Wiki** | Browsable workflow docs | `wiki-sync.yml` → `Home.md` |
| **Pages** | Static docs from `/docs` | `docs-pages-proof.yml` + Settings enablement |
| **Security** | Vulnerability reporting | `SECURITY.md` |
| **Sponsors** | Optional funding link | `.github/FUNDING.yml` (activation: DEV-084 M-1) |

## One-time setup

### 1. About section

```bash
gh repo edit sky2464/AgToosa \
  --description "A lightweight, repo-native control plane for spec-driven AI development" \
  --homepage "https://sky2464.github.io/AgToosa/" \
  --add-topic ai --add-topic bash --add-topic claude --add-topic cursor \
  --add-topic developer-tools --add-topic spec-driven-development --add-topic workflow
```

### 2. GitHub Pages (from `/docs`)

1. Open **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` · Folder: `/docs`
4. Save — site URL: `https://sky2464.github.io/AgToosa/`

Or via API (requires admin scope):

```bash
gh api -X POST repos/sky2464/AgToosa/pages \
  -f source[branch]=main \
  -f source[path]=/docs
```

Optional: set repository variable `PAGES_ENABLED=true` to allow deploy job in `docs-pages-proof.yml`.

### 3. Labels

Dispatch **Setup GitHub Labels** workflow (`.github/workflows/labels.yml`) or run:

```bash
bash scripts/github-labels-sync.sh --repo sky2464/AgToosa
```

Labels must match `docs/github-surface-manifest.json` and [`.github/TRIAGE.md`](TRIAGE.md).

### 4. Wiki home page

Dispatch **Sync Docs to Wiki** workflow (`.github/workflows/wiki-sync.yml`). This seeds `Home.md` with navigation links.

### 5. Milestone hygiene

Keep open milestones for the **current release** and the **last three** PATCH releases. Archive older PATCH milestones when shipping.

## Verification

### Local (no network — CI on pull requests)

```bash
bash scripts/github-surface-audit.sh --mode local
```

Checks manifest schema, required files, `ISSUE_TEMPLATE/config.yml`, and `FUNDING.yml`.

### Live (read-only GitHub API)

```bash
bash scripts/github-surface-audit.sh --mode live --repo sky2464/AgToosa
```

Checks About, topics, homepage, Pages source, community profile health (≥95%), labels, Discussions categories, and Wiki `Home.md`.

### CI

- `.github/workflows/github-surface-audit.yml` — local mode on PR; live mode on `main` push and `workflow_dispatch`
- `pre-release-checklist.yml` — live mode before tagging

## Projects tab (no v2 board)

Per DEV-139 and DEV-142 interview Q2:

- **Canonical PM surface:** GitHub Issues + milestones synced from Master-Plan
- **Projects v2 kanban:** explicitly **not** configured
- Classic `auto-project-assign.yml` is retired

The Projects tab may remain enabled for future use but requires no board for community health.

## Explicit non-goals (interview Q5)

This story does **not** modify:

| ID | Area |
|----|------|
| A | Branch protection / rulesets / required reviewers |
| B | Secrets, environments, deploy keys, OAuth apps |
| C | GitHub Marketplace Action publish (DEV-062 M-1) |
| D | GitHub Packages / container registry |
| E | Codespaces / devcontainer settings |
| F | Agents tab (Copilot agent config) |

## Related docs

- [`.github/PROJECT.md`](PROJECT.md) — Issues sync and intake
- [`.github/TRIAGE.md`](TRIAGE.md) — Label taxonomy
- [`.github/DISCUSSIONS.md`](DISCUSSIONS.md) — Discussion categories
- [`docs/github-surface-manifest.json`](../docs/github-surface-manifest.json) — Expected state contract
- [`docs/archived/spec-DEV-142.md`](../docs/archived/spec-DEV-142.md) — Full spec
