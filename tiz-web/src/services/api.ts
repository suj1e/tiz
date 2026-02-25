import { useAuthStore } from '@/stores/authStore'
import type { ApiError as ApiErrorType, ApiResponse } from '@/types'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

export class ApiError extends Error {
  type: string
  code: string

  constructor(error: ApiErrorType['error']) {
    super(error.message)
    this.type = error.type
    this.code = error.code
    this.name = 'ApiError'
  }
}

interface RequestOptions extends RequestInit {
  token?: string
}

async function request<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const { token, ...fetchOptions } = options

  const headers = new Headers(options.headers)

  if (token) {
    headers.set('Authorization', `Bearer ${token}`)
  }

  if (options.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...fetchOptions,
    headers,
  })

  const data = await response.json()

  if (!response.ok) {
    const error = data as ApiErrorType['error']
    if (response.status === 401) {
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    throw new ApiError(error)
  }

  return (data as ApiResponse<T>).data
}

export const api = {
  get<T>(path: string, options?: RequestOptions): Promise<T> {
    return request<T>(path, { ...options, method: 'GET' })
  },

  post<T>(path: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return request<T>(path, {
      ...options,
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    })
  },

  patch<T>(path: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return request<T>(path, {
      ...options,
      method: 'PATCH',
      body: body ? JSON.stringify(body) : undefined,
    })
  },

  delete<T>(path: string, options?: RequestOptions): Promise<T> {
    return request<T>(path, { ...options, method: 'DELETE' })
  },
}

export function getAuthHeaders(): { Authorization: string } | undefined {
  const token = useAuthStore.getState().token
  return token ? { Authorization: `Bearer ${token}` } : undefined
}
