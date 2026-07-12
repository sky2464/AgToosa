# DEV-081 Spike: Optional Local DX Add-on Validation

> **Story:** DEV-081 · Epic DEV-001 · Spike M  
> **Spec:** `docs/archived/spec-DEV-081.md`  
> **Test plan:** `docs/AgToosa_TestPlan-DEV-081.md`  
> **Status:** Spike evidence only — **no production implementation**, **not shipped**  
> **Reviewer:** AgToosa maintainer agent (human review pending)  
> **Evidence date:** 2026-07-11

## Claim boundary

| Classification | Meaning in this document |
|----------------|--------------------------|
| **Observed** | Reproducible measurement or file inspection in the recorded environment |
| **Assumption** | Reasonable inference not directly measured in this spike |
| **Untested** | Condition explicitly not exercised during evidence collection |

Nothing in this spike creates product capability. Optional add-ons remain roadmap candidates until a separately approved implementation story ships verified artifacts.

**Spike scope:** research and decision artifacts under `docs/spikes/` only. **No changes to** `agtoosa.sh`, `lib/`, `template/`, `npm/`, or CI workflow files were made as part of DEV-081.

---

## 1. Shared baseline journey

### 1.1 Baseline (no add-on)

A new local user on macOS with Cursor installed adopts AgToosa without any optional add-on:

1. Discover install paths from README: `bootstrap.sh`, git clone + `agtoosa.sh`, or `npx agtoosa`.
2. Run a non-interactive install: `bash agtoosa.sh --path . --platforms cursor --yes` (or npm equivalent).
3. Invoke workflow commands via Cursor native picker (`/agtoosa-help`, `/agtoosa-spec`, …) backed by `.cursor/commands/agtoosa-*.md`.
4. Run local verification: `bash Docs/agtoosa-verify.sh` (generated project) or `bash docs/agtoosa-verify.sh` (maintainer dogfood).
5. Optionally copy `Docs/agtoosa-gate.yml.example` to `.github/workflows/` for GitHub Actions CI gating.

This path is **complete without** a separate native binary, marketplace extension, or additional CI templates.

### 1.2 Representative environments

| Environment | Role | Availability | Limitation |
|-------------|------|--------------|------------|
| **Cursor on macOS** (darwin 25.5.0) | Editor extension evaluation | Available — maintainer workstation | Single editor/OS; VS Code and Windsurf not re-tested here |
| **GitHub Actions** (`ubuntu-latest`) | CI template evaluation | Available — documented example only | No live workflow run in this spike; template inspected |
| **npm wrapper** (`npm/bin/agtoosa.js`, Node ≥18) | Thin distribution wrapper baseline | Available — executed locally | Re-downloads pinned tarball each invocation; no Windows native path |

---

## 2. Evaluation rubric

All three options scored against the same criteria (AC-001). Scale: **Low / Medium / High** friction or cost unless noted.

| Criterion | Question |
|-----------|----------|
| **User value** | Does the add-on measurably improve discovery, setup, or daily use vs the baseline? |
| **Setup friction** | Extra installs, accounts, permissions, or config beyond baseline? |
| **Portability** | Works across supported OS/editor/CI without a second core implementation? |
| **Security** | Trust boundary, signing, permissions, and data exposure acceptable? |
| **Maintenance cost** | Ongoing owner, release coupling, and drift risk for AgToosa maintainers? |
| **Accessibility** | Keyboard/screen-reader paths, offline use, and discoverability without proprietary UI? |
| **Failure recovery** | Clean fallback and uninstall when the add-on fails or is removed? |
| **No-add-on fallback** | Baseline CLI + repo-local docs remain fully functional without the add-on? |

### Evidence quality labels

- **Observed:** command output, timing, or file content recorded below  
- **Assumption:** industry or architectural inference  
- **Untested:** not run in this spike (listed per option)

---

## 3. Option A — Thin native wrapper

