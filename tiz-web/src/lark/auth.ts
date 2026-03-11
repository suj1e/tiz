import { authService } from '@/services/auth'
import { useAuthStore } from '@/stores/authStore'
import { getLarkAuthCode, isInLarkEnv, loadLarkSDK } from './index'

/**
 * Try to login with Lark auth
 * @returns true if login succeeded, false otherwise
 */
export async function tryLarkLogin(): Promise<boolean> {
  if (!isInLarkEnv()) {
    return false
  }

  try {
    await loadLarkSDK()
    const code = await getLarkAuthCode()
    const { user, token } = await authService.larkLogin(code)

    // Use login() to ensure consistent state (localStorage, isAuthenticated, etc.)
    useAuthStore.getState().login(user, token)

    return true
  }
  catch (error) {
    console.error('Lark login failed:', error)
    return false
  }
}
