# Registry Pack Authoring Handbook

This is the **canonical** readiness handbook for authors preparing an AgToosa community template pack for registry review. User-facing install/list/publish behavior lives in `docs/AgToosa_Registry.md` (maintainer) / `Docs/AgToosa_Registry.md` (generated projects) — those docs **link here** and must not maintain a second full checklist.

Packs are markdown workflow bundles. Existing generator controls (SHA-256 pin, isolated staging, verified-flag gate, sensitive-path denylist, preview/consent) remain authoritative; this handbook does not change registry implementation.

---

## Readiness Checklist

Complete every item before opening a registry PR. Use placeholders only — never embed tokens, private registry URLs, or signing private keys in examples.

- [ ] **Scoped Spec template** — Pack purpose, in-scope files, and explicit non-goals are written (what the pack instructs an agent to do, and what it must not claim).
- [ ] **Test guidance** — Named checks or bats/fixture expectations document how a reviewer proves install/preview/queue/merge behavior for this pack.
- [ ] **Threat-model notes** — STRIDE-oriented notes for pack content (spoofing of “official” labeling, prompt injection via markdown, path/denylist abuse, secret leakage in examples).
- [ ] **Version compatibility** — Supported AgToosa version range and applicable platform surfaces; untested combinations are labeled untested (not “supported”).
- [ ] **Provenance** — Source repo, release tag/URL, SHA-256 of the tarball, and optional minisign sidecar metadata (when used) are recorded without private keys.
- [ ] **Worked example** — One concrete, synthetic walkthrough shows browse → install → preview → queue → merge using fake pack names and placeholder hashes.
- [ ] **Named maintenance owner** — A GitHub username (or team) is named as the ongoing owner, with an issue path for breakage and a short deprecation intent.

---

## Publication sequence (summary)

1. Author pack markdown under a dedicated repo (e.g. `your-org/agtoosa-my-pack`).
2. Tag a release and compute `sha256sum` of the release tarball.
3. Open a PR against `sky2464/agtoosa-registry` with `registry.json` + `packs/<name>.json` metadata.
4. Wait for **manual** maintainer registry review (`verified: true` only after approval).

For CLI details (`--registry list|info|install|publish`), see the Registry doc — do not duplicate those tables here.

---

## Allowlist / denylist reminder

Packs remain markdown-only for automatic install. Sensitive destinations such as `.claude/settings.json`, `.claude/hooks/`, and `.github/workflows/` are blocked by the generator denylist. Do not document workarounds that write protected settings or CI workflows via pack content.

---

## Claim Boundary

| Control | Classification |
|---------|----------------|
| This handbook and readiness checklist | documentation (agent-instructed) |
| Focused AUTH / inventory link checks in this repository | CI-enforced when repository CI runs them |
| Pack SHA-256, isolated staging, denylist, verified-flag gate | existing **generator-enforced** controls (referenced, not redefined here) |
| Registry approval (`verified: true`) and maintenance-owner confirmation | **manual** maintainer review |
| Fail-closed require-signatures / marketplace certification | **roadmap** (out of scope) |

Do **not** describe manual registry approval as CI-enforced.
