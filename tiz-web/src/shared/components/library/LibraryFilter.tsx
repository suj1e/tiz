import type { Category, Tag } from '@/types'
import { cn } from '@/lib/utils'

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
        <h3 className="mb-3 font-medium text-sm">分类</h3>
        <div className="space-y-1">
          <button
            type="button"
            onClick={() => onCategoryChange?.(null)}
            className={cn(
              'w-full rounded-lg px-3 py-2 text-left text-sm transition-all duration-200',
              !selectedCategory
                ? 'bg-primary text-primary-foreground shadow-sm'
                : 'hover:bg-accent hover:translate-x-1',
            )}
          >
            全部
          </button>
          {categories.map(category => (
            <button
              key={category.name}
              type="button"
              onClick={() => onCategoryChange?.(category.name)}
              className={cn(
                'flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm transition-all duration-200',
                selectedCategory === category.name
                  ? 'bg-primary text-primary-foreground shadow-sm'
                  : 'hover:bg-accent hover:translate-x-1',
              )}
            >
              <span>{category.name}</span>
              <span className={cn(
                'text-xs',
                selectedCategory === category.name ? 'opacity-80' : 'opacity-60',
              )}
              >
                {category.count}
              </span>
            </button>
          ))}
        </div>
      </div>

      <div>
        <h3 className="mb-3 font-medium text-sm">标签</h3>
        <div className="flex flex-wrap gap-2">
          {tags.map(tag => (
            <button
              key={tag.name}
              type="button"
              onClick={() => onTagToggle?.(tag.name)}
              className={cn(
                'rounded-full px-3 py-1 text-sm transition-all duration-200',
                selectedTags.includes(tag.name)
                  ? 'bg-primary text-primary-foreground shadow-sm'
                  : 'bg-muted hover:bg-muted/80 hover:shadow-sm',
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
