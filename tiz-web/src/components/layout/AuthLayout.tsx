import { Outlet } from 'react-router-dom'
import { ThemeToggle } from '@/components/common/ThemeToggle'
import { useUIStore } from '@/stores/uiStore'

export function AuthLayout() {
  const { theme, setTheme } = useUIStore()

  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="absolute right-4 top-4">
        <ThemeToggle theme={theme} onThemeChange={setTheme} />
      </div>
      <div className="w-full max-w-md">
        <Outlet />
      </div>
    </div>
  )
}
