import { CheckCircle, XCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

interface AnswerFeedbackProps {
  isCorrect: boolean
  correctAnswer?: string
  explanation?: string
}

export function AnswerFeedback({ isCorrect, correctAnswer, explanation }: AnswerFeedbackProps) {
  return (
    <div
      className={cn(
        'rounded-lg p-4',
        isCorrect ? 'bg-green-50 dark:bg-green-950' : 'bg-red-50 dark:bg-red-950',
      )}
    >
      <div className="flex items-center gap-2">
        {isCorrect ? (
          <>
            <CheckCircle className="h-5 w-5 text-green-500" />
            <span className="font-medium text-green-700 dark:text-green-300">回答正确</span>
          </>
        ) : (
          <>
            <XCircle className="h-5 w-5 text-red-500" />
            <span className="font-medium text-red-700 dark:text-red-300">回答错误</span>
          </>
        )}
      </div>

      {!isCorrect && correctAnswer && (
        <div className="mt-2 text-sm">
          <p className="font-medium">正确答案：</p>
          <p className="mt-1 text-muted-foreground">{correctAnswer}</p>
        </div>
      )}

      {explanation && (
        <div className="mt-2 text-sm">
          <p className="font-medium">解析：</p>
          <p className="mt-1 text-muted-foreground">{explanation}</p>
        </div>
      )}
    </div>
  )
}
