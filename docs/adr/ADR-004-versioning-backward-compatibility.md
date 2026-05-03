# ADR-004: Versioning and Backward Compatibility

**Status:** Accepted  
**Date:** 2026-05-01  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa is installed into user projects via `bash agtoosa.sh` and updated via `bash agtoosa.sh --update`. Once installed, the generated files (platform entry-points, workflow docs, hooks, slash commands) live in the user's repo. Users may edit these files. Future AgToosa versions may rename, restructure, or remove workflows.

The versioning strategy must:
- Allow in-place updates that preserve user edits outside AgToosa-owned blocks
- Communicate breaking changes clearly so users can migrate without surprising behavior
- Keep shell and PowerShell versions in sync
- Enable reproducible project setups when community packs are involved
- Avoid silent upgrades that change AI behavior without user awareness

Current state (v3.0.0): bash is at `3.0.0`, PowerShell is at `2.6.0` (out of sync). No `agtoosa-lock.json` exists. Breaking changes in v2.7.0 (command renames) were logged in `CHANGELOG.md` but had no automated migration path.

---

## Decision

**Use semantic versioning with HTML-comment markers for merge-safe in-place updates, explicit breaking change documentation in `CHANGELOG.md`, and a planned `agtoosa-lock.json` for pack reproducibility.**

Version markers (`<!-- AgToosa vX.Y.Z START/END -->`) delineate AgToosa-owned content in platform files. The `--update` flow replaces only the marked block, leaving user content outside markers intact. Breaking changes are always logged and, starting in v3.1, trigger a migration wizard that surfaces renames and removals interactively.

---

## Semver Interpretation for AgToosa

| Change type | Version bump | Examples |
|------------|-------------|---------|
| **MAJOR** | Breaking change to installed project structure | Removing a workflow phase, changing `Master-Plan.md` schema, dropping a platform |
| **MINOR** | New workflow, new platform, new registry commands | Adding v3 registry commands, Windows support |
| **PATCH** | Bug fixes, clarification in workflow docs, prompt tuning | Fixing a typo in `AgToosa_Build.md`, adjusting hook thresholds |

**Backward compatibility guarantee:** A `--update` from any patch or minor version to the next should be non-destructive for user-edited content outside markers. MAJOR version bumps may require manual migration steps, which are documented in `CHANGELOG.md` under `### Breaking`.

---

## Options Considered

### Option A: Marker-Based Merge + Explicit CHANGELOG (current)

Version markers delineate ownership. The `--update` flow uses regex to find and replace only the marked block. User edits outside markers are preserved. Breaking changes are listed explicitly in `CHANGELOG.md`. No automated migration tooling yet.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low — regex-based block replacement |
| User edit preservation | ✅ Markers make ownership explicit |
| Breaking change communication | ⚠️ Manual CHANGELOG; no in-run warning |
| Reproducibility | ❌ No lock file yet |
| Cross-script sync | ❌ PowerShell at v2.6.0, bash at v3.0.0 |

**Pros:**
- Simple implementation — pure bash string operations
- Markers are human-readable; users can see what AgToosa owns
- Works on all 6 platforms (HTML comments are universally inert)

**Cons:**
- No automated migration for breaking changes (renames, removals)
- PowerShell version is out of sync — cross-platform users get inconsistent behavior
- No lock file — pack versions not pinned per project
- `CHANGELOG.md` is manually maintained — risk of drift

### Option B: Versioned Schema Files + Migration Scripts

Each major version has a migration script (`migrations/v2-to-v3.sh`) that runs automatically during `--update` when the installed version is detected as older than the current MAJOR.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Medium — migration scripts + version detection |
| User edit preservation | ✅ Migration scripts handle conflict cases |
| Breaking change communication | ✅ Automated — migration runs interactively |
| Reproducibility | ❌ Still no lock file |
| Cross-script sync | Can enforce sync in migration |

**Pros:**
- Breaking changes handled automatically
- Interactive migration wizard can surface renames and prompt the user
- Version detection (`extract_version`) already exists

**Cons:**
- Migration scripts accumulate over time and become maintenance burden
- Scripts must be tested across all platform combinations
- Still doesn't solve pack reproducibility

### Option C: Immutable Installs + Explicit Re-Install

