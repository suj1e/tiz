# Tiz - AI 驱动的知识练习平台

Tiz 是一个基于 AI 的知识练习平台，用户通过对话式交互与 AI 探索学习需求，生成个性化的练习题和测验。

## 项目结构

```
tiz/
├── tiz-web/              # 前端项目 (React + TypeScript + Vite)
├── tiz-backend/          # 后端微服务 (独立服务，放在同一目录下)
│   ├── common/           # 公共模块 (发布到 Aliyun Maven)
│   ├── llm-api/          # LLM API DTOs (发布到 Aliyun Maven)
│   ├── llm-service/      # AI 服务 (Python/FastAPI) (:8106)
│   ├── auth-service/     # 认证服务 (:8101)
│   ├── chat-service/     # 对话服务 (:8102)
│   ├── content-service/  # 内容服务 (:8103)
│   ├── practice-service/ # 练习服务 (:8104)
│   ├── quiz-service/     # 测验服务 (:8105)
│   ├── user-service/     # 用户服务 (:8107)
│   └── gateway/          # API 网关 (:9080)
├── infra/                # 基础设施
│   ├── dev/              # 开发环境
│   ├── staging/          # 预发环境
│   ├── prod/             # 生产环境
│   └── infra.sh          # 管理脚本
├── standards/            # 开发规范文档
├── openspec/             # OpenSpec 变更管理
└── svc-all.sh            # 批量服务管理脚本
```

## 核心功能

- **对话式探索**: 通过自然语言对话，让 AI 理解学习需求
- **AI 生成题目**: 智能生成选择题和简答题，支持多种难度
- **练习模式**: 无时间限制，即时显示答案和解析
- **测验模式**: 限时测验，AI 评分，错题回顾
- **题库管理**: 保存题目到个人题库，随时回顾练习
- **Webhook 通知**: 配置 Webhook 接收事件通知

## 技术栈

### 前端 (tiz-web)
| 类别 | 技术 |
|------|------|
| 包管理器 | pnpm |
| 构建工具 | Vite 7.x |
| 框架 | React 19 + TypeScript 5.x |
| 路由 | React Router 7.x |
| 状态管理 | Zustand 5.x |
| UI | shadcn/ui + Tailwind CSS 4.x |
| Mock | MSW 2.x |
| 测试 | Vitest 4.x + Testing Library |

### 后端 (tiz-backend)
| 类别 | 技术 |
|------|------|
| 框架 | Spring Boot 4.0.2 / Spring Cloud Gateway |
| 语言 | Java 21 / Python 3.11+ |
| 构建 | Gradle / pixi |
| AI | LangGraph + LangChain |

## 快速开始

### 前端开发

```bash
cd tiz-web

# 安装依赖
pnpm install

# 开发模式 (带 Mock 数据，无需后端)
VITE_MOCK=true pnpm dev

# 开发模式 (连接后端)
pnpm dev

# 运行测试
pnpm test

# 生产构建
pnpm build
```

### 后端开发

每个服务都是独立的项目，可以单独开发和部署：

```bash
# 使用 svc.sh 脚本（推荐）
cd tiz-backend/auth-service
./svc.sh help           # 查看所有命令
./svc.sh build          # 构建
./svc.sh test           # 运行测试
./svc.sh run            # 本地运行
./svc.sh publish        # 发布 API 到 Maven

# 或使用 Gradle 命令
cd tiz-backend/common
gradle publish

cd tiz-backend/content-service
gradle :api:publish
gradle :app:bootRun
```

**服务配置文件：**
- `gradle.properties` - 项目 group 和 version（禁止在 build.gradle.kts 硬编码）
- `libs.versions.toml` - 依赖版本目录（所有依赖必须通过 version catalog 引用）
- `.env.example` - 环境变量模板

### AI 服务 (llm-service)

```bash
cd tiz-backend/llm-service

# 安装依赖
pixi install

# 运行开发服务器
pixi run dev
```

### 基础设施

```bash
cd infra

# 启动开发环境
./infra.sh start

# 查看状态
./infra.sh status

# 启动其他环境
./infra.sh start --env staging
./infra.sh start --env prod
```

### 服务配置

每个服务通过环境变量进行配置。各服务目录下有 `.env.example` 模板文件和 README.md 说明文档：

