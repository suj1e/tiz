# Proposal: 统一开发规范（镜像源 + 服务命名）

## Status
proposed

## Summary
1. 将微服务的开发镜像源统一为阿里云
2. 统一服务命名规范，消除所有 `srv` 后缀
3. 为所有有 Dockerfile 的服务添加 .dockerignore
4. 清理 tiz-web 冗余的 Dockerfile

## Motivation
- 官方 Gradle 源在国内下载慢
- 服务命名不统一：目录用 `-service`，但 Docker/compose 用 `srv` 后缀
- 缺少 .dockerignore 导致构建上下文过大、可能泄露敏感信息
- tiz-web 有 3 个 Dockerfile，但主 Dockerfile 已包含 desktop + mobile

---

## Part 1: 镜像源统一

### 1.1 Gradle Wrapper → 阿里云镜像
| 配置项 | 原值 | 新值 |
|--------|------|------|
| distributionUrl | `services.gradle.org` | `mirrors.aliyun.com/gradle/` |
| 版本 | 统一 | 9.3.1 |

涉及 9 个项目的 `gradle-wrapper.properties`

### 1.2 pip 源 → 阿里云镜像
| 配置项 | 原值 | 新值 |
|--------|------|------|
| pip index | `pypi.tuna.tsinghua.edu.cn` | `mirrors.aliyun.com/pypi/simple/` |

涉及 `llm-service/Dockerfile`

### 1.3 已配置项 (保持不变)
- Alpine apk 源: `mirrors.aliyun.com/alpine/` ✅
- Debian apt 源: `mirrors.aliyun.com` ✅
- Maven 仓库: 阿里云制品仓库 ✅

---

## Part 2: 服务命名规范化

### 2.1 命名规则
| 类型 | 规范 | 示例 |
|------|------|------|
| 目录名 | `-service` 后缀 | `auth-service` |
| Docker 容器名 | `tiz-<name>-service` | `tiz-auth-service` |
| Docker 镜像名 | `nxo/<name>-service` | `nxo/auth-service` |
| 服务发现 DNS | `<name>-service` | `auth-service:8101` |

### 2.2 服务名映射表
| 原名 (srv) | 新名 (-service) |
|------------|-----------------|
| `authsrv` | `auth-service` |
| `chatsrv` | `chat-service` |
| `contentsrv` | `content-service` |
| `gatewaysrv` | `gateway` (无后缀) |
| `llmsrv` | `llm-service` |
| `practicesrv` | `practice-service` |
| `quizsrv` | `quiz-service` |
| `usersrv` | `user-service` |

### 2.3 涉及文件

**docker-compose.yml (8 个服务)**:
```
auth-service/docker-compose.yml
chat-service/docker-compose.yml
content-service/docker-compose.yml
gateway/docker-compose.yml
llm-service/docker-compose.yml
practice-service/docker-compose.yml
quiz-service/docker-compose.yml
user-service/docker-compose.yml
```

**Java 代码 (默认值)**:
```
chat-service/app/.../HttpClientConfig.java     (llmsrv, contentsrv)
practice-service/app/.../ContentClientConfig.java (contentsrv)
quiz-service/app/.../ContentClientConfig.java  (contentsrv)
chat-service/app/src/test/resources/application-test.yaml (chatsrv)
```

**Python 代码**:
```
llm-service/pyproject.toml  (name = "llmsrv")
llm-service/pixi.toml       (name = "llmsrv")
llm-service/app/main.py     (service = "llmsrv")
llm-service/tests/test_main.py
```

**README.md (6 个服务)**:
```
gateway/README.md
chat-service/README.md
content-service/README.md
practice-service/README.md
quiz-service/README.md
llm-service/README.md
```

**SQL 初始化脚本 (3 个环境)**:
```
infra/dev/mysql-init/03-tiz-schema.sql
infra/staging/mysql-init/03-tiz-schema.sql
infra/prod/mysql-init/03-tiz-schema.sql
```

**其他**:
```
gateway/Dockerfile (注释)
gateway/src/.../package-info.java (文档注释)
chat-service/api/.../ChatEvent.java (注释)
```

---

## Part 3: .dockerignore

为 9 个服务添加 .dockerignore：

```gitignore
# Gradle
.gradle/
**/build/
!gradle/wrapper/gradle-wrapper.jar

# IDE
.idea/
*.iml
.vscode/

# Environment files (may contain secrets)
.env
.env.*
!.env.example

# Git
.git/
.gitignore

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Documentation
*.md
!README.md

# Scripts (not needed in container)
*.sh
```

---

## Part 4: tiz-web Dockerfile 清理

### 当前状态
```
tiz-web/
├── Dockerfile           # 主文件，包含构建 + UA 路由
├── Dockerfile.desktop   # 遗留，无构建阶段
└── Dockerfile.mobile    # 遗留，无构建阶段
```

### 决策
删除 `Dockerfile.desktop` 和 `Dockerfile.mobile`，只保留主 `Dockerfile`

理由：
- 主 Dockerfile 已支持 desktop + mobile 双构建
- 使用 nginx UA 路由自动分发
- 分离版本是遗留代码，不再使用

---

## Files Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 变更类型                  │ 文件数                                      │
├─────────────────────────────────────────────────────────────────────────┤
│ gradle-wrapper.properties │ 9 个 (修改)                                 │
│ .dockerignore (新增)      │ 9 个 (新增)                                 │
│ docker-compose.yml        │ 8 个 (服务名)                               │
│ Java 代码                 │ 5 个 (默认值 + 注释)                        │
│ Python 代码/配置          │ 4 个                                        │
│ README.md                 │ 6 个                                        │
│ SQL 初始化脚本            │ 3 个 (注释)                                 │
│ llm-service/Dockerfile    │ 1 个 (pip 源)                               │
│ tiz-web/Dockerfile.*      │ 2 个 (删除)                                 │
├─────────────────────────────────────────────────────────────────────────┤
│ 总计                      │ ~47 个文件                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Impact
- **镜像源**: 低风险，仅改下载地址
- **服务命名**: 需要重新部署所有服务，确保服务发现配置同步更新
- **.dockerignore**: 减小构建上下文，防止敏感信息泄露
- **tiz-web 清理**: 删除未使用的文件，无影响

## Execution Order
1. 添加 .dockerignore（随时可加）
2. 改镜像源（不影响运行）
3. 清理 tiz-web Dockerfile（删除未使用文件）
4. 改服务命名（需要停机或滚动更新）
