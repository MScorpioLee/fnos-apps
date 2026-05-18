## 2026-05-18

- initial release: Visor fpk 打包
- 基于上游 [dromara/orion-visor](https://github.com/dromara/orion-visor) v2.5.7
- 6 服务 docker 栈 (ui + service + mysql + redis + influxdb + guacd), 仅暴露 1081 端口
- 镜像源: `lijiahangmax/orion-visor-*` (Docker Hub 多架构)
- 内部服务密码 (mysql/redis/influxdb/secret) 由 `service_postinst` 自动生成随机值, 存储在 `${TRIM_PKGVAR}/CREDENTIALS.txt`
- 默认登录: `admin/admin` (登录后必须立即修改)
