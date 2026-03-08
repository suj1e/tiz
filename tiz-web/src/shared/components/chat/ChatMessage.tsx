import { User, Bot } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { Message } from '@/types'

interface ChatMessageProps {
  message: Message
}

export function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.role === 'user'

  return (
    <div
      className={cn(
        'flex gap-2 sm:gap-3',
        isUser ? 'flex-row-reverse' : 'flex-row',
      )}
    >
      <div
        className={cn(
          'flex h-7 w-7 shrink-0 items-center justify-center rounded-full sm:h-8 sm:w-8',
          isUser ? 'bg-primary text-primary-foreground' : 'bg-muted',
        )}
      >
        {isUser ? <User className="h-3.5 w-3.5 sm:h-4 sm:w-4" /> : <Bot className="h-3.5 w-3.5 sm:h-4 sm:w-4" />}
      </div>
      <div
        className={cn(
          'max-w-[85%] rounded-lg px-3 py-2 sm:max-w-[80%] sm:px-4',
          isUser ? 'bg-primary text-primary-foreground' : 'bg-muted',
        )}
      >
        <p className="whitespace-pre-wrap text-sm sm:text-base">{message.content}</p>
      </div>
    </div>
  )
}
