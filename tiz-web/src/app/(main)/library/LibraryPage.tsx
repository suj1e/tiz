import { useEffect, useState } from 'react'
import { Plus, Search } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { LibraryList } from '@/components/library/LibraryList'
import { LibraryFilter } from '@/components/library/LibraryFilter'
import { LoadingState } from '@/components/common/LoadingState'
import { EmptyState } from '@/components/common/EmptyState'
import { PageError } from '@/components/common/PageError'
import { useLibraryStore } from '@/stores/libraryStore'
import { contentService } from '@/services/content'
import { generateId } from '@/lib/utils'
import type { KnowledgeSetSummary } from '@/types'

export default function LibraryPage() {
  const {
    libraries,
    categories,
    tags,
    selectedCategory,
    selectedTags,
    searchQuery,
    isLoading,
    setLibraries,
    setCategories,
    setTags,
    setSearchQuery,
    setLoading,
    setSelectedCategory,
    toggleTag,
    addLibrary,
  } = useLibraryStore()

  const [filteredLibraries, setFilteredLibraries] = useState<KnowledgeSetSummary[]>([])
  const [error, setError] = useState<Error | null>(null)
  const [createOpen, setCreateOpen] = useState(false)
  const [newTitle, setNewTitle] = useState('')

  useEffect(() => {
    const loadData = async () => {
      setLoading(true)
      setError(null)
      try {
        const [libsRes, cats, tagsData] = await Promise.all([
          contentService.getLibraries(),
          contentService.getCategories(),
          contentService.getTags(),
        ])
        setLibraries(libsRes.data)
        setCategories(cats)
        setTags(tagsData)
      }
      catch (err) {
        setError(err instanceof Error ? err : new Error('加载失败'))
      }
      finally {
        setLoading(false)
      }
    }

    loadData()
  }, [])

  useEffect(() => {
    let filtered = libraries

    if (selectedCategory) {
      filtered = filtered.filter((lib) => lib.category === selectedCategory)
    }

    if (selectedTags.length > 0) {
      filtered = filtered.filter((lib) =>
        selectedTags.some((tag) => lib.tags.includes(tag)),
      )
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (lib) =>
          lib.title.toLowerCase().includes(query)
          || lib.tags.some((tag) => tag.toLowerCase().includes(query)),
      )
    }

    setFilteredLibraries(filtered)
  }, [libraries, selectedCategory, selectedTags, searchQuery])

  const handleCreate = () => {
    if (!newTitle.trim()) return

    // 创建空题库（仅本地，mock 模式）
    const newLibrary: KnowledgeSetSummary = {
      id: generateId(),
      title: newTitle.trim(),
      category: '',
      tags: [],
      difficulty: 'medium',
      question_count: 0,
      created_at: new Date().toISOString(),
    }

    addLibrary(newLibrary)
    setNewTitle('')
    setCreateOpen(false)
  }

  if (isLoading) {
    return <LoadingState />
  }

  if (error) {
    return (
      <PageError
        message={error.message}
        onRetry={() => {
          setError(null)
          setLoading(true)
          contentService.getLibraries().then(res => setLibraries(res.data)).finally(() => setLoading(false))
        }}
      />
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold">我的题库</h1>
          <p className="text-muted-foreground">管理你保存的练习题</p>
        </div>
        <Button onClick={() => setCreateOpen(true)}>
          <Plus className="mr-2 h-4 w-4" />
          新建题库
        </Button>
      </div>

      <div className="flex flex-col gap-4 lg:flex-row">
        <div className="flex-1">
          <div className="relative mb-4">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="搜索题库..."
              className="pl-9"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {filteredLibraries.length === 0 ? (
            <EmptyState
              title="暂无题库"
              description="开始对话生成练习题，然后保存到题库"
            />
          ) : (
            <LibraryList libraries={filteredLibraries} />
          )}
        </div>

        <div className="lg:w-64">
          <LibraryFilter
            categories={categories}
            tags={tags}
            selectedCategory={selectedCategory}
            selectedTags={selectedTags}
            onCategoryChange={setSelectedCategory}
            onTagToggle={toggleTag}
          />
        </div>
      </div>

      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>新建题库</DialogTitle>
            <DialogDescription>
              创建一个空题库，后续可通过对话生成题目添加
            </DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <Input
              placeholder="输入题库名称"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  handleCreate()
                }
              }}
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCreateOpen(false)}>
              取消
            </Button>
            <Button onClick={handleCreate} disabled={!newTitle.trim()}>
              创建
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
