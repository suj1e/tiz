import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Brain, Cpu, Sparkles, Globe, KeyRound, ArrowLeft } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { Slider } from '@/components/ui/slider'
import { userService } from '@/services/user'
import type { AiConfig } from '@/types'
import { toast } from 'sonner'

export default function AiConfigPage() {
  const navigate = useNavigate()
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [config, setConfig] = useState<Partial<AiConfig>>({
    preferredModel: 'gpt-4o',
    temperature: 0.7,
    maxTokens: 4096,
    systemPrompt: 'You are a helpful assistant.',
    responseLanguage: 'zh',
    customApiUrl: 'https://api.openai.com/v1',
    customApiKey: '',
  })

  useEffect(() => {
    loadConfig()
  }, [])

  const loadConfig = async () => {
    try {
      const data = await userService.getAiConfig()
      if (data) {
        setConfig(data)
      }
    } catch (error) {
      console.error('Failed to load AI config:', error)
      // Use default values on error
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      await userService.updateAiConfig(config as AiConfig)
      toast.success('AI 配置已保存')
      navigate('/home')
    } catch (error) {
      console.error('Failed to save AI config:', error)
      toast.error('保存失败，请重试')
    } finally {
      setSaving(false)
    }
  }

  const handleCancel = () => {
    navigate('/home')
  }

  const modelOptions = [
    { value: 'gpt-4o', label: 'GPT-4o', description: '最新的 OpenAI 模型，功能强大' },
    { value: 'gpt-4', label: 'GPT-4', description: 'OpenAI 的高性能模型' },
    { value: 'gpt-3.5-turbo', label: 'GPT-3.5 Turbo', description: '快速且经济的选择' },
    { value: 'claude-3-opus', label: 'Claude 3 Opus', description: 'Anthropic 的最强模型' },
    { value: 'claude-3-sonnet', label: 'Claude 3 Sonnet', description: '平衡性能和速度' },
  ]

  const languageOptions = [
    { value: 'zh', label: '中文' },
    { value: 'en', label: 'English' },
  ]

  if (loading) {
    return (
      <div className="flex min-h-[calc(100vh-4rem)] items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary border-r-transparent motion-reduce:animate-[spin_1.5s_linear_infinite]" />
          <p className="mt-4 text-muted-foreground">加载中...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6 pb-8">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" onClick={handleCancel}>
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-2xl font-semibold">AI 配置</h1>
          <p className="text-muted-foreground">自定义你的 AI 交互体验</p>
        </div>
        <Brain className="h-8 w-8 text-primary" />
      </div>

      {/* Model Selection */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5" />
            模型设置
          </CardTitle>
          <CardDescription>选择你偏好的 AI 模型和相关参数</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Model Selection */}
          <div className="space-y-2">
            <Label htmlFor="model">AI 模型</Label>
            <Select
              value={config.preferredModel}
              onValueChange={(value: string) => setConfig({ ...config, preferredModel: value })}
            >
              <SelectTrigger id="model">
                <SelectValue placeholder="选择 AI 模型" />
              </SelectTrigger>
              <SelectContent>
                {modelOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    <div className="flex flex-col">
                      <span className="font-medium">{option.label}</span>
                      <span className="text-xs text-muted-foreground">{option.description}</span>
                    </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Temperature Slider */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label htmlFor="temperature">温度 (创造性)</Label>
              <span className="text-sm text-muted-foreground">{config.temperature?.toFixed(1)}</span>
            </div>
            <Slider
              id="temperature"
              min={0}
              max={2}
              step={0.1}
              value={[config.temperature ?? 0.7]}
              onValueChange={(value: number[]) => setConfig({ ...config, temperature: value[0] })}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>精确</span>
              <span>平衡</span>
              <span>创造</span>
            </div>
          </div>

          {/* Max Tokens */}
          <div className="space-y-2">
            <Label htmlFor="maxTokens">最大 Token 数</Label>
            <Input
              id="maxTokens"
              type="number"
              min={256}
              max={32768}
              step={256}
              value={config.maxTokens ?? 4096}
              onChange={(e) => setConfig({ ...config, maxTokens: parseInt(e.target.value) || 4096 })}
              placeholder="4096"
            />
            <p className="text-xs text-muted-foreground">
              控制 AI 回复的最大长度，建议值: 2048 - 8192
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Response Settings */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Cpu className="h-5 w-5" />
            响应设置
          </CardTitle>
          <CardDescription>配置 AI 的回复行为和语言</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* System Prompt */}
          <div className="space-y-2">
            <Label htmlFor="systemPrompt">系统提示词</Label>
            <Textarea
              id="systemPrompt"
              value={config.systemPrompt ?? ''}
              onChange={(e) => setConfig({ ...config, systemPrompt: e.target.value })}
              placeholder="You are a helpful assistant."
              rows={4}
              className="resize-none"
            />
            <p className="text-xs text-muted-foreground">
              定义 AI 的角色和行为方式
            </p>
          </div>

          {/* Language Selection */}
          <div className="space-y-2">
            <Label htmlFor="language">回复语言</Label>
            <Select
              value={config.responseLanguage ?? 'zh'}
              onValueChange={(value: string) => setConfig({ ...config, responseLanguage: value as 'zh' | 'en' })}
            >
              <SelectTrigger id="language">
                <SelectValue placeholder="选择语言" />
              </SelectTrigger>
              <SelectContent>
                {languageOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* API Configuration */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Globe className="h-5 w-5" />
            API 配置
          </CardTitle>
          <CardDescription>自定义 API 端点和密钥（可选）</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Custom API URL */}
          <div className="space-y-2">
            <Label htmlFor="apiUrl">自定义 API 地址</Label>
            <Input
              id="apiUrl"
              type="url"
              value={config.customApiUrl ?? ''}
              onChange={(e) => setConfig({ ...config, customApiUrl: e.target.value })}
              placeholder="https://api.openai.com/v1"
            />
            <p className="text-xs text-muted-foreground">
              使用兼容 OpenAI API 的第三方服务时填写
            </p>
          </div>

          {/* Custom API Key */}
          <div className="space-y-2">
            <Label htmlFor="apiKey">API 密钥</Label>
            <div className="relative">
              <KeyRound className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                id="apiKey"
                type="password"
                value={config.customApiKey ?? ''}
                onChange={(e) => setConfig({ ...config, customApiKey: e.target.value })}
                placeholder="sk-..."
                className="pl-9"
              />
            </div>
            <p className="text-xs text-muted-foreground">
              {config.customApiKey ? '••••••••••••••••' : '留空使用默认配置'}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Actions */}
      <div className="flex justify-end gap-3">
        <Button variant="outline" onClick={handleCancel} disabled={saving}>
          取消
        </Button>
        <Button onClick={handleSave} disabled={saving}>
          {saving ? '保存中...' : '保存配置'}
        </Button>
      </div>
    </div>
  )
}
