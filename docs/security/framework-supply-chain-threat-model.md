# Threat Model: AgToosa Framework Supply Chain

**Status:** Documented mitigations + accepted residual risk (DEV-097)  
**Date:** 2026-07-12  
**Component:** AgToosa generator install chain, releases, catalog/registry, template outputs, maintainer CI  
**Companion:** Pack tarball content injection → [`template-injection-threat-model.md`](template-injection-threat-model.md) (do not duplicate AV catalog here)

---

## Overview

Community pack injection (DEV-064/065) is only one supply-chain surface. This document covers **framework-level** risks: how AgToosa itself is obtained, released, catalogued, generated into projects, and published by maintainers.

---

## Attack Surfaces

| Surface | Description |
|---------|-------------|
| **Pinned install chain** | `bootstrap.sh` / `curl \| bash` paths, Homebrew formula, npm wrapper download of release tarballs, optional `--ref` / `--sha256` pins |
| **Release artifacts** | GitHub Release assets, `SHA256SUMS`, optional minisign sidecars (DEV-054), version tags |
| **Catalog / registry metadata** | `catalog/catalog.json`, registry index URLs, pack manifests (`schema_version`, SHA-256, signature URLs) |
| **Generator template outputs** | Files copied from `template/` into projects (`Docs/`, platform adapters, hooks) |
| **Maintainer CI publish path** | Release workflows, environment protection, who can mint tags and upload assets |

---

## STRIDE Summary

| Category | Threat example | Mitigation / status | Residual risk |
|----------|----------------|---------------------|---------------|
| **Spoofing** | Impersonated registry or catalog host | HTTPS + documented registry URLs; SHA-256 on packs | DNS / hosting compromise of upstream |
| **Tampering** | Altered release tarball or pack archive | `SHA256SUMS`; tar-slip pre-scan; pack allowlist | Author with signing keys or release rights |
| **Repudiation** | Unclear which artifact was installed | Lock file + version marker (`Docs/agtoosa-lock.json`, `Docs/.agtoosa-version`) | Operational state (`.agtoosa/state.json`) is Wave 2 / DEV-093 |
| **Information Disclosure** | Staging dirs or lock files leak paths | Restrictive `mktemp` perms on apply staging; gitignore operational state | User machine logs outside AgToosa control |
| **Denial of Service** | Huge / malicious archives | Size/type allowlists; fail-fast validation | Disk exhaustion on large legitimate packs |
| **Elevation of Privilege** | Pack writes hooks/CI paths | Pack denylist for `.claude/settings.json`, hooks, `.github/workflows/` | AI assistants that later copy doc content into workflows (see pack TM) |

---

## Signing (DEV-054) — honest boundary

Minisign verification is **optional soft-warn**:

- Missing tool, missing pubkey, or invalid signature → **warning**; install continues when SHA-256 (+ verified flag policy) pass.
- Unsigned packs and releases remain first-class.
- This document does **not** claim signature-required install modes, cosign verification, or SLSA certification.

See `docs/security/README.md` (pubkey) and `docs/adr/ADR-011-minisign-primary-provenance.md`.

---

## Claim Boundary

| Control | Classification |
|---------|----------------|
| This framework threat model | documentation / manual |
| SHA-256 pack verify | generator-enforced (existing) |
| Tar-slip pre-scan | generator-enforced (existing) |
| Pack destination denylist | generator-enforced (existing) |
| Minisign | optional soft-warn (DEV-054) |
| Pinned `--ref` install | user / manual policy |
| Required-signature install mode | roadmap |

---

## Related

- Pack content injection deep-dive: [`template-injection-threat-model.md`](template-injection-threat-model.md)
- Registry user docs: `docs/AgToosa_Registry.md`
- Maintainer supply-chain notes: `docs/agtoosa-maintainer.md`

## Manual security-doc review pointer

At ship, record a short maintainer review that this file’s mitigation language still matches implemented generator behavior (no new enforcement claims).
