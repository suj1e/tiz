import { api } from './api'
import type { QuestionWithAnswer, QuizResult } from '@/types'

interface StartQuizResponse {
  quiz_id: string
  questions: QuestionWithAnswer[]
  time_limit: number | null
}

export const quizService = {
  start: (
    knowledgeSetId: string,
    options?: { time_limit?: number },
  ): Promise<StartQuizResponse> => {
    return api.post('/quiz/v1/start', {
      knowledge_set_id: knowledgeSetId,
      ...options,
    })
  },

  submit: (
    quizId: string,
    answers: Array<{ question_id: string; answer: string }>,
  ): Promise<{ result_id: string }> => {
    return api.post(`/quiz/v1/${quizId}/submit`, { answers })
  },

  getResult: (resultId: string): Promise<QuizResult> => {
    return api.get(`/quiz/v1/result/${resultId}`)
  },
}
