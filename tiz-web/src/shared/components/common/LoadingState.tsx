import { Loader2 } from 'lucide-react'

interface LoadingStateProps {
  text?: string
}

export function LoadingState({ text = '加载中...' }: LoadingStateProps) {
  return (
    <div className="flex min-h-[50vh] flex-col items-center justify-center">
      <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      <p className="mt-4 text-sm text-muted-foreground">{text}</p>
    </div>
  )
}
