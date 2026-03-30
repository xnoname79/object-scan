#!/bin/bash
# Build ObjectScan IPA via CLI (no Xcode UI needed)
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

SCHEME="ObjectScan"
ARCHIVE_PATH="build/ObjectScan.xcarchive"
EXPORT_PATH="build/export"

echo "=== Building ObjectScan ==="

# Clean previous build
rm -rf build/

# Step 1: Build archive (signed)
echo "[1/2] Archiving..."
xcodebuild archive \
    -project ObjectScan.xcodeproj \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -configuration Release \
    DEVELOPMENT_TEAM="73G9VJKFH2" \
    CODE_SIGN_STYLE=Automatic \
    | tail -20

echo ""

# Step 2: Export IPA
echo "[2/2] Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist ExportOptions.plist \
    | tail -10

echo ""
echo "=== Build complete ==="
echo "IPA: $EXPORT_PATH/ObjectScan.ipa"
