## ADDED Requirements

### Requirement: GitHub Actions 使用 gradle-version 参数配置 Gradle

GitHub Actions workflow SHALL 使用 `gradle/actions/setup-gradle@v4` 的 `gradle-version` 参数来指定 Gradle 版本，而不是手动下载。

#### Scenario: 使用 gradle-version 参数
- **WHEN** workflow 执行 Setup Gradle 步骤
- **THEN** 使用 `gradle/actions/setup-gradle@v4` action
- **AND** 设置 `gradle-version: "9.3.1"`
- **AND** 后续步骤使用 `gradle` 命令（非 `./gradlew`）

#### Scenario: 不使用手动下载
- **WHEN** workflow 配置 Gradle 环境
- **THEN** 不使用 `wget` 或 `curl` 下载 Gradle
- **AND** 不使用 `unzip` 手动安装
