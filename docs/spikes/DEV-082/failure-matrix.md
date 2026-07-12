# DEV-082 Fail-Closed Failure Matrix

> **Story:** DEV-082 · Spike evidence only — **proposed** outcomes only  
> **Default today:** DEV-054 soft-warn (unchanged)  
> **Evidence date:** 2026-07-11  
> Labels: Observed · Tabletop · Assumed · Untested

## How to read this matrix

- **Soft-warn (current):** observed/documented DEV-054 behavior.  
- **Fail-closed (proposed):** tabletop expected outcome **if** a future opt-in mode existed. **Not implemented.**

Both surfaces: **registry packs** and **release assets**, unless noted.

---

## Failure cases

| ID | Failure condition | Soft-warn today (L3) | Proposed fail-closed (L4) | Recovery prerequisite | Label |
|----|-------------------|----------------------|---------------------------|----------------------|-------|
| F-01 | Signature **absent** | Unchanged path (no sig attempt) | **Block** install/update when mode enabled | Operator disable mode **or** obtain signed artifact | Tabletop |
| F-02 | Signature file **unreadable** / corrupt path | Warn + continue | **Block** | Fix path/perms; or break-glass rollback | Tabletop |
| F-03 | Signature **invalid** (wrong key / tampered) | Warn + continue (Observed SP-002 pattern) | **Block** | Re-fetch authentic artifact; verify SHA-256 still authoritative | Observed (soft-warn); Tabletop (fail-closed) |
| F-04 | Trust anchor / pubkey **stale** after rotation | Warn if verify fails | **Block** until new pubkey distributed | Distribute rotated pubkey via authenticated channel | Observed (synth rotation mismatch) |
| F-05 | Trust anchor **revoked** | Same as verify fail → warn | **Block**; refuse revoked key id | Publish revocation notice + successor pubkey | Tabletop |
| F-06 | Verifier tooling **unavailable** (`minisign` missing) | Warn + continue (Observed SP-003) | **Block** (tooling required under HA mode) **or** documented offline exception | Install minisign **or** authorized break-glass | Observed (soft-warn); Tabletop (fail-closed) |
| F-07 | **Offline** operation (no network to fetch sig/pubkey) | Uses local cache/bundled pubkey; soft-warn if incomplete | Bundled pubkey required; missing sig → **Block** | Pre-stage sig + pubkey; SHA-256 still checked | Tabletop |
| F-08 | **Cache** hit with unsigned or soft-warn-failed artifact | Soft-warn path as today | Cached artifact must satisfy L4 or **Block** | Invalidate cache; re-fetch signed | Tabletop |
| F-09 | **Interrupted rotation** (mix of old/new keys mid-release) | Warn on mismatches | **Block** until single coherent trust set | Freeze releases; complete rotation runbook | Tabletop |
| F-10 | Pubkey override `AGTOOSA_MINISIGN_PUBKEY` points to wrong file | Warn + continue | **Block** | Fix override; audit who set it | Assumed |

---

## Availability note

Fail-closed converts signature/tooling problems into **denial of service** for installs. Soft-warn deliberately avoids that. Any future L4 mode must ship with the rollback runbook and independent recovery material.

**Untested:** Production lockout incident; multi-region cache poisoning with signed-looking garbage.
