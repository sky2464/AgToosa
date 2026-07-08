#!/usr/bin/env bash

# ── AgToosa: optional signed provenance (DEV-054 / ADR-011) ─────
# Soft-warn minisign verification. Never fails the caller.
# Sourced by lib/registry.sh. Bootstrap keeps a mirrored copy.

# Resolve the minisign public key path.
# Order: AGTOOSA_MINISIGN_PUBKEY → SCRIPT_DIR/docs/security/agtoosa.minisign.pub
resolve_minisign_pubkey() {
  if [[ -n "${AGTOOSA_MINISIGN_PUBKEY:-}" && -f "${AGTOOSA_MINISIGN_PUBKEY}" ]]; then
    printf '%s' "${AGTOOSA_MINISIGN_PUBKEY}"
    return 0
  fi
  if [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/docs/security/agtoosa.minisign.pub" ]]; then
    printf '%s' "${SCRIPT_DIR}/docs/security/agtoosa.minisign.pub"
    return 0
  fi
  if [[ -f "docs/security/agtoosa.minisign.pub" ]]; then
    printf '%s' "docs/security/agtoosa.minisign.pub"
    return 0
  fi
  return 1
}

# Soft-warn minisign verification.
# Args: artifact_path [sig_path]
# If sig_path is omitted, uses artifact_path.minisig when present.
# Returns 0 always. Emits warnings on failure / missing tool / missing pubkey.
soft_verify_minisign() {
  local artifact="$1"
  local sig_path="${2:-}"

  if [[ -z "$sig_path" ]]; then
    if [[ -f "${artifact}.minisig" ]]; then
      sig_path="${artifact}.minisig"
    else
      return 0
    fi
  fi

  [[ -f "$artifact" ]] || return 0
  [[ -f "$sig_path" ]] || return 0

  echo "Optional minisign signature found; verifying (soft-warn)..."

  local pubkey=""
  if ! pubkey=$(resolve_minisign_pubkey); then
    echo "⚠️  minisign: public key not found (set AGTOOSA_MINISIGN_PUBKEY or ship docs/security/agtoosa.minisign.pub). Continuing without signature verification." >&2
    return 0
  fi

  if ! command -v minisign &>/dev/null; then
    echo "⚠️  minisign: binary not found on PATH. Continuing without signature verification." >&2
    return 0
  fi

  if minisign -Vm "$artifact" -x "$sig_path" -p "$pubkey" >/dev/null 2>&1; then
    echo "✅ minisign signature verified."
  else
    echo "⚠️  minisign: signature verification failed for $(basename "$artifact"). Continuing because soft-warn mode is enabled (SHA-256 / verified gates still apply)." >&2
  fi
  return 0
}
