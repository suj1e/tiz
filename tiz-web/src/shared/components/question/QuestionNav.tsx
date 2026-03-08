import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface QuestionNavProps {
  current: number
  total: number
  onPrev: () => void
  onNext: () => void
  showSubmit?: boolean
  onSubmit?: () => void
}

export function QuestionNav({
  current,
  total,
  onPrev,
  onNext,
  showSubmit,
  onSubmit,
}: QuestionNavProps) {
  return (
    <div className="flex items-center justify-between">
      <Button
        variant="outline"
        onClick={onPrev}
        disabled={current === 0}
      >
        <ChevronLeft className="mr-2 h-4 w-4" />
        上一题
      </Button>

      <span className="text-sm text-muted-foreground">
        {current + 1} / {total}
      </span>

      {showSubmit && current === total - 1 ? (
        <Button onClick={onSubmit}>
          提交
        </Button>
      ) : (
        <Button onClick={onNext} disabled={current === total - 1}>
          下一题
          <ChevronRight className="ml-2 h-4 w-4" />
        </Button>
      )}
    </div>
  )
}
