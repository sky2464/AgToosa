# ADR-011: Minisign-primary optional provenance (soft warn)

> **Status:** Accepted  
> **Date:** 2026-07-08  
> **Deciders:** AgToosa maintainers (DEV-054 enrollment)  
> **Related:** ADR-002 (registry), DEV-065 (verified flag), DEV-066 (SHA256SUMS), DEV-054

## Context

Pack installs already fail closed on SHA-256 mismatch and enforce the registry `verified` flag (with `--allow-unverified` opt-in). Releases publish `SHA256SUMS`. Cryptographic signatures were deferred (ADR-002 mentioned GPG-signed `registry.json` at “v4”). DEV-054 enrolls optional signatures without making them mandatory or automating private-key handling.

## Decision

1. **Primary algorithm:** minisign (Ed25519). Cosign/Sigstore is documented as a future alternate only.
2. **Surfaces:** one provenance contract for **registry packs** and **release assets**.
3. **Posture:** when a signature artifact is present, attempt verify; on any verify failure (invalid sig, missing tool, missing pubkey) **warn and continue** if integrity/curation gates still pass. Absent signature → unchanged behavior.
4. **Trust anchor:** bundled public key path under `docs/security/` with override `AGTOOSA_MINISIGN_PUBKEY`. Private keys remain Manual/Deferred (`DEV-054 M-1`) and must never be committed.
5. **Out of this decision:** fail-closed `AGTOOSA_REQUIRE_SIGNATURES`, SBOM generation, cosign verify implementation, CI signing automation.

## Consequences

**Positive:** Honest incremental assurance; bats can use fixture keys; unsigned ecosystem keeps working; aligns with Team Trust “not yet mandatory” language.

**Negative:** Soft-warn can be ignored; users may over-read “signed provenance” marketing; real release signatures still wait on M-1.

**Supersedes (narrowly):** ADR-002’s “GPG signing of registry.json (v4)” as the *primary* planned algorithm for this enrollment — GPG/cosign remain possible future alternates; fail-closed index signing remains roadmap.
