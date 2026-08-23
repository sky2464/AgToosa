# Test Plan: DEV-142 — GitHub Surface Audit & Community Profile

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | GSA-001 | Unit | Manifest schema `agtoosa.github-surface-manifest/v1` valid | yes |
| AC-001 | GSA-002 | Unit | `github-surface-audit.sh --mode local` exits 0 | yes |
| AC-005 | GSA-003 | Unit | `ISSUE_TEMPLATE/config.yml` disables blank issues; links security + discussions | no |
| AC-004 | GSA-004 | Unit | Manifest includes full TRIAGE taxonomy labels | no |
| AC-008 | GSA-005 | Docs | `GITHUB-SURFACES.md` documents Projects v2 non-goal and audit command | no |
| AC-007 | GSA-006 | CI | `github-surface-audit.yml` exists; PR uses local mode | no |
| AC-007 | GSA-007 | CI | `pre-release-checklist.yml` runs live audit | no |
| AC-004 | GSA-008 | Unit | `labels.yml` delegates to `github-labels-sync.sh` | no |
| AC-006 | GSA-009 | CI | `wiki-sync.yml` seeds `Home.md` | no |
| AC-003 | GSA-010 | CI | `docs-pages-proof.yml` deploy guarded by `PAGES_ENABLED` | no |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| GSA-002 | Remove `config.yml` | Local audit fails |
| GSA-001 | Invalid schema_version | jq validation fails |

### Manual verification (post-ship)

| Step | Command / action | Expected |
|------|------------------|----------|
| About setup | `gh repo edit` per GITHUB-SURFACES.md | Description + topics + homepage set |
| Pages enable | Settings → Pages from `/docs` | `https://sky2464.github.io/AgToosa/` returns 200 |
| Label sync | `bash scripts/github-labels-sync.sh` | All manifest labels exist |
| Live audit | `bash scripts/github-surface-audit.sh --mode live` | Exit 0; health ≥95% |

## RED evidence

```
# Implemented green — local audit + bats GSA-001–GSA-010
```

## GREEN evidence

```
bats tests/agtoosa.bats --filter 'DEV-142 GSA' → 10/10 PASS
bash scripts/github-surface-audit.sh --mode local → exit 0
```
