import type { ReactNode } from 'react'
import { FileQuestion } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

interface EmptyStateProps {
  icon?: ReactNode
  title: string
  description?: string
  action?: {
    label: string
    onClick: () => void
  }
  className?: string
}

export function EmptyState({ icon, title, description, action, className }: EmptyStateProps) {
  return (
    <div className={cn(
      'flex min-h-[50vh] flex-col items-center justify-center text-center p-4 animate-in fade-in duration-300',
      className
    )}>
      <div className="mb-4 text-muted-foreground">
        {icon || <FileQuestion className="h-12 w-12" />}
      </div>
      <h3 className="mb-2 text-lg font-semibold">{title}</h3>
      {description && (
        <p className="mb-4 text-sm text-muted-foreground max-w-sm">{description}</p>
      )}
      {action && (
        <Button onClick={action.onClick}>{action.label}</Button>
      )}
    </div>
  )
}
