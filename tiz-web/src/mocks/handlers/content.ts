import { delay, http, HttpResponse } from 'msw'
import { mockLibrary } from '../data/library'

export const contentHandlers = [
  http.post('/api/content/v1/generate', async () => {
    await delay(1000)
    return HttpResponse.json({
      data: {
        knowledge_set_id: 'ks-1',
        questions: mockLibrary[0].questions.slice(0, 3),
      },
    })
  }),

  http.get('/api/content/v1/generate/:id/batch', async () => {
    await delay(500)
    return HttpResponse.json({
      data: {
        questions: mockLibrary[0].questions.slice(3, 6),
        has_more: false,
      },
    })
  }),

  http.get('/api/content/v1/library', async ({ request }) => {
    await delay(300)
    const url = new URL(request.url)
    const page = Number.parseInt(url.searchParams.get('page') || '1')
    const pageSize = Number.parseInt(url.searchParams.get('page_size') || '10')

    return HttpResponse.json({
      data: mockLibrary.map((lib) => ({
        id: lib.id,
        title: lib.title,
        category: lib.category,
        tags: lib.tags,
        difficulty: lib.difficulty,
        question_count: lib.question_count,
        created_at: lib.created_at,
      })),
      pagination: {
        page,
        page_size: pageSize,
        total: mockLibrary.length,
        total_pages: 1,
      },
    })
  }),

  http.get('/api/content/v1/library/:id', async ({ params }) => {
    await delay(200)
    const library = mockLibrary.find((lib) => lib.id === params.id)

    if (!library) {
      return HttpResponse.json(
        {
          error: {
            type: 'not_found_error',
            code: 'resource_not_found',
            message: '题库不存在',
          },
        },
        { status: 404 },
      )
    }

    return HttpResponse.json({ data: library })
  }),

  http.patch('/api/content/v1/library/:id', async ({ params, request }) => {
    await delay(300)
    const library = mockLibrary.find((lib) => lib.id === params.id)

    if (!library) {
      return HttpResponse.json(
        {
          error: {
            type: 'not_found_error',
            code: 'resource_not_found',
            message: '题库不存在',
          },
        },
        { status: 404 },
      )
    }

    const body = (await request.json()) as Partial<typeof library>
    Object.assign(library, body)

    return HttpResponse.json({ data: library })
  }),

  http.delete('/api/content/v1/library/:id', async () => {
    await delay(200)
    return HttpResponse.json({ data: {} })
  }),

  http.get('/api/content/v1/categories', async () => {
    await delay(200)
    return HttpResponse.json({
      data: [
        { id: 'cat-1', name: '编程基础', count: 5 },
        { id: 'cat-2', name: '前端开发', count: 3 },
        { id: 'cat-3', name: '后端开发', count: 2 },
      ],
    })
  }),

  http.get('/api/content/v1/tags', async () => {
    await delay(200)
    return HttpResponse.json({
      data: [
        { id: 'tag-1', name: 'JavaScript', count: 8 },
        { id: 'tag-2', name: 'TypeScript', count: 5 },
        { id: 'tag-3', name: 'React', count: 4 },
        { id: 'tag-4', name: 'CSS', count: 3 },
      ],
    })
  }),
]
