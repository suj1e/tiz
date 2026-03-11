## Context

tiz-web 是一个基于 React 19 + Vite 的前端应用，使用 Zustand 进行状态管理。性能分析发现以下问题：

1. **串行异步操作**: AuthProvider 和 LoginPage 中存在独立的异步操作被串行执行
2. **派生状态在 useEffect 中计算**: LibraryPage 使用 useEffect + useState 计算过滤后的列表，导致额外渲染周期
3. **大列表缺少渲染优化**: LibraryList 渲染大量卡片时没有使用 content-visibility

当前技术栈：
- React 19 (支持 useMemo、Promise.all)
- Tailwind CSS 4.x (支持 content-visibility)
- Vite 7.x (支持 tree-shaking)

## Goals / Non-Goals

**Goals:**
- 将独立的串行异步操作改为 Promise.all 并行执行
- 将 useEffect 计算的派生状态改为 useMemo
- 为大列表添加 content-visibility CSS 优化
- 减少不必要的渲染周期

**Non-Goals:**
- 不引入新的外部依赖（如 react-virtualized）
- 不修改 API 层或后端服务
- 不改变现有 UI/UX 行为
- 不处理 barrel imports（影响较小，留作后续优化）

## Decisions

### 1. 使用 Promise.all 并行化独立异步操作

**决策**: 在 AuthProvider 和 LoginPage 中使用 Promise.all 并行执行独立的异步操作

**替代方案考虑**:
- ❌ Promise.allSettled: 不需要部分失败继续执行的场景
- ❌ 保持串行: 初始化时间较长，用户体验差

**实现**:
```typescript
// AuthProvider.tsx
const [userData] = await Promise.all([
  authService.getCurrentUser(),
  checkAiConfig()
])

// LoginPage.tsx - 注意 checkAiConfig 依赖 login 后的 token
// 需要确认 checkAiConfig 是否需要认证状态
```

### 2. 使用 useMemo 替代 useEffect + useState 计算派生状态

**决策**: LibraryPage 的 filteredLibraries 改用 useMemo 在渲染时计算

**理由**:
- useMemo 在同一渲染周期内计算，避免额外的渲染周期
- useEffect + useState 模式会触发两次渲染（一次原始数据，一次过滤后数据）

**实现**:
```typescript
const filteredLibraries = useMemo(() => {
  let filtered = libraries
  if (selectedCategory) {
    filtered = filtered.filter(lib => lib.category === selectedCategory)
  }
  if (selectedTags.length > 0) {
    filtered = filtered.filter(lib =>
      selectedTags.some(tag => lib.tags.includes(tag))
    )
  }
  if (searchQuery) {
    const query = searchQuery.toLowerCase()
    filtered = filtered.filter(lib =>
      lib.title.toLowerCase().includes(query) ||
      lib.description.toLowerCase().includes(query)
    )
  }
  return filtered
}, [libraries, selectedCategory, selectedTags, searchQuery])
```

### 3. 使用 CSS content-visibility 优化列表渲染

**决策**: 为 LibraryList 中的卡片添加 content-visibility: auto

**替代方案考虑**:
- ❌ @tanstack/react-virtual: 引入新依赖，对于当前列表规模过度工程化
- ✅ content-visibility: 原生 CSS，零依赖，对于中等规模列表足够有效

**实现**:
```typescript
// 在 LibraryCard 或列表项外层添加
style={{ contentVisibility: 'auto' }}
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| Promise.all 中某个请求失败会导致整体失败 | 保持现有的 try-catch 错误处理，与当前行为一致 |
| useMemo 依赖数组遗漏导致计算不更新 | 仔细检查依赖项，使用 ESLint exhaustive-deps 规则 |
| content-visibility 可能导致滚动时短暂空白 | 设置 contain-intrinsic-size 作为占位高度 |
| checkAiConfig 可能依赖 login 后设置的 token | 需要验证 LoginPage 中 checkAiConfig 的调用时机 |

## Migration Plan

1. **AuthProvider.tsx**: 修改 initAuth 函数，Promise.all 并行化
2. **LoginPage.tsx**: 评估 checkAiConfig 依赖后决定是否并行化
3. **LibraryPage.tsx**: 删除 useEffect + useState，改用 useMemo
4. **LibraryList.tsx**: 添加 content-visibility 样式

**回滚策略**: 每个修改都是独立的，可以单独回滚。Git revert 即可。

## Open Questions

1. **LoginPage 中 checkAiConfig 的依赖**: 需要确认 checkAiConfig 是否需要 login 完成后的认证状态。如果需要，则无法并行化。
