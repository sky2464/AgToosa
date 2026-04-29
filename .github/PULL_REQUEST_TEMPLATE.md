## Description
<!-- Concise summary of what changed and why -->

## Related Issues
<!-- Required: link every issue this resolves. e.g. Closes #123, Fixes #456 -->
Closes #

## Type of Change
- [ ] `fix` — bug fix (non-breaking)
- [ ] `feat` — new feature (non-breaking)
- [ ] `feat!` — breaking change
- [ ] `docs` — documentation only
- [ ] `chore` — refactor / lint / CI — no behaviour change
- [ ] `security` — security fix

## Release Impact
- [ ] No release notes needed (chore/docs only)
- [ ] Patch release (bug fix)
- [ ] Minor release (new feature)
- [ ] Major release (breaking change) — migration path documented below

<!-- If breaking: describe the migration path for existing users -->

## Testing Evidence
<!-- Required: paste or link test output showing this works -->
```
# paste bats test run output, shellcheck output, or manual verification steps
```

## Checklist
- [ ] I have read [CONTRIBUTING.md](CONTRIBUTING.md)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, etc.)
- [ ] `bash agtoosa.sh --list-template-files` passes (if template files were added/removed)
- [ ] `bats tests/agtoosa.bats` passes locally
- [ ] `shellcheck agtoosa.sh lib/*.sh` passes (if shell files were changed)
- [ ] CHANGELOG.md updated (for `feat` and `fix` PRs)
- [ ] Docs updated to match behaviour changes
