import { cn } from '@/lib/utils'
import type { Category, Tag } from '@/types'

interface LibraryFilterProps {
  categories: Category[]
  tags: Tag[]
  selectedCategory: string | null
  selectedTags: string[]
  onCategoryChange?: (category: string | null) => void
  onTagToggle?: (tag: string) => void
}

export function LibraryFilter({
  categories,
  tags,
  selectedCategory,
  selectedTags,
  onCategoryChange,
  onTagToggle,
}: LibraryFilterProps) {
  return (
    <div className="space-y-6">
      <div>
        <h3 className="mb-3 font-medium">分类</h3>
        <div className="space-y-1">
          <button
            type="button"
            onClick={() => onCategoryChange?.(null)}
            className={cn(
              'w-full rounded-lg px-3 py-2 text-left text-sm transition-colors',
              !selectedCategory
                ? 'bg-primary text-primary-foreground'
                : 'hover:bg-accent',
            )}
          >
            全部
          </button>
          {categories.map((category) => (
            <button
              key={category.name}
              type="button"
              onClick={() => onCategoryChange?.(category.name)}
              className={cn(
                'flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm transition-colors',
                selectedCategory === category.name
                  ? 'bg-primary text-primary-foreground'
                  : 'hover:bg-accent',
              )}
            >
              <span>{category.name}</span>
              <span className="text-xs opacity-70">{category.count}</span>
            </button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="mb-3 font-medium">标签</h3>
        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => (
            <button
              key={tag.name}
              type="button"
              onClick={() => onTagToggle?.(tag.name)}
              className={cn(
                'rounded-full px-3 py-1 text-sm transition-colors',
                selectedTags.includes(tag.name)
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted hover:bg-muted/80',
              )}
            >
              {tag.name}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
