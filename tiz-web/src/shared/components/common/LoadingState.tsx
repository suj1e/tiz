import { Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'

interface LoadingStateProps {
  text?: string
  className?: string
}

export function LoadingState({ text = '加载中...', className }: LoadingStateProps) {
  return (
    <div className={cn(
      'flex min-h-[50vh] flex-col items-center justify-center animate-in fade-in duration-300',
      className,
    )}
    >
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
      <p className="mt-4 text-sm text-muted-foreground">{text}</p>
    </div>
  )
}
