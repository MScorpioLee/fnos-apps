## 2026-05-20

- 首次发布
- mihomo (Clash.Meta) 内核 + MetaCubeXD dashboard 一体化打包
- 默认管理端口 9097（避开 9090 与现有 Prometheus 冲突）
- 默认混合代理端口 7890（HTTP + SOCKS5），暴露至 LAN
- 安装时通过 setcap 授予 CAP_NET_ADMIN/CAP_NET_RAW/CAP_NET_BIND_SERVICE，支持 TUN 模式
- 默认通过 ghfast.top CDN 自动下载 GeoIP/GeoSite 数据库
- 首次启动自动从 hub.conversun.com CDN 拉取生产级配置模板，含完整策略组 + skk.moe rule-providers + 分流规则；自动注入 fnOS 端口/dashboard 设置，用户只需粘贴自己的代理节点即可使用
- 每次启动强制注入框架字段（external-controller / external-ui），防止用户在 dashboard 改坏后 dashboard 进不去
- 启动前 mihomo -t 预校验，配置错误时自动降级到 minimal fallback 并备份原配置（保证 dashboard 永远可访问）
- README 加「故障排查」章节列出三层防线 + 字段管理边界
