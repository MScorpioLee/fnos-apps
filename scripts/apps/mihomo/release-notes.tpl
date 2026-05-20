自动构建的 fnOS 安装包

- 基于 [Mihomo v${VERSION}](https://github.com/MetaCubeX/mihomo/releases/tag/v${VERSION}) (Clash.Meta 内核)
- Dashboard: [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) (gh-pages 最新)
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT} (管理 + Dashboard), 7890 (HTTP+SOCKS5 混合代理)${REVISION_NOTE}
- 默认已开启 LAN 访问 (allow-lan) 与 GeoIP/GeoSite CDN 自动更新
- TUN 模式默认关闭，可在 dashboard 启用（安装时已自动 setcap 授予 CAP_NET_ADMIN）
${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
