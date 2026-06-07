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

## Enforcement Boundary Matrix

| Control | Boundary | Current status |
|---|---|---|
| Template file inventory | generator-enforced | `agtoosa.sh`, `agtoosa.ps1`, and tests control installed file lists. |
| Registry SHA-256 check | generator-enforced | Registry install verifies the downloaded archive hash. |
| Registry path/filetype checks | generator-enforced | Pack files are validated before staging. |
| Bats regression suite | CI-enforced | CI can block regressions when tests are wired into required checks. |
| Release readiness public URL checks | CI-enforced | Intended for public launch mode; private mode skips anonymous URL checks. |
| TDD workflow | agent-instructed | `/agtoosa-build` instructs red/green/refactor, but the generator does not execute tests automatically. |
| STRIDE threat modeling | agent-instructed | `/agtoosa-spec` instructs threat modeling where applicable. |
| SBOM, SAST, DAST, observability | agent-instructed | Workflows instruct tool use; project stacks must provide the actual tools. |
| Publishing GitHub repo/tap/registry | manual | The owner must publish external surfaces before launch. |
| Security response timing | manual | Maintainers must choose a support channel and realistic response commitment. |

## Explicit Non-Guarantees

- AgToosa does not currently provide signed registry metadata.
- AgToosa does not currently provide signed release assets.
- AgToosa does not enforce enterprise policy at runtime.
- AgToosa does not promise an enterprise SLA.
- AgToosa does not replace a company's CI, legal, compliance, or security review obligations.
