# Review: DEV-041 - Public launch publication proof

> **Spec:** `docs/archived/spec-DEV-041.md`
> **Review date:** 2026-06-08
> **Verdict:** PASS

## Summary

DEV-041 publishes and verifies the launch surfaces that were intentionally blocked during private staging: public AgToosa repo, `v5.2.7` release, raw bootstrap files, registry index, Homebrew tap, support/community pages, and first-15-minute proof repo.

## Evidence

| Check | Result |
|-------|--------|
| Public launch checker | PASS: `bash scripts/check-launch-readiness.sh --mode public` |
| Registry | PASS: `registry.json` resolves as a valid JSON array |
| Homebrew tap | PASS: `sky2464/homebrew-agtoosa` resolves publicly |
| Proof project | PASS: `sky2464/agtoosa-first-15-proof` resolves publicly |
| Version parity | PASS: Bash, PowerShell, README, Formula, and bats expect `5.2.7` |
| Release CI | PASS: release workflows are idempotent when a release already exists |
| Security CI | PASS: Dependency-Check no longer receives invalid folded `others` input |

## Findings

| Severity | Persona | Finding | Status |
|----------|---------|---------|--------|
| 🟢 Passed | Security Officer | Public surfaces expose launch artifacts without adding secrets or private credentials. Registry remains HTTPS-trusted with empty public index until packs are published. | Accepted |
| 🟢 Passed | Engineering Manager | Changes are scoped to launch proof, version wiring, docs, checker coverage, and bookkeeping. No core generator behavior changes beyond version pinning. | Accepted |
| 🟢 Passed | CEO / Product Owner | User outcome is met: anonymous evaluators can inspect repo, release, registry, support, tap, and proof project. | Accepted |
| 🟢 Passed | QA Lead | DEV-041 smoke coverage maps to AC-001 through AC-008, and the public checker is the canonical proof gate. | Accepted |
| 🟡 Warning | Engineering Manager | Homebrew formula still uses the public `main` branch source instead of a tagged tarball SHA. This matches existing launch gate scope but should be hardened in a later distribution story. | Accepted; non-blocking for DEV-041 |

## Verdict

Verdict: PASS. No unresolved critical findings.

Suggested release: `v5.2.7` PATCH per ADR-005.
