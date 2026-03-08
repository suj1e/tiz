import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, ArrowRight, CheckCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { QuestionCard } from '@/components/question/QuestionCard'
import { QuestionProgress } from '@/components/question/QuestionProgress'
import { LoadingState } from '@/components/common/LoadingState'
import { usePracticeStore } from '@/stores/practiceStore'
import { practiceService } from '@/services/practice'

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
      if (!id) return

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
    if (!practiceId) return

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

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <QuestionProgress
        current={currentIndex + 1}
        total={questions.length}
      />

      <QuestionCard
        question={currentQuestion}
        onAnswer={(answer) => answerQuestion(currentQuestion.id, answer)}
      />

      <div className="flex justify-between">
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
          <Button onClick={nextQuestion}>
            下一题
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        )}
      </div>
    </div>
  )
}
