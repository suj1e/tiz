import { api } from './api'
import type { UserSettings } from '@/types'

export const userService = {
  getSettings: (): Promise<UserSettings> => {
    return api.get('/user/v1/settings')
  },

  updateSettings: (settings: Partial<UserSettings>): Promise<UserSettings> => {
    return api.patch('/user/v1/settings', settings)
  },
}
