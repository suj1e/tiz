import type { ApiError as ApiErrorType, ApiResponse } from '@/types'
import { useAuthStore } from '@/stores/authStore'

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
  /** Return raw response without extracting .data */
  raw?: boolean
  /** Skip automatic logout/redirect on 401 (for non-critical checks like AI config) */
  skipAuthRedirect?: boolean
}

async function request<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const { raw, skipAuthRedirect, ...fetchOptions } = options

  const headers = new Headers(options.headers)

  // Automatically get token from auth store
  const token = useAuthStore.getState().token
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

  // Safely parse JSON - handle non-JSON responses
  let data: Record<string, unknown>
  const contentType = response.headers.get('content-type')
  if (contentType?.includes('application/json')) {
    data = await response.json() as Record<string, unknown>
  }
  else {
    // Handle non-JSON responses (HTML error pages, plain text, etc.)
    const text = await response.text()
    if (!response.ok) {
      throw new ApiError({
        type: 'network_error',
        code: 'NON_JSON_RESPONSE',
        message: text || `请求失败 (${response.status})`,
      })
    }
    // For successful non-JSON responses, return empty object
    data = {}
  }

  if (!response.ok) {
    // Backend returns errors in format: { data: { type, code, message } }
    const errorBody = (data.data || data.error || data) as Record<string, unknown>
    const error = {
      type: (errorBody.type as string) || 'unknown_error',
      code: (errorBody.code as string) || 'UNKNOWN',
      message: (errorBody.message as string) || '请求失败',
    }
    if (response.status === 401 && !skipAuthRedirect) {
      useAuthStore.getState().logout()
      window.location.href = '/login'
    }
    if (error.code === 'AI_CONFIG_REQUIRED') {
      useAuthStore.getState().setHasAiConfig(false)
      window.location.href = '/ai-config'
    }
    throw new ApiError(error)
  }

  // Return raw response if requested, otherwise extract .data
  return raw ? data as T : ((data as unknown) as ApiResponse<T>).data
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

  put<T>(path: string, body?: unknown, options?: RequestOptions): Promise<T> {
    return request<T>(path, {
      ...options,
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    })
  },
}

export function getAuthHeaders(): { Authorization: string } | undefined {
  const token = useAuthStore.getState().token
  return token ? { Authorization: `Bearer ${token}` } : undefined
}
