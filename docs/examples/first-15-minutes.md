# AgToosa First 15 Minutes

This walkthrough shows the smallest credible AgToosa proof path in a clean repo. It is intentionally text-first so it can be verified before launch without a hosted demo.

## 1. Start From A Clean Repo

```bash
tmpdir="$(mktemp -d)"
mkdir "$tmpdir/agtoosa-proof"
cd "$tmpdir/agtoosa-proof"
git init
printf '# Proof App\n' > README.md
git add README.md
git commit -m "chore: start proof app"
```

Use the pinned public release path:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.3.7
```

The public proof repository for this walkthrough is [sky2464/agtoosa-first-15-proof](https://github.com/sky2464/agtoosa-first-15-proof).

For publication readiness, pair this walkthrough with the [public launch proof checklist](public-launch-proof.md).

## 2. Generator Created

After the generator runs, the repo should contain workflow files such as:

```text
Docs/AgToosa_Agent.md
Docs/AgToosa_Init.md
Docs/AgToosa_Spec.md
Docs/AgToosa_Build.md
Docs/AgToosa_Review.md
Docs/AgToosa_Ship.md
Docs/Master-Plan.md
```

Generator created these files. It did not implement product code, run security scans, or create a release by itself.

## 3. Agent Instructed

Open your AI coding assistant and run the workflow commands against the installed docs:

```text
/agtoosa-init
/agtoosa-spec quick
/agtoosa-build
/agtoosa-review
/agtoosa-ship check
```

Agent instructed work should produce durable artifacts such as:

```text
Docs/archived/spec-PROOF-001.md
Docs/AgToosa_TestPlan-PROOF-001.md
Docs/archived/review-PROOF-001.md
Docs/archived/ship-check-PROOF-001.md
```

The exact story ID can differ. The proof is that the repo now has a spec, a test-plan mapping, a review artifact, and a ship-check artifact that survive chat context loss.

## 4. What This Proves

AgToosa's value is repo-native workflow continuity:

- The generator installs the workflow contract.
- The agent follows the contract.
- The developer can inspect and version the resulting artifacts.
- The workflow can be repeated by another assistant later.

## Cleanup

Remove the proof repo when done:

```bash
rm -rf "$tmpdir"
```
