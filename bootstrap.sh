#!/usr/bin/env bash
set -euo pipefail

# AgToosa one-time bootstrap installer.
# Downloads the full repository payload (template + lib + scripts)
# and executes agtoosa.sh from the extracted directory.

REPO_OWNER="sky2464"
REPO_NAME="AgToosa"
REF="main"
KEEP_WORKDIR=false

usage() {
  cat <<'EOF'
Usage:
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) [options] [-- agtoosa_args...]

Bootstrap options:
  --ref <git-ref>   Git ref to download (default: main, recommended: vX.Y.Z tag)
  --keep            Keep extracted working directory for debugging
  -h, --help        Show this help message

Examples:
  # Recommended: pin a release tag
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v2.6.0

  # Run with generator flags
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v2.6.0 -- --dry-run
EOF
}

forwarded_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      [[ $# -lt 2 ]] && { echo "Error: --ref requires a value" >&2; exit 1; }
      REF="$2"
      shift 2
      ;;
    --keep)
      KEEP_WORKDIR=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      forwarded_args+=("$@")
      break
      ;;
    *)
      forwarded_args+=("$1")
      shift
      ;;
  esac
done

if [[ "$REF" == "main" || "$REF" == "master" ]]; then
  ARCHIVE_KIND="heads"
else
  ARCHIVE_KIND="tags"
fi

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/${ARCHIVE_KIND}/${REF}.tar.gz"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/agtoosa-bootstrap.XXXXXX")"
ARCHIVE_PATH="${WORKDIR}/agtoosa.tar.gz"

cleanup() {
  if [[ "$KEEP_WORKDIR" == false ]]; then
    rm -rf "$WORKDIR"
  else
    echo "Kept bootstrap workspace: $WORKDIR"
  fi
}
trap cleanup EXIT

echo "Downloading AgToosa (${REF})..."
curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"

echo "Extracting..."
tar -xzf "$ARCHIVE_PATH" -C "$WORKDIR"

SRC_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
if [[ -z "$SRC_DIR" || ! -f "$SRC_DIR/agtoosa.sh" ]]; then
  echo "Error: Extracted archive does not contain agtoosa.sh" >&2
  exit 1
fi

chmod +x "$SRC_DIR/agtoosa.sh"
exec bash "$SRC_DIR/agtoosa.sh" "${forwarded_args[@]}"
