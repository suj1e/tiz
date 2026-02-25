import { ChatMessage } from './ChatMessage'
import { ChatInput } from './ChatInput'
import type { Message } from '@/types'

interface ChatPanelProps {
  messages: Message[]
  onSend: (message: string) => void
  isLoading?: boolean
}

export function ChatPanel({ messages, onSend, isLoading }: ChatPanelProps) {
  return (
    <div className="flex h-full flex-col">
      <div className="flex-1 overflow-auto p-4">
        <div className="space-y-4">
          {messages.map((message) => (
            <ChatMessage key={message.id} message={message} />
          ))}
        </div>
      </div>
      <ChatInput onSend={onSend} disabled={isLoading} />
    </div>
  )
}