**Scope:** A compiled or scripted native shim (e.g. Go/Rust binary, additional npm-adjacent launcher) that **delegates only** to `agtoosa.sh` / `agtoosa.ps1` — not a second install/registry core.

### 3.1 Observations

| ID | Method | Finding | Label |
|----|--------|---------|-------|
| W-01 | `bash agtoosa.sh --version` on maintainer repo | Exit 0 in **~0.02s** user time | Observed |
| W-02 | `node npm/bin/agtoosa.js --version` on macOS | Downloads pinned `v5.3.7` tarball, extracts to temp, delegates to `agtoosa.sh`, deletes temp; **~0.9–1.3s** per run | Observed |
| W-03 | Read `npm/bin/agtoosa.js` | Wrapper performs tar-slip pre-scan, pins version to `package.json`, forwards argv to `bash agtoosa.sh`, sets `AGTOOSA_PACK_QUEUE_DIR` under `~/.cache/agtoosa/pack-queue`; **rejects win32** with message to use WSL or `agtoosa.ps1` | Observed |
| W-04 | Read `bootstrap.sh` / README | Bootstrap and git-clone paths already provide non-npm distribution without duplicating generator logic | Observed |
| W-05 | Error propagation | npm wrapper `process.exit(run.status ?? 1)` — child exit codes propagate | Observed |
| W-06 | Platform parity | Bash + PowerShell cores exist; npm wrapper is macOS/Linux only; no gap filled by a third native core in observed scenarios | Observed |

### 3.2 Rubric scores (wrapper as *new* add-on beyond existing npm shim)

| Criterion | Score | Notes |
|-----------|-------|-------|
| User value | Low–Medium | npm + bootstrap already cover “no clone” install; marginal gain for another wrapper |
| Setup friction | Medium | New binary channel = signing, PATH, updater |
| Portability | Low | Would duplicate three existing entry paths |
| Security | Medium | New distribution surface (spoofing risk per STRIDE) |
| Maintenance cost | High | Version lockstep with `AGTOOSA_VERSION`, per-OS builds |
| Accessibility | Medium | CLI remains primary |
| Failure recovery | Medium | Must not block bash/ps1 paths |
| No-add-on fallback | High | Baseline unchanged |

### 3.3 Second-core guard

Any design that re-implements install, registry merge, or template copy **inside** a native wrapper is **rejected** as a second core (AC-002 failure mode). Acceptable future shape: pure delegation shell only.

### 3.4 Decision: Thin native wrapper — **Defer**

| Field | Value |
|-------|-------|
| **Outcome** | **Defer** |
| **Confidence** | High |
| **Evidence** | W-01–W-06 |
| **Costs** | Engineering + signing + release train for marginal UX over npm/bootstrap/clone |
| **Risks** | Second distribution channel drift; impersonation if unsigned |
| **Reconsideration trigger** | Repeated user failures on all three current paths (clone, bootstrap, npx) that **cannot** be fixed in Bash/PowerShell/npm wrapper documentation or behavior |

**Untested:** Windows ARM native binary; air-gapped install without network (npm path).

No separate future implementation proposal — defer does not authorize build work.

---

## 4. Option B — Editor extension

**Scope:** Marketplace-published VS Code / Cursor extension for command discovery, Master-Plan navigation, or AgToosa status UI — **optional** to the installed `.cursor/commands/` pack.

### 4.1 Observations

| ID | Method | Finding | Label |
|----|--------|---------|-------|
| E-01 | List `template/.cursor/commands/` | **17** native `agtoosa-*.md` command files install with the pack; Cursor picker discovers `/agtoosa-*` without an extension | Observed |
| E-02 | Read `template/.cursor/commands/agtoosa-help.md` | Commands route to `Docs/AgToosa_*.md` workflows; no extension API required | Observed |
| E-03 | Read `template/.cursor/rules/agtoosa-core.mdc` | Core rules document Cursor routing; reserved `agtoosa-*` namespace | Observed |
| E-04 | Marketplace model | Extension requires publisher identity, update channel, workspace trust review, and permission manifest | Assumption |
| E-05 | Uninstall | Removing `.cursor/commands` + rules is handled by `--uninstall`; extension would add separate uninstall path | Assumption |
| E-06 | Offline | Installed markdown commands work offline; extension marketplace fetch is online-dependent | Observed (commands); Assumption (marketplace) |
| E-07 | Accessibility | Native commands use editor picker + markdown; extension UI would need explicit a11y testing | Untested |

