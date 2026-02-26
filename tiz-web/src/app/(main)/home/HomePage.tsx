import { useState, useRef, useEffect } from 'react'
import { Send } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { ChatMessage } from '@/components/chat/ChatMessage'
import { TypingIndicator } from '@/components/chat/TypingIndicator'
import { useChatStore } from '@/stores/chatStore'
import { createChatStream, type SSEEvent } from '@/services/chat'
import { generateId } from '@/lib/utils'

export default function HomePage() {
  const [input, setInput] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const abortControllerRef = useRef<{ abort: () => void } | null>(null)

  const {
    sessionId,
    messages,
    status,
    streamingContent,
    setSessionId,
    addMessage,
    setStatus,
    appendStreamingContent,
    clearStreamingContent,
  } = useChatStore()

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, streamingContent])

  const handleSend = () => {
    if (!input.trim() || status === 'streaming') return

    const userMessage = {
      id: generateId(),
      role: 'user' as const,
      content: input.trim(),
      created_at: new Date().toISOString(),
    }

    addMessage(userMessage)
    setInput('')
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
  }

  useEffect(() => {
    return () => {
      abortControllerRef.current?.abort()
    }
  }, [])

  return (
    <div className="flex h-full flex-col">
      <div className="flex-1 overflow-auto">
        <div className="mx-auto max-w-3xl p-4 sm:py-8">
          {messages.length === 0 ? (
            <div className="flex min-h-[50vh] flex-col items-center justify-center text-center sm:min-h-[60vh]">
              <h2 className="mb-2 text-xl font-semibold sm:text-2xl">开始学习之旅</h2>
              <p className="mb-6 text-sm text-muted-foreground sm:mb-8 sm:text-base">
                告诉我你想学习什么，我会帮你生成专属练习题
              </p>
              <div className="grid w-full max-w-sm gap-2 sm:gap-3">
                <Button
                  variant="outline"
                  className="justify-start text-sm"
                  onClick={() => setInput('我想学习 JavaScript 基础知识')}
                >
                  JavaScript 基础
                </Button>
                <Button
                  variant="outline"
                  className="justify-start text-sm"
                  onClick={() => setInput('帮我生成 React 相关的练习题')}
                >
                  React 框架
                </Button>
                <Button
                  variant="outline"
                  className="justify-start text-sm"
                  onClick={() => setInput('我想练习 TypeScript 类型系统')}
                >
                  TypeScript
                </Button>
              </div>
            </div>
          ) : (
            <div className="space-y-4 sm:space-y-6">
              {messages.map((message, index) => (
                <ChatMessage
                  key={message.id}
                  message={
                    message.role === 'assistant' && index === messages.length - 1 && status === 'streaming'
                      ? { ...message, content: streamingContent || message.content }
                      : message
                  }
                />
              ))}
              {status === 'streaming' && !streamingContent && <TypingIndicator />}
              <div ref={messagesEndRef} />
            </div>
          )}
        </div>
      </div>

      <div className="border-t">
        <div className="mx-auto max-w-3xl p-3 sm:p-4">
          <div className="flex gap-2">
            <Textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="输入你想学习的内容..."
              className="min-h-14 resize-none text-sm sm:min-h-16 sm:text-base"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault()
                  handleSend()
                }
              }}
            />
            <Button
              onClick={handleSend}
              disabled={!input.trim() || status === 'streaming'}
              className="shrink-0"
              size="icon"
            >
              <Send className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
