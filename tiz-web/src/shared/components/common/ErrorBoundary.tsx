import { Component, type ReactNode } from 'react'
import { AlertCircle, RefreshCw, Home } from 'lucide-react'
import { Link } from 'react-router-dom'
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
        <div className="flex min-h-[50vh] flex-col items-center justify-center p-4">
          <div className="text-center">
            <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-full bg-destructive/10">
              <AlertCircle className="h-6 w-6 text-destructive" />
            </div>
            <h2 className="mb-2 text-lg font-semibold">页面出错了</h2>
            <p className="mb-4 text-sm text-muted-foreground">
              {this.state.error?.message || '发生了未知错误'}
            </p>
            {import.meta.env.DEV && this.state.error && (
              <pre className="mb-4 max-w-md overflow-auto rounded-lg bg-muted p-3 text-left text-xs text-muted-foreground">
                {this.state.error.message}
              </pre>
            )}
            <div className="flex justify-center gap-3">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  this.setState({ hasError: false })
                  window.location.reload()
                }}
              >
                <RefreshCw className="mr-2 h-4 w-4" />
                刷新
              </Button>
              <Link to="/home">
                <Button size="sm">
                  <Home className="mr-2 h-4 w-4" />
                  首页
                </Button>
              </Link>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}
