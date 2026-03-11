import type { User } from '@/types'
import { create } from 'zustand'
import { userService } from '@/services/user'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  hasAiConfig: boolean | null // null = not checked yet
}

interface AuthActions {
  setUser: (user: User | null) => void
  setToken: (token: string | null) => void
  login: (user: User, token: string) => void
  logout: () => void
  setLoading: (loading: boolean) => void
  checkAiConfig: () => Promise<boolean>
  setHasAiConfig: (value: boolean) => void
}

type AuthStore = AuthState & AuthActions

const initialState: AuthState = {
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,
  hasAiConfig: null,
}

export const useAuthStore = create<AuthStore>(set => ({
  ...initialState,
  setUser: (user) => {
    console.log('[AuthStore] setUser called:', user?.email)
    set({ user, isAuthenticated: !!user })
  },
  setToken: (token) => {
    console.log('[AuthStore] setToken called:', token ? 'exists' : 'null')
    set({ token })
  },
  login: (user, token) => {
    console.log('[AuthStore] login called:', user?.email, token ? 'token exists' : 'no token')
    localStorage.setItem('tiz-web-token', token)
    set({ user, token, isAuthenticated: true, isLoading: false })
  },
  logout: () => {
    console.log('[AuthStore] logout called - resetting to initial state')
    localStorage.removeItem('tiz-web-token')
    set(initialState)
  },
  setLoading: isLoading => set({ isLoading }),
  setHasAiConfig: value => set({ hasAiConfig: value }),
  checkAiConfig: async () => {
    try {
      console.log('[AuthStore] checkAiConfig called')
      const status = await userService.getAiConfigStatus()
      set({ hasAiConfig: status.isConfigured })
      return status.isConfigured
    }
    catch (error) {
      console.log('[AuthStore] checkAiConfig error:', error)
      set({ hasAiConfig: false })
      return false
    }
  },
}))
