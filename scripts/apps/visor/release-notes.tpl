自动构建的 fnOS 安装包

- 基于 [Orion Visor v${VERSION}](https://github.com/dromara/orion-visor/releases/tag/v${VERSION})
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}
- 部署模式: 6 服务 docker 栈 (ui + service + mysql + redis + influxdb + guacd)

**首次使用**:
1. 安装时选择 "API 主机地址" → 填飞牛 NAS 的 LAN IP (例如 192.168.1.100)。RDP/VNC/SSH 跳板功能依赖此地址
2. 等待 ~2-3 分钟首次启动 (镜像拉取 + 数据库初始化)
3. 访问 `http://your-nas-ip:${DEFAULT_PORT}` → **默认账号密码 `admin/admin`, 登录后请立即修改**
4. 内部服务凭证 (mysql/redis/influxdb) 自动生成随机值, 存储在 `${TRIM_PKGVAR}/CREDENTIALS.txt`

**⚠️ 资源要求**: 6 服务 docker 栈, **飞牛 NAS 4GB 内存以上推荐**。低配机型可能跑不起来。

**镜像源**: `lijiahangmax/orion-visor-*` (Docker Hub 多架构)。如拉取失败, 飞牛 NAS 设置里换 docker 加速源后重装。

${CHANGELOG}
**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
