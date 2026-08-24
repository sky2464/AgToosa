# AgToosa TODOS

Items deferred from active plans. Each item has a source and a target milestone.

---

## From: v3.1.0 Release Plan (autoplan, 2026-05-04)

### v3.2.0 Target

- [x] **GitHub Release body** — GitHub Release for v3.1.0 created (already existed via tag push). Source: CEO review finding (announcement artifact missing).

- [ ] **Migration wizard milestone** — commit to a v3.2.0 release date for the interactive migration wizard (ADR-004 item 5) that runs on `--update` when a MAJOR version delta is detected. **Target: v3.2.0 / 2026-07-01.** Source: CEO review finding.

- [x] **Markdown template injection threat model** — documented in `docs/security/template-injection-threat-model.md`. Attack surface, vectors, existing mitigations (SHA-256 + file-type allowlist), open gaps, and recommended mitigations catalogued. Priority: Low while pack count near zero; escalate before public registry launch. Source: CEO/security review.

### Future / Backlog

- [ ] **Automated CHANGELOG generation** — Evaluated: `git-cliff` is viable and supports conventional commits, but adds a dev dependency (Rust binary). Manual CHANGELOG entries are acceptable at current commit volume (<5 releases/year). **Defer to v4** when commit volume or contributor count justifies the tooling overhead. Source: ADR-004, DX review.

- [x] **Exact-version bats test** — implemented: `--version prints version string` test now pins `"AgToosa v3.1.0"` (v3.1.0). Source: Eng review (nitpick).

- [x] **agtoosa-lock.json schema bats test** — implemented: `agtoosa-lock.json schema has required fields` test validates `name`, `version`, `sha256`, `installed_at` fields via python3 heredoc (v3.1.0). Source: Eng review.

---

## Open ADR Action Items (not blocking v3.1.0)

- [x] **ADR-001 item 3**: Extension authoring guide — created `docs/extension-authoring-guide.md` with 6-step guide and OpenCode worked example (v3.1.0)
- [ ] **ADR-001 item 4**: Evaluate manifest-driven platform approach when platform count reaches 8 — currently 7; trigger: 8th platform added
- [ ] **ADR-001 item 5**: Track Gemini CLI and Cursor hook API announcements — monitoring; no action until API ships
- [ ] **ADR-002 item 5**: GitHub Action in `agtoosa-registry` to lint/validate pack manifests — deferred; trigger: first community pack PR submitted
- [ ] **ADR-002 item 6**: GPG-signed registry index verification (v4) — deferred; SHA-256 pinning sufficient for now
- [ ] **ADR-002 item 7**: Pagination strategy for registry.json (>200 packs) — deferred; trigger: >200 packs or registry.json >200KB
- [x] **ADR-003 item 4**: Phase-order warnings in workflow docs — `> **Prerequisites:**` blockquotes added to Build, Review, Ship docs (v3.1.0)
- [x] **ADR-003 item 5**: Master-Plan.md compaction strategy — Part 6 "Compact Master-Plan.md" added to `AgToosa_Ship.md` with cycle-archive protocol (v3.1.0)
- [x] **ADR-003 item 6**: Parallel task distribution in Build phase for Claude Code — "Claude Code Parallel Pattern" subsection added to `AgToosa_Build.md` (v3.1.0)
- [x] **ADR-003 item 7**: Sub-agent dependency DAG + auto-rollback — `## Future: Sub-Agent Dependency DAG (v4)` design stub added to ADR-003 (v3.1.0)
- [ ] **ADR-004 item 5**: Interactive migration wizard for `--update` (MAJOR version delta) — **Target: v3.2.0 / 2026-07-01**
- [ ] **ADR-004 item 8**: Automated CHANGELOG generation from conventional commits — Evaluated; defer to v4 (see Future/Backlog above)
