## Why

tiz-web 当前为单一构建，无法针对桌面端和移动端进行独立优化。同时，项目需要支持飞书企业内应用的网页应用集成，实现飞书免登功能。

核心需求：
1. **多端独立入口**：桌面端 (tiz.com) 和移动端 (m.tiz.com) 使用不同 URL，各自优化
2. **飞书免登集成**：飞书桌面端和移动端打开网页应用时自动完成身份认证
3. **用户体系合并**：飞书登录用户与邮箱注册用户可自动绑定或手动关联

## What Changes

### 前端架构重构

- **BREAKING** 项目结构改为单仓库双构建 (monorepo with dual build)
- 新增 `src/desktop/` 目录：桌面端入口、路由、布局
- 新增 `src/mobile/` 目录：移动端入口、路由、布局
- 新增 `src/shared/` 目录：共享的页面、组件、stores、services
- 新增 `src/lark/` 目录：飞书集成逻辑
- 新增 `vite.config.desktop.ts` 和 `vite.config.mobile.ts` 双构建配置
- 新增 `index.desktop.html` 和 `index.mobile.html` 入口 HTML

### 布局分离

- 桌面端 AppLayout：侧边栏导航 + 顶部 Header
- 移动端 AppLayout：底部导航栏 (BottomNav) + 简化 Header
- 两端共享相同的页面组件 (HomePage, LibraryPage, ChatPage 等)

### 飞书免登

- 检测飞书环境 (UA 包含 "Lark" 或 "Feishu")
- 加载飞书 H5 SDK
- 调用 `tt.requestAuthCode` 获取 auth code
- 调用后端 `/auth/v1/lark/login` 完成登录
- 两端入口 (main.tsx) 各自处理飞书免登流程

### 后端新增接口

- `POST /auth/v1/lark/login`：飞书免登接口，遵循现有 API 响应规范
  - Request: `{ code: string }`
  - Response: `{ data: { user: User, token: string } }` (与普通登录相同)
- 数据库 `users` 表新增字段：`lark_open_id` (VARCHAR(64), UNIQUE)

### 部署配置

- Nginx 配置 User-Agent 检测，移动设备 301 重定向到 m.tiz.com
- 飞书开放平台配置：桌面端主页 tiz.com，移动端主页 m.tiz.com

## Capabilities

### New Capabilities

- `lark-auth`：飞书企业内应用免登能力，支持自动识别飞书环境并完成身份认证

### Modified Capabilities

- `auth-api`：新增飞书登录接口，支持通过飞书 auth code 完成认证
- `frontend-architecture`：前端架构从单构建改为双构建，支持桌面端和移动端独立部署

## Impact

### 前端文件变更

| 类型 | 文件/目录 | 变更说明 |
|------|-----------|----------|
| 新增 | src/desktop/ | 桌面端入口和布局 |
| 新增 | src/mobile/ | 移动端入口和布局 |
| 新增 | src/shared/ | 共享代码（从 src/ 迁移） |
| 新增 | src/lark/ | 飞书集成逻辑 |
| 新增 | vite.config.desktop.ts | 桌面端构建配置 |
| 新增 | vite.config.mobile.ts | 移动端构建配置 |
| 新增 | index.desktop.html | 桌面端 HTML |
| 新增 | index.mobile.html | 移动端 HTML |
| 修改 | package.json | 新增构建脚本 |
| 迁移 | src/app/ → src/shared/app/ | 页面组件 |
| 迁移 | src/components/ → src/shared/components/ | 共享组件 |
| 迁移 | src/stores/ → src/shared/stores/ | 状态管理 |
| 迁移 | src/services/ → src/shared/services/ | API 服务 |
| 迁移 | src/hooks/ → src/shared/hooks/ | 自定义 Hooks |
| 迁移 | src/types/ → src/shared/types/ | 类型定义 |

### 后端文件变更

| 服务 | 文件 | 变更类型 |
|------|------|----------|
| authsrv | LarkAuthController.java (新增) | 飞书登录控制器 |
| authsrv | LarkAuthService.java (新增) | 飞书登录服务 |
| authsrv | LarkLoginRequest.java (新增) | 请求 DTO |
| authsrv | User.java | 新增 lark_open_id 字段 |
| authsrv | V{N}__add_lark_open_id.sql (新增) | 数据库迁移 |

### 基础设施变更

| 组件 | 变更说明 |
|------|----------|
| Nginx | 新增 m.tiz.com server 配置，设备检测重定向 |
| SSL 证书 | 使用现有通配符证书 (*.tiz.com) |
| 飞书开放平台 | 新建企业自建应用，配置网页应用地址 |

## Migration Plan

### Phase 1: 代码重组 (本地可验证)

1. 创建 src/desktop/, src/mobile/, src/shared/ 目录结构
2. 移动现有代码到 src/shared/
3. 创建 desktop/mobile 入口文件 (main.tsx, App.tsx, router.tsx)
4. 配置双构建 (vite.config.*.ts)
5. 验证: `pnpm build:desktop && pnpm build:mobile`

### Phase 2: 布局分离 (本地可验证)

1. 创建桌面端 AppLayout (侧边栏布局)
2. 创建移动端 AppLayout (底部导航布局)
3. 调整 Header/Sidebar/BottomNav 组件
4. 验证: 分别启动桌面端和移动端查看布局

### Phase 3: 飞书集成 (本地可验证 - Mock 模式)

1. 创建 src/lark/ 目录和飞书免登逻辑
2. 在 desktop/mobile 入口集成飞书免登
3. MSW 添加 /auth/v1/lark/login mock handler
4. 验证: 本地用 mock 测试飞书登录流程

### Phase 3.5: 后端实现 (需服务器/飞书配置)

1. 后端新增 /auth/v1/lark/login 接口
2. 数据库添加 lark_open_id 字段
3. 飞书开放平台创建应用、配置权限
4. 验证: 真实飞书环境测试免登

### Phase 4: 部署配置 (需服务器)

1. 配置 Nginx (设备检测 + 重定向)
2. 配置 CI/CD 双构建和部署
3. 验证: 生产环境
