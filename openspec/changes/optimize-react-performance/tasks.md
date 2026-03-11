## 1. 并行化异步操作

- [x] 1.1 AuthProvider.tsx: 使用 Promise.all 并行执行 getCurrentUser 和 checkAiConfig
- [x] 1.2 LoginPage.tsx: checkAiConfig 依赖 login() 设置的 token，无法并行化（已分析确认）
- [x] 1.3 验证：构建成功，认证流程结构正确

## 2. 优化派生状态计算

- [x] 2.1 LibraryPage.tsx: 删除 filteredLibraries 的 useEffect 和 useState
- [x] 2.2 LibraryPage.tsx: 使用 useMemo 计算 filteredLibraries
- [x] 2.3 验证：构建成功，筛选逻辑正确

## 3. 列表渲染优化

- [x] 3.1 LibraryList.tsx: 为列表项添加 content-visibility: auto 样式
- [x] 3.2 LibraryList.tsx: 添加 contain-intrinsic-size 占位高度防止布局偏移
- [x] 3.3 验证：构建成功

## 4. 测试与验证

- [x] 4.1 运行 pnpm lint 确保无 lint 错误（修改的文件已通过）
- [x] 4.2 运行 pnpm test - authStore 测试失败是预存在的 localStorage mock 问题
- [x] 4.3 构建验证 pnpm build 成功

## 实施完成

所有代码修改已完成并通过构建验证。
- AuthProvider: Promise.all 并行化
- LibraryPage: useEffect → useMemo 优化
- LibraryList: content-visibility 优化

手动测试建议：
- 登录流程测试
- 图书馆页面筛选测试（分类、标签、搜索）
- 大列表滚动性能测试
