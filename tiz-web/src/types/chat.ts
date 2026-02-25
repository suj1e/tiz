export interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  created_at: string
}

export interface ChatSession {
  id: string
  messages: Message[]
  summary?: GenerationSummary
  status: 'idle' | 'streaming' | 'confirming' | 'generating'
}

export interface GenerationSummary {
  title: string
  category: string
  tags: string[]
  difficulty: 'easy' | 'medium' | 'hard'
  question_count: number
  question_types: ('choice' | 'essay')[]
}
