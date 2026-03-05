## Context

当前项目使用 Maven Local 作为服务间依赖共享方式，所有服务物理上放在 `tiz-backend/` 目录下但逻辑独立。未来计划拆分为多仓库。

**阿里云制品仓库信息：**
- Snapshot: `https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx`
- Release: `https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr`

**依赖关系：**
```
common (无依赖)
   ↓
*-api (依赖 common)
   ↓
*-app (依赖 *-api)
```

## Goals / Non-Goals

**Goals:**
- common 和各服务 api 模块可发布到阿里云 Maven 仓库
- 各服务可从阿里云仓库拉取依赖（支持远程 CI/CD 构建）
- GitHub Actions 多流水线独立发布，按路径触发
- 支持本地开发（gradle.properties）和 CI/CD（环境变量）两种认证方式
- SNAPSHOT/RELEASE 版本自动路由到对应仓库

**Non-Goals:**
- 不修改版本号策略（保持 1.0.0-SNAPSHOT）
- 不修改现有业务代码
- 不创建统一的 Gradle 插件（保持各项目独立配置）

## Decisions

### 1. 发布配置模式

**决定：** 每个模块独立配置 publishing 块，不抽取公共脚本

**理由：**
- 各服务是独立项目，未来会拆分仓库
- 独立配置迁移成本低，直接带走即可
- 避免引入额外的构建复杂度

**配置模板：**
```kotlin
publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "<artifact-id>"
        }
    }
    repositories {
        maven {
            name = "AliyunPackages"
            val isSnapshot = version.toString().contains("SNAPSHOT", ignoreCase = true)
            url = uri(
                if (isSnapshot) {
                    "https://packages.aliyun.com/.../snapshot-qazpfx"
                } else {
                    "https://packages.aliyun.com/.../release-epshtr"
                }
            )
            credentials {
                username = System.getenv("ALIYUN_MAVEN_USERNAME")
                    ?: project.findProperty("aliyunMavenUsername") as String? ?: ""
                password = System.getenv("ALIYUN_MAVEN_PASSWORD")
                    ?: project.findProperty("aliyunMavenPassword") as String? ?: ""
            }
        }
    }
}
```

### 2. 消费端仓库配置

**决定：** 在 `settings.gradle.kts` 的 `dependencyResolutionManagement` 中配置阿里云仓库

**理由：**
- 集中管理仓库，避免在每个 build.gradle.kts 中重复
- 与现有配置风格一致

**配置模板：**
```kotlin
dependencyResolutionManagement {
    repositories {
        mavenCentral()
        mavenLocal()
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        // 阿里云制品仓库 - Snapshot
        maven {
            name = "AliyunPackagesSnapshot"
            url = uri("https://packages.aliyun.com/.../snapshot-qazpfx")
            credentials {
                username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
                password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
            }
        }
        // 阿里云制品仓库 - Release
        maven {
            name = "AliyunPackagesRelease"
            url = uri("https://packages.aliyun.com/.../release-epshtr")
            credentials {
                username = System.getenv("ALIYUN_MAVEN_USERNAME") ?: ""
                password = System.getenv("ALIYUN_MAVEN_PASSWORD") ?: ""
            }
        }
    }
}
```

### 3. GitHub Actions 策略

**决定：** 每个可发布单元独立 workflow 文件，按路径触发

**理由：**
- 服务独立，未来拆分仓库时直接迁移
- 避免单个大 workflow 难以维护
- 变更隔离，互不影响

**Workflow 结构：**
```
.github/workflows/
├── publish-common.yml
├── publish-llmsrv-api.yml
├── publish-authsrv-api.yml
├── publish-chatsrv-api.yml
├── publish-contentsrv-api.yml
├── publish-practicesrv-api.yml
├── publish-quizsrv-api.yml
└── publish-usersrv-api.yml
```

### 4. 认证方式

**决定：** 双轨认证 - 环境变量 + gradle.properties

| 场景 | 方式 |
|------|------|
| 本地开发 | `~/.gradle/gradle.properties` |
| GitHub Actions | Repository Secrets |

**本地配置示例：**
```properties
# ~/.gradle/gradle.properties (不提交到 git)
aliyunMavenUsername=your-username
aliyunMavenPassword=your-password
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 凭据泄露 | 使用环境变量和 gradle.properties，不提交到 git |
| SNAPSHOT 版本冲突 | 本地开发时先用 mavenLocal，再从远程拉取 |
| 发布顺序问题 | common 必须先于 *-api 发布（在文档中说明） |
| 仓库 URL 变更 | 统一使用相同的 URL，变更时批量修改 |

## Migration Plan

1. **准备阶段**：在 GitHub 添加 Secrets
2. **发布端改造**：修改 8 个 build.gradle.kts
3. **消费端改造**：修改 9 个 settings.gradle.kts
4. **CI/CD 配置**：创建 8 个 workflow 文件
5. **验证**：
   - 本地执行 `./gradlew publish` 验证发布
   - 推送代码触发 GitHub Actions
   - 远程 CI/CD 构建验证依赖拉取

**回滚策略：**
- 每个文件修改是独立的，可单独回滚
- GitHub Packages 配置保留作为备用
