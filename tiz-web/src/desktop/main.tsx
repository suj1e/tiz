import { tryLarkLogin } from '@lark/auth'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { startMock } from '@/mocks/browser'
import App from './App'
import '@/index.css'

async function bootstrap() {
  if (import.meta.env.VITE_MOCK === 'true') {
    await startMock()
  }

  // Try Lark login first if in Lark environment
  await tryLarkLogin()

  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}

bootstrap()
