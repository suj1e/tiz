import { Sparkles } from 'lucide-react'
import { cn } from '@/lib/utils'

export function TypingIndicator() {
  return (
    <div className="flex items-center gap-3">
      {/* AI Avatar with gradient */}
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-primary/80 shadow-sm">
        <Sparkles className="h-4 w-4 text-primary-foreground" />
      </div>

      {/* Typing bubble */}
      <div className="rounded-2xl rounded-bl-md bg-muted px-5 py-3">
        <div className="flex gap-1.5">
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground/60',
              '[animation-delay:0ms]',
            )}
          />
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground/60',
              '[animation-delay:150ms]',
            )}
          />
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground/60',
              '[animation-delay:300ms]',
            )}
          />
        </div>
      </div>
    </div>
  )
}
