import { delay, http, HttpResponse } from 'msw'
import { mockLibrary } from '../data/library'

export const quizHandlers = [
  http.post('/api/quiz/v1/start', async () => {
    await delay(500)
    const questions = mockLibrary[0].questions.map((q) => ({
      ...q,
      userAnswer: undefined,
      isCorrect: undefined,
      score: undefined,
    }))

    return HttpResponse.json({
      data: {
        quiz_id: `quiz-${Date.now()}`,
        questions,
        time_limit: 600, // 10 minutes
      },
    })
  }),

  http.post('/api/quiz/v1/:id/submit', async () => {
    await delay(500)
    return HttpResponse.json({
      data: {
        result_id: `result-${Date.now()}`,
      },
    })
  }),

  http.get('/api/quiz/v1/result/:id', async () => {
    await delay(300)
    const questions = mockLibrary[0].questions

    return HttpResponse.json({
      data: {
        id: `result-${Date.now()}`,
        knowledge_set_id: 'ks-1',
        score: 70,
        total: 100,
        correct_count: 7,
        wrong_answers: questions.slice(0, 3).map((q) => ({
          question_id: q.id,
          question: q.content,
          user_answer: '错误答案',
          correct_answer: q.answer,
          explanation: q.explanation,
        })),
        completed_at: new Date().toISOString(),
      },
    })
  }),
]
