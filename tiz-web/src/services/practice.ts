import { api } from './api'
import type { QuestionWithAnswer } from '@/types'

interface StartPracticeResponse {
  practice_id: string
  questions: QuestionWithAnswer[]
}

interface SubmitAnswerResponse {
  correct: boolean
  score?: number
  explanation?: string
  ai_feedback?: string
}

interface CompletePracticeResponse {
  total: number
  correct: number
  score: number
}

export const practiceService = {
  start: (knowledgeSetId: string): Promise<StartPracticeResponse> => {
    return api.post('/practice/v1/start', { knowledge_set_id: knowledgeSetId })
  },

  submitAnswer: (
    practiceId: string,
    questionId: string,
    answer: string,
  ): Promise<SubmitAnswerResponse> => {
    return api.post(`/practice/v1/${practiceId}/answer`, {
      question_id: questionId,
      answer,
    })
  },

  complete: (practiceId: string): Promise<CompletePracticeResponse> => {
    return api.post(`/practice/v1/${practiceId}/complete`)
  },
}
