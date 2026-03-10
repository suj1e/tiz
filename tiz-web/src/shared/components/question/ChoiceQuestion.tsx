import { Check, X } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ChoiceQuestionProps {
  options: string[]
  selected?: string
  onSelect: (option: string) => void
  showFeedback?: boolean
  correctAnswer?: string
}

export function ChoiceQuestion({
  options,
  selected,
  onSelect,
  showFeedback,
  correctAnswer,
}: ChoiceQuestionProps) {
  return (
    <div className="space-y-2 sm:space-y-3">
      {options.map((option, index) => {
        const isSelected = selected === option
        const isCorrect = option === correctAnswer

        return (
          <button
            key={index}
            type="button"
            onClick={() => !showFeedback && onSelect(option)}
            disabled={showFeedback}
            className={cn(
              'group relative flex w-full items-center gap-2 rounded-lg border border-border p-3 text-left text-sm transition-all duration-200 sm:gap-3 sm:p-4 sm:text-base',
              // 未选中状态的悬停效果
              !isSelected && !showFeedback && 'hover:bg-muted/50 hover:border-primary/30 hover:shadow-sm',
              // 选中状态 - 左边框 + 背景色
              isSelected && !showFeedback && 'border-l-2 border-l-primary border-y-border border-r-border bg-primary/5',
              // 反馈状态 - 正确
              showFeedback && isCorrect && 'border-l-2 border-l-green-500 border-y-green-500/50 border-r-green-500/50 bg-green-50 dark:border-l-green-400 dark:bg-green-950/50',
              // 反馈状态 - 错误
              showFeedback && isSelected && !isCorrect && 'border-l-2 border-l-destructive border-y-destructive/50 border-r-destructive/50 bg-destructive/5 dark:border-l-destructive/80',
            )}
          >
            <span
              className={cn(
                'flex h-6 w-6 shrink-0 items-center justify-center rounded-full border border-border text-xs font-medium transition-colors sm:h-7 sm:w-7 sm:text-sm',
                isSelected && !showFeedback && 'border-primary bg-primary text-primary-foreground',
                showFeedback && isCorrect && 'border-green-500 bg-green-500 text-white dark:border-green-400 dark:bg-green-400',
              )}
            >
              {String.fromCharCode(65 + index)}
            </span>
            <span className="flex-1">{option}</span>
            {showFeedback && isCorrect && (
              <Check className="h-4 w-4 text-green-500 sm:h-5 sm:w-5 dark:text-green-400" />
            )}
            {showFeedback && isSelected && !isCorrect && (
              <X className="h-4 w-4 text-destructive sm:h-5 sm:w-5" />
            )}
          </button>
        )
      })}
    </div>
  )
}
