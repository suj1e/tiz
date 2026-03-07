## 1. 禁用 Nacos Config（服务端)

- [x] 1.1 authsrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.2 chatsrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.3 contentsrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.4 practicesrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.5 quizsrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.6 usersrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块
- [x] 1.7 gatewaysrv: 删除 `application.yaml` 中的 `spring.cloud.nacos.config` 块

## 2. 清理敏感配置默认值

- [x] 2.1 authsrv: 移除 `JWT_SECRET` 默认值
- [x] 2.2 其他服务: 检查并移除敏感配置默认值（如有）

## 3. 更新 docker-compose.yml

- [x] 3.1 authsrv: 添加完整环境变量声明
- [x] 3.2 chatsrv: 添加完整环境变量声明
- [x] 3.3 contentsrv: 添加完整环境变量声明
- [x] 3.4 practicesrv: 添加完整环境变量声明
- [x] 3.5 quizsrv: 添加完整环境变量声明
- [x] 3.6 usersrv: 添加完整环境变量声明
- [x] 3.7 gatewaysrv: 添加完整环境变量声明
- [x] 3.8 llmsrv: 添加完整环境变量声明

## 4. 创建环境配置文件

- [x] 4.1 authsrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.2 chatsrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.3 contentsrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.4 practicesrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.5 quizsrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.6 usersrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.7 gatewaysrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`
- [x] 4.8 llmsrv: 创建 `.env.dev`、`.env.staging`、`.env.prod`

## 5. 清理旧配置

- [x] 5.1 删除 `tiz-backend/nacos-config/` 目录

## 6. 更新文档

- [ ] 6.1 更新 `CLAUDE.md`：删除 nacos-config 相关说明
- [ ] 6.2 更新 `CLAUDE.md`：添加环境变量配置说明
