import { Link, useLocation } from 'react-router-dom'
import { Home, Settings, BookOpen } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Logo } from '@/components/common/Logo'

const navItems = [
  { path: '/home', label: '首页', icon: Home },
  { path: '/library', label: '题库', icon: BookOpen },
  { path: '/settings', label: '设置', icon: Settings },
]

function NavLinks() {
  const location = useLocation()

  return (
    <nav className="flex-1 space-y-1 p-4">
      {navItems.map((item) => {
        const isActive = location.pathname === item.path
        const Icon = item.icon
        return (
          <Link
            key={item.path}
            to={item.path}
            className={cn(
              'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-all',
              isActive
                ? 'bg-primary text-primary-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            )}
          >
            <Icon className="h-4 w-4" />
            {item.label}
          </Link>
        )
      })}
    </nav>
  )
}

export function Sidebar() {
  return (
    <aside className="flex w-64 flex-col border-r bg-card">
      <div className="flex h-16 items-center border-b px-4">
        <Logo asLink={false} />
      </div>
      <NavLinks />
    </aside>
  )
}
