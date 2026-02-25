import type { Difficulty, Question } from './question'

export interface KnowledgeSet {
  id: string
  user_id: string
  title: string
  category: string
  tags: string[]
  source_prompt: string
  difficulty: Difficulty
  question_count: number
  questions: Question[]
  created_at: string
  updated_at: string
}

export interface KnowledgeSetSummary {
  id: string
  title: string
  category: string
  tags: string[]
  difficulty: Difficulty
  question_count: number
  created_at: string
}

export interface Category {
  id: string
  name: string
  count: number
}

export interface Tag {
  id: string
  name: string
  count: number
}
