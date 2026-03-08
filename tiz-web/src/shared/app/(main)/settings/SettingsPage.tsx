import { useState } from 'react'
import { Webhook, Mail, Lock, Trash2 } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { ThemeToggle } from '@/components/common/ThemeToggle'
import { useUIStore } from '@/stores/uiStore'
import { useAuthStore } from '@/stores/authStore'

export default function SettingsPage() {
  const { theme, setTheme } = useUIStore()
  const { user } = useAuthStore()
  const [notifications, setNotifications] = useState(true)
  const [webhookUrl, setWebhookUrl] = useState('')
  const [webhookEnabled, setWebhookEnabled] = useState(false)
  const [webhookEvents, setWebhookEvents] = useState({
    practiceComplete: true,
    quizComplete: true,
    libraryUpdate: false,
  })

  const testWebhook = async () => {
    if (!webhookUrl) return
    // Mock webhook test
    alert('Webhook 测试请求已发送')
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">设置</h1>
        <p className="text-muted-foreground">管理你的账户和偏好设置</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>外观</CardTitle>
          <CardDescription>自定义应用的外观</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <Label>主题</Label>
              <p className="text-sm text-muted-foreground">选择应用的显示主题</p>
            </div>
            <ThemeToggle theme={theme} onThemeChange={setTheme} />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>通知</CardTitle>
          <CardDescription>管理通知设置</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <Label>推送通知</Label>
              <p className="text-sm text-muted-foreground">接收学习提醒和更新通知</p>
            </div>
            <Switch
              checked={notifications}
              onCheckedChange={setNotifications}
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Webhook className="h-5 w-5" />
            Webhook 配置
          </CardTitle>
          <CardDescription>配置 Webhook 以接收事件通知</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <Label>启用 Webhook</Label>
              <p className="text-sm text-muted-foreground">开启后将向配置的 URL 发送事件通知</p>
            </div>
            <Switch
              checked={webhookEnabled}
              onCheckedChange={setWebhookEnabled}
            />
          </div>

          {webhookEnabled && (
            <>
              <div className="space-y-2">
                <Label htmlFor="webhook-url">Webhook URL</Label>
                <div className="flex gap-2">
                  <Input
                    id="webhook-url"
                    type="url"
                    placeholder="https://your-server.com/webhook"
                    value={webhookUrl}
                    onChange={(e) => setWebhookUrl(e.target.value)}
                  />
                  <Button variant="outline" onClick={testWebhook} disabled={!webhookUrl}>
                    测试
                  </Button>
                </div>
              </div>

              <div className="space-y-3">
                <Label>触发事件</Label>
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm">练习完成</span>
                    <Switch
                      checked={webhookEvents.practiceComplete}
                      onCheckedChange={(checked) =>
                        setWebhookEvents({ ...webhookEvents, practiceComplete: checked })
                      }
                    />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">测验完成</span>
                    <Switch
                      checked={webhookEvents.quizComplete}
                      onCheckedChange={(checked) =>
                        setWebhookEvents({ ...webhookEvents, quizComplete: checked })
                      }
                    />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">题库更新</span>
                    <Switch
                      checked={webhookEvents.libraryUpdate}
                      onCheckedChange={(checked) =>
                        setWebhookEvents({ ...webhookEvents, libraryUpdate: checked })
                      }
                    />
                  </div>
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>账户信息</CardTitle>
          <CardDescription>管理你的账户</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-semibold">
              {user?.email?.[0]?.toUpperCase() || 'U'}
            </div>
            <div>
              <p className="font-medium">{user?.email || 'user@example.com'}</p>
              <p className="text-sm text-muted-foreground">免费账户</p>
            </div>
          </div>

          <div className="space-y-3 pt-2">
            <div className="flex items-center justify-between rounded-lg border p-3">
              <div className="flex items-center gap-3">
                <Mail className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm font-medium">邮箱地址</p>
                  <p className="text-xs text-muted-foreground">{user?.email || 'user@example.com'}</p>
                </div>
              </div>
              <Button variant="ghost" size="sm">
                修改
              </Button>
            </div>

            <div className="flex items-center justify-between rounded-lg border p-3">
              <div className="flex items-center gap-3">
                <Lock className="h-4 w-4 text-muted-foreground" />
                <div>
                  <p className="text-sm font-medium">密码</p>
                  <p className="text-xs text-muted-foreground">••••••••</p>
                </div>
              </div>
              <Button variant="ghost" size="sm">
                修改
              </Button>
            </div>
          </div>

          <div className="pt-4">
            <Button variant="destructive" size="sm">
              <Trash2 className="mr-2 h-4 w-4" />
              删除账户
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
