# Official Pack Pilot — Review and Evidence Checklist

> **Stories:** DEV-080 (three pilots), DEV-095 (five-pack expansion)  
> **Catalog contract consumed:** `schema_version` **1.0** (`catalog/catalog.schema.json` / DEV-053)  
> **Maintainer:** sky2464  
> **Publication status (all five):** **local candidate** — not externally published

Trust label vocabulary (verified / community / official pilot): see `docs/AgToosa_Registry.md` → **Trust surface**.

## Pilot inventory (exactly five; Rev4 five-pack maximum)

| Pack root | Primary domain | Manifest | Fixture | Status |
|-----------|----------------|----------|---------|--------|
| `packs/official-web/` | web (stack-agnostic SPA) | `packs/official-web/manifest.json` | `tests/fixtures/registry-packs/official-web/` | local candidate |
| `packs/official-api/` | api | `packs/official-api/manifest.json` | `tests/fixtures/registry-packs/official-api/` | local candidate |
| `packs/official-infra/` | infrastructure | `packs/official-infra/manifest.json` | `tests/fixtures/registry-packs/official-infra/` | local candidate |
| `packs/official-react/` | react (React/Next/Vite) | `packs/official-react/manifest.json` | `tests/fixtures/registry-packs/official-react/` | local candidate |
| `packs/official-security/` | security | `packs/official-security/manifest.json` | `tests/fixtures/registry-packs/official-security/` | local candidate |

DEV-080 shipped the first three pilots. DEV-095 expands to the five-pack maximum (`official-react`, `official-security`) — see `docs/updates/rev4-conflict-resolutions.md`. A sixth official pilot pack is out of scope.

## Review checklist (per pack)

- [x] Manifest validates via `bash agtoosa.sh --catalog validate packs/<pack>/manifest.json` (schema_version 1.0) — OPP-002 / OPE-003
- [x] Provenance records version, source, sha256, signature field (signature may be `not-present`) — OPP-001 / OPE-003
- [x] Trust classification honest (`review_status: local-candidate` until external acceptance) — OPP-010 / OPE-010
- [x] EXAMPLES.md has prerequisites, intended use, runnable example, non-goals — OPP-003 / OPE-004
- [x] New packs (`official-react`, `official-security`) link a per-pack example repository — OPE-004
- [x] COMPATIBILITY.md names supported AgToosa/platforms and untested/incompatible rows — OPP-004 / OPE-005
- [x] MAINTENANCE.md has owner, review cadence, compatibility-update policy, issue path, deprecation process — OPP-009 / OPE-009
- [x] Content-policy: only allowlisted extensions; no denylisted destinations — OPP-008
- [x] Isolated install/preview/queue/merge recorded (OPP-005–OPP-007, OPE-006–OPE-007); unsafe rejection recorded (OPP-008)

## Evidence links

| Test | Plan row | Purpose |
|------|----------|---------|
| OPP-001–OPP-004 | `docs/AgToosa_TestPlan-DEV-080.md` | Inventory, manifest, examples, compatibility (original three) |
| OPP-005–OPP-008 | same | Install / safety boundaries |
| OPP-009–OPP-010 | same | Maintenance + publication honesty |
| OPE-001–OPE-010 | `docs/AgToosa_TestPlan-DEV-095.md` | Five-pack ceiling, react/security packs, domain split |

## External publication state machine

| State | Meaning | Allowed claim |
|-------|---------|---------------|
| **local candidate** | Authored and proven in this repo only | “local candidate” / “not externally published” |
| **submitted** | PR or submission opened against `agtoosa-registry` | “submitted” — **not** published |
| **published** | Accepted external registry record independently confirmed | “externally published” / “available” in registry |

**Rule:** `published` requires confirmed external record. A local artifact or open PR is not proof of publication. Tasks **4.2** (submit) and **4.3** (confirm) remain manual — follow the canonical procedure: [`docs/registry-external-publication-runbook.md`](registry-external-publication-runbook.md) (pre-submit → submit → confirm).

## Pack validation CI gate (DEV-096)

Official pilots are gated by `.github/workflows/pack-validate.yml` on changes to `packs/official-*`, `tests/fixtures/registry-packs/official-*`, or `scripts/validate-official-packs.sh`.

Local / CI commands:

```bash
bash scripts/validate-official-packs.sh --mode private
bats tests/agtoosa.bats -f "OPP"
bats tests/agtoosa.bats -f "DEV-095|OPE-"
```

The helper validates each pilot manifest (`bash agtoosa.sh --catalog validate`), checks `provenance.sha256` against pack `Docs/` content, and requires fixture `Docs/` tree parity. Failures print `pack=`, `file=`, `observed=`, and `expected=` diagnostics. Mode `private`/`offline` performs no registry network fetch. All five official packs must pass.

### Repair steps when the gate fails

1. **Manifest / catalog** — Fix `packs/<pack>/manifest.json` until `bash agtoosa.sh --catalog validate packs/<pack>/manifest.json` prints `Catalog valid`.
2. **SHA drift** — Recompute SHA-256 of `packs/<pack>/Docs/<workflow>.md` and update `provenance.sha256` in the manifest to match (do not edit the digest alone without matching bytes).
3. **Fixture parity** — Copy allowlisted `Docs/` files from `packs/<pack>/` into `tests/fixtures/registry-packs/<pack>/` (same relative paths and bytes). Remove orphan fixture `Docs/` files not present in the pack.
4. **Re-run** — `bash scripts/validate-official-packs.sh --mode private` then `bats tests/agtoosa.bats -f "OPP|OPE-"` until both exit 0.

## Generator-enforced vs manual controls

| Control | Class |
|---------|-------|
| Tar-slip pre-scan, SHA-256, verified flag, file allowlist, denylist, preview, consent | Generator-enforced |
| Pack validation CI (manifest + SHA + fixture parity + OPP bats) | CI-enforced (DEV-096) |
| Content review, review cadence, external registry approval | Manual |
