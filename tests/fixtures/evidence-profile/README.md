# Evidence-profile Gate 7 fixtures (DEV-089)

YAML profiles for EPV bats. Project trees are seeded in-test under `$TEST_PROJECT`.

| File | Purpose |
|------|---------|
| `valid-standard.yml` | Healthy standard profile |
| `valid-security-sensitive.yml` | SAST/dependency-scan presence checks (no false claims) |
| `valid-guided-stride.yml` | Guided threat-model row — must not FAIL without wired command |
| `invalid-malformed.yml` | Bounded WARN on bad YAML |
| `invalid-unknown-active.yml` | Unknown `active` profile key |
| `command-injection.yml` | Shell metacharacters in `command` — never eval |
| `ledger-missing-profile.yml` | Profile requires review; pair with Done story lacking `evidence-*.md` |
