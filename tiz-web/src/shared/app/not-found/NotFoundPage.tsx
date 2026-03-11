import { Link, useNavigate } from 'react-router-dom'
import { Home, ArrowLeft } from 'lucide-react'
import { Button } from '@/components/ui/button'

export default function NotFoundPage() {
  const navigate = useNavigate()

  const handleGoBack = () => {
    // Check if there's history to go back to
    if (window.history.length > 1) {
      navigate(-1)
    } else {
      // No history, go to home
      navigate('/home', { replace: true })
    }
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center text-center p-4">
      <h1 className="mb-4 text-9xl font-bold text-muted-foreground/30">404</h1>
      <h2 className="mb-2 text-2xl font-semibold">页面不存在</h2>
      <p className="mb-8 text-muted-foreground">
        你访问的页面不存在或已被移除
      </p>
      <div className="flex gap-4">
        <Button variant="outline" onClick={handleGoBack}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          返回上页
        </Button>
        <Link to="/home">
          <Button>
            <Home className="mr-2 h-4 w-4" />
            返回首页
          </Button>
        </Link>
      </div>
    </div>
  )
}
