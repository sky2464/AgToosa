# AgToosa Registry — Community Template Packs

Browse, search, and install community-created workflow packs (domain-specific templates, platform configs, etc.).

---

## Quick Start

**List available packs:**
```bash
bash agtoosa.sh --registry list
```

**Search for packs:**
```bash
bash agtoosa.sh --registry search ml-pipeline
```

**Show pack details:**
```bash
bash agtoosa.sh --registry info ml-pipeline
```

**Install a pack:**
```bash
bash agtoosa.sh --registry install ml-pipeline
```

**Install a specific version:**
```bash
bash agtoosa.sh --registry install ml-pipeline@1.2.0
```

**Install a local pack (offline mode):**
```bash
bash agtoosa.sh --registry install ./my-local-pack
```

---

## What Are Packs?

Packs are bundles of markdown workflow files and configuration stubs that extend AgToosa for specific use cases:

- **Domain-specific workflows:** ML pipelines, mobile apps, embedded systems, data engineering, etc.
- **Platform configs:** Custom IDE rules, slash commands, and AI prompt templates.
- **Organizational standards:** Company-specific quality gates, review checklists, deployment procedures.

Packs are **markdown-only** for safety — no executable code is automatically run when you install them.

---

## Installation Flow

1. **Browse or search** the registry to find a pack.
2. **Confirm** when prompted (packs are reviewed by maintainers before publication).
3. **Download** the pack tarball from GitHub.
4. **Verify** the pack's SHA-256 hash against the registry (abort on mismatch).
5. **Stage** the pack files into your project's `ship/` directory.
6. **Review and merge** — the files integrate alongside core AgToosa workflows.

---

## Creating Your Own Pack

To publish a template pack:

1. Create a GitHub repo: `your-org/agtoosa-my-pack`
2. Write your workflow markdown files.
3. Tag a release: `git tag v1.0.0 && git push --tags`
4. Download the release tarball and compute its SHA-256:
   ```bash
   sha256sum agtoosa-my-pack-v1.0.0.tar.gz
   ```
5. Open a PR against `sky2464/agtoosa-registry`:
   - Add an entry to `registry.json` with name, description, author, version, URL, and SHA-256.
   - Add a `packs/my-pack.json` manifest with full metadata and link to your repo docs.

A maintainer will review and merge your contribution.

---

## Registry Index

The registry is maintained at **[sky2464/agtoosa-registry](https://github.com/sky2464/agtoosa-registry)**.

Each pack entry includes:
- **name** — Pack identifier (used in `--registry install <name>`)
- **description** — Short summary of what the pack provides
- **author** — GitHub username of the pack maintainer
- **version** — Semantic version (e.g., 1.2.0)
- **url** — Direct link to the release tarball on GitHub
- **sha256** — SHA-256 hash of the tarball (verified during install)
- **verified** — Whether the pack has been reviewed and approved

---

## Security

**How your safety is protected:**

- ✅ **SHA-256 verification** — Ensures the tarball wasn't tampered with during download.
- ✅ **Markdown-only content** — Packs contain only `.md` and `.json` files; no scripts are executed.
- ✅ **Registry review** — New packs require PR approval from maintainers before publication.
- ✅ **Pinned versions** — Each published version's hash is recorded; existing installs are unaffected if a pack author goes rogue.
- ✅ **HTTPS from GitHub** — Registry and pack tarballs are fetched over HTTPS from trusted GitHub CDN.

---

## Troubleshooting

**"Pack not found"**
- Check the pack name: `bash agtoosa.sh --registry list`
- Make sure you spelled it correctly (names are case-sensitive).

**"SHA-256 mismatch"**
- The downloaded file doesn't match the registry record.
- This usually means a network glitch; try again.
- If it persists, report it to the pack maintainer.

**"Network error"**
- The registry fetch failed (GitHub may be down or you lack internet).
- The registry is cached for 1 hour; try again later.
- For offline installation, use `--registry install ./local-pack`.

**"Pack version not found"**
- The `@version` you requested is not listed in `registry.json` for that pack name.
- Run `--registry info <name>` to see the version currently in the index.
- To install the index version, omit `@version`: `--registry install <name>`.
- Pinned installs fail closed; AgToosa will not install a different version silently.

**Version pinning**
- `--registry install <name>` installs the pack row for that name in the registry index.
- `--registry install <name>@1.2.0` installs only when the index lists exactly `1.2.0` for that name.

---

## Next Steps

1. **Discover packs** — `bash agtoosa.sh --registry list`
2. **Share your own** — Create a pack and submit a PR to the registry repo.
3. **Give feedback** — Open an issue on [sky2464/agtoosa-registry](https://github.com/sky2464/agtoosa-registry) with suggestions.
