# DEV-054 minisign fixtures (test-only)

Disposable public key + sample payload used by SP bats.

- `test.minisign.pub` — public key for soft-warn verify tests
- `sample.txt` / `sample.txt.minisig` — valid signature pair
- `sample.txt.bad.minisig` — intentionally invalid sidecar

**Do not** commit private keys. Re-sign locally if fixtures need refresh:

```bash
minisign -G -W -p test.minisign.pub -s /tmp/test.minisign.key
minisign -S -W -s /tmp/test.minisign.key -m sample.txt
rm -f /tmp/test.minisign.key
```
