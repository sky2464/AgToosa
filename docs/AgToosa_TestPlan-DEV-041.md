# Test Plan: DEV-041 - Public launch publication proof

> **Spec:** `docs/archived/spec-DEV-041.md`
> **Coverage target:** public launch URLs, pinned install proof, registry/tap availability, demo proof project
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-041"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | PL-001 | Public integration | `scripts/check-launch-readiness.sh --mode public` passes after repo publication | yes |
| AC-002 | PL-002 | Install smoke | README pinned release install path works anonymously from a clean environment | yes |
| AC-003 | PL-003 | Distribution | Bash and PowerShell bootstrap files are anonymous-accessible from expected public URLs | yes |
| AC-004 | PL-004 | Registry | Public registry JSON resolves and pack URL/SHA metadata is valid or intentionally documented as empty | yes |
| AC-005 | PL-005 | Homebrew | Homebrew tap/formula is public or README clearly keeps Homebrew gated | no |
| AC-006 | PL-006 | Community/support | issues, discussions, release page, security policy, and badges resolve anonymously | yes |
| AC-007 | PL-007 | Proof project | Public demo project shows generated files plus spec/test-plan/review/ship evidence | yes |
| AC-008 | PL-008 | Docs truthfulness | Launch docs preserve enforcement boundary language and avoid overclaiming | no |
| AC-001 | PL-006 | Release CI | Release workflows update existing releases instead of failing on duplicate release creation | yes |
| AC-001 | PL-007 | Security CI | Dependency-Check workflow avoids invalid folded `others` arguments | yes |

## Commands

```bash
bash scripts/check-launch-readiness.sh --mode public
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh >/tmp/agtoosa-bootstrap.sh
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1 >/tmp/agtoosa-bootstrap.ps1
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/v5.2.7/bootstrap.sh >/tmp/agtoosa-bootstrap-v5.2.7.sh
curl -fsSL https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json | jq .
git ls-remote https://github.com/sky2464/homebrew-agtoosa.git
git ls-remote https://github.com/sky2464/agtoosa-first-15-proof.git
git diff --check
```

## Validation Evidence

```text
2026-06-08 public publication evidence:
- `bash scripts/check-launch-readiness.sh --mode public` public mode passes after publication.
- `https://github.com/sky2464/AgToosa` is public, and release `v5.2.7` is the pinned public release target.
- `https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json` returns valid JSON; the launch index is intentionally empty until public packs are published.
- `https://github.com/sky2464/homebrew-agtoosa` is public and contains `Formula/agtoosa.rb`.
- `https://github.com/sky2464/agtoosa-first-15-proof` is public and contains generated-style workflow files plus spec, test-plan, review, and ship-check evidence.
- Release workflows use `gh release view` before create/edit so repeated tag automation does not fail when a release already exists.
- Security workflow no longer passes the invalid folded Dependency-Check `others` argument.
```
