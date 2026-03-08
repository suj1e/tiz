import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '@/stores/authStore'
import { authService } from '@/services/auth'

export function useAuth(requireAuth = false) {
  const navigate = useNavigate()
  const { user, isAuthenticated, isLoading, login, logout, setLoading } = useAuthStore()

  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('tiz-web-token')

      if (!token) {
        setLoading(false)
        if (requireAuth) {
          navigate('/login')
        }
        return
      }

      try {
        const userData = await authService.getCurrentUser()
        login(userData, token)
      }
      catch {
        logout()
        localStorage.removeItem('tiz-web-token')
        if (requireAuth) {
          navigate('/login')
        }
      }
      finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [])

  return {
    user,
    isAuthenticated,
    isLoading,
    login,
    logout,
  }
}
