import { Component, type ReactNode } from 'react'
import { AlertTriangle, Home, RefreshCw } from 'lucide-react'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class RootErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-screen flex-col items-center justify-center bg-background p-4">
          <div className="text-center">
            <div className="mb-6 inline-flex h-16 w-16 items-center justify-center rounded-full bg-destructive/10">
              <AlertTriangle className="h-8 w-8 text-destructive" />
            </div>
            <h1 className="mb-2 text-2xl font-bold">出错了</h1>
            <p className="mb-2 text-muted-foreground">
              页面加载时发生了错误
            </p>
            {import.meta.env.DEV && this.state.error && (
              <pre className="mb-4 max-w-md overflow-auto rounded-lg bg-muted p-4 text-left text-xs text-muted-foreground">
                {this.state.error.message}
              </pre>
            )}
            <div className="flex justify-center gap-3">
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
              <Link to="/">
                <Button>
                  <Home className="mr-2 h-4 w-4" />
                  返回首页
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
