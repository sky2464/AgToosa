# Compatibility — Official Security Pack

## Supported

| Dimension | Value |
|-----------|-------|
| AgToosa | `>=5.0.0 <6.0.0` |
| Platforms | `cursor`, `claude` |

## Security evidence expectations

| Expectation | Classification |
|-------------|----------------|
| STRIDE / threat-model ACs in specs | Guided + evidenced via lifecycle docs |
| Registry allowlist / denylist / preview / consent | Generator-enforced |
| External SAST/DAST / scanner runs | Manual / stack-dependent — record command evidence when used |
| Fail-closed signature mode | Out of scope for this pack |

This pack does **not** claim that AgToosa itself executes scanners or fails closed on SAST findings.

## Untested / incompatible

| Combination | Status |
|-------------|--------|
| AgToosa `>=6.0.0` | incompatible (major boundary) |
| AgToosa `<5.0.0` | incompatible |
| Windsurf-only host | untested |
| Gemini-only host | untested |
| Copilot-only host | untested |

Do not imply support for untested platform combinations.
