import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { startMock } from './mocks/browser'
import './index.css'
import App from './App.tsx'

async function bootstrap() {
  if (import.meta.env.VITE_MOCK === 'true') {
    await startMock()
  }

  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}

bootstrap()
