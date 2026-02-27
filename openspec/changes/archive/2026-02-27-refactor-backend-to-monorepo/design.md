## Context

当前 tiz 项目是一个 monorepo，包含：
- `tiz-web/` - 前端项目 (React + Vite)
- `authsrv/`, `chatsrv/`, ... - 8 个后端服务
- `common/` - 公共 Java 模块
- `infra/` - Docker Compose 基础设施
- `standards/` - 开发规范文档
- `openspec/` - 变更管理

后端服务直接放在根目录，与 Gradle 配置文件（`build.gradle.kts`, `settings.gradle.kts`, `gradle/`）混在一起，结构不够清晰。

## Goals / Non-Goals

**Goals:**
- 将所有后端相关代码移动到 `tiz-backend/` 目录
- 保持 Gradle 多项目构建正常工作
- 保持 Git 历史完整
- 更新相关文档和配置

**Non-Goals:**
- 不修改任何服务代码
- 不修改 API 接口
- 不修改构建脚本内容（仅移动位置）

## Decisions

### 1. 目录结构

**决定**: 创建 `tiz-backend/` 作为所有后端服务的根目录

**目标结构**:
```
tiz/
├── tiz-web/           # 前端 (不变)
├── tiz-backend/       # 后端 (新建)
│   ├── common/
│   ├── authsrv/
│   ├── chatsrv/
│   ├── contentsrv/
│   ├── practicesrv/
│   ├── quizsrv/
│   ├── llmsrv/
│   ├── usersrv/
│   ├── gatewaysrv/
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   └── gradle/
├── infra/             # 基础设施 (不变)
├── standards/         # 规范 (不变)
├── openspec/          # 变更管理 (不变)
├── CLAUDE.md          # Claude 指南 (更新路径)
└── README.md          # 项目说明 (更新结构)
```

**替代方案**:
- 将前端也改名 (`tiz-frontend`) - 拒绝，前端已经是 `tiz-web`，无需修改
- 保持现状 - 拒绝，结构混乱

### 2. Git 移动策略

**决定**: 使用 `git mv` 保持历史

```bash
mkdir tiz-backend
git mv common authsrv chatsrv contentsrv practicesrv quizsrv llmsrv usersrv gatewaysrv tiz-backend/
git mv build.gradle.kts settings.gradle.kts gradle tiz-backend/
```

### 3. 文档更新

需要更新的文档：
- `CLAUDE.md` - Claude Code 指南
- `README.md` - 项目结构说明

## Risks / Trade-offs

**风险 1**: IDE 需要重新导入项目
→ 解决: 在 CLAUDE.md 中说明重新导入步骤

**风险 2**: CI/CD 脚本路径变更
→ 解决: 目前没有 CI/CD，无需担心

**风险 3**: 现有 worktrees 路径失效
→ 解决: worktrees 已清理，无需担心

## Migration Plan

1. 创建 `tiz-backend/` 目录
2. 移动所有后端服务目录
3. 移动 Gradle 配置文件
4. 更新文档
5. 提交变更
