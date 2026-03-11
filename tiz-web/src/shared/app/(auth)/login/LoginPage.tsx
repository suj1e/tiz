import { BookOpen } from 'lucide-react'
import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { authService } from '@/services/auth'
import { useAuthStore } from '@/stores/authStore'

export default function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const { login, checkAiConfig } = useAuthStore()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const from = (location.state as { from?: { pathname: string } })?.from?.pathname || '/home'

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    console.log('[LoginPage] handleSubmit called')

    try {
      console.log('[LoginPage] Calling authService.login...')
      const response = await authService.login({ email, password })
      console.log('[LoginPage] Login response:', response)
      login(response.user, response.token)
      console.log('[LoginPage] login() called, checking AI config...')

      // Check AI config status and redirect if needed
      const hasConfig = await checkAiConfig()
      console.log('[LoginPage] AI config check result:', hasConfig)
      if (!hasConfig) {
        console.log('[LoginPage] Navigating to /ai-config')
        navigate('/ai-config', { replace: true })
      }
      else {
        console.log('[LoginPage] Navigating to:', from)
        navigate(from, { replace: true })
      }
    }
    catch (err) {
      console.error('[LoginPage] Login error:', err)
      setError(err instanceof Error ? err.message : '登录失败')
    }
    finally {
      setLoading(false)
    }
  }

  return (
    <Card>
      <CardHeader className="text-center">
        <div className="mb-4 flex justify-center">
          <Link to="/" className="flex items-center gap-2 font-semibold text-lg">
            <BookOpen className="h-6 w-6" />
            <span>Tiz</span>
          </Link>
        </div>
        <CardTitle className="text-2xl">欢迎回来</CardTitle>
        <CardDescription>登录你的账户继续学习</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="rounded-md bg-destructive/10 p-3 text-sm text-destructive">
              {error}
            </div>
          )}
          <div className="space-y-2">
            <Label htmlFor="email">邮箱</Label>
            <Input
              id="email"
              type="email"
              placeholder="your@email.com"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">密码</Label>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
            />
          </div>
          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? '登录中...' : '登录'}
          </Button>
        </form>

        {/* 第三方登录 */}
        <div className="mt-6">
          <div className="relative flex items-center justify-center">
            <hr className="w-full border-t border-muted" />
            <span className="absolute bg-card px-2 text-xs text-muted-foreground">
              其他登录方式
            </span>
          </div>
          <div className="mt-4 flex justify-center">
            <Button
              variant="outline"
              className="w-full gap-2"
              onClick={() => {
                // 飞书OAuth授权跳转，替换为你的飞书APP_ID和回调地址
                const APP_ID = import.meta.env.VITE_LARK_APP_ID
                const REDIRECT_URI = encodeURIComponent(`${window.location.origin}/lark/callback`)
                window.location.href = `https://open.feishu.cn/open-apis/authen/v1/index?app_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&state=login`
              }}
            >
              <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11.967 0C5.396 0 0 5.396 0 11.967C0 18.538 5.396 23.934 11.967 23.934C18.538 23.934 23.934 18.538 23.934 11.967C23.934 5.396 18.538 0 11.967 0Z" fill="#2663EB"/>
                <path d="M16.972 7.077H13.771V11.705H16.972V7.077Z" fill="white"/>
                <path d="M10.162 7.077H6.961V11.705H10.162V7.077Z" fill="white"/>
                <path d="M16.972 13.28H13.771V17.908H16.972V13.28Z" fill="white"/>
                <path d="M10.162 13.28H6.961V17.908H10.162V13.28Z" fill="white"/>
              </svg>
              飞书登录
            </Button>
          </div>
        </div>

        <div className="mt-4 text-center text-sm text-muted-foreground">
          还没有账户？
          {' '}
          <Link to="/register" className="text-primary hover:underline">
            立即注册
          </Link>
        </div>
      </CardContent>
    </Card>
  )
}
