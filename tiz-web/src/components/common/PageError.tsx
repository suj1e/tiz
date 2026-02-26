import { AlertCircle, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface PageErrorProps {
  title?: string
  message?: string
  onRetry?: () => void
}

export function PageError({
  title = '出错了',
  message = '加载失败，请重试',
  onRetry,
}: PageErrorProps) {
  return (
    <div className="flex min-h-[50vh] flex-col items-center justify-center text-center p-4">
      <AlertCircle className="mb-4 h-12 w-12 text-destructive" />
      <h3 className="mb-2 text-lg font-semibold">{title}</h3>
      <p className="mb-4 text-sm text-muted-foreground">{message}</p>
      {onRetry && (
        <Button variant="outline" onClick={onRetry}>
          <RefreshCw className="mr-2 h-4 w-4" />
          重试
        </Button>
      )}
    </div>
  )
}
