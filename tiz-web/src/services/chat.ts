import { useAuthStore } from '@/stores/authStore'
import type { ChatStreamRequest, ConfirmGenerationRequest, GenerationSummary, Message } from '@/types'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api'

export type SSEEventType = 'session' | 'message' | 'confirm' | 'done' | 'error'

export interface SSEEvent {
  type: SSEEventType
  data: unknown
}

export interface SessionEvent {
  session_id: string
}

export interface MessageEvent {
  content: string
}

export interface ConfirmEvent {
  summary: GenerationSummary
}

export interface ErrorEvent {
  type: string
  code: string
  message: string
}

export function createChatStream(
  request: ChatStreamRequest,
  onEvent: (event: SSEEvent) => void,
  onError?: (error: Error) => void,
): { abort: () => void } {
  const controller = new AbortController()
  const token = useAuthStore.getState().token

  ;(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/chat/v1/stream`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify(request),
        signal: controller.signal,
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const reader = response.body?.getReader()
      if (!reader) {
        throw new Error('No reader available')
      }

      const decoder = new TextDecoder()
      let buffer = ''

      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        buffer += decoder.decode(value, { stream: true })
        const lines = buffer.split('\n')
        buffer = lines.pop() || ''

        for (const line of lines) {
          if (line.startsWith('event: ')) {
            const eventType = line.slice(7) as SSEEventType
            const dataLine = lines[lines.indexOf(line) + 1]
            if (dataLine?.startsWith('data: ')) {
              const data = JSON.parse(dataLine.slice(6))
              onEvent({ type: eventType, data })
            }
          }
        }
      }
    }
    catch (error) {
      if ((error as Error).name !== 'AbortError') {
        onError?.(error as Error)
      }
    }
  })()

  return {
    abort: () => controller.abort(),
  }
}

export const chatService = {
  confirmGeneration: (request: ConfirmGenerationRequest): Promise<{ knowledge_set_id: string }> => {
    return fetch(`${API_BASE_URL}/chat/v1/confirm`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(useAuthStore.getState().token
          ? { Authorization: `Bearer ${useAuthStore.getState().token}` }
          : {}),
      },
      body: JSON.stringify(request),
    }).then((res) => res.json().then((data) => data.data))
  },

  getHistory: (sessionId: string): Promise<{ messages: Message[] }> => {
    return fetch(`${API_BASE_URL}/chat/v1/history/${sessionId}`, {
      headers: {
        ...(useAuthStore.getState().token
          ? { Authorization: `Bearer ${useAuthStore.getState().token}` }
          : {}),
      },
    }).then((res) => res.json().then((data) => data.data))
  },
}
