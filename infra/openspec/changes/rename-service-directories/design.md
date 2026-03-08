## Context

tiz-backend 采用微服务架构，每个服务是独立的 Gradle 项目。当前目录命名使用 `*srv` 后缀（如 `authsrv`），不符合行业主流规范，可读性较差。

**利益相关者**: 后端开发团队

**约束**:
- 项目处于早期开发阶段，外部依赖较少
- 需要保持向后兼容的 Maven 坐标一段时间
- CI/CD 需要同步更新

## Goals / Non-Goals

**Goals:**
- 将所有服务目录重命名为 `*-service` 风格
- 更新所有相关配置文件
- 保持构建和部署流程正常工作

**Non-Goals:**
- 不修改服务内部代码逻辑
- 不修改 API 接口
- 不修改运行时行为

## Decisions

### 1. 命名风格选择

**决定**: 使用 `*-service` 后缀

**备选方案**:
| 方案 | 示例 | 优点 | 缺点 |
|-----|------|-----|------|
| `*-service` | auth-service | Spring 社区主流，清晰 | 稍长 |
| `*-svc` | auth-svc | 简短 | 不够常见 |
| 无后缀 | auth | 最简洁 | 与 common 等模块风格不统一 |

**理由**: `*-service` 是 Spring/Java 生态最主流的命名方式，清晰表达服务性质。

### 2. 特殊处理

**gateway-service**: Gateway 通常不加 service 后缀，但为保持一致性，保留 `-service`

**llm-api**: 原 `llmsrv-api` 是 API 模块不是服务，改为 `llm-api` 更准确

### 3. Maven 坐标策略

**决定**: 同时更新 Group ID 和 Artifact ID

新坐标格式: `io.github.suj1e:<new-name>:1.0.0-SNAPSHOT`
- 例: `io.github.suj1e:auth-service:1.0.0-SNAPSHOT`

## Risks / Trade-offs

| 风险 | 缓解措施 |
|-----|---------|
| 旧坐标的依赖者找不到包 | 保留旧包一段时间，添加 relocation 提示 |
| CI/CD 脚本硬编码路径 | 全面搜索替换 |
| 文档过时 | 同步更新 CLAUDE.md |

## Migration Plan

1. **准备阶段**: 确认所有需要修改的文件列表
2. **执行阶段**: 按 服务目录 → Gradle 配置 → CI/CD → 文档 顺序执行
3. **验证阶段**: 运行 `./start-dev.sh` 验证所有服务正常启动
4. **发布阶段**: 发布新 Maven 包，旧包标记为 deprecated

**回滚策略**: Git revert，无数据迁移风险
