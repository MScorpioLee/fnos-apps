#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building MetaTube ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    TARBALL_ARCH="amd64"
    ;;
  arm64|aarch64)
    TARBALL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

# Upstream binaries are published to metatube-server-releases (not the SDK repo).
DOWNLOAD_URL="https://github.com/metatube-community/metatube-server-releases/releases/download/v${VERSION}/metatube-server-linux-${TARBALL_ARCH}.zip"
echo "Downloading: $DOWNLOAD_URL"
curl -fL -o metatube-server.zip "$DOWNLOAD_URL"

mkdir -p app_root/bin app_root/ui
unzip -o -q metatube-server.zip -d app_root

# The zip contains a single arch-suffixed binary (e.g. metatube-server-linux-amd64).
# Rename it to the canonical name expected by the wrapper script.
extracted_bin=$(find app_root -maxdepth 1 -name "metatube-server-linux-*" -type f | head -1)
[ -n "$extracted_bin" ] || { echo "metatube-server binary not found in zip" >&2; exit 1; }
mv "$extracted_bin" app_root/metatube-server
chmod +x app_root/metatube-server

# Copy fnOS-specific files
cp apps/metatube/fnos/bin/metatube-server app_root/bin/metatube-server
chmod +x app_root/bin/metatube-server
cp -a apps/metatube/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
