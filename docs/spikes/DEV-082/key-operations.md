# DEV-082 Synthetic Key Lifecycle Operations

> **Story:** DEV-082 · Spike evidence only — **no production implementation**  
> **Material:** Disposable synthetic minisign keys **outside the repository**; destroyed after observation  
> **Evidence date:** 2026-07-11  
> **Private-key nonretention:** Confirmed — no `.key` / secret material committed under `docs/spikes/DEV-082/`

## Confidence labels

| Label | Use here |
|-------|----------|
| **Observed** | Commands run on maintainer workstation (darwin; `minisign` at `/opt/homebrew/bin/minisign`) |
| **Tabletop** | Role / process steps reasoned without production systems |
| **Assumed** | Industry practice not measured here |
| **Untested** | Explicitly not exercised |

---

## Roles (tabletop)

| Role | Duty | Separation |
|------|------|------------|
| Key generator | Create keypair offline | Distinct from day-to-day release signer when dual-control required |
| Signer | Sign release/pack artifacts | Does not control pubkey distribution alone |
| Distributor | Publish pubkey + document fingerprint | Authenticated channel (release notes / docs/security) |
| Auditor | Record generate/rotate/revoke/break-glass events | Read-only to private key material |
| Recovery officer | Independent recovery material + break-glass | Must not be the sole online signer |

---

## Lifecycle coverage (AC-003)

| Operation | How exercised | Result | Label |
|-----------|---------------|--------|-------|
| **Generation** | `minisign -G -W` in `/tmp/agtoosa-dev082-synth.*` | Keypair created; pubkey printable | Observed |
| **Offline custody** | Private key never copied into repo; held only in temp dir | Temp dir destroyed after run | Observed |
| **Signer separation** | Roles table above; single operator ran synth | Dual-control not exercised | Tabletop |
| **Public-key distribution** | Model: ship pubkey under `docs/security/` + `AGTOOSA_MINISIGN_PUBKEY` override (existing DEV-054) | Path exists for soft-warn today | Observed (path); Assumed (HA distribution SLAs) |
| **Rotation** | New keypair; resign artifact; verify with new pubkey | Success; old pubkey fails new sig (key id mismatch) | Observed |
| **Revocation** | Treat old pubkey as revoked after rotation; refuse verify with revoked anchor | Old pubkey vs new sig → exit 1 | Observed (synthetic) |
| **Expiry** | No native minisign cert expiry; policy expiry via documented rotate-by date | Policy-only | Assumed |
| **Recovery** | Independent trusted pubkey copy + prior SHA-256SUMS; not the same unavailable private key | See rollback-runbook | Tabletop |
| **Audit** | Record actor, time, artifact, reason for each key action | Spike records timestamps in this file | Tabletop |
| **Private-key nonretention** | `rm -f *.key`; entire synth dir removed | `test ! -d $SYNTH` OK | Observed |

### Synthetic observation excerpt (2026-07-11)

```text
# Ephemeral dir (destroyed; path not retained as durable state)
minisign -G -W -p synth.pub -s synth.key
minisign -S -W -s synth.key -m artifact.txt
minisign -V -p synth.pub -m artifact.txt   # success
# rotation
minisign -G -W -p synth-rotated.pub -s synth-rotated.key
minisign -S -W -s synth-rotated.key -m artifact.txt -x artifact.txt.rotated.minisig
minisign -V -p synth.pub -m artifact.txt -x artifact.txt.rotated.minisig
# → Signature key id mismatch; exit 1 (EXPECTED)
rm -f synth.key synth-rotated.key && rm -rf $SYNTH
```

**Do not treat this as production key operations.** No production private key was generated, stored, or logged.

---

## Production readiness claim

**None.** Synthetic/tabletop only. Fail-closed enforcement does **not** exist.

## Untested

- HSM / hardware token custody
- Dual-control ceremony with two humans
- Cosign/Sigstore alternate path
- Windows PowerShell signing workflow
