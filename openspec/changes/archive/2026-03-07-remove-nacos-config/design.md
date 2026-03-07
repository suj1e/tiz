## Context

当前系统使用 Nacos 作为配置中心，服务启动时从 Nacos 加载配置。配置文件存储在 `nacos-config/` 目录，通过 `import.sh` 脚本导入到 Nacos。

对于 7 个微服务的规模，这种方式过于复杂：
- 配置需要在 git 和 Nacos 之间同步
- 大部分配置是静态的基础设施地址
- 敏感信息已经在使用环境变量

## Goals / Non-Goals

**Goals:**
- 简化配置管理，使用环境变量替代 Nacos Config
- 保留 Nacos Discovery 用于服务发现
- 每个服务独立管理自己的环境配置文件
- 配置来源单一透明

**Non-Goals:**
- 不改变服务发现机制
- 不实现配置动态刷新（接受改配置需重启）
- 不改变 K8s 部署方式（如有）

## Decisions

### 1. 配置管理方式：环境变量

**选择：** 环境变量 + docker-compose.yml 显式声明

**理由：**
- 12-factor app 标准
- CI/CD 友好，无需额外 import 步骤
- 配置来源单一，无漂移风险
- 对于 7 个服务足够用

**替代方案：**
- 保留 Nacos Config：过度复杂
- Spring Cloud Config：引入新依赖，没必要
- K8s ConfigMap：未来 K8s 部署时再迁移

### 2. 环境文件组织：每服务独立

**选择：** 每个服务目录下放置 `.env.dev`、`.env.staging`、`.env.prod`

```
authsrv/
├── docker-compose.yml
├── .env.dev
├── .env.staging
└── .env.prod
```

**理由：**
- 符合微服务独立部署原则
- 服务可以单独抽离部署
- 配置职责清晰

### 3. 默认值策略：开发环境有默认，生产环境无默认

**选择：** `docker-compose.yml` 中使用 `${VAR:-default}` 语法

**理由：**
- 开发环境开箱即用
- 生产环境必须显式设置，避免遗漏
- 敏感信息不设默认值

## Risks / Trade-offs

| 风险 | 缓解措施 |
|-----|---------|
| 改配置需要重启服务 | 接受，日志级别调整不频繁 |
| 环境变量多，docker-compose.yml 较长 | 使用 `.env` 文件管理，保持整洁 |
| 配置分散在各服务目录 | 这是微服务的特点，不是问题 |
