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
2. **Check verified status** — unverified packs are rejected unless you pass `--allow-unverified` (or set `AGTOOSA_ALLOW_UNVERIFIED=1`).
3. **Download** the pack tarball from GitHub.
4. **Verify SHA-256** against the registry index (abort on mismatch).
5. **Pre-scan the archive** — member paths with absolute segments or `..` are rejected **before** extraction (tar-slip protection).
6. **Stage in isolation** — the pack extracts to a temp directory, never directly into your project.
7. **Preview and confirm** — AgToosa prints the full file tree, flags AI-instruction surfaces, and marks denylisted paths that will be skipped at merge. Confirm to proceed.
8. **Queue** validated files under `.agtoosa/pack-queue/<pack-name>/` (durable staging outside ephemeral `ship/`).
9. **Merge** — run `bash agtoosa.sh` in your project to integrate queued packs alongside core AgToosa workflows.

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

## Offline cache and trust

AgToosa caches `registry.json` locally so list/search/info work when the network is slow or unavailable (default TTL: 1 hour).

| Surface | Cache location |
|---------|----------------|
| Bash | `$AGTOOSA_REGISTRY_CACHE_DIR/registry.json` if set, else `~/.cache/agtoosa/registry.json` |
| PowerShell | `%USERPROFILE%\.cache\agtoosa\registry.json` |

**HTTPS trust model:** The registry index is downloaded over HTTPS from GitHub only. There is no GPG or signed manifest for `registry.json` in v1 — treat the index as trusted to the same degree as the HTTPS origin. If you need a fresh index, delete the cache file (or wait for TTL expiry) and run `--registry list` again when online.

**High-assurance installs:** Pack tarballs are always SHA-256 checked against the hash in the index during install. For stricter environments, pre-seed `AGTOOSA_REGISTRY_CACHE_DIR` with a vetted `registry.json` and independently verify each pack's SHA-256 (e.g. `sha256sum`) against a trusted source before `bash agtoosa.sh --registry install <name>`.

**Publishing packs:** Use Bash — `bash agtoosa.sh --registry publish` (the PowerShell port prints a redirect; it does not run the publish wizard).

---

## Security

**How your safety is protected:**

- ✅ **SHA-256 verification** — Ensures the tarball wasn't tampered with during download.
- ✅ **Tar-slip pre-scan** — Archive member lists are checked for absolute paths and `..` segments **before** extraction; hostile tarballs are rejected without writing to disk.
- ✅ **Isolated staging** — Packs extract to a temp directory first; only user-confirmed content reaches `.agtoosa/pack-queue/`.
- ✅ **Informed-consent preview** — Before queueing, AgToosa prints the full file tree and flags AI-instruction surfaces (`.cursor/*`, `CLAUDE.md`, etc.) so you know what your assistant will follow.
- ✅ **Verified-pack gate** — Registry entries with `"verified": false` are rejected unless you pass `--allow-unverified` (or set `AGTOOSA_ALLOW_UNVERIFIED=1`).
- ✅ **Sensitive-path denylist** — Packs cannot write to `.claude/settings.json`, `.claude/hooks/`, or `.github/workflows/` (blocked at preview and merge).
- ✅ **Markdown-only content** — Packs contain only `.md` and `.json` files; no scripts are executed.
- ✅ **Registry review** — New packs require PR approval from maintainers before publication (`verified: true`).
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

**"Pack not verified"**
- The pack exists in the index but has `"verified": false` (not yet reviewed by registry maintainers).
- Prefer waiting for maintainer approval, or install with explicit opt-in: `bash agtoosa.sh --allow-unverified --registry install <name>`.
- Unverified packs still run the full preview and denylist checks — verification status is about maintainer review, not tarball integrity.

**"Archive contains path traversal" or "absolute path member"**
- The tarball failed the pre-extraction tar-slip scan (a member path escapes the archive root).
- Do not install the pack; report it to the pack maintainer and registry maintainers.
- For local packs, rebuild the tarball with relative paths only.

**Version pinning**
- `--registry install <name>` installs the pack row for that name in the registry index.
- `--registry install <name>@1.2.0` installs only when the index lists exactly `1.2.0` for that name.

---

## Next Steps

1. **Discover packs** — `bash agtoosa.sh --registry list`
2. **Share your own** — Create a pack and submit a PR to the registry repo.
3. **Give feedback** — Open an issue on [sky2464/agtoosa-registry](https://github.com/sky2464/agtoosa-registry) with suggestions.
