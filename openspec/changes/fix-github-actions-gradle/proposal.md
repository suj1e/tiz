## Why

当前 GitHub Actions workflow 的 Gradle 配置有问题：
1. 使用 `wget` 手动下载 Gradle，方式不规范且不可靠
2. 没有正确使用 `gradle/actions/setup-gradle` 的 `gradle-version` 参数
3. 导致 CI 流水线执行失败

## What Changes

- 移除手动 wget 下载 Gradle 的步骤
- 使用 `gradle/actions/setup-gradle@v4` 的 `gradle-version` 参数指定版本
- 使用 `gradle` 命令（非 `./gradlew`，因为项目没有 wrapper）

## Capabilities

### New Capabilities

无

### Modified Capabilities

- `maven-publish`: 更新 CI/CD 发布流程的 Gradle 配置方式

## Impact

**修改的文件（8 个 workflow）：**
- .github/workflows/publish-common.yml
- .github/workflows/publish-llmsrv-api.yml
- .github/workflows/publish-authsrv-api.yml
- .github/workflows/publish-chatsrv-api.yml
- .github/workflows/publish-contentsrv-api.yml
- .github/workflows/publish-practicesrv-api.yml
- .github/workflows/publish-quizsrv-api.yml
- .github/workflows/publish-usersrv-api.yml
