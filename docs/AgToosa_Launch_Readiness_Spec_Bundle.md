# AgToosa Launch Readiness Spec Bundle

> Date: 2026-06-07
> Source report: `docs/AgToosa_Strategic_Architecture_Launch_Readiness_Report.md`
> Purpose: turn every launch-readiness finding into implementation-ready specs, then add competitive uplift specs so AgToosa is not merely launchable, but clearly differentiated.

## Executive Spec Goal

AgToosa should launch as the best lightweight, repo-native, multi-assistant SDLC workflow pack for solo and indie developers. It should not claim to beat GitHub Spec Kit on ecosystem size, OpenSpec on brownfield spec modeling, BMAD on agent-role depth, Task Master on task execution, or Spec Kitty on worktree orchestration. It should beat them in its chosen wedge:

- Fast anonymous install from public source.
- No target-app runtime or SDK dependency.
- Bash and PowerShell parity for install/update.
- Cross-assistant workflow adapters with visible parity tests.
- Honest enforcement boundaries: generator-enforced controls versus agent-instructed process.
- Launch discipline: specs, test plans, reviews, ship checks, and support paths installed into the repo.
- Private/offline-friendly operation after install, with optional signed/high-assurance registry mode later.

The specs below use `LRS-*` IDs to avoid colliding with the repo's `DEV-*` story numbering. When implementation begins, promote each spec or logical bundle into the next available `DEV-*` story in `docs/Master-Plan.md`.

## Definition Of Public Launch Ready

AgToosa is public-launch ready only when all of these are true:

1. A developer with no private repository access can follow the README quick start successfully.
2. Public repo, releases, raw bootstrap URLs, registry URL, Homebrew tap if advertised, issues/discussions/support links, badges, and license/security pages return expected statuses.
3. Bash and PowerShell fresh install and update paths preserve user context, update version markers, and keep installed platform adapters current.
4. README claims are narrower than the implementation: no overclaiming "no dependencies," security enforcement, TDD enforcement, SBOM/DAST, or enterprise policy controls.
5. Registry publish/install archive shape is stable, documented, and regression-tested.
6. Security policy names current supported versions, current security surfaces, and a real reporting channel.
7. Competitor positioning is current, dated, and decision-oriented rather than a stale checkmark table.
8. Release CI or release checklist catches public URL drift before announcement.

## Competitive Success Metrics

These are not all required for day-one launch, but they define "better than alternatives" inside AgToosa's wedge:

| Metric | Target |
|---|---|
| First successful install | Under 60 seconds on macOS/Linux with standard tools and no Node/Python runtime requirement for Bash path. |
| Windows confidence | PowerShell install/update parity covered by automated tests and documented honestly. |
| Cognitive overhead | README answers "when to use AgToosa" in under one screen before deep docs. |
| Proof | One public proof project or walkthrough shows spec -> build -> review -> ship artifacts. |
| Trust | Public security policy, release assets, checksum/signing roadmap, and exact enforcement boundary language. |
| Differentiation | Decision guide names where Spec Kit, OpenSpec, BMAD, Task Master, Spec Kitty, and metaswarm are better choices. |

## Implementation Waves

| Wave | Objective | Specs |
|---|---|---|
| Wave 1 | Public launch blockers | LRS-001, LRS-002, LRS-003, LRS-006, LRS-007, LRS-008, LRS-013 |
| Wave 2 | Credibility and docs truth | LRS-004, LRS-005, LRS-009, LRS-010, LRS-011, LRS-012 |
| Wave 3 | Growth positioning | LRS-014, LRS-015 |
| Wave 4 | Team/enterprise credibility | LRS-016 |

## Finding Specs

### LRS-001 - Public Distribution Publication Gate

Maps to finding: P0-1, public distribution is intentionally private and must be published before launch.

#### Goal

Make the public distribution surface real before launch, or make the README explicitly private-staging only. The public state must match the install/support claims.

#### Scope

