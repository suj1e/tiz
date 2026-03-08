import { create } from 'zustand'
import type { QuestionWithAnswer, QuizResult } from '@/types'

interface QuizState {
  quizId: string | null
  knowledgeSetId: string | null
  questions: QuestionWithAnswer[]
  currentIndex: number
  timeLimit: number | null
  remainingTime: number | null
  isComplete: boolean
  result: QuizResult | null
  startTime: number | null
}

interface QuizActions {
  setQuizId: (id: string | null) => void
  setKnowledgeSetId: (id: string | null) => void
  setQuestions: (questions: QuestionWithAnswer[]) => void
  setCurrentIndex: (index: number) => void
  setTimeLimit: (seconds: number | null) => void
  setRemainingTime: (seconds: number | null) => void
  decrementTime: () => void
  answerQuestion: (questionId: string, answer: string) => void
  nextQuestion: () => void
  prevQuestion: () => void
  setResult: (result: QuizResult | null) => void
  complete: () => void
  reset: () => void
}

type QuizStore = QuizState & QuizActions

const initialState: QuizState = {
  quizId: null,
  knowledgeSetId: null,
  questions: [],
  currentIndex: 0,
  timeLimit: null,
  remainingTime: null,
  isComplete: false,
  result: null,
  startTime: null,
}

export const useQuizStore = create<QuizStore>((set) => ({
  ...initialState,
  setQuizId: (quizId) => set({ quizId }),
  setKnowledgeSetId: (knowledgeSetId) => set({ knowledgeSetId }),
  setQuestions: (questions) => set({ questions, startTime: Date.now() }),
  setCurrentIndex: (currentIndex) => set({ currentIndex }),
  setTimeLimit: (timeLimit) => set({ timeLimit, remainingTime: timeLimit }),
  setRemainingTime: (remainingTime) => set({ remainingTime }),
  decrementTime: () => set((state) => ({ remainingTime: Math.max((state.remainingTime ?? 0) - 1, 0) })),
  answerQuestion: (questionId, answer) =>
    set((state) => ({
      questions: state.questions.map((q) =>
        q.id === questionId ? { ...q, userAnswer: answer } : q,
      ),
    })),
  nextQuestion: () =>
    set((state) => ({
      currentIndex: Math.min(state.currentIndex + 1, state.questions.length - 1),
    })),
  prevQuestion: () => set((state) => ({ currentIndex: Math.max(state.currentIndex - 1, 0) })),
  setResult: (result) => set({ result }),
  complete: () => set({ isComplete: true }),
  reset: () => set(initialState),
}))
