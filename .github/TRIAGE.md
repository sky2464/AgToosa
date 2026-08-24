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
| **Source** | `source:agtoosa-sync` (Master-Plan mirror) · `source:community` (contributor-filed) |

## AgToosa-synced vs community issues

| Label | Meaning | Intake workflow |
|-------|---------|-----------------|
| `agtoosa:DEV-XXX` | Mirror of a Master-Plan story | Skip intake — updated by `agtoosa-issues-sync.yml` |
| `source:agtoosa-sync` | Outbound sync from Master-Plan | Maintainer edits Master-Plan, not the Issue directly |
| `source:community` | Filed by a contributor | `agtoosa-issues-intake.yml` → proposal → `/agtoosa-task` |

**Do not** edit AgToosa-synced issue titles to change scope — update `docs/Master-Plan.md` and let CI sync.

## Triage Workflow

1. **New issue opened** → automatically labelled `status-needs-triage` by auto-label workflow
2. **Maintainer reviews** within the SLA window:
   - Confirm it is reproducible (add `needs-repro` if not)
   - Assign priority label
   - Assign type and area labels
   - Remove `status-needs-triage`, add `status-confirmed`
   - Assign to a milestone (or `Backlog` if unscheduled)
3. **If accepted from community intake** → use backlog draft from intake proposal artifact; run `/agtoosa-task` or edit Master-Plan; sync updates the public mirror on next `main` push
4. **If duplicate** → add `duplicate` label, close with a link to the canonical issue
5. **If won't fix** → add `status-wont-fix`, close with a brief explanation

## Closing Stale Issues

Issues with no activity for **30 days** receive a `stale` warning via the stale bot. Issues remain stale for **7 more days** before auto-closure. Maintainers may pin issues to exempt them from staleness.

## Escalation

Security vulnerabilities must NOT be filed as public issues. See [SECURITY.md](SECURITY.md) for the private disclosure process.