- `README.md` badges, install URLs, release links, discussion links, registry references.
- GitHub repo visibility and repository settings.
- Release page and tagged release assets.
- Raw bootstrap URLs for `main` and current pinned tag.
- `sky2464/agtoosa-registry` or replacement registry location.
- `sky2464/homebrew-agtoosa` or replacement tap location if Homebrew remains advertised.
- `.github/SUPPORT.md`, `.github/DISCUSSIONS.md`, issue templates, and security advisory path.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-001-AC1 | Anonymous `curl -I` or GitHub API checks for repo, releases, raw bootstrap, registry, tap if advertised, support, issues, discussions, and license return expected public statuses. |
| LRS-001-AC2 | README install commands point only to public URLs, or the README is explicitly marked private-staging and not ready for public use. |
| LRS-001-AC3 | Release notes include a publication checklist with each public surface checked after publication. |
| LRS-001-AC4 | A release-readiness script or documented command records the public URL check evidence. |

#### Validation

```bash
curl -I https://github.com/sky2464/AgToosa
curl -I https://github.com/sky2464/AgToosa/releases
curl -I https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh
curl -I https://raw.githubusercontent.com/sky2464/AgToosa/vX.Y.Z/bootstrap.sh
curl -I https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json
```

Run equivalent checks for support, issues, discussions, badges, and Homebrew if advertised.

#### Competitive Outcome

AgToosa stops losing trust at the first click. This is table stakes against Spec Kit, OpenSpec, BMAD, Task Master, and Spec Kitty, all of which have visible public install paths.

---

### LRS-002 - Public Quickstart Install

Maps to finding: P0-2, README primary install commands remain private-only until publication.

#### Goal

Ensure the README quickstart works for a first-time public developer without private repo access and without extra explanation.

#### Scope

- README quickstart install commands.
- `bootstrap.sh` and `bootstrap.ps1` public download paths.
- Pinned release install examples.
- Private-staging install note, if repo remains private before launch.
- Fresh install smoke on macOS/Linux and Windows PowerShell.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-002-AC1 | The first README install command succeeds from a clean temp directory on a machine without GitHub auth. |
| LRS-002-AC2 | A pinned-release install command succeeds and is listed before any `main` branch command. |
| LRS-002-AC3 | `main` install is labeled unstable or development-only. |
| LRS-002-AC4 | The quickstart ends with a concrete verification command such as `bash agtoosa.sh --version` or generated file presence checks. |
| LRS-002-AC5 | PowerShell quickstart either works natively or states the exact Windows support boundary. |

#### Validation

```bash
tmpdir="$(mktemp -d)"
cd "$tmpdir"
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/vX.Y.Z/bootstrap.sh | bash
bash agtoosa.sh --version
```

```powershell
$tmp = New-Item -ItemType Directory -Force ([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid()))
Set-Location $tmp.FullName
iwr -UseBasicParsing https://raw.githubusercontent.com/sky2464/AgToosa/vX.Y.Z/bootstrap.ps1 | iex
.\agtoosa.ps1 -Version
```

#### Competitive Outcome

The first-run experience becomes simpler than Node/Python-heavy alternatives for developers who only want local workflow files.

---

### LRS-003 - PowerShell Update Parity

Maps to finding: P1-1, PowerShell `-Update` reports success but does not update platform files or version marker.

#### Goal

Make PowerShell update behavior equivalent to Bash update behavior for installed platform detection, staged file copying, smart merge, context preservation, and version marker writes.

#### Scope

- `agtoosa.ps1` update path.
- Installed platform detection for `Docs/`, `CLAUDE.md`, `.claude/`, `.cursor/`, `.gemini/`, `.github/`, `.windsurf/`, `.codex/`, `OPENCODE.md`, and other supported adapters.
- Version marker update: `Docs/.agtoosa-version`.
- Tests for old content preservation and new block insertion.
- CI PowerShell smoke coverage.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-003-AC1 | `agtoosa.ps1 -Update -UpdatePath <project>` detects currently installed platform adapters instead of passing an empty platform list. |
| LRS-003-AC2 | Existing user content in platform context files is preserved. |
| LRS-003-AC3 | AgToosa-managed blocks are replaced or appended according to the same merge contract as Bash. |
| LRS-003-AC4 | `Docs/.agtoosa-version` is updated to the current PowerShell generator version after successful update. |
| LRS-003-AC5 | A regression test proves an old `CLAUDE.md`, old `.claude/commands/agtoosa-spec.md`, and old version marker are updated. |
| LRS-003-AC6 | Windows CI fails when `-Update` silently succeeds without updating files. |

