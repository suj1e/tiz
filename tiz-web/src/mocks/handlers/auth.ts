import { http, HttpResponse, delay } from 'msw'
import { mockUsers } from '../data/users'

export const authHandlers = [
  http.post('/api/auth/v1/register', async ({ request }) => {
    await delay(500)
    const body = (await request.json()) as { email: string; password: string }

    const existingUser = mockUsers.find((u) => u.email === body.email)
    if (existingUser) {
      return HttpResponse.json(
        {
          error: {
            type: 'validation_error',
            code: 'email_exists',
            message: '该邮箱已被注册',
          },
        },
        { status: 400 },
      )
    }

    const newUser = {
      id: `user-${Date.now()}`,
      email: body.email,
      created_at: new Date().toISOString(),
      settings: { theme: 'system' as const },
    }

    return HttpResponse.json({
      data: {
        user: newUser,
        token: `mock-token-${Date.now()}`,
      },
    })
  }),

  http.post('/api/auth/v1/login', async ({ request }) => {
    await delay(500)
    const body = (await request.json()) as { email: string; password: string }

    const user = mockUsers.find((u) => u.email === body.email)
    if (!user) {
      return HttpResponse.json(
        {
          error: {
            type: 'authentication_error',
            code: 'invalid_credentials',
            message: '邮箱或密码错误',
          },
        },
        { status: 401 },
      )
    }

    return HttpResponse.json({
      data: {
        user,
        token: `mock-token-${user.id}`,
      },
    })
  }),

  http.post('/api/auth/v1/logout', async () => {
    await delay(200)
    return HttpResponse.json({ data: {} })
  }),

  http.get('/api/auth/v1/me', async ({ request }) => {
    await delay(200)
    const authHeader = request.headers.get('Authorization')

    if (!authHeader?.startsWith('Bearer ')) {
      return HttpResponse.json(
        {
          error: {
            type: 'authentication_error',
            code: 'token_invalid',
            message: '未授权',
          },
        },
        { status: 401 },
      )
    }

    const user = mockUsers[0]
    return HttpResponse.json({ data: user })
  }),
]
