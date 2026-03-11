import type { Message } from '@/types'
import { Sparkles } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ChatMessageProps {
  message: Message
}

export function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.role === 'user'

  return (
    <div
      className={cn(
        'flex gap-2 sm:gap-3 animate-message-in',
        isUser ? 'flex-row-reverse' : 'flex-row',
      )}
    >
      {/* Avatar */}
      {isUser
        ? (
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground">
              <span className="text-xs font-medium">你</span>
            </div>
          )
        : (
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-primary/80 shadow-sm">
              <Sparkles className="h-4 w-4 text-primary-foreground" />
            </div>
          )}

      {/* Message Bubble */}
      <div
        className={cn(
          'max-w-[85%] rounded-2xl px-4 py-2.5 sm:max-w-[80%] sm:px-5 sm:py-3',
          isUser
            ? 'bg-primary text-primary-foreground ml-auto rounded-br-md'
            : 'bg-muted rounded-bl-md',
        )}
      >
        <p className="whitespace-pre-wrap text-sm leading-relaxed sm:text-base">
          {message.content}
        </p>
      </div>
    </div>
  )
}
