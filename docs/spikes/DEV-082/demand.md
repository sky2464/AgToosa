# DEV-082 Demand Evaluation — High-Assurance Signature Mode

> **Story:** DEV-082 · Spike S · Epic DEV-003  
> **Evidence date:** 2026-07-11  
> **Claim boundary:** Manual research evidence only. Not market-wide demand. **Spike evidence only — no production implementation.**

## Predefined decision criteria (set before findings)

| Outcome | Threshold (must all hold for that outcome) |
|---------|--------------------------------------------|
| **Adopt** | ≥1 representative high-assurance user/org with named protected surfaces + blocking semantics + adoption constraints; authorized security reviewer; operable key lifecycle + independent rollback; migration remains opt-in |
| **Defer** | Demand is maintainer-hypothetical, pack ecosystem below ADR-002 revisit trigger, or operability incomplete — keep soft-warn baseline |
| **Reject** | Proposed design would fail unsigned installs by default, or recovery depends on the unavailable key/channel |

**Labels used below:** Observed · Tabletop · Assumed · Untested

---

## Representative scenarios

| ID | Scenario | Current workaround | Protected surfaces | Blocking semantics (proposed) | Adoption constraints | Evidence source | Label |
|----|----------|--------------------|--------------------|-------------------------------|----------------------|-----------------|-------|
| D-01 | Regulated org wants install to refuse unsigned registry packs | Soft-warn + SHA-256 fail-closed + `verified` flag + `--allow-unverified` opt-in | Registry packs | Fail install when signature absent/invalid under explicit opt-in mode | Needs dual-control key ops + break-glass | Maintainer persona; no enrolled customer named | Assumed |
| D-02 | Release pin with cryptographic signature mandatory on bootstrap tarball | Soft-warn on `.minisig` when present; SHA256SUMS fail-closed on mismatch; `--ref` pin fail-closed | Release assets | Fail bootstrap when sig missing/invalid under opt-in | Offline + missing minisign must be defined | ADR-011 / Team Trust roadmap language | Observed (docs) |
| D-03 | Community pack ecosystem grows; unsigned packs become supply-chain concern | `verified: false` gate; file allowlist; denylist; tar-slip scan | Registry packs + index | Fail-closed only after trust-anchor ops mature | ADR-002 revisit when pack count **>10** | ADR-002 action item 6; registry pack count near zero | Observed |
| D-04 | Air-gapped CI wants fail-closed signatures without network key fetch | Bundle pubkey + SHA-256; soft-warn if minisign missing | Both | Must not hard-depend on network for trust anchor | Offline policy required | Spec AC-004 offline row | Tabletop |

---

## Demand synthesis

| Finding | Label |
|---------|-------|
| No GitHub issues or external tickets requesting `AGTOOSA_REQUIRE_SIGNATURES` were found during this spike | Observed |
| ADR-002 documents re-evaluate fail-closed when community pack count >10; current pack count remains near zero / zero community packs | Observed |
| Team Trust / Readiness / CONTEXT list fail-closed require-signatures as **roadmap**, not a shipped need with enrolled users | Observed |
| Soft-warn (DEV-054) already covers “signature present → attempt verify” without availability lockout | Observed |
| Hypothetical regulated-org persona (D-01) is **not** an adoption signal per AC-001 failure mode | Assumed |

**Demand verdict:** Insufficient representative high-assurance demand to meet the **Adopt** threshold. Prefer **Defer**.

---

## Untested

- Direct interviews with regulated adopters
- Live pack-count telemetry from a public registry host (no silent telemetry collected)
- Enterprise procurement questionnaires citing fail-closed signatures