#### Validation

```powershell
pwsh -NoProfile -File ./agtoosa.ps1 -Update -UpdatePath <temp-project>
Get-Content <temp-project>/Docs/.agtoosa-version
Select-String -Path <temp-project>/CLAUDE.md -Pattern "AgToosa"
Select-String -Path <temp-project>/.claude/commands/agtoosa-spec.md -Pattern "AgToosa"
```

Add a focused Bats or CI slice equivalent to:

```bash
bats tests/agtoosa.bats -f "PowerShell update"
```

#### Competitive Outcome

AgToosa can credibly claim cross-platform support. Without this, Windows support is weaker than competitors with package-manager-based installs.

---

### LRS-004 - Truthful Dependency And Runtime Claims

Maps to finding: P1-2, README overclaims "No dependencies."

#### Goal

Make dependency claims precise: no target-app SDK/runtime, but the generator uses standard CLI tools and optional registry tools.

#### Scope

- README headline and requirements section.
- Comparison table language.
- Bootstrap docs.
- Generated project docs if they repeat the claim.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-004-AC1 | README does not say "No dependencies" without qualification. |
| LRS-004-AC2 | README states the generator requirements: Bash or PowerShell, Git, curl or web request support, tar where needed, and jq for registry commands if still required. |
| LRS-004-AC3 | README separately states the target app does not need an AgToosa SDK or runtime. |
| LRS-004-AC4 | Any "local-first" or "offline" claim names the point after which it is true. |
| LRS-004-AC5 | Tests or grep checks prevent reintroducing the unqualified claim. |

#### Validation

```bash
rg -n "No dependencies|No SDK|runtime|jq|curl|tar|PowerShell|Bash" README.md template docs
```

#### Competitive Outcome

Truthful dependency framing makes AgToosa more credible than hype-driven alternatives and protects trust with senior developers.

---

### LRS-005 - Current Competitive Decision Guide

Maps to finding: P1-3, README competitor table is stale and strategically unsafe.

#### Goal

Replace stale checkmark marketing with a dated, honest decision guide that shows where AgToosa wins and where other tools are better.

#### Scope

- README competitor section.
- Source appendix or dated comparison notes.
- Positioning for GitHub Spec Kit, OpenSpec, BMAD, Task Master, Spec Kitty, and metaswarm.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-005-AC1 | README removes or rewrites the old "AgToosa v2" comparison table. |
| LRS-005-AC2 | README includes "Use AgToosa when" and "Use another tool when" guidance. |
| LRS-005-AC3 | Competitor claims are dated and limited to verifiable public docs or repo metadata. |
| LRS-005-AC4 | AgToosa's wedge is stated as lightweight, repo-native, multi-assistant SDLC workflow installation. |
| LRS-005-AC5 | The comparison explicitly concedes competitor strengths: Spec Kit ecosystem, OpenSpec brownfield current/delta model, BMAD role ecosystem, Task Master task execution/MCP, Spec Kitty worktree orchestration. |

#### Validation

```bash
rg -n "AgToosa v2|Spec-Kit|OpenSpec|BMAD|Task Master|Spec Kitty|metaswarm|Use AgToosa" README.md
```

#### Competitive Outcome

AgToosa becomes easier to trust because it helps developers choose correctly, even when the right choice is a competitor.

---

### LRS-006 - Registry Publish/Install Archive Contract

Maps to finding: P1-4, registry publish/install layout mismatch.

#### Goal

Define and enforce one canonical pack archive shape so packs created by `registry publish` install into the same layout expected by `registry install`.

#### Scope

