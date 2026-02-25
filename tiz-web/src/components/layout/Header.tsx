import { Menu } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ThemeToggle } from '@/components/common/ThemeToggle'
import { UserMenu } from '@/components/common/UserMenu'
import { useUIStore } from '@/stores/uiStore'

export function Header() {
  const { toggleMobileMenu } = useUIStore()

  return (
    <header className="flex h-16 items-center justify-between border-b bg-card px-4 lg:px-6">
      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          size="icon"
          className="lg:hidden"
          onClick={toggleMobileMenu}
        >
          <Menu className="h-5 w-5" />
        </Button>
      </div>
      <div className="flex items-center gap-2">
        <ThemeToggle />
        <UserMenu />
      </div>
    </header>
  )
}
