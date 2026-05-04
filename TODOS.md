# AgToosa TODOS

Items deferred from active plans. Each item has a source and a target milestone.

---

## From: v3.1.0 Release Plan (autoplan, 2026-05-04)

### v3.2.0 Target

- [ ] **GitHub Release body** — create a GitHub Release (not just a git tag) with release notes for v3.1.0, formatted for users browsing the releases tab. Source: CEO review finding (announcement artifact missing).

- [ ] **Migration wizard milestone** — commit to a v3.2.0 release date for the interactive migration wizard (ADR-004 item 5) that runs on `--update` when a MAJOR version delta is detected. Without a date, this item drifts indefinitely. Source: CEO review finding.

- [ ] **Markdown template injection threat model** — `.json`/`.md` pack files can carry template injection payloads that land in generated CI workflows. Scope and mitigate before the registry has real community packs. Source: CEO/security review. Low urgency while pack count is near zero.

### Future / Backlog

- [ ] **Automated CHANGELOG generation** — evaluate `git-cliff` or similar conventional-commit-to-CHANGELOG tooling. Currently manual CHANGELOG entries are the primary maintenance burden for each release. Rationale for deferral: small commit volume makes manual approach acceptable through v3.x. Source: ADR-004, DX review.

- [ ] **Exact-version bats test** — add a bats test that pins the expected version string (`AgToosa v3.1.0`) rather than the loose `AgToosa v*` glob. Currently the `--version` test passes regardless of what version is installed. Source: Eng review (nitpick).

- [ ] **agtoosa-lock.json schema bats test** — add a bats test that validates the lock file schema (required fields: name, version, sha256, installed_at). Source: Eng review.

---

## Open ADR Action Items (not blocking v3.1.0)

- [ ] **ADR-001 item 3**: Extension authoring guide — how to add a new platform template tree
- [ ] **ADR-001 item 4**: Evaluate manifest-driven platform approach when platform count reaches 8
- [ ] **ADR-001 item 5**: Track Gemini CLI and Cursor hook API announcements
- [ ] **ADR-002 item 5**: GitHub Action in `agtoosa-registry` to lint/validate pack manifests
- [ ] **ADR-002 item 6**: GPG-signed registry index verification (v4)
- [ ] **ADR-002 item 7**: Pagination strategy for registry.json (>200 packs)
- [ ] **ADR-003 item 4**: Phase-order warnings in workflow docs
- [ ] **ADR-003 item 5**: Master-Plan.md compaction strategy (archive completed cycles)
- [ ] **ADR-003 item 6**: Parallel task distribution in Build phase for Claude Code
- [ ] **ADR-003 item 7**: Sub-agent dependency DAG + auto-rollback (v4 design doc)
- [ ] **ADR-004 item 5**: Interactive migration wizard for `--update` (MAJOR version delta)
- [ ] **ADR-004 item 8**: Automated CHANGELOG generation from conventional commits
