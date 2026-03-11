import { RouterProvider } from 'react-router-dom'
import { ErrorBoundary } from '@/components/common/ErrorBoundary'
import { Toaster } from '@/components/ui/sonner'
import { useTheme } from '@/hooks/useTheme'
import { AuthProvider } from '@/providers/AuthProvider'
import { router } from './router'

function App() {
  useTheme()

  return (
    <AuthProvider>
      <ErrorBoundary>
        <RouterProvider router={router} />
        <Toaster />
      </ErrorBoundary>
    </AuthProvider>
  )
}

export default App
