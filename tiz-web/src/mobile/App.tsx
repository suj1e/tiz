import { RouterProvider } from 'react-router-dom'
import { Toaster } from '@/components/ui/sonner'
import { ErrorBoundary } from '@/components/common/ErrorBoundary'
import { AuthProvider } from '@/providers/AuthProvider'
import { router } from './router'
import { useTheme } from '@/hooks/useTheme'

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
