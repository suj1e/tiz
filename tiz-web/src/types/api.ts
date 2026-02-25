export interface ApiResponse<T> {
  data: T
}

export interface ApiError {
  error: {
    type: string
    code: string
    message: string
  }
}

export interface PaginatedResponse<T> {
  data: T[]
  pagination: {
    page: number
    page_size: number
    total: number
    total_pages: number
  }
}

export interface LoginRequest {
  email: string
  password: string
}

export interface RegisterRequest {
  email: string
  password: string
}

export interface LoginResponse {
  user: import('./user').User
  token: string
}

export interface ChatStreamRequest {
  message: string
  session_id?: string
}

export interface ConfirmGenerationRequest {
  session_id: string
  question_types?: ('choice' | 'essay')[]
  difficulty?: 'easy' | 'medium' | 'hard'
  question_count?: number
}

export interface StartPracticeRequest {
  knowledge_set_id: string
}

export interface SubmitAnswerRequest {
  question_id: string
  answer: string
}

export interface StartQuizRequest {
  knowledge_set_id: string
  time_limit?: number
}

export interface SubmitQuizRequest {
  answers: Array<{
    question_id: string
    answer: string
  }>
}

export interface QuizResult {
  id: string
  knowledge_set_id: string
  score: number
  total: number
  correct_count: number
  wrong_answers: Array<{
    question_id: string
    question: string
    user_answer: string
    correct_answer: string
    explanation?: string
  }>
  completed_at: string
}
