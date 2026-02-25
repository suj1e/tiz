import { describe, it, expect, beforeEach } from 'vitest'
import { useAuthStore } from '@/stores/authStore'
import type { User } from '@/types'

describe('useAuthStore', () => {
  const mockUser: User = {
    id: 'user-1',
    email: 'test@example.com',
    created_at: '2024-01-01T00:00:00Z',
    settings: { theme: 'system' },
  }

  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: true,
    })
  })

  it('should have correct initial state', () => {
    const state = useAuthStore.getState()
    expect(state.user).toBeNull()
    expect(state.token).toBeNull()
    expect(state.isAuthenticated).toBe(false)
    expect(state.isLoading).toBe(true)
  })

  it('should set user', () => {
    useAuthStore.getState().setUser(mockUser)
    expect(useAuthStore.getState().user).toEqual(mockUser)
    expect(useAuthStore.getState().isAuthenticated).toBe(true)
  })

  it('should set user to null', () => {
    useAuthStore.getState().setUser(mockUser)
    useAuthStore.getState().setUser(null)
    expect(useAuthStore.getState().user).toBeNull()
    expect(useAuthStore.getState().isAuthenticated).toBe(false)
  })

  it('should set token', () => {
    useAuthStore.getState().setToken('test-token')
    expect(useAuthStore.getState().token).toBe('test-token')
  })

  it('should login', () => {
    useAuthStore.getState().login(mockUser, 'test-token')
    expect(useAuthStore.getState().user).toEqual(mockUser)
    expect(useAuthStore.getState().token).toBe('test-token')
    expect(useAuthStore.getState().isAuthenticated).toBe(true)
    expect(useAuthStore.getState().isLoading).toBe(false)
  })

  it('should logout', () => {
    useAuthStore.getState().login(mockUser, 'test-token')
    useAuthStore.getState().logout()
    expect(useAuthStore.getState().user).toBeNull()
    expect(useAuthStore.getState().token).toBeNull()
    expect(useAuthStore.getState().isAuthenticated).toBe(false)
  })

  it('should set loading', () => {
    useAuthStore.getState().setLoading(false)
    expect(useAuthStore.getState().isLoading).toBe(false)
  })
})
