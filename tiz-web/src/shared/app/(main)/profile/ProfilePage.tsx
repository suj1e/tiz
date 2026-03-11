import { Lock, Mail, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAuthStore } from '@/stores/authStore'

export default function ProfilePage() {
  const { user } = useAuthStore()

  const handleEmailChange = () => {
    // TODO: Implement email change functionality
    alert('邮箱修改功能即将上线')
  }

  const handlePasswordChange = () => {
    // TODO: Implement password change functionality
    alert('密码修改功能即将上线')
  }

  const handleDeleteAccount = () => {
    // TODO: Implement account deletion functionality
    if (confirm('确定要删除账户吗？此操作不可恢复。')) {
      alert('账户删除功能即将上线')
    }
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">个人信息</h1>
        <p className="text-muted-foreground">管理你的账户信息</p>
      </div>

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
              <Button variant="ghost" size="sm" onClick={handleEmailChange}>
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
              <Button variant="ghost" size="sm" onClick={handlePasswordChange}>
                修改
              </Button>
            </div>
          </div>

          <div className="pt-4">
            <Button variant="destructive" size="sm" onClick={handleDeleteAccount}>
              <Trash2 className="mr-2 h-4 w-4" />
              删除账户
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
