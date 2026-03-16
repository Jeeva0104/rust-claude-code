#!/usr/bin/env bash
# rust-claude-code installer
# Usage: ./install.sh [rust|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.claude/rules"

echo "=== rust-claude-code installer ==="

# Create target directory
mkdir -p "${TARGET_DIR}"

# Install common rules
echo "Installing common rules..."
cp "${SCRIPT_DIR}/rules/common/"*.md "${TARGET_DIR}/"

# Install Rust rules
echo "Installing Rust rules..."
cp "${SCRIPT_DIR}/rules/rust/"*.md "${TARGET_DIR}/"

echo "=== Installation complete ==="
echo "Installed to: ${TARGET_DIR}"
echo ""
echo "Files installed:"
ls -la "${TARGET_DIR}/"
