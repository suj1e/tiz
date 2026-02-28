import { api } from './api'
import type { UserSettings, WebhookConfig } from '@/types'

export const userService = {
  getSettings: (): Promise<UserSettings> => {
    return api.get<{ data: { settings: UserSettings } }>('/user/v1/settings', { raw: true }).then((res) => res.data.settings)
  },

  updateSettings: (settings: Partial<UserSettings>): Promise<void> => {
    return api.patch('/user/v1/settings', settings)
  },

  getWebhook: (): Promise<{ webhook: WebhookConfig | null }> => {
    return api.get('/user/v1/webhook')
  },

  saveWebhook: (config: WebhookConfig): Promise<{ webhook: WebhookConfig }> => {
    return api.post('/user/v1/webhook', config)
  },

  deleteWebhook: (): Promise<void> => {
    return api.delete('/user/v1/webhook')
  },
}
