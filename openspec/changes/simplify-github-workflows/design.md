## Context

当前项目使用 GitHub Actions 进行 CI/CD：
- 9 个 Docker 构建工作流（手动触发）
- 8 个 Maven 发布工作流（路径变更自动触发）

由于团队规模小、发布频率低，这些自动化流水线的维护成本高于收益。改为手动发布更简单直接。

## Goals / Non-Goals

**Goals:**
- 删除所有 CI/CD workflow，减少维护负担
- 添加 Dependabot 自动检查依赖更新
- 保持手动发布能力（通过 `svc.sh` 脚本）

**Non-Goals:**
- 不迁移到其他 CI/CD 平台
- 不改变现有的发布流程（svc.sh 脚本）

## Decisions

### 1. 删除全部 workflow vs 保留部分

**决定**: 删除全部 17 个 workflow

**理由**:
- 当前 workflow 都是手动触发或低频使用
- `svc.sh` 脚本已覆盖所有发布功能
- 减少维护负担，避免 workflow 过时

### 2. Dependabot 配置范围

**决定**: 配置 4 个包管理器

| 包管理器 | 目录 | 更新频率 |
|---------|------|----------|
| gradle | `tiz-backend/*/` | weekly |
| npm | `tiz-web/` | weekly |
| pip | `tiz-backend/llm-service/` | weekly |
| github-actions | `.github/workflows/` | weekly |

**理由**: 覆盖所有技术栈，统一每周检查

### 3. Dependabot 分组策略

**决定**: 按服务分组，限制每次最多 5 个 PR

**理由**:
- 避免 PR 过多造成混乱
- 按服务分组便于审查

## Risks / Trade-offs

| 风险 | 缓解措施 |
|-----|---------|
| 依赖过时未及时发现 | Dependabot 每周检查，创建 PR 提醒 |
| 忘记手动发布 | 发布前检查清单，文档说明 |
| Dependabot PR 积压 | 定期审查，设置自动合并规则（minor/patch） |

## Migration Plan

1. 创建 `.github/dependabot.yml`
2. 删除 `.github/workflows/` 下所有文件
3. 更新 README.md 和 CLAUDE.md，删除 CI/CD 相关说明
4. 如果 workflows 目录为空，可删除目录或保留空的 `.gitkeep`
