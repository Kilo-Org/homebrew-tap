#!/bin/bash
set -e

VERSION="$1"
if [ -z "$VERSION" ]; then
    echo "❌ Error: Version parameter is required"
    exit 1
fi

FORMULA_FILE="kilocode.rb"
DOWNLOAD_URL="https://registry.npmjs.org/@kilocode/cli/-/cli-${VERSION}.tgz"

echo "🔍 Checking version $VERSION..."

# Validate version format (basic semver check)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "❌ Error: Invalid version format. Expected format: X.Y.Z (e.g., 1.0.14)"
    exit 1
fi

# Check if the npm package version exists
echo "📦 Validating package exists on npm registry..."
if ! curl -sf "https://registry.npmjs.org/@kilocode/cli/$VERSION" > /dev/null 2>&1; then
    echo "❌ Error: Version $VERSION not found on npm registry"
    echo "   Please verify the version exists at: https://www.npmjs.com/package/@kilocode/cli"
    exit 1
fi

# Get current version from formula
CURRENT_VERSION=$(grep 'version "' "$FORMULA_FILE" | sed 's/.*version "\(.*\)".*/\1/')
echo "📋 Current formula version: $CURRENT_VERSION"
echo "🎯 Requested version: $VERSION"

# Check if versions are the same
if [ "$CURRENT_VERSION" = "$VERSION" ]; then
    echo "✅ Formula is already at version $VERSION - no update needed"
    exit 0
fi

# Version comparison for upgrade-only policy
compare_versions() {
    local ver1="$1"
    local ver2="$2"
    
    # Split versions into arrays
    IFS='.' read -ra V1 <<< "$ver1"
    IFS='.' read -ra V2 <<< "$ver2"
    
    # Compare major, minor, patch
    for i in 0 1 2; do
        if [ "${V1[i]:-0}" -gt "${V2[i]:-0}" ]; then
            return 0  # ver1 > ver2
        elif [ "${V1[i]:-0}" -lt "${V2[i]:-0}" ]; then
            return 1  # ver1 < ver2
        fi
    done
    return 1  # versions are equal
}

# Only allow upgrades
if ! compare_versions "$VERSION" "$CURRENT_VERSION"; then
    echo "❌ Error: Downgrade not allowed. Requested version $VERSION is not newer than current version $CURRENT_VERSION"
    echo "   This workflow only supports upgrades to newer versions"
    exit 1
fi

echo "⬆️ Upgrading from $CURRENT_VERSION to $VERSION"

# Download the package to calculate SHA256
echo "⬇️ Downloading package to calculate SHA256..."
if ! curl -sL "$DOWNLOAD_URL" -o "/tmp/kilocode-${VERSION}.tgz"; then
    echo "❌ Error: Failed to download package from $DOWNLOAD_URL"
    exit 1
fi

echo "🔐 Calculating SHA256 checksum..."
SHA256=$(shasum -a 256 "/tmp/kilocode-${VERSION}.tgz" | cut -d' ' -f1)
echo "📋 SHA256: $SHA256"

# Clean up downloaded file
rm "/tmp/kilocode-${VERSION}.tgz"

# Update the formula file
echo "📝 Updating formula file..."
sed -i.bak "s/version \".*\"/version \"$VERSION\"/" "$FORMULA_FILE"
sed -i.bak "s|url \".*\"|url \"$DOWNLOAD_URL\"|" "$FORMULA_FILE"
sed -i.bak "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$FORMULA_FILE"

# Remove backup file
rm "${FORMULA_FILE}.bak"

echo "✅ Formula updated successfully!"
echo "📋 Changes made:"
git diff "$FORMULA_FILE"