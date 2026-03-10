export interface User {
  id: string
  email: string
  created_at: string
  settings: UserSettings
}

export interface UserSettings {
  theme: 'light' | 'dark' | 'system'
}

export type WebhookEvent = 'practice.complete' | 'quiz.complete' | 'library.update'

export interface WebhookConfig {
  url: string
  enabled: boolean
  events: WebhookEvent[]
}

export interface AiConfig {
  preferredModel: string
  temperature: number
  maxTokens: number
  systemPrompt: string
  responseLanguage: 'zh' | 'en'
  customApiUrl: string
  customApiKey: string
}

export interface AiConfigStatus {
  isConfigured: boolean
}
