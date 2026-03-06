# 任务清单

## 实施任务

- [ ] **T1: 修改 .env.example 默认路径**
  - 文件: `infra/envs/staging/.env.example`
  - 将 `DATA_PATH=/opt/dev/dockermnt/tiz` 改为 `DATA_PATH=/opt/dev/dockermnt/tiz-staging`

- [ ] **T2: 创建 staging 的 .env 文件**
  - 文件: `infra/envs/staging/.env`
  - 基于用户提供的凭证配置
  - 确认文件被 .gitignore 忽略

- [ ] **T3: 创建数据目录**
  - 创建 `/opt/dev/dockermnt/tiz-staging` 目录结构
  - 子目录: mysql, redis, elasticsearch, nacos, kafka

- [ ] **T4: 验证配置**
  - 确认 .env 文件不会被 git 追踪
  - 运行 `git status` 确认
