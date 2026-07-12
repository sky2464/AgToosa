# AgToosa Offline and Network-Dependency Matrix

> **Canonical source** for CLI offline / network behavior. Agent and Registry docs **link here** — do not maintain competing command×class tables elsewhere.
>
> Generated projects receive this file as `Docs/AgToosa_Network_Matrix.md`. The AgToosa maintainer mirror is `docs/AgToosa_Network_Matrix.md`.

## Dependency classes

| Class | Meaning |
|-------|---------|
| `offline` | Succeeds with no network egress once the local generator/install is present |
| `network-required` | Needs network to complete successfully |
| `network-optional` | Prefers network; a documented offline fallback (cache, local path, or private mode) exists |

Exactly one class applies per command/mode row.

## Matrix

| Command / mode | Bash | PowerShell | Class | Offline fallback / notes |
|----------------|------|------------|-------|--------------------------|
| install (project wizard) | `bash agtoosa.sh` / `--path` / `--platforms` | `.\agtoosa.ps1` / `-Path` / `-Platforms` | offline | Copies from the local generator `template/`; no registry fetch. Bootstrap/`curl` first-time download of AgToosa itself is separate and network-required. |
| update | `bash agtoosa.sh --update [path]` | `.\agtoosa.ps1 -Update -UpdatePath <path>` | offline | Applies the local generator baseline to a project install. |
| verify | `bash agtoosa.sh --verify [path]` | `.\agtoosa.ps1 -Verify -UpdatePath <path>` | offline | Runs the local lifecycle verifier (`Docs/agtoosa-verify.sh`). |
| doctor | `bash agtoosa.sh --doctor [path]` | `.\agtoosa.ps1 -Doctor -UpdatePath <path>` | offline | Local install diagnosis only (version skew, wiring, context). |
| registry list | `bash agtoosa.sh --registry list` | `.\agtoosa.ps1 -Registry -RegistryCommand list` | network-optional | Uses cached `registry.json` when fresh (`AGTOOSA_REGISTRY_CACHE_DIR` or `~/.cache/agtoosa`); pre-seed the cache for air-gapped list. |
| registry info | `bash agtoosa.sh --registry info <name>` | `.\agtoosa.ps1 -Registry -RegistryCommand info -RegistryArg <name>` | network-optional | Same registry cache / pre-seed path as list. |
| registry install | `bash agtoosa.sh --registry install <name-or-./path>` | `.\agtoosa.ps1 -Registry -RegistryCommand install -RegistryArg <name-or-.\path>` | network-optional | Offline: `--registry install ./local-pack` (or absolute path). Remote name installs need network or a pre-seeded cache plus a reachable/local tarball URL. |
| registry publish | `bash agtoosa.sh --registry publish [pack-dir]` | Prints Bash/WSL/Git Bash redirect (no native wizard) | network-optional | Local wizard validates the pack and prints a `registry.json` entry; opening the PR on GitHub requires network. |
| catalog validate | `bash agtoosa.sh --catalog validate <path>` | `.\agtoosa.ps1 -Catalog -CatalogCommand validate -CatalogArg <path>` | offline | Validates a local catalog JSON file; no network. |
| launch-readiness (private) | `bash scripts/check-launch-readiness.sh --mode private` | Use Bash/WSL/Git Bash (script is bash) | offline | Local docs/language checks only; skips anonymous public URL checks. |
| launch-readiness (public) | `bash scripts/check-launch-readiness.sh --mode public` | Use Bash/WSL/Git Bash (script is bash) | network-required | Performs anonymous public URL checks (`curl`) against advertised surfaces. |

## Mitigations cheat sheet

| Mitigation | How |
|------------|-----|
| Local pack install | `bash agtoosa.sh --registry install ./my-pack` |
| Registry cache dir | `export AGTOOSA_REGISTRY_CACHE_DIR=/path/to/vetted-cache` (pre-seed `registry.json`) |
| Private launch mode | `bash scripts/check-launch-readiness.sh --mode private` |
| High-assurance offline | Pre-seed cache + verify pack SHA-256 before install; optional minisign soft-warn via `AGTOOSA_MINISIGN_PUBKEY` |

## Related

- Agent command overview: `Docs/AgToosa_Agent.md`
- Registry cache and trust detail: `Docs/AgToosa_Registry.md` (operational notes only — not a second matrix)
