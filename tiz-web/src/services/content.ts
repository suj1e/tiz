import { api } from './api'
import type { Category, KnowledgeSet, KnowledgeSetSummary, PaginatedResponse, Tag } from '@/types'

export const contentService = {
  generateQuestions: (
    sessionId: string,
    options?: {
      question_types?: ('choice' | 'essay')[]
      difficulty?: 'easy' | 'medium' | 'hard'
      question_count?: number
    },
  ): Promise<{ knowledge_set_id: string; questions: KnowledgeSet['questions'] }> => {
    return api.post('/content/v1/generate', {
      session_id: sessionId,
      ...options,
    })
  },

  getGenerateBatch: (
    knowledgeSetId: string,
    batch: number,
  ): Promise<{ questions: KnowledgeSet['questions']; has_more: boolean }> => {
    return api.get(`/content/v1/generate/${knowledgeSetId}/batch?batch=${batch}`)
  },

  getLibraries: (params?: {
    page?: number
    page_size?: number
    category?: string
    tags?: string[]
    search?: string
  }): Promise<PaginatedResponse<KnowledgeSetSummary>> => {
    const searchParams = new URLSearchParams()
    if (params?.page) searchParams.set('page', String(params.page))
    if (params?.page_size) searchParams.set('page_size', String(params.page_size))
    if (params?.category) searchParams.set('category', params.category)
    if (params?.tags?.length) searchParams.set('tags', params.tags.join(','))
    if (params?.search) searchParams.set('search', params.search)

    const query = searchParams.toString()
    return api.get(`/content/v1/library${query ? `?${query}` : ''}`)
  },

  getLibrary: (id: string): Promise<KnowledgeSet> => {
    return api.get(`/content/v1/library/${id}`)
  },

  updateLibrary: (
    id: string,
    data: Partial<Pick<KnowledgeSet, 'title' | 'category' | 'tags'>>,
  ): Promise<KnowledgeSet> => {
    return api.patch(`/content/v1/library/${id}`, data)
  },

  deleteLibrary: (id: string): Promise<void> => {
    return api.delete(`/content/v1/library/${id}`)
  },

  getCategories: (): Promise<Category[]> => {
    return api.get('/content/v1/categories')
  },

  getTags: (): Promise<Tag[]> => {
    return api.get('/content/v1/tags')
  },
}
