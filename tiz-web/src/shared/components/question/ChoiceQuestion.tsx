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
    <div className="space-y-2">
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
              'flex w-full items-center gap-2 rounded-lg border p-3 text-left text-sm transition-colors sm:gap-3 sm:p-4 sm:text-base',
              isSelected && !showFeedback && 'border-primary bg-primary/5',
              showFeedback && isCorrect && 'border-green-500 bg-green-50 dark:bg-green-950',
              showFeedback && isSelected && !isCorrect && 'border-red-500 bg-red-50 dark:bg-red-950',
              !showFeedback && 'hover:bg-accent',
            )}
          >
            <span
              className={cn(
                'flex h-6 w-6 shrink-0 items-center justify-center rounded-full border text-xs font-medium sm:text-sm',
                isSelected && 'border-primary bg-primary text-primary-foreground',
              )}
            >
              {String.fromCharCode(65 + index)}
            </span>
            <span className="flex-1">{option}</span>
            {showFeedback && isCorrect && (
              <Check className="h-4 w-4 text-green-500 sm:h-5 sm:w-5" />
            )}
            {showFeedback && isSelected && !isCorrect && (
              <X className="h-4 w-4 text-red-500 sm:h-5 sm:w-5" />
            )}
          </button>
        )
      })}
    </div>
  )
}
