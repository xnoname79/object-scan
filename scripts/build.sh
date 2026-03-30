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

# Step 1: Build archive
echo "[1/2] Archiving..."
xcodebuild archive \
    -project ObjectScan.xcodeproj \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -configuration Release \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_ALLOWED=NO \
    | tail -20

echo ""

# Step 2: If you have signing set up, export IPA:
# xcodebuild -exportArchive \
#     -archivePath "$ARCHIVE_PATH" \
#     -exportPath "$EXPORT_PATH" \
#     -exportOptionsPlist ExportOptions.plist

echo "=== Archive complete ==="
echo "Archive: $ARCHIVE_PATH"
echo ""
echo "To export signed IPA, set your DEVELOPMENT_TEAM in project.yml,"
echo "run ./scripts/setup.sh again, then uncomment the export step in this script."
