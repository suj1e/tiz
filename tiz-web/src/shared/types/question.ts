export type QuestionType = 'choice' | 'essay'
export type Difficulty = 'easy' | 'medium' | 'hard'

export interface Question {
  id: string
  type: QuestionType
  content: string
  options?: string[]
  answer: string
  explanation?: string
  rubric?: string
}

export interface QuestionWithAnswer extends Question {
  userAnswer?: string
  isCorrect?: boolean
  score?: number
}
