# GitHub Issues & Public Roadmap

AgToosa uses **`docs/Master-Plan.md` as the sole PM authority**. GitHub Issues are a **public mirror** for contributors — not a second source of truth.

## Public surfaces

| Surface | Purpose |
|---------|---------|
| [GitHub Issues](https://github.com/sky2464/AgToosa/issues) | Live backlog mirror (active cycle + open backlog) |
| README `AGTOOSA-ROADMAP` block | Auto-generated summary on Master-Plan sync |
| Milestones | Align to Project Charter release (e.g. `v0.3.52`) |

## Automation (DEV-139)

**Outbound sync** — `.github/workflows/agtoosa-issues-sync.yml`

- Triggers on `main` when `docs/Master-Plan.md` changes
- Runs `scripts/agtoosa-issues-sync.sh` to upsert Issues via `gh`
- AgToosa-synced issues carry label `agtoosa:DEV-XXX` and `source:agtoosa-sync`
- Titles use GitHub conventions (`feat:`, `fix:`, `chore:`) — no `DEV-` title prefix

**Inbound intake** — `.github/workflows/agtoosa-issues-intake.yml`

- Community issues (no `agtoosa:DEV-*` label) → intake proposal artifact + triage comment
- Maintainer accepts via `/agtoosa-task` or explicit Master-Plan edit
- Label `source:community` distinguishes contributor-filed issues

## Contributing via GitHub

1. Browse [open issues](https://github.com/sky2464/AgToosa/issues) or file a new feature/bug from templates
2. Maintainer triages per [.github/TRIAGE.md](TRIAGE.md)
3. Accepted work is enrolled in Master-Plan; sync updates the public mirror
4. Open a PR referencing the issue; merge closes linked work when applicable

## Release planning

- **Milestones** — match `docs/Master-Plan.md` Project Charter; `release-advanced.yml` creates next PATCH on tag push
- **Labels** — see [.github/TRIAGE.md](TRIAGE.md) taxonomy + `agtoosa:DEV-*` sync labels

## Downstream installs

Copy `template/.github/workflows/agtoosa-issues-sync.yml.example` to enable the same pattern in generated projects. See `Docs/AgToosa_TrackerSync.md` → **publish** and **intake** workflows.
