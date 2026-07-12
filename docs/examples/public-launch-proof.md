# AgToosa Public Launch Proof

Use this checklist after `sky2464/AgToosa` is made public. It turns DEV-041 into a repeatable publication audit instead of a one-off announcement.

## Required Public Surfaces

| Surface | Expected proof |
|---------|----------------|
| Repository | `https://github.com/sky2464/AgToosa` opens without authentication |
| Release | `https://github.com/sky2464/AgToosa/releases/tag/v5.3.7` opens without authentication |
| Bash bootstrap on `main` | `https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh` returns HTTP 200 |
| PowerShell bootstrap on `main` | `https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1` returns HTTP 200 |
| Pinned Bash bootstrap | `https://raw.githubusercontent.com/sky2464/AgToosa/v5.3.7/bootstrap.sh` returns HTTP 200 |
| Registry | `https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json` returns valid JSON |
| Homebrew | `https://github.com/sky2464/homebrew-agtoosa` opens without authentication |
| Support | issues, discussions, security policy, CI badge, and security badge open without authentication |
| Demo project | `https://github.com/sky2464/agtoosa-first-15-proof` links to generated files plus spec, test plan, review, and ship/readiness evidence |

## Commands

```bash
bash scripts/check-launch-readiness.sh --mode public

curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh >/tmp/agtoosa-bootstrap.sh
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1 >/tmp/agtoosa-bootstrap.ps1
curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/v5.3.7/bootstrap.sh >/tmp/agtoosa-bootstrap-v5.3.7.sh
curl -fsSL https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json | jq .
git ls-remote https://github.com/sky2464/homebrew-agtoosa.git
git ls-remote https://github.com/sky2464/agtoosa-first-15-proof.git
```

## Demo Project Acceptance

The proof project should be intentionally small. It passes when a new evaluator can inspect these files in public GitHub:

```text
Docs/AgToosa_Agent.md
Docs/AgToosa_Spec.md
Docs/AgToosa_Build.md
Docs/AgToosa_Review.md
Docs/AgToosa_Ship.md
Docs/Master-Plan.md
Docs/archived/spec-PROOF-001.md
Docs/AgToosa_TestPlan-PROOF-001.md
Docs/archived/review-PROOF-001.md
Docs/archived/ship-check-PROOF-001.md
```

Do not replace this with screenshots or marketing copy. The durable repo artifacts are the proof.
