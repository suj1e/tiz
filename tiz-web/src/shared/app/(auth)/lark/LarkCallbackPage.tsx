import { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { LoadingState } from '@/components/common/LoadingState'
import { authService } from '@/services/auth'
import { useAuthStore } from '@/stores/authStore'

export default function LarkCallbackPage() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { login, checkAiConfig } = useAuthStore()
  const [error, setError] = useState('')

  useEffect(() => {
    const code = searchParams.get('code')

    if (!code) {
      setError('授权失败：缺少code参数')
      setTimeout(() => navigate('/login'), 2000)
      return
    }

    const handleLarkLogin = async () => {
      try {
        const response = await authService.larkLogin(code)
        login(response.user, response.token)

        // Check AI config status and redirect if needed
        const hasConfig = await checkAiConfig()
        if (!hasConfig) {
          navigate('/ai-config', { replace: true })
        }
        else {
          navigate('/home', { replace: true })
        }
      }
      catch (err) {
        console.error('飞书登录失败:', err)
        setError(err instanceof Error ? err.message : '飞书登录失败')
        setTimeout(() => navigate('/login'), 2000)
      }
    }

    handleLarkLogin()
  }, [searchParams, navigate, login, checkAiConfig])

  if (error) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-destructive text-lg">{error}</div>
          <div className="text-muted-foreground text-sm">正在跳转到登录页...</div>
        </div>
      </div>
    )
  }

  return <LoadingState />
}
