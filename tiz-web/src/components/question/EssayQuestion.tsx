import { Textarea } from '@/components/ui/textarea'
import { AnswerFeedback } from './AnswerFeedback'

interface EssayQuestionProps {
  value: string
  onChange: (value: string) => void
  showFeedback?: boolean
  correctAnswer?: string
  rubric?: string
}

export function EssayQuestion({
  value,
  onChange,
  showFeedback,
  correctAnswer,
  rubric,
}: EssayQuestionProps) {
  return (
    <div className="space-y-4">
      <Textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="输入你的答案..."
        className="min-h-[120px]"
        disabled={showFeedback}
      />

      {showFeedback && correctAnswer && (
        <AnswerFeedback
          isCorrect={false}
          correctAnswer={correctAnswer}
          explanation={rubric}
        />
      )}
    </div>
  )
}
