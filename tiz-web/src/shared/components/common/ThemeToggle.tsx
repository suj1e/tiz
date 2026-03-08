import { Moon, Sun, Monitor } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

type Theme = 'light' | 'dark' | 'system'

interface ThemeToggleProps {
  theme?: Theme
  onThemeChange?: (theme: Theme) => void
}

export function ThemeToggle({ theme = 'system', onThemeChange }: ThemeToggleProps) {
  const getIcon = () => {
    switch (theme) {
      case 'light':
        return <Sun className="h-4 w-4" />
      case 'dark':
        return <Moon className="h-4 w-4" />
      default:
        return <Monitor className="h-4 w-4" />
    }
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          {getIcon()}
          <span className="sr-only">切换主题</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem onClick={() => onThemeChange?.('light')}>
          <Sun className="mr-2 h-4 w-4" />
          浅色
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => onThemeChange?.('dark')}>
          <Moon className="mr-2 h-4 w-4" />
          深色
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => onThemeChange?.('system')}>
          <Monitor className="mr-2 h-4 w-4" />
          系统
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
