#!/usr/bin/env bash
set -euo pipefail

# AgToosa one-time bootstrap installer.
# Downloads the full repository payload (template + lib + scripts)
# and executes agtoosa.sh from the extracted directory.

REPO_OWNER="sky2464"
REPO_NAME="AgToosa"
REF="main"
KEEP_WORKDIR=false
LOCAL_ARCHIVE=""

usage() {
  cat <<'EOF'
Usage:
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) [options] [-- agtoosa_args...]

Bootstrap options:
  --ref <git-ref>   Git ref to download (default: main, recommended: vX.Y.Z tag)
  --archive <path>  Use a local .tar.gz archive instead of downloading from GitHub
  --keep            Keep extracted working directory for debugging
  -h, --help        Show this help message

Examples:
  # Recommended: pin a release tag
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z

  # Run with generator flags
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref vX.Y.Z -- --dry-run

  # Pass through common generator flags
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) -- --version
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
    --archive)
      [[ $# -lt 2 ]] && { echo "Error: --archive requires a value" >&2; exit 1; }
      LOCAL_ARCHIVE="$2"
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

build_archive_url() {
  local kind="$1"
  echo "https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/${kind}/${REF}.tar.gz"
}

download_archive() {
  local primary_url
  primary_url="$(build_archive_url "$ARCHIVE_KIND")"

  echo "Requested ref: ${REF}"
  echo "Primary archive URL: ${primary_url}"

  if curl -fsSL "$primary_url" -o "$ARCHIVE_PATH"; then
    ARCHIVE_URL="$primary_url"
    return 0
  fi

  if [[ "$ARCHIVE_KIND" == "tags" ]]; then
    local fallback_url
    fallback_url="$(build_archive_url "heads")"
    echo "Primary download failed; trying branch fallback: ${fallback_url}" >&2
    if curl -fsSL "$fallback_url" -o "$ARCHIVE_PATH"; then
      ARCHIVE_URL="$fallback_url"
      return 0
    fi
  fi

  echo "Error: Unable to download AgToosa archive for ref '${REF}'." >&2
  echo "Tried: ${primary_url}" >&2
  if [[ "$ARCHIVE_KIND" == "tags" ]]; then
    echo "Also tried branch fallback for '${REF}'." >&2
  fi
  echo "Tip: use a valid release tag (for example vX.Y.Z) or an existing branch name." >&2
  return 1
}

cleanup() {
  if [[ "$KEEP_WORKDIR" == false ]]; then
    rm -rf "$WORKDIR"
  else
    echo "Kept bootstrap workspace: $WORKDIR"
  fi
}
trap cleanup EXIT

echo "Downloading AgToosa (${REF})..."
if [[ -n "$LOCAL_ARCHIVE" ]]; then
  if [[ ! -f "$LOCAL_ARCHIVE" ]]; then
    echo "Error: --archive file not found: ${LOCAL_ARCHIVE}" >&2
    exit 1
  fi
  echo "Using local archive: ${LOCAL_ARCHIVE}"
  cp "$LOCAL_ARCHIVE" "$ARCHIVE_PATH"
  ARCHIVE_URL="local:${LOCAL_ARCHIVE}"
else
  download_archive
fi

echo "Extracting..."
tar -xzf "$ARCHIVE_PATH" -C "$WORKDIR"

SRC_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
if [[ -z "$SRC_DIR" || ! -f "$SRC_DIR/agtoosa.sh" ]]; then
  echo "Error: Extracted archive does not contain agtoosa.sh" >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR/template" || ! -d "$SRC_DIR/lib" ]]; then
  echo "Error: Extracted archive is incomplete. Required directories template/ and lib/ were not found." >&2
  echo "Archive source: ${ARCHIVE_URL}" >&2
  exit 1
fi

chmod +x "$SRC_DIR/agtoosa.sh"
exec bash "$SRC_DIR/agtoosa.sh" "${forwarded_args[@]}"
