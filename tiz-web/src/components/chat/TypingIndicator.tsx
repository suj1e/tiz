import { cn } from '@/lib/utils'

export function TypingIndicator() {
  return (
    <div className="flex items-center gap-3">
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted">
        <div className="flex gap-1">
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground',
              '[animation-delay:0ms]',
            )}
          />
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground',
              '[animation-delay:150ms]',
            )}
          />
          <span
            className={cn(
              'h-2 w-2 animate-bounce rounded-full bg-muted-foreground',
              '[animation-delay:300ms]',
            )}
          />
        </div>
      </div>
      <div className="rounded-lg bg-muted px-4 py-2">
        <p className="text-sm text-muted-foreground">正在输入...</p>
      </div>
    </div>
  )
}