- `lib/registry.sh` publish tarball creation.
- `lib/registry.sh` install extraction.
- `agtoosa.ps1` registry install behavior if it consumes the same archive shape.
- Registry docs and example pack.
- Bats publish-to-install regression.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-006-AC1 | A canonical pack archive shape is documented: either root files in tarball or exactly one top-level pack directory. |
| LRS-006-AC2 | `registry_publish` creates only the canonical shape. |
| LRS-006-AC3 | `registry_install` accepts the canonical shape and rejects or normalizes noncanonical nested layouts. |
| LRS-006-AC4 | Bash and PowerShell registry install produce the same `.agtoosa/pack-queue/<pack>/...` layout. |
| LRS-006-AC5 | A regression test publishes a pack using the real publish path, then installs it and asserts no duplicate nested `<pack>/<pack>/` directory. |
| LRS-006-AC6 | Path traversal, disallowed file type, and SHA-256 checks remain green. |

#### Validation

```bash
bats tests/agtoosa.bats -f "registry"
find <temp-project>/.agtoosa/pack-queue -maxdepth 3 -type f | sort
```

#### Competitive Outcome

The registry becomes predictable enough to support community packs, a required capability if AgToosa wants ecosystem value without a heavy runtime.

---

### LRS-007 - Security Policy And Trust Model Refresh

Maps to finding: P1-5, security policy is stale and references deprecated surfaces.

#### Goal

Make the security posture current, accurate, and credible for a public developer launch.

#### Scope

- `SECURITY.md`.
- README security/trust language.
- Registry trust model docs.
- GitHub security advisory settings or contact channel.
- Supported versions policy.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-007-AC1 | `SECURITY.md` supports the current release line and does not reference `2.x` as the only supported version. |
| LRS-007-AC2 | `SECURITY.md` names current security surfaces: `agtoosa.sh`, `agtoosa.ps1`, `bootstrap.sh`, `bootstrap.ps1`, `lib/registry.sh`, release assets, and template instructions. |
| LRS-007-AC3 | Deprecated `install.sh` is removed from active security scope or clearly labeled deprecated. |
| LRS-007-AC4 | Reporting channel is verified: GitHub private advisories, a working email, or both. |
| LRS-007-AC5 | README distinguishes registry SHA/path checks from stronger guarantees not yet implemented, such as signed registry index or signed releases. |
| LRS-007-AC6 | A future high-assurance mode is tracked separately rather than overclaimed. |

#### Validation

```bash
rg -n "2\\.x|install\\.sh|security@|advisory|registry|signed|SHA" SECURITY.md README.md docs
```

#### Competitive Outcome

Security-conscious developers can evaluate AgToosa honestly. This is especially important because AgToosa installs instructions into repos used by AI agents.

---

### LRS-008 - Homebrew Distribution Hardening

Maps to finding: P1-6, Homebrew path is not launch-ready.

#### Goal

Either make Homebrew a real, verified distribution path or remove it from primary install docs until it is real.

#### Scope

- `Formula/agtoosa.rb`.
- README Homebrew install section.
- Public tap repository.
- Tagged source archive and SHA-256.
- Release checklist or CI verification.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-008-AC1 | If README advertises Homebrew, `brew install sky2464/agtoosa/agtoosa` works from a clean machine or CI image. |
| LRS-008-AC2 | Formula uses a tagged release archive or stable release asset, not an unpublished/private branch source. |
| LRS-008-AC3 | Formula has a real SHA-256 for the public source. |
| LRS-008-AC4 | README marks Homebrew as unavailable/private-staging if the tap is not public. |
| LRS-008-AC5 | Release checklist includes Homebrew verification. |

#### Validation

```bash
brew untap sky2464/agtoosa || true
brew install sky2464/agtoosa/agtoosa
agtoosa --version || bash agtoosa.sh --version
```

#### Competitive Outcome

Homebrew gives AgToosa a low-friction install path that can compete with `uvx`, `npx`, `pipx`, and npm global installs.

---

### LRS-009 - Conservative macOS Bootstrap Guidance

Maps to finding: P2-1, bootstrap macOS guidance is not credible.

#### Goal

