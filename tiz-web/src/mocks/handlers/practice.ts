import { delay, http, HttpResponse } from 'msw'
import { mockLibrary } from '../data/library'

export const practiceHandlers = [
  http.post('/api/practice/v1/start', async () => {
    await delay(500)
    const questions = mockLibrary[0].questions.map((q) => ({
      ...q,
      userAnswer: undefined,
      isCorrect: undefined,
      score: undefined,
    }))

    return HttpResponse.json({
      data: {
        practice_id: `practice-${Date.now()}`,
        questions,
      },
    })
  }),

  http.post('/api/practice/v1/:id/answer', async () => {
    await delay(300)

    // Simulate answer checking
    const isCorrect = Math.random() > 0.3

    return HttpResponse.json({
      data: {
        is_correct: isCorrect,
        score: isCorrect ? 1 : 0,
        explanation: isCorrect ? '回答正确！' : '回答错误，正确答案见解析。',
      },
    })
  }),

  http.post('/api/practice/v1/:id/complete', async () => {
    await delay(300)
    return HttpResponse.json({
      data: {
        total: 10,
        correct: 7,
        score: 70,
      },
    })
  }),
]
