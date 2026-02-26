import { delay, http, HttpResponse } from 'msw'
import type { WebhookConfig } from '@/types'

// 内存中存储 webhook 配置（mock 用）
let mockWebhook: WebhookConfig | null = null

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

  http.get('/api/user/v1/webhook', async () => {
    await delay(200)
    return HttpResponse.json({
      data: {
        webhook: mockWebhook,
      },
    })
  }),

  http.post('/api/user/v1/webhook', async ({ request }) => {
    await delay(200)
    const body = (await request.json()) as WebhookConfig

    mockWebhook = {
      url: body.url,
      enabled: body.enabled ?? true,
      events: body.events || [],
    }

    return HttpResponse.json({
      data: {
        webhook: mockWebhook,
      },
    })
  }),

  http.delete('/api/user/v1/webhook', async () => {
    await delay(200)
    mockWebhook = null
    return HttpResponse.json({
      data: null,
    })
  }),
]
