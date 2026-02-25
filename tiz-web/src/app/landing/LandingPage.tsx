import { Link } from 'react-router-dom'
import { BookOpen, MessageSquare, Sparkles } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

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
  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link to="/" className="flex items-center gap-2 font-semibold text-lg">
            <BookOpen className="h-6 w-6" />
            <span>Tiz</span>
          </Link>
          <nav className="flex items-center gap-4">
            <Link to="/login">
              <Button variant="ghost">登录</Button>
            </Link>
            <Link to="/register">
              <Button>注册</Button>
            </Link>
          </nav>
        </div>
      </header>

      {/* Hero */}
      <section className="container mx-auto px-4 py-20 text-center">
        <h1 className="mb-6 text-4xl font-bold tracking-tight lg:text-6xl">
          AI 驱动的知识练习平台
        </h1>
        <p className="mb-8 text-lg text-muted-foreground lg:text-xl">
          通过对话探索学习需求，AI 智能生成个性化练习题
        </p>
        <div className="flex justify-center gap-4">
          <Link to="/chat">
            <Button size="lg">开始试用</Button>
          </Link>
          <Link to="/register">
            <Button size="lg" variant="outline">免费注册</Button>
          </Link>
        </div>
      </section>

      {/* Features */}
      <section className="container mx-auto px-4 py-16">
        <div className="grid gap-6 md:grid-cols-3">
          {features.map((feature) => {
            const Icon = feature.icon
            return (
              <Card key={feature.title}>
                <CardHeader>
                  <Icon className="mb-2 h-10 w-10 text-primary" />
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
          <p>© 2024 Tiz. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}
