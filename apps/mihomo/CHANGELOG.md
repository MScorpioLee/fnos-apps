## 2026-05-20

- 首次发布
- mihomo (Clash.Meta) 内核 + MetaCubeXD dashboard 一体化打包
- 默认管理端口 9097 (避开 9090 与现有 Prometheus 冲突)
- 默认混合代理端口 7890 (HTTP + SOCKS5), 暴露至 LAN
- 安装时通过 setcap 授予 CAP_NET_ADMIN / CAP_NET_RAW / CAP_NET_BIND_SERVICE, 支持 TUN 模式
- 零外部依赖: minimal default 配置硬编码在 bin/mihomo-server, 不依赖任何远程模板 / CDN
- **关键修复**: 注入 fnOS framework guard JS 到 metacubexd index.html, 拦截 dashboard 的 PUT /configs 请求,
  自动改写 payload 中的 external-controller / external-ui 为 fnOS 必需值。
  解决用户在 dashboard "Update Config from URL" 加载自己的订阅模板时, mihomo 切换到
  上游 external-controller (如 127.0.0.1:9090) 导致 dashboard 失联 / 看似 cancel 的问题。
  现在用户可在 dashboard 直接加载自己的 Clash 订阅 URL, 立即生效。
- 三层故障防线: 每次启动强制注入框架字段 + mihomo -t 预校验 + 验证失败自动降级到 minimal default
