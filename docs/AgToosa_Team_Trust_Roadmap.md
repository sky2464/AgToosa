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

DEV-042 through DEV-060 define the Competitive execution wave. These are future work unless a linked DEV story is shipped with passing evidence. The wave is meant to strengthen AgToosa where current alternatives are strongest while preserving the current product boundary: repo-native workflow files, proof gates, and explicit agent handoffs rather than a hosted runtime.

Planned capabilities include:

- Spec quality analyzer.
- Brownfield spec drift baseline.
- EARS-to-test TDD gate.
- Work package wave DAG and optional worktree isolation.
- Async agent handoff packs and agent result import gates.
- Evidence ledger.
- Cross-model review gate.
- Tracker sync bridge.
- Hook automation pack.
- Extension and preset catalog.
- Signed registry provenance.
- Agent capability matrix.
- Retrospective learning loop.
- Multi-repo story overlay.
- Local dashboard.
- Governance policy-as-code.
- Public benchmark suite.

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
