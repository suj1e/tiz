## Why

tiz-web 前端存在多个 React 性能问题，导致不必要的渲染周期和较慢的用户体验。基于 Vercel React 最佳实践分析，发现串行异步操作、派生状态在 useEffect 中计算、大列表缺少渲染优化等问题。这些问题影响应用初始化速度、登录流程和列表渲染性能。

## What Changes

- **串行 await 并行化**: 将 AuthProvider 和 LoginPage 中的独立异步操作改为 Promise.all 并行执行
- **派生状态优化**: LibraryPage 中 filteredLibraries 从 useEffect+useState 改为 useMemo，消除额外渲染周期
- **列表渲染优化**: LibraryList 添加 content-visibility CSS 属性，提升大列表渲染性能
- **导入优化**: 减少 barrel imports 使用，改为直接导入

## Capabilities

### New Capabilities

- `react-performance-patterns`: 定义 React 性能优化模式，包括异步并行化、派生状态计算、列表渲染优化等最佳实践

### Modified Capabilities

(无现有 specs 需要修改)

## Impact

**修改文件:**
- `tiz-web/src/shared/providers/AuthProvider.tsx` - 并行化 getCurrentUser 和 checkAiConfig
- `tiz-web/src/shared/app/(auth)/login/LoginPage.tsx` - 并行化 login 和 checkAiConfig
- `tiz-web/src/shared/app/(main)/library/LibraryPage.tsx` - useEffect 派生状态改为 useMemo
- `tiz-web/src/shared/components/library/LibraryList.tsx` - 添加 content-visibility

**影响范围:**
- 用户认证流程初始化速度提升
- 登录流程响应速度提升
- 图书馆页面筛选性能提升（减少渲染周期）
- 大列表滚动性能提升

**依赖:**
- 无新增外部依赖
- 基于现有 React 19 API（Promise.all, useMemo, CSS content-visibility）
