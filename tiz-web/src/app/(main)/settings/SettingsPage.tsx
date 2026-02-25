import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { ThemeToggle } from '@/components/common/ThemeToggle'
import { useUIStore } from '@/stores/uiStore'

export default function SettingsPage() {
  const { theme, setTheme } = useUIStore()
  const [notifications, setNotifications] = useState(true)

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
          <CardTitle>账户</CardTitle>
          <CardDescription>管理你的账户信息</CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            账户管理功能即将推出
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
