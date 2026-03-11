import { BookOpen, MessageSquare, Sparkles } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { Logo } from '@/components/common/Logo'
import { ThemeToggle } from '@/components/common/ThemeToggle'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAuthContext } from '@/providers/AuthProvider'
import { useUIStore } from '@/stores/uiStore'

const features = [
  {
    icon: MessageSquare,
    title: '对话式探索',
    description: '通过自然语言对话，让 AI 理解你的学习需求',
  },
  {
    icon: Sparkles,
    title: 'AI 生成题目',
    description: '智能生成选择题和简答题，支持多种难度',
  },
  {
    icon: BookOpen,
    title: '题库管理',
    description: '保存题目到个人题库，随时回顾和练习',
  },
]

export default function LandingPage() {
  const navigate = useNavigate()
  const { theme, setTheme } = useUIStore()
  const { isAuthenticated, hasAiConfig } = useAuthContext()

  const handleStartTrial = () => {
    if (!isAuthenticated) {
      navigate('/login')
    }
    else if (hasAiConfig === false) {
      navigate('/ai-config')
    }
    else {
      navigate('/chat')
    }
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Logo />
          <nav className="flex items-center gap-4">
            <ThemeToggle theme={theme} onThemeChange={setTheme} />
            <Link to="/login">
              <Button variant="ghost">登录</Button>
            </Link>
            <Link to="/register">
              <Button>注册</Button>
            </Link>
          </nav>
        </div>
      </header>

      {/* Hero with gradient background and glow effect */}
      <section className="relative container mx-auto px-4 py-20 text-center overflow-hidden">
        {/* Subtle gradient background */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-background to-accent/5" />
        </div>
        {/* Glow effect at bottom right */}
        <div className="absolute -bottom-32 -right-32 h-64 w-64 rounded-full bg-primary/20 blur-3xl" />

        <h1 className="mb-6 font-display text-4xl font-bold tracking-tight lg:text-6xl">
          AI 驱动的知识练习平台
        </h1>
        <p className="mb-8 text-lg text-muted-foreground lg:text-xl">
          通过对话探索学习需求，AI 智能生成个性化练习题
        </p>
        <div className="flex justify-center gap-4">
          <Button
            size="lg"
            className="hover:scale-[1.02] transition-transform duration-200"
            onClick={handleStartTrial}
          >
            开始试用
          </Button>
          <Link to="/register">
            <Button size="lg" variant="outline" className="hover:scale-[1.02] transition-transform duration-200">
              免费注册
            </Button>
          </Link>
        </div>
      </section>

      {/* Features with hover effects */}
      <section className="container mx-auto px-4 py-16">
        <div className="grid gap-6 md:grid-cols-3">
          {features.map((feature) => {
            const Icon = feature.icon
            return (
              <Card
                key={feature.title}
                className="transition-all duration-300 hover:-translate-y-1 hover:shadow-lg"
              >
                <CardHeader>
                  <Icon className="mb-2 h-10 w-10 text-primary transition-transform duration-300 hover:-rotate-12" />
                  <CardTitle>{feature.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription>{feature.description}</CardDescription>
                </CardContent>
              </Card>
            )
          })}
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t py-8">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>© 2026 Tiz. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}
