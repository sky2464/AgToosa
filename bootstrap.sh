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
EXPECTED_SHA256=""

usage() {
  cat <<'EOF'
Usage:
  bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) [options] [-- agtoosa_args...]

Bootstrap options:
  --ref <git-ref>   Git ref to download (default: main, recommended: vX.Y.Z tag)
  --archive <path>  Use a local .tar.gz archive instead of downloading from GitHub
  --sha256 <hex>    Verify the downloaded archive against this SHA-256 before running
  --keep            Keep extracted working directory for debugging
  -h, --help        Show this help message

Pinned tags fail closed: if the tag archive cannot be downloaded, bootstrap
aborts instead of silently falling back to a branch of the same name.

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
    --sha256)
      [[ $# -lt 2 ]] && { echo "Error: --sha256 requires a value" >&2; exit 1; }
      EXPECTED_SHA256="$2"
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

  # Pinned tags fail closed. Silently substituting a branch of the same name
  # would defeat the pin (a moving branch is not the artifact the user asked for).
  echo "Error: Unable to download AgToosa archive for ref '${REF}'." >&2
  echo "Tried: ${primary_url}" >&2
  if [[ "$ARCHIVE_KIND" == "tags" ]]; then
    echo "Pinned tag downloads do not fall back to branches." >&2
    echo "Check the tag name against https://github.com/${REPO_OWNER}/${REPO_NAME}/releases" >&2
    echo "or pass an explicit branch name (e.g. --ref main) if you want branch content." >&2
  else
    echo "Tip: use a valid release tag (for example vX.Y.Z) or an existing branch name." >&2
  fi
  return 1
}

# Reject archives whose member list contains absolute paths or '..' segments
# BEFORE extraction — post-extract checks cannot undo a tar slip.
assert_safe_archive() {
  local archive="$1"
  local entries entry
  if ! entries=$(tar -tzf "$archive" 2>/dev/null); then
    echo "Error: Unable to read archive member list (corrupt archive?)." >&2
    return 1
  fi
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if [[ "$entry" == /* ]]; then
      echo "Error: Archive contains absolute path member: $entry" >&2
      return 1
    fi
    case "/$entry/" in
      */../*)
        echo "Error: Archive contains path traversal member: $entry" >&2
        return 1
        ;;
    esac
  done <<< "$entries"
  return 0
}

verify_archive_sha256() {
  local archive="$1" expected="$2"
  [[ -z "$expected" ]] && return 0
  local actual
  if command -v sha256sum &>/dev/null; then
    actual=$(sha256sum "$archive" | awk '{print $1}')
  elif command -v shasum &>/dev/null; then
    actual=$(shasum -a 256 "$archive" | awk '{print $1}')
  else
    echo "Error: --sha256 given but neither sha256sum nor shasum is available." >&2
    return 1
  fi
  if [[ "$actual" != "$expected" ]]; then
    echo "Error: Archive SHA-256 mismatch!" >&2
    echo "  Expected: $expected" >&2
    echo "  Got:      $actual" >&2
    return 1
  fi
  echo "SHA-256 verified."
  return 0
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

if ! verify_archive_sha256 "$ARCHIVE_PATH" "$EXPECTED_SHA256"; then
  exit 1
fi

if ! assert_safe_archive "$ARCHIVE_PATH"; then
  exit 1
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
