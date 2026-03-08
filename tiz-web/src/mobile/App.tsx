import { RouterProvider } from 'react-router-dom'
import { Toaster } from '@/components/ui/sonner'
import { ErrorBoundary } from '@/components/common/ErrorBoundary'
import { router } from './router'
import { useTheme } from '@/hooks/useTheme'

function App() {
  useTheme()

  return (
    <ErrorBoundary>
      <RouterProvider router={router} />
      <Toaster />
    </ErrorBoundary>
  )
}

export default App
