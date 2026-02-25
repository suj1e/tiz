import { Component, type ReactNode } from 'react'
import { AlertCircle, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback
      }

      return (
        <div className="flex min-h-screen flex-col items-center justify-center text-center p-4">
          <AlertCircle className="mb-4 h-12 w-12 text-destructive" />
          <h2 className="mb-2 text-xl font-semibold">页面出错了</h2>
          <p className="mb-4 text-muted-foreground">
            {this.state.error?.message || '发生了未知错误'}
          </p>
          <Button
            variant="outline"
            onClick={() => {
              this.setState({ hasError: false })
              window.location.reload()
            }}
          >
            <RefreshCw className="mr-2 h-4 w-4" />
            刷新页面
          </Button>
        </div>
      )
    }

    return this.props.children
  }
}
