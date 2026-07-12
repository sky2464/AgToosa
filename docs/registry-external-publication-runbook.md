# External Registry Publication Runbook

> **Story:** DEV-103  
> **Extends:** DEV-080 tasks **4.2** (external submission) and **4.3** (acceptance confirmation)  
> **Audience:** Pack maintainers submitting official pilots to `agtoosa-registry`  
> **Non-goals:** Automating external approval, CI publish to a remote registry, or changing local `--registry install` / `--registry publish` behavior

This runbook is the **canonical manual procedure** for external publication. Local OPP proof and `agtoosa.sh --registry publish` (local staging) are **not** external publication.

Trust label vocabulary (verified / community / official pilot) stays in `docs/AgToosa_Registry.md` → **Trust surface** (DEV-101). This runbook does not redefine those labels.

## Publication state machine (DEV-080)

| State | Meaning | Allowed claim |
|-------|---------|---------------|
| **local candidate** | Authored and proven in this repo only | “local candidate” / “not externally published” |
| **submitted** | PR or submission opened against `agtoosa-registry` | “submitted” — **not** published |
| **published** | Accepted external registry record **independently confirmed** | “externally published” / “available” in registry |

**Order:** local candidate → submitted → published.

**Honesty rules:**

- A local pack artifact is **not** proof of publication.
- Opening a PR does **not** constitute external publication.
- Merging a PR alone is **not** enough until the accepted external record is independently confirmed.
- Do **not** claim publication based only on local artifacts.

---

## 1. Pre-submit validation

Complete every gate **before** opening an external submission. Prefer evidence already recorded in `docs/official-pack-pilot-checklist.md` and OPP bats (`docs/AgToosa_TestPlan-DEV-080.md`).

### Pre-submit checklist

- [ ] **Manifest validation** — `bash agtoosa.sh --catalog validate packs/<pack>/manifest.json` (DEV-053 `schema_version` 1.0) passes; OPP-002 green.
- [ ] **OPP green evidence** — OPP-001–OPP-010 (or current OPP set for the pack) green; checklist review items signed off for this pack.
- [ ] **Content-policy review** — only allowlisted extensions; no denylisted destinations; unsafe rejection path still documented (OPP-008).
- [ ] **Maintainer ownership** — `MAINTENANCE.md` owner, review cadence, issue path, and deprecation process present (OPP-009).
- [ ] **Compatibility declarations** — `COMPATIBILITY.md` names supported AgToosa/platforms and untested/incompatible rows (OPP-004).
- [ ] **Trust honesty** — pack remains `review_status: local-candidate` / inventory **local candidate** until confirmation (OPP-010); do not pre-label as published.

### Evidence links to attach (or cite)

| Artifact | Typical path / pointer |
|----------|------------------------|
| Pilot checklist | `docs/official-pack-pilot-checklist.md` |
| OPP test plan | `docs/AgToosa_TestPlan-DEV-080.md` |
| Pack root | `packs/<pack>/` |
| Manifest | `packs/<pack>/manifest.json` |
| Install fixture | `tests/fixtures/registry-packs/<pack>/` |
| Focused bats | `bats tests/agtoosa.bats -f "DEV-080\|OPP-"` |

Do **not** open the external PR until this section is complete.

---

## 2. Submit (DEV-080 task 4.2)

Open a submission against the external `agtoosa-registry` repository/process. This step sets inventory state to **submitted** only — it does **not** make the pack published or available in the registry.

### Required registry record fields

Include (or link) at least:

| Field | Purpose |
|-------|---------|
| Pack name / id | Matches local pack identity |
| Version | Exact version under submission |
| Artifact pointer | Tarball URL, release asset, or path the registry consumes |
| SHA-256 | Hash of the submitted artifact |
| Manifest / metadata | Identity, ownership, compatibility, trust fields (DEV-053) |
| Provenance notes | Source repo, commit, or release tag |
| Reviewer contact path | Maintainer issue URL, PR reviewers, or registry contact listed in the external repo |

### Submission steps

1. Confirm pre-submit checklist is complete.
2. Open the external registry PR or submission record with the fields above.
3. Record the **PR/record URL** in the pilot checklist notes (or adjacent evidence).
4. Update inventory / checklist status from **local candidate** → **submitted** only.
5. Notify reviewers via the documented contact path; wait for external review.

### What this step does **not** claim

- Opening a PR does **not** equal published.
- `bash agtoosa.sh --registry publish` stages or proves **local** packs; it does **not** automatically publish to the external registry.
- There is **no** AgToosa CI Action that externally publishes packs as part of this runbook.

---

## 3. Confirm (DEV-080 task 4.3)

After the external registry accepts the record, **independently verify** that acceptance before changing inventory state to **published**.

### Confirmation checklist

- [ ] Locate the **accepted external registry record** (merged index row, published registry.json entry, or equivalent).
- [ ] **Independently confirm** name, version, SHA-256, and artifact pointer match what was submitted.
- [ ] Confirm the record is visible through the registry’s normal consumer path (not only a PR discussion).
- [ ] Only then update inventory / checklist from **submitted** → **published** (allowed claim: “externally published” / “available” in registry).
- [ ] Align trust wording with DEV-101: official pilot may leave “local candidate” claims; do not call community packs “verified” here.

### Forbidden confirmation shortcuts

- Do **not** set inventory to **published** on PR open alone.
- Do **not** treat a merged PR as publication without verifying the accepted external record.
- Do **not** treat a local artifact as externally published.

---

## Discovery

| Surface | Link |
|---------|------|
| This runbook | `docs/registry-external-publication-runbook.md` |
| Pilot checklist (OPP + 4.2/4.3) | `docs/official-pack-pilot-checklist.md` |
| Registry trust + inventory | `docs/AgToosa_Registry.md` → Trust surface · Official Pack Pilot |
| Template mirror | `template/Docs/AgToosa_Registry.md` (discovery link only) |

## Claim boundary

| Control | Classification |
|---------|----------------|
| This runbook | documentation / manual procedure |
| Local OPP proof | CI-enforced in this repository |
| External registry acceptance | manual / external |
| Pack install safety | generator-enforced; unchanged by this runbook |
