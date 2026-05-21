#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="metatube"
APP_DISPLAY_NAME="MetaTube"
APP_VERSION_VAR="METATUBE_VERSION"
APP_VERSION="${METATUBE_VERSION:-latest}"
APP_DEPS=(curl unzip)
APP_FPK_PREFIX="metatube"
APP_HELP_VERSION_EXAMPLE="1.4.0"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.4.0       # 指定版本，x86 架构
  $0 1.4.0                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    # Binaries published to metatube-server-releases (not the SDK repo)
    tag=$(curl -sL "https://api.github.com/repos/metatube-community/metatube-server-releases/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.4.0"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/metatube-community/metatube-server-releases/releases/download/v${APP_VERSION}/metatube-server-linux-${TARBALL_ARCH}.zip"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/metatube-server.zip" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/metatube-server.zip" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 metatube-server..."
    cd "$WORK_DIR"
    mkdir -p extract
    unzip -o -q metatube-server.zip -d extract

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    # Single-binary zip with arch-suffixed name (e.g. metatube-server-linux-amd64).
    # Find and rename to canonical name expected by the wrapper.
    local extracted_bin
    extracted_bin=$(find extract -maxdepth 1 -name "metatube-server-linux-*" -type f | head -1)
    [ -n "$extracted_bin" ] || error "未找到 metatube-server 二进制"
    cp "$extracted_bin" "$dst/metatube-server"
    chmod +x "$dst/metatube-server"

    cp "$PKG_DIR/bin/metatube-server" "$dst/bin/metatube-server"
    chmod +x "$dst/bin/metatube-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
