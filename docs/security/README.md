# AgToosa minisign public key (DEV-054 / ADR-011)

> **Status:** Maintainer pubkey + release `.minisig` sidecars shipped (DEV-054 M-1 complete 2026-07-08).
> Private key remains local only — **never** commit `*.minisign.key`.

## Verify a signed artifact

```bash
minisign -Vm <file> -p docs/security/agtoosa.minisign.pub
# or
export AGTOOSA_MINISIGN_PUBKEY=/path/to/key.pub
```

Signature sidecar: `<file>.minisig` (or registry entry `signature.url`).

## Claim boundary

- Optional verify is **soft-warn**: invalid/missing tool/pubkey → warning; install continues if SHA-256 (+ verified flag) pass.
- Unsigned packs/releases remain first-class.
- Fail-closed require-signatures and cosign verify are **roadmap**.
- Private-key generation remains **manual** (`DEV-054 M-1`).

See `docs/adr/ADR-011-minisign-primary-provenance.md` and `docs/AgToosa_Registry.md`.
