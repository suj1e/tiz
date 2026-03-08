export const LARK_APP_ID = import.meta.env.VITE_LARK_APP_ID || ''

/**
 * Check if running inside Lark/Feishu environment
 */
export function isInLarkEnv(): boolean {
  const ua = navigator.userAgent
  return (
    ua.includes('Lark') ||
    ua.includes('Feishu') ||
    new URLSearchParams(window.location.search).has('mock_lark')
  )
}

/**
 * Load Lark H5 SDK dynamically
 */
export function loadLarkSDK(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.tt) {
      resolve()
      return
    }

    const script = document.createElement('script')
    script.src = 'https://lf1-cdn-tos.bytegoofy.com/obj/h5sdk/h5sdk.js'
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('Failed to load Lark SDK'))
    document.head.appendChild(script)
  })
}

/**
 * Get auth code from Lark SDK
 */
export function getLarkAuthCode(): Promise<string> {
  return new Promise((resolve, reject) => {
    if (!window.tt) {
      reject(new Error('Lark SDK not loaded'))
      return
    }

    window.tt.requestAuthCode({
      app_id: LARK_APP_ID,
      success: (res) => resolve(res.code),
      fail: (err) => reject(err),
    })
  })
}
