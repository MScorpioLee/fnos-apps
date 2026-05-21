## 2026-05-21

- 【修复】Docker 镜像拉取失败问题 (issue #139)
  - 上游 ghcr.io/ente-io/server 不发布 semver 标签，改为 `:latest` 滚动跟踪
  - 更新 get-latest-version.sh：版本号改为日期戳格式，准确反映滚动更新特性
  - 更新安装向导提示：明确镜像加速器仅对 docker.io 生效，ghcr.io 需直接连接
  - 修复 release-notes.tpl 中指向 GitHub Release 的链接格式

## 2026-03-03

- 首次发布
- 内置 PostgreSQL 和 MinIO 依赖容器
