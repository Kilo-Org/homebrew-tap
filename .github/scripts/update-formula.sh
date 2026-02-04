#!/bin/bash
set -e

VERSION="$1"
if [ -z "$VERSION" ]; then
    echo "Error: Version parameter is required"
    exit 1
fi

FORMULA_FILE="kilocode.rb"
DOWNLOAD_URL="https://registry.npmjs.org/@kilocode/cli/-/cli-${VERSION}.tgz"

echo "Updating formula to version $VERSION"
echo "Download URL: $DOWNLOAD_URL"

# Download the package to calculate SHA256
echo "Downloading package to calculate SHA256..."
curl -sL "$DOWNLOAD_URL" -o "/tmp/kilocode-${VERSION}.tgz"
SHA256=$(shasum -a 256 "/tmp/kilocode-${VERSION}.tgz" | cut -d' ' -f1)
echo "Calculated SHA256: $SHA256"

# Update the formula file
echo "Updating formula file..."
sed -i.bak "s/version \".*\"/version \"$VERSION\"/" "$FORMULA_FILE"
sed -i.bak "s|url \".*\"|url \"$DOWNLOAD_URL\"|" "$FORMULA_FILE"
sed -i.bak "s/sha256 \".*\"/sha256 \"$SHA256\"/" "$FORMULA_FILE"

# Remove backup file
rm "${FORMULA_FILE}.bak"

echo "Formula updated successfully!"
echo "Changes made:"
git diff "$FORMULA_FILE"