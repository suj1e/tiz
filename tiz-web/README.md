# tiz-web

AI 驱动的知识练习平台前端项目。

## 技术栈

- **React 19** + **TypeScript 5.x**
- **Vite 7.x** 构建工具
- **Tailwind CSS 4.x** + **shadcn/ui** 样式
- **Zustand** 状态管理
- **React Router 7.x** 路由
- **MSW 2.x** Mock 服务
- **Vitest** + **Testing Library** 测试

## 开发

```bash
# 安装依赖
pnpm install

# 开发模式 (带 Mock)
VITE_MOCK=true pnpm dev

# 开发模式 (连接后端)
pnpm dev

# 代码检查
pnpm lint

# 运行测试
pnpm test

# 测试覆盖率
pnpm test:coverage

# 生产构建
pnpm build
```

## 目录结构

```
src/
├── app/                    # 页面组件
│   ├── (auth)/             # 认证页面 (登录/注册)
│   ├── (main)/             # 主应用页面
│   ├── chat/               # 试用对话
│   ├── landing/            # 落地页
│   └── not-found/          # 404 页面
├── components/             # UI 组件
│   ├── ui/                 # shadcn/ui 基础组件
│   ├── layout/             # 布局组件
│   ├── chat/               # 对话组件
│   ├── question/           # 题目组件
│   ├── library/            # 题库组件
│   ├── quiz/               # 测验组件
│   └── common/             # 通用组件
├── hooks/                  # 自定义 Hooks
├── stores/                 # Zustand 状态
├── services/               # API 服务
├── types/                  # TypeScript 类型
├── lib/                    # 工具函数
├── mocks/                  # MSW Mocks
└── test/                   # 测试配置
```

## 环境变量

复制 `.env.example` 为 `.env` 并配置：

```bash
# API 基础路径
VITE_API_BASE_URL=/api

# 是否启用 Mock
VITE_MOCK=false
```

## 部署

```bash
# Docker 构建
docker build -t tiz-web .

# 运行容器
docker run -p 80:80 tiz-web
```

## 许可证

私有项目
