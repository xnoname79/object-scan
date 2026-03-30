#!/bin/bash
# Run this on MacinCloud after cloning the repo
set -e

echo "=== ObjectScan Setup ==="

# 1. Check Xcode
echo "[1/3] Checking Xcode..."
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcode not found. Install via: xcode-select --install"
    exit 1
fi
xcodebuild -version

# 2. Install XcodeGen (generates .xcodeproj from project.yml)
echo "[2/3] Installing XcodeGen..."
if ! command -v xcodegen &> /dev/null; then
    brew install xcodegen
fi
echo "XcodeGen version: $(xcodegen --version)"

# 3. Generate Xcode project
echo "[3/3] Generating Xcode project..."
xcodegen generate

echo ""
echo "=== Setup complete! ==="
echo "Now run: ./scripts/build.sh"
