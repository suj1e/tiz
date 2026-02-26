# 任务清单

## P0 - 关键 Bug 修复

- [x] 修复 api.ts 响应解析问题
  - 添加 `raw` 选项支持返回完整响应
  - 保持向后兼容

- [x] 修复 content.ts API 调用
  - getLibraries 获取完整分页响应
  - getCategories 正确处理响应
  - getTags 正确处理响应

- [x] 修复 LibraryPage 数据加载
  - 修正数据解构
  - 添加错误状态处理
  - 使用 PageError 组件显示错误

## P1 - 错误处理完善

- [x] 创建 RootErrorBoundary 组件
  - 路由级错误边界
  - 美化的错误页面
  - 重试和返回首页按钮

- [x] router.tsx 添加 errorElement
  - 根路由添加错误边界
  - 懒加载失败处理

- [x] 优化 ErrorBoundary 样式
  - 更好的视觉设计
  - 错误详情展示（开发模式）
  - 一致的错误页面风格

- [x] 其他页面添加错误状态
  - HomePage 添加错误处理
  - PracticePage 添加错误处理
  - QuizPage 添加错误处理

## P1 - 主题切换统一

- [x] LandingPage 添加 ThemeToggle
  - 在 Header 右侧添加
  - 登录按钮左侧

- [x] AuthLayout 添加 ThemeToggle
  - LoginPage 继承
  - RegisterPage 继承

- [x] ChatPage 添加 ThemeToggle
  - 在 Header 右侧添加

## P1 - 导航优化

- [x] 侧边栏移除重复对话入口
  - Sidebar.tsx 移除对话导航项
  - /chat 路由保留（重定向到 /home 或独立使用）

- [x] 首页优化（可选）
  - 考虑添加快速入口卡片
  - 最近使用的题库

## P2 - 设置页完善

- [x] 添加 Webhook 配置卡片
  - Webhook URL 输入框
  - 事件多选（练习完成、测验完成等）
  - 测试 Webhook 按钮
  - 保存/取消按钮

- [x] 完善账户信息卡片
  - 显示用户邮箱
  - 修改密码入口（模态框或跳转）
  - 账户删除（带确认）

## P2 - 项目图标

- [x] 生成 favicon.svg
  - 设计简洁的 T 字母或书本图标
  - 使用项目主色调

- [x] 生成 favicon.ico
  - 32x32 和 16x16

- [x] 生成 apple-touch-icon.png
  - 180x180

- [x] 更新 index.html
  - 添加 favicon 链接
  - 添加 apple-touch-icon 链接
  - 更新 title 和 meta

## P2 - 响应式动态适配

- [x] 全局响应式布局检查与修复
  - 移除所有写死的尺寸 (如 `h-[50px]`, `min-h-[60vh]` 等)
  - 使用 Tailwind 响应式断点 (sm:, md:, lg:, xl:)
  - 确保移动端和 PC 端都有良好的布局

- [x] HomePage 响应式修复
  - min-h-[60vh] → 动态计算
  - 输入框尺寸响应式
  - 按钮尺寸响应式

- [x] ChatPage 响应式修复
  - h-[50px] w-[50px] 按钮尺寸动态化
  - min-h-[50px] 输入框动态化
  - 空状态区域动态高度

- [x] 通用组件响应式修复
  - ChatMessage max-w-[85%] → 动态或保持（这个是合理的）
  - ChatInput min-h-[60px] → 响应式
  - PageError/EmptyState/LoadingState min-h-[400px] → 动态

- [x] 测试各断点显示效果
  - 移动端 (< 640px)
  - 平板 (640px - 1024px)
  - 桌面 (> 1024px)

## P3 - 其他修复

- [x] 修改版权年份
  - LandingPage.tsx 2024 → 2026

## 测试

- [x] 验证题库页面正常加载
- [x] 验证错误页面正确显示
- [x] 验证所有页面主题切换
- [x] 验证设置页新功能
- [x] 验证 favicon 显示
