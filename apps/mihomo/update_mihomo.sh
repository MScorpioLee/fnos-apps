#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="mihomo"
APP_DISPLAY_NAME="Mihomo"
APP_VERSION_VAR="MIHOMO_VERSION"
APP_VERSION="${MIHOMO_VERSION:-latest}"
APP_DEPS=(curl unzip gunzip tar)
APP_FPK_PREFIX="mihomo"
APP_HELP_VERSION_EXAMPLE="1.19.25"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.19.25       # 指定 mihomo 版本，x86 架构
  $0 1.19.25                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.19.25"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local mihomo_url="https://github.com/MetaCubeX/mihomo/releases/download/v${APP_VERSION}/mihomo-linux-${TARBALL_ARCH}-v${APP_VERSION}.gz"
    local metacubexd_url="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

    info "下载 mihomo ($ARCH): $mihomo_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/mihomo.gz" "$mihomo_url" || error "下载 mihomo 失败"
    info "已下载 mihomo: $(du -h "$WORK_DIR/mihomo.gz" | cut -f1)"

    info "下载 metacubexd dashboard: $metacubexd_url"
    curl -L -f -o "$WORK_DIR/metacubexd.zip" "$metacubexd_url" || error "下载 metacubexd 失败"
    info "已下载 metacubexd: $(du -h "$WORK_DIR/metacubexd.zip" | cut -f1)"
}

app_build_app_tgz() {
    info "解压制品..."
    cd "$WORK_DIR"

    # mihomo 二进制
    gunzip -c mihomo.gz > mihomo
    chmod +x mihomo

    # metacubexd 静态文件（gh-pages 归档顶层目录为 metacubexd-gh-pages）
    unzip -q metacubexd.zip
    [ ! -d "metacubexd-gh-pages" ] && error "未找到 metacubexd-gh-pages 目录"

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui" "$dst/metacubexd"

    # mihomo 二进制
    cp "$WORK_DIR/mihomo" "$dst/mihomo"
    chmod +x "$dst/mihomo"

    # metacubexd 静态文件
    cp -a "$WORK_DIR/metacubexd-gh-pages/." "$dst/metacubexd/"

    # fnOS 框架文件
    cp "$PKG_DIR/bin/mihomo-server" "$dst/bin/mihomo-server"
    chmod +x "$dst/bin/mihomo-server"

    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
