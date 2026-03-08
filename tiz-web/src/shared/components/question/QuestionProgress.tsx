interface QuestionProgressProps {
  current: number
  total: number
}

export function QuestionProgress({ current, total }: QuestionProgressProps) {
  const percentage = (current / total) * 100

  return (
    <div className="space-y-2">
      <div className="flex justify-between text-sm">
        <span className="text-muted-foreground">进度</span>
        <span className="font-medium">{current} / {total}</span>
      </div>
      <div className="h-2 overflow-hidden rounded-full bg-muted">
        <div
          className="h-full bg-primary transition-all"
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  )
}
