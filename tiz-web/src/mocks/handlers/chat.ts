import { delay, http, HttpResponse } from 'msw'

export const chatHandlers = [
  http.post('/api/chat/v1/stream', async ({ request }) => {
    const body = (await request.json()) as { message: string; session_id?: string }

    const encoder = new TextEncoder()
    const stream = new ReadableStream({
      async start(controller) {
        const send = (event: string, data: object) => {
          controller.enqueue(
            encoder.encode(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`),
          )
        }

        // Send session ID
        const sessionId = body.session_id || `session-${Date.now()}`
        send('session', { session_id: sessionId })
        await delay(100)

        // Simulate AI response
        const responses = [
          '你好！我是你的学习助手。',
          '我可以帮你生成练习题，让你更高效地学习。',
          '请告诉我你想学习什么内容？比如：',
          '1. JavaScript 基础知识',
          '2. React 框架',
          '3. TypeScript 类型系统',
        ]

        for (const text of responses) {
          send('message', { content: text })
          await delay(300)
        }

        send('done', {})
        controller.close()
      },
    })

    return new Response(stream, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    })
  }),

  http.post('/api/chat/v1/confirm', async () => {
    await delay(500)
    return HttpResponse.json({
      data: {
        knowledge_set_id: `ks-${Date.now()}`,
      },
    })
  }),

  http.get('/api/chat/v1/history/:id', async () => {
    await delay(200)
    return HttpResponse.json({
      data: {
        messages: [
          {
            id: '1',
            role: 'user' as const,
            content: '我想学习 JavaScript 基础',
            created_at: new Date().toISOString(),
          },
          {
            id: '2',
            role: 'assistant' as const,
            content: '好的，我可以帮你生成 JavaScript 基础练习题。',
            created_at: new Date().toISOString(),
          },
        ],
      },
    })
  }),
]
