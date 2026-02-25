import { delay, http, HttpResponse } from 'msw'

export const userHandlers = [
  http.get('/api/user/v1/settings', async () => {
    await delay(200)
    return HttpResponse.json({
      data: {
        theme: 'system',
      },
    })
  }),

  http.patch('/api/user/v1/settings', async ({ request }) => {
    await delay(200)
    const body = (await request.json()) as { theme?: string }

    return HttpResponse.json({
      data: {
        theme: body.theme || 'system',
      },
    })
  }),
]
