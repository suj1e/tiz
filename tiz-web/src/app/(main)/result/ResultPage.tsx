import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, XCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { QuizResult } from '@/components/quiz/QuizResult'
import { WrongAnswerReview } from '@/components/quiz/WrongAnswerReview'
import { LoadingState } from '@/components/common/LoadingState'
import { quizService } from '@/services/quiz'
import type { QuizResult as QuizResultType } from '@/types'

export default function ResultPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const [result, setResult] = useState<QuizResultType | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadResult = async () => {
      if (!id) return

      try {
        const data = await quizService.getResult(id)
        setResult(data)
      }
      catch (error) {
        console.error('Failed to load result:', error)
      }
      finally {
        setLoading(false)
      }
    }

    loadResult()
  }, [id])

  if (loading) {
    return <LoadingState text="加载结果..." />
  }

  if (!result) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-muted-foreground">没有找到测验结果</p>
        <Button className="mt-4" onClick={() => navigate('/library')}>
          返回题库
        </Button>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Button variant="ghost" onClick={() => navigate('/library')}>
        <ArrowLeft className="mr-2 h-4 w-4" />
        返回题库
      </Button>

      <QuizResult
        score={result.score}
        total={result.total}
        correctCount={result.correct_count}
        completedAt={result.completed_at}
      />

      {result.wrong_answers.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <XCircle className="h-5 w-5 text-destructive" />
              错题回顾
            </CardTitle>
          </CardHeader>
          <CardContent>
            <WrongAnswerReview wrongAnswers={result.wrong_answers} />
          </CardContent>
        </Card>
      )}

      <div className="flex justify-center gap-4">
        <Button variant="outline" onClick={() => navigate('/library')}>
          返回题库
        </Button>
        <Button onClick={() => navigate(`/quiz/${result.knowledge_set_id}`)}>
          重新测验
        </Button>
      </div>
    </div>
  )
}
