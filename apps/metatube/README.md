# MetaTube for fnOS

每日自动同步 [MetaTube 官方](https://github.com/metatube-community/metatube-sdk-go) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=metatube) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:8091`

## 说明

- JAV 元数据刮削服务器，搭配 Emby/Jellyfin 使用
- 内置 20+ 数据源，支持电影/演员元数据抓取
- 提供 RESTful API，可被 Emby/Jellyfin 插件直接调用
- 使用 SQLite 数据库持久化数据（位于应用数据目录）
- 零外部依赖（纯 Go 静态二进制）
- 安装后通过 Web UI 访问，可在 Emby/Jellyfin 中配置插件

## 本地构建

```bash
./update_metatube.sh                        # 最新版本，自动检测架构
./update_metatube.sh --arch arm             # 指定架构
./update_metatube.sh 1.4.0                  # 指定版本
./update_metatube.sh --help                 # 查看帮助
```

## 版本标签

- `metatube/vX.Y.Z` — 首次发布
- `metatube/vX.Y.Z-r2` — 同版本打包修订

## Credits

- [MetaTube SDK & Server](https://github.com/metatube-community/metatube-sdk-go)
- [MetaTube Community](https://metatube-community.github.io/)
