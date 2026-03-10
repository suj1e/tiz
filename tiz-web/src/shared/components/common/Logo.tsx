import { Link } from 'react-router-dom'
import { cn } from '@/lib/utils'

interface LogoProps {
  className?: string
  showText?: boolean
  asLink?: boolean
}

export function Logo({ className, showText = true, asLink = true }: LogoProps) {
  const content = (
    <div className={cn('flex items-center gap-2', className)}>
      {/* Logo Icon - 渐变方块 T */}
      <div className="relative flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-primary/80 shadow-sm transition-all duration-[var(--duration-normal)] ease-out hover:scale-105 hover:shadow-glow">
        <span className="font-display text-sm font-bold text-primary-foreground">
          T
        </span>
      </div>
      {/* Logo Text */}
      {showText && (
        <span className="font-display text-lg font-semibold">Tiz</span>
      )}
    </div>
  )

  if (asLink) {
    return <Link to="/">{content}</Link>
  }
  return content
}
