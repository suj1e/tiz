## Context

项目使用 `gradle/actions/setup-gradle@v4` 来配置 Gradle 环境，但之前的实现使用了不正确的方式手动下载 Gradle。

根据官方文档，`setup-gradle` action 支持以下参数：
- `gradle-version`: 指定 Gradle 版本，默认为 `latest`
- 支持的值：具体版本号（如 `"9.3.1"`）、`latest`、`release-candidate`、`nightly`

## Goals / Non-Goals

**Goals:**
- 使用官方推荐的方式配置 Gradle
- 修复 CI 流水线执行失败的问题

**Non-Goals:**
- 不添加 Gradle Wrapper（项目当前不需要）
- 不修改其他 CI/CD 配置

## Decisions

### 1. 使用 gradle-version 参数

**决定：** 使用 `gradle/actions/setup-gradle@v4` 的 `gradle-version` 参数

**配置示例：**
```yaml
- name: Setup Gradle
  uses: gradle/actions/setup-gradle@v4
  with:
    gradle-version: "9.3.1"

- name: Build
  run: gradle build  # 使用 gradle 命令
```

**理由：**
- 官方推荐方式
- 自动处理下载和缓存
- 更简洁可靠

### 2. 移除手动下载步骤

**决定：** 删除 `wget` 下载和 `unzip` 安装步骤

**理由：**
- `setup-gradle` 已内置版本管理功能
- 手动方式不可靠且不符合最佳实践

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 版本号写错 | 使用项目验证过的版本 9.3.1 |
