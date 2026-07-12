# Verifier and CI Adoption

Canonical copy-in guide for AgToosa’s deterministic verifier and the maintained GitHub Actions gate. Other surfaces (README, Quickref, Readiness) link here instead of duplicating the full procedure.

## Operating contexts

Pick the path prefix that matches where you are working. Do not mix them in one command.

| Context | Path prefix | Where |
|---------|-------------|--------|
| **Generated Project Mode** | `Docs/` | Downstream install after `agtoosa.sh` |
| **Maintainer Dogfood Mode** | `docs/` | This AgToosa generator repository |

## 1. Local verifier (machine check)

The installed verifier is a **local machine check**. Running it on your laptop does **not** make a CI gate active.

### Generated project

```bash
bash Docs/agtoosa-verify.sh                    # default gates (human text)
bash Docs/agtoosa-verify.sh --strict           # WARN → FAIL
bash Docs/agtoosa-verify.sh --format json      # verify-result-v1 machine output
bash Docs/agtoosa-verify.sh stats              # cycle analytics
```

### Maintainer repository (Dogfood)

```bash
bash docs/agtoosa-verify.sh                    # default gates (human text)
bash docs/agtoosa-verify.sh --strict           # WARN → FAIL
bash docs/agtoosa-verify.sh --format json      # verify-result-v1 machine output
bash docs/agtoosa-verify.sh stats              # cycle analytics
```

### JSON machine output

`--format json` prints a single `verify-result-v1` document on stdout (schema: `Docs/schemas/verify-result-v1.json` / `docs/schemas/verify-result-v1.json`). Required fields: `schema_version`, `tool`, `exit_code`, `summary`, `findings[]` (`id`, `severity`, `problem`, `impact`, `fix`; optional `assurance`, `ac_refs`). Exit codes stay `0` / `1` / `2`. Human text mode remains the default and uses **Problem / Impact / Fix** blocks for WARN/FAIL findings.

Generator dispatch:

```bash
bash agtoosa.sh --verify --format json .
bash agtoosa.sh --doctor --format json .
```

Doctor JSON includes a `provenance` object labeling `Docs/.agtoosa-version` (semver marker, committed), `Docs/agtoosa-lock.json` (pack pins, committed when used), and `.agtoosa/state.json` (operational hashes, gitignored — absent is OK).

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Pass (no FAIL findings) |
| `1` | Findings present (FAIL, or WARN under `--strict`) |
| `2` | Usage error (bad flags or root) |

## 2. Enforcement states

Use these labels honestly:

| State | Classification |
|-------|----------------|
| `Docs/agtoosa-verify.sh` (or `docs/…`) installed and run locally | **local machine check** (machine-enforced locally when invoked) |
| `Docs/agtoosa-gate.yml.example` shipped but not copied | **template only** |
| Workflow copied to `.github/workflows/` **and** a real Actions run observed | **CI-enforced** for configured events |
| Branch protection / required checks | **manual** repository administration |
| Non-GitHub CI wiring | **provider-neutral** guidance only (unless a separately maintained example exists) |

Never call the uncopied `.example` file **CI-enforced**. AgToosa never writes `.github/workflows/` automatically.

## 3. GitHub Actions adoption (maintained, copy-ready)

GitHub Actions is the only **maintained**, **copy-ready** provider example. Owning surfaces: `Docs/agtoosa-gate.yml.example` / `docs/agtoosa-gate.yml.example` (mirrors) and this guide. Contract coverage: VCA bats in `tests/agtoosa.bats`.

The shipped gate runs the verifier with `--format json`, validates non-empty JSON via `jq`, and **preserves the verifier exit status** (JSON parse success must not mask a verifier failure).

### Safe copy sequence

1. **Inspect** the destination. List `.github/workflows/` (create the directory if missing).
2. **Stop** if `.github/workflows/agtoosa-gate.yml` already exists — do not silently overwrite a customized workflow.
3. **Copy** the shipped example explicitly (Generated Project path shown; use `docs/` in Maintainer Dogfood Mode):

```bash
mkdir -p .github/workflows
cp Docs/agtoosa-gate.yml.example .github/workflows/agtoosa-gate.yml
```

Maintainer Dogfood Mode copy:

```bash
mkdir -p .github/workflows
cp docs/agtoosa-gate.yml.example .github/workflows/agtoosa-gate.yml
```

4. **Review the diff** (`git diff .github/workflows/agtoosa-gate.yml`).
5. **Commit and push** the workflow file.
6. **Observe** a real GitHub Actions workflow run (PR or push to a configured branch).
7. Only after that observed run may you call the gate **CI-enforced**. Enabling required status checks remains a separate manual admin step.

## 4. Other CI providers (provider-neutral, unmaintained)

Guidance for GitLab CI, CircleCI, Jenkins, and Azure Pipelines is **provider-neutral** and **unmaintained**. AgToosa does not ship checked-in workflow files or focused contract bats for those platforms.

Provider-neutral contract:

- Invoke the **repo-local** verifier (`Docs/agtoosa-verify.sh` or `docs/agtoosa-verify.sh`).
- Preserve the verifier’s exit status as the job result.
- Fail closed if the verifier script is absent.
- Do not treat pseudocode snippets as a maintained integration.

## Related

- Gate template: [`docs/agtoosa-gate.yml.example`](../agtoosa-gate.yml.example) (maintainer) · `Docs/agtoosa-gate.yml.example` (generated install)
- Quickref verification section: [`docs/AgToosa_Quickref.md`](../AgToosa_Quickref.md)
- Enforcement matrix: [`docs/AgToosa_Readiness.md`](../AgToosa_Readiness.md)
- Comparison context: [`docs/enforcement-comparison.md`](../enforcement-comparison.md)
