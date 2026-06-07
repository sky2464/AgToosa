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

detect_platform() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)
      echo "darwin"
      ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # Check for WSL2
        if grep -qi "microsoft\|wsl" /proc/version 2>/dev/null || uname -r | grep -qi "microsoft"; then
          echo "windows-wsl2"
        elif grep -qi "ubuntu\|debian" /etc/os-release; then
          echo "linux-ubuntu"
        elif grep -qi "fedora\|rhel\|centos" /etc/os-release; then
          echo "linux-fedora"
        else
          echo "linux-generic"
        fi
      else
        echo "linux-generic"
      fi
      ;;
    *)
      echo "unsupported"
      ;;
  esac
}

print_install_guide() {
  local missing="$1"
  local platform="$2"

  case "$platform" in
    darwin)
      echo "Missing: $missing"
      echo "To install on macOS, run:"
      echo "  brew install $missing"
      echo "If Git or compilers are missing, install Apple Command Line Tools:"
      echo "  xcode-select --install"
      echo "If your default Bash is too old, install a newer Bash:"
      echo "  brew install bash"
      ;;
    linux-ubuntu)
      echo "Missing: $missing"
      echo "To install on Ubuntu/Debian, run:"
      echo "  sudo apt-get update && sudo apt-get install -y $missing"
      ;;
    linux-fedora)
      echo "Missing: $missing"
      echo "To install on Fedora/RHEL, run:"
      echo "  sudo dnf install -y $missing"
      ;;
    linux-generic)
      echo "Missing: $missing"
      echo "Please install $missing using your system package manager."
      echo "Examples:"
      echo "  Ubuntu/Debian: sudo apt-get install -y $missing"
      echo "  Fedora/RHEL: sudo dnf install -y $missing"
      echo "  Alpine: apk add $missing"
      ;;
    windows-wsl2)
      echo "Missing: $missing (in WSL2)"
      echo "To install inside WSL2, run:"
      echo "  sudo apt-get update && sudo apt-get install -y $missing"
      ;;
    *)
      echo "Missing: $missing"
      echo "Please install $missing using your system package manager."
      ;;
  esac
}

check_dependencies() {
  local platform
  platform="$(detect_platform)"

  if [[ "$platform" == "unsupported" ]]; then
    echo "Error: Unsupported operating system. AgToosa currently supports macOS, Linux, and WSL2." >&2
    echo "Detected: $(uname -s)" >&2
    return 1
  fi

  local missing_tools=()

  # Check bash (4.0+)
  if ! command -v bash &>/dev/null; then
    missing_tools+=("bash")
  else
    local bash_version
    bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    if [[ -z "$bash_version" ]]; then
      # Try alternative parsing
      bash_version=$(bash -c 'echo ${BASH_VERSINFO[0]}')
    fi
    if [[ -z "$bash_version" ]] || [[ $(echo "$bash_version" | cut -d. -f1) -lt 4 ]]; then
      echo "Warning: bash version ${bash_version:-unknown} detected. bash 4.0+ recommended." >&2
    fi
  fi

  # Check git
  if ! command -v git &>/dev/null; then
    missing_tools+=("git")
  fi

  # Check curl
  if ! command -v curl &>/dev/null; then
    missing_tools+=("curl")
  fi

  # Check tar
  if ! command -v tar &>/dev/null; then
    missing_tools+=("tar")
  fi

  # Report missing tools
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo "Error: Missing required tool(s):" >&2
    for tool in "${missing_tools[@]}"; do
      echo "" >&2
      print_install_guide "$tool" "$platform" >&2
    done
    echo "" >&2
    return 1
  fi

  return 0
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

# Check dependencies before attempting download
echo "Checking system dependencies..."
if ! check_dependencies; then
  exit 1
fi

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