Remove fragile platform-version claims from bootstrap messaging and replace them with conservative, verifiable guidance.

#### Scope

- `bootstrap.sh` platform messages.
- README macOS prerequisites.
- Any generated docs that repeat macOS Bash assumptions.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-009-AC1 | `bootstrap.sh` no longer claims "macOS 26+ ships with bash 5.2+". |
| LRS-009-AC2 | macOS guidance states only verified prerequisites: command line tools, Git, curl, tar, and newer Bash if required. |
| LRS-009-AC3 | Message explains what to do when Bash is too old. |
| LRS-009-AC4 | Bootstrap still exits clearly when required tools are missing. |

#### Validation

```bash
rg -n "macOS 26|bash 5\\.2|Homebrew|command line tools" bootstrap.sh README.md docs
bash bootstrap.sh --help || true
```

#### Competitive Outcome

Small credibility fixes matter. This prevents an avoidable trust loss during install.

---

### LRS-010 - PowerShell Registry Publish Contract

Maps to finding: P2-2, PowerShell docs are internally inconsistent around registry publish.

#### Goal

Make PowerShell registry command support explicit and consistent across parameter comments, help text, README, and behavior.

#### Scope

- `agtoosa.ps1` parameter comments.
- `agtoosa.ps1` `Show-Usage`.
- README Windows registry section.
- Tests or grep checks.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-010-AC1 | PowerShell help, parameter comments, and README list the same supported registry commands. |
| LRS-010-AC2 | If `publish` is not supported natively, `agtoosa.ps1 --registry publish` fails with a clear message that names Bash, WSL, or Git Bash alternatives. |
| LRS-010-AC3 | If `publish` is implemented natively, it produces the same canonical archive shape as Bash. |
| LRS-010-AC4 | A focused test prevents help/comment drift. |

#### Validation

```powershell
pwsh -NoProfile -Command "./agtoosa.ps1 -Help"
pwsh -NoProfile -Command "./agtoosa.ps1 -Registry publish"
```

```bash
rg -n "publish|RegistryCommand|registry list|registry search|registry info|registry install" agtoosa.ps1 README.md tests/agtoosa.bats
```

#### Competitive Outcome

Clear Windows boundaries are better than vague parity claims. Developers can plan around known limits.

---

### LRS-011 - Release Workflow Modernization

Maps to finding: P2-3, release workflows retain deprecated `actions/create-release@v1`.

#### Goal

Modernize release automation so public releases are repeatable, maintained, and less likely to break during launch.

#### Scope

- `.github/workflows/release.yml`.
- `.github/workflows/release-advanced.yml`.
- Release docs/checklists.
- GitHub CLI fallback if preferred.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-011-AC1 | Deprecated `actions/create-release@v1` is removed from release workflows. |
| LRS-011-AC2 | Release creation uses `gh release create` or a maintained action. |
| LRS-011-AC3 | Release workflow attaches or references bootstrap scripts, source archive, checksums, and release notes as appropriate. |
| LRS-011-AC4 | Dry-run or non-publishing validation path exists for private staging. |
| LRS-011-AC5 | Release docs explain required permissions and failure recovery. |

#### Validation

```bash
rg -n "actions/create-release|gh release|softprops|release" .github/workflows docs README.md
```

Run workflow syntax validation if available.

#### Competitive Outcome

Launch reliability improves. Maintained release automation is a prerequisite for trust in install-by-curl products.

---

### LRS-012 - Public Support And Community Surface

Maps to finding: P2-4, support/community artifacts depend on publication.

#### Goal

Make public support, discussions, issue intake, and security reporting coherent on launch day.

#### Scope

- `.github/SUPPORT.md`.
- `.github/DISCUSSIONS.md`.
- Issue templates.
- README support/community links.
- GitHub Discussions settings.
- Security advisory settings.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-012-AC1 | README support links all resolve publicly after publication. |
| LRS-012-AC2 | Issues and discussions are enabled or README states the chosen support path. |
| LRS-012-AC3 | Bug report template asks for OS, shell, install command, AgToosa version, and target project context. |
| LRS-012-AC4 | Feature request template asks whether the request affects generator, template, platform adapter, registry, or docs. |
| LRS-012-AC5 | Security reports are routed outside public issues. |

