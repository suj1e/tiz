import { useAuthStore } from '@/stores/authStore'
import { authService } from '@/services/auth'
import { isInLarkEnv, loadLarkSDK, getLarkAuthCode } from './index'

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

    useAuthStore.getState().setUser(user)
    useAuthStore.getState().setToken(token)

    return true
  } catch (error) {
    console.error('Lark login failed:', error)
    return false
  }
}
