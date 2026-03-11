import type { ReactNode } from 'react'
import type { User } from '@/types'
import { createContext, useCallback, useContext, useEffect, useState } from 'react'
import { authService } from '@/services/auth'
import { useAuthStore } from '@/stores/authStore'

interface AuthContextValue {
  isLoading: boolean
  isAuthenticated: boolean
  user: User | null
  hasAiConfig: boolean | null
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function useAuthContext(): AuthContextValue {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuthContext must be used within an AuthProvider')
  }
  return context
}

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [isInitialized, setIsInitialized] = useState(false)
  const { user, isAuthenticated, isLoading, hasAiConfig, setUser, setToken, setLoading, checkAiConfig, logout } = useAuthStore()

  const initializeAuth = useCallback(async () => {
    const storedToken = localStorage.getItem('tiz-web-token')
    console.log('[AuthProvider] initializeAuth called, token exists:', !!storedToken)

    if (!storedToken) {
      setLoading(false)
      setIsInitialized(true)
      return
    }

    try {
      // Set token first so api.ts can use it
      setToken(storedToken)
      console.log('[AuthProvider] Token set, fetching user data...')

      // Fetch user data and AI config in parallel
      const [userData] = await Promise.all([
        authService.getCurrentUser(),
        checkAiConfig(),
      ])

      console.log('[AuthProvider] User data fetched:', userData?.email)
      setUser(userData)
    }
    catch (error) {
      // Token invalid or expired
      console.warn('[AuthProvider] Auth initialization failed:', error)
      logout()
    }
    finally {
      setLoading(false)
      setIsInitialized(true)
      console.log('[AuthProvider] Initialization complete')
    }
  }, [setUser, setToken, setLoading, checkAiConfig, logout])

  useEffect(() => {
    initializeAuth()
  }, [initializeAuth])

  // Show loading state during initialization
  if (!isInitialized || isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary border-r-transparent motion-reduce:animate-[spin_1.5s_linear_infinite]" />
          <p className="mt-4 text-muted-foreground">加载中...</p>
        </div>
      </div>
    )
  }

  return (
    <AuthContext
      value={{
        isLoading,
        isAuthenticated,
        user,
        hasAiConfig,
      }}
    >
      {children}
    </AuthContext>
  )
}
