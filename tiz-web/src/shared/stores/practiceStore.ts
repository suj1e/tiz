import { create } from 'zustand'
import type { QuestionWithAnswer } from '@/types'

interface PracticeState {
  practiceId: string | null
  knowledgeSetId: string | null
  questions: QuestionWithAnswer[]
  currentIndex: number
  isComplete: boolean
  startTime: number | null
}

interface PracticeActions {
  setPracticeId: (id: string | null) => void
  setKnowledgeSetId: (id: string | null) => void
  setQuestions: (questions: QuestionWithAnswer[]) => void
  setCurrentIndex: (index: number) => void
  answerQuestion: (questionId: string, answer: string) => void
  nextQuestion: () => void
  prevQuestion: () => void
  complete: () => void
  reset: () => void
}

type PracticeStore = PracticeState & PracticeActions

const initialState: PracticeState = {
  practiceId: null,
  knowledgeSetId: null,
  questions: [],
  currentIndex: 0,
  isComplete: false,
  startTime: null,
}

export const usePracticeStore = create<PracticeStore>((set) => ({
  ...initialState,
  setPracticeId: (practiceId) => set({ practiceId }),
  setKnowledgeSetId: (knowledgeSetId) => set({ knowledgeSetId }),
  setQuestions: (questions) => set({ questions, startTime: Date.now() }),
  setCurrentIndex: (currentIndex) => set({ currentIndex }),
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
  complete: () => set({ isComplete: true }),
  reset: () => set(initialState),
}))