#### Validation

```bash
rg -n "issues|discussions|support|security|advisory" README.md .github docs
```

Then run public URL checks after repo publication.

#### Competitive Outcome

Community proof starts with a visible, low-friction feedback loop. Without it, AgToosa looks abandoned even if local code is strong.

---

### LRS-013 - Launch Readiness Regression Gate

Maps to finding: P2-5, test coverage misses launch-critical classes.

#### Goal

Add an explicit launch-readiness validation layer that catches public URL drift, stale docs/security claims, PowerShell update drift, and registry archive-shape drift.

#### Scope

- `tests/agtoosa.bats` or a separate release-readiness script.
- CI workflow integration, likely release-only or manually triggered while repo is private.
- README/release checklist.
- Public URL checks parameterized for private staging versus public launch.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-013-AC1 | A release-readiness command checks public URLs only when launch mode is enabled, so private staging can still run local tests. |
| LRS-013-AC2 | The command checks repo, releases, raw bootstrap, registry JSON, Homebrew tap if advertised, discussions/issues/support, badges, and security policy. |
| LRS-013-AC3 | The command checks PowerShell update parity or invokes the focused PowerShell update test. |
| LRS-013-AC4 | The command checks registry publish/install archive-shape compatibility. |
| LRS-013-AC5 | The command fails on stale `SECURITY.md` supported-version claims. |
| LRS-013-AC6 | The release checklist requires recording the launch-readiness command output before announcement. |

#### Validation

```bash
bats tests/agtoosa.bats -f "launch readiness"
AGTOOSA_LAUNCH_PUBLIC=1 ./scripts/check-launch-readiness.sh
```

Use the exact command name chosen during implementation.

#### Competitive Outcome

AgToosa's launch process becomes evidence-driven. This is a practical advantage over prompt-pack projects that rely on manual README checks.

---

## Competitive Uplift Specs

### LRS-014 - First 15 Minutes Proof Walkthrough

#### Goal

Show a developer exactly what AgToosa does in a real repo during the first 15 minutes: install, initialize, spec, build, review, and ship artifacts.

#### Scope

- README quick demo.
- `docs/examples/first-15-minutes.md` or equivalent.
- A tiny proof project or fixture repo.
- Screenshots optional; text commands are enough for launch.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-014-AC1 | Walkthrough starts from a clean repo and ends with visible AgToosa artifacts. |
| LRS-014-AC2 | It shows at least one spec, one test-plan mapping, one review, and one ship-check artifact. |
| LRS-014-AC3 | It names what the generator created versus what the AI agent was instructed to do. |
| LRS-014-AC4 | It includes a cleanup/reset note so developers can try safely. |
| LRS-014-AC5 | README links to the walkthrough in the first screen or quickstart section. |

#### Validation

Run the walkthrough commands in a temp repo and confirm all referenced artifacts exist.

#### Competitive Outcome

AgToosa becomes easier to understand than larger frameworks. The proof is concrete, not theoretical.

---

### LRS-015 - Wedge Positioning And Use-Case Examples

#### Goal

Make AgToosa's target user and non-target user obvious, reducing wrong-fit adoption and increasing trust among right-fit developers.

#### Scope

- README positioning.
- Docs landing page or `docs/AgToosa_Readiness.md`.
- Example use cases for solo app developer, small team, private/offline repo, and multi-assistant workflow.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-015-AC1 | README says AgToosa is best for solo/indie developers and small teams using multiple AI coding tools. |
| LRS-015-AC2 | README says AgToosa is not the best fit for teams already standardized on Spec Kit/OpenSpec/BMAD/Task Master or teams needing enforceable runtime policy. |
| LRS-015-AC3 | At least three concrete use-case examples show when AgToosa helps. |
| LRS-015-AC4 | At least three counterexamples show when not to use it. |
| LRS-015-AC5 | Positioning avoids claiming universal superiority. |

#### Validation

