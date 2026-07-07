# GitHub Project Configuration

This document describes the AgToosa GitHub Project setup for issue tracking and project management.

## Project: AgToosa Development

**View:** https://github.com/orgs/sky2464/projects/X

### Boards

**Main Board** — Kanban workflow
- **Backlog** — Ideas, future work, research spikes
- **Ready** — Prioritized, ready to start
- **In Progress** — Currently being worked on
- **In Review** — PR open, awaiting review
- **Done** — Merged and shipped

### Automation

**Auto-add issues:**
- All issues in AgToosa repo → Backlog
- All PRs in AgToosa repo → In Review

**Auto-close issues:**
- PR merged with "Closes #123" → Done

**Auto-archive:**
- Issues closed without PR after 30 days → Archive

### Custom Fields

- **Priority:** None, Low, Medium, High, Urgent
- **Type:** Feature, Bug, Chore, Documentation, Research, Testing
- **Estimate:** S, M, L, XL (story points)
- **Team:** Backend, Docs, DX, QA, Release

### Views

**By Priority** — High priority first
**By Type** — Features, then bugs, then chores
**By Sprint** — (when using GitHub's sprint field)
**Blocked Items** — Issues with blocking dependencies

## Syncing with Linear

AgToosa maintains dual PM:
- **Linear** — Authority for AgToosa development (internal)
- **GitHub Project** — Public discovery board for contributors

Manual sync workflow:
1. Create issue in Linear (primary)
2. File corresponding GitHub issue (if public contribution)
3. Link in description: "See LINEAR-XXX in AgToosa workspace"

## Contributing via GitHub

Contributors can:
1. Pick an issue from "Ready" board
2. Comment to claim work
3. Open PR, reference issue
4. PR merged → auto-closes issue → moves to Done

## Release Planning

Upcoming releases tracked in:
- **Milestones** — current open milestone matches `docs/Master-Plan.md` Project Charter (e.g. `v5.3.1` after `v5.3.0` ships); `release-advanced.yml` auto-creates the next PATCH milestone on tag push
- **Labels** — release-v2.5.0 for tracking commits
- **Projects** — Separate project per major release
