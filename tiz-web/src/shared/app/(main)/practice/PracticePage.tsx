import { ArrowLeft, ArrowRight, CheckCircle } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { LoadingState } from '@/components/common/LoadingState'
import { QuestionCard } from '@/components/question/QuestionCard'
import { QuestionProgress } from '@/components/question/QuestionProgress'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { practiceService } from '@/services/practice'
import { usePracticeStore } from '@/stores/practiceStore'

export default function PracticePage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const {
    practiceId,
    questions,
    currentIndex,
    isComplete,
    setPracticeId,
    setQuestions,
    answerQuestion,
    nextQuestion,
    prevQuestion,
    complete,
  } = usePracticeStore()

  const [loading, setLoading] = useState(false)

  useEffect(() => {
    const startPractice = async () => {
      if (!id)
        return

      setLoading(true)
      try {
        const response = await practiceService.start(id)
        setPracticeId(response.practice_id)
        setQuestions(response.questions)
      }
      catch (error) {
        console.error('Failed to start practice:', error)
      }
      finally {
        setLoading(false)
      }
    }

    startPractice()
  }, [id])

  const handleComplete = async () => {
    if (!practiceId)
      return

    try {
      await practiceService.complete(practiceId)
      complete()
    }
    catch (error) {
      console.error('Failed to complete practice:', error)
    }
  }

  if (loading) {
    return <LoadingState text="加载练习题..." />
  }

  if (questions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-muted-foreground">没有找到练习题</p>
        <Button className="mt-4" onClick={() => navigate('/library')}>
          返回题库
        </Button>
      </div>
    )
  }

  const currentQuestion = questions[currentIndex]
  const isLastQuestion = currentIndex === questions.length - 1
  const hasAnswered = Boolean(currentQuestion?.userAnswer)

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <QuestionProgress
        current={currentIndex + 1}
        total={questions.length}
      />

      <QuestionCard
        question={currentQuestion}
        onAnswer={answer => answerQuestion(currentQuestion.id, answer)}
      />

      <div className="flex justify-between gap-2">
        <Button
          variant="outline"
          onClick={prevQuestion}
          disabled={currentIndex === 0}
        >
          <ArrowLeft className="mr-2 h-4 w-4" />
          上一题
        </Button>

        {isLastQuestion ? (
          <Button onClick={handleComplete} disabled={isComplete}>
            <CheckCircle className="mr-2 h-4 w-4" />
            完成练习
          </Button>
        ) : (
          <Button
            onClick={nextQuestion}
            className={cn(
              'transition-all duration-200',
              // 答题后下一题按钮添加脉动提示
              hasAnswered && 'animate-pulse-ring',
            )}
          >
            下一题
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        )}
      </div>
    </div>
  )
}
