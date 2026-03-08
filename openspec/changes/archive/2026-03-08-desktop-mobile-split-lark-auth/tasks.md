## Phase 1: 代码重组

### 1.1 目录结构调整
- [x] 创建 `src/desktop/` 目录
- [x] 创建 `src/mobile/` 目录
- [x] 创建 `src/shared/` 目录
- [x] 创建 `src/lark/` 目录

### 1.2 代码迁移
- [x] 移动 `src/app/` → `src/shared/app/`
- [x] 移动 `src/components/` → `src/shared/components/`
- [x] 移动 `src/stores/` → `src/shared/stores/`
- [x] 移动 `src/services/` → `src/shared/services/`
- [x] 移动 `src/hooks/` → `src/shared/hooks/`
- [x] 移动 `src/types/` → `src/shared/types/`
- [x] 移动 `src/lib/` → `src/shared/lib/`
- [x] 移动 `src/mocks/` → `src/shared/mocks/`
- [x] 移动 `src/assets/` → `src/shared/assets/`
- [x] 移动 `src/index.css` → `src/shared/index.css`

### 1.3 桌面端入口
- [x] 创建 `src/desktop/main.tsx` 入口文件
- [x] 创建 `src/desktop/App.tsx` 根组件
- [x] 创建 `src/desktop/router.tsx` 路由配置
- [x] 创建 `index.desktop.html`

### 1.4 移动端入口
- [x] 创建 `src/mobile/main.tsx` 入口文件
- [x] 创建 `src/mobile/App.tsx` 根组件
- [x] 创建 `src/mobile/router.tsx` 路由配置
- [x] 创建 `index.mobile.html`

### 1.5 构建配置
- [x] 创建 `vite.config.desktop.ts`
- [x] 创建 `vite.config.mobile.ts`
- [x] 更新 `tsconfig.json` 路径别名
- [x] 更新 `package.json` scripts
- [x] 删除旧的 `vite.config.ts` 和 `index.html`

### 1.6 验证
- [x] 验证 `pnpm dev:desktop` 能正常启动
- [x] 验证 `pnpm dev:mobile` 能正常启动
- [x] 验证 `pnpm build:desktop` 能正常构建
- [x] 验证 `pnpm build:mobile` 能正常构建
- [x] 验证 `pnpm test` 测试通过

---

## Phase 2: 布局分离

### 2.1 桌面端布局
- [x] 创建 `src/desktop/layouts/AppLayout.tsx` (侧边栏布局)
- [x] 创建 `src/desktop/components/Sidebar.tsx`
- [x] 调整 `src/shared/components/layout/Header.tsx` 适配桌面端
- [x] 更新 `src/desktop/router.tsx` 使用桌面端布局

### 2.2 移动端布局
- [x] 创建 `src/mobile/layouts/AppLayout.tsx` (底部导航布局)
- [x] 创建 `src/mobile/components/BottomNav.tsx`
- [x] 调整 `src/shared/components/layout/Header.tsx` 适配移动端
- [x] 更新 `src/mobile/router.tsx` 使用移动端布局

### 2.3 共享布局组件
- [x] 移动 `src/shared/components/layout/` 到合适位置
- [x] 确保 `ProtectedRoute` 在两端都能正常工作
- [x] 确保 `AuthLayout` 在两端都能正常工作

### 2.4 验证
- [x] 验证桌面端布局显示正确 (侧边栏)
- [x] 验证移动端布局显示正确 (底部导航)
- [x] 验证两端导航功能正常
- [x] 验证响应式断点正确

---

## Phase 3: 飞书集成 (前端)

### 3.1 飞书 SDK 集成
- [x] 创建 `src/lark/types.ts` 类型定义
- [x] 创建 `src/lark/index.ts` SDK 加载和环境检测
- [x] 创建 `src/lark/auth.ts` 免登逻辑

### 3.2 服务层扩展
- [x] 在 `src/shared/services/auth.ts` 新增 `larkLogin` 方法
- [x] 在 `src/shared/types/api.ts` 新增飞书登录相关类型 (如需要)

### 3.3 入口集成
- [x] 在 `src/desktop/main.tsx` 集成飞书免登
- [x] 在 `src/mobile/main.tsx` 集成飞书免登

### 3.4 Mock 支持
- [x] 在 `src/shared/mocks/handlers/auth.ts` 新增 `/auth/v1/lark/login` handler
- [x] 添加 `?mock_lark=true` 参数支持模拟飞书环境

### 3.5 验证
- [x] 验证非飞书环境正常渲染
- [x] 验证 `?mock_lark=true` 时触发 mock 飞书登录
- [x] 验证飞书登录成功后 token 存储正确

---

## Phase 3.5: 飞书集成 (后端)

### 3.5.1 数据库
- [x] 创建数据库迁移脚本，新增 `lark_open_id` 字段
- [x] 更新 `User` 实体类

### 3.5.2 飞书 API 客户端
- [x] 添加飞书 SDK 依赖
- [x] 创建飞书 API 客户端配置
- [x] 实现获取用户信息的方法

### 3.5.3 登录接口
- [x] 创建 `LarkLoginRequest` DTO
- [x] 创建 `LarkAuthController`
- [x] 创建 `LarkAuthService`
- [x] 实现用户查找/创建/绑定逻辑

### 3.5.4 飞书开放平台
- [ ] 创建企业自建应用
- [ ] 配置应用权限 (`contact:user.base:readonly`)
- [ ] 配置桌面端主页 URL
- [ ] 配置移动端主页 URL
- [ ] 获取 App ID 和 App Secret

### 3.5.5 验证
- [ ] 验证接口响应格式符合 API 规范
- [ ] 验证新用户自动创建
- [ ] 验证已有用户自动绑定
- [ ] 在真实飞书环境测试免登流程

---

## Phase 4: 部署配置

### 4.1 Nginx 配置
- [x] 配置 tiz.dmall.ink server block
- [x] 配置 m.tiz.dmall.ink server block
- [x] 配置 User-Agent 检测和重定向
- [x] 配置 SSL 证书 (通配符 *.dmall.ink)

### 4.2 CI/CD
- [x] 更新构建流程支持双构建 (Dockerfile.desktop, Dockerfile.mobile)
- [x] 配置桌面端构建产物部署 (tiz-web-desktop 容器)
- [x] 配置移动端构建产物部署 (tiz-web-mobile 容器)

### 4.3 验证
- [x] 验证桌面端访问 tiz.dmall.ink 正常
- [x] 验证移动设备访问 tiz.dmall.ink 重定向到 m.tiz.dmall.ink
- [x] 验证 m.tiz.dmall.ink 直接访问正常
- [ ] 验证飞书桌面端打开应用正常
- [ ] 验证飞书移动端打开应用正常