### 4.2 Rubric scores

| Criterion | Score | Notes |
|-----------|-------|-------|
| User value | Low–Medium | Discovery largely solved by installed command files |
| Setup friction | High | Marketplace install, trust prompt, updates |
| Portability | Low | Per-editor extension matrix (Cursor, VS Code, Windsurf, …) |
| Security | High concern | Broad workspace permissions if extension reads repo/git |
| Maintenance cost | High | Separate release cadence from generator |
| Accessibility | Medium | Depends on extension UI choices |
| Failure recovery | Medium | CLI + markdown commands must remain authoritative |
| No-add-on fallback | High | Full workflow without extension today |

### 4.3 Decision: Editor extension — **Defer**

| Field | Value |
|-------|-------|
| **Outcome** | **Defer** |
| **Confidence** | Medium–High |
| **Evidence** | E-01–E-07 |
| **Costs** | Extension CI, marketplace review, multi-editor parity |
| **Risks** | Permission creep; users mistake extension for required dependency |
| **Reconsideration trigger** | Sustained demand for Master-Plan navigation or command discovery **after** pack install, not solvable by `.cursor/commands` or docs |

**CLI fallback:** `bash agtoosa.sh --help`, `/agtoosa-help`, and `Docs/AgToosa_Agent.md` remain complete without any extension.

**Untested:** Cursor marketplace sideload; screen-reader audit of picker vs custom webview.

No separate future implementation proposal — defer does not authorize build work.

---

## 5. Option C — Additional CI templates

**Scope:** Maintainer-shipped copy-ready workflows beyond `docs/agtoosa-gate.yml.example` (GitLab CI, CircleCI, Azure Pipelines, Jenkins, etc.).

### 5.1 Observations

| ID | Method | Finding | Label |
|----|--------|---------|-------|
| C-01 | Read `docs/agtoosa-gate.yml.example` | Single **GitHub Actions** example; `permissions: contents: read`; pinned `actions/checkout@<sha>`; manual copy only — AgToosa never writes `.github/workflows/` | Observed |
| C-02 | Grep repository | No checked-in GitLab/CircleCI/Jenkins templates; `spec-DEV-079` defers unmaintained provider snippets | Observed |
| C-03 | Provider gap | Teams on non-GitHub CI must invoke `agtoosa-verify.sh` via provider-neutral `bash` step — no maintained template today | Observed |
| C-04 | Duplication risk | Each provider template duplicates verifier invocation + path detection (`Docs/` vs `docs/`) | Observed |
| C-05 | Maintenance owner | No maintainer currently exercises non-GHA templates in CI | Observed |
| C-06 | Copy-only boundary | Generator policy: templates are **copy-only** examples; not generated into host repos automatically (`lib/install.sh` denylist includes `.github/workflows/`) | Observed |

### 5.2 Rubric scores

| Criterion | Score | Notes |
|-----------|-------|-------|
| User value | Medium (for non-GHA users) | Real gap, but only if maintained |
| Setup friction | Medium | Per-provider copy + secrets/permissions review |
| Portability | Medium | Provider-specific YAML |
| Security | High concern | CI tokens, workflow write scope |
| Maintenance cost | High without owner | Rotting snippets worse than none |
| Accessibility | N/A | CI is operator-facing |
| Failure recovery | Medium | Users can run verifier locally if CI template wrong |
| No-add-on fallback | High | Local `agtoosa-verify.sh` unchanged |

