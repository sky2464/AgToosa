# ADR-017: Fresh Public Claims and Windows Backend Truth

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** User + AI agent (DEV-118 interview and approval)
**Related:** ADR-015 (Product Truth Contract) · DEV-105 (PowerShell Maintain Parity) · DEV-120 (Delivery Proof Fabric)

## Context

Public AgToosa documentation currently mixes implementation facts, workflow guidance, evidence tiers, and roadmap language. Some claims say “fully supported,” “only,” “enforced,” or “zero-downtime” without evidence that earns those terms. Several already-shipped stories are still described as backlog.

Windows guidance has a related truth gap. `bootstrap.ps1` ultimately runs `agtoosa.sh` through Git Bash; several PowerShell maintenance operations delegate to Bash; registry publish redirects; and Python is used by important paths without coherent disclosure. The advertised pinned PowerShell snippet sets a caller variable but does not bind that value to the downloaded script parameter.

## Decision

1. Add a claim ledger to the Product Truth Contract. Every active governed claim records a stable capability ID, owner, target/surface, status, enforcement or evidence class, evidence reference, evidence commit/tool version when available, governed surfaces, `owner_contract_id`, `owner_contract_fingerprint`, `verified_at`, `expires_at`, verifier metadata, and notes.
2. Public claims expire after 90 days and immediately require re-verification when the current fingerprint of their owning command, adapter, dependency, or path-policy object differs from `owner_contract_fingerprint`. The checker derives that fingerprint as SHA-256 over canonical UTF-8 JSON for the local object resolved by `owner_contract_id`; it excludes claim freshness fields and never fetches evidence.
3. Expired evidence makes a claim `stale` or `unverified`, not automatically `unsupported`. Rendered public output omits or downgrades stale claims; it never silently promotes them.
4. Govern README capability/platform tables and the Compatibility, Network, Readiness, enforcement-comparison, and Team Trust documents. Scan other public documentation for unsupported absolute or superiority language without ledgering every sentence.
5. Distinguish platform and surface identities. Gemini CLI evidence does not establish Jules support; Codex CLI evidence does not establish OpenCode support; Copilot VS Code evidence does not establish Copilot Cloud behavior.
6. Classify each operation as `native`, `bash-delegated`, `redirect-only`, `unsupported`, or `optional/degraded`, with explicit dependencies and missing-dependency behavior, including Node/npm and possible package-fetch network access for the existing CI Markdown-lint operation.
7. Correct PowerShell release-ref propagation and fail closed on invalid or unavailable refs. A pin test proves ref binding and artifact selection, not artifact integrity or provenance.
8. Add dependency preflight before the affected operation mutates state. Preflight proves command discovery only, not functional compatibility.
9. Do not implement full native PowerShell parity in DEV-118. Honest Bash-backed behavior is acceptable when declared and tested.
10. Freshness metadata and pointers do not prove authenticity; execution-bound provenance remains DEV-120 scope.

## Rationale

- Time-bounded claims prevent old evidence from remaining “current” indefinitely.
- Per-operation backend truth is more useful than a platform-wide “Full” label.
- Separating surface identities prevents unsupported inheritance across related products.
- Correcting ref propagation and preflight behavior repairs real defects without absorbing a PowerShell rewrite.

## Consequences

### Positive

- Users see support and dependency boundaries before an operation starts.
- Public claims become reviewable, dated, and evidence-linked.
- Windows documentation matches the actual backend path.
- Future adapter changes trigger explicit claim review.

### Negative

- Public claims require periodic maintenance.
- Date-based validation needs a deterministic test clock.
- Some broad marketing language will be removed or downgraded.
- Platform tables become more detailed than one “supported” badge.

## Alternatives Considered

| Option | Rejected because |
| -------- | ------------------ |
| Dates as warnings only | Allows stale public claims to remain active indefinitely. |
| Thirty-day expiry | Creates excessive maintenance before the evidence workflow is proven. |
| No expiry; recheck only on code changes | Misses vendor and environment drift outside this repository. |
| Full native PowerShell rewrite | Exceeds DEV-118 and duplicates work without validated demand. |
| Network-refresh claims in CI | Breaks deterministic local validation and increases the trust boundary. |
