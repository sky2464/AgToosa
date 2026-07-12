---
title: AgToosa Documentation
---

# AgToosa

Canonical documentation lives in this repository's `docs/` tree. This landing
page **links** to guides by user job — it does not duplicate their bodies.

Project Pages base path: `/AgToosa/`.

## Start

Get installed and oriented:

- [First 15 minutes](examples/first-15-minutes.md) — smallest credible proof walkthrough
- [Install / init](AgToosa_Init.md) — install and project bootstrap entry points
- [Update](AgToosa_Update.md) — baseline update check · plan · apply · verify
- [Agent instructions](AgToosa_Agent.md) — operating contexts and commands

Browsable renders: [First 15]({{ '/examples/first-15-minutes.html' | relative_url }}) · [Agent]({{ '/AgToosa_Agent.html' | relative_url }})

## Use

Daily lifecycle workflow:

- [Spec](AgToosa_Spec.md) — deepen requirements and acceptance criteria
- [Build](AgToosa_Build.md) — implement against the approved spec
- [Review](AgToosa_Review.md) — structured review against ACs
- [Ship](AgToosa_Ship.md) — release and archive
- [Verify](agtoosa-verify.sh) — deterministic lifecycle verifier (`bash docs/agtoosa-verify.sh`)

## Trust

Evaluate verification, registry, and security boundaries:

- [Verifier CI adoption](examples/verifier-ci-adoption.md) — verification in CI
- [Registry](AgToosa_Registry.md) — pack trust boundary, install, and provenance
- [Evidence](AgToosa_Evidence.md) — evidence ledger and claim boundary
- [Security docs](security/README.md) — supply-chain and injection threat models

## Adapt

Extend with packs and catalogs:

- [Registry pack authoring](registry-pack-authoring.md) — author and publish packs
- [Catalog](AgToosa_Catalog.md) — catalog validate and plan
- [Extension authoring](extension-authoring-guide.md) — extension pack guidance

## Maintain

Upgrade, diagnose, and contribute:

- [Update](AgToosa_Update.md) — detect → plan → apply → verify
- [Quickref (doctor / uninstall)](AgToosa_Quickref.md) — `--doctor` and `--uninstall` surfaces
- [Revert](AgToosa_Revert.md) — uninstall / revert guidance
- [Maintainer guide](agtoosa-maintainer.md) — Maintainer Dogfood Mode
- [Contributing](https://github.com/sky2464/AgToosa/blob/main/CONTRIBUTING.md) — contribution process
