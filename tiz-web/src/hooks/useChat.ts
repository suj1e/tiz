import { useCallback, useRef } from 'react'
import { useChatStore } from '@/stores/chatStore'
import { createChatStream, type SSEEvent } from '@/services/chat'
import { generateId } from '@/lib/utils'

export function useChat() {
  const abortControllerRef = useRef<{ abort: () => void } | null>(null)

  const {
    sessionId,
    messages,
    status,
    streamingContent,
    summary,
    setSessionId,
    addMessage,
    setStatus,
    appendStreamingContent,
    clearStreamingContent,
    setSummary,
    reset,
  } = useChatStore()

  const sendMessage = useCallback((content: string) => {
    if (!content.trim() || status === 'streaming') return

    const userMessage = {
      id: generateId(),
      role: 'user' as const,
      content: content.trim(),
      created_at: new Date().toISOString(),
    }

    addMessage(userMessage)
    setStatus('streaming')
    clearStreamingContent()

    const assistantMessage = {
      id: generateId(),
      role: 'assistant' as const,
      content: '',
      created_at: new Date().toISOString(),
    }
    addMessage(assistantMessage)

    abortControllerRef.current = createChatStream(
      { message: userMessage.content, session_id: sessionId || undefined },
      (event: SSEEvent) => {
        switch (event.type) {
          case 'session':
            setSessionId((event.data as { session_id: string }).session_id)
            break
          case 'message':
            appendStreamingContent((event.data as { content: string }).content)
            break
          case 'confirm':
            setSummary((event.data as { summary: typeof summary }).summary)
            setStatus('confirming')
            break
          case 'done':
            setStatus('idle')
            break
          case 'error':
            setStatus('idle')
            console.error('Chat error:', event.data)
            break
        }
      },
      () => setStatus('idle'),
    )
  }, [status, sessionId, addMessage, setStatus, clearStreamingContent, appendStreamingContent, setSessionId, setSummary])

  const abort = useCallback(() => {
    abortControllerRef.current?.abort()
    setStatus('idle')
  }, [setStatus])

  return {
    sessionId,
    messages,
    status,
    streamingContent,
    summary,
    sendMessage,
    abort,
    reset,
  }
}
