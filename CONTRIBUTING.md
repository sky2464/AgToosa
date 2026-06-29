# Contributing to AgToosa

We love your input! We want to make contributing to AgToosa as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Improving documentation

## Code of Conduct

Please note we have a [Code of Conduct](CODE_OF_CONDUCT.md). Please follow it in all your interactions with the project.

## Development Process

### Getting Started

1. **Fork** the repository and clone your fork locally
2. **Create a feature branch** from `main`: `git checkout -b feature/your-feature-name`
3. **Make your changes** with clear, atomic commits using conventional commit format
4. **Run tests**: `bash tests/agtoosa.bats`
5. **Push** to your fork and **submit a Pull Request**

### Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

Optional body with more details.

Optional footer with breaking changes or issue references.
```

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`

Example:
```
feat(agtoosa-spec): add threat modeling step

Adds STRIDE threat modeling to the spec workflow, improving security.

Closes #123
```

### Code Standards

- **Shell scripts**: Follow Google Shell Style Guide ([shellcheck](https://www.shellcheck.net/))
- **Markdown**: Validate with [markdownlint](https://github.com/igorshubovych/markdownlint-cli)
- **Testing**: Add BATS tests for new functionality
- **Documentation**: Keep `.md` files in sync with actual implementation

### Testing

Run the full test suite before submitting:

```bash
# Run all BATS tests
bash tests/agtoosa.bats

# Run with verbose output
bash tests/agtoosa.bats --verbose
```

Tests cover:
- Core generator functionality
- Platform-specific file copying
- Version validation
- Configuration merging
- Error handling

### Maintainer validation

When changing `agtoosa.sh`, `lib/maintain.sh`, or `agtoosa-verify.sh`, run these checks from the repo root before opening a PR:

```bash
# Full regression suite
bats tests/agtoosa.bats

# Deterministic lifecycle gate (maintainer uses lowercase docs/)
bash agtoosa.sh --verify .
bash docs/agtoosa-verify.sh --strict

# Install health — run against a generated project (doctor checks Docs/, not maintainer docs/)
# bash agtoosa.sh --doctor /path/to/generated-project
```

See `docs/agtoosa-maintainer.md` for the full maintainer guide (generator maintenance CLI, verifier dual-path conventions, release checklist).

**Install troubleshooting (downstream projects):**

| Symptom | Check |
|---------|-------|
| Version skew after a release | `bash agtoosa.sh --doctor /path/to/project` — run `--update` when the generator is newer |
| Verifier FAIL before ship | `bash Docs/agtoosa-verify.sh` in the project; fix spec approval, EARS ACs, threat model, or RED/GREEN evidence |
| Partial or broken install | `--doctor` for missing docs/wiring; `--update` to restore; `--uninstall` only when removing AgToosa (preserves Master-Plan and Context/) |
| CI gate not running | Copy `Docs/agtoosa-gate.yml.example` to `.github/workflows/agtoosa-gate.yml` manually — AgToosa does not write workflows automatically |

## Report Bugs Using GitHub Issues

We use GitHub Issues to track public bugs. Report a bug by [opening a new issue](https://github.com/sky2464/AgToosa/issues).

### Great Bug Reports Include

- A quick summary and/or background
- Steps to reproduce
- What you expected to happen
- What actually happens
- Your environment (OS, shell, platform)
- Error messages or logs
- Possibly screenshots

## Submit Feature Requests

Feature requests are always welcome! Submit via:

1. **GitHub Issues** — For features that should be tracked
2. **Discussions** — For ideas you'd like to explore first

When submitting a feature:
- Explain the use case and motivation
- Describe the expected behavior
- Provide examples if possible

## Pull Requests

1. **Fork** the repository and create your branch from `main`
2. **Add tests** if you've added new functionality
3. **Update documentation** if you've changed behavior
4. **Ensure tests pass**: `bash tests/agtoosa.bats`
5. **Check code quality**: `shellcheck agtoosa.sh lib/*.sh`
6. **Check markdown**: `markdownlint *.md template/Docs/*.md`
7. **Use conventional commits** for clear history
8. **Submit** your PR with a clear description

### PR Guidelines

- **Title**: Use conventional commit format
- **Description**: Reference related issues (e.g., `Closes #123`)
- **Labels**: Add appropriate labels (bug, enhancement, docs, etc.)
- **Size**: Keep PRs focused — split large changes across multiple PRs
- **Tests**: All tests must pass before merging

## Deprecation Policy

Before removing or renaming a command, workflow, or public interface:

1. **Announce in a minor release**: The old name continues to work but prints a deprecation warning at runtime.
2. **Document in CHANGELOG.md** under `### Deprecated` (not `### Breaking`) in the announcement release.
3. **Remove in the next minor or major release**. Move the CHANGELOG entry from `### Deprecated` to `### Breaking`.

**Example timeline:**
- v3.1.0: `/agtoosa-old-cmd` prints "⚠️ Deprecated: renamed to /agtoosa-new-cmd in v3.2.0"
- v3.2.0: `/agtoosa-old-cmd` removed; CHANGELOG lists it under `### Breaking`

This gives users one release cycle to migrate. For MAJOR version bumps (breaking schema changes), a migration wizard will guide users through `--update` (v3.1+).

## Attribution

Contributors are recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- Discussions and community shoutouts

## License

By contributing to AgToosa, you agree that your contributions will be licensed under its MIT License.
