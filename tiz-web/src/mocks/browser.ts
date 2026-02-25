import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)

export async function startMock() {
  if (import.meta.env.VITE_MOCK === 'true') {
    await worker.start({
      onUnhandledRequest: 'bypass',
    })
  }
}