```bash
rg -n "Use AgToosa when|Do not use AgToosa when|solo|indie|Spec Kit|OpenSpec|BMAD|Task Master" README.md docs
```

#### Competitive Outcome

The product becomes more defensible because it chooses a market instead of pretending to be everything.

---

### LRS-016 - Team And Enterprise Trust Roadmap

#### Goal

Define the later trust features needed for regulated or team adoption without blocking the solo-developer launch.

#### Scope

- Signed registry index plan.
- Optional high-assurance install mode.
- Docs versioning and migration policy.
- Adapter drift automation.
- Support/security SLA language.
- Enforcement boundary matrix.

#### Acceptance Criteria

| ID | Requirement |
|---|---|
| LRS-016-AC1 | A roadmap doc separates day-one launch, growth, and team/enterprise requirements. |
| LRS-016-AC2 | Signed registry index and signed release assets are tracked as future high-assurance work unless implemented now. |
| LRS-016-AC3 | Docs versioning and migration guidance are defined for breaking workflow changes. |
| LRS-016-AC4 | Adapter drift automation is specified beyond grep-only parity. |
| LRS-016-AC5 | A matrix states which controls are generator-enforced, CI-enforced, agent-instructed, or manual. |
| LRS-016-AC6 | Support/security response expectations are explicit and do not overpromise enterprise SLA before the project can support one. |

#### Validation

```bash
rg -n "signed registry|high-assurance|docs versioning|migration|adapter drift|generator-enforced|agent-instructed|SLA" docs README.md
```

#### Competitive Outcome

AgToosa can credibly speak to teams later without diluting the public launch. It becomes honest and extensible instead of overbuilt.

## Cross-Spec Test Matrix

| Area | Required Evidence Before Public Launch |
|---|---|
| Local Bash | `bash agtoosa.sh --version`, `--help`, fresh install, update, registry list/search/info/install. |
| Local PowerShell | `.\agtoosa.ps1 -Version`, `-Help`, fresh install, update, registry list/search/info/install. |
| Static shell quality | `shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 agtoosa.sh bootstrap.sh lib/*.sh`. |
| Full regression | `bats tests/agtoosa.bats`. |
| Launch URLs | Public URL checker in public mode after repo publication. |
| Docs truth | Grep checks for stale dependency, version, security, competitor, and private-staging language. |
| Registry | Publish-to-install E2E test plus SHA/path/filetype negative tests. |
| Release | Workflow syntax plus dry-run or release checklist evidence. |

## Recommended Story Split

Do not ship this as one large implementation story. Split it into these implementation stories:

1. `DEV-035 - Launch P0 publication and quickstart gate`: LRS-001, LRS-002, LRS-012 public link subset.
2. `DEV-036 - Windows and registry parity`: LRS-003, LRS-006, LRS-010.
3. `DEV-037 - Truthful launch docs`: LRS-004, LRS-005, LRS-007, LRS-009, LRS-015.
4. `DEV-038 - Distribution hardening`: LRS-008, LRS-011, LRS-013.
5. `DEV-039 - Proof and growth`: LRS-014.
6. `DEV-040 - Team trust roadmap`: LRS-016.

If capacity is constrained, ship stories 1-4 before public launch. Stories 5-6 can follow immediately after launch, but story 5 should be completed before any serious growth push.

## Non-Goals

- Building a hosted service.
- Replacing GitHub Spec Kit, OpenSpec, BMAD, Task Master, Spec Kitty, or metaswarm in their strongest categories.
- Claiming enforceable enterprise policy before signed registry, release signing, docs versioning, and explicit enforcement boundaries exist.
- Adding a Node, Python, or MCP runtime to AgToosa's core launch path.

## Spec Self-Review

- Placeholder scan: no unfinished placeholder markers are intentionally left.
- Internal consistency: public-private staging is treated as expected now and blocking only for public launch.
- Scope check: the bundle is intentionally larger than one implementation story; the recommended story split prevents a single oversized build cycle.
- Ambiguity check: each finding has scope, acceptance criteria, validation evidence, and competitive outcome.
