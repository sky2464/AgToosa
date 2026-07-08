# AgToosa Team Trust Roadmap

AgToosa launches first for solo and indie developers. Team/enterprise trust work is planned, but it is not a current guarantee unless explicitly listed as implemented.

## Phase 1: day-one launch

Day-one launch focuses on public developer trust:

- Public repo, releases, raw bootstrap URLs, support links, and registry URLs work anonymously.
- README explains generator prerequisites and target-app runtime boundaries.
- Bash and PowerShell advertised paths have regression coverage.
- `SECURITY.md` names current supported versions and security surfaces.
- Launch readiness can be checked in private and public modes.

## Phase 2: growth push

Before a serious growth push:

- Publish the first 15 minutes proof walkthrough.
- Add a public proof project or case study.
- Keep competitor positioning dated and decision-oriented.
- Improve onboarding around examples, support templates, and contribution paths.
- Track adapter drift with broader checks than simple string greps.

## Phase 3: team/enterprise trust

Team/enterprise adoption needs stronger evidence and controls:

- signed registry index and signed release assets are future high-assurance work.
- High-assurance install mode should verify signed metadata before installing packs.
- docs versioning should define which workflow docs belong to each release line.
- migration guidance should explain breaking workflow changes and how downstream repos update.
- adapter drift automation should compare generated platform behavior, not only file presence.
- No enterprise SLA is promised until support capacity, escalation policy, and response commitments exist.

## Competitive execution wave

DEV-042 through DEV-060 define the Competitive execution wave. **v5.3.0 shipped the proof-engine and supply-chain core** (DEV-042, DEV-043, DEV-044 via DEV-061/067, DEV-060 suite, DEV-061–073). Remaining DEV-045–059 stories are future work unless a linked DEV story is shipped with passing evidence. The wave strengthens AgToosa where alternatives lean on heavier runtimes while preserving the product boundary: repo-native workflow files, machine-checkable proof where shipped, and explicit agent handoffs.

**Shipped in v5.3.0 (examples):**

- Spec quality analyzer (DEV-042) — agent-instructed gate in `/agtoosa-spec`.
- Brownfield spec drift baseline (DEV-043) — agent-instructed current-state step.
- EARS-to-test TDD gate (DEV-044) — machine-checked via `agtoosa-verify.sh` + RED/GREEN evidence blocks.
- Lifecycle verifier + CI gate template (DEV-061/062) — `Docs/agtoosa-verify.sh`, `Docs/agtoosa-gate.yml.example`.
- Phase-event log + spec amend/living specs (DEV-063/072).
- Supply-chain hardening (DEV-064–066) — tar-slip pre-scan, pack containment, pinned installs + `SHA256SUMS`.
- Public benchmark suite scaffold (DEV-060) — `docs/benchmarks/` (competitor runs manual-deferred).

**Shipped agent-instructed:** Async agent handoff packs (DEV-047 `/agtoosa-handoff`) and agent result import gate (DEV-048 `/agtoosa-import`) — wired into canonical workflow docs; agent-instructed, not generator-enforced.

**Still backlog (examples):** work-package DAG schema (DEV-045 partial), worktree isolation (DEV-046), Evidence ledger (DEV-049), cross-model review (DEV-050), tracker sync (DEV-051), hook automation pack (DEV-052), extension catalog (DEV-053), Signed registry provenance (DEV-054 partial), agent capability matrix (DEV-055), retrospective loop (DEV-056), multi-repo overlay (DEV-057), local dashboard (DEV-058), governance policy-as-code (DEV-059). See `docs/Master-Plan.md` → Backlog.

Each story must classify its controls as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap before it can be described as implemented.

## Enforcement Boundary Matrix

| Control | Boundary | Current status |
|---|---|---|
| Template file inventory | generator-enforced | `agtoosa.sh`, `agtoosa.ps1`, and tests control installed file lists. |
| Registry SHA-256 check | generator-enforced | Registry install verifies the downloaded archive hash. |
| Registry path/filetype checks | generator-enforced | Pack files are validated before extraction (member-list scan), after staging, and again at merge time. |
| Registry verified flag | generator-enforced | Unverified packs are blocked unless `--allow-unverified` is passed explicitly. |
| Pack destination denylist | generator-enforced | Packs cannot write `.claude/settings.json`, `.claude/hooks/`, or `.github/workflows/`; preview shows AI-instruction surfaces before consent. |
| Pinned install fail-closed | generator-enforced | `bootstrap.sh --ref vX.Y.Z` aborts when the tag is missing (no branch fallback); brew formula pins a tagged tarball + sha256. |
| Lifecycle verifier | machine-checked (CI-enforceable) | `Docs/agtoosa-verify.sh` validates spec approval, EARS ACs, AC→test mapping, threat model, and TDD evidence; `Docs/agtoosa-gate.yml.example` wires it into PR checks. |
| Bats regression suite | CI-enforced | CI can block regressions when tests are wired into required checks. |
| Release readiness public URL checks | CI-enforced | Intended for public launch mode; private mode skips anonymous URL checks. |
| Release asset checksums | CI-enforced | Release workflow publishes versioned `bootstrap.sh`/`bootstrap.ps1` and a `SHA256SUMS` asset; `bootstrap.sh --sha256` verifies. |
| Async agent handoff packs | agent-instructed | `/agtoosa-handoff` exports a context snapshot, task list, evidence requirements, and return instructions before dispatching to async agents. Not generator-enforced. |
| Agent result import gate | agent-instructed | `/agtoosa-import` validates returned evidence, maps ACs, and gates Tracking updates on repo-local verification. "Imported claims are not evidence until repo-local verification passes." Not generator-enforced. |
| TDD workflow | agent-instructed + machine-warned | `/agtoosa-build` requires RED/GREEN evidence blocks; the verifier warns when they are missing (`--strict` fails). |
| STRIDE threat modeling | agent-instructed + machine-checked | `/agtoosa-spec` instructs threat modeling; the verifier fails active specs without a threat-model section. |
| SBOM, SAST, DAST, observability | agent-instructed | Workflows instruct tool use; project stacks must provide the actual tools. |
| Publishing GitHub repo/tap/registry/npm | manual | The owner must publish external surfaces (including the npm wrapper) before claiming them. |
| Security response timing | manual | Maintainers must choose a support channel and realistic response commitment. |

## Explicit Non-Guarantees

- AgToosa does not currently provide cryptographically signed registry metadata (the index is HTTPS-trusted; pack tarballs are SHA-256 pinned; the verified flag is enforced at install).
- AgToosa publishes release checksums (`SHA256SUMS`) but does not yet provide cryptographic signatures (minisign/cosign) on release assets.
- AgToosa does not enforce enterprise policy at runtime.
- AgToosa does not promise an enterprise SLA.
- AgToosa does not replace a company's CI, legal, compliance, or security review obligations.
