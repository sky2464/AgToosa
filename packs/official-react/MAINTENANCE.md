# Maintenance Policy — Official React Pack

| Field | Value |
|-------|-------|
| Owner | sky2464 |
| Review cadence | Quarterly content + compatibility review (or sooner on AgToosa MAJOR) |
| Compatibility-update policy | Bump pack `compatibility.agtoosa` when a breaking AgToosa MAJOR ships; re-run OPE install fixtures before promoting status |
| Issue path | https://github.com/sky2464/AgToosa/issues (label: `pack:official-react`) |
| Deprecation process | Announce in CHANGELOG + Registry pilot inventory; mark `lifecycle: deprecated` in manifest; keep installable for one MINOR train; remove from pilot inventory only after replacement or explicit retirement note |

**Official** means curated under this policy for the pilot — not a guarantee of fit for every React project.
