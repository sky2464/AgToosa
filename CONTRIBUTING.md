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

## Attribution

Contributors are recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- Discussions and community shoutouts

## License

By contributing to AgToosa, you agree that your contributions will be licensed under its MIT License.
