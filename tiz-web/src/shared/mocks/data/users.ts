import type { User } from '@/types'

export const mockUsers: User[] = [
  {
    id: 'user-1',
    email: 'demo@example.com',
    created_at: '2024-01-01T00:00:00Z',
    settings: {
      theme: 'system',
    },
  },
  {
    id: 'user-2',
    email: 'test@example.com',
    created_at: '2024-02-15T10:30:00Z',
    settings: {
      theme: 'dark',
    },
  },
]
