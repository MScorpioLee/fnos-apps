# Mihomo for fnOS

[Mihomo](https://github.com/MetaCubeX/mihomo)（前 Clash.Meta）多协议代理内核，集成 [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) 可视化面板，打包为 fnOS 第三方应用。

## 功能特性

- **多协议代理**：Shadowsocks / V2Ray / Trojan / Hysteria2 / WireGuard / Tuic 等
- **可视化面板**：访问 `http://<NAS_IP>:9097/ui/` 管理代理节点、规则、连接
- **混合代理端口**：`7890/tcp`（HTTP + SOCKS5 同端口），默认监听 `0.0.0.0`，LAN 内任意设备可使用
- **TUN 模式**：默认关闭；可在 dashboard 启用，安装时已通过 `setcap` 授予所需 Linux capabilities
- **规则数据库自动更新**：GeoIP / GeoSite 通过 `ghfast.top` CDN 加速，每 24 小时自动更新
- **开箱即用的生产级配置模板**：首次启动自动拉取 conversun 自维护模板（完整策略组 + skk.moe rule-providers + 分流规则），用户只需在 dashboard 粘贴自己的订阅节点即可使用

## 端口分配

| 端口 | 协议 | 用途 |
|------|------|------|
| 9097 | TCP | 外部管理 API + MetaCubeXD dashboard |
| 7890 | TCP | HTTP + SOCKS5 混合代理 |
| 1053 | UDP/TCP (localhost) | 内部 DNS（TUN 模式下劫持 53 端口）|

## 首次使用

1. 安装完成后，在 fnOS 应用中心点击 Mihomo 图标，浏览器自动打开 `http://<NAS_IP>:9097/ui/`
2. 首次启动会自动从 CDN 下载配置模板（含完整策略组与分流规则），并注入 fnOS 必需的端口/dashboard 参数
3. dashboard 默认无 secret，可在「设置」中修改
4. **添加自己的代理节点**：dashboard → 「配置」→ 编辑 `config.yaml`，在 `proxies:` 字段下追加自己的节点（节点名建议带 🇭🇰/🇸🇬/🇼🇸/🇯🇵/🇺🇲 emoji 或 HK/SG/TW/JP/US 关键词，地区分组会自动按 `filter` 筛选）
5. 启用 TUN 模式（透明代理整个 NAS 出口流量）：dashboard →「设置」→ 开启 TUN

## 配置文件位置

```
${TRIM_PKGVAR}/config/config.yaml
```

## 配置模板

首次启动时会从下方 URL 下载并注入 fnOS 配置：

```
https://hub.conversun.com/https://raw.githubusercontent.com/conversun/SurgeRule/main/Custom_Clash.yaml
```

模板内置：

- 16 个策略组（Proxy / AI / Media / TikTok / Apple / GitHub / Google / Telegram / Tunnel / Crypto / PayPal / Stripe / Speedtest / Check / CDN / Final）
- 5 个地区 url-test 节点组（🇭🇰 HK / 🇸🇬 SG / 🇼🇸 TW / 🇯🇵 JP / 🇺🇲 US），按 emoji 或国别关键词自动筛选
- 完整 rule-providers（skk.moe + AWAvenue-Ads + blackmatrix7），覆盖广告拦截、流媒体、金融、CDN、域名分流等
- TUN + Sniffer + 完整 DNS（fake-ip + fallback-filter）

**手动更新模板**：dashboard → 「配置」→ 「Update Config from URL」→ 粘贴上述 URL

## Local Build

```bash
cd apps/mihomo
./update_mihomo.sh                  # 自动检测架构，拉取最新版
./update_mihomo.sh --arch arm       # 强制 ARM
./update_mihomo.sh 1.19.25          # 指定版本
```

## 故障排查（三层防线）

mihomo + dashboard 是强耦合体系，本应用通过分层降级保证用户永远不会失联：

### 第 1 层：mihomo 正常运行

用户通过 metacubexd dashboard (`http://<NAS_IP>:9097/ui/`) 控制一切：

- 看运行日志：dashboard → 「日志」页签
- 改订阅地址：dashboard → 「配置」→ 编辑 `proxy-providers.<name>.url`
- 加节点 / 改规则：dashboard → 「配置」→ 编辑 yaml
- 重新拉取模板：dashboard → 「配置」→ 「Update Config from URL」→ 粘贴 CDN URL

### 第 2 层：config.yaml 损坏 → 自动降级

每次启动时 `mihomo -t` 验证配置：

- 验证通过 → 正常启动
- 验证失败 → 备份原配置到 `config.failed-<timestamp>.yaml`，切换到 minimal fallback，**dashboard 仍可访问**
- fnOS 应用日志中会写明备份位置和恢复步骤

另外：用户在 dashboard 修改 `external-controller` 端口或 `external-ui` 路径后，下次启动会被强制还原为 fnOS 框架值，并在日志写 WARN（防止改坏后 dashboard 进不去）。

### 第 3 层：极端情况（minimal fallback 也挂）

- **fnOS 应用中心 → Mihomo → 查看日志**：所有 mihomo 启动错误都写在 `${TRIM_PKGVAR}/mihomo.log`
- **SSH / 文件管理器编辑**：`/vol*/apps/mihomo/var/config/config.yaml`
- **重置配置**：删掉 `config.yaml` 后重启应用，会自动重新下载模板

## 端口/字段管理边界

| 字段 | 谁管 | 说明 |
|------|------|------|
| `external-controller` 端口 | **fnOS 框架强制** | 每次启动还原为 `0.0.0.0:<manifest.service_port>` |
| `external-ui` 路径 | **fnOS 框架强制** | 每次启动还原为 `<APP_DIR>/metacubexd` |
| `secret` | **用户管理** | 首次启动为空，用户在 dashboard 自由设置 |
| `tun.enable` | **用户管理** | 模板首次注入时强制 `false`，后续保留用户设置 |
| `proxies` / `proxy-providers` / `rules` / 其他业务字段 | **用户管理** | mihomo dashboard 完全控制 |

## 上游版本管理

MetaCubeXD dashboard 始终拉取 `gh-pages` 分支最新快照，跟随 mihomo 内核版本一同打包发布。
