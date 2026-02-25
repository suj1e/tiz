# Tiz - AI 驱动的知识练习平台

Tiz 是一个基于 AI 的知识练习平台，用户通过对话式交互与 AI 探索学习需求，生成个性化的练习题和测验。

## 项目结构

```
tiz/
├── tiz-web/           # 前端项目 (React + TypeScript + Vite)
├── gatewaysrv/        # API 网关服务 (Java/Spring Cloud Gateway)
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

## 技术栈

### 前端 (tiz-web)
| 类别 | 技术 |
|------|------|
| 包管理器 | pnpm |
| 构建工具 | Vite 7.x |
| 框架 | React 19 + TypeScript 5.x |
| 路由 | React Router 7.x |
| 状态管理 | Zustand |
| UI | shadcn/ui + Tailwind CSS 4.x |
| Mock | MSW 2.x |
| 测试 | Vitest + Testing Library |

### 后端 (gatewaysrv)
| 类别 | 技术 |
|------|------|
| 框架 | Spring Cloud Gateway |
| 语言 | Java 21 |
| 构建 | Gradle |

## 快速开始

### 前端开发

```bash
cd tiz-web

# 安装依赖
pnpm install

# 开发模式 (带 Mock 数据)
VITE_MOCK=true pnpm dev

# 开发模式 (连接后端)
pnpm dev

# 运行测试
pnpm test

# 生产构建
pnpm build
```

### 后端开发

```bash
cd gatewaysrv

# 构建
./gradlew build

# 运行
./run.sh
```

### 基础设施

```bash
cd infra

# 启动所有服务
docker-compose -f docker-compose-lite.yml up -d
```

## 页面路由

| 路径 | 页面 | 认证 |
|------|------|------|
| `/` | 落地页 | 否 |
| `/login` | 登录 | 否 |
| `/register` | 注册 | 否 |
| `/chat` | 试用对话 | 否 |
| `/home` | 首页 | 是 |
| `/library` | 题库 | 是 |
| `/practice/:id` | 练习 | 是 |
| `/quiz/:id` | 测验 | 是 |
| `/result/:id` | 结果 | 是 |
| `/settings` | 设置 | 是 |

## API 网关路由

```
/api/auth/v1/**     → auth-service
/api/chat/v1/**     → chat-service
/api/content/v1/**  → content-service
/api/practice/v1/** → practice-service
/api/quiz/v1/**     → quiz-service
/api/user/v1/**     → user-service
```

## 开发规范

详细规范请参阅 `standards/` 目录：

- [API 文档](standards/api.md)
- [后端规范](standards/backend.md)
- [前端规范](standards/frontend.md)

## 许可证

私有项目，保留所有权利。