No in-place updates. Users run `--install` fresh, which generates a new `ship/` dir and presents a diff before applying. Old files are archived, not overwritten.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low — no merge logic |
| User edit preservation | ❌ User edits must be manually re-applied |
| Breaking change communication | N/A — always starts fresh |
| Reproducibility | ✅ Each install is deterministic |

**Pros:**
- No merge complexity
- Every install is reproducible from the same AgToosa version + config inputs

**Cons:**
- Users lose edits on every update — unacceptable for active projects
- Forces users to track their own customizations externally

---

## Trade-off Analysis

Option A is the right foundation. The marker-based merge is working correctly and preserving user edits. The gaps are in **migration tooling** (Option B's interactive wizard is worth adding as a v3.1 enhancement) and **pack reproducibility** (lock file, v3.1).

The PowerShell version drift is the most urgent concrete risk: users on Windows may be running a v2.6.0 behavior while bash users are on v3.0.0. The two must be brought to version parity on the next minor release.

Option C is unsuitable for active projects but may be appropriate as an optional `--reinstall --clean` flag for users who want a fresh state.

---

## Deprecation Policy (Proposed, v3.1+)

Before a breaking change ships:

1. **One minor release notice:** The old command/behavior continues to work but emits a deprecation warning during execution.
2. **Migration guide in CHANGELOG.md** under `### Deprecated` (not `### Breaking`) in the notice release.
3. **Breaking change in next minor or major:** Old behavior removed. `CHANGELOG.md` entry moves to `### Breaking`.

**Example for v2.7.0 renames (retroactive lesson):**
- Should have shipped `/agtoosa-caveman` deprecation warning in v2.6.x
- v2.7.0 should have removed it with migration note
- Interactive `--update` wizard (v3.1) would have surfaced: _"Command `/agtoosa-caveman` was renamed to `/agtoosa-concise`. Your `.claude/commands/agtoosa-caveman.md` has been updated."_

---

## Lock File Design (`agtoosa-lock.json`, v3.1)

```json
{
  "agtoosa_version": "3.1.0",
  "installed_at": "2026-05-01T12:00:00Z",
  "platforms": ["claude", "cursor", "gemini"],
  "packs": [
    {
      "name": "ml-pipeline",
      "version": "1.2.0",
      "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "installed_at": "2026-05-01T12:00:00Z"
    }
  ]
}
```

- Written to `Docs/agtoosa-lock.json` on install and `--update`
- Committed to the project repo for reproducibility
- `--update` reads the lock file to know which packs were previously installed and re-validates their SHA-256

---

## Consequences

**Easier:**
- In-place updates that preserve user edits (marker system)
- Auditing what version AgToosa is at in any project (`extract_version`)
- Rolling back to a previous AgToosa version (reinstall from pinned release tag)

**Harder:**
- Communicating breaking changes without an automated migration wizard
- Keeping bash and PowerShell versions in sync (currently out of sync)
- Guaranteeing reproducible project setups without a lock file (v3.1 gap)
- Testing `--update` behavior across all platform combinations and version distances

**Will need to revisit:**
- Interactive migration wizard for breaking changes (v3.1)
- `agtoosa-lock.json` for pack reproducibility (v3.1)
- PowerShell version parity with bash (urgent — next release)
- Automated `CHANGELOG.md` generation from git commits (reduce drift risk)
- `--reinstall --clean` flag for fully deterministic fresh installs
- Deprecation period policy: formalize as 1-minor-release notice before breaking removal

---

## Action Items

1. [x] Ship marker-based merge (`lib/version.sh`, `lib/copy.sh`) (v3.0.0)
2. [x] Ship `--update` mode with deep-merge for `settings.json` (v3.0.0)
3. [ ] **URGENT:** Bring PowerShell (`agtoosa.ps1`) to v3.0.0 parity with bash
4. [ ] Implement `agtoosa-lock.json` — written on install/update, committed to project repo (v3.1)
5. [ ] Build interactive migration wizard — runs on `--update` when MAJOR version delta detected (v3.1)
6. [ ] Formalize deprecation policy in `CONTRIBUTING.md` (1-release notice before breaking removal)
7. [ ] Add CI check: assert `AGTOOSA_VERSION` is identical in `agtoosa.sh` and `agtoosa.ps1`
8. [ ] Investigate automated CHANGELOG generation from conventional commits
