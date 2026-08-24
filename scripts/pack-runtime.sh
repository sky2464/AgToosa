#!/usr/bin/env bash
# DEV-150 — Deterministic corporate/EDR-safe minimal runtime pack.
# Builds agtoosa-runtime-vX.Y.Z.tar.gz containing exactly agtoosa.sh,
# agtoosa.ps1, lib/, and template/ at the archive root — no tests, fixtures,
# or maintainer docs.
set -euo pipefail

ROOT_DIR="${AGTOOSA_PACK_RUNTIME_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OUTPUT_DIR="."

usage() {
  cat <<'EOF'
Usage:
  scripts/pack-runtime.sh [--root DIR] [--output-dir DIR]

Builds a minimal corporate/EDR-safe runtime tarball:
  agtoosa-runtime-vX.Y.Z.tar.gz containing exactly agtoosa.sh, agtoosa.ps1,
  lib/, and template/ at the archive root.

Options:
  --root DIR        Source repository root (default: repo containing this script)
  --output-dir DIR  Directory to write the tarball into (default: current directory)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      [[ $# -lt 2 ]] && { echo "Error: --root requires a directory" >&2; exit 2; }
      ROOT_DIR="$2"
      shift 2
      ;;
    --output-dir)
      [[ $# -lt 2 ]] && { echo "Error: --output-dir requires a directory" >&2; exit 2; }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

for member in agtoosa.sh agtoosa.ps1 lib template; do
  [ -e "$ROOT_DIR/$member" ] || { echo "Error: missing $member in $ROOT_DIR" >&2; exit 1; }
done

VERSION="$(grep -m1 '^AGTOOSA_VERSION=' "$ROOT_DIR/agtoosa.sh" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$VERSION" ] || { echo "Error: could not read AGTOOSA_VERSION from $ROOT_DIR/agtoosa.sh" >&2; exit 1; }

mkdir -p "$OUTPUT_DIR"
TARBALL="$OUTPUT_DIR/agtoosa-runtime-v${VERSION}.tar.gz"

# Fixed, alphabetically sorted member order for deterministic output across runs.
tar -czf "$TARBALL" -C "$ROOT_DIR" agtoosa.ps1 agtoosa.sh lib template

echo "Wrote $TARBALL"
