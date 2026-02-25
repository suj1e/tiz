import { useState, useRef, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { BookOpen, Send } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { ChatMessage } from '@/components/chat/ChatMessage'
import { TypingIndicator } from '@/components/chat/TypingIndicator'
import { useChatStore } from '@/stores/chatStore'
import { createChatStream, type SSEEvent } from '@/services/chat'
import { generateId } from '@/lib/utils'

export default function ChatPage() {
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
    <div className="flex h-screen flex-col bg-background">
      {/* Header */}
      <header className="shrink-0 border-b">
        <div className="mx-auto flex h-14 items-center justify-between px-3 sm:h-16 sm:px-4">
          <Link to="/" className="flex items-center gap-2 font-semibold text-base sm:text-lg">
            <BookOpen className="h-5 w-5 sm:h-6 sm:w-6" />
            <span>Tiz</span>
          </Link>
          <nav className="flex items-center gap-2 sm:gap-4">
            <Link to="/login">
              <Button variant="ghost" size="sm" className="sm:size-default">登录</Button>
            </Link>
            <Link to="/register">
              <Button size="sm" className="sm:size-default">注册</Button>
            </Link>
          </nav>
        </div>
      </header>

      {/* Chat Area */}
      <div className="flex-1 overflow-auto pb-4">
        <div className="mx-auto max-w-3xl px-3 py-4 sm:px-4 sm:py-8">
          {messages.length === 0 ? (
            <div className="flex min-h-[60vh] flex-col items-center justify-center text-center px-2">
              <h2 className="mb-2 text-xl font-semibold sm:text-2xl">开始学习之旅</h2>
              <p className="mb-6 text-sm text-muted-foreground sm:mb-8 sm:text-base">
                告诉我你想学习什么，我会帮你生成专属练习题
              </p>
              <div className="grid w-full max-w-xs gap-2 sm:gap-3">
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

      {/* Input Area - Fixed on mobile */}
      <div className="shrink-0 border-t bg-background">
        <div className="mx-auto max-w-3xl p-3 sm:p-4">
          <div className="flex gap-2">
            <Textarea
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="输入你想学习的内容..."
              className="min-h-[50px] resize-none text-sm sm:min-h-[60px] sm:text-base"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault()
                  handleSend()
                }
              }}
            />
            <Button
              size="icon"
              className="h-[50px] w-[50px] shrink-0 sm:h-auto sm:w-auto"
              onClick={handleSend}
              disabled={!input.trim() || status === 'streaming'}
            >
              <Send className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
