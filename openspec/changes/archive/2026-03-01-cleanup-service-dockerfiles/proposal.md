## Why

服务应该完全独立，不依赖自定义基础镜像。当前 Dockerfile 依赖 `ghcr.io/suj1e/tiz/base-jre:21`，需要改为使用官方镜像。同时清理遗留代码目录。

## What Changes

- 删除 `tiz-backend/docker/` 目录（基础镜像构建文件）
- 删除 `tiz-backend/contentsrv/src/` 目录（遗留代码）
- 删除 `tiz-backend/usersrv/src/` 目录（遗留代码）
- 修改 7 个 Java 服务的 Dockerfile，使用官方 `eclipse-temurin:21-jre-alpine` 镜像

## Capabilities

### New Capabilities

无

### Modified Capabilities

无

## Impact

- 删除: `tiz-backend/docker/`, `contentsrv/src/`, `usersrv/src/`
- 修改: 7 个 Java 服务的 Dockerfile
