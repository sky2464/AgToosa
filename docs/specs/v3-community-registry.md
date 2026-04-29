# AgToosa v3 — Community Template Registry

## Problem Statement

AgToosa ships a fixed set of workflow markdown files. As the community grows, teams will want to share custom slash-command templates, domain-specific workflow extensions (e.g. ML pipelines, mobile apps, embedded systems), and alternative AI platform configs. There is currently no mechanism to discover, install, or contribute these.

A community registry lets users `bash agtoosa.sh --registry install ml-pipeline` and have trusted, versioned template packs land in their project alongside the core AgToosa files.

---

## Goals

- **Discoverability**: Browse and search published template packs.
- **Safety**: Users install only signed/verified packs; no silent code execution.
- **Simplicity**: No new runtime dependency beyond `bash` + `curl` (or `git`).
- **Contributor-friendly**: Publishing a pack should take < 10 minutes.

---

## Non-Goals (v3)

- Package dependency resolution between packs.
- Paid or private registries (v4 concern).
- GUI tooling.

---

## Registry Hosting

**Decision: GitHub-native, flat-file registry.**

The registry index lives in a dedicated repo (`sky2464/agtoosa-registry`) as a single `registry.json` file plus a `packs/` directory of individual pack manifests.

```
sky2464/agtoosa-registry/
  registry.json          # index: [{name, description, author, version, url, sha256}]
  packs/
    ml-pipeline.json     # individual pack manifest
    react-native.json
    ...
```

**Rationale:**
- Zero infrastructure cost; GitHub CDN for distribution.
- Pull requests are the contribution workflow — familiar to all developers.
- Registry index is human-readable and auditable.
- Alternatives considered: npm registry (requires Node), custom API (requires hosting + auth), Git submodules (too complex for end users).

---

## Authentication & Integrity

Each pack entry in `registry.json` includes:

```json
{
  "name": "ml-pipeline",
  "description": "Machine learning project workflow templates",
  "author": "sky2464",
  "version": "1.2.0",
  "url": "https://github.com/sky2464/agtoosa-ml-pipeline/archive/refs/tags/v1.2.0.tar.gz",
  "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "verified": true
}
```

**Integrity verification flow:**
1. `agtoosa.sh` downloads the tarball to `/tmp/agtoosa-pack-XXXX.tar.gz`.
2. Computes `sha256sum` of the downloaded file.
3. Compares against the `sha256` field in the registry. **Aborts on mismatch.**
4. Extracts into `ship/` staging area; user confirms before copying to project.

**Signing (v3):** SHA-256 hash in the registry index (maintained by `sky2464`). Pack authors submit a PR with the tarball URL and hash; a maintainer verifies the hash matches the release artifact before merging.

**Signing (v4 stretch):** GPG-signed registry index so users can verify the index itself hasn't been tampered with.

---

## User Experience

### Discovery

```bash
bash agtoosa.sh --registry list                        # list all packs
bash agtoosa.sh --registry search ml                   # search by keyword
bash agtoosa.sh --registry info ml-pipeline            # show pack details
```

### Installation

```bash
bash agtoosa.sh --registry install ml-pipeline         # install pack to current project
bash agtoosa.sh --registry install ml-pipeline@1.1.0  # pin to a specific version
```

Flow:
1. Fetch `registry.json` from `sky2464/agtoosa-registry` (cached for 1 h).
2. Find pack entry, display name / description / author / version.
3. Ask: "Install ml-pipeline v1.2.0 by sky2464? (Y/n)"
4. Download tarball, verify SHA-256.
5. Stage into `ship/packs/ml-pipeline/`.
6. Ask: "Copy pack files to `<project-path>`? (Y/n)"
7. Merge into project (same force/skip logic as core install).

### Contributing a Pack

```
1. Create a GitHub repo: your-org/agtoosa-my-pack
2. Tag a release: git tag v1.0.0 && git push --tags
3. Compute SHA-256: sha256sum <downloaded-tarball>
4. Open a PR against sky2464/agtoosa-registry:
   - Add entry to registry.json
   - Add packs/my-pack.json with full manifest + docs link
5. A maintainer reviews and merges.
```

---

## Security Model

| Threat | Mitigation |
|--------|-----------|
| Tampered tarball (MITM) | SHA-256 verification; abort on mismatch |
| Malicious pack content | Packs are markdown-only; no scripts executed during install |
| Registry index tampering | HTTPS fetch from GitHub; v4: GPG signature |
| Supply-chain (pack author goes rogue) | SHA-256 is pinned per version in registry; existing installs unaffected |
| Typosquatting | Registry is curated (PR review required); `--registry info` shows full author/repo |

**Markdown-only constraint**: Pack tarballs may only contain `.md` files and `.json` config stubs. `agtoosa.sh` will reject packs containing any other file type (enforced by the installer before staging).

---

## Implementation Plan

### Phase 1 — Registry read path (v3.0)

1. Add `--registry` flag parsing to `agtoosa.sh`.
2. Implement `lib/registry.sh`: `registry_list`, `registry_search`, `registry_info`, `registry_install`.
3. SHA-256 verification helper (uses `sha256sum` on Linux, `shasum -a 256` on macOS).
4. Create `sky2464/agtoosa-registry` repo with `registry.json` schema + first 2–3 example packs.
5. BATS tests for happy path and SHA mismatch rejection.

### Phase 2 — Contribution tooling (v3.1)

1. `bash agtoosa.sh --registry publish` wizard: guides pack author through tagging, tarball generation, and generating the PR body with the correct hash.
2. GitHub Action in `agtoosa-registry` that validates pack manifests on PR.

### Phase 3 — Signed index (v4)

1. GPG-signed `registry.json.sig` fetched alongside the index.
2. `agtoosa.sh` verifies signature if `gpg` is available; warns but proceeds if not (opt-in enforcement).

---

## Open Questions

1. **Registry repo governance**: Who can merge registry PRs? Start with `sky2464` as sole maintainer; add CODEOWNERS as community grows.
2. **Pack naming namespace**: Flat names (`ml-pipeline`) or scoped (`@sky2464/ml-pipeline`)? Start flat; add scoping if name collisions emerge.
3. **Version pinning in projects**: Should AgToosa record installed pack versions in a `Docs/agtoosa-lock.json`? Useful for reproducibility. Deferred to v3.1.
4. **Offline mode**: Should `--registry install` work from a local path? Yes — `--registry install ./my-local-pack` should skip the registry fetch and go straight to SHA verification + staging.
