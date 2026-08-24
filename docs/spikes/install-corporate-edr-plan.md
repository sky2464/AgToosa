# Spike: Corporate / EDR-Safe Install Plan

> **Tracking:** [#89](https://github.com/sky2464/AgToosa/issues/89)  
> **Status:** Phase 1 shipped (v5.3.60 via PR #92); Phase 2 (runtime tarball) shipped (v5.3.63 via DEV-150)

## Problem

One-line install commands fail on fresh Windows (EDR blocks in-memory PowerShell) and macOS (`bash <(curl…)` under `sh`, missing git). Corporate users need installs that:

1. Do not trigger EDR remote-execution heuristics
2. Ship only what is needed to run the generator — **not** the full maintainer repository

## Principle

| Audience | Install path |
|----------|--------------|
| End user / corporate | Pinned **release artifacts** (minimal runtime) |
| Maintainer / contributor | `git clone` (full repo for bats, generator, docs) |

**`git clone` is development only.** It ships tests, fixtures, maintainer docs, and CI config that end users do not need.

## Phase 1 — Immediate (docs + safe patterns)

Shipped or in flight via PR #90:

| Item | Notes |
|------|-------|
| Remove `iex` / `[scriptblock]::Create` from README and `bootstrap.ps1` help | File-on-disk PowerShell |
| Pipe-based Bash quick start (`curl … \| bash -s --`) | Avoids process substitution |
| Corporate interim path: release tarball + `SHA256SUMS` + `bootstrap --archive` | Local files only; `github.com/releases` URLs |
| Mark `git clone` as development-only in readme-reference | |
| Troubleshooting for EDR, missing deps, interactive prompt | |

## Phase 2 — Minimal runtime release asset (shipped v5.3.63)

### Problem

GitHub source archive (`AgToosa-vX.Y.Z.tar.gz`) still includes tests, bats, maintainer docs, and fixtures.

### Deliverable

Publish `agtoosa-runtime-vX.Y.Z.tar.gz` on every release:

```
agtoosa.sh
agtoosa.ps1
lib/
template/
```

### Release workflow

- CI packs runtime tarball on tag
- Append digest to `SHA256SUMS`
- Optional `.minisign` sidecar (existing soft-warn path)

### Target corporate UX

```bash
VERSION=v5.3.60
curl -fsSL -o agtoosa-runtime.tar.gz \
  "https://github.com/sky2464/AgToosa/releases/download/${VERSION}/agtoosa-runtime-${VERSION}.tar.gz"
curl -fsSL -o SHA256SUMS \
  "https://github.com/sky2464/AgToosa/releases/download/${VERSION}/SHA256SUMS"
sha256sum -c SHA256SUMS --ignore-missing
tar -xzf agtoosa-runtime.tar.gz -C /opt/agtoosa
/opt/agtoosa/agtoosa.sh --path /path/to/project --platforms cursor --yes
```

No bootstrap required — verify, extract, run.

### Acceptance criteria

- [x] Runtime tarball materially smaller than full source archive — 414K vs ~17.1MB full source (≈41× smaller), measured on v5.3.62 tree
- [x] `SHA256SUMS` lists runtime asset — `release-advanced.yml` appends `agtoosa-runtime-*.tar.gz` digest
- [x] bats: pack contents = exactly `{agtoosa.sh, agtoosa.ps1, lib/, template/}` — RTA-001, RTA-003
- [x] readme-reference corporate section prefers runtime asset over source archive — RTA-005
- [ ] Homebrew formula may switch to runtime URL (optional follow-up) — best-effort, see DEV-150 AC-007

## Phase 3 — Enterprise distribution (demand-gated)

| Item | Trigger |
|------|---------|
| Authenticode-signed scripts | Repeated EDR blocks on file-on-disk path |
| `winget` package | Windows enterprise demand |
| Air-gapped mirror runbook | Customer offline policy |
| Fail-closed minisign | DEV-082 demand gate |

## Install path matrix (target)

| Audience | Path | EDR risk | Payload |
|----------|------|----------|---------|
| Solo dev | `curl … \| bash -s --` or file bootstrap | Low–medium | Ephemeral |
| Corporate | Runtime tarball + SHA256 | **Lowest** | **Minimal** |
| macOS package | `brew install sky2464/agtoosa/agtoosa` | Low | Minimal |
| Maintainer | `git clone` | N/A | Full repo |

## Out of scope

- `git clone` as recommended end-user or corporate path
- Bypassing EDR — all paths are inspectable, local-first, no telemetry
- Shipping maintainer tests/fixtures to production users
