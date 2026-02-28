# Tiz - AI 驱动的知识练习平台

Tiz 是一个基于 AI 的知识练习平台，用户通过对话式交互与 AI 探索学习需求，生成个性化的练习题和测验。

## 项目结构

```
tiz/
├── tiz-web/           # 前端项目 (React + TypeScript + Vite)
├── tiz-backend/       # 后端微服务 (独立 Gradle 项目)
│   ├── common/        # 公共模块 (发布到 Maven Local)
│   ├── llmsrv/        # AI 服务 (Python/FastAPI) (:8106)
│   ├── authsrv/       # 认证服务 (:8101)
│   │   ├── api/       # DTO 和客户端接口 (发布到 Maven Local)
│   │   └── app/       # 服务实现
│   ├── chatsrv/       # 对话服务 (:8102)
│   │   ├── api/       # DTO 和客户端接口
│   │   └── app/       # 服务实现
│   ├── contentsrv/    # 内容服务 (:8103)
│   │   ├── api/       # DTO 和客户端接口
│   │   └── app/       # 服务实现
│   ├── practicesrv/   # 练习服务 (:8104)
│   │   ├── api/       # DTO 和客户端接口
│   │   └── app/       # 服务实现
│   ├── quizsrv/       # 测验服务 (:8105)
│   │   ├── api/       # DTO 和客户端接口
│   │   └── app/       # 服务实现
│   ├── usersrv/       # 用户服务 (:8107)
│   │   ├── api/       # DTO 和客户端接口
│   │   └── app/       # 服务实现
│   └── gatewaysrv/    # API 网关 (:8080)
├── infra/             # 基础设施配置 (Docker Compose)
├── standards/         # 开发规范文档
│   ├── api.md         # API 接口文档
│   ├── backend.md     # 后端开发规范
│   ├── frontend.md    # 前端开发规范
│   └── postman.json   # Postman Collection
└── openspec/          # OpenSpec 变更管理
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

每个 Java 服务都是独立的 Gradle 项目，采用 api + app 子模块结构：
- **api/**: DTO 和客户端接口（发布到 Maven Local 供其他服务依赖）
- **app/**: 服务实现

```bash
# 首先发布 common 模块
cd tiz-backend/common
gradle publishToMavenLocal

# 发布服务 API（如果其他服务依赖它）
cd tiz-backend/contentsrv
gradle :api:publishToMavenLocal

# 构建并运行服务
cd tiz-backend/contentsrv
gradle :app:bootRun
```

### 服务间依赖

服务通过 Maven Local 相互依赖：
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - 公共工具类
- `io.github.suj1e:contentsrv-api:1.0.0-SNAPSHOT` - 内容服务 DTO
- `io.github.suj1e:llmsrv-api:1.0.0-SNAPSHOT` - AI 服务 DTO
- 等等...

### AI 服务 (llmsrv)

```bash
cd tiz-backend/llmsrv

# 安装依赖
pixi install

# 运行开发服务器
pixi run dev
```

### 基础设施

```bash
cd infra

# 启动所有服务
docker-compose -f docker-compose-lite.yml up -d
```

## 页面路由

| 路径 | 页面 | 认证 | 说明 |
|------|------|------|------|
| `/` | 落地页 | 否 | 产品介绍，支持主题切换 |
| `/login` | 登录 | 否 | 用户登录 |
| `/register` | 注册 | 否 | 用户注册 |
| `/chat` | 试用对话 | 否 | 无需登录的试用对话 |
| `/home` | 首页 | 是 | 对话式学习 |
| `/library` | 题库 | 是 | 管理保存的练习题 |
| `/practice/:id` | 练习 | 是 | 练习模式 |
| `/quiz/:id` | 测验 | 是 | 测验模式 |
| `/result/:id` | 结果 | 是 | 测验结果 |
| `/settings` | 设置 | 是 | 主题、通知、Webhook、账户设置 |

## API 网关路由

```
/api/auth/v1/**     → authsrv:8101
/api/chat/v1/**     → chatsrv:8102
/api/content/v1/**  → contentsrv:8103
/api/practice/v1/** → practicesrv:8104
/api/quiz/v1/**     → quizsrv:8105
/api/user/v1/**     → usersrv:8107
```

## 开发规范

详细规范请参阅 `standards/` 目录：

- [API 文档](standards/api.md)
- [后端规范](standards/backend.md)
- [前端规范](standards/frontend.md)

## API 变更记录

### 2026-02 游标分页迁移

题库列表接口 (`GET /api/content/v1/library`) 已从传统的页码分页迁移到游标分页：

**旧版 (已废弃)**:
```
GET /api/content/v1/library?page=1&limit=10
响应: { "data": [...], "pagination": { "page": 1, "total_pages": 5, "total_count": 50 } }
```

**新版 (当前)**:
```
GET /api/content/v1/library?page_size=10&page_token=
响应: { "data": [...], "has_more": true, "next_token": "eyJ..." }
```

**变更说明**:
- `page` 参数改为 `page_token`（游标字符串，首次请求为空）
- `limit` 参数改为 `page_size`
- 响应移除 `pagination` 对象，改为 `has_more` 和 `next_token` 字段
- 当 `has_more` 为 `false` 时，`next_token` 不存在

**分类/标签响应格式更新**:
```json
// 旧版
{ "data": { "categories": ["前端开发", "后端开发"] } }

// 新版（包含 count 字段）
{ "data": { "categories": [{ "name": "前端开发", "count": 15 }] } }
```

## 部署

### 前置要求
- Docker & Docker Compose
- GitHub CLI

### GitHub Secrets 配置
| Secret | 说明 |
|--------|------|
| SERVER_HOST | 服务器 IP 或域名 |
| SERVER_USER | SSH 用户名 |
| SSH_PRIVATE_KEY | SSH 私钥 |
| DEPLOY_PATH | 部署目录 (/opt/dev/apps/tiz) |

### 部署命令
```bash
# 打 tag 触发部署
git tag v1.0.0
git push origin v1.0.0
```

### 手动部署
```bash
cd /opt/dev/apps/tiz
docker-compose -f infra/docker-compose-app.yml up -d
```

## 许可证

私有项目，保留所有权利。