```
auth-service/
├── README.md           # 服务说明文档
├── docker-compose.yml
└── .env.example        # 环境变量模板
```

复制 `.env.example` 为 `.env.dev`、`.env.staging` 或 `.env.prod` 并配置相应值。

部署时指定环境文件：
```bash
cd tiz-backend/auth-service
docker-compose --env-file .env.prod up -d
```

### 一键启动后端服务

```bash
cd tiz-backend

# 启动所有服务
./start-dev.sh start

# 查看状态
./start-dev.sh status

# 查看日志
./start-dev.sh logs auth-service

# 停止所有服务
./start-dev.sh stop
```

## 服务部署

每个服务都是独立的，有独立的 Dockerfile 和 docker-compose.yml：

```bash
# 在任意服务目录下
cd tiz-backend/auth-service
docker-compose up -d

# 或者构建镜像
docker build -t auth-service:latest .
```

### 基础设施端口 (dev 环境)

| 服务 | 端口 | 用途 |
|------|------|------|
| MySQL | 30001 | 数据库 |
| Redis | 30002 | 缓存 |
| Elasticsearch | 30003 | 搜索引擎 |
| Nacos Console | 30006 | 配置中心 Web UI |
| Nacos API | 30848 | SDK 连接地址 |
| Kafka | 30009 | 消息队列 |
| Kafka UI | 30010 | Kafka 管理界面 |

### 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| tiz-web | 80 | 前端 (UA 分流 desktop/mobile) |
| gateway | 9080 | API 网关 |
| auth-service | 8101 | 认证服务 |
| chat-service | 8102 | 对话服务 |
| content-service | 8103 | 内容服务 |
| practice-service | 8104 | 练习服务 |
| quiz-service | 8105 | 测验服务 |
| llm-service | 8106 | AI 服务 |
| user-service | 8107 | 用户服务 |

## API 网关路由

```
/api/auth/v1/**     → auth-service:8101
/api/chat/v1/**     → chat-service:8102
/api/content/v1/**  → content-service:8103
/api/practice/v1/** → practice-service:8104
/api/quiz/v1/**     → quiz-service:8105
/api/user/v1/**     → user-service:8107
```

## 依赖管理

项目使用 [Dependabot](https://docs.github.com/en/code-security/dependabot) 自动检查依赖更新，每周一运行。

**配置文件:** `.github/dependabot.yml`

| 包管理器 | 目录 | 更新频率 |
|---------|------|----------|
| Gradle | `tiz-backend/*/` | 每周一 |
| pnpm | `tiz-web/` | 每周一 |
| pip | `tiz-backend/llm-service/` | 每周一 |

## 手动发布

所有发布操作通过 `svc.sh` 脚本手动执行：

```bash
# 发布 Maven 依赖
cd tiz-backend/common && ./svc.sh publish
cd tiz-backend/auth-service && ./svc.sh publish

# 构建 Docker 镜像
cd tiz-backend/auth-service && ./svc.sh image
cd tiz-backend/auth-service && ./svc.sh image --local  # 只构建不推送

# 批量操作
./svc-all.sh publish    # 发布所有 API
./svc-all.sh image      # 构建所有镜像
```

**镜像仓库:** `registry.cn-hangzhou.aliyuncs.com/nxo/<service>`

## 开发规范

详细规范请参阅 `standards/` 目录：

- [API 文档](standards/api.md)
- [后端规范](standards/backend.md)
- [前端规范](standards/frontend.md)

### Gradle 构建规范

**禁止在 build.gradle.kts 中硬编码：**

| 禁止项 | 正确做法 |
|--------|----------|
| `group = "io.github.suj1e"` | 使用 `gradle.properties` |
| `version = "1.0.0-SNAPSHOT"` | 使用 `gradle.properties` |
| `implementation("group:artifact:1.0.0")` | 使用 `libs.xxx` |

**正确示例：**
```kotlin
// gradle.properties
// version=1.0.0-SNAPSHOT
// group=io.github.suj1e

// build.gradle.kts
dependencies {
    implementation(libs.common)
    implementation(libs.content.api)
    testRuntimeOnly(libs.h2)
}
```

## 许可证

私有项目，保留所有权利。
