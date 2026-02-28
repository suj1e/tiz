import { delay, http, HttpResponse } from 'msw'
import { mockLibrary } from '../data/library'

export const contentHandlers = [
  http.post('/api/content/v1/generate', async () => {
    await delay(1000)
    const library = mockLibrary[0]
    return HttpResponse.json({
      data: {
        knowledge_set: {
          id: library.id,
          title: library.title,
          category: library.category,
          tags: library.tags,
          difficulty: library.difficulty,
        },
        questions: library.questions.slice(0, 3),
        batch: {
          current: 1,
          total: 2,
          has_more: true,
        },
      },
    })
  }),

  http.get('/api/content/v1/generate/:id/batch', async ({ request }) => {
    await delay(500)
    const url = new URL(request.url)
    const page = Number.parseInt(url.searchParams.get('page') || '2')
    const library = mockLibrary[0]

    return HttpResponse.json({
      data: {
        questions: library.questions.slice(3, 6),
        batch: {
          current: page,
          total: 2,
          has_more: false,
        },
      },
    })
  }),

  http.get('/api/content/v1/library', async ({ request }) => {
    await delay(300)
    const url = new URL(request.url)
    const pageSize = Number.parseInt(url.searchParams.get('page_size') || '10')

    const libraries = mockLibrary.map((lib) => ({
      id: lib.id,
      title: lib.title,
      category: lib.category,
      tags: lib.tags,
      difficulty: lib.difficulty,
      question_count: lib.question_count,
      created_at: lib.created_at,
    }))

    // For mock, return all data with has_more: false
    return HttpResponse.json({
      data: libraries,
      has_more: false,
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
      data: {
        categories: [
          { name: '编程基础', count: 5 },
          { name: '前端开发', count: 3 },
          { name: '后端开发', count: 2 },
        ],
      },
    })
  }),

  http.get('/api/content/v1/tags', async () => {
    await delay(200)
    return HttpResponse.json({
      data: {
        tags: [
          { name: 'JavaScript', count: 8 },
          { name: 'TypeScript', count: 5 },
          { name: 'React', count: 4 },
          { name: 'CSS', count: 3 },
        ],
      },
    })
  }),
]
