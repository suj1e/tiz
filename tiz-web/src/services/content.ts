import { api } from './api'
import type { Category, CursorResponse, KnowledgeSet, KnowledgeSetSummary, Tag } from '@/types'

export const contentService = {
  generateQuestions: (
    sessionId: string,
    save: boolean = true,
  ): Promise<{ knowledge_set: KnowledgeSet; questions: KnowledgeSet['questions']; batch: { current: number; total: number; has_more: boolean } }> => {
    return api.post('/content/v1/generate', {
      session_id: sessionId,
      save,
    })
  },

  getGenerateBatch: (
    knowledgeSetId: string,
    page: number,
  ): Promise<{ questions: KnowledgeSet['questions']; batch: { current: number; total: number; has_more: boolean } }> => {
    return api.get(`/content/v1/generate/${knowledgeSetId}/batch?page=${page}`)
  },

  getLibraries: (params?: {
    page_size?: number
    page_token?: string
    category?: string
    tag?: string
    keyword?: string
  }): Promise<CursorResponse<KnowledgeSetSummary>> => {
    const searchParams = new URLSearchParams()
    if (params?.page_size) searchParams.set('page_size', String(params.page_size))
    if (params?.page_token) searchParams.set('page_token', params.page_token)
    if (params?.category) searchParams.set('category', params.category)
    if (params?.tag) searchParams.set('tag', params.tag)
    if (params?.keyword) searchParams.set('keyword', params.keyword)

    const query = searchParams.toString()
    return api.get(`/content/v1/library${query ? `?${query}` : ''}`, { raw: true })
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
    return api.get('/content/v1/categories', { raw: true }).then((res) => res.data.categories)
  },

  getTags: (): Promise<Tag[]> => {
    return api.get('/content/v1/tags', { raw: true }).then((res) => res.data.tags)
  },
}
