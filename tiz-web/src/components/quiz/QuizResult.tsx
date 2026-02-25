import { Trophy, Target } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { formatDateTime } from '@/lib/utils'

interface QuizResultProps {
  score: number
  total: number
  correctCount: number
  completedAt: string
}

export function QuizResult({ score, total, correctCount, completedAt }: QuizResultProps) {
  const percentage = Math.round((score / total) * 100)
  const isPassed = percentage >= 60

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Trophy className={isPassed ? 'h-5 w-5 text-yellow-500' : 'h-5 w-5 text-muted-foreground'} />
          测验结果
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-center">
          <div className="text-center">
            <div className="mb-2 text-5xl font-bold">{percentage}%</div>
            <div className="text-muted-foreground">
              {isPassed ? '恭喜通过！' : '继续努力！'}
            </div>
          </div>
        </div>

        <div className="mt-6 grid grid-cols-3 gap-4 text-center">
          <div>
            <div className="text-2xl font-bold">{score}</div>
            <div className="text-sm text-muted-foreground">得分</div>
          </div>
          <div>
            <div className="flex items-center justify-center gap-1 text-2xl font-bold text-green-500">
              <Target className="h-5 w-5" />
              {correctCount}
            </div>
            <div className="text-sm text-muted-foreground">正确</div>
          </div>
          <div>
            <div className="text-2xl font-bold">{formatDateTime(completedAt)}</div>
            <div className="text-sm text-muted-foreground">完成时间</div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
