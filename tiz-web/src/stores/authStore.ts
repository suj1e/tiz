import { create } from 'zustand'
import type { User } from '@/types'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
}

interface AuthActions {
  setUser: (user: User | null) => void
  setToken: (token: string | null) => void
  login: (user: User, token: string) => void
  logout: () => void
  setLoading: (loading: boolean) => void
}

type AuthStore = AuthState & AuthActions

const initialState: AuthState = {
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,
}

export const useAuthStore = create<AuthStore>((set) => ({
  ...initialState,
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setToken: (token) => set({ token }),
  login: (user, token) => set({ user, token, isAuthenticated: true, isLoading: false }),
  logout: () => set(initialState),
  setLoading: (isLoading) => set({ isLoading }),
}))
