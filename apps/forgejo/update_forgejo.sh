#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="forgejo"
APP_DISPLAY_NAME="Forgejo"
APP_VERSION_VAR="FORGEJO_VERSION"
APP_VERSION="${FORGEJO_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="forgejo"
APP_HELP_VERSION_EXAMPLE="9.0.4"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64" ;;
        arm) TARBALL_ARCH="arm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 9.0.4       # 指定版本，x86 架构
  $0 9.0.4                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://codeberg.org/api/v1/repos/forgejo/forgejo/releases/latest" 2>/dev/null | \
        jq -r '.tag_name' | sed 's/^v//')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 9.0.4"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://codeberg.org/forgejo/forgejo/releases/download/v${APP_VERSION}/forgejo-${APP_VERSION}-linux-${TARBALL_ARCH}"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/forgejo" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/forgejo" | cut -f1)"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    cp "$WORK_DIR/forgejo" "$dst/forgejo"
    chmod +x "$dst/forgejo"

    cp "$PKG_DIR/bin/forgejo-server" "$dst/bin/forgejo-server"
    chmod +x "$dst/bin/forgejo-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
