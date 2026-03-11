import { BookOpen, Home, Settings } from 'lucide-react'
import { Link, useLocation } from 'react-router-dom'
import { cn } from '@/lib/utils'

const navItems = [
  { path: '/home', label: '首页', icon: Home },
  { path: '/library', label: '题库', icon: BookOpen },
  { path: '/settings', label: '设置', icon: Settings },
]

export function BottomNav() {
  const location = useLocation()

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 flex h-16 items-center justify-around border-t bg-card">
      {navItems.map((item) => {
        const isActive = location.pathname === item.path
        const Icon = item.icon
        return (
          <Link
            key={item.path}
            to={item.path}
            className={cn(
              'flex flex-1 flex-col items-center justify-center gap-1 py-2 text-xs transition-all',
              isActive
                ? 'text-primary'
                : 'text-muted-foreground',
            )}
          >
            <Icon className={cn(
              'h-5 w-5 transition-transform',
              isActive && 'scale-110',
            )}
            />
            <span className="font-medium">{item.label}</span>
          </Link>
        )
      })}
    </nav>
  )
}
