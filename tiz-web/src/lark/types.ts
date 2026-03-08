declare global {
  interface Window {
    tt?: {
      requestAuthCode: (options: {
        app_id: string
        success: (res: { code: string }) => void
        fail: (err: unknown) => void
      }) => void
    }
  }
}

export interface LarkUserInfo {
  open_id: string
  name: string
  email?: string
}

export interface LarkAuthResponse {
  code: string
}
