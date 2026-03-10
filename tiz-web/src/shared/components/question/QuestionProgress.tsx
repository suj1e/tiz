import { cn } from '@/lib/utils'

interface QuestionProgressProps {
  current: number
  total: number
}

export function QuestionProgress({ current, total }: QuestionProgressProps) {
  const percentage = (current / total) * 100
  const isComplete = current === total

  return (
    <div className="space-y-2">
      <div className="flex justify-between text-sm">
        <span className="text-muted-foreground">进度</span>
        <span className="font-medium tabular-nums">{current} / {total}</span>
      </div>
      <div className="h-2.5 overflow-hidden rounded-full bg-muted">
        <div
          className={cn(
            'h-full transition-all duration-500 ease-out',
            isComplete
              ? 'bg-success'
              : 'bg-gradient-to-r from-primary to-accent'
          )}
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  )
}
