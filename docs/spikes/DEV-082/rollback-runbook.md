# DEV-082 Rollback / Break-Glass Runbook (Tabletop)

> **Story:** DEV-082 · Spike evidence only — **unimplemented** control  
> **Evidence date:** 2026-07-11  
> **Label:** Tabletop unless noted Observed  
> Does **not** claim production fail-closed or break-glass automation exists.

## Purpose

If a future opt-in fail-closed signature mode caused lockout, operators must restore the **prior safe default** (DEV-054 soft-warn; SHA-256 + verified-flag gates remain). Bypass is **not** normal operation.

---

## Authorization (tabletop)

| Step | Actor | Requirement |
|------|-------|-------------|
| 1 | Requester | Document incident: time, artifact, error, blast radius |
| 2 | Approver | Distinct from sole online signer when dual-control applies |
| 3 | Executor | Apply temporary disable of fail-closed **only** (not disable SHA-256) |
| 4 | Auditor | Append audit record (actor, time, artifact, reason, duration) |

**Assumed:** Dual-control mirrors key-operations roles. **Untested:** Live dual-approval workflow.

---

## Independent trusted recovery material

Must **not** depend on the same unavailable private key or sole compromised channel:

| Material | Role | Independence |
|----------|------|--------------|
| Bundled / previously mirrored **public** key copy | Re-establish verify after rotation | Separate from private key |
| `SHA256SUMS` / lock digests | Integrity without signatures | Already authoritative (Observed) |
| Prior release tags + known-good git SHAs | Restore known software | Out-of-band from registry sig channel |
| Documented soft-warn default | Return path | Code/docs rollback to L3 behavior |

**Failure mode (AC-006):** If recovery needs the unavailable private key → rollback **unproven**; block **Adopt**.

---

## Break-glass entry (proposed steps)

1. Confirm SHA-256 / verified-flag gates still pass (do not weaken L1/L2).  
2. Obtain authorization per table above.  
3. Disable fail-closed mode only (future: unset opt-in flag / env — **not present today**).  
4. Record audit line.  
5. Bound duration (e.g. ≤24h) with owner for restoration.  
6. Prefer fixing trust anchor / re-signing over prolonged bypass.

---

## Restoration — return to safe default

| Check | Expected |
|-------|----------|
| Fail-closed mode | Off / not configured (today: never on) |
| Soft-warn | Active when `.minisig` present |
| SHA-256 | Fail-closed on mismatch |
| Registry `verified` | Enforced with allow-unverified opt-in |
| Audit | Break-glass closed with root cause |

**Tabletop exercise (2026-07-11):** Walked steps 1–6 against synthetic rotation failure (old pubkey vs new sig). Confirmed independent recovery = distribute new **public** key + keep SHA-256; private key not required for consumers. Timing: ~5–15 minutes documentation walk-through (not a production incident).

**Observed:** Current codebase has no `AGTOOSA_REQUIRE_SIGNATURES` to disable — rollback today is “do nothing; soft-warn remains.”

---

## Untested

- Timed fire-drill with two humans  
- Compromised pubkey CDN scenario  
- Automated audit log pipeline
