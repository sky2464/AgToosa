# Release Policy

This document defines the AgToosa release process, versioning rules, and quality gates.

## Versioning

AgToosa follows [Semantic Versioning 2.0](https://semver.org/):

| Bump | When |
|------|------|
| **PATCH** (x.y.Z) | Bug fixes, docs corrections, CI-only changes — no behaviour change |
| **MINOR** (x.Y.0) | New features, new platform support, new commands — backward-compatible |
| **MAJOR** (X.0.0) | Breaking changes to the generator CLI, removed commands, renamed template files |

## Release Cadence

| Track | Cadence | Branch |
|-------|---------|--------|
| **Stable** (minor) | Monthly, on the last Monday | `main` |
| **Patch** | On-demand for P0/P1 fixes | `main` |
| **Pre-release** (alpha/beta) | As needed for major features | `main` with `-beta.N` suffix |

## Pre-Release Checklist

Before tagging a release, the maintainer must confirm all of the following:

- [ ] `AGTOOSA_VERSION` in `agtoosa.sh` matches the tag being cut
- [ ] `CHANGELOG.md` has a `## [X.Y.Z]` section with all merged PRs summarised
- [ ] All CI checks pass on `main` (`ci.yml`, `security-scan.yml`, `semantic-lint.yml`)
- [ ] BATS tests pass: `bats tests/agtoosa.bats`
- [ ] Template completeness check passes: `bash agtoosa.sh --list-template-files`
- [ ] At least one platform entry-point file manually verified end-to-end
- [ ] Milestone for the current version is ≥ 90% closed
- [ ] Release workflow has `contents: write` permission for `gh release create`
- [ ] Private staging mode passes: `bash scripts/check-launch-readiness.sh --mode private`
- [ ] Public launch mode passes after publication: `AGTOOSA_LAUNCH_MODE=public bash scripts/check-launch-readiness.sh`

## How to Cut a Release

```bash
# 1. Bump version in agtoosa.sh
#    AGTOOSA_VERSION="X.Y.Z"

# 2. Update CHANGELOG.md — add ## [X.Y.Z] section

# 3. Commit the bump
git add agtoosa.sh CHANGELOG.md
git commit -m "chore: release vX.Y.Z"

# 4. Tag — triggers release-advanced.yml automatically
git tag vX.Y.Z
git push origin main --tags
```

The `release-advanced.yml` workflow then:
1. Validates version consistency between the tag and `agtoosa.sh`
2. Confirms the CHANGELOG entry exists
3. Extracts release notes from CHANGELOG
4. Publishes the GitHub Release
5. Creates the next-version milestone automatically

## Failure recovery

If release publication fails after a tag is pushed:

1. Do not force-push or delete the tag until the failure mode is understood.
2. Check workflow permissions include `contents: write` for GitHub release creation.
3. Re-run the workflow after fixing permissions or release-note extraction.
4. If a partial GitHub Release exists, update it with `gh release edit` instead of creating a duplicate.
5. Re-run `bash scripts/check-launch-readiness.sh --mode private` before attempting public-mode checks.

## Supported Versions

| Version | Status | End of Support |
|---------|--------|---------------|
| `5.2.x` (current) | Active | TBD |
| `< 5.2` | EOL unless explicitly backported | 2026-01-01 |

Only the latest minor release receives patch backports. Older minors are EOL.

## Breaking Changes

- Breaking changes require a MAJOR version bump
- A deprecation notice must appear in the CHANGELOG of the previous minor release before the breaking change lands
- The README and CONTRIBUTING.md must be updated to document the migration path

## Who Can Cut Releases

Only maintainers with push access to `main` may push tags and trigger releases. Collaborators may prepare release PRs but cannot publish.
