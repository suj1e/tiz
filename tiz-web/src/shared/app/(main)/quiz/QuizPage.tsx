import { ArrowLeft, ArrowRight, Send } from 'lucide-react'
import { useCallback, useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { LoadingState } from '@/components/common/LoadingState'
import { QuestionCard } from '@/components/question/QuestionCard'
import { QuizTimer } from '@/components/quiz/QuizTimer'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { quizService } from '@/services/quiz'
import { useQuizStore } from '@/stores/quizStore'

export default function QuizPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const {
    quizId,
    questions,
    currentIndex,
    remainingTime,
    isComplete,
    setQuizId,
    setQuestions,
    setTimeLimit,
    decrementTime,
    answerQuestion,
    nextQuestion,
    prevQuestion,
    complete,
  } = useQuizStore()

  const [loading, setLoading] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    const startQuiz = async () => {
      if (!id)
        return

      setLoading(true)
      try {
        const response = await quizService.start(id)
        setQuizId(response.quiz_id)
        setQuestions(response.questions)
        setTimeLimit(response.time_limit)
      }
      catch (error) {
        console.error('Failed to start quiz:', error)
      }
      finally {
        setLoading(false)
      }
    }

    startQuiz()
  }, [id])

  const handleSubmit = useCallback(async () => {
    if (!quizId)
      return

    setSubmitting(true)
    try {
      const answers = questions.map(q => ({
        question_id: q.id,
        answer: q.userAnswer || '',
      }))
      const result = await quizService.submit(quizId, answers)
      complete()
      navigate(`/result/${result.result_id}`)
    }
    catch (error) {
      console.error('Failed to submit quiz:', error)
    }
    finally {
      setSubmitting(false)
    }
  }, [quizId, questions, complete, navigate])

  // Timer effect
  useEffect(() => {
    if (remainingTime === null || remainingTime <= 0 || isComplete)
      return

    const timer = setInterval(() => {
      decrementTime()
    }, 1000)

    return () => clearInterval(timer)
  }, [remainingTime, isComplete, decrementTime])

  // Auto submit when time runs out
  useEffect(() => {
    if (remainingTime === 0 && !isComplete) {
      handleSubmit()
    }
  }, [remainingTime, isComplete, handleSubmit])

  if (loading) {
    return <LoadingState text="加载测验..." />
  }

  if (questions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-muted-foreground">没有找到测验题目</p>
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
    <div className="mx-auto max-w-3xl space-y-4 sm:space-y-6">
      {remainingTime !== null && (
        <QuizTimer seconds={remainingTime} />
      )}

      <div className="text-center text-sm text-muted-foreground">
        题目
        {' '}
        <span className="font-medium tabular-nums">{currentIndex + 1}</span>
        {' '}
        /
        {' '}
        <span className="font-medium tabular-nums">{questions.length}</span>
      </div>

      <QuestionCard
        question={currentQuestion}
        onAnswer={answer => answerQuestion(currentQuestion.id, answer)}
      />

      <div className="flex justify-between gap-2">
        <Button
          variant="outline"
          size="sm"
          className="sm:size-default"
          onClick={prevQuestion}
          disabled={currentIndex === 0}
        >
          <ArrowLeft className="mr-1 h-3 w-3 sm:mr-2 sm:h-4 sm:w-4" />
          <span className="hidden sm:inline">上一题</span>
          <span className="sm:hidden">上一题</span>
        </Button>

        {isLastQuestion ? (
          <Button
            size="sm"
            className="sm:size-default"
            onClick={handleSubmit}
            disabled={submitting}
          >
            <Send className="mr-1 h-3 w-3 sm:mr-2 sm:h-4 sm:w-4" />
            提交
          </Button>
        ) : (
          <Button
            size="sm"
            className={cn(
              'sm:size-default transition-all duration-200',
              // 答题后下一题按钮添加脉动提示
              hasAnswered && 'animate-pulse-ring',
            )}
            onClick={nextQuestion}
          >
            <span className="hidden sm:inline">下一题</span>
            <span className="sm:hidden">下一题</span>
            <ArrowRight className="ml-1 h-3 w-3 sm:ml-2 sm:h-4 sm:w-4" />
          </Button>
        )}
      </div>
    </div>
  )
}
