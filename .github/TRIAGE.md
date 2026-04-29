# Issue Triage Policy

This document defines how issues are triaged, prioritized, and responded to in the AgToosa project.

## Who Triages

The primary maintainer (@sky2464) triages all new issues. Community members with `Collaborator` access may triage with maintainer approval.

## Response SLAs

| Severity | First Response | Resolution Target |
|----------|---------------|------------------|
| P0 — Critical (data loss, security, generator broken) | 24 hours | 48 hours |
| P1 — High (workflow broken, major UX regression) | 3 days | 1 week |
| P2 — Medium (feature gap, non-critical bug) | 1 week | Next minor release |
| P3 — Low (cosmetic, minor improvement) | 2 weeks | Backlog |

## Severity Assignment

Apply the highest matching rule:

- **P0** — `bash agtoosa.sh` fails on a fresh clone; security vulnerability; data corruption
- **P1** — A workflow command (`/agtoosa-spec`, `/agtoosa-build`, etc.) produces wrong output; a CI workflow is broken; a platform entry-point file is missing
- **P2** — A feature behaves unexpectedly but a workaround exists; docs are misleading; test coverage gap
- **P3** — Typo, wording improvement, cosmetic label, nice-to-have feature

## Label Taxonomy

Every triaged issue must have at least one label from each category:

| Category | Labels |
|----------|--------|
| **Type** | `bug` · `enhancement` · `documentation` · `chore` · `security` · `question` |
| **Priority** | `priority-critical` · `priority-high` · `priority-medium` · `priority-low` |
| **Status** | `status-needs-triage` · `status-confirmed` · `status-blocked` · `status-wont-fix` |
| **Contributor** | `good-first-issue` · `help-wanted` · `needs-repro` |
| **Area** | `area-generator` · `area-template` · `area-ci` · `area-docs` · `area-security` |

## Triage Workflow

1. **New issue opened** → automatically labelled `status-needs-triage` by auto-label workflow
2. **Maintainer reviews** within the SLA window:
   - Confirm it is reproducible (add `needs-repro` if not)
   - Assign priority label
   - Assign type and area labels
   - Remove `status-needs-triage`, add `status-confirmed`
   - Assign to a milestone (or `Backlog` if unscheduled)
3. **If duplicate** → add `duplicate` label, close with a link to the canonical issue
4. **If won't fix** → add `status-wont-fix`, close with a brief explanation

## Closing Stale Issues

Issues with no activity for **30 days** receive a `stale` warning via the stale bot. Issues remain stale for **7 more days** before auto-closure. Maintainers may pin issues to exempt them from staleness.

## Escalation

Security vulnerabilities must NOT be filed as public issues. See [SECURITY.md](../SECURITY.md) for the private disclosure process.
