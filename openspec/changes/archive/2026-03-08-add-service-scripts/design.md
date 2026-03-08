## Context

当前 tiz-backend 包含 10 个独立服务，每个服务由不同团队维护。GitHub Actions 提供了 CI/CD 能力，但本地开发时缺少统一的服务管理工具。

**服务类型**:
- Java 服务 (api + app): auth-service, chat-service, content-service, practice-service, quiz-service, user-service
- Java 单模块: gateway, llm-api, common
- Python 服务: llm-service

## Goals / Non-Goals

**Goals:**
- 提供统一的服务管理 CLI
- 支持 publish、image、build、run、test 等核心命令
- 支持版本管理、配置验证、日志查看等运维命令
- 各服务脚本独立，可由各团队自行维护

**Non-Goals:**
- 不替代 GitHub Actions（CI/CD 仍由 GitHub 完成）
- 不提供集群部署能力
- 不提供数据库迁移功能

## Decisions

### 1. 脚本命名

**决定**: `svc.sh`

**备选方案**:
| 方案 | 优点 | 缺点 |
|-----|------|------|
| `svc.sh` | 简短，语义清晰 | - |
| `service.sh` | 更明确 | 较长 |
| `Makefile` | 标准化 | 不够灵活 |

### 2. 命令设计

**决定**: 采用子命令模式

```
./svc.sh <command> [options]
```

**命令列表**:

| 命令 | 说明 |
|------|------|
| `build` | 本地构建 |
| `test` | 运行测试 |
| `run` | 本地运行 |
| `publish` | 发布 API 到 Maven |
| `image` | 构建+推送 Docker 镜像 |
| `image --local` | 只构建，不推送 |
| `version` | 查看版本 |
| `version bump` | 版本号+1 |
| `tag` | 创建 Git tag |
| `status` | 健康检查 |
| `logs` | 查看日志 |
| `validate` | 验证配置 |
| `rollback <v>` | 回滚版本 |
| `images` | 镜像管理 |
| `deps` | 依赖管理 |
| `help` | 帮助信息 |

### 3. 脚本模板分类

**决定**: 3 种模板

| 模板 | 适用服务 | 特点 |
|------|----------|------|
| `java-service` | auth, chat, content, practice, quiz, user | api/ + app/ 子模块 |
| `java-single` | gateway, llm-api, common | 无子模块 |
| `python-service` | llm-service | pixi + FastAPI |

### 4. 环境支持

**决定**: 通过 `--env` 参数支持多环境

```bash
./svc.sh run --env dev      # 使用 .env.dev
./svc.sh run --env staging  # 使用 .env.staging
./svc.sh run --env prod     # 使用 .env.prod
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|-----|---------|
| 脚本重复，维护成本高 | 使用模板生成，保持一致性 |
| 各团队修改后不一致 | 提供核心模板，文档说明最佳实践 |
| 依赖外部凭证 | validate 命令检查配置完整性 |

## Migration Plan

1. 创建 3 种脚本模板
2. 为每个服务生成脚本
3. 添加 `publish-all.sh` 批量脚本
4. 更新 CLAUDE.md 文档
