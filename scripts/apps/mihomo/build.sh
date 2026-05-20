#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Mihomo ${VERSION} for ${TARBALL_ARCH} (with MetaCubeXD dashboard)"

# Step 1: mihomo binary (gzip-compressed single binary)
MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/v${VERSION}/mihomo-linux-${TARBALL_ARCH}-v${VERSION}.gz"
echo "Downloading mihomo: $MIHOMO_URL"
curl -fL -o mihomo.gz "$MIHOMO_URL"

# Step 2: MetaCubeXD dashboard (static SPA, gh-pages branch snapshot)
METACUBEXD_URL="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"
echo "Downloading metacubexd: $METACUBEXD_URL"
curl -fL -o metacubexd.zip "$METACUBEXD_URL"

# Step 3: Assemble app_root/
mkdir -p app_root/bin app_root/ui app_root/metacubexd

# mihomo binary
gunzip -c mihomo.gz > app_root/mihomo
chmod +x app_root/mihomo

# metacubexd static files (gh-pages archive root: metacubexd-gh-pages/)
unzip -q metacubexd.zip
[ ! -d "metacubexd-gh-pages" ] && { echo "metacubexd-gh-pages directory not found" >&2; exit 1; }
cp -a metacubexd-gh-pages/. app_root/metacubexd/

# fnOS framework files
cp apps/mihomo/fnos/bin/mihomo-server app_root/bin/mihomo-server
chmod +x app_root/bin/mihomo-server
cp -a apps/mihomo/fnos/ui/* app_root/ui/ 2>/dev/null || true

# Package
cd app_root
tar -czf ../app.tgz .
echo "==> app.tgz built: $(du -h ../app.tgz | cut -f1)"
