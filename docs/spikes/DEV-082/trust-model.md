# DEV-082 Layered Trust Model

> **Story:** DEV-082 · Spike evidence only — **no production implementation**  
> **Baseline:** DEV-054 / ADR-011 optional minisign soft-warn (unchanged)  
> **Evidence date:** 2026-07-11

## Claim labels

Observed · Tabletop · Assumed · Untested

---

## Four distinct layers (must not collapse)

| Layer | What it proves | Fail behavior today | Proposed fail-closed (roadmap only) | Surfaces |
|-------|----------------|---------------------|-------------------------------------|----------|
| **1. SHA-256 integrity** | Bytes match published digest | **Fail closed** on mismatch | Unchanged (already authoritative) | Registry packs · release assets (`SHA256SUMS`) |
| **2. Registry review status** | Curation / `verified` flag | Fail closed unless `--allow-unverified` / `AGTOOSA_ALLOW_UNVERIFIED` | Unchanged; **not** replaced by signatures | Registry packs |
| **3. DEV-054 optional soft-warn** | Cryptographic origin when `.minisig` / `signature.url` present | **Warn and continue** on verify failure / missing tool | Remains default forever unless separate approved story | Registry packs · release assets |
| **4. Proposed fail-closed signature policy** | Same crypto check, blocking availability contract | **Does not exist** — no flag, env, or exit path | Opt-in only; refuse install/update on absent/invalid/revoked sig or unreadable trust anchor per failure-matrix | Registry packs · release assets |

**Observed:** ADR-011 and `docs/AgToosa_Team_Trust_Roadmap.md` document layers 1–3 and park layer 4.

**Assumed:** Operators may conflate “signed” with “verified pack” — docs must keep language distinct.

---

## Protected surfaces

| Surface | Integrity (L1) | Review (L2) | Soft-warn (L3) | Proposed fail-closed (L4) |
|---------|----------------|-------------|----------------|---------------------------|
| Registry packs | SHA-256 pin at install | `verified` flag | Optional minisign | Opt-in refuse on sig failure |
| Release assets | `SHA256SUMS` / bootstrap pin | N/A (release channel trust) | Optional `.minisig` sidecar | Opt-in refuse on sig failure |

---

## Migration safety (AC-005)

| Existing artifact class | Today | Under proposed opt-in mode | Default path |
|-------------------------|-------|----------------------------|--------------|
| Unsigned pack / release | Works if L1 (+ L2 for packs) pass | Continues to work unless operator **explicitly** enables fail-closed | **Unchanged** |
| Valid soft-warn-signed | Soft-warn success (silent or success msg) | Passes fail-closed if mode enabled | Unchanged |
| Soft-warn-failing (bad sig / missing tool) | Warn + continue | Would **block** only if fail-closed enabled | Default remains soft-warn |

**Migration path:** documented opt-in (future story) after trust-anchor distribution, key ops, and rollback are proven. **Reject** any design that makes unsigned installs fail by default.

**Untested:** Live migration of a production unsigned install fleet (none enrolled).

---

## Non-replacement rule

Signature verification **must not** be described as replacing SHA-256 or registry review. Fail-closed mode would be an **additional** gate on top of L1/L2.