### 5.3 Decision: CI templates — **Defer**

| Field | Value |
|-------|-------|
| **Outcome** | **Defer** |
| **Confidence** | High |
| **Evidence** | C-01–C-06 |
| **Costs** | Per-provider maintenance + contract tests (see DEV-079 VCA policy) |
| **Risks** | Untested snippets presented as supported; permission sprawl |
| **Reconsideration trigger** | A maintainer or user **commits to owning** a specific provider template with bats/VCA coverage, per DEV-079 AC-004 |

**Copy-only vs generated:** Additional templates must remain **copy-only** user actions, never auto-written by the generator.

**Untested:** Live GitLab/CircleCI workflow runs against this repository.

No separate future implementation proposal — defer does not authorize template additions in this spike.

---

## 6. Decision summary (independent outcomes)

| Option | Decision | Confidence | Primary evidence |
|--------|----------|------------|------------------|
| Thin native wrapper | **Defer** | High | W-01–W-06 |
| Editor extension | **Defer** | Medium–High | E-01–E-07 |
| CI templates | **Defer** | High | C-01–C-06 |

These are **three independent decisions** (AC-005). No combined go/no-go. **No adopt** recommendations — therefore **no** new implementation stories opened from this spike (AC-006).

---

## 7. Security and maintenance review

| Review area | Conclusion |
|-------------|------------|
| Security | Deferring all options avoids new trust boundaries (binary publisher, extension permissions, CI token scopes) |
| Portability | Baseline Bash/PowerShell + platform markdown entry points remain authoritative |
| Accessibility | Installed Cursor commands + CLI cover baseline; extension a11y untested |
| Maintenance | Highest cost options (extension, multi-provider CI) deferred without dedicated owners |
| No-add-on fallback | Confirmed complete for all three evaluations |

---

## 8. Future work pointers (not DEV-081 scope)

| Item | Relationship |
|------|--------------|
| DEV-079 Verifier and CI adoption examples | Canonical GHA copy-in guide; provider-neutral policy for non-GHA |
| Existing `npm/bin/agtoosa.js` | Already ships as delegating distribution wrapper — not expanded here |
| Roadmap (`docs/updates/AgToosa Strategic Improvement Roadmap.md`) | Lists wrapper/extension/CI as candidates validated by this spike |

---

## 9. TDD evidence (DXV)

### RED (2026-07-11)

```text
$ bats tests/agtoosa.bats -f "DEV-081"
not ok 1–8 — docs/spikes/DEV-081-local-dx-validation.md missing
```

### GREEN (2026-07-11)

```text
$ bats tests/agtoosa.bats -f "DEV-081"
1..8
ok 1 DEV-081 DXV-001: shared baseline rubric completeness
ok 2 DEV-081 DXV-002: thin wrapper delegation boundary @smoke
ok 3 DEV-081 DXV-003: editor extension trust and fallback review @smoke
ok 4 DEV-081 DXV-004: CI template gap evidence @smoke
ok 5 DEV-081 DXV-005: three independent DX decisions @smoke
ok 6 DEV-081 DXV-006: decision evidence and trigger traceability
ok 7 DEV-081 DXV-007: spike has no production implementation
ok 8 DEV-081 DXV-008: evidence assumption claim separation
Exit code: 0
```

---

## 10. Assumptions and untested conditions

**Assumptions**

- Cursor native command picker is sufficient for typical discovery post-install.
- GitHub Actions example remains the only maintainer-exercised CI integration.
- Users who need non-GHA CI can run verifier via generic shell steps without a shipped template.

**Untested**

- Windows native wrapper demand beyond `agtoosa.ps1`.
- Cursor/VS Code marketplace extension permissions audit.
- GitLab CI, CircleCI, Azure Pipelines, Jenkins live workflow execution.
- Screen-reader testing on Cursor command picker.

**Not shipped:** thin native wrapper product, editor extension, and additional CI templates remain **not shipped** as of this document.
