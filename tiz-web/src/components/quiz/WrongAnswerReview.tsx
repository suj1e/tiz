import { XCircle } from 'lucide-react'

interface WrongAnswer {
  question_id: string
  question: string
  user_answer: string
  correct_answer: string
  explanation?: string
}

interface WrongAnswerReviewProps {
  wrongAnswers: WrongAnswer[]
}

export function WrongAnswerReview({ wrongAnswers }: WrongAnswerReviewProps) {
  return (
    <div className="space-y-4">
      {wrongAnswers.map((answer, index) => (
        <div
          key={answer.question_id}
          className="rounded-lg border p-4"
        >
          <div className="mb-3 flex items-start gap-2">
            <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-red-100 text-sm font-medium text-red-600 dark:bg-red-950">
              {index + 1}
            </span>
            <p className="font-medium">{answer.question}</p>
          </div>

          <div className="space-y-2 pl-8 text-sm">
            <div className="flex items-start gap-2">
              <XCircle className="mt-0.5 h-4 w-4 shrink-0 text-red-500" />
              <div>
                <span className="text-muted-foreground">你的答案：</span>
                <span className="text-red-600">{answer.user_answer}</span>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <span className="mt-0.5 h-4 w-4 shrink-0 text-center text-green-500">✓</span>
              <div>
                <span className="text-muted-foreground">正确答案：</span>
                <span className="text-green-600">{answer.correct_answer}</span>
              </div>
            </div>

            {answer.explanation && (
              <div className="mt-2 rounded bg-muted p-2 text-muted-foreground">
                <span className="font-medium">解析：</span>
                {answer.explanation}
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}
