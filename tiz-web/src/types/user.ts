export interface User {
  id: string
  email: string
  created_at: string
  settings: UserSettings
}

export interface UserSettings {
  theme: 'light' | 'dark' | 'system'
}
