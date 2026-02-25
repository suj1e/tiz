import { Timer } from 'lucide-react'
import { cn } from '@/lib/utils'

interface QuizTimerProps {
  seconds: number
}

export function QuizTimer({ seconds }: QuizTimerProps) {
  const minutes = Math.floor(seconds / 60)
  const secs = seconds % 60

  const isLow = seconds < 60

  return (
    <div
      className={cn(
        'flex items-center justify-center gap-2 rounded-lg p-3 text-center sm:p-4',
        isLow ? 'bg-red-50 text-red-600 dark:bg-red-950' : 'bg-muted',
      )}
    >
      <Timer className="h-4 w-4 sm:h-5 sm:w-5" />
      <span className="font-mono text-xl font-bold sm:text-2xl">
        {String(minutes).padStart(2, '0')}:{String(secs).padStart(2, '0')}
      </span>
    </div>
  )
}
