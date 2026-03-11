import type { QuestionWithAnswer } from '@/types'
import { ChoiceQuestion } from './ChoiceQuestion'
import { EssayQuestion } from './EssayQuestion'

interface QuestionCardProps {
  question: QuestionWithAnswer
  onAnswer: (answer: string) => void
  showFeedback?: boolean
}

export function QuestionCard({ question, onAnswer, showFeedback = false }: QuestionCardProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm transition-all sm:p-6">
      <div className="mb-3 flex items-center gap-2 sm:mb-4">
        <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
          {question.type === 'choice' ? '选择题' : '简答题'}
        </span>
      </div>
      <p className="mb-4 text-base font-medium text-foreground sm:mb-6 sm:text-lg">{question.content}</p>

      {question.type === 'choice'
        ? (
            <ChoiceQuestion
              options={question.options || []}
              selected={question.userAnswer}
              onSelect={onAnswer}
              showFeedback={showFeedback}
              correctAnswer={question.answer}
            />
          )
        : (
            <EssayQuestion
              value={question.userAnswer || ''}
              onChange={onAnswer}
              showFeedback={showFeedback}
              correctAnswer={question.answer}
              rubric={question.rubric}
            />
          )}
    </div>
  )
}
