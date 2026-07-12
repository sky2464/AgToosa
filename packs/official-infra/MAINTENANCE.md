# Maintenance Policy — Official Infrastructure / Security Pack

| Field | Value |
|-------|-------|
| Owner | sky2464 |
| Review cadence | Quarterly content + compatibility + security-control-map review (or sooner on AgToosa MAJOR or registry safety change) |
| Compatibility-update policy | Bump pack `compatibility.agtoosa` when a breaking AgToosa MAJOR ships; re-validate allowlist/denylist/preview behavior; re-run OPP-007/OPP-008 before promoting status |
| Issue path | https://github.com/sky2464/AgToosa/issues (label: `pack:official-infra`) |
| Deprecation process | Announce in CHANGELOG + Registry pilot inventory; mark `lifecycle: deprecated` in manifest; keep installable for one MINOR train; remove from pilot inventory only after replacement or explicit retirement note |

**Official** means curated under this policy for the pilot — not a continuous SLA or security guarantee beyond documented generator-enforced controls.
