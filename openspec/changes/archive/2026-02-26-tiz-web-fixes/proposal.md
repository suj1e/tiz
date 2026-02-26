# tiz-web-fixes

修复 tiz-web 前端项目中发现的问题和完善缺失功能。

## 背景

tiz-web 项目以 mock 方式启动后，发现多处问题需要修复：

1. **题库页面崩溃** - API 响应解析错误导致 React 运行时错误
2. **错误处理不完善** - 缺少统一的错误页面和错误状态处理
3. **主题切换缺失** - 部分页面没有主题切换功能
4. **侧边栏导航重复** - 首页和对话功能完全重复
5. **版权年份错误** - 显示 2024 应为 2026
6. **项目图标缺失** - 仍使用 Vite 默认图标
7. **设置页功能不完整** - 缺少 webhook 配置和账户信息

## 目标

- 修复题库页面的关键 Bug
- 完善全站错误处理机制
- 统一主题切换功能
- 优化导航结构
- 完善设置页功能
- 生成项目图标

## 范围

### 包含

- 修复 content.ts API 响应解析
- 添加路由级 errorElement
- 所有页面添加 ThemeToggle
- 重新设计首页/对话页关系
- 设置页添加 webhook 配置
- 设置页完善账户信息
- 生成 favicon 和 logo
- 修改版权年份

### 不包含

- 后端 API 修改
- 新增业务功能
- 性能优化

## 影响范围

| 模块 | 改动类型 |
|------|----------|
| services/content.ts | Bug 修复 |
| router.tsx | 新增 errorElement |
| ErrorBoundary.tsx | UI 优化 |
| LandingPage, LoginPage, RegisterPage, ChatPage | 新增 ThemeToggle |
| HomePage | 重新设计或合并 |
| LibraryPage | 错误状态处理 |
| SettingsPage | 新增功能 |
| public/ | 新增图标 |

## 风险

- 首页/对话合并可能影响用户习惯，需要考虑路由兼容
- 错误处理改动较大，需要充分测试

## 成功标准

- 题库页面正常加载和显示
- 所有页面都能切换主题
- 运行时错误显示友好的错误页面而非 React 红屏
- 设置页包含完整的配置选项
- 项目有专属 favicon
