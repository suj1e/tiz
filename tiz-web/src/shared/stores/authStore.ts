import { create } from 'zustand'
import type { User } from '@/types'
import { userService } from '@/services/user'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  hasAiConfig: boolean | null  // null = not checked yet
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

export const useAuthStore = create<AuthStore>((set) => ({
  ...initialState,
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setToken: (token) => set({ token }),
  login: (user, token) => {
    localStorage.setItem('tiz-web-token', token)
    set({ user, token, isAuthenticated: true, isLoading: false })
  },
  logout: () => {
    localStorage.removeItem('tiz-web-token')
    set(initialState)
  },
  setLoading: (isLoading) => set({ isLoading }),
  setHasAiConfig: (value) => set({ hasAiConfig: value }),
  checkAiConfig: async () => {
    try {
      const status = await userService.getAiConfigStatus()
      set({ hasAiConfig: status.isConfigured })
      return status.isConfigured
    } catch {
      set({ hasAiConfig: false })
      return false
    }
  },
}))
