## Context

当前 8 个业务服务：
- Java: gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv, quizsrv, usersrv
- Python: llmsrv

每个服务已有 Dockerfile，需要独立的 docker-compose.yml。

## Goals / Non-Goals

**Goals:**
- 每个服务可独立 `docker-compose up` 启动
- 配置文件跟随代码（nacos-config 在 tiz-backend 下）
- 保持现有 Dockerfile 不变

**Non-Goals:**
- 不修改服务代码
- 不处理服务间依赖（由开发者自行管理）
- 不涉及 CI/CD 配置

## Decisions

### 1. 目录结构

```
tiz-backend/
├── nacos-config/           # 从 deploy/ 移入
│   ├── dev/
│   ├── staging/
│   └── prod/
├── authsrv/
│   ├── Dockerfile          # 已有
│   ├── docker-compose.yml  # 新增
│   └── ...
├── gatewaysrv/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── ...
└── ... (其他服务同理)
```

### 2. docker-compose.yml 模板

每个服务的 compose 包含：
- 服务定义（镜像、端口、环境变量）
- 连接 `npass` 网络
- 从 Nacos 读取配置
- 敏感信息通过环境变量或 .env 文件

**Java 服务模板:**
```yaml
services:
  authsrv:
    build: .
    container_name: tiz-authsrv
    restart: always
    ports:
      - "8101:8101"
    environment:
      - NACOS_SERVER_ADDR=${NACOS_SERVER_ADDR:-nacos:8080}
      - NACOS_NAMESPACE=${NACOS_NAMESPACE:-}
      - SPRING_DATASOURCE_PASSWORD=${MYSQL_PASSWORD}
      - SPRING_DATA_REDIS_PASSWORD=${REDIS_PASSWORD}
    networks:
      - npass
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  npass:
    external: true
```

### 3. 环境变量

通过 `.env` 文件管理，不硬编码在 compose 中。

## Risks / Trade-offs

**服务启动顺序** → 开发者自行管理，不自动处理依赖
