import { Timer } from 'lucide-react'
import { cn } from '@/lib/utils'

interface QuizTimerProps {
  seconds: number
}

export function QuizTimer({ seconds }: QuizTimerProps) {
  const minutes = Math.floor(seconds / 60)
  const secs = seconds % 60

  // 最后30秒为紧张状态，超时为危险状态
  const isWarning = seconds > 0 && seconds <= 30
  const isCritical = seconds === 0

  return (
    <div
      className={cn(
        'mx-auto flex w-fit items-center justify-center gap-2.5 rounded-xl border p-3 text-center transition-all duration-300 sm:gap-3 sm:p-4',
        // 正常状态
        !isWarning && !isCritical && 'border-border bg-muted/50 text-foreground',
        // 紧张状态 (最后30秒) - warning 色
        isWarning && 'border-warning/50 bg-warning/10 text-warning animate-pulse',
        // 超时状态 - destructive 色
        isCritical && 'border-destructive/50 bg-destructive/10 text-destructive',
      )}
    >
      <Timer className={cn(
        'h-4 w-4 sm:h-5 sm:w-5',
        isWarning && 'animate-spin-slow',
        isCritical && 'animate-ping',
      )} />
      <span className="font-mono text-xl font-bold tabular-nums sm:text-2xl">
        {String(minutes).padStart(2, '0')}:{String(secs).padStart(2, '0')}
      </span>
    </div>
  )
}
