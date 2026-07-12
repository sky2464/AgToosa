# AgToosa Catalog — Extension and Preset Discovery

Browse curated **extensions** (single registry packs) and **presets** (ordered, pinned sets) without replacing the Registry install authority.

> **Install safety:** All pack installation runs through `--registry install` with preview, consent, and SHA-256 verification. See `Docs/AgToosa_Registry.md` for the canonical install contract — this document does not duplicate those rules.

---

## Quick Start

**List catalog entries:**
```bash
bash agtoosa.sh --catalog list
```

**Search by keyword or tag:**
```bash
bash agtoosa.sh --catalog search ml
```

**Inspect an entry (compatibility + trust fields):**
```bash
bash agtoosa.sh --catalog info ext-ml-pipeline
```

**Validate a catalog file:**
```bash
bash agtoosa.sh --catalog validate catalog/catalog.json
```

**Generate a non-executing preset install plan:**
```bash
bash agtoosa.sh --catalog plan preset-fullstack-ml
```

Run each printed `--registry install name@version` command separately. The catalog never installs packs itself.

---

## Extensions vs Presets

| Kind | Purpose |
|------|---------|
| **extension** | Curated discovery metadata for one pinned registry pack (name, version, provenance snapshot). |
| **preset** | Ordered list of extension IDs with rationale; `plan` resolves members and emits registry commands. |

---

## Compatibility

`info` and `plan` evaluate:

- AgToosa semantic-version range (`compatibility.agtoosa`)
- Required platforms (installed sentinels: `.cursor/`, `.claude/`, etc.)
- Required capabilities (queued packs under `.agtoosa/pack-queue/`)
- Declared conflicts and deprecation (`lifecycle: deprecated`)

Results: `compatible`, `incompatible`, or `unknown` with reasons. An `unknown` result never implies compatibility.

---

## Trust and Provenance (Separate Fields)

Catalog output shows these fields **independently**. None of them is a security guarantee:

| Field | Meaning |
|-------|---------|
| **Curation tier** | Human governance label (`official`, `community-reviewed`, `experimental`, …). |
| **Registry verified (snapshot)** | Registry `verified` value at catalog review time — authoritative value is always the live registry index. |
| **Review status** | Catalog maintainer review state (`reviewed`, `not-reviewed`). |
| **Checksum (snapshot)** | SHA-256 pinned in the catalog entry — registry SHA-256 wins at install time. |
| **Signature state (snapshot)** | Optional minisign sidecar state at review time. |

If catalog provenance drifts from the registry index, the entry is **stale** and `plan` withholds ready install commands until reconciled.

---

## Claim Boundary (v1)

- No hosted marketplace, ratings, or automatic preset installation.
- No catalog authority over registry metadata, verification, or merge behavior.
- Curation recommendations are not cryptographic trust.

---

## Related

- **Registry (canonical install):** `Docs/AgToosa_Registry.md`
- **Production catalog data:** `catalog/catalog.json` in the AgToosa generator repository (shipped as reference; teams may fork for private catalogs in future stories).
