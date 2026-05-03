# ADR-002: Community Template Registry Design

**Status:** Accepted  
**Date:** 2026-05-01  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa users want to share and reuse domain-specific workflow packs (e.g., `ml-pipeline`, `react-native`, `microservices`). These packs extend the core 4-phase workflow with specialized templates, context files, and platform-specific instructions. We need a distribution mechanism that:

- Requires no infra to host or run (no registry server, no paid tier)
- Verifies pack integrity against tampering or supply-chain compromise
- Allows version pinning for reproducible project setups
- Stays within the zero-dependency constraint (bash + curl only)
- Supports offline installs for air-gapped or corporate environments

Phase 1 (v3.0.0) delivered the read path: list, search, info, install, and offline install. Phase 2 (v3.1) will add the write path (contribution tooling). Phase 3 (v4) adds cryptographic signing of the index itself.

---

## Decision

**Use a GitHub-native flat-file registry hosted at `sky2464/agtoosa-registry`, fetched over HTTPS with SHA-256 per-tarball integrity verification and a 1-hour local cache.**

The registry is a single `registry.json` index plus per-pack manifests (`packs/<name>.json`). Packs are GitHub release tarballs. No registry server is needed — GitHub's CDN serves all files. The index is curated (PR review required) to prevent typosquatting. Per-tarball SHA-256 pinning means existing installs are unaffected if a pack author later goes rogue or publishes a malicious version.

---

## Options Considered

### Option A: GitHub-Native Flat-File Registry (current)

```
sky2464/agtoosa-registry/
  registry.json          # [{name, description, author, version, url, sha256, verified}]
  packs/
    <name>.json          # individual pack manifests
```

Install flow: fetch index → user selects pack → fetch tarball → verify SHA-256 → stage files → merge.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low — HTTPS fetch + SHA-256 check |
| Hosting cost | Free (GitHub CDN) |
| Scalability | High for read; Medium for write (PR bottleneck) |
| Offline support | ✅ `./local-pack` path |
| Integrity | SHA-256 per tarball; GPG index signing (v4) |
| Zero-dependency | ✅ `curl` + `sha256sum`/`shasum` |

**Pros:**
- No infra to run or pay for
- GitHub's CDN is reliable and globally available
- PR-based curation prevents name squatting and malicious packs
- SHA-256 pinning means compromised pack author cannot silently affect existing installs
- Offline path works today

**Cons:**
- Index updates require a PR (write latency ~hours)
- No dependency resolution between packs
- No `agtoosa-lock.json` yet — reproducibility depends on user pinning versions manually
- Large pack count (>500) will make `registry.json` unwieldy without pagination

### Option B: npm Registry (scoped `@agtoosa/` packages)

Publish packs as npm packages. Install via `npm install @agtoosa/ml-pipeline`.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Medium — npm publish workflow |
| Hosting cost | Free (public npm) |
| Scalability | High — npm handles millions of packages |
| Offline support | ❌ Requires npm cache or Verdaccio proxy |
| Integrity | npm provenance / package-lock.json |
| Zero-dependency | ❌ Requires Node.js |

**Pros:**
- Industry-standard; contributors already know npm publish
- Dependency resolution built in (semver ranges)
- `package-lock.json` provides reproducibility out of the box

**Cons:**
- Breaks zero-dependency constraint (Node.js required)
- npm scoped packages require an npm account and org for `@agtoosa/`
- Overkill for markdown-only file distribution

### Option C: Git Submodules

Each pack is a separate git repo; projects include packs as submodules.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low for author, High for user (submodule UX is notoriously poor) |
| Hosting cost | Free |
| Scalability | Low — submodule churn in user repos |
| Offline support | ✅ Git is available |
| Integrity | Git SHA pinning |
| Zero-dependency | ✅ Git required (already a dependency) |

**Pros:**
- No separate registry infra
- Cryptographic integrity via git commit SHAs

**Cons:**
- Submodule UX is poor; users regularly forget `--recurse-submodules`
- Projects accumulate submodule noise
- No discovery mechanism — users must know the pack's repo URL in advance

---

## Trade-off Analysis

Option A (flat-file GitHub registry) is the correct choice for v3.x. The zero-dependency constraint eliminates Option B. Option C solves integrity but sacrifices discovery and usability. The main risk in Option A is **index scalability** at high pack counts and **no lock file** for reproducibility — both are known gaps addressed in v3.1 and v4.

The PR-review bottleneck for index writes is acceptable at current community size and is a feature (curation prevents typosquatting). If the registry grows to hundreds of packs, a GitHub Action auto-approval workflow for verified authors can reduce latency without losing curation.

---

## Security Model

| Threat | Mitigation | Status |
|--------|-----------|--------|
| Tampered tarball (MITM) | SHA-256 verify in `compute_sha256`; abort on mismatch | ✅ Shipped |
| Malicious pack code execution | Packs are markdown-only; no scripts executed during install | ✅ By design |
| Registry index tampering | HTTPS from GitHub; GPG-signed index | ⏳ v4 |
| Rogue pack author (post-publish) | SHA-256 pinned per version; existing installs unaffected | ✅ Shipped |
| Typosquatting | Curated registry (PR review required) | ✅ By policy |
| Offline install with no SHA manifest | Local packs skip registry lookup; manifest optional | ⚠️ Gap: no enforcement |

---

## Consequences

**Easier:**
- Zero-infra distribution — no server to maintain, no paid tier
- Pack integrity is verifiable without trusting the author's hosting
- Offline installs work without any registry interaction

**Harder:**
- Reproducible builds require manual version pinning until `agtoosa-lock.json` ships
- Inter-pack dependencies must be resolved manually (no dependency graph)
- Registry pagination needed if pack count exceeds ~200 entries

**Will need to revisit:**
- `agtoosa-lock.json` for pack version pinning (v3.1)
- File-type enforcement in staging (`lib/registry.sh` — reject non-markdown files)
- GPG signing of `registry.json` index (v4)
- Pagination or indexing strategy if pack count exceeds 200
- Auto-approval GitHub Action for verified authors (when PR bottleneck becomes painful)

---

## Action Items

1. [x] Ship read path: list, search, info, install, offline install (v3.0.0)
2. [ ] Implement `agtoosa-lock.json` — record installed pack name, version, sha256 (v3.1)
3. [ ] Add file-type allowlist enforcement in staging — reject `.sh`, `.py`, etc. (v3.1)
4. [ ] Ship `--registry publish` contribution wizard (v3.1)
5. [ ] Add GitHub Action in `agtoosa-registry` to lint/validate pack manifests (v3.1)
6. [ ] Design GPG-signed index verification (v4)
7. [ ] Define pagination strategy for registry.json when pack count approaches 200
