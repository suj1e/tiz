import type { KnowledgeSet } from '@/types'
import { mockQuestions } from './questions'

export const mockLibrary: KnowledgeSet[] = [
  {
    id: 'ks-1',
    user_id: 'user-1',
    title: 'JavaScript 基础知识',
    category: '编程基础',
    tags: ['JavaScript', '前端'],
    source_prompt: '我想学习 JavaScript 基础知识',
    difficulty: 'easy',
    question_count: 10,
    questions: mockQuestions,
    created_at: '2024-01-15T10:00:00Z',
    updated_at: '2024-01-15T10:00:00Z',
  },
  {
    id: 'ks-2',
    user_id: 'user-1',
    title: 'React 框架进阶',
    category: '前端开发',
    tags: ['React', 'Hooks', '前端'],
    source_prompt: '帮我生成 React 进阶练习题',
    difficulty: 'medium',
    question_count: 8,
    questions: mockQuestions.slice(0, 8),
    created_at: '2024-02-01T14:30:00Z',
    updated_at: '2024-02-01T14:30:00Z',
  },
  {
    id: 'ks-3',
    user_id: 'user-1',
    title: 'TypeScript 类型系统',
    category: '前端开发',
    tags: ['TypeScript', '类型', '前端'],
    source_prompt: '我想练习 TypeScript 类型相关的内容',
    difficulty: 'hard',
    question_count: 6,
    questions: mockQuestions.slice(0, 6),
    created_at: '2024-02-20T09:00:00Z',
    updated_at: '2024-02-20T09:00:00Z',
  },
]
