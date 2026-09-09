#!/usr/bin/env bash
# Fast test runner for local development and agent workflows.
# Runs key guards and @smoke tests in seconds without running the 1,296-test suite.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}==> 1. Checking version parity...${NC}"
BASH_VER=$(grep -m1 'AGTOOSA_VERSION=' agtoosa.sh | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
PS_VER=$(grep -m1 'AGTOOSA_VERSION\s*=' agtoosa.ps1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
NPM_VER=$(grep -m1 '"version"' packaging/npm/package.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [ "$BASH_VER" != "$PS_VER" ] || [ "$BASH_VER" != "$NPM_VER" ]; then
  echo -e "${RED}❌ Version mismatch: bash=$BASH_VER ps1=$PS_VER npm=$NPM_VER${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Version parity passed (v${BASH_VER})${NC}"

echo -e "${CYAN}==> 2. Validating template completeness...${NC}"
MISSING=0
while IFS= read -r f; do
  if [[ ! -f "template/$f" ]]; then
    echo -e "${RED}❌ Missing: template/$f${NC}"
    MISSING=$((MISSING + 1))
  fi
done < <(bash agtoosa.sh --list-template-files)

if [[ "$MISSING" -gt 0 ]]; then
  echo -e "${RED}🔥 Total missing template files: $MISSING${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Template files verified${NC}"

echo -e "${CYAN}==> 3. Running Product Truth contract validation...${NC}"
if command -v python3 >/dev/null 2>&1 && [[ -f "data/contracts/product-truth-v1.json" ]]; then
  python3 scripts/product-truth.py check \
    --root . \
    --contract data/contracts/product-truth-v1.json \
    --as-of 2026-07-14
  python3 scripts/product-truth.py render --check \
    --root . \
    --contract data/contracts/product-truth-v1.json \
    --as-of 2026-07-14
  bats tests/product-truth.bats
  echo -e "${GREEN}✅ Product Truth passed${NC}"
fi

echo -e "${CYAN}==> 4. Running Generator Smoke Tests...${NC}"
bats tests/agtoosa.bats -f '@smoke BCL|PN|WP2|ACC|NET|PSP|CORE'

echo ""
echo -e "${GREEN}🎉 All fast checks and smoke tests passed!${NC}"
