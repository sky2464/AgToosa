# Official Pack Pilot — Review and Evidence Checklist

> **Story:** DEV-080  
> **Catalog contract consumed:** `schema_version` **1.0** (`catalog/catalog.schema.json` / DEV-053)  
> **Maintainer:** sky2464  
> **Publication status (all three):** **local candidate** — not externally published

Trust label vocabulary (verified / community / official pilot): see `docs/AgToosa_Registry.md` → **Trust surface**.

## Pilot inventory (three shipped; five maximum under DEV-095)

| Pack root | Primary domain | Manifest | Fixture | Status |
|-----------|----------------|----------|---------|--------|
| `packs/official-web/` | web | `packs/official-web/manifest.json` | `tests/fixtures/registry-packs/official-web/` | local candidate |
| `packs/official-api/` | api | `packs/official-api/manifest.json` | `tests/fixtures/registry-packs/official-api/` | local candidate |
| `packs/official-infra/` | infrastructure | `packs/official-infra/manifest.json` | `tests/fixtures/registry-packs/official-infra/` | local candidate |

DEV-080 shipped exactly three pilots. Expansion to five maximum (`official-react`, `official-security`) is **DEV-095** scope — see `docs/updates/rev4-conflict-resolutions.md`.

## Review checklist (per pack)

- [x] Manifest validates via `bash agtoosa.sh --catalog validate packs/<pack>/manifest.json` (schema_version 1.0) — OPP-002
- [x] Provenance records version, source, sha256, signature field (signature may be `not-present`) — OPP-001
- [x] Trust classification honest (`review_status: local-candidate` until external acceptance) — OPP-010
- [x] EXAMPLES.md has prerequisites, intended use, runnable example, non-goals — OPP-003
- [x] COMPATIBILITY.md names supported AgToosa/platforms and untested/incompatible rows — OPP-004
- [x] MAINTENANCE.md has owner, review cadence, compatibility-update policy, issue path, deprecation process — OPP-009
- [x] Content-policy: only allowlisted extensions; no denylisted destinations — OPP-008
- [x] Isolated install/preview/queue/merge recorded (OPP-005–OPP-007); unsafe rejection recorded (OPP-008)

## Evidence links

| Test | Plan row | Purpose |
|------|----------|---------|
| OPP-001–OPP-004 | `docs/AgToosa_TestPlan-DEV-080.md` | Inventory, manifest, examples, compatibility |
| OPP-005–OPP-008 | same | Install / safety boundaries |
| OPP-009–OPP-010 | same | Maintenance + publication honesty |

## External publication state machine

| State | Meaning | Allowed claim |
|-------|---------|---------------|
| **local candidate** | Authored and proven in this repo only | “local candidate” / “not externally published” |
| **submitted** | PR or submission opened against `agtoosa-registry` | “submitted” — **not** published |
| **published** | Accepted external registry record independently confirmed | “externally published” / “available” in registry |

**Rule:** `published` requires confirmed external record. A local artifact or open PR is not proof of publication. Tasks 4.2/4.3 remain manual until a human completes external submission and confirmation.

## Generator-enforced vs manual controls

| Control | Class |
|---------|-------|
| Tar-slip pre-scan, SHA-256, verified flag, file allowlist, denylist, preview, consent | Generator-enforced |
| Content review, review cadence, external registry approval | Manual |
