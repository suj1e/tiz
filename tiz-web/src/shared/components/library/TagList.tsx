import { cn } from '@/lib/utils'

interface TagListProps {
  tags: string[]
  maxVisible?: number
}

export function TagList({ tags, maxVisible = 3 }: TagListProps) {
  const visibleTags = tags.slice(0, maxVisible)
  const remainingCount = tags.length - maxVisible

  return (
    <div className="flex flex-wrap gap-1">
      {visibleTags.map((tag) => (
        <span
          key={tag}
          className="rounded-full bg-muted px-2 py-0.5 text-xs"
        >
          {tag}
        </span>
      ))}
      {remainingCount > 0 && (
        <span
          className={cn(
            'rounded-full bg-muted px-2 py-0.5 text-xs',
          )}
        >
          +{remainingCount}
        </span>
      )}
    </div>
  )
}
