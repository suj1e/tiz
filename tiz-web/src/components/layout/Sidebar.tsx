import { Link, useLocation } from 'react-router-dom'
import { BookOpen, Home, MessageSquare, Settings } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { useUIStore } from '@/stores/uiStore'

const navItems = [
  { path: '/home', label: '首页', icon: Home },
  { path: '/library', label: '题库', icon: BookOpen },
  { path: '/chat', label: '对话', icon: MessageSquare },
  { path: '/settings', label: '设置', icon: Settings },
]

function NavLinks({ onClick }: { onClick?: () => void }) {
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
            onClick={onClick}
            className={cn(
              'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
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

function Logo() {
  return (
    <Link to="/home" className="flex items-center gap-2 font-semibold text-lg">
      <BookOpen className="h-6 w-6" />
      <span>Tiz</span>
    </Link>
  )
}

export function Sidebar() {
  const { sidebarOpen } = useUIStore()

  return (
    <>
      {/* Desktop Sidebar */}
      <aside
        className={cn(
          'hidden lg:flex w-64 flex-col border-r bg-card transition-all',
          !sidebarOpen && 'w-0 overflow-hidden',
        )}
      >
        <div className="flex h-16 items-center border-b px-4">
          <Logo />
        </div>
        <NavLinks />
      </aside>
    </>
  )
}

export function MobileSidebar() {
  const { mobileMenuOpen, setMobileMenuOpen } = useUIStore()

  return (
    <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
      <SheetContent side="left" className="w-64 p-0">
        <div className="flex h-16 items-center border-b px-4">
          <Logo />
        </div>
        <NavLinks onClick={() => setMobileMenuOpen(false)} />
      </SheetContent>
    </Sheet>
  )
}
